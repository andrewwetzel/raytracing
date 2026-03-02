      SUBROUTINE DIPOLY
      COMMON /CONST/ PI,PIT2,PID2,DUM(5)
      COMMON /YY/ MODY, Y, PYPR, PYPTH, PYPPH, YR, PYRPR, PYRPT, PYRPP,
     1 YTH, PYTPR, PYTPT, PYTPP, YPH, PYPPR, PYPPT, PYPPP
      COMMON R(6) /WW/ ID(10), WQ, W(400)
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (FH, W(201))
      CHARACTER*6 MODY
      DATA MODY /'DIPOLY'/
      ENTRY MAGY
      SINTH = SIN(R(2))
      COSTH = SIN(PID2-R(2))
      TERM9 = SQRT(1.0 + 3.0*COSTH**2)
      T1 = FH * (EARTHR/R(1))**3 / F
      Y = T1 * TERM9
      YR = 2.0 * T1 * COSTH
      YTH = T1 * SINTH
      PYRPR = -3.0 * YR / R(1)
      PYRPT = -2.0 * YTH
      PYTPR = -3.0 * YTH / R(1)
      PYTPT = 0.5 * YR
      PYPR = -3.0 * Y / R(1)
      PYPTH = -3.0 * Y * SINTH * COSTH / TERM9**2
      PYPPH = 0.0
      PYRPP = 0.0
      PYTPP = 0.0
      YPH = 0.0
      PYPPR = 0.0
      PYPPT = 0.0
      PYPPP = 0.0
      RETURN
      END
