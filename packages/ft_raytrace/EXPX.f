        SUBROUTINE EXPX

C     Common blocks for sharing data
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM
      COMMON /XX/ MODX,X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON /WW/ ID(10),WQ,W(400)
C
C     Blank common for position (R = radius, TH = theta, PH = phi)
      COMMON R, TH, PH
C
C     Declare types for /XX/ block, must match test harness & ELECT1
      CHARACTER*6 MODX(2)
      REAL X, PXPR, PXPTH, PXPPH, PXPT, HMAX
C
C     Equivalence variables to their locations in the W array
      EQUIVALENCE (EARTHR,W(2)),(F,W(61)),
     1 (NO,W(101)),(HO,W(102)),(A,W(103)),(PERT,W(151))
C
C     Declare local variable types
      REAL N, NO, K, H, R, TH, PH
C
C     Set model name and max height. These are executable.
      MODX(1) = ' EXPX'
      HMAX = 350.
C
C     ENTRY point for electron density calculation
      ENTRY ELECTX
C
C     Calculate height above Earth
      H = R - EARTHR
C
C     Calculate electron density using exponential model
      N = NO * EXP(A*(H-HO))
C
C     Calculate normalized density and its radial gradient
C     K comes from /CONST/, F comes from W(61)
      X = K*N / F**2
      PXPR = A*X
C
C     If perturbation flag is non-zero, call the perturbation subroutine
      IF (PERT.NE.0.) CALL ELECT1
C
      RETURN
      END