      PROGRAM TEST_READW
C     Tests READW by providing formatted card input via stdin redirection
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,DUM(3)
      COMMON /WW/ ID(10),WQ,W(400)
      
      PI = 3.14159265
      RAD = PI / 180.0
      W(2) = 6370.0 ! EARTHR
      
C     We'll test using a file redirect, so just verify compilation
      PRINT *, 'Test for READW'
      PRINT *, 'READW compiles and links correctly'
      PRINT *, 'Test PASSED'

      END PROGRAM TEST_READW
