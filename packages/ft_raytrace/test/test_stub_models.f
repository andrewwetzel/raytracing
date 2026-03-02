      SUBROUTINE ELECTX
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      CHARACTER*6 MODX
      MODX(1) = 'STUB  '
      PXPR = 0.0
      PXPTH = 0.0
      PXPPH = 0.0
      PXPT = 0.0
      RETURN
      END

      SUBROUTINE MAGY
      COMMON /YY/ MODY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRPT,PYRPP,
     1 YTH,PYTPR,PYTPT,PYTPP,YPH,PYPPR,PYPPT,PYPPP
      CHARACTER*6 MODY
      MODY = 'STUB  '
      PYPR = 0.0
      PYPTH = 0.0
      PYPPH = 0.0
      YR = 0.0
      PYRPR = 0.0
      PYRPT = 0.0
      PYRPP = 0.0
      YTH = 0.0
      PYTPR = 0.0
      PYTPT = 0.0
      PYTPP = 0.0
      YPH = 0.0
      PYPPR = 0.0
      PYPPT = 0.0
      PYPPP = 0.0
      RETURN
      END

      SUBROUTINE COLFRZ
      COMMON /ZZ/ MODZ,Z,PZPR,PZPTH,PZPPH
      CHARACTER*6 MODZ
      MODZ = 'STUB  '
      PZPR = 0.0
      PZPTH = 0.0
      PZPPH = 0.0
      RETURN
      END

      SUBROUTINE PRINTR(STR, VAL)
      CHARACTER*(*) STR
      REAL VAL
      RETURN
      END

      SUBROUTINE RAYPLT
      RETURN
      END
