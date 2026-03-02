      SUBROUTINE POLCAR
C     CONVERTS SPHERICAL COORDINATES TO CARTESIAN
      DIMENSION XQ(6),X(6),RQ(4)
      COMMON R(6) 
      COMMON /COORD/ S
      COMMON /CONST/ PI,PIT2,PID2,DUM(5)
      
      SAVE XQ, X, RQ, VERT
      
      LOGICAL VERT
      
      IF (R(5) .EQ. 0.0 .AND. R(6) .EQ. 0.0) GO TO 1
      VERT = .FALSE.
      SINA = SIN(R(2))
      COSA = COS(R(2))
      SINP = SIN(R(3))
      COSP = COS(R(3))
      
      XQ(1) = R(1)*SINA*COSP
      XQ(2) = R(1)*SINA*SINP
      XQ(3) = R(1)*COSA
      
      X(4) = R(4)*SINA*COSP + R(5)*COSA*COSP - R(6)*SINP
      X(5) = R(4)*SINA*SINP + R(5)*COSA*SINP + R(6)*COSP
      X(6) = R(4)*COSA - R(5)*SINA
      RETURN

C     VERTICAL INCIDENCE
 1    VERT = .TRUE.
      RQ(1) = R(1)
      RQ(2) = R(2)
      RQ(3) = R(3)
      RQ(4) = SIGN(1.0, R(4))
      RETURN

      ENTRY CARPOL
C     STEPS THE RAY A DISTANCE S, AND THEN CONVERTS CARTESIAN 
C     COORDINATES TO SPHERICAL COORDINATES
      IF (VERT) GO TO 2
      X(1) = XQ(1) + S*X(4)
      X(2) = XQ(2) + S*X(5)
      X(3) = XQ(3) + S*X(6)
      
      TEMP = SQRT(X(1)**2 + X(2)**2)
      R(1) = SQRT(X(1)**2 + X(2)**2 + X(3)**2)
      R(2) = ATAN2(TEMP, X(3))
      R(3) = ATAN2(X(2), X(1))
      
      R(4) = (X(1)*X(4) + X(2)*X(5) + X(3)*X(6)) / R(1)
      R(5) = (X(3)*(X(1)*X(4) + X(2)*X(5)) - (X(1)**2+X(2)**2)*X(6)) /
     1       (R(1)*TEMP)
      R(6) = (X(1)*X(5) - X(2)*X(4)) / TEMP
      RETURN

C     VERTICAL INCIDENCE
 2    R(1) = RQ(1) + RQ(4)*S
      R(2) = RQ(2)
      R(3) = RQ(3)
      R(4) = RQ(4)
      R(5) = 0.0
      R(6) = 0.0
      RETURN
      END
