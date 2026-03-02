      PROGRAM TEST_POLCAR
      COMMON R(6) 
      COMMON /COORD/ S
      COMMON /CONST/ PI,PIT2,PID2,DUM(5)
      
      PI = 3.14159265
      PID2 = PI / 2.0
      
      R(1) = 6370.0
      R(2) = 0.0
      R(3) = 0.0
      R(4) = 1.0
      R(5) = 1.0
      R(6) = 0.0
      
      CALL POLCAR
      
      PRINT *, 'Test for POLCAR'
      S = 1000.0
      CALL CARPOL
      
      PRINT *, 'New R(1) = ', R(1)
      PRINT *, 'New R(2) = ', R(2)
      PRINT *, 'New R(3) = ', R(3)
      PRINT *, 'New R(4) = ', R(4)
      PRINT *, 'New R(5) = ', R(5)
      
      IF (R(1) .GT. 6370.0) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_POLCAR
