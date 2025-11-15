      PROGRAM TEST_QPARAB
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*6 MODX
      INTEGER ID
      REAL WQ, W, R
      REAL X, PXPR, PXPTH, PXPPH, PXPT
      REAL FC, HM, SH, PERT
      REAL PI, PIT2, PID2, DEGS, RAD, K, DUM(7)
      REAL EARTHR, F

      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(FC,W(101)),(HM,W(102)),
     1 (SH,W(103)),(PERT,W(150))

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 5.0
      FC = 10.0
      HM = 300.0
      SH = 100.0
      PERT = 0.0

      R(1) = EARTHR + 300.0
      R(2) = PID2

      CALL ELECTX

      PRINT *, 'Test for QPARAB'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X

      IF (MODX(1) .EQ. 'QPARAB') THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_QPARAB
