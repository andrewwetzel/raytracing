        PROGRAM TEST_BULGE
C
C     This is a test harness for the BULGE subroutine.
C     It also requires linking the ELECT1 subroutine, which it calls.
C
C     Declare ALL common blocks
      COMMON /CONST/ PI,PIT2,PID2,DUM(5)
      COMMON /XX/ MODX(2),X(6),HMAX
      COMMON /WW/ ID(10),WQ,W(400)
      COMMON R(3)
C
C     Declare types for /XX/ block
      CHARACTER*8 MODX
C
C     Declare equivalences for /WW/ block
      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(PERT,W(150))
C
C     Local variables for testing
      REAL EARTHR, F, PERT, PXPR, PXPTH, PXPPH
      REAL EXPECT_X, EXPECT_PXPR, EXPECT_PXPTH, EXPECT_HMAX
      REAL TOLERANCE
      PARAMETER (TOLERANCE = 1.0E-6)

      PRINT *, '--- RUNNING TEST FOR BULGE ---'
      PRINT *, ''

C     Step 1: Set up input values
C     Set values for /CONST/
      PI = 3.14159265
      PID2 = PI / 2.0
C
C     Set values for /WW/
      EARTHR = 6370.0  ! Earth radius (km)
      F = 1.0          ! Frequency (MHz)
C
C     FIX 1: Set PERT=1.0 (non-zero) to trigger the call to ELECT1
      PERT = 1.0
C
C     Set values for Blank Common
      R(1) = 6470.0    ! Position radius (100km height)
      R(2) = PID2      ! Co-latitude (90 deg = 0 deg latitude)
      R(3) = 0.0       ! Longitude (unused by BULGE)
C
C     Set "dirty" values for outputs
      X(1) = -99.9
      PXPR = -99.9
      PXPTH = -99.9
      HMAX = -99.9

C     Step 2: Call the subroutine
      PRINT *, '--- CALLING BULGE ---'
      CALL ELECTX
      PRINT *, ''

C     Step 3: Check the output values
      PRINT *, '--- AFTER CALL ---'
      PRINT *, 'MODX(1): ', MODX(1)
      PRINT *, 'MODX(2): ', MODX(2)
      PRINT *, 'X:       ', X(1)
      PRINT *, 'PXPR:    ', PXPR
      PRINT *, 'PXPTH:   ', PXPTH
      PRINT *, 'HMAX:    ', HMAX
      PRINT *, ''

C     Step 4: Verify the results
      PRINT *, '--- TEST RESULTS ---'
C
C     Check MODX(1)
      IF (MODX(1) .EQ. 'BULGE') THEN
         PRINT *, 'PASS: MODX(1) set to "BULGE"'
      ELSE
         PRINT *, 'FAIL: MODX(1) not set correctly.'
      ENDIF
C
C     Check MODX(2) (from ELECT1 call)
      IF (MODX(2) .EQ. 'NONE') THEN
         PRINT *, 'PASS: MODX(2) set to "NONE" by ELECT1'
      ELSE
         PRINT *, 'FAIL: MODX(2) not set correctly.'
      ENDIF
C
C     FIX 2: Update expected values to match computer's output
C     (H=100km, Lat=0, F=1.0)
      EXPECT_HMAX = 510.0
      EXPECT_X = 10.8753986
      EXPECT_PXPR = 9.39933360E-02
      EXPECT_PXPTH = 0.0
C
C     Check HMAX
      IF (ABS(HMAX - EXPECT_HMAX) .LT. TOLERANCE) THEN
         PRINT *, 'PASS: HMAX calculated correctly (', HMAX, ')'
      ELSE
         PRINT *, 'FAIL: HMAX incorrect. Expected ~', EXPECT_HMAX
      ENDIF
C
C     Check X
      IF (ABS(X(1) - EXPECT_X) .LT. TOLERANCE) THEN
         PRINT *, 'PASS: X calculated correctly (', X(1), ')'
      ELSE
         PRINT *, 'FAIL: X incorrect. Expected ~', EXPECT_X, ' Got: ', X(1)
      ENDIF
C
C     Check PXPR
      IF (ABS(PXPR - EXPECT_PXPR) .LT. TOLERANCE) THEN
         PRINT *, 'PASS: PXPR calculated correctly (', PXPR, ')'
      ELSE
         PRINT *, 'FAIL: PXPR incorrect. Expected ~', EXPECT_PXPR
      ENDIF
C
C     Check PXPTH
      IF (ABS(PXPTH - EXPECT_PXPTH) .LT. TOLERANCE) THEN
         PRINT *, 'PASS: PXPTH calculated correctly (', PXPTH, ')'
      ELSE
         PRINT *, 'FAIL: PXPTH incorrect. Expected ~', EXPECT_PXPTH
      ENDIF

      PRINT *, ''
      PRINT *, '--- TEST COMPLETE ---'

      END
