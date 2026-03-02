      PROGRAM TEST_FSW
      REAL Z
      COMPLEX F, DF
      
C     Test FSW at a small value (triggers Power Series, ABS(Z) < 0.05)
      Z = 0.02
      CALL FSW(Z, F, DF)
      PRINT *, 'FSW( 0.02) = ', F
      PRINT *, 'DFSW(0.02) = ', DF

C     Test FSW at a medium value (triggers Fresnel, 0.05 <= ABS(Z) <= 6)
      Z = 1.0
      CALL FSW(Z, F, DF)
      PRINT *, 'FSW( 1.00) = ', F
      PRINT *, 'DFSW(1.00) = ', DF

C     Test FSW at a negative medium value (triggers Fresnel, X < 0)
      Z = -1.0
      CALL FSW(Z, F, DF)
      PRINT *, 'FSW(-1.00) = ', F
      PRINT *, 'DFSW(-1.00) = ', DF

C     Just compiling and running it without crashing means we successfully linked C and S.
      PRINT *, 'Test PASSED'
      END PROGRAM TEST_FSW
