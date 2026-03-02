      PROGRAM TEST_BQWFWC
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RADIAN,K,C,LOGTEN
      COMMON /RIN/ MODRIN(3),COLL,FIELD,SPACE,KAY2,H,PHPT,PHPR,PHPTH,
     1 PHPPH,PHPOM,PHPKR,PHPKTH,PHPKPH,KPHPK,POLAR,LPOLAR,
     2 SGN
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      COMMON /RK/ N,STEP,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      EQUIVALENCE (RAY,W(1)), (F,W(6)), (EARTHR, W(2)), (READFN,W(100))
      LOGICAL SPACE
      CHARACTER*6 MODX
      CHARACTER*8 MODRIN
      COMPLEX KAY2, H, PHPT, PHPR, PHPTH, PHPPH, PHPOM, PHPKR, PHPKTH, 
     1 PHPKPH, KPHPK, POLAR, LPOLAR

      C = 299792.458
      PI = 3.14159265
      PIT2 = 2.0 * PI
      F = 10.0
      RAY = 1.0 ! ordinary ray
      RSTART = 0.0
      SGN = 1.0

      R(4)=0.0
      R(5)=0.0
      R(6)=0.0
      R(1) = EARTHR + 100.0

      X = 0.0
      Z = 0.0
      READFN = 0.0

C     Run test: should trigger the fallback branch because X=0.0 < 1.0E-4
      CALL RINDEX

      PRINT *, 'Test for BQWFWC'
      PRINT *, 'N2 / KPHPK = ', KPHPK
      PRINT *, 'H          = ', H

      IF (ABS(REAL(KPHPK) - 1.0) .LT. 1.0E-5 .AND.
     +    ABS(REAL(H) - (-0.5)) .LT. 1.0E-5) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_BQWFWC
