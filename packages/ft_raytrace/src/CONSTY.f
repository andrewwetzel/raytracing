      SUBROUTINE CONSTY
      COMMON /YY/ MODY, Y, PYPR, PYPTH, PYPPH, YR, PYRPR, PYRPT, PYRPP,
     1 YTH, PYTPR, PYTPT, PYTPP, YPH, PYPPR, PYPPT, PYPPP
      COMMON /WW/ ID(10), WQ, W(400)
      EQUIVALENCE (F, W(6)), (FH, W(201)), (DIP, W(202))
      CHARACTER*6 MODY
      DATA MODY /'CONSTY'/
      ENTRY MAGY
      Y = FH / F
      YR = Y * SIN(DIP)
      YTH = Y * COS(DIP)
      PYPR = 0.0
      PYPTH = 0.0
      PYPPH = 0.0
      PYRPR = 0.0
      PYRPT = 0.0
      PYRPP = 0.0
      PYTPR = 0.0
      PYTPT = 0.0
      PYTPP = 0.0
      YPH = 0.0
      PYPPR = 0.0
      PYPPT = 0.0
      PYPPP = 0.0
      RETURN
      END
