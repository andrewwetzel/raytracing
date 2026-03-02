      PROGRAM TEST_HARMONY
      COMMON /YY/ MODY, Y, PYPR, PYPTH, PYPPH, YR, PYRPR, PYRPT, PYRPP,
     1 YTH, PYTPR, PYTPT, PYTPP, YPH, PYPPR, PYPPT, PYPPP
      COMMON R(6)
      COMMON /WW/ ID(10), WQ, W(400)
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (READFH, W(200))

      REAL MODY

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 5.0
      READFH = 1.0

C     Test at equator
      R(1) = EARTHR
      R(2) = PID2
      R(3) = 0.0

      OPEN(5, FILE='packages/ft_raytrace/harmony.dat')
      CALL MAGY
      CLOSE(5)

      PRINT *, 'Test for HARMONY'
      PRINT *, 'MODY   = ', MODY
      PRINT *, 'Y      = ', Y
      PRINT *, 'YR     = ', YR
      PRINT *, 'YTH    = ', YTH
      PRINT *, 'YPH    = ', YPH
      PRINT *, 'PYPR   = ', PYPR
      PRINT *, 'PYRPR  = ', PYRPR
      PRINT *, 'PYTPR  = ', PYTPR

      IF (Y .GT. 0.0) THEN
        PRINT *, 'Test PASSED (runs without crashing)'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_HARMONY
