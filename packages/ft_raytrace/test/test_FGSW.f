      PROGRAM TEST_FGSW
      REAL X
      COMPLEX F, DF, G, DG
      COMPLEX EXPECT_G, EXPECT_DG
      
      X = 1.0
      CALL FGSW(X, F, DF, G, DG)
      
      PRINT *, 'Test for FGSW'
      PRINT *, 'X = ', X
      PRINT *, 'F = ', F
      PRINT *, 'DF = ', DF
      PRINT *, 'G = ', G
      PRINT *, 'DG = ', DG
      
      EXPECT_G = X * F
      EXPECT_DG = F + X * DF
      
      IF (ABS(REAL(G) - REAL(EXPECT_G)) .LT. 1E-4 .AND.
     +    ABS(AIMAG(G) - AIMAG(EXPECT_G)) .LT. 1E-4) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_FGSW
