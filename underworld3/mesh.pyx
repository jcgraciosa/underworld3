from petsc4py.PETSc cimport DM, PetscDM, DS, PetscDS, Vec, PetscVec, PetscIS, PetscDM, PetscSF
from .petsc_types cimport PetscInt, PetscReal, PetscScalar, PetscErrorCode, PetscBool, DMBoundaryConditionType, PetscDSResidualFn, PetscDSJacobianFn
from .petsc_types cimport PtrContainer
from petsc4py import PETSc
from .petsc_gen_xdmf import generateXdmf
import numpy as np
import sympy

cdef extern from "petsc.h" nogil:
    PetscErrorCode DMCreateSubDM(PetscDM, PetscInt, const PetscInt *, PetscIS *, PetscDM *)
    PetscErrorCode DMPlexSetMigrationSF( PetscDM, PetscSF )
    PetscErrorCode DMPlexGetMigrationSF( PetscDM, PetscSF*)

class Mesh():

    def __init__(self, 
                elementRes=(16, 16), 
                minCoords=None,
                maxCoords=None,
                simplex=False,
                interpolate=False):
        options = PETSc.Options()
        options["dm_plex_separate_marker"] = None
        self.elementRes = elementRes
        if minCoords==None : minCoords=len(elementRes)*(0.,)
        self.minCoords = minCoords
        if maxCoords==None : maxCoords=len(elementRes)*(1.,)
        self.maxCoords = maxCoords
        self.isSimplex = simplex
        self.dm = PETSc.DMPlex().createBoxMesh(
            elementRes, 
            lower=minCoords, 
            upper=maxCoords,
            simplex=simplex)
        part = self.dm.getPartitioner()
        part.setFromOptions()
        self.dm.distribute()
        self.dm.setFromOptions()

        # from sympy import MatrixSymbol
        # self._x = MatrixSymbol('x', m=1, n=self.dim)

        from sympy.vector import CoordSys3D
        self._N = CoordSys3D("N")
        self._r = self._N.base_scalars()[0:self.dim]

        import weakref
        self._vars = weakref.WeakValueDictionary()

        # sort bcs
        from enum import Enum
        class Boundary2D(Enum):
            BOTTOM = 1
            RIGHT  = 2
            TOP    = 3
            LEFT   = 4
        class Boundary3D(Enum):
            BOTTOM = 1
            TOP    = 2
            FRONT  = 3
            BACK   = 4
            RIGHT  = 5
            LEFT   = 6
        
        if len(elementRes) == 2:
            self.boundary = Boundary2D
        else:
            self.boundary = Boundary3D

        for ind,val in enumerate(self.boundary):
            boundary_set = self.dm.getStratumIS("marker",ind+1)        # get the set
            self.dm.createLabel(str(val).encode('utf8'))               # create the label
            boundary_label = self.dm.getLabel(str(val).encode('utf8')) # get label
            if boundary_set:
                boundary_label.insertIS(boundary_set, 1) # add set to label with value 1

        self.dm.view()

    @property
    def N(self):
        return self._N

    @property
    def r(self):
        return self._r

    @property
    def data(self):
        # get flat array
        arr = self.dm.getCoordinatesLocal().array
        # get number of nodes
        nnodes = len(arr)/self.dim
        # round & cast to int to ensure correct value
        nnodes = int(round(nnodes))
        return arr.reshape((nnodes, self.dim))

    @property
    def dim(self):
        """ Number of dimensions of the mesh """
        return self.dm.getDimension()

    def save(self, filename):
        viewer = PETSc.Viewer().createHDF5(filename, "w")
        viewer(self.dm)
        generateXdmf(filename)

    def add_mesh_variable(self):
        return

    @property
    def vars(self):
        return self._vars

# class MeshVariable(sympy.Function):
#     def __new__(cls, mesh, *args, **kwargs):
#         # call the sympy __new__ method without args/kwargs, as unexpected args 
#         # trip up an exception.  
#         obj = super(MeshVariable, cls).__new__(cls, mesh.N.base_vectors()[0:mesh.dim])
#         return obj
    
#     @classmethod
#     def eval(cls, x):
#         return None

#     def _ccode(self, printer):
#         # return f"{type(self).__name__}({', '.join(printer._print(arg) for arg in self.args)})_bobobo"
#         return f"petsc_u[0]"

from enum import Enum
class VarType(Enum):
    SCALAR=1
    VECTOR=2
    OTHER=3  # add as required 

class MeshVariable:

    def __init__(self, mesh, num_components, name, vtype, isSimplex=False):
        if name in mesh.vars.keys():
            raise ValueError("Variable with name {} already exists on mesh.".format(name))
        if not isinstance(vtype, VarType):
            raise ValueError("'vtype' must be an instance of 'Variable_Type', for example `uw.mesh.VarType.SCALAR`.")
        self.vtype = vtype
        self.mesh = mesh
        self.num_components = num_components
        self.petsc_fe = PETSc.FE().createDefault(mesh.dm.getDimension(), num_components, isSimplex, PETSc.DEFAULT, name+"_", PETSc.COMM_WORLD)
        self.field_id = mesh.dm.getNumFields()
        mesh.dm.setField(self.field_id,self.petsc_fe)
        # create associated sympy function
        if   vtype==VarType.SCALAR:
            self._fn = sympy.Function(name)(*self.mesh.r)
        elif vtype==VarType.VECTOR:
            if num_components!=mesh.dim:
                raise ValueError("For 'VarType.VECTOR' types 'num_components' must equal 'mesh.dim'.")
            from sympy.vector import VectorZero
            self._fn = VectorZero()
            subnames = ["_x","_y","_z"]
            for comp in range(num_components):
                subfn = sympy.Function(name+subnames[comp])(*self.mesh.r)
                self._fn += subfn*self.mesh.N.base_vectors()[comp]
        super().__init__()
        # now add to mesh list
        self.mesh.vars[name] = self
        # create a subdm for this variable. 
        # this allows us to extract corresponding arrays.
        # cdef DM subdm = PETSc.DMPlex()
        # cdef PetscInt fields = self.field_id
        # cdef DM dm = self.mesh.dm
        # DMCreateSubDM(dm.dm, 1, &fields, NULL, &subdm.dm)
        # cdef PetscSF sf
        # DMPlexGetMigrationSF( subdm.dm, &sf)
        # DMPlexSetMigrationSF(    dm.dm,  sf)
        # self.dm = subdm
        # self.data = self.dm.createLocalVector()

    @property
    def fn(self):
        return self._fn

    