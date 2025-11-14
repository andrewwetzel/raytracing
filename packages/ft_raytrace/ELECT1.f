C     APPENDIX 4. PERTURBATIONS TO ELECTRON DENSITY MODELS WITH INPUT
C     PARAMETER FORMS
C
C     The following perturbations to electron density models (irregularities)
C     are available. The input parameter forms, which describe the
C     perturbation, and the subroutine listings are given on the pages shown.
C
C     a. Do-nothing perturbation (ELECT1)
C     b. East-west irregularity with an elliptical cross-section
C        above the equator (TORUS)
C     c. Two east-west irregularities with elliptical cross-sections
C        above the equator (DTORUS)
C     d. Increase in electron density at any latitude (TROUGH)
C     e. Increase in electron density produced by a shock wave (SHOCK)
C     f. "Gravity-wave" irregularity (WAVE)
C     g. "Gravity-wave" irregularity (WAVE2)
C     h. Height profile of time derivative of electron
C        density for calculating Doppler shift (DOPPLER)
C
C     To add other perturbations to electron density models the user must
C     write a subroutine to modify the normalized electron density (X) and
C     its gradient (aX / or, aX / a e, aX / aqJ) as a function of position
C     in spherical polar coordinates {r, e, CIl.
C
C     The restrictions on electron density models also apply to
C     perturbations. Again, the coordinates r, e, qJ refer to the
C     computational coordinate system, which may not be the same as
C     geographic coordinates. In particular, they are geomagnetic
C     coordinates when the earth-centered dipole model of the earth's
C     magnetic field is used.
C
C     The input to the subroutine is through blank common (see Table 3)
C     for the position (r, e, cp) and through common block /XX/
C     (see Table 8) for the unperturbed electron density and its gradient.
C     The output is through common block /XX/. It is useful if the name
C     of the subroutine suggests the perturbation model to which it
C     corresponds. It should have an entry point ELECT1 so that it may be
C     called by an electron density subroutine. Any parameters needed
C     by the subroutine should be input into W(151) through W(199)
C     of the W array. (See Table 2.)
C
C-----------------------------------------------------------------------
C
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
C     Equivalence PERT to W(151). This means the variable PERT
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