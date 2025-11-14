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
