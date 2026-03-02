      PROGRAM TEST_LINEAR
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM(2)
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(FACT,W(101)),(HM,W(102)),
     1 (HMIN,W(103)),(PERT,W(150))
      REAL K
      CHARACTER*6 MODX

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0
      DEGS = 180.0 / PI
      RAD = PI / 180.0
      K = 80.6E-6

      EARTHR = 6370.0
      F = 5.0
      FACT = 1.0E10
      HM = 400.0
      HMIN = 100.0
      PERT = 0.0

      R(1) = EARTHR + 200.0
      R(2) = PID2

      CALL ELECTX

      PRINT *, 'Test for LINEAR'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X
      PRINT *, 'PXPR = ', PXPR

C     Expected: PXPR = K*FACT/F**2 = 80.6e-6 * 1e10 / 25 = 32240.0
C     X = PXPR * (H - HMIN) = 32240.0 * 100.0 = 3224000.0
      IF (MODX(1) .EQ. 'LINEAR' .AND.
     +    ABS(PXPR - 32240.0) .LT. 1.0 .AND.
     +    ABS(X - 3224000.0) .LT. 100.0) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_LINEAR
