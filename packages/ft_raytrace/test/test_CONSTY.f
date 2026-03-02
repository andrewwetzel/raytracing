      PROGRAM TEST_CONSTY
      COMMON /YY/ MODY, Y, PYPR, PYPTH, PYPPH, YR, PYRPR, PYRPT, PYRPP,
     1 YTH, PYTPR, PYTPT, PYTPP, YPH, PYPPR, PYPPT, PYPPP
      COMMON /WW/ ID(10), WQ, W(400)
      EQUIVALENCE (F, W(6)), (FH, W(201)), (DIP, W(202))
      CHARACTER*6 MODY

      F = 5.0
      FH = 1.0
      DIP = 3.1415926535 / 4.0  ! PI/4 = 45 degrees

      CALL MAGY

      PRINT *, 'Test for CONSTY'
      PRINT *, 'MODY = ', MODY
      PRINT *, 'Y    = ', Y
      PRINT *, 'YR   = ', YR
      PRINT *, 'YTH  = ', YTH

C     Expected: Y = 1/5 = 0.2
C     YR = 0.2 * sin(PI/4) = 0.2 * 0.707106 = 0.141421
C     YTH = 0.2 * cos(PI/4) = 0.141421
      IF (MODY .EQ. 'CONSTY' .AND.
     +    ABS(Y - 0.2) .LT. 1.0E-5 .AND.
     +    ABS(YR - 0.141421) .LT. 1.0E-5 .AND.
     +    ABS(YTH - 0.141421) .LT. 1.0E-5) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_CONSTY
