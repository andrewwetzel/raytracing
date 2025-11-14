      PROGRAM TEST_ELECT1
      COMMON /XX/ MODX(2),X(6)
      COMMON /WW/ ID(10),WQ,W(400)
      EQUIVALENCE (PERT,W(150))
      REAL X, WQ
      INTEGER ID
      W(150) = 99.9
      PRINT *, '--- RUNNING TEST FOR ELECT1 ---'
      PRINT *, ' '
      PRINT *, ' --- BEFORE CALL ---'
      PRINT *, ' Initial PERT (W(151)): ', W(150)
      PRINT *, ' Initial MODX(2) value: ', MODX(2)
      PRINT *, ' '
      PRINT *, ' --- CALLING ELECT1 ---'
      CALL ELECT1
      PRINT *, ' '
      PRINT *, ' --- AFTER CALL ---'
      PRINT *, ' Final PERT (W(151)): ', W(150)
      PRINT *, ' Final MODX(2) value: ', MODX(2)
      PRINT *, ' '
      PRINT *, ' --- TEST RESULTS ---'
      IF (W(150) .NE. 0.0) THEN
        PRINT *, ' FAIL: PERT was not set to 0.0. Value: ', W(150)
      ELSE
        PRINT *, ' PASS: PERT was set to 0.0.'
      END IF
      PRINT *, ' '
      PRINT *, ' --- TEST COMPLETE ---'
      END PROGRAM TEST_ELECT1
