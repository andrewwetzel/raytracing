      PROGRAM TEST_GAUSEL
C     TEST PROGRAM FOR GAUSEL SUBROUTINE
      IMPLICIT REAL*8 (A-H, O-Z)
      DIMENSION C(4,5)
      INTEGER NRD, NRR, NCC, NSF
C     SET UP A 2X2 SYSTEM
C     2X + 3Y = 8
C     4X + 1Y = 6
C     SOLUTION: X=1, Y=2
      NRD = 4
      NRR = 2
      NCC = 3
      C(1,1) = 2.0
      C(1,2) = 3.0
      C(1,3) = 8.0
      C(2,1) = 4.0
      C(2,2) = 1.0
      C(2,3) = 6.0
      PRINT 100, '--- BEFORE CALL ---'
      PRINT 110, 'C(1,3) = ', C(1,3)
      PRINT 110, 'C(2,3) = ', C(2,3)
 100  FORMAT(A20)
 110  FORMAT(A10, F10.5)
      CALL GAUSEL(C, NRD, NRR, NCC, NSF)
      PRINT 100, '--- AFTER CALL ---'
      PRINT 110, 'SOLUTION X = ', C(1,3)
      PRINT 110, 'SOLUTION Y = ', C(2,3)
      PRINT 120, 'NSF = ', NSF
 120  FORMAT(A6, I5)
C     CHECK RESULTS
      IF (.NOT.((ABS(C(1,3) - 1.0D0) .LT. 1.0D-5) .AND.
     +    (ABS(C(2,3) - 2.0D0) .LT. 1.0D-5))) GOTO 200
      PRINT 100, '--- TEST PASSED ---'
      GOTO 300
 200  PRINT 100, '--- TEST FAILED ---'
 300  CONTINUE
      END
