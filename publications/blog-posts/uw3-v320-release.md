---
title: "Underworld3 v3.2.0: dropping while it's hot!" 
description: >-
  The latest quarterly release of Underworld3. Ten new capabilities now
  validated, faults can be cut into a mesh as real
  discontinuities, and the free surface runs in three dimensions on a spherical
  shell.
date: 2026-10-08
authors:
  - name: Juan Carlos Graciosa and the Underworld team 
    orcid: 0000-0000-0000-0000
    affiliations:
      - Australian National University
license: CC-BY-4.0
banner: figures/banner.png
keywords:
  - Underworld Code
  - release
  - development
exports:
  - format: typst
    logo: ../../static/uwtn-logo.png
    series: "Underworld Technical Notes"
    origin_url: https://www.underworldcode.org/underworld3-v3-2-0/
    template: ../../templates/pdf
    output: underworld3-v3-2-0.pdf
    article_id: UWTN 2026-0XX
    article_version: 1.0.0
    software_version: underworld3 v3.2.0
---
<div class="uwtn-banner"><img src="figures/banner.png" alt=""></div>

Underworld3 v3.2.0 is out! Ten capabilities are newly announced as supported, seven as preview and one as experimental! 

## What's new

| Capability | What it does | Status | Documentation |
|---|---|---|---|
| **Analytic Benchmark Solutions** | Closed-form solutions for verifying solver convergence rates | Supported | [analytic](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/api/analytic.md) · [analytic-solutions](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/developer/subsystems/analytic-solutions.md) · [example: Ex_Stokes_Cartesian_SolC](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/examples/fluid_mechanics/advanced/Ex_Stokes_Cartesian_SolC.py) |
| **Boundary Conditions on Curved Surfaces** | Free-slip and traction conditions using true geometric normals | Supported | [Free-slip boundary conditions on curved boundaries](/boundary-conditions-on-non-planar-boundaries/) · [example: Ex_Stokes_Annulus_Benchmark_Kramer](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/examples/fluid_mechanics/advanced/Ex_Stokes_Annulus_Benchmark_Kramer.py) |
| **Checkpoint and Restart** | Snapshots, on-disk checkpoints and exact same-mesh reload | Supported | [snapshot-restore](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/snapshot-restore.md) · [create_xdmf](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/beginner/create_xdmf.md) |
| **Constitutive Models** | Viscous, viscoplastic, viscoelastic-plastic, diffusion and Darcy laws | Supported (VEP failures fixed) | [Constitutive Models in Symbolic Form](/constitutive-models-in-symbolic-form/) · [example: vep-square](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/benchmarks/vep-square.md) |
| **Geometric Multigrid / FMG Preconditioner** | Geometric full-multigrid preconditioning on refinement meshes | Supported (was Preview) | [Setting Up Full Multigrid](/setting-up-full-multigrid/) · [example: bench_fmg_vs_gamg_velocity_ksp](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/figures/bench_fmg_vs_gamg_velocity_ksp.md) |
| **Material History Transport** | Semi-Lagrangian, BDF and Adams-Moulton behind one D/Dt interface | Supported | [systems_ddt](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/api/systems_ddt.md) · [semi-lagrangian-time-integration](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/semi-lagrangian-time-integration.md) · [particle-population-and-materials](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/particle-population-and-materials.md) |
| **Materials Registry and Distribution** | Separates what a material is from where it is | Supported | [materials](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/api/materials.md) · [example: particle-population-and-materials](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/particle-population-and-materials.md) |
| **SUPG-Stabilised Transport** | SUPG stabilisation, the default for advection-diffusion and Navier-Stokes | Supported | [eulerian-navier-stokes](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/eulerian-navier-stokes.md) · [eulerian-advection-diffusion](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/eulerian-advection-diffusion.md) · [solvers](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/api/solvers.md) |
| **Stress Tensor Visualisation** | Principal-stress glyphs and stress trajectories | Supported | [stress-visualisation](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/stress-visualisation.md) |
| **Variable Data Access Contract** | One canonical write path for mesh and swarm variable data | Supported | [Mesh Variables and PETSc Vectors](/mesh-variables-and-petsc-vectors-keeping-arrays-in-sync/) · [example: 2-Variables](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/beginner/tutorials/2-Variables.ipynb) |
| **Consistent Boundary Flux Recovery** | Pointwise surface flux recovered from the interior residual | Preview | [boundary_flux](https://github.com/underworldcode/underworld3/blob/v3.2.0/src/underworld3/utilities/boundary_flux.py) · [test_1019](https://github.com/underworldcode/underworld3/blob/v3.2.0/tests/test_1019_boundary_flux.py) |
| **Fault Networks and Split-Node Faults** | Faults as real mesh discontinuities rather than smeared weak zones | Preview | [Faults: to mesh or not to mesh?](/putting-a-fault-in-a-mesh/) |
| **Integration-Point Variables** | Material history stored at quadrature points rather than mesh nodes | Preview | [integration-point-variables](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/developer/subsystems/integration-point-variables.md) |
| **Point Location and Function Evaluation** | Point location and symbolic evaluation in a distributed mesh | Preview | [Finding Particles in a Distributed, Unstructured Mesh](/finding-particles-in-a-distributed-unstructured-mesh/) · [example: 3-Symbolic_Forms](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/beginner/tutorials/3-Symbolic_Forms.ipynb) |
| **Prognostic Free Surface** | Surface height relaxing toward stress-derived equilibrium topography | Preview | [Free surface in Underworld](/free-surface-in-underworld/) |
| **Solver Control and Reporting** | Per-iteration callbacks, convergence reporting and stall detection | Preview | [solver-iteration-callbacks](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/solver-iteration-callbacks.md) |
| **Transverse-Isotropic Rheology** | Anisotropic viscosity with a director | Preview (one accuracy drift unresolved) | [vep-transverse-isotropy-faults](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/vep-transverse-isotropy-faults.md) · [bench: ti_vep](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/benchmarks/) |
| **Geoid and Self-Gravity Response** | Geoid and self-gravity response for spherical shells and annuli | Experimental | [postprocessing](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/api/postprocessing.md) |

## A few worth calling out

Geometric multigrid will matter a lot to those running big Stokes problems. If you have been letting Underworld fall back to algebraic multigrid without thinking about it, [Setting Up Full Multigrid](/setting-up-full-multigrid/) explains what the difference is worth. 

Free-slip and traction conditions on curved boundaries are supported, which matters for modelling a lot of problems. Documentation is in [Boundary conditions on non-planar boundaries](/boundary-conditions-on-non-planar-boundaries/).

SUPG stabilisation is now the default for both advection-diffusion and Navier-Stokes, so most models pick it up without being asked. Against the semi-Lagrangian alternative it is cheaper per step and much more accurate with small Courant numbers. Above a Courant number of about 2 the semi-Lagrangian scheme is better. [Eulerian Navier-Stokes](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/eulerian-navier-stokes.md) and [Eulerian advection-diffusion](https://github.com/underworldcode/underworld3/blob/v3.2.0/docs/advanced/eulerian-advection-diffusion.md) document the trade.

The largest body of work this quarter went into faults. You can now specify a fault network once, as a trace and a hierarchy, and have it realised either as a split-node cut with contact laws or as a volumetric weak plane. Faults can now be modelled as real mesh discontinuities rather than smeared weak zones. [Faults: to mesh or not to mesh?](/putting-a-fault-in-a-mesh/) covers the choice and why it is not obvious.

The prognostic free surface is now dimension-general and runs in three dimensions on a spherical shell. [A free surface in Underworld](/free-surface-in-underworld/) describes the method.

## Things that will break

There are five breaking API changes. They are listed with migration guidance in the release notes.

## Come have a look

```bash
git clone --branch v3.2.0 https://github.com/underworldcode/underworld3.git
```

Containers are at `ghcr.io/underworldcode/underworld3`, and if you would rather
not install anything at all, you can run a notebook in your browser — see
[Running Underworld in a Browser](/running-underworld-in-a-browser/).

The full [release notes](https://github.com/underworldcode/underworld3/releases/tag/v3.2.0) list every bug fix, improvement and breaking change, and the names of everyone who contributed. 
