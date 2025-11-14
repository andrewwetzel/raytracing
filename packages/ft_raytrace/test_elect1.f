      PROGRAM TEST_ELECT1

      COMMON /XX/ MODX,X(6)
      COMMON /WW/ ID(10),WQ,W(400)
      EQUIVALENCE (PERT,W(151))

      CHARACTER*6 MODX(2), TEST_VAL, NONE_VAL

      DATA TEST_VAL /' DIRTY'/
      DATA NONE_VAL /' NONE'/

      PRINT *, '--- RUNNING TEST FOR ELECT1 ---'
      PRINT *, ''

      PRINT *, '--- BEFORE CALL ---'
      PERT = 99.9
      MODX(2) = TEST_VAL
C
      PRINT *, 'Initial PERT (W(151)): ', PERT
      PRINT *, 'Initial MODX(2) value: ', MODX(2)
      PRINT *, ''

      PRINT *, '--- CALLING ELECT1 ---'
      CALL ELECT1
      PRINT *, ''

      PRINT *, '--- AFTER CALL ---'
      PRINT *, 'Final PERT (W(151)):   ', PERT
      PRINT *, 'Final MODX(2) value:   ', MODX(2)
      PRINT *, ''

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