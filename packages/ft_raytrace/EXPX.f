        SUBROUTINE EXPX

      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM
      COMMON /XX/ MODX,X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON /WW/ ID(10),WQ,W(400)

      COMMON R, TH, PH

      CHARACTER*6 MODX(2)
      REAL X, PXPR, PXPTH, PXPPH, PXPT, HMAX

      EQUIVALENCE (EARTHR,W(2)),(F,W(61)),
     1 (NO,W(101)),(HO,W(102)),(A,W(103)),(PERT,W(151))

      REAL N, NO, K, H, R, TH, PH

      MODX(1) = ' EXPX'
      HMAX = 350.

      ENTRY ELECTX

      H = R - EARTHR

      N = NO * EXP(A*(H-HO))

      X = K*N / F**2
      PXPR = A*X

      IF (PERT.NE.0.) CALL ELECT1

      RETURN
      END