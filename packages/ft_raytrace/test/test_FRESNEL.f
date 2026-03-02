      PROGRAM TEST_FRESNEL
      REAL C, S, CX, SX, DIFFC, DIFFS

C     Test C(1.0) ~ 0.779893400
C     Test S(1.0) ~ 0.438259147

      CX = C(1.0)
      SX = S(1.0)
      
      PRINT *, 'Test for FRESNEL (C and S)'
      PRINT *, 'C(1.0) = ', CX
      PRINT *, 'S(1.0) = ', SX

      DIFFC = ABS(CX - 0.7798934)
      DIFFS = ABS(SX - 0.4382591)

      IF (DIFFC .LT. 1.0E-4 .AND. DIFFS .LT. 1.0E-4) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_FRESNEL
