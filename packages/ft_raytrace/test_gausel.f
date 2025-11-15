      PROGRAM TEST_GAUSEL
      REAL A(2,2), B(2)
      DATA A(1,1),A(2,1),A(1,2),A(2,2)/2.,4.,3.,1./
      DATA B(1),B(2)/8.,6./
      CALL GAUSEL(A,2,B)
      PRINT *, 'SOLUTION X = ', B(1)
      PRINT *, 'SOLUTION Y = ', B(2)
      IF ((ABS(B(1) - 1.0) .LT. 1.0E-5) .AND.
     +    (ABS(B(2) - 2.0) .LT. 1.0E-5)) THEN
        PRINT *, '--- TEST PASSED ---'
      ELSE
        PRINT *, '--- TEST FAILED ---'
      ENDIF
      END