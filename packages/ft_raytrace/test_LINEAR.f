      PROGRAM TEST_LINEAR
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*6 MODX
      INTEGER ID
      REAL WQ, W, R
      REAL X, PXPR, PXPTH, PXPPH, PXPT
      REAL H0, A, PERT
      REAL PI, PIT2, PID2, DEGS, RAD, K, DUM(7)
      REAL EARTHR, F

      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(H0,W(101)),(A,W(102)),
     1 (PERT,W(150))

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 5.0
      H0 = 100.0
      A = 0.1
      PERT = 0.0

      R(1) = EARTHR + 200.0
      R(2) = PID2

      CALL ELECTX

      PRINT *, 'Test for LINEAR'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X

      IF (MODX(1) .EQ. 'LINEAR') THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_LINEAR
