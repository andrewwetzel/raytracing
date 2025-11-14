      SUBROUTINE GAUSEL (C,NRD,NRR,NCC,NSF)
      DIMENSION C(NRD,NCC),L(128,2)
      BITS = 2.**(-18)
      NR=NRR
      NC=NCC
      NSF=0
      NRM=NR-1
      NRP=NR+1
      D=1.0
      LSD=1
      DO 1 KR=1,NR
      L(KR,1)=KR
      L(KR,2)=0
1     CONTINUE
      IF(NR.EQ.1) GO TO 42
      DO 41 KP=1,NRM
      KPP=KP+1
      PM=0.0
      MPN=0
      DO 2 KR=KP,NR
      LKR=L(KR,1)
      PT=ABS(C(LKR,KP))
      IF(PT.LE.PM) GO TO 2
      PM=PT
      MPN=KR
      LMP=LKR
2     CONTINUE
      IF(MPN.EQ.0) GO TO 9
      NSF=NSF+1
      IF(MPN.EQ.KP) GO TO 3
      LSD=-LSD
      L(KP,2)=L(MPN,1)
      L(MPN,1)=L(KP,1)
      L(KP,1)=LMP
3     MKP=L(KP,1)
      P=C(MKP,KP)
      D=D*P
      DO 41 KR=KPP,NR
      MKR=L(KR,1)
      Q=C(MKR,KP)/P
      IF(Q.EQ.0.0) GO TO 41
      DO 4 LC=KPP,NC
      R=Q*C(MKP,LC)
      C(MKR,LC)=C(MKR,LC)-R
      IF(ABS(C(MKR,LC)).LT.ABS(R*BITS)) C(MKR,LC)=0.0
4     CONTINUE
41    CONTINUE
42    LNR=L(NR,1)
      P=C(LNR,NR)
      IF(P.EQ.0.0) GO TO 9
      NSF=NSF+1
      D=D*P*LSD
      IF(NR.EQ.NC) GO TO 8
      DO 61 MC=NRP,NC
      C(LNR,MC)=C(LNR,MC)/P
      IF(NR.EQ.1) GO TO 61
      DO 6 LL=1,NRM
      KR=NR-LL
      MR=L(KR,1)
      KRP=KR+1
      DO 5 MS=KRP,NR
      LMS=L(MS,1)
      R=C(MR,MS)*C(LMS,MC)
      C(MR,MC)=C(MR,MC)-R
5     CONTINUE
      IF(ABS(C(MR,MC)).LT.ABS(R*BITS)) C(MR,MC)=0.0
      C(MR,MC)=C(MR,MC)/C(MR,KR)
6     CONTINUE
61    CONTINUE
      DO 71 LL=1,NRM
      KR=NR-LL
      MKR=L(KR,2)
      IF(MKR.EQ.0) GO TO 71
      MKP=L(KR,1)
      DO 7 LC=NRP,NC
      Q=C(MKR,LC)
      C(MKR,LC)=C(MKP,LC)
      C(MKP,LC)=Q
7     CONTINUE
71    CONTINUE
8     C(1,1)=D
      GO TO 91
9     C(1,1)=0.0
91    RETURN
      END