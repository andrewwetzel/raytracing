      SUBROUTINE EXPZ
C     EXPONENTIAL COLLISION FREQUENCY MODEL
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      COMMON /ZZ/ MODZ, Z, PZPR, PZPTH, PZPPH
      COMMON R(6) /WW/ ID(10), WQ, W(400)
      REAL NU, NU0
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (NU0, W(251)),
     1 (H0, W(252)), (A, W(253))
      CHARACTER*6 MODZ
      DATA MODZ /'EXPZ  '/
      ENTRY COLFRZ
      H = R(1) - EARTHR
      NU = NU0 / EXP(A*(H-H0))
      Z = NU / (PIT2 * F * 1.0E6)
      PZPR = -A * Z
      PZPTH = 0.0
      PZPPH = 0.0
      RETURN
      END
