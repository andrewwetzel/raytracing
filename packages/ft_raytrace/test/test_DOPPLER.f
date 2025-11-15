      PROGRAM TEST_DOPPLER
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM(2)
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*6 MODX
      INTEGER ID
      REAL WQ, W, R
      REAL READFN
      REAL K
      REAL X, PXPR, PXPTH, PXPPH, PXPT

      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(READFN,W(151))

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0
      DEGS = 180.0 / PI
      RAD = PI / 180.0
      K = 1.0

      EARTHR = 6370.0
      F = 5.0
      READFN = 1.0

      R(1) = EARTHR + 150.0
      R(2) = PID2

      OPEN(5, FILE='doppler.dat')
      CALL ELECT1
      CLOSE(5)

      PRINT *, 'Test for DOPPLER'
      PRINT *, 'MODX = ', MODX(2)
      PRINT *, 'X    = ', X

      IF (ABS(X - 15000.0/25.0) < 1.0 .AND. MODX(2) .EQ. 'DOPPLR') THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_DOPPLER
