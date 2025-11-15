      PROGRAM TEST_TABLEX
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*6 MODX
      INTEGER ID
      REAL WQ, W, R
      REAL X, PXPR, PXPTH, PXPPH, PXPT
      REAL READFN, F, PI, PIT2, PID2, DEGS, RAD, K, DUM(7)

      EQUIVALENCE (READFN,W(100)),(F,W(6))

      PI = 3.1415926535
      W(8) = 80.6e-6
      READFN = 1.0
      F = 5.0
      R(1) = 6370.0 + 150.0

      OPEN(5, FILE='tablex.dat')
      CALL ELECTX
      CLOSE(5)

      PRINT *, 'Test for TABLEX'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X

      IF (ABS(X - 6000.0) < 1.0 .AND. MODX(1) .EQ. 'TABLEX') THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_TABLEX
