      PROGRAM TEST_DIPOLY
      COMMON /CONST/ PI,PIT2,PID2,DUM(5)
      COMMON /YY/ MODY, Y, PYPR, PYPTH, PYPPH, YR, PYRPR, PYRPT, PYRPP,
     1 YTH, PYTPR, PYTPT, PYTPP, YPH, PYPPR, PYPPT, PYPPP
      COMMON R(6)
      COMMON /WW/ ID(10), WQ, W(400)
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (FH, W(201))
      CHARACTER*6 MODY

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 5.0
      FH = 1.0

C     Test at equator: R=EARTHR, colatitude R(2)=PID2
      R(1) = EARTHR
      R(2) = PID2
      R(3) = 0.0

      CALL MAGY

      PRINT *, 'Test for DIPOLY'
      PRINT *, 'MODY = ', MODY
      PRINT *, 'Y    = ', Y
      PRINT *, 'YR   = ', YR
      PRINT *, 'YTH  = ', YTH

C     At equator (R(2) = PI/2): 
C     COSTH = sin(0) = 0, SINTH = sin(PI/2) = 1
C     TERM9 = sqrt(1.0 + 3*0) = 1.0
C     T1 = (1.0)*(1.0)^3 / 5.0 = 0.2
C     Y = 0.2 * 1.0 = 0.2
C     YR = 2.0 * 0.2 * 0 = 0.0
C     YTH = 0.2 * 1 = 0.2
      IF (MODY .EQ. 'DIPOLY' .AND.
     +    ABS(Y - 0.2) .LT. 1.0E-5 .AND.
     +    ABS(YR - 0.0) .LT. 1.0E-5 .AND.
     +    ABS(YTH - 0.2) .LT. 1.0E-5) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_DIPOLY
