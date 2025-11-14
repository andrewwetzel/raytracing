C     If no perturbation is wanted, the following subroutine should be used.
C
      SUBROUTINE ELECT1
C
C     USE WHEN AN ELECTRON DENSITY PERTURBATION IS NOT WANTED
C
C     Common blocks for sharing data with other subroutines
      COMMON /XX/ MODX,X(6)
      COMMON /WW/ ID(10),WQ,W(400)
C
C     Declare MODX as a CHARACTER*6 array. This must match
C     all other declarations of the /XX/ common block.
      CHARACTER*6 MODX(2)
C
C     Equivalence PERT to W(1D1). This means the variable PERT
C     shares the same memory location as the 151st element of array W.
      EQUIVALENCE (PERT,W(151))
C
C     Set the perturbation flag/value to 0 (no perturbation).
      PERT=0.
C
C     Set the perturbation model name to ' NONE'
C     This is an EXECUTABLE statement, which runs every time.
      MODX(2) = ' NONE'
C
      RETURN
      END