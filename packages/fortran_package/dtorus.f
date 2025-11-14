INPUT PARAMETER FORM FOR SUBROUTINE DTORUS
A perturbation to an ionospheric electron density model consisting of
two east -west irregularities with elliptical cross sections above the
equator. Since the model is expressed in spherical coordinates and does
not depend on longitude, the perturbation is actually a torus circling
the earth above the equator.
N = No (l + 6 )
6 = C 1 exp { -[

{re + Hl)( 8 - n IZ) cos S + (r - rQ -H1 ) SinS]?
Al

+ C? exp {-[

{rQ+H? )(8 - n /z+ 08 )cosS + {r-ro -~)sinS ]
A?

_[

(r - rQ - H?) cos S - ~:" + H ? )(8 - n Iz + 08 ) sin S

08 = Northward angul<:.r displacement of the lower blob from
the uppe r one

=
rQ

Hl - Ha
tanS (ro + Ha)

is the radius of the earth.

r, 8 , (!) are spherical (earth-centered) pOlar coordinates.
No (r, 8 , (!))

is any electron density model.

Specify:
use perturbation,-:-_ _ _ _ _{,W150 = 1.)
ignore perturbation
(W150 = 0.)
Fractional perturbation ele ctron dell'sity at the center of the upper
blob, C 1 =
(W15l).
That of the lower blob, C? = _______{W15 6) .
Height (above ground) of the center of the upper blob,
Hl =
km (W155) .

lZ9

r}

That of the lowe r blob, H . = _______ km (WI 59) .
Angle (with a ho r izontal suuthward vectur) of the line juining the

blob centers , 9 =

rad (W 1 54) .
- - - - - - - - < !deg

S emi - axis of the upper blob, to the 1/ e perturbation contour , in' the
direction of the Ime joining the blobs, Al =
km (W 1 52).

That of the lowe r blob, A . = _ _ _ _ _ _ _km (WI 57).
Semi-ax is of the upper' blob in the direction normal to the l ine joining
the blobs , B, = _ _ _ _ _ _ km (WI 53).

That of the lower blob, B. =

km (WI 58) .

SUB ROU TINE DTORUS
COMMON ICONS T I PI,PIT2,PI02,DUM(5)
CO MMON IXXI MOQX(2),X,PXPR,PXPTH,PXPPH,PXPT
COMMON R(6) /WW/ IOI IO),WQ ,W (400 1
EQUIVA LENCE IEARTHR,W(21),(Cl.W11511l,(Al,W(15211.(Bl.W(1531),
1
2

IBE TA."" ( 1541 ),CHl.,WI1551 ),(C2, .... C1561) ,(A2,W(157 )) , (B2 .WII S 811.
(H2 ,W I159 1)

DTORDOI
DTOROOZ
DTORO D3
DTOR004
DTOROD5
OTOR00 6

DTOR007
REAL LA MBDA l,LAMBDA2
DTDR008
DATA (MODX(ZJ =6HDT ORUSI,IPDPP=O.1
DTOR009
ENTRY ELECT!
DTOROIO
IF IX.EQ.O •• AND.PXPR.EQ. O•• AND.PXPTH.EO.O •• ANO.PXPPH.EO.O.J RETURNDTOROIl
[F 1(1 . £0 . 0 .J RETURN
DTOR012
R1=EARTHR+H1
DTOR013
R2=EAR THR+H2
DTORD14
Zl =Rlll - Rl
DTORD15
Z2 =Rfll - R2
DTOR016
LAMBOAl =Rl *(R(2 1-PI02J
DTOR017
LAMB DA2 =R2*(R(2J -PI0 2+(HI-HZ1/RZ/TANF(BETAJ)
DTOR018
S INBET:SINfB ETA l
DTOR019
COSBET =COS(SE TAl
DTO R020
Pl =L AMBDAl*COS BET+Zl*SINBE T
DT OR021
P2=LAMBDA2*COSBET+ZZ*SINBET
DTOR02Z
Yl=Zl*COSB ET-LAMBDA1*SINBET
DTOR DZ3
Y2 =Z Z*COSB ET-LAMBDAZ*SINBET
DTORDZ4
DEL TAl= (1* EXP(-(Pl/AlJ**Z- (Y l / B11**Z)
DTOROZ5
DELTA2=C2*EXP( -( PZ/A2 1 **2-(Y2/BZ1**Z)
DTORDZ6
DEL1=1.+DE LT A1+DELTA2
DTORD27
PDPRl~ -Z.*DELTAl*(Pl*SINBET /A l**2+Yl*COSBET/Bl**Z)
DTORDZ8
POPR2= - Z. *OELTA2*(P2*SINBET/AZ**Z+YZ*(OSBET/BZ**Z)
DTORD29
POPT l =- Z.*OE LTAl*(Pl*Rl* COSBE T/Al**Z- Yl*Rl*SINBET/Sl**2)
DTOR030
P OPT 2= ~Z .*DELTA2*(P2*R2*COSBET/A2**2 - Y2*R2*SINB ET /B2** 21
DTOR031
PXPR=PXPR*OEL l+X*(P DP Rl+ PD PRZ J
DTORD3Z
PXPTH=P XP TH*OELl+X*(PDPTl+PDPTZ)
DTOR033
PXPPH =PXPPH*DELl*POPP
DTDR034
X=X* OELI
DTOR035
RETURN
DTORD36
END
DTOR 037 -
