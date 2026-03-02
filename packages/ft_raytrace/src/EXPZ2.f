      SUBROUTINE EXPZ2
C     COLLISION FREQUENCY PROFILE FROM TWO EXPONENTIALS
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      COMMON /ZZ/ MODZ, Z, PZPR, PZPTH, PZPPH
      COMMON R(6) /WW/ ID(10), WQ, W(400)
      
      REAL NU1, NU2, EXP1, EXP2
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (NU1, W(251)),
     1 (H1, W(252)), (A1, W(253)), (NU2, W(254)), (H2, W(255)),
     2 (A2, W(256))
      
      CHARACTER*6 MODZ
      DATA MODZ /'EXPZ2 '/
      
      ENTRY COLFRZ
      H = R(1) - EARTHR
      EXP1 = NU1 * EXP(-A1*(H-H1))
      EXP2 = NU2 * EXP(-A2*(H-H2))
      Z = (EXP1 + EXP2) / (PIT2 * F * 1.0E6)
      PZPR = (-A1*EXP1 - A2*EXP2) / (PIT2 * F * 1.0E6)
      PZPTH = 0.0
      PZPPH = 0.0
      RETURN
      END
