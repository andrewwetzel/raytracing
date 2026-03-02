      PROGRAM TEST_TABLEX
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM(2)
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(READFN,W(100)),
     1 (PERT,W(150))
      REAL K
      CHARACTER*6 MODX

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0
      DEGS = 180.0 / PI
      RAD = PI / 180.0
      K = 1.0

      EARTHR = 6370.0
      F = 1.0
      READFN = 1.0
      PERT = 0.0

C     Test at H=150km, between first two profile points
C     Profile: 100km=1e4, 200km=3e5, 300km=1e4
C     At H=150: linear interp = 1e4 + (150-100)*(3e5-1e4)/(200-100)
C             = 1e4 + 50*2.9e5/100 = 1e4 + 1.45e5 = 1.55e5
C     With K=1, F=1: X = 1.55e5 / 1.0 = 155000.0
      R(1) = EARTHR + 150.0

      OPEN(5, FILE='packages/ft_raytrace/tablex.dat')
      CALL ELECTX
      CLOSE(5)

      PRINT *, 'Test for TABLEX'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X
      PRINT *, 'HMAX = ', HMAX

      IF (MODX(1) .EQ. 'TABLEX' .AND.
     +    ABS(X - 155000.0) .LT. 1.0 .AND.
     +    ABS(HMAX - 200.0) .LT. 0.1) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_TABLEX
