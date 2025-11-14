      PROGRAM TEST_EXPX
C
C     This is a test harness for the EXPX subroutine.
C     It also requires linking the ELECT1 subroutine, which it calls.
C
C     Declare ALL common blocks used by EXPX and ELECT1
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,K,DUM
      COMMON /XX/ MODX(2),X(6),HMAX
      COMMON /WW/ ID(10),WQ,W(400)
       COMMON R(3)
C
C     Blank common for position (R = radius, TH = theta, PH = phi)
C
C     Declare types for /XX/ block, MUST MATCH EXPX and ELECT1
      CHARACTER*8 MODX
      REAL PXPTH, PXPT
C
C     Declare equivalences for /WW/ block to set inputs
      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),
     1 (NO,W(101)),(HO,W(102)),(A,W(103)),(PERT,W(151))
C
C     Local variables for testing
      REAL PI,PIT2,PID2,DEGS,RAD,K,DUM(2)
      REAL EARTHR, F, NO, HO, A, PERT
      REAL EXPECT_X, EXPECT_PXPR
      REAL N_CALC, H_CALC
      REAL TOLERANCE
      PARAMETER (TOLERANCE = 1.0E-6)

      PRINT *, '--- RUNNING TEST FOR EXPX ---'
      PRINT *, ''

C     Step 1: Set up input values
C     Set values for /CONST/
C     K is a constant for N -> X conversion. We'll use 1.0 for this test.
      K = 1.0
C
C     Set values for /WW/
      EARTHR = 6370.0  ! Earth radius (km)
      F = 10.0         ! Frequency (MHz)
      NO = 1000.0      ! e- density at HO (cm^-3)
      HO = 100.0       ! Reference height (km)
      A = 0.1          ! Exponential constant (km^-1)
C
C     Set PERT to a non-zero value to trigger the call to ELECT1.
      PERT = 1.0
C
C     Set values for Blank Common
C     Set R to be 100km above the surface (6370 + 100)
      R(1) = 6470.0       ! Position radius (km)
      R(2) = 0.0
      R(3) = 0.0
C
C     Set "dirty" values for outputs to ensure they get changed
      MODX(1) = 'EXPX'
      MODX(2) = 'NONE'
      X(1) = -99.9
      PXPR = -99.9
      HMAX = 350.0

      PRINT *, '--- BEFORE CALL ---'
      PRINT *, 'MODX(1): ', MODX(1)
      PRINT *, 'MODX(2): ', MODX(2)
      PRINT *, 'X:       ', X(1)
      PRINT *, 'PXPR:    ', PXPR
      PRINT *, ''

C     Step 2: Call the subroutine
      PRINT *, '--- CALLING EXPX ---'
      CALL EXPX
      PRINT *, ''

C     Step 3: Check the output values
      PRINT *, '--- AFTER CALL ---'
      PRINT *, 'MODX(1): ', MODX(1)
      PRINT *, 'MODX(2): ', MODX(2)
      PRINT *, 'X:       ', X(1)
      PRINT *, 'PXPR:    ', PXPR
      PRINT *, 'HMAX:    ', HMAX
      PRINT *, ''

C     Step 4: Verify the results
      PRINT *, '--- TEST RESULTS ---'
C
C     Check HMAX
      IF (ABS(HMAX - 350.0) .LT. TOLERANCE) THEN
         PRINT *, 'PASS: HMAX set to 350.0'
      ELSE
         PRINT *, 'FAIL: HMAX is not 350.0'
      ENDIF
C
C     Check MODX(1)
      IF (MODX(1) .EQ. 'EXPX') THEN
         PRINT *, 'PASS: MODX(1) set to "EXPX"'
      ELSE
         PRINT *, 'FAIL: MODX(1) not set correctly.'
      ENDIF
C
C     Check MODX(2) (this is set by the call to ELECT1)
      IF (MODX(2) .EQ. 'NONE') THEN
         PRINT *, 'PASS: MODX(2) set to "NONE" by ELECT1'
      ELSE
         PRINT *, 'FAIL: MODX(2) not set correctly.'
      ENDIF
C
C     Calculate expected values for X and PXPR to verify math
C     H = R - EARTHR = 6470.0 - 6370.0 = 100.0
      H_CALC = 100.0
C     N = NO * EXP(A*(H-HO)) = 1000.0 * EXP(0.1 * (100.0 - 100.0))
C       = 1000.0 * EXP(0.0) = 1000.0 * 1.0 = 1000.0
      N_CALC = 1000.0
C     X = K*N / F**2 = 1.0 * 1000.0 / 10.0**2 = 1000.0 / 100.0 = 10.0
      EXPECT_X = 10.0
C     PXPR = A * X = 0.1 * 10.0 = 1.0
      EXPECT_PXPR = 1.0
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
         PRINT *, 'FAIL: PXPR incorrect. Expected ~', EXPECT_PXPR,
     &       ' Got: ', PXPR
      ENDIF

      PRINT *, ''
      PRINT *, '--- TEST COMPLETE ---'

      END