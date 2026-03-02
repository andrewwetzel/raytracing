      PROGRAM TEST_DOPPLER
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM(2)
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*6 MODX
      REAL K
      REAL READFN
      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(READFN,W(151))

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0
      DEGS = 180.0 / PI
      RAD = PI / 180.0
      K = 1.0

      EARTHR = 6370.0
      F = 1.0
      READFN = 1.0
      HMAX = 0.0

C     Test at H=150km between points 100km (1e3) and 200km (5e3)
C     Linear interp: 1e3 + 50*(5e3-1e3)/100 = 1e3 + 2e3 = 3e3
C     PXPT = 3000 / 1.0 = 3000.0
      R(1) = EARTHR + 150.0
      R(2) = PID2

      OPEN(5, FILE='packages/ft_raytrace/doppler.dat')
      CALL ELECT1
      CLOSE(5)

      PRINT *, 'Test for DOPPLER'
      PRINT *, 'MODX = ', MODX(2)
      PRINT *, 'PXPT = ', PXPT
      PRINT *, 'HMAX = ', HMAX

      IF (MODX(2) .EQ. 'DOPPLR' .AND.
     +    ABS(PXPT - 3000.0) .LT. 1.0 .AND.
     +    ABS(HMAX - 200.0) .LT. 0.1) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_DOPPLER
