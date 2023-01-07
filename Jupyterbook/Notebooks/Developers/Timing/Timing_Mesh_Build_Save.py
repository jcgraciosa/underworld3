# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.1
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# # Mesh save / load from hdf5
#
# Build (`gmsh`) meshes for various resolutions and then save them as hdf5 files. After that, reload the mesh. Note that the gmsh part is serial so we are really checking that this is properly managed and that the parallel save does not blow up. 
#
# The script can be run with a negative testing level which will skip the build and re-use the old mesh. This is designed to evaluate the loading of hdf5 dmplex mesh checkpoints for decomposed meshes cleanly.
#
# For most 3D cases, the serial bottleneck is enough that we probably prefer to create the meshes in advance and read them from the h5 checkpoint (we know that because of this timing file !).
#

# +
import os
os.environ["UW_TIMING_ENABLE"] = "1"
os.environ["SYMPY_USE_CACHE"] = "no"

import petsc4py
from petsc4py import PETSc

import underworld3 as uw
from underworld3.systems import Stokes
from underworld3 import function

import numpy as np
import sympy

free_slip_upper = True


# Define the problem size
#      1 - ultra low res for automatic checking
#      2 - low res problem to play with this notebook
#      3 - medium resolution (be prepared to wait)
#      4 - highest resolution (benchmark case from Spiegelman et al)

problem_size = 2

# For testing and automatic generation of notebook output,
# over-ride the problem size if the UW_TESTING_LEVEL is set

uw_testing_level = os.environ.get("UW_TESTING_LEVEL")
if uw_testing_level:
    try:
        problem_size = int(uw_testing_level)
    except ValueError:
        # Accept the default value
        pass
    
r_o = 1.0
r_i = 0.5


if problem_size < 0:
    problem_size = -problem_size
    skip_gmsh = True
else:
    skip_gmsh = False

if problem_size <= 1:
    res = 0.05
elif problem_size == 2:
    res = 0.025
elif problem_size == 3:
    res = 0.01
elif problem_size == 4:
    res = 0.005
elif problem_size == 5:
    res = 0.002
elif problem_size == 6:
    res = 0.001
elif problem_size == 7:
    res = 0.0005

# +
from underworld3 import timing

timing.reset()
timing.start()

# +
# Annulus first, then sphere !

tmp_filename = f".meshes/uw_mesh_h5_test2d_res{problem_size}.msh"

if not skip_gmsh:
    mesh1 = uw.meshing.Annulus(radiusOuter=r_o, 
                               radiusInner=r_i, 
                               cellSize=res,
                               filename=tmp_filename)

    if uw.mpi.rank == 0:
        print("2d mesh generation complete", flush=True)

    mesh1.dm.view()    
    
# -

if uw.mpi.rank == 0:
    print("Read back 2d mesh", flush=True)

mesh2 = uw.discretisation.Mesh(tmp_filename + ".h5")
mesh2.dm.view()

timing.print_table(display_fraction=0.999)

# +
## Now the sphere:

timing.reset()
timing.start()

# +
if problem_size <= 1: 
    cell_size = 0.30
elif problem_size == 2: 
    cell_size = 0.15
elif problem_size == 3: 
    cell_size = 0.05
elif problem_size == 4: 
    cell_size = 0.03
elif problem_size == 5: 
    cell_size = 0.02
elif problem_size == 6: 
    cell_size = 0.01
elif problem_size == 7: 
    cell_size = 0.005
    
res = cell_size

# +
tmp_filename = f".meshes/uw_mesh_h5_test3d_res{problem_size}.msh"

if not skip_gmsh:
    mesh3 = uw.meshing.SphericalShell(
        radiusInner=r_i, 
        radiusOuter=r_o, 
        cellSize=res, 
        qdegree=2,
        filename = tmp_filename
    )

    if uw.mpi.rank == 0:
        print("3d mesh generation complete", flush=True)

    mesh1.dm.view()

if uw.mpi.rank == 0:
    print("Read back 3d mesh", flush=True)

# -

mesh4 = uw.discretisation.Mesh(tmp_filename+".h5")
mesh4.dm.view()

timing.print_table(display_fraction=1)


