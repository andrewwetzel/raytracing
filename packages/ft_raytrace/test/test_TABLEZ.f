      PROGRAM TEST_TABLEZ
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      COMMON /ZZ/ MODZ, Z, PZPR, PZPTH, PZPPH
      COMMON R(6)
      COMMON /WW/ ID(10), WQ, W(400)
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (READNU, W(250))
      
      CHARACTER*6 MODZ

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 1.0
      READNU = 1.0

C     Test at H=150km, between first two profile points
C     Profile: 100km=1e6, 200km=3e6, 300km=1e6
C     At H=150: linear interp = 1e6 + (150-100)*(3e6-1e6)/(200-100)
C             = 1e6 + 50*2e6/100 = 1e6 + 1e6 = 2e6
C     Scaled: Z = 2e6 / (PIT2 * 1.0E6) / F = 2.0 / PIT2 = 1.0 / PI = 0.3183098
      R(1) = EARTHR + 150.0

      OPEN(5, FILE='packages/ft_raytrace/tablez.dat')
      CALL COLFRZ
      CLOSE(5)

      PRINT *, 'Test for TABLEZ'
      PRINT *, 'MODZ = ', MODZ
      PRINT *, 'Z    = ', Z

      IF (MODZ .EQ. 'TABLEZ' .AND.
     +    ABS(Z - 0.3183098) .LT. 1.0E-5) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_TABLEZ
