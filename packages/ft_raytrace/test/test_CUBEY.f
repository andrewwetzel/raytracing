      PROGRAM TEST_CUBEY
      COMMON /YY/ MODY, Y, PYPR, PYPTH, PYPPH, YR, PYRPR, PYRPT, PYRPP,
     1 YTH, PYTPR, PYTPT, PYTPP, YPH, PYPPR, PYPPT, PYPPP
      COMMON R(6)
      COMMON /WW/ ID(10), WQ, W(400)
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (FH, W(201)), (DIP, W(202))
      CHARACTER*6 MODY

      EARTHR = 6370.0
      F = 5.0
      FH = 1.0
      DIP = 3.1415926535 / 4.0  ! PI/4 = 45 degrees

C     Test at R(1) = 2 * EARTHR
      R(1) = 2.0 * EARTHR

      CALL MAGY

      PRINT *, 'Test for CUBEY'
      PRINT *, 'MODY = ', MODY
      PRINT *, 'Y    = ', Y
      PRINT *, 'YR   = ', YR
      PRINT *, 'YTH  = ', YTH

C     Expected: Y = (1/2)^3 * (1/5) = (1/8) * 0.2 = 0.025
C     YR = 0.025 * sin(PI/4) = 0.025 * 0.707106 = 0.017677
C     YTH = 0.025 * cos(PI/4) = 0.017677
      IF (MODY .EQ. 'CUBEY ' .AND.
     +    ABS(Y - 0.025) .LT. 1.0E-5 .AND.
     +    ABS(YR - 0.017677) .LT. 1.0E-5 .AND.
     +    ABS(YTH - 0.017677) .LT. 1.0E-5) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_CUBEY
