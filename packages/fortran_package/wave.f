INPUT PARAMETER FORM FOR SUBROUTINE WAVE
A perturbation to an ionospheric electron density model consisting of
a "gravity-wave" irregularity traveling from north pole to south pole

I'> = 0 ex p {- [(R - Ro - Zo )!HP} •
COS{ZTT

[t' + (TT!Z - 8) ~o + (R - Ro)! Az J}

oN - --ZTT
2
1.- Vx NoO exp - [(R - Ro - zo)!H]
at
x
sin 2TT

[t' + (TT!Z - 9) ~: + (R - Ro)!AzJ

Ro is the radius of the earth.

R, 8, CD are the spherical (earth - centered) polar coordinates
(I'> is independent of CD ).
No (R, 6, CD) is any electron density model.

Specify:
the height of maximum wave amplitude, Zo = ___-.:km (WI51)
wa ve -a mplitude "scale height, " H = ____km (W15Z)
wave perturbation amplitude, 0 =

[0. to 1. J (WI 53)

horizontal trace velocity, Vx =
km/sec (W154)
(needed only if Doppler shift is calculated)
horizoCltal wavelength, Ax
vertical we. velenf;th

1

~.z

= ___.-:krn (W155)

= ____km

(W156)

time in wave periods, t' = ____ [0. to 1. J (W157)

(W150: = 1. to use perturbation, = O. to ignore perturbation)

134

C

SUBROUTINE WAVE
PERTURBATION TO AN ALPHA-CHAPMAN ELEcTRON DENSITY MODEL
COMMON ICONSTI PI,prT2,PI02.DUM(51
COMMON IXXI MOOX(21,X,PXPR,PXPTH,PXPPH,PXPT,HMAX
COMMON R(6) IWWI IDIIO),W O,Wf4 00 1
EQUIVI\LENCE (EARTHR,WI211,(l O,WI15111,(SH,WI152)),(DELTA,W(lS31).

WAVE001
WAVE002
WAVE003
WAVE004
WAVE005
WAVE006
1 (VSURX,W(154)1,ILA~BOAX,W{15511'(LAMBDAl'W{15611,(TP,W(157))
WAVE007
REAL LAMBDAX,LAMBDAl
WAVE008
OA-A IMODXf2J=6H WAVE)
WAVE009
ENTRY ELECT,
WAVEOIO
IF fX.EQ.O •• AND.PXPR.EO.O •• AND.PXPTH.EO.O •• AND.PXPPH.EQ.O.) RETURNWAVE011
IF fDElTA.EO.O •• OR.SH.~Q.O.)
RETURN
WAVE012
H~RI1J-EARTHR
WAVE013
EXPO=EXPI-{(H-lOJ/SH ) ·*2'
WAVE014
TMP=PIT2*ITP+(PID2-R(ZI'*EARTHR/LAMBDAX+H/LAMBDAZI
WAVEOlS
SINW=SINITMP)
WAVE016
COSW=SIN(PID2-TMP)
WAVE017
CONS=l.O+DELTA*EXPO*COSW
WAVE018
IF (H.NE.O. 1 PXPR=PXPR*CONS-X*DELTA*EXPO*'2.0/SH**Z*IH-ZO)*COSW
WAVE019
1 +PITZ/LAMSDAZ*SINW)
WAVE020
PXPTH=PXPTH*CONS+X* OElTA*PIT2*EARTHR/LAMBDAX*SINW*EXPQ
WAVE021
PXPPH=PXPPH*CONS
WAVE022
PXPT=O.
WAVE023
IF IVSUBX.NE.O.) PXPT=-PITZ*VSUBX/LAMBDAX*X*DELTA*EXPQ*SINW
WAVEOZ4
X=X*CONS
WAVE025
RE TURN
WAVE026
END
WAVE027-
INPUT PARAMETER FORM FOR SUBROUTINE WAVE Z
PERTURBATION TO AN IONOSPHERIC ELECTRON DENSITY MODEL
A "gravity-wave" irregularity traveling from north pole to south pole same as WAVE 1, but with Gaus s ian amplitude variations in latitude and
longitude, and provision for a horizontal "group velocity"

N = No (I + AC)
A

= 6 exp - (r - ;; - zQ

r. C r. r
-@8 9 (t)

exp -

C = cos ZTI[t' + (TI/Z-8) ~

exp -( :

+ (r - r@)/),.zJ

x

rg

is the radius of the earth.

r, 8, ~ are spherical (earth-centered) polar coordinates.
No (r, 8, (iI)

is any electron density model.

Specify:
use perturbation _ _ _ _ _ _ _(WISO = 1.)
(WI SO = 0.)

ignore perturbation

the height of maximum wave amplitude,

= ______km (WISI)

z~

wave -amplitude" scale height," H =

km (WI SZ)

wave perturbation amplitude, 6 =

(0 to I) (WIS3)

horizontal trace velocity, Vx =
kml sec. (WlS4)
(needed only if Doppler shift is calculated)
horizontal wavelength, Ax =

- - - - -km (WISS)

vertical wavelength, Az =
time in wave periods, t

f

km

=

(WlS6)

(WlS7)

amplitude" scale distance" in latitude, @ =

- - - "degree s (WlS9)
=

degrees (WI60)

latitude of maximum amplitude at t = 0, 8", =

degrees (WIS8)

amplitude "scale distance" in longitude,

~

southward group velocity, V, =
kml sec (WI61)
(needed even if Doppler shift is not calculated)
136

SUBROUTI~E

C

WAVE2
WAV2001
PERTURBATION TO AN ANY ELECrqON DENSITY MODEL
WAV2002
COMMON ICONSTI PI,PIT2,PID2,DUM(SJ
WAV2003
COMMON IXXI MODX(2),X,PXPR,PXPTH,PXPPH,PXPT
WAV2004
COMMON R(6J l'tlWI IOC1 0J , ...... O'W(400J
WAV2005
EQUIVALENCE (EARTHR,W(2J),{ZO,W(151)),(S H,W(152 )1'~D ELTA"ff'(1531)' WAV2006
1 (VSUBX,WIl54)),(LAMBDAX,W{l55)),(i....AMBDAZ,'NIl56JI,( TP,W( 157)),
WAV2007
2 (THOO,V" 158) ),(THC,W(15911 ,(PHIC,W(l6011 ,(VGX,WI161) I
WAV200a
REA L LAMBDAX,LAMBDAZ
WAV2009
DATA IMO DX(2)=6H WAVE2)
WAV2010
ENTRY ELECTl
WAV20ll
IF (X.EO.O •• AND.PXPR.EO.O •• AND.PXPTH.EO.O •• AND.PXPPH.EO.O.J RETURNWAV2012
IF (DELTA.EO.O •• OR.SH.EO.O.)
RETURN
WAV20l3
H=RIl)-EARTHR
WAV2014
THO =THO O+LAMBDAX*T?*VGX/VSUBX/EARTHR
WAV2015
EXPR=EXP(-( (H -Z01/ SH1**2)
WAV2016
EXP TH=E XP( - (R(21 -TH 01/ THC)**2)
WAV2017
EXPPHI=EXP(-IR{3)/PHIC)**2)
WAV2018
WW=PIT2*(TP + IPID2 -R (2J J*EARTHR/LAMBDAX+H/LAMBDAZI
WAV2019
SINW =S INIWW)
WAV2020
COSW=COSIWW)
WAV2021
E=DEL TA*E XPR*EXPTH*EXPPH I
WAV2022
CONS=I.0+E*COSW
WAV2023
PXPR=PxPR*cONS-X*E*2.*(COSW*IH-ZO)/SH**2+PJ/LAMBDAZ*SINW)
WAV2024
WAV2025
PXPTH=PXPTH*CONS+2.*E*(X*PI*EARTHR*SINW/LAMBDAX-{R(21 - THO) I
1 THC**2*C OS W)
WAV2026
PXPPH=PXPPH*CONS-X*2.*E*RI31/PHIC**2*COSW
WAV2027
PXPT=-PIT2*VSUBX*E/LAMBDAX*SINW+Z.O*E*VGX/EARTHR*COSW*(RIZI-THO
WA,V2028
1 -LAM BDAX*TP/EARTHR)/THC
WAV2029
X=X*C ONS
WAVZ030
RETURN
WAV2031
END
WAV2032-

137

INPUT PARAMETER FORM FOR SUBROUTINE DOPPLER

HEIGHT

PROFILE OF dN/dt

(A perturbation to an ionospheric electron density model which calculates the time
derivative of electron density for c alculating Doppler shifts)
First card t e lls how many profile po i nt s in 14 format. The c ard s following t he first
c ard g ive t he he i ght and dN/dt of the profile points one point per card in FS . 2, E l2. 4
format. The heights must be in increasing order. Set WISt ::.1. 0 to read in a new
profile. After the c ards are read, DOPPLER will reset W151 .: 0. This subroutine
makes an exponential extrapolation down using the bottom 2 points in the profile.

112T3FTsT6171a 91~II I I~ijl~~16117: laI 19120 1 2T3141sl6171a 9110111 11211311411511611711all *01
HEIGHT

h
km

TIME DERIVATIVE OF
ELECTRON DENSITY
dN/dt
ELECTRONS/em ' /see

HEIGHT

h
km

TIME DERIVATIVE OF
ELECTRON DENSITY
dN/d t
ELECTRONS/em ' /see

,

I

,

I

, ,
,.

,
,
,

,

,

138

SUB~OUTINE

OOPPLER
COMPUTES ON/OT
FR)M PROFILES
AS THOSE USED 9r SUBROUTINE TAB LE X
C MAKES AN EXPONENTIAL ExTRAPOLATION OO~" USING THE
NEEDS SUaROUT[NE GAUSEL

OOPPOOl
THE SAME FHMOOPP002
00PP003
BOTTOH TWO POINTS
OOPPOO'
00PP005
JIM£NSION HP::(ZSQ) .FN2C(Z5Q} .Cl.LP·U(250),BETA(25(JI ,GAH'fA(Z50).
OOPPOOb
1 DElTA(ZSfU ,SlOPE(Z50) ,MArett,S)
00PP007
:OHHON ICONSTI P(,PIT2,PI02,OEGS,R"'O,K.OU~(2)
OOPPOO 6
::OHMON IXXI 1100)(2) ,XOUH,PXPR..PXPT-t,PXPPH,X,HHAX
00PP009
:OMMON R(E,) nn", Itl(10),WO,WC:o.oo)
00PP010
EQUIVALENCE (EA~THRtW(21),(F,jIf(&)lt{REAOFNtW(1511)
OOPP011
REAL HATtK
00PP012
'J ATA (HOOl(21=7HOOPPLER)
00PP013
ENTRY ELECTl
00PP01lo
IF (REAOF".EQ.'.I GO TO 10
00PP015
REAOFN=O.
OOPPOlb
,~EAO 1000, NJC,(liPC(I) ,FN2C(l) .1=l,NOC)
00PP017
IJuO FORHAT HIt/CFe.Z.ElZ.Ct')
00PP016
PRINT 1200, (HPC(IJ ,FNZC(!) ,I=l.NOCl
00PP019
JN/OT
1200 ~ORHAT(lHl,1~(,&KH£IGHTt4(,161
II 1 X. 02 .J .10. E2 O. 1J1 I 0) P P 020
A=Q.
00PP021
IF(FN2CLlI.NE.0.1 A=ALO:;(ON2C(2I1F'2C(1I)/(HPC(21-H'C(1I1
0)PP022
FN2C(1)=K'FN2C(1)
00PP023
FN2C(21=K'FN2C(21
00PP02.
SLOPE(1)=A>FN2CLL)
00PP025
SLOPE(NOC)=O.
OOP P 026
.... ,.,AX=1
00PP027
00PP026
00 6 I=2.NOC
IF (FN2C(lI.GT.FM2C(NMAX)) NM4X=I
00PP029
IF (I.E(;I.NOC) GO TO •
00PP030
FN2C(I+11=K-FN2CCI+l)
OOPP031
)0 3 Jzl,3
00PP032
'1=I+J-Z
00PP033
,' 1AT(J,l)::l.
00PP03.
MAT(J.2)=rlPC(H)
00PP035
MAT(J,3)::HPC(M)··2
00PP036
HAT(J.Iol=FN2C(M)
00PP037
3
CALL GAUSEL OUT .tt .. 3 .. ,+,NRANK)
00PP036
IF (NRANK.LT.31 GO TO 60
00PP039
SlOPE(I)::HAT(2.tt'+2. 4HAT(3,'+)·HPC(I)
OOPPO.O
'+ 00 5 J::l,Z
OOPPO.l
.1 =I+J-2
00PP042
HAT<J.lI =1.
00PP043
'1AT(J,Z)::HPC(H)
00PP044
HAT(J.3J=HPC(H,4·Z
00PP045
00PP046
MAT(J.4)=HPC(H'··3
MAT (J.51=FN2CLHI
00PP047
00PP046
L=J+2
00PP049
HAT (L .1>=0.
HAT(l.ZJ=l.
00PP050
HAT(L.31=2.·HPC(N'
00PP051
MAT(L.4'=3.·HPC(K,·4Z
OOPP052
5 ~AT(L.5)=SLOPE(H'
00PP053
CALL GAUSEL (HAT.,+,4,5 .. NRANK)
00PP054
IF (NRANK.LT.41 GO TO 60
00PP055
ALPHA(I)=KAT(1.51
00PP056
6ETA(I)=HAT<2.5)
OOP P05 7
GAMKA(I)=NAT(3.51
00PP056
6 DELTA(I)=KAT(4.51
00PP059
HHAX=AHlX1(HHlX,HPC(NHAX)1
OOPPObO
NH =2
00PP061
10 H=R(1)-EARTHR
00PP062
FZ=F·F
00PP063
IF (H.GE.HPC<111 GO TO 12
00PP06.
11 NH=2
00PP065

C
C

139

HAV ING

IF(FN2C(II.EO.0.I GO TO 50
X=FN2 C(11*EXPIA*(H-HPC(1)) I/F2

GO TO 50
12 IF (H.GE.HPC(NOCI I GO TO 18
NSTEP=1
IF

(H.lT.HPCINH-ll)

NSTEP=-l

15 IF (HP((NH-!I.LE.H.AN D.H.LT.HPCINHI) GO TO 16
NH =NH+N C;TEP
l~

DOPP066
DOPP067
DOPP068
DOPP069
DOPP070
DOPPO 71
DOPP072
DOPPO 73
DOPPO 74

DOPP075
16 X =(ALPH AINHI+H*(BF.TA{NHJ+H*(GAMMAINH)+H*OELTA(NHJ II )/F2
DOPP076
DOPP077
GO TO 50
J8 X =F N~C(NOCI/F2
DOPPO 78
<;n CONTINUE
DOPP079
RETURN
OOPPORO
f,f"I PRINT 6()l1n,
I .HPC( r I
DOPPORI
600 0 FORMAT(4H THE,T4,55HTH POINT IN THE
DN/DT
PROFILE HAS TDOPP082
lHE HEIGHT,F8.2,40H KM, WHICH IS THE SAME AS ANOTHER POINT.)
DOPP083
CALL EXIT
DOPP084
DOPP085
END
GO TO

140

APPENDIX 5.

MODELS OF THE EARTH'S MAGNETIC FIELD
WITH INPUT PARAMETER FORMS

The following models of the earth's magnetic field are available .
The input parameter forms, which describe the model, and the subroutine listings are given on the pages shown.

a.
b.
c.

d.

Constant dip and gyrofrequency (CONSTY)
Earth- centered dipole (DIPOL Y)
Constant dip . Gyrofrequency varies as the
inverse cube of the distance from the center
of the ea rth (CUBEY)
Spherical harmonic expansion (HARMONY)

142
143

144
145

To add o ther models of the earth's magnetic field the user must
write a subroutine that will calculate the normalized strength and direction of the earth's magnetic field (Y, Y

r

, Y , Y

9

cp

) and their gradients

(oY/o r, oY/09, oY/oco. , oY r 10 r, oY r 109. oY r 10qJ. oY Slo r, oY S/0 9,
oY 9/0cp, oY qJ/o r, oY col09 , oY cp/0qJ ) as a function of position in spherical polar coordinates (r, 9, cp l.
gyrofrequencyand f

(Y = fHI f, where fH is the electron

is the wave frequency. )

The restrictions on electron density models also apply to lTIodels of
the earth's magnetic field.

The coordinates

r,

e , cp

refp.r to

the computational coordinate system, which is not necessarily the same
as geographic coordinates.

W24 and W25 give the geographic latitude

and longitude of the north pole of the computational coordinate sys tem.
The input to the subroutine (r, 9 , 'II )
Table 3.)

is through blank com.m.on.

The output is through common block IYY/.

(See

(See Table 9.)

It

is useful if the name of the subroutine suggests the model to which it corresponds.

It should have an entry point MAGY so that other subroutines

in the program can call it.

Any parameters needed by the subroutine

should be input into W201 through W249 of the Warray.

(See Table 2. )

1£ the subroutine needs massive amounts of data, these should be read in

by the subroutine follow ing the example of subroutine HARMONY.

141

INPUT PARAMETER FORM FOR SUBROUTINE CONSTY
An ionospheric ITlodel of the earth's magnetic fie ld consisting of constant
dip and gyrofrequency
Specify:
gyrofr equenc y , fH ~

MHz (W201)

dip, I ~ _ _ _ _ _ de g rees (W202)
radian s
The magnetic meridian is defined by the geog raphic

coordinates

of the north rnagnetic pole :

radians
latitude

longitude

C

~

degrees

north (W 24)

radians
degrees

east (W25)

SUBROU TINE CONSTY
CONYOOI
CONSTANT DIP AND GYROFREOUENCY
CONY002
COMMON IYY/ MODy,y,PVPR,PYPTH,PYDPH,YR,PYRPR,PYRPT,PYRPP,YTH,PYTPRCONV003
1,PYTPT,PYTPP,YPH,PYPPR,PYPPT,PYPPP
CONV004
COMMON /WW/
EOUIVALENCE
DATA

IDI I O),WO ,W(40 01
(F,W I6) ) ,(FH,W (ZOll} ,(DIP,W {Z02 ))

(i.,ODY =6H CONSTYl

CONV005
CONY006
CONYOD7

ENTRY MAGY

CONYOOB
CONY009
CONYOIO
CONYOll
CONY0 12
CONY013 -

Y~FH/F

YR=Y*SIN {DIPI
YTH:Y*COSCDIPI
RETURN
END

142

INPUT PARAMETER FORM FOR SUBROUTINE DIPOLY
An ionospheric model of the earth 1 s magnetic field consisting of an earth
centered dipole
The gyrofrequency is given by:
"" .1
R +h'
2
f
=f
( _0_)3 ( I + 3 COS A)"
H H o Ro
'(F

The magnetic dip angle 1 I, is given by
tan I ;:: 2 cot A
h is the height above the ground
Ro is the radius of the earth
A is the geomagnetic colatitude

Specify:
the gyrofrequency at the e quator on the ground,

fHo ::; ______ MHz (W201)

the geographic coordinates of the north magnetic pole
radians
latitude
degrees north (W24)
longitude

;:: _ _ _ _ __

radians
degrees east (W25:\

SUBROUTINE OIPOLY
DIPOOOI
COMMON ICONST/ PJ,PJT2,PID2,OUM(SI
DIP0002
COMMON IYY! MOOY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRP T,PYRPP,YTH,PYTPRDIP0003

1,PYTPT,PYTPP,YPH.PYPPR,PYPPT ,PYPPP

COMMON Rlbl IWWI IDIIOI,WQ,WI4QQI
EQUIVALENCE (E ARTHR,W1Z) I, (F,W (6 11,I FH,W1ZOllj
OATA (MOOV=6HOIPOLVJ
ENTRY MAGY
SIN TH=SIN(R(211
COSTH=SIN (PID2-R(2 11
TERM9 =SQRTI1 . +3.*C OSTH**2)
Tl=FH*IEARTHR/R{111**3/F
Y=Tl*TERM9
VR= 2.*Tl*COSTH
YTH= Tl*SINTH
PYRPR=-~.*YR/R(ll

PYRPT=-2.*YTH
PYTPR=-3.*YTH/RIl)
PYTPT=.S*VR
PYPR=-3.*Y/RIll
PVPTH=-3.*V*SINTH*CQSTH/TERM9**2
RETURN
END

143

DIP0004

DIP0005
DIP0006
DIP0007
DIPOOOS
DIP0009
DIPOOIO
DIPOOII
DIPOOl2
DIPOOl3
DIPOOl4
DIP.oOl5
DIPOOl6
DIP0017
DIPOOIS
DIPOOl9
DIP0020
DIP0021
DIP0022
DIPOO23-

INPUT PARAMETER FORM FOR SUBROUTINE CUBEY
A model of the earth' 5 magnetic field consisting of a constant dip and
a gyrofrequency which varies as the inverse cube of the distance from
the center of the earth
This model has the same height variation as a dipole magnetic field.
The gyrofrequency is given by:

a

is the radius of the earth.

r

is the distance from the center of the earth.

Specify:

gyrofrequency at the ground,

dip, I =

radians
- - - - - - - degrees

~o = _ _ _ _ _-----'MHz

(W201)

(W202)

The magnetic meridian is defined by the geographic coordinates of the
north magnetic pole:

radians
latitude = ______ degrees north (W24)
km
radians
longitude = _ _ _ _ _:degrees east (W25)
km

C
C
C

SUBROUTINE CUBEY
CUBEOOI
CONSTANT DIP.
CUBE002
GYROFREO DECREASES AS CUBE OF DISTANCE FROM CENiER OF EARTH.
CUBE003
THIS MODEL HAS SAME HEIGHT VARIATION AS A DIPOLE FIELD.
CUBE004
(OMMON IYY/ MODy,y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRPT,PYRPP,YTH,PYTPRCUBE005
1,PYTPT,PYTPP,VPH,PVPPR,PVPPT,PVPPP
CUBE006
COMMON 'R IWWI ID(lOI,WO,W(4001
CUBE007
EQUIVALENCE (EARTHR,W(211,(F,W(611,(FH,W(2011),(DIP,W(202J 1
CUBEOoa
DATA(MODY =5HCUBEYI
CUBE009
ENTRY MAGY
CUBEOIO
V=(EARTHR/RJ**3 *FH/F
CUBED11
YR= Y*SINfDIP)
CUBE012
VTH = V*COS(DIPI
CUBE013
PYPR=-3.*Y/R
CUBE014
PYRPR=-3.*YR/R
CUBE015
PYTPR=-3.*VTH/R
CUBE016
RETURN
CUBE017
END
CUBED18-

144

INPUT PAR AMETER FORM FOR SUBROUTINE HARMONY

A model of the earth's magnetic field based on a spherical harmonic
expansion
The upward, soutberly, and easterly components of tbe earth's magneti
field are given by:

6

Hr = -

n +2

I (n+1)(~)

cos m cp + h

m
n

sinm cp)

n=o

.
- gnmSlnrn
~)

where
a

is the radius of tbe eartb.

r, 8 , ~ are spherical (eartb-centered) polar coordinates.
H o(8} = 1
a
o
H (8 } = cos 8
l
HII (8 ) = sin 8
H

rn+ 1

rn(8} = H

rn

rn(8} cos 8

Hm+1 rn+l(8} = Hm rn(8} sin 8

Hn+2

m 8
m(8 )
8
(n+rn+l)(n-rn+l)
() = H n + 1
cos
- (2n+3)
(2n+ 1)

G rn(8} = - : 8 Hn rn(8} sin8
n

145

H rn(8}
n

m

G

(e) = -mH

m

+
n 1

G

m

m
m

(e) cose

(e) = -(n+l) Hn+l

m

(e)cose

+ (n+m+l) (n-m+l) H m(e)
2n+l
n

T he recursion formulas for calculating H
n
Eckhouse (1964).

m

(e) and G

m
n

(e) are from

This subroutine uses coefficients gn m and h n m for Gauss normalization.
Some coefficients are now being published for Schmidt normalization
(e. g. Cain and Sweeney, 1970). The factors Sn, m used for converting
the "Schmidt normalized" coefficie nts to the "Gauss normalized"
coefficients are as follows (Cain, et. al., 1968, Chapman and Bartels,
1940) :
S·

= -1

S

= S n-l,o [2:-1J

0,0

n, 0

s{!K
n+l

S

n, 1 = n,o

S

= S
n, rn.

_!(n-m+l)
n, rn.-I "
n+rn.

for m)1

By convention, the "Gauss normalized" coefficient gl° is positive,
whe reas the "Schmidt normalized" coefficient gl° is negative. Coefficients based on more recent data on the earth's magnetic field including
nlOre satellite data are in the POGO 8/69 model.
Specify below the Gaus s coefficients gn
columns
2- 10
0

1st card

go

2nd card

gl

3rd card

g2

4th card

g3

5th card

g4

6th card

gs

7th card

g6

0

0

0

0

columns
21 - 30

and h

columns
31 - 40

n

m.
ln gaus s .

columns
41 - SO

columns columns
51 - 60 61 - 70

=
1
gl=--

0

0

columns
11 - 20

m

=
=
=
=
=

1
2
g =
g =
2-- 2-1
2
3
g 3 = - - g3=- - g3=- 1
4
2
3
g =
g =
4 - - g4=- - 4 - - g4=- 1
2
4
S
3
g =
S - - gS=- - gS=- - gS=- - gS=- 1
2
3
4
S
6
g =.
g =
g =
g =
6 -6 -6 -6 - - g6=- - g 6 = - -

146

0

8th card

h

9th card

h[

10th card

h2

11 th card

h3

12th card

h

13th card

h5

14th card

h6

0
0

0

0

0

=
1
h =
1
1
h =
2 - 1
h =
3 -1
h =
4 -1
h =
5 -1
h =
6 - -

=
=
=

=

4
0

0

=
=

2
h =
2 -2
3
h =
h =
3 -3
2
3
h 4=
h =
h =
4 -4
4
5
2
3
h 4=
h =
h =
h =
5 -5 -5 -5
5
2
3
h 6=
h 4=
h =
h =
h =
6 -- 6 -- 6 -- 6
6 - -

Set W200 = 1. to read in a set of coefficients .
This subroutine represents:

H

rn
n

rn

G

(e) by H(rn+ l, n+l)
(e)byG(rn+l,n+l)

tl

by GG(rn+l, n+l)

h

C

rn
n

by HH(rn+l, n+l)

SUBROUTINE HARMON y
MODEL OF THE EARTH S MAGNETIC FIELD BASED ON A HARMONIC ANALYSIS

HARMODl
HARM002

DIMENSION PHPTH(7,7J ,PGPTH(7,7) ,A1(7,7) ,81(7,7)
HARMOD)
DIMENSJON H17,7) ,G17,71 ,GG(7.71 .HH(7,7),SINP(7),caSP(7)
HARM004
COMMO~ IYY/ MODy,y,PYPR,PYPTH,PYPPH,yR,PYRPR,PYRPT,PYRPP,YTH,PYTPRHARM005

HARM006

1,PYTPT ,PYTPP ,YPH,PYPPR,PYPPT,PYPPP
Cm·1MON R(6)

C

/~"WI

IDCIO),WQ,WI400 1

HARMOD7

COMMON ICONSTI PI,PIT2,PID2.DUM(SI

HARMOOe

EOUIVA L ENCE
EQUIVALENCE

HARM009
HARMOIO

(THETA,RI21) ,(PHI,RI3' )
IEARTHR,WI2J ),IF,W(6)) ,IREADFH.WI200IJ

RAT IQ OF CHARGE 10 MASS FOR FLECT~ ON
DATAIEOM = 1.7589E7)
DATA (5E1=0.) ,iH=1.,48(O.», (G =49(O.»
1 ,(P GPTh =49(O.» tCMOJY=7HHARMONY)
ENTRY MAGY
IFISET) GO TO 2
DO 1 M=1,7
DO 1 N=1,7
BICM,NI=(N+M - ll·(N - M+11/C2*N-1.1
AICM,Nl=81CM,N1/C2*N+11
SET=,.

147

,(PHPTH=49(O.»

HARMOll
HARM012
HARM013
HARM014
HARM015
HARM016
HARM017
HARM018
HARM019
HARM020
HARM021

2 IF(READFH.EQ.O.) GO TO 3

HARM022

READ 20QQ,GG.HH
2000 FORMAT(lX,F9.4,6FIO.4)

KARM023
HARM024

PRINT 210Q,GG
HARM025
2100 FORMAT(lHl,lOX,lHQ,14X,lHl,14X,lH2,14X,lH3,14X.lH4.14X,lH5.14X,lH6HARM026
1/9X,7(lHG,14XI/IOX,7 1 1HN'14XI//(lX,7F15.6))
HARM027
PRINT 220Q,HH
HARM028

2200 FeRMAT(// llX,lHQ,14X,lHl,14X,lH2.14X,lH3,14X,lH4,14X.IHS.14X.IH6HARM029
1 19X,7(IHH,14X)/lOX,7(lHN,14XII/(lX,7F15.6))
HARM030
3

4

5

6

READFH=O.
COSTHE=COS(THETA)
SINTHE=SIN(THETA)
AOR=EARTHR/R(lJ
PAORPR= - AOR/R(I)
CNST2=AOR
PCNSPR=PAORPR
FINI=PFINIR=PFINIT=PFINIP=O.
FIN2=PFIN2R=PFIN2T=PFIN2P=O.

HARM031
HARM032
HARM033
HARM034
HARM035
HARM036
HARM037
HARMD38
HARM039

FIN3=PFIN3R=PFIN3T=PFIN3P=O.
DO 4 M=1,7
SINP{MI=SIN{(M-!I*PHII
COSP(M)=CQS((M-!I*PHIJ

HARM040
HARM041

HIl.2i=COSTHE

HARM044

H(2,2)=SINTHE
DO 5 M=1,5

HARM045
HARM046

H(M+l'~+2J=COSTHE*H(M+l,M+ll

HARM047
HARM048
HARM049
HARM050
HARM05l
HARM052
HARMO 53
HARM054
HARM055
HARM056
HARM057

HARM042
HARM043

H(M+2,M+21=SINTHE*H(M+l,M+ll
DO 5 N=~,5
H(M,N+2 1=COSTHE*H(M,N+II-Al(M,NI*H(M,NI
DO 6 M=1,6
G(,101+1 ,M+l J =-M*COSTHE*H(M+l ,r~+l I
PHPT H (M+ 1,,"'1+ 1 I =-G U-1+ 1 ,M+ 1) IS r NTHE
PGPTH (M+ 1 ,M+ 1) =M*S I NTHE*H (M+ 1 ,M+ 1) -M*COSTHE*PHPTH (tof+ 1 ,M+l)
DO 6 N=M,6
G(M,N+ll=-N*C05THE*H(M,N+ll+81(M,N'*H(M,NJ
PHPTHIM,N+IJ:-G(M,N+11/5INTHE

PGPTH(M,N~lJ=N*5INTHE*H(~,N+l)-N*COSTHE*PHPTH(M,N+l)+Rl(M,Nl*PHPTHHARM058

1 (M,NI
DO 8 N=1,7
CR=PCRPTH =PCRPPH= O.
CTH=PCTHPT=PCTHPP=O.
CPH=PCPtiPT=PCPHPP=O.
DO 7 M=l,N
TEMPl=GG(M,Nl*COSP(M'+HH(M,NI*5INP(MI
TEMP2= (M-l) * (HH (M ,N I *casp (MI -GG (M ,N) *5 TNP (HI)
CR
=CR
+H(~,Nl*TEMPl
PCRPTH=PCRPTH+PHPTH(M,Nl*TEMPl
PCRPPH=PCRPPH+H(~,~I*TEHP2

CTH
=CTH
+G(M,NJ*TEMPI
PCTHPT=PCTHPT+PGPTH(M,Nl*TEMPl
PCTHPP=PCTHPP+G(M,NI*TEMP2
CPH
=CPH
+H(M,NI*TEMP2
PCPHPT=PCPHPT+PHPTHIM,N'*TEMP2
7

PCPHPP=P,CPHPP-H(M,N)*(M-IJ**2*T~MPl
CNST2=(~IST2*AOR

PCNSPR=CNST2*PAORPR+AOR*PCNSPR
FINl=FTNl+N*CNST2*CR
PFINIR=PFINIR+N*PCNSPR*CR
PFINlT=PFINIT+N*CNST2*PCRPTH
PF r N IP=PF I·N lP+N*CNS T 2*PCRPPH
FIN2=FIN2+CNST2*CTH
PFIN2R=PFIN2R+PCNSPR*CTH
PFIN2T=PFIN2T+CNST2*PCTHPT
PFIN2P=PFIN2P+CNST2*PCTHPP
FIN3=FIN3+CNST2*CPH

148

HARM()59
HARM060
HARM061
HARM062
HARM063
HARM064
HARM065
HARM066
HARM067
HARM068
HARM069
HARM070
HARM07l
HARM072
HARM073
HARM074
HARM075
HARM076
HARM077
HARM078
HARM079
HARM080
HARM081
HARM082
HARM083
HARM084
HARM085
HARM086

P FI N3 R=PF IN3 iH PCNSPR"'CPH

a

HARM087

P FINH= PF INH +CNST2 "PCPHPT

HAR M066

PFIN3P=PFIN3P"CNSTZ·PCPHP::>

HARt10a9

~THETA=-FIN2/SINTHE

HARHOgO
HARMOg1

HPHI=FIN3/SINTHF.
C~·~·····'"

CONvERT FROM MAG FIELQ IN G4USS

TO GYROFREQ IN H~Z

HARH09Z

:ONST=-EOH/PIT2"t . E-6/F
YR=-CONST"FINt

HARHOg3

YTH=CONST'HT~ETA

HARMOg5

YPH=CONsr·H?HI
Y=SQRT(YR··2"YTH··2+YPH··Z)

HARM096
HARM097

PYRPR=-COHST+PFIN1~

P YTPR=-CONS T'PF IN2R/51 NT HE
cYPPR=CONST' PF I "3RI SIN THE

HARHOg6
HARM Ogg
HA RM10 0

PYPR= (YR"'PY ~PR"YTH· PYTPR+YPH·PYPPRJ IV

HARt110i

PYRPT=-CONST+PFINl T
>YlPT =-CONS T' (PFI N2 TIS INT"E +H THET A'COS THE/SI NT HE)
PY PPT=C ONST' (PF I.3T lSI NTH E-HPH ":05 THE/SINTHE)

HARHt02
HARIHO J
HAR HtO ~

PYPTH= ('t'R,.PY RP T .... TH "'PY TPT "YPH. PY??T) IY
P YT PP=-CONS Tt-? FIN2P lSI NT HE

HARHi05
HARMi0G
HAR M10 7

PYPPP=CON ST" PF IN] PI SIN THE
PYPPH=' 't'R·Py RPP+'f TH "'PY TPP+ YPH· PYPPP) IY

HARH109

HARMOg~

~YRPP=-CONST·PF[N1P

HARM to 6

RETURN
HARHttO
C
COEFFICIENTS IN GAUSSIAN UNITS FROM JONES AND HELOTTE (195]).
HARM11t
:
THE FOLLOWI., 1. CARDS CAN 3E USED AS DATA CARDS FOR THIS SUBRDUTINEHARMl12
C
O.
HARHl13
C.3039
.Ol16
HARMll~
C.0t76
-.Q5Qg
-.0135
HARH115
C-.0255
.0515
-.02J6
-.00"
HARH116
C-.OH~
-.OJ97
-.0236
.a067
-.0016
HARH117
C.029]
-.0329
-.0130
.00Jl
.OOJ~
.0005
HARM118
C-.0211
-.0073
-.0( ,:7
.0210
.0017
-.OOO~
.000.
HARH119
C O.
HARH120
C
-.0555
HARM121
C
.02.0
-.00"
HARH122
C
.0190
-.0033
-.0001
HARH1ZJ
C
-.0139
.0076
.0019
.0010
HARH124
C
.0057
-.0016
.OOO~
.0032
-.OOO~
HARM1Z5
C
-.0026
-.0204
.0016
.0009
.0004
.0002
HARH126
C
THo FOLLOWING SET OF GAUSS NORMALIZED COEFFICIENTS WERE CONVERTED
HARN127
C
FROM THE SCHMIDT NORMALIZED COEFFICIENTS CALCULATED BY LINEARLY
HARH128
C
EXTRAPOLATING TO EPOCH 197. THE COoFFICIENTS PUBLISHED FOR EPOCH
H4RH129
C 19.0 BY CAIN AND SWEENEY (1970).
(USES EARTH RADIUS = 6J71.2)
HARH1JO
C .000000
HARH131
C+.30095J +.020296
HARH132
C+.028106 -.052"
-.014435
HARH1JJ
C-.0306
+.0.5;;0
-.025252 -.00'~52
HARH134
C-.041Z43 -.04395. -.01.897 +.006021 -.002525
HARH135
C+.C1'7~2 -.037076
-.016g06 +.00Z519 +.00365. +.00003.
HARH13.
C-.006713 -.01223~ -.00.3.4 +.02137
+.001593 -.000072 +.00066
HARM137
C .000000
HARH138
C .000000 -.05788.
HARH139
C .0UOOOO +.OJ59.2 +.001129
HARH140
C .000000 +.01106~ -.004421 +.001180
HARH141
C .000000 -.010299 +.0087g4 -.000086 +.002256
HARH14Z
C .000000 -.0036~9 -.012615 +.0076~5 +.002207 -.000326
HARH143
C .000000 +.003157 -.012670 -.009261 +.002266 -.000135 +.0002~3
HARH14~
END
HARH145-

149

APPENDIX 6. COLLISION FREQUENCY MODELS WITH
INPUT PARAMETER FORMS
The following collision frequency m.odels are available .

The input

param.eter form.s, which describe the m.odel, and the subroutine listings
are given on the pages shown .
a.
b.
c.
d.

Tabular profiles ( TABLEZ)
Constant collision frequency (CONSTZ)
Exponential profile (EXPZ)
Com.bination of two exponential profiles
(EXPZ2)

152
155
156
157

To add other collision frequency m.odels the user m.ust write a subroutine that will calculate the norm.alized collision frequency (Z)

and

its gradient (OZ/O r, oZ/09, oZ/ocp) as a function of position in spherical
polar coord inates (r, 9, cp ).

(Z = v/2 n f, where V is the collision fre-

quency between electrons and neutral air m.olecules and f is the wave
frequency.

If the Sen- Wyller form.ula for refractive index is used, then

Z = v

/2 n f , where V
is the m.ean collision frequency. )
m.
m.
The restrictions on electron density m.odel. also apply to collision

frequency m.odels.

The coordinates r,

e ,cp refer to the com.putatio nal

coordinates system., which m.ay not be the sam.e as geographic coordinates.

In particular, they are geom.agnetic coordinates when the earth-

centered dipole m.odel of the earth's m.agnetic field is used.
The input to the subroutine (r, e,<tl) is through blank com.m.on.
Table 3.)

The output is through com.m.on block /ZZ/ .

(See

(See Tablel0 .) It

is useful if the nam.e of the subroutine suggests the m.odel to which it cor responds.

It should have an entry point COLFRZ so that other subrou-

tines in the prograIn can call it.

Any param.eter needed by the subroutine

should be inl'ut into W251 through W299 of the W array.

(See Table 2. )

If the Inodel needs Inassive am.ounts of data, these should be read in by
the subroutine following the exam.ple of subroutine TABLEZ.

151

INPUT PARAMETER FORM FOR SUBROUTINE T ABL EZ

IOIWSPHERIC COLLlSIOIl FREQUEIKY PROFILE
T h e first card t ells how many profile points in 14 farrnaL

Th e c ards follow ing the fi rs t

c ard giv e the he ight and collision frequency of the profile po int s one po int per c ard i n
Set W 250 = 1. 0 t o

F 8 . 2, E 12. 4 forma t.

T he heights must be in increasing order .

r e ad in a new profile.

After the cards are read, TABL E Z w ill res et W 2 50 = O. o.

T his subroutine makes an exponential extrapolation down using the bott om 2 points in

t he profile.

I 2 3,456 7; S 9 loi ll 1 1 1 3 ~ 1 4 i I5 1 6 ~ 17 : IS : 19 120 112i 3i 45 ; 6i 7i S' 9 iIOi ll :12iI3hI 5iI 6i I7 iISI19120i
HE IGHT

COLLISION FREQUENC Y

HEIGHT

COLLISION FREQUENC Y

COLLI S I ONs/sec.

h
km

COLLI S IONs/sec.

v

h
km

v

1 +-1-1-

I --'-t-t
-"--T -+--+-+--

,

,

,

I , ,

-'-

I

1

I

1

~ --i ~t·-t--I·-- -

I

I

I

I

I

I-I-j-+--

t--I- +- I -+-,-+-L

I

I

I

I

,

, ,

,
I

I

-1-1--1-+

152

I

I

I

I

I

I

I

I

I

1

I-+-t--I- --

1

1

SUBROUTINE TABLEI
:ALCULATES COLLISION FREQUENCY A~O ITS GRADIENT FROM PROFILSS
HAVING THo SAME FORM AS THOSE USED BY CROFTS RAY TRACING PROGRAM
C ~AKES AN EXPONENTIAL EXTRAPOLATION ~OWN USING THE BOTTO~ TWO POINTS
C
NEEDS SJOR~UTINE GAUSEL

C
C

DIMENSION
1

HP:(100),FN2C(100),~LPHA(100),BETA(lCOJ.

GAHI'1A(1001 ,DELTA(100) ,I'1AT(~,5) ,5LOPE(100)

:OHMON tCONSTI P(,PIT2,PI02,OJM(5)

:OHHON IlZI

HOOl.l,PZPR,PZPTH,PZ~P~

COMMON FUo' IWHI IO(10I,HO,ltHItOO)
EQ.UIVALENCE (::AR.fHR,W(Z)). (F"H&I) t<PEAONU,WC25011
UAL MA T
~ATA

(MOOZ.6HTA~LEI)

ENTRY COLF~1
[F (.NOT.~EADNU)
REAONU'O.
~EAO

l

2,

GO

TO 10

NO::,(HPCCII ,FN2C(I) ,I::::l,~O::)

FORMAT([4/(F8.l.E1l.4))
PRINT 1200, (HPC( II .FN2C(II,

1200

l;I,NDe)

FORHAT(lHlfl~X,bHHEIGHT,~X,20HCOLLISION

FREQUENCY

1(lX,F20.10,E2J.10I)
A·O.
[F(FNlCU) .N£.O.I A'ALOG(FNlC(l)/FNlC(ll )/(HPCIZ) -HPC(lll
>NlC(1)'FN2C(11/PITl'1.E-6
FNlC(Z)'FNlC('I/PITZ'1.E-6

SLOPE(11;A·FN2C(11
SLOPE(NOCI'O.
)0 5 I'Z.NOC
IF(I.EQ.NOCI GO TO 6
FNZC(I+l)' FNZCII+11/PITZ'1.E-6

JO 3 J::l,3

M=I+J-Z
MAT (Jtl)=1.
HAT(J.Z)'HPC(HI
~AT(J,3'=H~C(H)··2

3

MAT(J,~)=FNZC(H)

CALL GAUSEL PlAf.It,3,It,NRANK)
IF

INRANK.LT.3)

GO

TO ZO

SLOPE (Xl =I1AT (2 ,It)"2 .·Jr1AT (3, It) .HPC(I)
;

:ONTINUE

iJO It ..J::1,2
Jr1=I"J-Z
MAT(J.l)=l.
UT(J.ZI=HPC(HI

I1AT(J,3J;HPC(H)··Z
MAT(J,It)::HPC(")··3
HAT(J.51=FNZCIHI

L=J"Z
HAHL.U',.

HAT(L,Z)::1.
~ATIL.31'Z.·HPCIMI

I1AT(L,It)::3.·HPC(H)··Z
4

~ATIL.51=SLOPE(MI

CALL GAUSEL (HAT.It,4,5,NRANK)
IF (NRANK.LT.41 GO TO ZO
ALPHA(II'HAT(1.51
3ETA(I1=HAT(Z.51
~AHHA(I'=MAT(3,5)

S

DELTA(II=HAT('.51
JUP=Z
10 H=Rlll-EARTHR
IF (H.GE.HPC(UI GO TO 1Z
1l JUP=Z
Z=FNZC(ll'EXP(A"H-HPC(lIII/F
PZPR=A'Z

153

TAB lOO 1
TABZOOZ
TABZ003
TABl004
TAB lOOS
TAB Z006
TABl007
TABl008
TABl009
TABlOl0
TAB lOll
TABl01Z
TAB lOll
TABl014
TABl01S
TABl016
TABl017
TAB l018
TABl019
TABzoza
TABlOZl
TAB lOZZ
TAB ZOZ3
TABIOZ4
TAB lOZS
TABlOZ6
TABZOZ7
TABZOZ8
TAB lOZ9
TABl030
TABl031
TABl03Z
TABl033
TABZ034
TAB Z035
TAB l036
TABZ037
TABl038
TAB Z039
TABZO,O
TABZ041
TAB l04Z
TAB Z043
TABZO . .
TABl045
TABZO,6
TAB ZO.r
TAB Z048
TAB l049
TAB l 050
TABZ051
TABZ05Z
TAB Z053
TAB Z054
TABZ055
TABZ056
TABl057
TABZ058
TABZ059
TABZ060
TAB Z061
TABl06Z
TAB la63
TABl064
TABl065

TABl 0 66
TABl 06 7
NS rEP= I
TABl068
IF fH.LT.HPCfJUP-I)) NSTEP=- I
TABl069
15 IF fHPCfJUP-]l.GT.H.OR.H.GE.HPCfJUP)) GO TO 16
TABl070
Z=IALPHA(JUPI+H*IBETAIJUP)+H*!GAMMA(JUP1+H*DELTA(JUPJ IIIIF
TABl 07 1
PlPR=IBET~(JUPI+H*12.*GAMMA{JUPI+H*3.*OELTA(JUP)))/F
TABl072
TABl073
RETURN
}6 JUo=JUP+NSTEP
TABl 074
IF CJUP.LT.21 GO TO 11
TAAl 0 75
IF fJUP.LT.NOC) G(l TO 15
TABl 076
18 JlJP=NO(
T ABlO 77
l=FN2CfNOCl/F
TABl078
PZPR=n.
TABl 079
RETURN
TABl OBO
20 PRINT 7.1. J,HPcctl
TABl ORl
21
FORMAT'4H THE.I4.5BHTH POINT IN THE COLLISION FREQUENCY PROFILE HATABl082
1S THE HEIGHT.F8.2,40H KM, WHICH IS THE SAME A~ ANOTHE R POINT.'
TABl083
TABl OB4
CALL FXIT
END
TABlOB5
12

RETUR"I
IF IH.GE.HPC(NOCI I

GO TO 18

154

INPUT PARAMETER FORM FOR SUBROUTINE CONSTZ
An ionospheric collision frequency model consisting of a constant collision
frequency

" = 0

for I) < h
-

for h> h

.

m iD

min

Specify:

(

"0

= _ _ _ _ _ collisions pe r second (W251)

h

=

min

-----

krn (W 2 <;2)

SUBROU TINE (ONSTl
CONSTAN T COLLISION FREQUENCY
COMMON ICONST/ PI,PIT2,PI02,DUM(51
COMMON IlZI MOOl,Z,PZPR,PZPTH,PZPP H
(OMMON R(6)

/WWI

EQUrVAL::NCE

(EARTHR,W(2) J, (F,W{61I,{NU,WI251) I ,(HMIN,W(2521)

IDIIO),WQ,W(400J

REAL NU
DATA (MOD l=6HCQNSTlJ
ENTRY (OLFRl
H=R '11 -EARTHR
l=O.

IF ( H.GT.HMINI Z=NU/ ( PIT2*Fl*1.E-6
RETURN
END

155

(ONlOOl
(ONl002
(ONl003
(ON2004
(ON2005
(ON2006
(ON2007
(ON2008
(ON2009
(ON2010
(ON20 11
(ON2012
(ON2013
(ON2014-

I N PUT PARAMET ER FORM F OR S UB R O UT I NE E XP Z
An ionospheri c collis i on frequency model consisting of an exponential
profile

h

is the h ~ight above the groWld

Specify:
The collis.lon frequency at the h.:;ight

he, Vo
collisions per second (W251)

The reference height,

110 = _ __ ______ km (W252)

The ~xpo:''len:ial decrease 0:

c

a = _ _ _ _ _ _ _ _ _-ckrn - 1
( W253)

SUBROU TI NE ExPZ
EXPONENTIAL COLL ISION FREQUENCY MODEL
(OMMON ICONSTI PI,prT2,p r02 , DUM(51
(OMMON I l l / MOQZ,Z,PlPR,PZPTH,PZ PPH
COMMON RCb) /WWI rO(l OJ,WQ,W(4001

EXPZOOt
EXPZOOz

REA L NU , ,"lUG

EXPZ006

EQU I VALENCE
1

\) with tv'!ight,

(EAR THR, w(2 ) ) , (F, ',4 (6) ) , (NUD, W( 25 1 ) I • (H O , W (252 I I ,

(A,W ( 253J J

DATA ( MOnl=6H EXPZ I

ENTRY COLFRZ
H=R( j l - EAPTHR
NU=NUQ/EXP (A*CH- HOI I
Z=NU/ f P I T2* F*1 . E6)
PZPR
=-A*l

EXPZ003

EXPl004
EXPZ005

EXPZ007
EXPlOOa
EXPZ009
EXPZOIO
EXPZOll
EXPZOIZ
EXPZOl3
EXPZ014

RETURN
END

EXPZOl5
EXPZOI6 -

15 6

INPUT PARAMETER FORM FOR SUBROUTINE EXPZ2
An ionospheric co lli sion frequency tnodel consisting of a cotnbination of
two exponential profiles
V = \he

- a,(h-h1 )

where h

+ v2 e

- "-<; (h - h. )

is the height ab:Jve the ground.

Specify for the first exponential:

Collision frequency at height hl J

= ---,_ __ ---,-;-;=",-;,,-;_ _ collis ion s

\1 1

per second (W 251)

Reference h e igh~,

h1

;

Expo·~1.e-ntial decrease of

_ _ _ _ _ __

\I

with he i ght,

km (W2 5 2)

al

= _ __ _ _----'km - 1 (W2 53 )

Specify for th ·~ second exponential:

Collision frcq'~ency at height h2 .

\1 2

= _ _ _ _ _-:--,--_ _.,-_collisions

p'or second (W254)

Reference h.ight,

h . ; _ _ _ _ _ _ _km (W255)

Expvnential decrease of \) with beight,

~

_ _ _ _ _ km - 1 (W2S6)

SUBROUTrNE EXPl2
COLLISION FREQUENCY PROFILE FRO~ TWO EXPONENTIALS
CO MM ON ICONST! PI,PIT2,PI02,DUMISI
COMMON IlZ/ MODZ,Z,PZPR,PZPTH,PlPPH
COMMON RI61 /WW/ tD(lO),WQ,W(4COJ

c

EOU t V 1\ L ENe E

1

(Al,W(2~1)

J

'f AR THR , W( 2 ) I , ( F ,W { 6 J I , ( NU 1 'W ( 251 ) J , I HI, W( 252 I I ,
,INU2,W(2541),{H2,W(25,)J,(A2,WI25&1'

RFA.L NUl.NU2
DA TA (Mn~Z=6H EXPZ?I
I="NTRY COLFRZ
H=Rfll-EARTHR
EXPl = NUl* EXPf - Al*IH - Hll I
EXP2 = NU2. EXP(-A2*(H - H21 I
Z=(EXP1+EXP2)/(PIT2*F*1.E6)
PZPR = (-Al*FXPl - A2*EXP?I/(PIT?*~*1.F61

RETURN
ENO

157

XPl2001
XPl2002
XPl2003
XPl2004
XPl2005
XPl2006
XPl2007
XPl2008
XPl2009
XPl2 010
XPl2 0 11
XPl2012
XPl2013
XPZ20j4
XPl2015
XPl2016
xpl2017-

APPENDIX 7.

CDC 250 PLOT PACKAGE

This appendix describes the plotting routines used by the ThreeDimensional Ray T racing Program.

T he information was taken from

"User's Guide to Cathode Ray Plotter Subroutines," ESSA Technical
Memorandum ERLTM-ORSS 5, by L. David Lewis, January, 1970, and
is printed with the permission of the author.
If you have access to a plotter, you may obtain plots by converting

the following plotting commands to comparable commands on your
system.
The CDC-250 Microfilm Recorder, under control of the NOAA
Boulder CDC - 3800 computer, plots data on the face of a high resolution
cathode ray tube, which is photographed onto standard sized perforated,
35 mm film.
T he plotting area, called a frame, is a square .
are described in rectangular coordinates.

Plotting positions

Coordinate values are inte-

gers in the range 0 - 1023; (0,0) is the "lower left hand corner".
Plotting specifications are transmitted to the plot routines via the
following COMMON.
COMMON /DD/ IN, IOR, IT, IS, IC, ICC, IX, IY
T he usage of each of the eight variables is listed below, followed by an
explanation of the subroutine calls .
IN

Intensity.
IN=O specifies normal intensity.
IN=1 specifies high intensity.

lOR

Orientation.
IOR=O specifies upright orientation.
IOR= 1 specifies rotated orientation (90· counterclockwise) •

IT

Italics (Font).
IT=O specifies non-Italic (Roman) symbols.
IT=1 specifies Italic symbols.

159

IS

Symbol size.
IS=O specifies miniature size.
IS= 1 specifies small size.
IS=2 specifies medium size.
IS=3 specifies large size.

IC

Symbol case.
IC=O specifies upper case.
IC= 1 specifies lower case.

ICC

Character code, 0-63 (R1 format).
ICC and IC together specify the symbol plotted.

IX

X-coordinate, 0-1023.

IY

Y -coordinate, 0-1023.

CALL DDINIT (N,ID) is required to initialize the plotting process.
CALL DDBP

defines a vector origin at position IX, IY.

CALL DDVC

plots a vector (straight line), with intensity IN, from
the vector origin defined by the previous DDBP or
DDVC call, to the vecto:: end position at IX, IY. A
single call to DDBP followed by successive calls to
DDVC (with changing IX and IY) plots connected
vectors.

CALL DDTAB

initializes tabular plotting.

CALL DDTEXT (N, NT) plots a given array in a tabular mode, after
initiating tabular plotting via DDTAB, as described
above. NT is an ar ray of length N, containing "text"
for tabular plotting. Text consists oC character
codes, packed 8 per word (A8 Format). Text
characters are plotted as tabular symbols until the
cO'.11mand character I (octal code 14, card code
4,8, or the alphabetic shift counterpart of the = on
the keypunch) occurs. The command character is
not plotted. DDTEXT interprets the next character
asa command; and after the command is processed,
tabular plotting resumes until I is again -encountered.
I . means end of text: DDTEXT returns to the
calling routine.
CALLDDFR

causes a frame advance operation. Plot1:ing on the
current frame is completed, and the film advances
to the next frame.

160

APPENDIX 8.

SAMPLE CASE

A sam.ple case is included with the description of the program. for
three reasons.

First, it dem.onstrates the use of the program..

Second,

it illustrates the three types of output available (printout, punched cards,
and ray path plots).

Finally, it serves as a test case to verify that the

user's copy of the program. is running correctly.

This last point is es-

pecially im.portant if the user has had to m.ake m.any m.odifications in
c onverting the program. to run on a com.puter other than a CDC 3800 .
Although the ionospheric m.odels in the sam.ple case dem.onstrate
the use of the program., they don't give realistic absorption for the radio
waves.

The absorption in the sam.ple case is too low for two reasons.

First, although the Chapm.an layer has a realistic electron density for
the F region, it has In.uch too low an electron nensity for the D region,

where m.ost of the absorption occurs.

Second, the collision frequency

profile in the sam.ple case is designed for use with the Sen- Wyller form.ula for refractive index rather than the Appleton-Hartree form.ula used
in the sam.ple case.

Multiplying the collision frequency profile in the

sam.ple case by 2.5 gives an effective collision frequency profile for use
with the Appleton-Hartree form.ula that will give nearly the correct
absorption for HF radio waves (Davies, 1965, p. 89).
Appendix 8a.

Input Param.eter Form.s for the Sam.ple Case

Filled-out input param.eter form.s are included to describe the
sam.ple case (i. e., show what ray paths are requested for which iono spheric m.odels and what type of output is wanted).

Furtherm.ore,

com.paring them. with Appendix 8b illustrates the relationship between
the form.s and the input data cards.

161

INPUT PARAMETER FORM FOR THREE-DIMENSIONAL RAY PATHS
Name _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Project No. _ _ _ _ _ _ Date _ _ _ _ __
Ionospheric ill (3 character s)

xoi

Title (75 characters) __To
......,.s+L..JC,.....a"'s..L_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ __
Models:

Electron density
Perturbation
Magnetic field
Ordinary
Extraordinary
Collision frequency

Transmitter:

CI+QPJI
WAvE

D,foLV

_ _ _ (WI = + 1.)
_.!::......-~_ (WI = - 1.)

Ex p'f 2.

Height
Latitude
Longitude
Frequency, initial
final
step
Azimuth angle, initial
final
step
Elevation angle, initial
final
step

_ _"'0'-_ km, nautical miles, feet (W3)
40 rad, ~ km (W 4)
-lOS rad, de
km (W5)
__......
r.... MHz W7)
(W8)
(W9)
_-,*"",,5""e-rad, ~clockwise of north (WII)
(WI2)
(W13)
_-::!O'-L_ rad, e(W15)
90
(W16)
/,5"
(W17)

200

Receiver: Height
Penetrating rays:

.@ nautical miles, feet (W20)

..r (W21 = 0.)
_ _ _ (W21 = 1.)

Wanted
Not wanted

_ ....3.L-_ (W22)

Maximum number of hops
Maximum number of steps per hop

/000

Maximum allowable error per step

to-if (W42)

= 1. to integrate

Additional calculations:

Phase path
Absorption
Doppler shift
Path length
Other

Printout:
Punched cards (raysets):

(W23)

= 2. to integrate and p~int
....Z...._(W57)
_ ....:2.____ (W 58)
_ _ _ (W59)
_ _ _ (W60)

_

Every _-"S,,-_ steps of the ray trace (W71)

_1::.,/"
__ (W72 = 1.)

162

INPUT PARAMETER FORM FOR PLOTTING THE PROJECTION
OF THE RAY PATH ON A VERTICAL PLANE

Coor dinate s of the left edge of the graph:
rad

Latitude

~ north (W83)
=- - - -1../0,
'-"'-'----

knt

rad

Longitude = __--'-/~O....:.$.:....:,_ __

~ east (W84)
knt

Coordinates of the right edge of the graph:
rad

Latitude

=

Longitude =

52, 1'2-

--"---'--'----

-

g I, 'if

~ north (W85)
knt

rad

~ east (W86)
kIn

Height above the ground of the bottom of the graph = _-=0_,__ kIn (W88)
rad
Distance between tic marks = --.:.i_O_O_'_ _.,;d",e"l;g (W87)

<§9
(W81

= 1.)

163

INPUT PARAMETER FORM FOR PLOTTING THE PROJECTION
OF THE RAY PATH ON THE GROUND

Coor dinate s of the left edge of the gr a ph:
rad
L a titude

= ___4-'-"'0-'-, _ _ __

~

north (W 83)

kIn

r ad

Longitude =

-

lOS:

~ east (W84)
kIn

Coordinates of the right edge of the graph:

Latitude

rad
= __3",,-,:<,,-,-,!i ..
.:2..~_ _ Qiei,1 north (W8S)
kIn

rad
Qieg)
Longitude = _---"-_8'2..!/~,.L8L_ _ _
kIn

east (W86)

Factor to expand lateral deviation scale by =

2. 00 ,

(W82)

rad
Distance between tic marks on range scale = _-'I--'O=O-",' --_ _

~

<e::J
(W8l = 2.)

164

(W87)

INPUT PARAMETER FORM FOR SUBROUTINE CHAPX
An ionospheric electron density model consisting of a Chapman layer w i th
tilts, ripples, and gradients

r

2

= fC exp\.. Ci (l - z - e
h - h

z

h

).J

max

H
2

f

-z '\

= <0

c

h

max

(1+ A SID ( 2 T1 (e - D/B) + C (8 - D)

maxo

+ E( 8 - ~

'I Ro

2 "

iN is the plasma frequency

h is the height above the ground
Ro is the radius of the earth in km
and

e is the colatitude in radians.

Specify:
Critical frequency at the equator,

f

= __~
""-...,,
• S'
=--___...:MHz (W I OI)

Co

Height of the rnaximwn electron density at the equator,

Scale height.
Ci

H =

h

=300 km (WI02)

maxo

_-',"'2.
, =-.___ km (W I 03 )

= _ -"O
='S'
>L__ (W I 04,

0.5 for an

Ci

Chapman layer,

1. 0 for a

8 Chapman layer)
2

Amplitude of. periodic variation of f

Period of variation of l

c

w i th latitude,

with latitude,

A = _ _",Q,,, _ _ (W I 0 5)

rad
B = __-'0::0....____ deg (WIO 6)

km

c

Coefficient of linear variation of f
Tilt of the layer,

2·

c

with latitude,

E = _ _---'0::...:.. ___ rad (WI08)
deg

165

C =

0.

r ad - 1 (W I O?)

INPUT PARAMETER FORM FOR SUBROUTINE WAVE
A pertur"!:>ation to an ionospheric electron density model consisting of
a "gravity-wave" ir 'r egularity traveling from north pole to south pole

6.

= 6 exp - [(R - Ro - zo)/H]2
cos 2rr [t' + (rr/2 - 8) ~xo

+ (R - Ro)1 A, ]

aN __~rr Vx N 6 exp _ [(R - Ro _ zo)/H]2
o
at
x
sin 2rr [t' + (n/2 - 6) ~: + (R - Ro)/Az ]

Ro is the radius of the earth.

R,

e, cp are the spherical (earth-centered) polar coordinates
(6. is independent of co ).

No (R, 6, co) is any electron density model.
Specify:
the height of maximum wa ve amplitude, Zo = 250. km (Wl5l)
wave-amplitude "scale height," H = /00.
wave perturbation amplitude, 6 =

0.1.

km (W152)

[0. to 1.J (W153)

horizontal trace velocity, Vx =
km/sec (W154)
(needed only if Doppler shift is calculated)
horizontal wa velength, Ax = 100. km (W155)
vertical wa velength,

}~%

=

100. km

. .In \vave perlO
. d 5, t' =
tlme

166

0.

(W156)

[0. to 1. J (W157)

INPUf PARAMETER FORM FOR SUBROUfINE DIPOLY
An ionospheric lTIodel of the earth I S magnetic field consisting of an earth
centered dipole
The gyrofrequency is given by:
1

fH = fHo ( R;:h) (1 + 3 cos

2

>-)'

The magnetic dip angle, I, is given by

tan I = 2 cot

>-

h is the height above the ground
Ro is the radius of the earth

A is the geomagnetic colatitude

Specify:
the gyrofrequency at the equator on the ground, fHo = ---,0"",-,-,8,,-__ MHz (W20i)
the geographic coordinates of the north magnetic pole
radians
latitude
= _ ...7",8","",5'",-_ (!egr e!]> north (W24)

long itude

L'. .,,--_

= _2b...
Q

radians
([egre§> east (W25)

167

INPUT PARAMETER FOR M FOR SUBROUTINE EXPZ 2

An io'"1ospheric collision frequcncy model con,sisting of a double
c'<po!1cntial profile

where h

is thc height above the ground.

Specify for the first exponential:

3. "5 x/O ¢

Collision frequency at he i ght h1' \1 1 =

p,~r

Reference height,

h1

collis ions

second (W251)

=_ . .I'-'O"'-"O<-___km (W252)

Expoc,ential dec r ease of

\I

with height,

a1 =

(J.IJf8

km - 1 (W253)

Specify for th-~ second exponential:

Collision freq'~ency at height h2 , \1 2 = __....,_3'-O'""----:---:-:-=-::-c:--_collisions
p'~r second (W254)

Reference h 'oight,

h 2 = _LI_If'-"'O"-___km (W255)

Exponential decrease of

\I

with he i ght, a2

1 68

= D.o/83

km -1 (W256)

Appendix Sb .
XOI
1
1
3
4

5
7
9

11
13
15,
16
17
20
22

TEST CASE
O.
- 1.

O.
40.
- 105.
6.0

o.

45.0

1

O.
90.0
15.0
200.

1
1
1

o.

3.

57

2.

58
71

2.
5.0

72

1.
1.
40.0
-105.
52.12
-81.8

81
83

84
85
86

87
101
102
103
104
150

1

1

1
1
I

1

100.0
6.5
300.0
62.
0.5

1

1.
250.
152 100.

Listing of I nput Cards for t h e Sample Case

OF DUPLICATE W CARDS, THE LAST ONE DOMINATES
EXTRAORDINARY RAY
TRANSMITTER HEIGHT. KM
TRANSMITTER LATITUDE. DEG NORTH
TRANSMITTER LONGITUDE. DEG EAST
INITIAL FREQUENCY, MC/S
DONT STEP FREQUENCY
INITIAL AZIMUTH ANGLE, DEGS CLOCKWISE FROM NORTH POLE
DONT STEP AZIMUTH ANGLE
INITIAL ELEVATION ANGLE, DEG
FINAL ELEVATION ANGLE, DEG
STEP IN ELEVATION ANGLE. DEG
RECEIVER HEIGHT ABOVE THE EARTH, KM
NUMBER OF HOPS
INTEGRATE AND PRINT PHASE PATH
INTEGRATE AND PRINT ABSORPTION
NUMBER OF STEPS FOR EACH PRINTING
PUNCH RAYSETS
PLOT PROJECTION OF RAY PATH ON A VERTICAL PLANE
LEFT LATITUDE OF PLOT, OEG
LEFT LONGITUDE OF PLOT. DEG
RIGHT LATITuDE OF PLOT. DEG
RIGHT LONGITUDE OF PLOT, DEG
DISTANCE BETWEEN TIC MARKS. KM
CRITICAL FREQUENCY, MC/S
HMAX, KM
SCALE HEIGHT, KM
ALPHA CHAPMAN LAyER
CALL PERTURBATION SUBROUTINE

151

zo,

153
155
156
201

SH, SCALE HEIGHT, KM
DELTA
LAMBDAX, HORIZONTAL WAVELENGTH, KM
LAMBDAZ, VERTICAL WAVELENGTH, KM
GYROFREQUENCY ON THE GROUND AT THE EQUATOR. MHZ
ACCEPTED STANDARD LAT. OF NORTH MAGNETIC PO LE. DEG NORTH

0 .1
100.
100.

24

0.8
78.5

25
251
252
253

291.
3.65
100.0
.148

254

30.

255
256

140.
.0183

XOI
71

TEST CASE

72
81
82

o.
o.

2.
10.0

1
1

E4

KM

ACCEPTED STANDARD LONG. OF NORTH MAGNETIC POLE, OEG EAST

COLLISION FREQUENCY AT HI. ISEC
HI, REFERENCE HEIGHT, KM
AI, EXPONENTIAL DECREASE OF NU WITH HEIGHT, /KM
COLLIsION FREQUENCY AT H2. ISEC
HZ, REFERENCE HEIGHT, KM
A2, EXPONENTIAL DECREASE OF NU WITH HEIGHT. IKM
(A BLANK IN COL. 1- 3 ENDS THE CURRENT W ARRAY)
NO PERIODIC PRINTOUT
DO NOT PUNCH RAYSETS
PLOT PROJECTION OF RAY PATH ON THE GROUND
LATERAL DEVIATION EXPANSION FACTOR
(A BLANK IN COL . 1- 3 ENDS THE CURRENT W ARRAY)

Col. 1 - 3
Identification number
Col. 4-17
Data in E14. 6 format
Col. 18
A 1 indicates an angle in degrees
Col. 19
A 1 indicates a central earth angle in kilometers
Col. 20
A 1 indicates a distance in nautical miles
Col. 21
A 1 indicates a distance in feet
Col. 22-24
Left for other cO!lve-rsions
Col. 25-80
Description 0: the data

169

)(01

I[SI

CHAn:

CA~f.

INITIAL VALU ES

,
1

,HP.JL'f

WAH
ro~

TH E

r )(Pl Z

w ~~~~'f --

APPLETON - HAkTREE
kLL

~NGL ~S

IN

~AUIA~S .

ONL'f

~ONZERO

VALUES

FO~HULA

11/ 05/71.
rlCTRAOROlNAR'f WITll COLLISIONS

P~ I NTEO

-1 .00000UOO~OJ*UOO
b.J7~O~O~~~GG~ti0 3

•5 Eo .

~<HJ 1 700o0 J-OOl

-1. 6jZ5357 14 &u9~OO

7

b.OOuOOO~OOOO ' OOO

11

7.8,3~o l oJ3~0 - ~0 1

10

1. :j 7 OHI) 32679*0 00

17

2.6 17 q~3077ql - u& 1

"zz 2.0JOOOOOOOOOt002
1.00 00&000000 +003
10083kQZ80+000
""" 5I .J. 0189061ZJ31
9 uOO
9
3.00 00~COOOOO+COO

.
.,
...,"
"

>-'

""o

.7

3.DDJOJ&uOOOO &OO
1 • .JOOOOOJOOOO - OOk
5.00000000000900 1
1.000000 00000 *000

(l)

P
P.

. ..
:><:

00
()

1.0U OOuOOO~00 t D02

I.J OOOJOOOOOO - uOo
5.0DODJOOOaOJ-O OI
2.o0Dooaooooo ~ ooo

""71 2.00000000000 90 00
".. b . 9613 1 70080.. 60J-t 001
OOO
1 2/o - 001
"86 -1:;t.0'l007000
... Z7b7'1JZb lJtOOO
" o3.00000000000+002
. 5JOOOCJOOOO t OOO
101
7Z

~
'0
'0

(J)

\11

S

5.0000~OOOOOO + OOO

'0

1 .00000100000 t O~0

(l)

>-'

t. O~OCo~uOO~Ot~OO

8l
~

-1 .~32 59S 71

1.55'16 5~ 71 Z 73-u02

10'
103
10.

D.l~999999~9S + 00 1

:; . 00000 0 00000-001

150

1 .i)Ji)CJJJGOJ~.COij

1 51
1"
1"

Z. 5000JOOOOJO +002

IS'
1"

'01

1 .00000JOO300.0~Z

1.00000 000000 - 00 1
1.i)0 00000OOOO t C02
1 .0000JOOOOOJ +ODZ
! . o~~a~OJCi)i)O - JOl

'51

l.D 5UOJOODQ02 +ilC~

'"
'"

J . OaOO.JOilOOOa t OO l

'52 1. 0300JOOOJOJ+JJ2
"3 1 . .. d OOOOilOOOl - llOl
256

1. lJ~ o;~Hq H~ . OO2

1. 6J.uJJOJ~J~ - JCZ

'1:l

"....
g.
o

g.

•

:;:;:;:;:; ~:! ~ ~ ~ .: ~ ~ ~

o

6:e :: ; !: ~ ~ ~ ~ ~ ~ ~ ~:;::;: :;:

o o o o o Q g O O O Oo _ _ _ _ _ _ NNNNNNNNNMMM

~

~=c c cococoOoooo ooOoOcOcoccooOooc

<1<0
~

' • •• •• •• • ••• • • • • • • • •• ••• •• • • • •
oooOcOoOOCOOgoocoOCOOOOOOOCO -Q

~ ~~~~~* ~~~~ !: : ~~~:~ ~~ ~~~~ ~ ~~ ~~~:
~

O~~~~~~~M

_ ~~

~~

~~~ ~~~~~jjjj_jOO

.... '" .. .. . ..... . .... , ... . . . . . _._.... .
EO NNNNNNN

~

_ ~~ O~~ ~~O~~~N~~~~~~

OMNNNCCCC~~~~N~~

4

N

r

CC~~O_NNMjj
______ _

~

r

~_~jN

oC~

M'

___

j

N

~

~MMMMMMMMMMM NNNNNNNN~ ~~~~~~~~_
O~~~~~~~~~~~NNNNNNNNNOOOOOOOOM

~

O~~~~~~~~~~~OOOOOOOO~~~~~~~~~j
~NNNNNNNNNNN~~~~~

•

••••

••

~

••

CCN~~

~

~

~

•

•

______ O
••••• "
•
___ C

~~
~N NN~ ~~~~~~~#
~~~~O
_ ~~~~~~~~~~~ON~~
~ ~OO _ N~~

COO

~g~~

•

j~~

~
~

~

•

~

• • •
N __

~

••••
__

~~

o

~"'oMNNNCCCC

w

j ~C

~C~~

~

0..:1:
0

MM~MCN~

OCjONjC~jjjOj

~~~~~
CON~~~~OO_NMM
______
NNNMMM j j j j j j

•

•

~~~~Oj_MM

~~~~~gg~~~

_~~

~

__________

0
0
0
0

,
"

~

0

~
::O$~

:l:O U ....

... _

O?

i:-'

~

>
~

C
0

,

0

"

,
•

>.

..
--.
w
Z. >

_Z_

",,,,
"

r<

."'..,,~
o w

>

L

0

- -

>

no

.

~

171

Z .... :::

e ;;~
o.

.. .
..
>
_ w
~

'"

.>

0

Z

z

z

o

goaO~~~~~~~~~~~~~O~~~4~~4~~~ ~
oooooo_~~~~~ ~~~ _~~~~~~~~_N~4 ~
c
o o o o o o c O O = = = = = _ _ _ _ _ _ _ _ _ NNNNN

~

~mo==o=oo=ooooooooooooooooooooo

a: c

o

•• • • • • • • • • • • • • • • • • • • • • • • •••••

0000 000 000000000 0000000 0

000 0

0

~

~
,~

.z

z

·;

,0

OOOOO=~4~M

~

u

0

_ ~~O~~~~3_4~_

----------

___________ 00000000 4

_______ ~

J:

•

•••••••••

•••••

••••••••••••••

o

~

~ NN"'MM ~ ~~~~~~~~~~~ ~ N ~~~ ~~~~~

~

0

~~~~~-~--~

O~~M~~NO N~O ~~_NM~N~~Q~~N_~~_N

0

Z~O~~~"_""~~~M~~~~ ~ ~~MQ~a~NN~~~

0

... l:

•

'"

",'

0

~

z

z

w

0

••
z,

~

~

z
~

e •."
~

;• "0

40

M.~~Q"M

•

~~"M

0

z

N

~~Q~~_~~~~~~~~MM~~~~~~"'Q~MM~ ~ ~~
~"'~~"'~M ~ ~~M~ ~~ ~M ~ ~O~~~~~M~ ~ ~

u
w

0

~

~4N

o44444444J34~~~~~~~~~ooooooo_
=
___________ OOOCOOOO _ MMMMMMM4

··• ,
"w

N

_N NN MM4~~~~~~~~OO~ON44~~~Oo~

Q..

0

~

~

O O O O O O O O O O O O N N N N N NNNMO OOOOOOO

•~
w

444~~~_M

M~O~~~

~N40N~M_~~NMMMM

>

~

NNO~40NN~

~~O

O_N_~~4~N~OOO_NNNO~_Me

X

~

0

~

~

~

z

O~

044444M04~M_~~~~00004~~~~

~O

-~
-~
0

•z

O~~~4_~

__
_ _ ~~
___
__
ILl:.: • • • • • • • • • • • • • • • • • • • • • • • • • • • • •
~
U~
_ _ ~~~~~4 _ ~NN~~ M MM~~ ~_ 0000 4 N
~

o ~

,

O ____

~

~-

•

•

N

u
w

•

O

•

_

•

...
•

~~

.

• _
• _
• _•

~

•

___
• _
• _
• _
• _
• _• _•
"O

O~

~"

_M

•

•

N

O

•

•

NNNM

~

~

• •

•

•

•

.. , ,

~M_

~~M ~~ ~~~~=~= o ~ o~=~ ~~ N~~===o ~ ~

4~=_N ~~~

o

•

~O~~N

''';'

~

.... OQ==OOOOQOCC~cc==COOOO

~~O_MNMM~COC OCO OOOC=OCOMMOOOOOO

f~~~~ ;~~~~~~
~~~ ~~ ~~~~~~, ~~
, ,
, , ~~~~~~
,

,

.,o
o
e
o
o

•

_- "' .... '" , , , , , , , , , , ,

~~~

,,,

u

w

•

OMM~~"'~"'~N~~OOO"' ~N .~ ~~O ~ ~NMNO
~
O~C~~~ ~ NO _ ~~OON"'O~~M"'~O~MM~~O~
Z4~OD~O ~~" ~~~DMO~~~~~"N~M~~_. " I~O
~

--

.

0<..1 . . . . . . . . . . . . . . . . .

.

.

.

.... .

....... N

, --- --- ,,--, , --, , --

... OO~~~~~~~~~M~_OOO"' ~ ~~~.~~~~"'_"'O

~ ~
>

.... ----~--

OOOOOOO_~~~~~ . N"'MNM"''''NMO~~~~
oooooO~.~_~~ ~
OO OO

OO~G~C

_

~

~~~

~~~~I_~~ ~~ ~

~~~~GO~~.

__ ___ _________
••

w
~
u

~~"'~~~ .~

z

OC

_ _

••••••••••••••••••••••

NG~~~~~

•

••

•

•

· 0

"""",,~
M NNN~~Mo _
~~~MNNNNNO

:;
0

z

•

z

OOOO_NN~"'II

OOOOOO O_O~ "'~

~

~~.NO

oooonooooo ____

ze u

•

:Z:OU ...

~MO

OG~

~ ~~ MMMNNN N

o

_ _ M"'_
..

_" NNO~ ~

ooo~cooococoNo

•••••••••••••••

•

•••••••

•

••• J

...... 0 0

OOOOOOOOOOOOoooooooooonooooo~

O .~

,

Z.

•

'

"

,

,

,

,

<:> o
., o
." o
<:>o
'='oL.oc:>O
0
...... _ '. ..., ~ " ' ... M
o
O
o ____

,

,

,

,

,

,

"

~ J' "- ... oJ' J ' N

'" N

'"

U

J

(t' ..,

....

NMMM~~~~~~~~~'"

~~~~~~~~~~~~~~~~~~ ~~ ~~~~~~~~:

~?~~~?~~~~~oer n ~c~~o~e~nOQ~~~

OI~~NC~~ M~_M' . tNO~.C~ ~

<:>

w

~
~

r

;~N

Z

~'~~N~n~~

' N~oQ" ~"' '''M'''''' <:1' _ q>M'''~O , D _I..zN ''''Q

OCN~ON<:1'~. · DC~OON~OO~~N .t~ ~~O~N
oO~~ _~~N N~~O _~~<:1' ~~.~<:1'CC _ ~O~N~

•••••••••••••••••••••••••••••

d~O~ _ ON~~,~..z ~ ~~ Z~ ~O~O~N~~"'~~N~·O
~
~ _ ~~~ ..z~ ~N ' D~QOO~~WMM_oe~ ~ N~~N

... "''''''' '''..., :y, ." ..' '" -..> , L .., ... . .... ~ :: ::: ~~ ~::::::::~:

X

ONQ"'NO~N~ _ N~NN~~ ~~ ~MO~4NN""~

~ ~

~,~

"'

_

~_~~~

o~~N~e

_

~

<:1'~

_

o

~_

~

~M

"'~NO"'~Moe_o"'

__
____

, ~~

~

_t~

~~""~~

~_

___

·D
~

...w ............................ .
~

r

o

~~

~~

~_~I

~

O~~·~<:1'_I.

X

~

__

o~o

~~

~NNNN"'O~

m~<:1'_O~

_~~~..z

. ~~~~~ON~~D~ ~~ ~·~~o~ ..z

------~-----

z
~

--~
an

'W
=oooo~

~

~~~.n~

oo~c

_

OoQ

OOoOOo o

o

.......

,

oooooo~

,

,

•

,

,

,

__
__

oooo

~oooo~oo

,

,

,

,

z
z

W<.!)I .oJ

o~'~~ln~o

"

0

· o~

~~~
r:z:,.

r z

~

----- -

_z.
, .z

'"

.~

~:Y~~o

':>:...00

VI '" ILl

.-

N~~

~"'_ ~ ~ · D~~

'".
- <>: -

-. >

_

,

,

,

,

__

~~

~o_~~

. nl~.o

O~oon

~

noo~ooooo

,

•

,

,

I

,

,

,

...

OOOO~ ~ N _"' ~_~"'MN"'M~MMOMM<:1'_~_~O
•
,.
"
"
,.,"
"
I
,
,
,
,
,

172

,

~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_ _ _ NNNNN

8
~

QOCCOCCOCQOOOOO~_~_~

~~oooooooooococccoccocoococooc

a: 0
o

~

••••••••••••••••••••••••••••

occoocooocooccccccooooaooooc

~

•

~

=~~~~~_~~o~~~~~~c~~~~~~~ ~~~o

4

O~~~~~~~N~~~

~

___

~O~~~~~~~N~C~

C~~~~~~N~==C~~~N=~~~~~~~

_ _ ~O

~O~~~~~~~_=~O~~~~~~~~~OO~_4~_

,,,\0< . . . . . . • • • • . . . . . . • . . • • • . . • . . •
~

•

••••••••

c~~~~~~~~~~~
o~~~~~~~
OOOOOOOOOOOONNNN~NNN~~~~~~~M
a~~~~~~~~~~~~~~~~~~~ONNNNNN~

•

>

~

~

-----C

O

~

=

~

C_N~~O.~N~~OOC~.NONNM_~~~N.
_ _ _ _ _ NNNMMM • • • •
__ N N
~

•Z

~

O ~ ~~MM~~~~OOCOM~8~ ~ONM.M ~_Na
~

~

O~~~~~~~~~~~~~~~~~~~DM~~MMMO

•z

Q. Z;

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

~~O.~~MM~~~~~~~~~ • • • • ONM

•

•

•

•

•

O_N~~C.ON~ONNN_~~~~~O~.O.O_

~

~~_~~ NNN~~4444~~~~~~~O_NNN~

~

~~----

__________ ____
___ __
.
, ,,,,

o
o

•

• • OOO N

o

C~N4~NN~~~

__

OO~~~CN~o~~_~~e_

Z~O~~~O~~~~~~_~~~_~~~_ON~~N~O~

04cN~~~~~~~~~~~~
~~
~
. ~_O
~
UOOON~~~~_~
~
~~_N~_

~

..... z:

~
~

"W

•••••••

•••••

,

•

••••••

•

,, ,

••

•

••••

,,

ON~o~~oco~ccoeceC~~~~~Neo~ce

"~e~~

o

•

__

ccooooooooeOO~~O~OOOOOo

~"O~N_ooooooeooooUOCCOONOOOOOO

0'-' • • • • • • • • • • •

••

•••••••••••••••

~~OOooo~OOOOOOOOOoo~oooon~o~~o

' "

,

,

•

"

,

,

,

,

,

I

,

,

,

,

~
O~~O~~O~~~~NOO~~_~o~~~_~~~~o
~

OCNo~~o~~~~~oO~_~

_

~

O~~~~~~_~cN

Z,,~o=~o_~~~o~~~oO~~~~~~_n ' ~o~~~o,

00..1 ....
_

........................
____

OOooo

~~

~

•

• • '"

=

'NNNNNNNN~NN

,

....

•

~~~~oo_~~~~~~~~o",o~o.

M~M~~M~~~N_

~

,

1

,

' "

oooooo~~~~~~e~~~ ~~~~~ ~~~~~ _

~~

OO~COO~~~CO~~ ~ ~~~~O~O~'~~~~

.... ~ ~
z: W

oocooO~~~~~MM_~~ON'N_~~M~~~~

•••

~o

•

••••••••••••••••••••

•

•• 0

ouooOO~~~~~~~~~N~N_~O_~~~~~O

,

~M~M~~NN NNNNNN ~_

,

~

a

oooooO _ ~~~~~~~~_~~~~=4~~NN' _

"

~oOOOOOO~N'

,.~

N

<

,

o

..,-"

__

~~N~O~'O~~N~O

~

_

~~~~~~~~~~~~~ ~~ ~ ~~;;;~~~~~~~

z:o u w

~_oo

oooo~OOOOOOOOOOOOOOOOUOOOOO~

1

,

C

O V <' U CU~_~~ M MO~U~~~~~

,

"

.,

,

OOOOOCOU _ _

I

,

NNNN~~~

,

~

,

,

,

,

,

U O

"

<.)

_ ~

~O~~~OO

"

.• U
__

~

~~~~~~~~~~~~~~~~~~;~~~~~ ~ \ ~ =
"'"
, 0,

0"'"
I • c,

0,

C'

,

c>
I ""
, 0,

....,..,"'"
, , , 0,

c> 0

e

C

Q

0

Q

. ,

Q

0

"" "" c

O O~~ _ _
~'~~Me~ee
~ O~ ~ O_ON"'TO~~N!
__
O

W

_

N~~

oo",

~

~

Ouo_

uu

",e~~'~~~~~~M

~~~eNo~O"O~

_

N~"'oM~N

__

O

~

~N

U~ · O_'M~~_~MN~~_"'~~ ~ ~"'M_N~O~~

z't
"~

•

••••••

O~ N

•

••••••••••••••••••••

_ _ ~ ~ _~~O N ,~

e"' M_O'MO Q~ _ ~

~~

~O_M~~_'~_T ~ ~ ~N ~ "' M~MMn~ N~C O

Q

_____

O~

N

N~

M~N .

~_~~~~ON~~

M~44

__

~~

.~~

r·

~

~~

~

:

~~O_~~O_~~O~

N

~

- . . .... . . ... .. .. . . .......... .
O~~'~~ ~ \ ~~_~"'~T ~ ~ ~ · O _ ~",,~~o~ ·ft ~_
o~~_O~~~~~M~~",o~~~c~o~~~ ~ ~~N

X

~z:C~ft~~~MMN~OM ~~ ' N

....
z:

'""

~

O

O~~~O~O~~OO~

____
~ . ~~~~:~~~!:==~~~~~~

N

C~

~~~~~~'

N~ln

,

~_
- W
>

,,

0

-- ~

==;;

;!!
~~

W

r.r:>:

~~~NNN~

~

~~

~ ~ ~!~~!

",
-.o w ·.::t

~

_

,

0

O ~

_z ...

x"(""!"

~

W~W

_ ~ _ OO~~~~I~~~DOO"'~~~ I ~_O~ ~ ~ ~

~O

_~_O_oOOOOOOD~_OOOOO_o~OOOOO

.. , " " " . , " , , .

OOOoOooooOOOO~OOOOOOoo~OoOOO

, . , . ," _ _" " ,

~OMCNN

,

'"

~NN

I

_

,

173

OO~'NNNN~O~N

,

_

N~O

","

'"

TEST CASE

CHIl.~)(

w~"E

OIPOlY

b.COQJ~G

FI<EaU[ ,' j(.Y

ELEVATr~~

0"000

XHTR

0.000 OUR 101\'
]-011
0+ I) oa

-

-J

"'"

-j-JOq
-lo-\I J8
-1- 0Jl
5-0J~

-2-005
&-Jil5
-3-iI11
2 - 00"
2-il06
3 - 00:'
_3- ~,)7
J-011
1-005
4-00&
&- ilO"
6-0iH.
6-~0"

RCVR
AP OGEE
IojAVE REV

HE r;:;H1

°A .~GE

'"

!<M

O.OOH:
52 . '315'1
oZ . 24·}Q
69 , J"2(:
i6.1331
"9.47 .. 3
113.d433
142.55of:
I1J.I0H
133 . 2703
200 .i1000
209.011 .. 3
20'1.68J ..
20~.4300

2u5 d&lS
RCVR

EXIT 10,",
O+JOO GR.NO REf
0 + 000 E~ T K ION
-&-007
-6-007
- .. -006
7-005
-3- Hl RCV~

2G~.OliOO

172 . 6329
117.8':> 20
119 . 5472
3d . "02!)
30.3021:
0 . 0000

52.'3177
l1(1. 1 (i6~
13 d .4~ 'JI

165.6750
I dOl . 5Qj':i
2~O.OOJ':

APfLETml-HART~EE

fXPlZ
MHZ .

tZIMUTH ANGLE OF

ANGL~

OF TRANSHISSION =

AlPW T>i
!lEVIA TI ON
XHT P.
LOCAL
OEf,
OEG

FO :~HlJlA

T~ANSHI SS ION

EXTR:AORDINA iH

11/0517'0
WITH COLLISIONS

4s.000nOD DEG

1t5.DOOOOO DEG

ELEYATION
LOCAL

XH T ~

POLARIZATION

GROUP PATH

OEG

REAL

tMAG

45 . 000
1+5 ... 71
45.552
.. 5.bI4
.. 5 .7 51
45.d73
45. H6
.. 5.d57
.. 3.266
J4.o7J
26 ... 80
4.180
3.110
-0.26&
-12.692
-23."56
-41.316
- .. 50154
- 44"'127
-4 .. ... 72
- .. 4 ... 72
4 4.11 ..
44.599
1,5 .1 03
.. 5 . 0':15

-0,000
-0.113

1.000
1.1 00

,*5.000
- 0.0 aD
-O.O5~
0.000
.. 5.000
-0.021
-0. 000
-0.002
"5.000
- O. JCC
-,). J aoj
-0.000
'l7 . 2010
.. 5.000
110. II8£; ~
-I). 'l 0 C
- 0.000
45.000
- 0 .000
- 0.002
-') . 000
0.003
.. lo.'J80
1311.045"
1&,,0762&
-~. il g
- 0.10&
.. 4.789
-0.001
.. lo.1i1 ..
-J.OOJ
130.6257
- J .'~71
0 . 369
-Jo1]2
II. &07
.. 3.622
- iJ . OO~
700.2014
-0 . J 6 Q
233 .25<;9
-1. 590
40.lo 3&
0.000
.. 0.109
- 0 . J .. c -1.7 .. &
O. OOJ
23~ . 8629
i). 0 Oil
24 1. 0~b9
(I . ~21
-1. 9i12
J9'''3 1
36.11 19
,.; . 24"
-2. 00 1
0 . 000
259.5H9
-1 .4 1 5
34.427
J . oo~
774.371:18
J. HS
21.233
0.00 ]
111.8136
'J . S 47
-0.183
3&'; .;' 6liO
J. '> &~ -0.033
1&.021
~.OOJ
J. 00]
J. <; 7 ~
-0. OH
10.932
394 . 264'3
2 . 976
444.9524
il.004
'J . " 74 - 0 . 027
_ .. 4 . 952<0
-0.027
2 . '178
0 . :; 7 ~
il . OO ..
-o.o~]
<'81, .7 ilbO
J.57&
- 0.025
- 2.t ~ 0
- 0.J22
-'J. 105
3311 .6621
O . ~ltl
3.168
-0.020
-~.oo~
<;,15 .3 574
O, "!H
7.7as
-0.000
~ .5111
9.566
t:Z2 . ':IrJ<;
- 0.01&
-J.OOO
tSn .166'l
0.5 7~ - 0.0001
11.1 '39 "2.~69
(,7& . 0632
0.057
12.376 35 . 811
-0.001
0 . '.>72
12.71',9
- O.OOil
';H .5163
'J . '-''of
0 . 796
2&.'153
Trl IS ~Af CALCULATION TOOK
10.310 SEC

1 .207
1.219

87.6128
':IT.blza

1.217
1.213
1. 209
1.20'l
1.2&0
1 .€:H
2.2'l3
-1. <;76
-1.631
-1. 623
-1.266
-1 .142
-1.041
-1.031
-1.G32
-1. 000
-1. GOO
1. 000
1. C'34
1.1"6
1.19 ..
1.230
1. 434
20159

11':I.b128
139.&126
159.&128
1 'l'J.&126
239.0128
279.b126
295.1649
3 10 601&109
35201649
360.1649
366.1649
4 1 0.6543
4&7.d543
547.8543
587 . 6543
659.8543
&59 . 65 .. 3
715 . 5&2&
791.33CJ2
672.3392
'31203]':12
952.3392
99203392
1015.6617

DE;';

Q.OO OO

52 . 32"0
&1 . 3530

-0. ; 0 ~
- J.~on

&~ . 2802

O. ~ 0 0

d3.it&S'1

- O . 1(j~

- 0.000

45 . 000

'"0.0000
74.&126

PHASE

PA TH

'"

0.0000
74.6128

87.b 126
':17.6 126
119. &126
UCJ.6125
1 59.60 cl1
1 'l'J .10 233
231 . 3102
2&8.91018
278.4396
JO Io. 3962
30603131
3 1 0 .1 892
32 ... 3tH
336 . 837Z
317. &491
454 . 52 1 2
.. 94 . 513 1
566.5130
566.5130
&22.2214
&97.9960
77e.9960
616 . 81 7 ..
857.2445
690.3307
905.3752

ABSORPT ION

DB
0.0000

0.0000
0.0000

o.aooo
0.0001
0.00010
0.0009
0.0021
0 .0 030
0.00106
0.0056
0.0095
0.00CJ8
0.0103
0.0122
O. 0 137
o.01&CJ
0.0 193
~. 0204
0.0206
0.020&
0.0206
0.Ol06
0.02 14
O. liZ26
0.02 36
0 . 02 5 2
0.02&6

z
~

~~~~:~:~~~~!!~:~~:~~~~~~;~~

~

QoOOOOOOOOO~""_"NNNNNNNNNNN

~moCoOOCCOoCOOCOOCOOOOOOCOOOo
~

<:I

o

•••••••••••••••••••••••••••
OOOOOOOooQOOOOOOOOOO OOOOOOO

~

~

.

.~

z

z
,0

~
~

.~
g~

O~~~C40~~M~_"~~~"04~~~~~~MC
OOOOOON~N~~~~N~~Q'~NNN~~4~MO

~

o~~

~~~C~MM~~~~O

"M

_ _ _ NN NNN OC

rOOOOoOO~~~~NNOCM"~~~NCCC4NO

,~

~~

W >l

"~

~
~
~

0

u

••••

••••••••••

•••

•

•

••••••••

O"~cccC~~~cMM~~MO~hMNcNMMC"
~~h~"Mh_N4~~~~h "~~ ~OM404h~
_"_N NNNNNNNMMM44~~~~~~

z

•

z

~

C

OOOOOOOOO~~~~~~NNNNNMhhhhh_

>

~

O~~~~~~~~~~~~~~NNNNNMMMMMMO
OOOOOOOOONNNNNN
__
__

0..

z: • • • • • • • • • • • • • • • • • • • • • • • • • • •

>

·

z

z

0

~

0

•
~
>

OOOOOOOOONNNNNN~~~~~O~~~~~M

~

~

'MMMMM~

~>lO _ ~OOOOOO~~4 40 0~NNN~~~~~~~~
C
~~~~~~~~~~NN~~~~~~~~~~~~~~

=
o

u

w

0
0
0
0

~~~NNN~~~ ~~33~~~~~~ ~ ~~

~ ... _ _ _ _ _
___
__
__
_ _ ~NN _ _ _ _ _ _ _ _ _ _ _ _ _ ~
C~N~~~c~ec~NN~c~~~~cc~ec

__

~

Z~O~~CCOD D~ ~~CC~~N_ ~~ CON~~~~~

u

U4~Ou~

·- ••

~

N~Oc_ooOOOC~~COOC~

... :a:: • • • • • • • • • • • • • • • • • • • • • • • • • • •
~

I

I

••

I

••

,

,

0

z

~

~

0

"

~~O~~_oooOOOOccOOOCCCCONNOCOO
~4 00QODOOOOCOOOODOOOCOCOOOCOO

C 1,01

U

z
0

~

~

~

·
••·

••••

•

••••••

••

••

••

••••••••

••

~=OO~OOOOOOOOOOOOOOOOOOOOOOO~

•••

!z •~
o
z ;• •
~
w

~~I~N _~c cc~Ooco~o~~~oo.~ ~oo o

~

>

I

I

I

I

I

I

I

I

I

I

I

t

I

I

I

~
cN~e~NN~O~G~~~~~~_~_O~_~~C~

~

~

O~C~~N~~~~~~~NN~ _ Oe_N~ _~~ O~~

~~~ON~~~~~_~~~~~~N~r~~~~~~~~~~O

0<..)1,01

•

•••••

•••••••••••••••

' , '

•

•

•• 0

"'CQOOOOCOOO~O~~~~ON~~~~~~~~~~M.
.O~~~QD~~~~N I
'M ~Q.~~~~.~~.'O.G

~~
;!

, , , ,

I

I

,

COOOO~~~~_NNe~~OO~_~~~~~~N

"0

~COOO~~~N~~~N~~~

_ _ ~~~ _~_ Me

oCCOC~~ · OM~GGO.~~N~ ~CNo~~ ~~V

• • • • • • • • • • • • • • • • •• • •• • • • • • a

w
~

OOOOc~~~~~~~~~ee~~~

_ o_o~~oo

0

·oo.

I

~
z

, O'O~~~'~'~I~'~~r~MN

_

__

NNNM~

z

OOOOOO~G

~

~4~

0

=

~o uw

~~ oo

N
<

0 >"

_~NN~

~~~~~~M_~~

__

o

~'"

OOOOOOO~~~OON~~~O~~ON~ ~ OM~~
OOOOOOOOG~~~.O~~G~~OC.O.N~4

....... .... ............ . ..

OOCOOOOOQ~~~~

I

,

,

,

,

.,'

~

•
__
__
c~e~
_•
_•
_ ~~MMN
______
<..)

z<

.
~

QOO~WQ~~~~I~NO~M\~~ ·, _~h~~~a~U
~

ooooCO~~~~~N_G~o

_l

o~~MI

__

~~~ ~' :~~ ~ ~ ~~~'~~~~~~~~~~~!~~=
__
,

oooonooOO"~OO

•

,

,

•

,

•

,

,

,

,

,

,

M~~C~~~~_~O~

,

,

,

I

•

I

,

•

,

,

••

._

_~

__

g

~

·

0

N

~

C

t

..
.,

O~~~O~~.~N.oorO~~.NO~N~~

-

~M~~~O~M~O~~M_OM

"

W
0
0

__

!,oj

O~N~~_~~

w

~

CNN~~_~UN~~.~~O_~~O~~O~~NO~

.'

~yc,~~~~~~,O~.~

7'1:
~

•••••

~~~~~~~~~~_~N~~~_

•••••••••••••••••

~~NOt~~NU~NNN~~~~~~_g~~

O~N~MM~~40Q~~_~O~NN~CG~

M~

__

~O

-

•••••••••

~
~

y

••

••

••

•

•

••••

••

•

•••

~N~~~~~I~O~~~_.O~~~OCN~~_~C
~~~~c_~~~NNNNOC~ _~ N
~~ _ ~~~

_ _ _ _ NNNNNNN _ _

"

_ __ N

Z" Z

<

~ Z

~.

~

>

~~

•

~U

__

_ ~~~ _ O.G~~NO~~N'O~~~N~C

~

>

••

O~~~.~~N~'~o~.~~no~~~~~~~~~oo

X

w
Ow

•<
.Z

•

~rn~~~

0

~ X

••

• • ~~~~~N~gQ_ ~ ~~M
._ _ _ •
_•
__
_ _ _ _ NNNNNNNn~
~~.~~ _ M~~.~~C_

Mn~~~~~c_~

.>

•

z

_I O~_~~~~N_

>

>
U

- •·
>

..

Z
u

CU~
~

U"

>

u

O~OQ~~

~

..

.z

~ ~

~

> 0.
z >

~

"ow

.,>

0>

~

U

~~%

~~~~314~o~~~,~c

Oooooo~ooaoooaOOO~"OO

~

_ _ ,n.n~g
__
CC~o

o~~Oaa~aOoOOcOOOoO~~OooOoOO

..............
aoaO~

,

•

I

....

_1140~

I.

,

,

175

,

I

•

,

,

"

___

,
M

....
O

I

_4

"

,

....

,

,

,

,

,

...

NNO~~M.t~

,

I

'"

,

<0,

WAvE

il iF OLY
n~O U ('lt y

E: ){PZZ
6 . COO~OO

F LEV~TIJN

tiE I GH r
Oi 000 )(HT R
uiODa [NTR l Ot- J - 0 11
-3-011
-2-0011
-1-~07

....
....,

a-

1110517r.
APP LET ON-HAr..TREE FORHULA rxTRAOROINARY wITH COLLISIONS

TES T C ~ SE

CHAP)(

-9-007
'+-007
3-00:'
O+OilO RCIIR
6 -00 5

I- DO ..
1-004 APOGEE
9 - 0H lIol II:; RE II
5-:10$
0+000 RCIIR
2":"10 5
- 2-0015
- l- a O£>
-1-00 &
-1- 006 ExIT r ON
OtOOO GR N" REf
0 +000 EN T~ I ON
-8-00'
-6- 00&
2-005
4- 0J5
-3·011 ~CIIR

'"

O. Of.iJO
52 .9blt b
oO.71b~

65 .5~"' ''
87 . 785~

IJ7.1 217
1 2€l . 455tJ
1 .. 5.£>921
17d.77 37
2)O . J O)(
2210 . ~1o .. C
230. 7 "if>
230 d l S 3
2loJ .25 9;;
222.0226
200 . 000(0
161.ob 'll
129.0135
')S.7312
n2 ... 97/o
23. J;, 2 C1
0 . 0000
52 . 96.1b
'17 . 0257
lZIl . J0 97

1 53 .37 H
la].o}'1l ~
200 .0 0~L

f\ llrl(,E

'"
O.
Il
1 ... 0 7 5 9

~ ....

z, AZIMUTH ANGLE OF TRANSMI SS ION
IoS.CDooaD OEG
OF TRAN S MISSION = H.ODOODD OEG

~NGL f

t Z 1 t' u TH
il [VUTJON
nlHI
l OC Al

l(MTR

OEG

DEO

;:lEG

ELEVATION
LOCAL

':,)0

75.0,)0
- il . O DC
75.000
10 .11 tO
17.3H8
- 0 . CO 0 iJ
75.000
-O.DOL
75 .0 00
23 .1901
-,J . u DC
75.0')0
Z e . 2 1 Zit
71t.9'}9
- 0 . 00 1
J3 .20 25
- 0.007
3e .l'+ 96
74. 9~"
- 0 . !1 £>2
7 ... nO
.. (; .6 08 1
0
.
Ho2
52 . &IP5
'''.7d3
-1 • ., 77
74.379
00 . 6£>'15
1;)(;, 1025
-1. 7 11
73 ... 32
-1. 511
73 .111
o ?55G ..
- ')'~22
72.J07
'0. 76"1
1. ; 1,3
68 .50e
~ .. . 262:1
01.084
100.62<;7
S . 5 ll
3 • .,,.2
,,9 . 25&
1 3/0 .6131
10 . J 9 2
J8.6&1
1 'j5 .6~6"
11. ~I! ~
In. Ide s
27 .405
tb.'t63
19G . 950d
12.?2~
1 2 .192
- 6 . ~56
1'>.551
~20 . 990S
? .. C.75b9
13. <;':>7
- o.ZcU
-1.0 83
2 7 b . JIo 1; J
1" . ]7 ~
- 5 , "1 ~
9 .5 65
I/o. 7 6~
- 5.'165
1/o.7 d5
?qb . e Io 6 ~
-,. .72 1
16 . 9 .. 6
1'.; . 12 1'
l2e . Sllt ..
-4./0 25
22 .35 3
1'> ." 2.
310 " . 0&2 4
2 ,..q15
3E-Z . 9 J72
15 . " 7';
-". 2 14
J7 .... . 35{:7
1 5 .7')"
l5 .9H
-l. 6 ""
THI S ~A' C Al CU L4TI ON TOO K
- 0 . 00 0

-0.000
-0.000
-0.000
-0. 000
-0.000
O. 000
- 0 .012
- 0.32 1
1.3310
1.370
-7.3':10
-8. 853
-11.181
-110. 20&
-13. 5 43
-11.276
-9.7510
- 8 . 5&2
-7. &20

OEG

PO LA RIZ ATION
REA L
IHt>G

75.000
75. 1l7

-0. DOl

75 .110 5

- 0.0110
- 0.00 II
-01 . oo~
- 0.000

75.156
75.209
75.253
75.279
75.166
73 . 849
71.357
52 .074
15.5&9
8 . 2l1
-10.10 74
-29.337
- :'&.1075
-55.293
-56 ... 07
- 5& .2 82
-56.0810
- 55'8f5
55.706
56 . ~27

-a.allt

-O. OO~

- o. aDol
- 0 . 000
- 0 . 000
-0.00 0
:1.000
J. 000
iI. 001
!j, 0 0(1
0.000
0.000
J. a a 0
0.0001
~ .001
~. 00 J
- 'J. 00 a
-3. 069
-11. 00 1
-!l.000

56.231
56 . .. 0 b
55. ~O ..
- J.ooa
- 0 . 0 00
51 . H4
-0.000
45.37&
').&24 SE::

1.GOO
i.IlZ]

1.0410
1 '(l107

1. Glt6
loIl47
I.C4£>
l.tllo7
1.057
1.067
1.5&8
-9. 825
-J. e 7&
-1 . 95i1
-1.143
-1.0210
-1.007
-1. (j0&
-1 . co£>
-1.00&
-1.000
1. 000
1.0b4
1.134
1.1-JO
1 .13'>
1.19,
1. l710

GRO UP PATH

K"
0.0000

SIo.0371o
62./lJ71o

67 .11 3710

90.83710
110.il371o
13006374
150.637"
166.a37"
213dl81
2&& . 9181
306.9161
314dl81
330 . 9161
376.9181
10310. 96 73
491.9£>13
53 1 .9013
571 . 9673
1'>11.9673
&51 . 9673
£>67.41059
7~1,"563

792.10563
IIJ£' '' ~ bJ

872 ... 563
HZ./oS63
937.9,1'

PHASE

K"

PHH

48S(lRP T ION

0 . 0000

08
D.OOO O

510 .837"
62./13710
67.63710
90.6374
110.6365
130.8161
150.£>143
183 . 5011
202 .12e"
2 17.2922
220.0213
220.4&73
221.5762
228.5 798
2 109.21"7
291.7604
330.5977
370.5601
410.5600
1050.5600
1066.0386
550 .04e9
591.01069
bJt.OJ.,b
&70.52(,0
705 .8795
7 2 2.6911

0.0000
0.0000
0.0000
0.0001
0.0005
0.0013
0.00 19
0.0030
0.00"6
0.0091
0.0127
O.Olllo
0.01" 7
0 .01 81
0.0232
0.02&3
0.0275
0.0289
0.0292
0.0292
0 . 0292
0.0292
0.0293
O.O JOJ
0.031",
0 . 0327
0 .0 3 103

z

8

~~~~~~~~~~~~~::~~=~=::~~:~:=:~:::=~~~=~=~~::::::~~

or c

• • • • • • • • • • • • • • • • ••••• • • • • • • • • • •• • • • • • • • • • • • • • • •• ••
ccocccccccoocccccccoccccocccccocccooccooooccOcoocn

~
COOOOOogcoCaoOO=o=OOOO=O=O==== O= O~~
~m==O=O=OO==ODOO=CCOC=CCCOC c =cc= ==Occ

.
~

_~_ NNNNNNNNNNN"
=cccccoccOccccc

o

.-,."
,

.z

r

~~

4

o~ee~e~eee~~~ee~NNo~ec~~~ _ ~Me~~NN~N~eOM~~~~ ~_ o~cNu
COOCOOCCO~OCOOOOO~~~_N~~~j~~~~~ ~ OMN ~ ~N~~~~~ ~ _ _ MOO~

~

c ~~~~~~

~~~~~~~4~~MM~MN~~~O N~

~~C~N~~M~o ~~M nn~ ~~~

_

o~

~:~~~~~~~~~~~~~~~~~~~~ ~ ~~~~ ~ ~~~~~~~~~~~::~~~~~~~~~~~

-- ""
•

W

ON6~N.~~~_.~~.~.~o~~o~eC~~M~C.hNM~~~~nCNNNo~onnNM~

___
______________

r

~

0

~~~~~~~~~~~~~~~O

NN

~~~~~~~~C

__ " __ _

N~~N~
_~~
N~C~~
NNNNNNNNNN~~~~~~~~~~

"

~

o~~~~~~~~e~~~e~~~~~.e~e~e~e~~e~~~eee~ecocac~~~~~~c

_ ____
_ _ _ ___
_ _ _ _ _ _ _ _ _ OOCCONNNNNNN
• • • • • • • • • • • • • • • • • • • • •
o~¥ON~~N~~~~_~~~~~~~o~~o~~ce~~e~h~~N~ce3~_~e.~N~~~~~~
__
_________ ____
OOOOOooooocoooccccaCCCOaOaOcO~~~~~~~~~~~~

~

o~~~~~~

4

3~~~~3~~~~~333~~3~

___

~~~~~~

~~~

~

~~~~~~~~~~~

~

~~~~~~~NN~N~NNNNNNN~~~~~~~~h~

!z

Q. :II:

"~ ~

• • • • •

•

• •

•

• •

• •

• •

• •

~~~~~~~~~~~~.~~O

~

• • • •

• • •

• •

• • •

NN~~~~~h~a~~~~
~~ _ ~C ~ ~N~o~eNM
NNNNN~~~~~~~~~~~~~~.~

~

;
w

~ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ __ __ _ _ _ _ _ _ 3 ~ _ _ _ _ _ _ _ _ _ _ _ _ _ _
.... ,. ...................... " . ........... . .. .... ...... .
Z~oo
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ NNNN~
~ ~~_~C~~C33~ocooaoca
O~N~~~~~~~~~~~~ecee.~.~~~c
~ C~~N~~~~mON N~Oc~~~~~~

0

~

,

;
•
"
'"w

~

",
~
r

"

"

;; ~
w

_o oooc~~oaaoo

;!

,

I

,

,

I

,

,

,

~~~~~~NNN _ _ _ O~~oo~~ooaoeoe~ooo~6oe~ooaOOON_~~OO~OO

;

~;~~~~~~~~~~~~~~~~~g~~ggggg~ggg~~ggg6ggg~gggg~6ggg~g

0

<;

OqCo~coc~ao~aaccaOac~c~coooocoocu~ca~~~

~~~~~~;~~~~~~~~;~~~~~~~~~~~~~~~ ~~~~~~ ~~~~~~~;~~~~~~~
,

0

,

,

,

,

•

,

,

,

1

,

,

I

,

I

,

I

I

,

,

,

,

•

,

,

,

,

,

I

I

,

I

I

,

1

,

,

,

I

I

,

,

~

0

~

~

oooccooocccoooooaaaaCO~~a 3
~

MO~~~~~OO_MMM _ C~~~ _ h_~~M

coooeoococoaCCCOOOOCOO~~~~~hOh~

_

O~~~M~

OU,,-,

••••••

•

•••

••

••••

••

••

•

•••••

••••

•••••••••••

3~

__

I

••

••••

•

•

•

I

,

,

,

I

,

,

QOOO~o~o~oaoancoa

0

.

.. ...

.

~

oaO~~~h~~N

............ -

.

....

_~

~~~~~~~~·ON~~~N~~

....... ....... .

_ _ .~

.......

.

' 0

0===oooo=ooc==oca=coc~~~~~~~~~~~~~C~h~0~.~=~ah_~40

?-~-~~~~-----~-~--·--~~~~~~~~O~_~~~~~~~~ON

'~ ~~O"·"_

r

"

o

z

z

~~a_~~~_occ~aooo=oo~oaac~cooocaoc~~_

~~N~oc=a=coooQo=c=ooooeocccccaaooco_
~o~~o=acoooooo=ocoo=cooc~COCoa==o~ o~

.. . . . .... . ........... . ...... ...... .
777h
' 77:777
'
~

"

Z<tl!l
I:OUW

~~

"c

~

OO

c~~~aOOOOOOo==ooocc=aooao=aaaaaaoao~

i.':;;~

I

~
~

,,

..

,"
•
;;
w

.;

"
~

0

~

0

z

.:.

<w'

3~~h~~~~~ ~~~.~· ~~~~~~~ ~,~·o~~~~~·~~.~"r

r. ~ L'

~~ ~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:

~ :;;

~~~~~~w~~~~~w~~~~ 'n ~~~~~~~~~~~~~~~

,

,

~~oo=~~oaoaooc~oC

,

•

__

,

,

,

,

,

,

,

,

I

I

I

,

,

,

,

,

,

,

•

,

,

•

,

,

•

,

,

,

,

~~~~_~=~~~~N~~~~~~

O?oooo=caoooaco=0=oa~OU_~~ _ N~O~~~D _

'« '"

~ W e ' : ' 0,,", g Q O 0 0 < : " ' 0 0 > 0 0

QOO c o o 00"'", 0 0 '"

<> OoN~

_

~M~~~~~o~~~u

~~~~~~a~a~O'~3_

~

~

or ~~ ~ N<1'.,.., ~O'" j

"'N
_N~"'~~~~"' ~~~

O~~_C~~~~~~~~~~~~~~~~~~~N~N~~O~~~4~~_OU~4~~~~~~ON~
~-_~O~Q~on~~OC"O~_~~·~~~h"''''~O_O~~~~~'''~DO~hM'~~~'''j~C
~

=~~~~~~ ~~~4~4334~"' M~M~~~NN~~~O~~O~~=~~O~~~~Q~~~"~~

~~~~:~!~!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:~~~~~
w _"'IO",~~q~_~~~~~~~a~.a~~O~h~~No~ ~=~~ ~~_o_NN~~"'~''''h~
~

~~~~~ · OOO~"'~h~~~~ "

• • NN~~~~
<t'O
_ "'M"'M"'~ NO~ _~'"
_ _ _ - • • ~~
___
"'N"''''N'''NNNN__

_-_~

y
0_

.,

T;:",

< w r

_ ___ __ •

>

w

">

>
>

aO~~~.<t'

~~.,~

......

~

owo

.0

~

>

~~ND~~
_ __

.. "
-.-z_

>

•"

•w

;
___ __ _

...

>

. . ; ;e.

w

•

w

.~

o

>

>

">

_0'

~
~

>0

0

•

h~O~~~I~~~.

_

~

.. .y7.

0

•

• .,<,!I •.,
'n~·n~

_ _ ...

~~~~

~~~~~~~~~~~~~~~~~:~~~~~~g~:~~~~~~~~~~~~~~~:~~:~~~~
..

,

•

,

,

,

I

,

I

,

,

,

I

•

,

,

I

I

I

,

I

,

,

,

I

I

I

,

...

,

I

,

,

I

,

,

,

,

,

I

•

,

,

I

O.., ..,M ~<t'~~~~M~O~NM _ N~~ ~~3~MMNN_O~..,3~~N~N ~N _ NN..,~

,

,

I

I

,

I

,

,

,

I

,

,

,

""

177

,

,

y

~~Og~voo=uao=c~OQU~UOOMN_~~Q~N~U_N=MU~hNU~M_4_NM_~

.~

~

.....

~:II:~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~ ~ ~~~~~ ~~ ~ ~~~:~~~~~~~~~

"

00

~~

!!!!!!!!!!!!!!!!!~!!!!!!!!!!!!!!!!!

>

~>
."w
"r

I

NN~~~U~~~~_~~~~~~O~~.~~~~~~~~~~~~~~U

N>

i

•

=oooaooo~ooaccaoocooo~~~~~~~~~~~~C~~~~~h_~NNC~~NM¥

;0

0

~

,

~oaoooooococcc=coaoooe~~~~~N ~~ ~~~~~~~O~C~~N~M~~C~

~ "w 0z
"" "
~

~

~N~VMh

~O Ocoocccooooaoc=cocococa~~~~~~~~ ~~~~_M_~~~~ ~~~~~~~h~
~ ~
~~-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~_M~~~~h~h~~hhhhh~

;!

""

_ _ _

zq~ooaaoooo~~OCOOOO~OO~OO~~~~~~~~~~N~_Nh~NO_O~~C~~~~N~

,

I

I

,

,

,

I

"

I

I

"

I

I

,

,

..

_ N~~O

"

,

_

,

~

~z

'0
~.

,.
o~

- 0"
u

=

•>

·
·~

z

0

«
~

~

~ •
u

~

Z

0

"

~
~

«

~

,~ "">
z, 0
•
z ~
0

··
~

•~

z
z

0

>

z"

,
0

~

·
0

«
z

~

~

"

"
""

·
· ·•
·•
N

"

"0
"
0

W W

~~

~

~

z

OM

_

~C_O_N~MQ~03

_

QN~

_

O OOcOO UOOOOO~OoOoOo O

. . , .... ,. , ........... , .....

OO~O

__

O

_

~NON

OOOOOOOOO~OO

•U
M
W

;

~O MO OO~ _ OOOO

"

__
O~

oNN

C

=

_

NN

_~N

OOOOCOO

_ _ NN
~~OO

........ , .. , .. , ..... , .. .. .. , .. , .... , .. ,

~OOO~O~OO~~~OoOOOO~OO~~OOOOO~OO O

~~OO"OO ~

OO~o~oo

_O OOOOU~OOO~OMO~MMOO~~OOooooONo

~OO~O~~~oooe~ooooo~OOOOOO O

~N

_ ~

_

grN

O O~OOOOOO~OOOOO~O

O~O~~M~~OOONMOOOOO~OOOOOOO~ _ ~NOO~~OOOOOOOOOOQ~O
OOU _ ~~N~OOo · ONOoooooooooooo _ ~N _ oo~oooooOooooou~o
UOO~OOMOUOOI _ OOOOO~OOOOOOO~ · ~~~OO~ · ~OO~OO,OO~O · ~ ~ ~
~O~~O
~O

_ ~ ~OOOM~OOOOOUOOOO "

O~

_ ~OO_~~OO~OOOOOOOOO~OOO

' A~~D~O~·~OOOOO . ,OOOO~~ O

_ .~~~~~.~OOOOOoo~oooro

- ·· .... ...... .. ..................... . .. . ..... . ....
-.
. Z
U .

>

W

~
_z

oU

"

OOM~o~~~caao~aaaoocaccC~CM~~~~oC~coccaa~aaQOO~O
~O_NaMa~aaoo~oaoo~ooOOOO~ _ ND~~ oo ~~aooooo~~ooo~~
~~~Mo ' ~~

_ ~ao_~ooooo~oooOOOeM~~~

?O ~~O~OOO~O~O~O

OM~~O~~~OO?~~Oooooooaoo~o~~o.~~o
7'n

. o

7

~~

_N~~~

-

NNM

--

~M

-

~

---

~NN

-

N

-

~

7

~

7_

_o~ ~ooooo~o~o

~M~~

_

N

___ _

~

M

_M
~~

__ M __

__
__
__
_ _ _ NNNNN ~~~~~ • • ~~~ee~eee~aooo~
' ~~~~~o~~~~~~
______
____ NNNNNN N

_

~~CN

M.~_NM.~~~_e

178

NM.~~

NM~O_NM~~

NM~~~

z

Z

o

OO'O..D ...... c:>O ......... ."

o

CO ..... .... 4'4'."fOO

OC>CC>C>NNN~-4 ...
...
c::>O ........... N"'NNt\j",
o..<l:)ooc>C>oOO<;>OCC>

....

0 0 . , . , . , .......... '"
0 0 0 0 0 .......... ""

co: 0
o

COOOOOOo;:lO

0<'0'

o

.~
~z

CL-a)oooooo<:>oo

••••••••••

..,<;;><:>000:;><:>c:>000

~

~

~

~

z

z

~;:

....

o~

0

00"...,.000"0''''(\1",.0

'" .......... .

...
~

O " ' ........ CI"' .... ., ........ O

.... :z::e>"' .......... oD"''''''''''CI

-- ""

.~

0
U

oO ....... O"""' _ N
04''o£)<D ' " 0 4'''''''
:1:0"' 4'4' "'C>_ .... ."

Wlo( • • • • • • • • •

O~~~~~~::;:;~

""<l.r

...

O . . , " ' N N N " ' ....... ,.._

...

<C

oO'NNNNN ... OO'"

...

0..

O"'CQClC"""'C7'C7' ....

.......... ..,"''''-

0 . / ' ' ' ' ......... '''0' ........

.....

. . o N " ' " , ............

_"I'''''''
'" "'.0<:::1 C>..,
__

J:
0..

O ... N"'ONC>,z ....

~

... .0.00"0 .... " ' ' ' ' . ' ' ' ,..

""

Q.

•••••••••

~

.. 'o£)<D"'<:>
_ ...
.... 4(7'
_ ...

L
~

z

•
>
••

ONO'C7'O""' ............... O
0..:1: • • • • • • • • • • •
::>"'c;> ... C>C>Naolt\O ...... . ,
(\I ...... " ' ... "'C>\I'I"'CI

" "'
~

o

0

<.!I

~

0

~

z

... ..,OO..,..,4' .......
<:>"' .... NN"'..,..,C;O

C

'''''' 0 ...

a.
0 4 ' ' ' ' ' ' ' .....
0_00..,.., ......... .,.
a. J: • • • . " . • • • •
::o:ro:O~ ......... ..,NO ...
o
a-.,../'.,.0<1'f1'4'

.... "'oD<D_N4'f1'

(J£

. , ..... " ' ' ' ' , . . . ' ' ' ... 0 0 , . . ,

<!I

...... _NN"' ............

...... _ ...

0

<

~

~
<

0
0
0

"
"~ •

~

0

"
,""'

:;;

~

~

,

L

Z
0

~

r

0 . . , ...... .... 1 ' - 0 " ' ....

""

""

.0;

"""

'"

0

co:

"" a-O"O"'''',,"'''

I

I

~

,

. . . . . . . . . . , " ' .... .... 00<::1

"

,,

c:> .... O O .... e)CI ....

"''''c

U

...J

o , D o o ....

4...00_0<:>01'-000

, ....,

a.~o..,ooooo

:.l

Z " ' . . , O . . , , , .......................... ON

~

0<.)\01

"

"~ "
0

",
;;

o-...J

N

C

Z

u

~...o

I'

I

, -

>

%

o

0 ..... "',z.., ..... ~0'
0 ........ "'""",<D",

"~
W ~ ~

oa- ... .,O'4' .... a-:roo:

<w

•••••••

_0

"' .... N .... -, .....
.............
, ./', ...., ...O

_0

~,;,~~,:,::~~~:::e
,

'--'_'0

_ ...

<

w

"" ......... '" 0 '" 4 4 .... '>t
• • • • • • • • • ·0

XO

.... 0 0 ..... " ' 0 0 0 " ' 4 ' ' ' ' 0 .

""

...
C> ' /'I " ' ........... .0'" ... '"

"~

o

.... _ ,

",.0 """' .0"'''''''

0

,. . ....ZW..,

z

,

Z

Z

o

u

.... o-:.

oo oooo oooo~
~

Z< 0

rou .....

~

· ~./'J

. . . . . . . . . . -,

"

0 ........ .......... 0 0 0 ......
0000000000""

" ~"
z<
N>

C'>t\.t\. ..., .., ' " "" ..

41"'~

OClOOOOOOcCl

"
"~ "

Z<~

Z<

,.., .-..u

zw
xc.

"

<

<,,~

~",~,,,,,,o,€O'a-<'

c ...... _ 4' 4'
'"
"'oOOc,""coc,"
~

'::C:O:;':; ':':~":!;

0 " 0

,O

C.,
... "' ....
co ........

'I: 0 u ....
....... 0 0

, , ,

o

....... o ..... ...
N...,O ...
OOC04
" • " • " • • "...0
00000<:>00::::J
,
, , , ' U

0~C"~""0"'''''''.n_

"
=
"
<

"

W

z
N

o u . . . . . . . . . . . . . ...

. . . . . . . . . . . ....

<
>

"

-'

.... OClo ... gOa ... o .... c o o .

~

c:>

o .... oo"'""''''oDQ
O ... OON ......... "'OoD
Z4.<.!)o oDOO"'''''''''' 0""

...,,..,<:> ....... <:> ...

~

W

,

..... 4 . 0 ... 0 0 0 ' " " 0 . . , 0
OW , • • • • • • • •

...... " " 0 " ' .... 0<:1"'0(0'0<:>0

o

...... ,., ...... .............

~

OW· • • • • • • • • • •
O:YogOOoC'>,=,Oco,""

o
o
o

-

Z <!IO"''''''",,,,,,,,,,,,,,
OqOM4.l..tOOI(>Q"\
....:1: • • • • • • • • •

.. ...JoC7'OOOc:;lc:>..,OOC>

W

o

Z
0

~
<

..... o c", ... C. ..o","' ....

Z"-'ONNNC7'C7'O ... ...., ......

.... :l; _
•
•..
•_
•_
••
••••
•
......
_
..............
_13'

O ... .., .... , ..... oI.IQQ>iJ .... ClM

0

••••

, ,,, ,

,

"

••

'4

•..• "'<:oo~n"='OfY

C'>~,:>o",o""O'Olo'"

0

<

~
N
N

•

~

~

". 1:

0<:> _ _ (7' .... "" .... ..,"" "' ...
<:> .... .n ;:) .......... .., ..... (7' oJ' ~
4'O~ ... :ICI

c""
'I' ..............
'01",_
""",,"'''''' __
•

•

•

•

~

•

•

•

•

•

0

••

-'

~~~c>~,I"~

~

__
_ 17 · "' ... ..;<:>4"""".;0

~'>t<:>",

Q'

C4'4'./''''a- ... ..,

...
">

•, ~ • .3_ ': ·r ... r...,

....

<!I

c O _ _ I'-'I),J'ooD

?':I:

•

<>.lo(~

It'

"

•••••••

"'~~""",,,,,,,,,,,,,,

..,CQo .... _ c
... . ,

.... --""""...,..,..,~

~

~

"

· ""
0

0

" '"
">

•

ur

,"

.

,

<
_z

~U

W

~

'~"" <1'oJ'""",o "''''NoD

"" .... ·0"' .... ..,0.., ..........

J:
c .... 44'_Nc~<;lClo;:l
<.!):r",(J''''' _ _ NO(J'''''''''7'

... :roo:

W
:

• • • • • • • • • ••
o .... 'C""-eC"""N ...... 1'..... .,;":::~4'
-l':=;:~
"" _ _ >.tlo.;;!:
> ...
::0 ..... ..., ... 0 ... 0 _ ........

_ ...

_Q::_,._~O!:

:::..,
<1::11:

...0

WI-:::Ieo.

...

Q

"" .... ,.." " ' .... ..>

. ,, ,, ,, ,, , ...., , .

z:-

w' 0

o"''"'-t/'....,O~... <D
r
~.., ... ..,oD .... O~'"
<!Iro "' _ _ 0'"'0 '7''''
.... lo(

••••••

•

_

•

. . . c"""" .... N'CO"'"N _
1:

"' ~~~~

\.... ~

OI: _ _ >;;!: .... "" ...

0 '1'1 ........ 00.;0<11
..._
... 3:_"' .... _

':)
W

...... zz> _z ... ><>z
rz .... ""><'Y~""""_
>< '... II: x: ~ .... <!O .... II::S-:I:

....

.. ~~ C'> ........

>
0

z

~I-

o ./'.., .~ .... .D ..... ~Q
' = ' O C O " ' ........... ....

fICO!:

00

,
W I-":lOC

z
""><tr:>:_
>< ... r.::r:J< .... <!I .... :I:;

...... 2:Z>_OI: ...
1:Z _ _

-.0000000=>00

~C ....... o"'Q ... O
00_"'''''''0'0''''0
"00000"'<:>0

0"""'"" <D ""c <:> . . . . 0

0 0 ...... "1 ... 0 " ' 0

:;:::::::;g~:;~~g

179

+ •

, ••

"

, •

,

, •

,

11105/71+

TEST C",S<:

'"'CHAi'X

W.l.~[

JIPJL'f

APPL[TOtl-HA RTREE FO~I1ULA ExTRAORDINARY HITH COLLISIONS

f XPZ 2

0.006JOO MHZ. AZIMUTH ANGLE Of

FI'IECuEllCr

fLEV~r I JN

~Nr,l~

OF TRANSMI5SION

"5.000000 DEC,

T~ANS~I SS I ON

=

30.000011~

DEa

il.21~uTH

DEvIATION
ttEIGHT

3- 011
0+000
0+0,)0

"

~ 'nR

ENTR ION
NIN 'JI'; I

O+JOO MIN (JIST

.....
00

0-010 \oI",VE REV
Z-'liI5 E~ IT
-3-011 GRrlO REF
1i*IlOO UH~ 101\
1i*000 l'1IN JIST

'"

:l . } 0 C~
52.'373<;'
l'H.Sb .. l
191.5b41

Fll.40':';o,
"d. 7 3:;~

O.OOUO
:'2.Q711
UY.:\217

0

~A ~ GE

" 0 orie
~.

~HTP.

,,"

1\9.<JOtu

- C. COO

354. '14 (HI
3S4 . 94(d

- 0 . 023
- 0 . ~ Z 3'

3~8.1Gb5

- O. OZO

[l[V ATIO tl

LOCAL

xrHit

OEO

DEG

-0.000
0.21'3
O.2B

30.000
lo .HS
26.3'18

o*aOG
0+000
-3-011
2-00:'
3·JJ.,
3- 0 11
a-DO"
0*\100
0*)00
- j-HI

~MH

E'I TR ION

'"
:;;2. "I75Q
0.0000

~';VR

2iJ~ . OOOO

APOGEE
.u .... E. REV
RCVR
EUT 10'"
GR."'O REf
ErHR ION
RCVP.

2J~ . c8j4

2~q .43 "O

2ilO.JO\l1i
36.3020
J.JO)O

52.9717
20U .,) 0\10

30.6(1'3
0.000

PGLAiHZATICN
IHAG
RElIl

- ,:; .0 aD
- O. HZ
0 . 000
0 .000

0.000
-1. J95
~. u0)
26 .154
0.03,
1.406 -26.'H5
~ .357
t;41o.46e1
-3. 29'3
28.17 3
-J.OOil
i3l.Quao
"). '. O~
2Q.0103
-Q.271
~ . ,.Iot:
-;).308
-0.1 0 10
~3Q .l H2
0.000
J . r; 1~
0.454
10.581
O. liD 0
1107.5272
THI::; R41 C4lCUL4TION TOOK
iI.113 SEC
0 .137
-0.3'37
-0 • .14'3

ELEVATl)!\. AN;;Lf OF TR:4NSMISSION

HI:. IGHT

LOCAL
OEG
30.ol00

4,IMUTH
lJEVU TI ON
~MrR:
LOC Al

=

1.000
1.25<)
-1.0;30

-1.530
-1. 4 75

-1.013
1.coa
1.223
-1.771

JEt.

DEO

~ ,'1TR:

DEO

KH

D.ooon

PHASE

PATM

KH
0.0000
104.6686

ABSORPTION

DB
0.0000
0.0000

10 ... 6686
1025.79210
425.7924
r.2'3.7nr.
770.7n4
872.6850
963.3256
1312.1:1736

ItO O. 'H>14

c..ooel

40D,qUlo
1003.6'31'3
720.51057
822.10383
933.0789
1240.1070

0.0062

GROUP PA TH

PH4SE PATH

ABSORPT ION

'"

08
0.0000
0.0000

0.oti65
0.0177
0.0177
O. 0177
0.OZ59

45.0GQOOO OEG

ELEVATION
POLA~IZA TION
LOCAL
DEl;
~EAL
IM.IIG
K<
- (I.OO·J
1.000
105,.000
c.oaoo
1.100
45.471
- ~ .113
- U.C~O
-0.000
45.0JO
52 .324 6
-0.000
2.293
-0.132
.. 3.622
28.480
200.2014
O. '" 07
\1.00 ,)
-1. e3 l
.. 0.lQ9
3 .110
-'J. :iltC
-1. 740
,,35. bol~
O.OO'} -1.t23
J. -)21
-1. 'H2
39.1031
241. J"Ie~
-0.2"6
-1.1102
34.427 -23.45£>
\I.OOil
J ..~8<j
-1.415
?74.3781:1
0.004 -1.000
2.\178 -'+4 ... 72
.• 4~.9524
0 . :; 74
-0.027
-J. OO )
-2.1 :10
44.114
1.000
JoSH
- 0 . \125
4e4.7J6il
1.091,
-0.105
-0. 022
3. b8
104.5099
I:. J~.c621
O. '.i 71>
- 0 . 000
2.159
12.709
26.953
t<> 1.51cj
0 . 5 .. •
O. '90
TH[S R~1 CALCULATiUN roo~
".013 SoEC
R: 0\, 'I GE

GROUP P A' H

'"

0.0000
74.6126
295016109
352.1649
360.1"49
410.8543
659.dS103
715.51'>26
7Ql.3392
t015.j617

0.0000
74.6128
276.~398

~.OC58

306. J131
310.18'92
H€;. 8372
566.5130
622.2214
697.9980
905.3752

0.0098
0.0103
0.0137
0.020"
0.0206
0.0206
(). 0266

<01

TEjT

C~APX

C~~f

W 4~E

11/05/7'.

0 I PCl Y
FRi:..OlJE,ilY

6.0QQ,JOO Hill.
ELl ~ A TIJ ~

liE I GH T
0+ 0 00

o+oao

-00

O+ (j 00
-1-004

XMTR
HHR 1 0N
RCVR

AP OGt:E
WAVE i?EV
OtOOO RCvR
-2-~0 7 EXIT lON
OtOOO GRNU REF
-3-011 EN I R I ON
Ot-OOO ~CVR
-1- ~(l 1t

K"

a .D OOG
52 . 9He
200 . 0(;oe
£25 .83 32
225 . 83.i2
2uO.OOJIi
26 . 77 :; 1
a.OODO
52 d8 Ie
200 . 0 00 0

APPLETON - HARTREE FORMULA EXTRA ORDINARY WITH COLLISIONS

, 'IF l2

~4 ~ GE

K"
C. GOQO

~NGL ~

OEG

OEG

HEIGHT

q /l~ C.E

<"

K.'

O .~ OOO

";2 .9 Slob
200 . 0000
230 091<:13
2J~.l513

200 .<l OOU
2903420
() . 00 JD
52.9636
2~0.1l00G

:

DO .O COOa~

OEC.

ELE'IATION

XHTR
OEG

;, o. 00 0

LOC~L

;>OLA~IZATIGN

DEb

REAL

6C.OOC

- a.OOJ

60.272
-0.053
3'3 .325
50.576
-D.DIlO
- il .354
5 ... 02
55 .672 -5.296
0 . 00 ()
1 <t~ . ~»30
- li .35"
5 .4 02
55 . 872
- 5 .2 98
0 . 300
168 .1Ii3»
-1. Ja J
1':'.370
.. 1'1 .7104 -62.1099
O. a 0 (I
6
.
;'
107
5
.561
~9
.'+11
;).000
230 .91 96
13. ;; 6"
2"0 .711rl
-7. I) 0"
13.003
-1.01:13
1>9.320
- ~.~oo
- 7 . '1 92
20G . G662
12. 02 1
1 0 . 2'019 69.1t')'J
-0.026
3 13.'3111
-10. t 1 ~
8.555
30 .632
- 0.000
6 3.,6"
THI S RAY CALCULATION r OOK
7.518 ~EC
30 . l Si]&,
111, . 41.<,2
14f>.6930

-0.15 7

-0. 000
-0 .&51

ELEVATIJtl ANGLE. OF

utQJO X'1T R
OtJOD ErHR I ON
OtOOO RCVR
1- 00 4 APOGEE
9 - B5 WAV" REV
OtDOO RCvR
-1- DOb EXIT 10'
Ot-OUO G~NO Rt: F
<l * Jij G EtH R lOt.
-3-011 RCVi(

rRAN~HISSION

AztHuTH
rJl:VIATlO,1
XHTF
LOC4 l
-1). 0 0 e

1,5.00 0000 DEC.

AZIMUTH ANGLE OF T RAN $ MI SS IO II

OF

il . 0 ~ OU
lit. a 7S9
52 . 6 d 75
:' 7. 5SG,+
70.7691
l J6 . bZ')7

T~ANSHI SSION

AZIHUTH
l)EVIATION
LO C AL
OEG
OEG
~MT R

- v. OOoJ

- O.OOV
- 0 . 3 02
1.331t
-i. '> 11
-a.853
-~. 12Z -11.101
5 . '> 11 -13. 543
-6.85&
220. 'B08
12. J9Z
240 .75119
13. 5 S7
- 6 .291
1 ... 3n
-5 . .. 7')
'N6 . 3 4 G3
37<;.3507
1 5.794
- 3 . 61t4
THI S ~AY CA L CULA TI ON

1.01t9

1.250
-2.C02
- 2 .C02
-1. 025
-1.000
1.DOO
1.(;25
1.e9,)

GR.OUP PATH

K"

PHASE

PATH

<.
0.0000

ABSORPTION
0'

0 .0 000
61.0908
239.25'52
324.2552
3210.2552
J95.1225
588.1225
616.7330
673.3376
837.7013

61.0906
225.&3 '+3
253.2661
253.2661
273 ..H58
1053.61210
"82.2229
538.8275
691.0808

0.0000
0.0000
0.0050
0.0114
0.0114
C. 0 1 73
0.0223
0.0223
0.0223
0.0271

GROUP PATH

PHASE PA TH

ABSORPTION

75.000000 DEG

ELE VA lION
LOCAL

XHT~

OEG

IM.IIG
1.000

O£O

75. UOO
75.000
750127
74.783
71.357
73 .111
8.237
72.3Q7
-4.47"
6 1.084 -46.,+7S
6 . 55 1 - 55.685
-ldld3
55.706
'1.565
56. <127
25. 91H
45 .376
TOOK
9.0 .. 9 SEC

POLAR IZATI ON
RE AL
IMA G
-0.000
1.000
- 0.02,+
1.023
- 0.0 OJ
1.087
J. 0 a J
- 3.8 76
a. aO'J -1.'3S0
0.000 -1 .021t
-1.000
1.1. a 0 J
-0.00)
1.000
-(1. 0 69
1.061t
- O.OD~
1 . 374

K"

0.0000
54.H7 ..
213.9181
314.9181
330.9181
434.Y673
651.9673
687.'+459
751.IoS63
937 . 9577

K"

0.0000
54.8371t
202.1281t
220.4673
221.5782
2109.27"7
1050.5600
1t86.o386
550.0 f!89
722.8911

0'
0.0000
0.0000
0.001t6
0.0134
0.011t7
0 . 0232
0.02'32
0.02')2
0.0292
0.0343

z

o

d dOOC ~ ~~~~~NNNC

C>""c:> O .... N~<CN..., "' '''''''''C>

o o c c c o O "' _ _ "''''''''''''''

~

~mooo o c>oococ:>ooc>oc>

0< C

o

•

•

•

••

•

•

••

•

••

•••

000000000000000

~

~
.~
~ z

, 0

~

~::;:;

~

I

O<C<C<C ....

,~

~"
~ "
0

w

0

•

~C~~N~~~"'~~"""'~~'"
CNj~~""~M"''''<CC~O'''

~

"''''~_~~

r

_ ........

~

~

o

0

Z

"

"
~

~

. . --- ----j"' --- --

~

O~~ NO ~~O~~~

~-

""'

•

0

~
~

"•
"0

'"",
;;
;

~

•••••

•••
I

~
~

~

I

I

I

,

I

u

•

~

•

""

~

,

·
•

.... ~-~

••••

I

I

I

I

..,"''''_1'')

"
~

I

I

I

I

2

OC>OO ....... .... (1''"'O~N~..,
~0"'0,ro ....
..........(>"' ... N>O
ooOo~(1''''O(1' .... tf\NN''''lI!
• • ••• • ••• •• ••• 0

~
~

'" '"'''',....., ... "'..,...,.,., N

oOOO(1'(1'(1'(1'~~""",(1'",O

"'.0 ~

,

z

r

o

~

z

~

""""'<.!l

.... 0 0 0 0 0 0 0 " " ' 0 0 ...
0 0 0 0 0 0 0 0 , , " 0 0 ...
0:>0000000"'00"'"

....... 0 0

00<:>0000000"':;:>

. ... .... ...

"

1 : 0 U ....

:::> .... ~

..,,,,,

" '"

~

<.1

I

,,

""

'"
'" w .... .:J .f' ," _" C '" ., V
o!J .f' ..c oJ;> .!) ~ >0 ..c ..c ..c .0

"

"
c'
Z

";"; "~":";". ~ ~ ~": '::;

-.

...
_........ .....................
_...;- - ----""

'"
" ..." '" '" '" '" 'Y
~ or'
.... '"
~ '" '" ...
I

,

I

,

,

,

I

•

•

,

,

O""oo.., .... ~m(1'..,M ... (1' ...

....

r

~~

<:'O.., .... "'_ ... '"

O.:>·~c:>;:>tf\N ...
0 " " " ' 0 0 .... 0"'_(1'(1'(1'0(1' _
Oq~o<:> _ ..,(1'DcMD ... ~ ....

<.!l
;>-:>:

••

••

•••••

•

••

•

•

•

~KCL'OOOOOOM3~"'MMN

Q

~

....... ..., ~" N

_

...

~

<.:> ., .,-. ,~ ,J

.,

C

. C'"

J.J

;>

= ~;~;~~~~~~~~~~~
~

~C~~ N

.... lI!

=
~

•••

.... _ ON~OO~O:>"'O
••• •••••••••

~N~~(1'~~~n..,~~ON~

.... O~~M~N
__

"'~ . O_

'n

NNNN~

Z

,>,

0

....... ' .. ' "

'"~

Z .... Z
WuJ

0 ,.. 0

"l: 'r'"

~""Il.''''Q:

,

UI
'0

•

o o o c o ( 1 ' .... OC(1'~~ _ _ "' ...
.... N~NN~(1'O~O
OU W • • • • • • • • • • • • • ~ .....
~OOOOOOO(1''''(1' .... '''~~~(1' .... •
~~
~(1'~(1'~~~~ .... ~ ........ ~ ........ ..,

.~
~

I

;;:

"

" '"c0

I

0 0 0 0 0 1 " ) ( 1 ' .... " ' ...

Z

~

0

••••

,

~

"
~

•

,

Z~~ooooo~

z

,"

•

I

•••••••

0

;:

••

o..~OO~OO~OOOO~OO~~

.
•
r

•

~""'~OOOOOOOOOOOOOO

'" UJ

z

_0

•

""'~oO~oooCOOoooooo

~

~

.... NC<C .... oDNoD...,

O<1'N<1'..,
_ _ _ ....
N CNU"IoDOOc->..,'"
M"'Oc..,OOOO

~

~
,

~

~

O~OOOOOOOOU,"'O~UOO

..... ::1:

0

~

__

~ONNN

Z~OO

0

~

I

~oDoDoD"''''

"''''oD ........
OoD_ .... _ ~N .... M
.... .... NN""MjlnoDoD<C

~

~

0

•,

j

~~ONj~a'oD

'"

0

~

"

O~~jj

C,...a'N ........ .... _ _ ....

o..:r • • • • • • • • • • • • • • •

0

"0
r
"0

''''M_~~''''

OCCCOC"''''''''''~~~_~

~

•z

_ _

NNNN4jj~

<c<c>""..,..,<C., OO"'C O>&loDO

o
~

·•
·•,

••• • • • • • ••• • • • •

~

~

>

.... C

~"'NN~...,"' _
CCCC"" ~ ~ON ~ ~~~_~
C~~~""N~N"'M~""~~~

4

_10:_

'" ... :=oa::o::
0::0:: "
......... " ' " " , ' O , ... Z ... ,
::c 7""'4'" " " U " " ' C ( n . U " ' t r Z u
l.UW "'~l.U l.U<.!l'r

"'lL.I'1:S"~~O::~'X""'trl.U<.!IWO::

0 .0,..,.., .....

... 0' ....
n ........ <:>
.......... 0 0 0 0 0 0 .... 0 ........ 0

<:> .... _

0

~"'OOoO"'o~o<:>o<:>""

,

,

,

,

I

..

00

0,..,""'" "'NO"'''''N.tIN''''''0

, , , ,

18 2

•

,

,

I

,

, .,

,

I

"

,

.....

~I

..

Appendix 8d.

Listing of Punched Card Output (ray sets)
for Sample Case

TEST CASE
XOI
CHAPX
6 . 500+000 3.000+002 6.200+001
WAVE
2.500+ 002 1.000+002 1.000-001
DIPQLY
8.000 - 001 0 .0 00+0')0 0 . 000+000
3 .6 5() +OO4 1.000+002 1.480-(11)1
EXPZ2

x'Jlx

o 4000'1255000

5.000-001 0.000+000
0.000+000 1.000+002
n . OOO+OOO 0 .0 00+000
3.00 0 +0 1)1 1.40')+002

0. 11 00+000

0 . 000+000 0.000+000
1.830-002 0 . 000+000

2000 001"1
6f'l(l ('I '1
45 0QOOO
0
- 29
0 1514 389 4513 -161 0
11
2
14912561
2
- 29
0 1514389 4513 -161 0
11
10
29000482
-0
738 2875068 80425 68182
22
£..3050842
- 0 '12785611 09 482 91246
-7
76
33
4500000
o 40000255000 2000 000
600(10
1500000
0 635731
6041034
15
184
8122 - 3264
8
6<141('13 4
184
8
15
0 635731
8122 - 3264
12129251
46
-23 14656 1211ng4 81100 58053
17
59
18286204
-65
- 0 1854769 92641 58123
26
4500000
o 40 000255000 2000000
3000000
60000
3549 4 08
0 407964 17828 - 7003
8
- 23
219
35494(18
8
-23
219
0 407964 17828 - 7003
7336080
405 -349 28173 731203139482 89236
18
11075272
514
454
26
0 11384 30174444 101677
45 00000
o 4()OOO255000
20000 00
4500000
60000
607 28480
2002014 -132
285194 9971 -6754
6
274,788
389 -1415-23456 342980 67874 -6143
14
4847060
576
- 25 44114 484589230974137632
21
(..1915163
548
796 26953
72988 0 285982175495
27
o 40000255000 2000000
4500000
6000000
60000
7950 - 5671
1144182 -1 57 -851 5 05 78 231305
5
1681639 -1383 16876 - 62499 2629931321'0 10323
17
2407118 -7009 13003 69320
240697376036241525
22
3139111-1 01 15 8555 63564 376316461386314765
27
7500000
0 40000255000 2000000
45 0 0000
60000
526875
1334 71357 207034 6884 -4 906
5
-302
1066297 5511-1>543 -46475 227435207533 21840
23
24 07589 13557 -6291 55706 240745446701245294
29
34
3753507 15794 - 3644 45376 4,0 4 30507528292462
o 40000255000 2000000
6n'1no
4500000
9000000
3028214734180000 88779 200000 7166 -5034
5
153973214734
0 - 75213 200610210447 37559
20
537019214734
0 78918
25
53702568516382995
927180214734
0 77233 221057612222414510
30

1581469 1'.. 911561
1581469
1~81469

1579016

XOl:<
1721392
1721392
1721416
1719566

XOIX
1 9 15641
1 915641

1916346

1898217
XOlx
0
2096543
2096843
0
XOIX
0
22 58382
2258>82
0
XOlx
0
2309183
230,183
0
X01X
0
2382305
2382305
0

The first card is the title ca rd.
The second card contains the name of the electron density
model plus parameters W101 - WI0?
The third card contains the name of the perturbation
model plus parameters WlSl - WlS7 .
The fourth card contains the name of the magnetic field
model plus parameters WZOI - WZ07.
The fifth card contains the name of the collision
frequency model plus parameters WZ5 1- WZ57.

For description of remaining cards, see figures 1 and 2 .

183

o . uoo +ooo

1 .O CO +002 0 . 000+000

o - 1003T

0
0
0
0
0
0
0
0
0
0
0
0

0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0

0 -17Z1 M

o - 1722M
o -1 00%

-0 9323""
0 - lOOn
0 -1481M
0 - 1482M
-0
1003G
0 -1953M
-0
1003T
0 - 1531M
0 -1532M
-0 1 003G
0 -1773f.A
-0
1003T
- 0 2291R
0 -1142R
-0
100%
- 0 2163R
-0
1003T
-0
1251R
0 -1 032R
- 0 1003G
-0 11 0 3R
-0
1003T
-0 1091R
0 -1022R
- 0 1003G
-0
1373R
-0 1003T
- 0 1031R
0 - 1082R
-0 1003G
-0 1013R

Appendix 8e.

Ray Path Plots for Sample Case

Projection of raypath on vertical plane

XOI

TEST CA.SE

r: = S.OOO, AZ = A5.00, EXTRAORD.

184

11/05174
100.00 KM BETWEEN TICK HARKS

Projection of raypath on ground for sample case

X

F' =

TEST C~SE
Z = 45.00 , EXTRMRD,

6.000 ,

185

II/O~I7'

100.00 KH BETWEEN TICI( MARKS

FORM
13·73 1

OT·29

U.S . DEPAR T MENT OF COMMERCE
O F FICE OF TELECOMMUNICATIONS

BIBLIOGRAPHIC DATA SHEET
I. PUBLICATION OR REPORT NO

3. Recip ient's Acce ss ion No.

2. Gov't Accession No.

OTR 75 - 76
4. TITLE AND SUB TITLE

S. Publ icat ion Date

A versatile three- dimensional ray tracing computer
program for radio waves i n the ionosphere

October 1975
6. Perf orm in g Organization Code

OT/ITS, Div. 1
7. AUTHOR(S)

9. Pr oj e ct / Task / Work Unit No.

R. Michael Jones and J ud i th J. Stephenson
8. PERFORMING ORGANIZATION NAME AND ADDRESS

U. S. Department of Conunerce
Office of Telecommunications
Insti tute for Telecommunicati on Sciences
Boulder, Colorado 80302

10. Contract / Grant No.

12. T y~ of Rep o rt and Period Covered

11. Sponsoring Organ izat ion Name and Address

U. S. Department of Conunerce
Office of Telecommunications
Institute for Telecommunication Sc i ences
Boulder, Co l orado 80302

Technica l Report
13.

14. SU PPLEMENTARY NOTES

IS. ABSTRACT ( A 20()-'woro or les s factual summary of most sifP1ificant information. It do cument include s a siQniticant
bjbljo~raphy

ot literature survey, ment;oo it here . )

Thi s report describes an accurate, versat i le FORTRAN computer program f or
tracing rays through an anisotropic medium whose index of r efracti on varies continuously in three dimensions. Although developed to calculate the propagation
of radio waves in the i onosphere , the program can be easi l y modi fi ed to do other
types of ray tra cing because of its organizat i on into subroutine.
The program can represent the refracti ve index by e i ther the Appleton- Hartree
or the Sen- \,yller formu l a, and has several ionospheric models for electron density
perturbations to the e l ectron density (irregularities), the earth's magnetic fie l d
and e l ectron co l l i s i on f requency.
For each path, the program can calculate group path length, phase path length,
absorption, Doppler shift due to a t i me - varying ionosphere , and geometrical path
l ength . In addition to pr i nting these' parameters and the direct i on of the wave
normal a t various point s along the ray path, the program c an p l ot the project i on
of the ray path on any vert i cal plane or on the ground and punch the main characteristics of each ray path on cards .
The documentation incl udes equations, flow charts , program listings with
corrunents, definitions of program variables, deck set- ups, description of input
and output, and a sample case.
KEY WORDS:
Appleton- Hartree formu l a; computer progr am; ionosphere; radio waves; ray tracing;
Sen-Wyller formula; three- dimensional.

17. AV AILA BILITY STATEMENT

18 . ~cwi ty Class (This report)

UNCLASSIFIED

CZlXUNLlM1TED.

19. ~curity Cl ass (This pa~)

0

20. Number of pages

197
21. Price:

FOR OFFICIAL DISTRIBUTION.

UNCLASSIFIED
~ u. S. GOVERNMENT PRINTING OFFICE 1117~· 662·16t1111C1 R.... e

l'SCOMM - 'J C 2Sl716-P73
16(X)1Ot • fJJ.

ERRATA (21 April 1979)
OT REPORT

75-76

A VERSATILE THREE-DIMENSIONAL RAY TRACING COMPUTER PROGRAM .... _ _ '.
rOR RADIO WAVES IN THE IONOSPHERE

by R. Michael Jones and Judith J . Stephenson
The 8th line from the bottom of page 9 should read :
(1) the dispersion relat i on cannot be exactly satisfied, or
The first line in the 3rd complete paragraph on page 12 should read :
Similarly, the AHWrNC (Appleton - Hartree , ',; ith field , no colli -

in SUBROUTINE PRI1'1TR on pa~e 80 should read :
RANG"C:=EJl.R THR '" .~.7 AN2 (RCE, EARTHR+EPS+Xt1'i'RH)

PRIN12S

Line 8C1'1C020 in SUBROUTINE BQI-1F"NC on page 100 should read :
REJl.L N2, NNP, L?OLAR , LPOLRI, KR, KtH! [(PH, K2 , KDOTY, K4, KDOTY2,

BONC020

Line 7.o.8X064 in SUBROUTINE TABLEX on page 112 s"r.ould read :
PXPR=PXPTH=PXPPH=O .

TABX064

Line

P~IN'25

Follo'.{ing line CHAP024 in SUBROUTINE CH.Il. PX on page 116, insert the line :
CHAP0245
PXPPH=O .
Line VeHA010 in SUBROUTINE VCHAPX on pag e 111 should read :
X=PXPR=PXPTH=PxPFH=O .

VCHA010

Line DCHA014 in SUBROUTINE DCHAPT on page 119 should read :
X=PXPR=PXPTH=?XPPH=O.

DCHA014

Line LINE013 in SUBROUTINE LINEAR on page 120 should read :
X=PXPR=PXPTH=PXPPH=O .

LINEO 13

Line PARA012 in ~UBROUTINE QPARAB on page 121 should re?d :
X=P XP R=P XPTH = PXPPH =0 .

PARA012

Following line BULG038 in SUBROUTINE BULGE on page 123, insert the line :
BULG0385
PXPPH=O .
Following line EXPX014 in SUBROUTINE EXPX on page 124, insert the line :
PXPTH=PXPPH=O.
EXPX014S
The equation for the gyro frequency near the top of page 143 should r ead :

F ..
n

= FH. (R 0 I(R 0 + h»3(1 + 3 cos 2g)1/2
o

where 9 is the geomagnetic colatitude .
Line TABZ01S in SUBROUTINE TABLEZ on page 153 should r ead :
IF (READNU . EO.O . ) GO TO 10

TABZ01S

