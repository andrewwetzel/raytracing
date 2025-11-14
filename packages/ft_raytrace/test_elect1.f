C     PROGRAM TEST_ELECT1
C
C     This is a test harness for the ELECT1 subroutine.
C     It checks if ELECT1 correctly sets the PERT and MODX flags.
C
C     We MUST declare the same common blocks as the subroutine
C     to share memory with it.
      COMMON /XX/ MODX,X(6)
      COMMON /WW/ ID(10),WQ,W(400)
      EQUIVALENCE (PERT,W(151))
C
C     Declare MODX as a CHARACTER*6 array and the test
C     variables to match.
      CHARACTER*6 MODX(2), TEST_VAL, NONE_VAL
C
C     We need local variables to hold the "dirty" test value
C     and the expected "clean" value for comparison.
C     Use modern character strings instead of Hollerith constants.
      DATA TEST_VAL /' DIRTY'/
      DATA NONE_VAL /' NONE'/

      PRINT *, '--- RUNNING TEST FOR ELECT1 ---'
      PRINT *, ''

C     Step 1: Set "dirty" initial values before the call.
      PRINT *, '--- BEFORE CALL ---'
      PERT = 99.9
      MODX(2) = TEST_VAL
C
      PRINT *, 'Initial PERT (W(151)): ', PERT
      PRINT *, 'Initial MODX(2) value: ', MODX(2)
      PRINT *, ''

C     Step 2: Call the subroutine
      PRINT *, '--- CALLING ELECT1 ---'
      CALL ELECT1
      PRINT *, ''

C     Step 3: Check the values after the call
      PRINT *, '--- AFTER CALL ---'
      PRINT *, 'Final PERT (W(151)):   ', PERT
      PRINT *, 'Final MODX(2) value:   ', MODX(2)
      PRINT *, ''

C     Step 4: Verify the results and print a pass/fail message
      PRINT *, '--- TEST RESULTS ---'
      IF (PERT .EQ. 0.0) THEN
         PRINT *, 'PASS: PERT was correctly set to 0.0'
      ELSE
         PRINT *, 'FAIL: PERT was not set to 0.0. Value: ', PERT
      ENDIF

      IF (MODX(2) .EQ. NONE_VAL) THEN
         PRINT *, 'PASS: MODX(2) was correctly set to " NONE"'
      ELSE
         PRINT *, 'FAIL: MODX(2) was not set correctly.'
      ENDIF

      PRINT *, ''
      PRINT *, '--- TEST COMPLETE ---'

      END