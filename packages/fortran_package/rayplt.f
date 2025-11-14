SUBROUTINE RAYPLT
main deck
SUBROUTINE PRINTR
SUBROUTINE POLCAR
SUBROUTINE REACH
SUBROUTINE BACK UP
SUBROUTINE TRACE
SUBROUTINE READW

~

A

PROGRAM NITIAL

Figure 3 .

Program deck set - up

40

10.

INPUT

T he input data for a ray tracing program divide themselves
naturally into two groups:
First, data that control the type of ray trace requested, such as
the transmitter location and frequency, plus parameters describing
analytic models of the ionosphere .

Since there are few of these,

efficiency in packing such data can be exchanged for versatility and
ease of data handling.

Therefore, by putting only one piece of data on

each card, we gain the convenience s of reading in the se data in any order
and of having the program read in only those data that are different
from those of the previous case.

A number in the first three columns

of each card identifies the data being read in.

Table 2 defines the

identifying numbers that are subscripts for a linear array, W

The

last 56 columns of the card are available for comments.
We have also provided a method for conversion of units for input.
The computer program needs allgles in radians, whereas people usually
like to use angles in degrees.

The program is set up f()r angles in radians,

but putting a "1" in column 18 allows the user to enter the angle in degree s
and have the program make the conversion.

A" 1" in column 19 allows

the user to enter central earth angles as the great circle distance along
the ground in kilometers.

(The program will calculate the latitude of a

transmitter which is 500 km north of the equator, for instance.)
program expects d i stances in kilometers .

The

A" 1" in column 20 indicates

a distance in nautical miles, and a "1" in column 21 indicates a distance
in fe et.
Appendix 8b contains a sample of how the cards are to be punched.
If two or more cards have the same identifying number, the last one

dominates.

A card with the first three columns blank indicates the end

of this type of data cards.

41

Table 2.
WI
W2':'
W3
W4
W5
W?
W8
W9

Wll
WI2
WI3
WI5
WI6
WI?
W20
W2I
W22'~

W23*
W24'~

W2S*
W4 I *

W42i,(

W43"
W44i~

W45"
W46';
W47~f.

W5?
W58
W59

w60
W71
W72
W8I

W82-S8
WIOO-I49
W ISO-I99
W200-249
W2S0-299

Description of the Input Data for the W Array

= 1. for ordinary ray
= -1. for extraordinary ray
Radius of the earth in km
Height of transmitter above the earth in km
North geog raphi c latitude of the transmitter
East geographic longitude of the transmitter
Initial frequency in MHz
Final frequency in MHz
Step in frequency in MHz (zero for a fixed frequency)
Initial azimuth angle of transmis sion
Final azimuth angle of transmission
Step in azimuth angle of transmis sion (zero for a fixed azimuth)
Initial elevation angle of transmission
Final elevation angle of transmission
Step in elevation angle of transmission (zero for a fixed elevation)
Receiver height above the earth in km
Nonzero to skip to the next frequency after the ray has penetrated
the iO:l.Osphe.re
Maximum number of hops
Maximum number of steps per hop
North geographic latitude of the north geomagnetic po~e
East geographic longitude of north geomagnetic pole
=1. for Runge-Kutta integration
=2. for Adams-Moulton integration without error checking
=3. for Adams -Moulton integration with relative error check
=4. for Adams - Moulton integration with absolute error check
Maximum allowable- single step error
Ratio of maximum singl e step error to minimum single step error
Initial integration step size in km (step in group path)
Maximum step length in kIn
Minimum step length in km
Factor by which to increase or decrease step length
=1. to integrate, =2. to integrate and print phase path
=1. to integrate, =2. to integrate and print absorption
=1. to irl:~~grate, =2. to integrate and print doppler shift
=1. to integrate, =2. to integrate and print ·path length
Number of steps between periodic printout
Nonzero to pWlch raysets on cards
=0. to not plot ray path
=1. to plot projection of ray path on a vertical plane
=2. to plot projection· of ray path on the ground
Parameters used "When plotting
Parameters for analytic electron density models
Parameters for perturbations to electron density mode ls
Para.meters for analytic magnetic field models
Parameters for analytic collision frequency models

*These values have been initialized in the main program but may be reset by reading
them in. See Appendix lb for the initial values.

42

A second group of input data cards are necessary if nonanalytic iono spheric models such as the electron density profile defined by subroutine
T ABLEX or the collision frequency profile defined by subroutine T ABLEZ
are used.

Each subroutine defining a nonanalytic ionospheric model reads

in data cards according to a format defined in that subroutine.
ment in the W ar r ay controls the reading of these cards.

An ele-

(See table 2. )

Figure 4 shows the order in which these data cards should be arranged.
11 . ACCURACY

The numerical integration subroutine has a built-in mechanism to
check errors and adjust the integration step length accordingly.

If

the errors get larger than a maximum specified by the user, the routine
will decrease the step length in order to maintain the accuracy.

On the

other hand, if the accuracy is greater than that required by the user,
the routine will increase the step length in order to reduce the computing cost.

The user specifies the desired accuracy in W42 (see

table 2).

W 42 is the maximam allowable relative error in any single

step for any of the equations being integrated.

To get a very accurate
_5

(but expensive) ray trace, one can use a small W 42 (about 10

_6

or 10

).

For a cheap, approximate ray trace, one should use a large W 42
(10-

3

or even 10 -

2

).

For cases in which all of the variables being inte-

grated increase monotonically, the total relative error can be guaranteed
to be less than W42.

Otherwise, the total relative error cannot be

easily estimated.
T he far left column of the printout from the ray path calculation
gives an indication of the integration error in the magnitude of the vector
which points in the wave normal direction.

Although the calculation of

this error is made independently of the error calculation in the numerical integration routine, we have found that except near reflection for vertical or near vertical incidence this error is usually of the same order

43

etc./

CARD

TITLE CARD

A card with the first three CO,lU<nlnS',,"
bl ank to indicate th e end of data

DAT A
the W ARRA y, one per
car d as shown in Appendix 8b .

This may be repeated
as often as necessary.

TITLE CAR D,

Figure 4 .

Data deck set - up.

44

of magnitude as that specified in W42.

We have found that whenever

this error has exceeded W42 by several orders of magnitude, the electron density subroutine we had written was calculating a gradient of
electron density inconsistent with the spatial variation of electron
density being calculated.

See the general description of electron

density models in Appendix 3a for more information.
12.

COORDINATE SYSTEMS

The program uses two different spherical polar coordinate
systems, namely, a geographic and a computational coordinate system.
Input data for the coordinates of the transmitter (W4 and W 5) and input
data for the coor din ate s of the north pole of the computational coordi_
nate system (W24 and W2 5) are entered in geographic coordinates.
(Putting W25 equal to O' and W24 equal to 90· would superimpose the
two north poles and equate the two coordinate systems. )
When the two coordinate systems do not coincide, the three types
of ionospheric models calculate electron density, the earth's magnetic
field, and collision frequency in terms of the computational coordinate
systerrl.

In particular, the dipole model of the earth's magnetic field

uses the axis of the COrrlputational coordinate systerrl as the axis for the
dipole field.

Thus, when using this dipole model, the COrrlputational

coordinate systerrl is a georrlagnetic coordinate system, and both electron density and collision frequency must be defined in georrlagnetic
coordinates.

Dudziak (1961) describes the transformations between

these coordinate systerrls.

45

13.

HOW THE PROGRAM WORKS

This ray tracing program consists of various subroutines that perform specific tasks in calculating ray paths.

This division of labor

facilitates modifying the program to solve specific problems.

Often it

may be necessary to change only one or two subroutines to convert the
program to a different uSe.
The main program (NITIAL) sets up the initial conditions (transmitter loc ation, wave frequency, and direction of transmission) for
each ray trace.

In setting up the initial conditions for each ray trace,

the main program (NITIAL) steps frequency, azimuth angl e of transmission, and elevation angle of transmission.

The details of the workings

of NITIAL can be found in the flow chart in figure 5.

Then subroutine

TRACE calculates one ray path for the requested number of crossings
of the specified receiver height.
ray tracing program.

Subroutine TRACE is the heart of the

It is the most complicated subroutine included,

but also the most important to understand.

The flow chart in figure 6

should help to expl ain TRACE.
Subroutine RKAM integrates the differential equations numerically
using an Adams -Moulton predictor - corrector method with a RungeKutta starter.

Subroutine HAMLTN evaluates the differential equa-

tions to be integrated.

Sub routine RIND E X calculates the phase refrac-

tive index and its gradients, the group refractive index, and the polarization.

(Eight versions of subroutine RINDEX are included.) Subroutines

ELECTX, ELECT!, MAGY, and COLFRZ calculate the ionospheric
electron density, perturbations to the electron d ensity (irregularities),
the earth's magnetic field, and the electron collision frequency, respectively.

Several versions of these four subroutines are included and it

is easy to add more.

Subroutine REACH calculates a straight-

line segment of a ray path in free space between the earth and the

46

I

I

~nil'OI;lO"On

'0
Ho~e

In,holile

..

, W-o"oy ,ead

SeT conslan Ts

The W -or<oy

I

'"

onoles of I.ansm,nion 10 zero
meons n<) per iOdic prinlinql
Mo"e sure IRAYI . , ( +, 1o. ordinary, · 1 10' Ulroordino. y 1
Set NT YP (.1 10< e~l,oQ'dino'Y, • 2 IQf no fi eld . ' :3 for ordingry I
$olle the nome of . he electron densiTy pe.lu.baljor, model
W150 is ze.o, Ind,eoTe no pertu,botion

SeT the f,equency, Ilel/aloOf! ond azimuTh

II W71 '5 lero. fe T iT 10 W23 (Ih"

..

" ,

PunCh on COtCS The
W-orroy

P"nl

W-orroy 10'

some at The IOnosptumc PG.omele.,

LeI sub'oulmes PRINTR ond RAYPLT ~nQ" The.e ,$ 0 ne w W -O HOy
In",oh ze ~"'omelers 10' Integrotion subrOU Tine RKAM
DetermIne T,o nsm, I'e ' loca Tion In com~ulo T lOnol coordinote sySTem
Ca lculate The numbe. of fr eQuenc ies . azimuth onqles, and ele llOll(ln
onQ les . eQues ted

SeQ ln Irequeney loop
Begon Ol,muth angle loop
rrse9,n elevoli on on91e loop
!"'t,a lia Ihe 'ndependent variable ond Ihe li ',~1 6 de pe ndent in le9 'otion va. iab le s
Sel RSTART ( Ie ll subrou line RKA M 10 slarl ,nl e""ot,on )

.

,

Is '!'ws thelN'St elev 0t'I91e?
~

How ",e olreQdy pronle<l3royson Ih<s page?

I
I , .. oh, "om'.. 0' " " ~'"'" 00 , . , 00"

"

Hove 'M! prlnled more thon
17 lines an n'l 's

po,"'
25

No

\ Inc.eases lhe number 01 .oys p",nted on Ih,s page by one
Pr,nt the elevation Qnqle 01 "on,m"s_

~

,,,

I H~,
' " plO$lTlO
, .. ,,""f.eQuency
doe,'"~ ,,''"'''''
P.int the
ond 0
I meSSQge lhal Ihe .oy 's ,n Qn

evonescenl r : oon?

'0

evenescen' .eglon

Normolile the Ih.ee comPQnenl!, QI Ihe wove no.mol di.ection so Ihat oh,
magnilude equals Ihe .ef.act,ve indu
Inilia li ze lhe .esl of Ihe depende nl inleg.o l ic n varicbln
one roy PClh COlculQ le d
Calculale ond pr int M oo long it taa~ to colcuto le Ihat .ay pa th

",,'

Dod 'he.oy
penel.o'e 00 Ihe h,s' hop

'"'

Do we only won' r'(lnpenelrot,ng rays?

..

,

No

'0

No

LoS! elevoloen on",l. ?

-r

"

Yes

\ Termlnote III'S . oy polh pial

No

"

...L

91oc~

numbers correspond
p"OQrcl'l'l sia lemen' numDers

Losl cZ,muth cnQle?

"

",
I)d 'he roy
Irate on!he hrs! 1'Op"
0",

Do we only wo n I non-pen" r o l' n~ rays?

'"'

.

,

A. e we os~on", lor only one
mnulll onQI. and one
ele\' angl.?
No
No

"

'0
Los! freQuency"

.. .. Tyes

, ,

Punch 0 cc.d ,i9 nclin",
of Ihe roysels 10. Ih ,s W-orray
RestOfe the nome 01 the elect.on den" Iy ~e. tu.bal"m modoe l in MOOX\2)

Figur e 5.

I

Flow chart for program NITIAL.

47

"""j

the number of I,nes pr,nted on til,s page 10lero
ISel
Pront a page head 'nQ. lhe frequency. and
the aZlmulh a ng le o f Ircnsm,ss,an

I

In,Mh,. NHOP. tl.A.X ,N SI<.I p. RSTART
\HOP. HTM fIo X. NEWRAY. THERE

Call H:.M LTON lca lc"'o'e o"""a'''H)
(al'"lOIe HOME (~' '''' a ... ay I,om
'O"Ce,ye' he'9"')
p"n'. p.mc~ )M TR

RETURN

Pici a ,ey po, n'

",

I_____________C"~O"~,.OO"'~____________________C"~O~C;~

-'==-'F",-,-,-~r

~.. I>o~

" Y

I ~'HO M E I

I
I

A"h'~

So.., "" "",a"on "'"obl.. e. wIVal,.."

-0

'h.

Y.'~60

On

9'0""0 1

5., WAS 1'0 '."'.mbe, THERE I
Call RKA M
Co1c" 'a,. H
5 .. THERE '0101 ••
S., WASNT 1'0 , • ......."b., HOME I
Calcu lo,o HOME
Calcu la,. SMT ( .."ma'. of "",toca l
d .. 'cnce to nee,." apogee 0<

f;c. 'he ,oy

...

I

I

~

",

".,*"

"""""o,.~ 'he
,,,"o<p.hc,. ?

Y'~t8\

(THERE)

' ..:. ".' heo;M"

79

'" P""C~

. '$;. P(N[T

I P"nl.

P EN ETRAT

~~
R(TUR

alo<~ numb. "

ce,,"POnd 'o<lO"mOn'
O\JmOe., 'n the "'~',,""n.

Figure 6.

Flow cha rt for subroutine TRACE .

T he ray graphics illustrate the path of a ray during a single step.
48

ionosphere or between ionospheric laye rs.

Subroutine BACK UP finds

an intersection of the ray with the receiver height or with the ground.
Subroutine PRINTR prints information describing the ray path and
punch e s the r esults on cards (rays ets ).
ray path.

Subroutine RAYPLT plots th e

The block diagram in figure 7 shows the relationship among

these (and other) subroutines.
Th e listing s of most of the subroutines have comments that should
help in understanding how they work.

In addition, Tables 3 through 14

define the variables in the common blocks.
14.

ACKNOWLEDGMENTS

Part of the organization of this program into subroutin es follows
that of the program of Dudziak (1961), in particular for subroutines
RKAM, HAMLTN

,RINDEX, ELECTX, MAGY, and COLFRZ.

Also,

the coordinate transformation in subroutine PRINTR and the method for
data input via th e W array are taken from th e program of Dudziak (1961).
The term "rayset, II the idea of punching results of each hop for each
ray trac e onto cards, and the idea of automatically plotting r ay paths
come from the program of Croft and Gregory (1963).

The quasi-parabolic

lay e r electron density model QPARAB is taken from the pap e r by Croft
and Hoogasian (1968).

Notice that the quasi-parabolic laye r that is

now in the program is slightly different from the one in the program of
Jones (1966).

Subroutin e RKAM is a modification of subroutine RKAMSUB,

which was written by G. J. Lastman and is available through the CDC
CO -OP library (the CO-OP identification is D2 UTEX RKAMSUB). Subroutine GAUSEL was written by L. David L ewis, Spac e Environm ent
Laboratory, National Oceanic and Atmospheric Administration.

Sub-

routine FSW was written in conjunction with Helmut Kopka of the MaxPlanck-Institut fUr Aeronomie, Lindau/Ha rz, Germa ny.

49

PR OGRAM

NITIA L

Sets conston ts
Initlollzes the W-orroy
Decides when to read dolo In l O the W-o rroy
Resets some of the W -orroy
Punches some of the W-o rroy (ionospheric
parameters) on cords
Prints the W- orroy
Sleps frequency, azimuth angle of transmission
and elevation angle of transmiSSion

H

Reads Input dolo mto the W -array

Sets the miliol condi tions for eoch roy Iroce

Plots a pomt of the roy poth.

!

Pnnts a line describing a

,

SUBROUTINE TRACE

pOlO! on the ray path

Punches roy se ' s
Prints column headings

t

Calculates one ray path from the Initial condl'lons ~I-----.J
specified by PRCXJRAM NITIAL for the
number of hops requested.

t

SU BR OUTINE REACH

SUBROUTINE RKAM

In teg rat es one step of the
differential equa tions
each lime It IS calle d.

l-

o

1

ISUBROUTINE POL CAR

Calcula tes the poSiti on of a POint a t a given
dis tance and direction from on 11'111101 pOint
Conve rt s the pos I lIOn of and direction at that
paint from car tesian coordinate s to spherical
polar coordinates

I--

Draws axes and calls for labelIng and termination of plot.

ENTRY GRAZE
Finds the nearest POint where the
ray makes a closest app r oach
to the receiver height

SUBROUTINE HAMLTN

L~

ENTRY CA R t-'UL

ENTRY ENDPLT

Fmds the nearest pOint where the
ray cr osses the re ce ive r height

~

Converts pOSllion and direction from spherical
polar coordinates to corte slon coordinates

L - - -__>-jl

SUBROUTINE BACK UP

Calcula tes the straight Ime roy path l---m a non-devlatlve non - absorbmg
region between any two of the
follOWing ; the ear th, on ionospheriC loye r, the receiver heigh t ,
e closest approach to the receiver
height, a perigee.

U>

I

SUBRO UTINE RAYPLT

Prints page headings

SUBROUT INE PRINTER

l

SUBROUT IN E REAOW

Evaluates the diffe r ential
equa tions to be mt egra ted

,

SUBROUTINE PLOT
A general plaiting routine which
In ter pola tes between pomts Iymg
outside the plolling ar ea

ENTRY PLTEND
Terminates a plot.

SU BROUTINE LABPL T

SUBROU T INE RINDEX
Evaluates the phase refrac tive mdex,
ItS gradient, the group re f ractive
Index, and the potorrzallan

Labels the raypath pla l s

L

SUBROUTINE ELECTl
Calculates a perturbation 10
on p.le<.trnn denSit y model

Figur e 7 .

Calcula tes the elec tron denSity
and li s gradlenl

I SUBROUTINE MAGY

Calculates the ear th:s magnetic
field and lIs grad,cn1.

B lock diagram for t h e r ay tracing program.

SUBROUTINE COLFRZ
Calculates the ColliSion f r equency
and lis gradien t

Table 3.
Position in
C o mmon

Definitions of the Para meters in Blank Common
Variabl e
Name

Definition

1-20

R

The d e p endent varia bles in th e differ ential e quations being integ rate d-th e d e finitions of th e first six ar e
fix ed, but th e oth e rs m ay be v a ri ed
by the program us e r.

1

R( 1)

r

2

R(2)

e

3

R( 3 )

cp

4

R(4)

k

5

R(5)

ke

6

R( 6)

k

7 -12

R(7)-R( 12)

13 -20

R( 13)-R(20)

Res e rve d for futur e expa nsion.

21

T

Group p a th in kilometers (th e ind e pend ent va riabl e in th e diffe r ential
e qua tion s ) .

22

STP

St e p l ength in group path.

2 3 -42

DRDT

Th e d e rivative s of the d e p end e nt
variabl e s w ith r e sp e ct to the ind epend ent va riable T.

r

cp
Thos e variabl e s th e us e r has c hos e n
to inte grate, t a k e n in the foll owing
ord e r:
P -phas e path in kilom et e rs
A -absorption in d e cibel s
M -Doppl e r shift in hertz
s - geo metric a l p a th l en g th in kilo met e rs

Rand T a r e initializ e d in pro g r a m NITIAL a nd cha n ged in subroutin e s
RKAM, REACH, and BACK UP.
STP is c a lculated in subroutin e RKAM.
DRDT is calculated in subroutine HAMLTN
RKAM.
51

and us e d in subro utine

Table 4.

Definitions of the Parameters in Common Block / CONST /

Positiotl itl
Commotl

Variable
Name

Definition

1

PI

TT

2

PIT2

2TT

3

PID2

TT/2

4

DEGS

180.0/TT

5

RAD

TT/ 180.0

6

K

7

C

Ratio of the square of the plasma
frequency to the electron density in
MHz 2 cm 3 = r c2/TT = e 2 / (4TT2 € m).
where r is tfi'e classical elect:?'on
radius, a c is the fre e space speed of
light, e is the charge on the electron,
m is the mass of the electron, and
€
is the capacitivity of a vacuum.
a
Fre e space speed of light in km / s ec .

8

LOGTEN

log

e

10

These parameters are set itl pro gram NITIAL .

52

Table 5.

Position in
Common

Definitions of the Parameters i l l Common Block /RK/

Variable
Name

Definition

1

N

The number of equations being
integrated.

2

STEP

The initial step in group path in
kilometers.

3

MODE

Defines type of integration used
(same as W41), see Tabl e 2.

4

EIMAX

Maximum allowable single step
error (same as W42).

5

EIMIN

Minimum allowable single step
error (= W42/W43).

6

E2MAX

Maximum step l ength (same as W45).

7

E2MIN

Minimum step·length (same as W46).

8

FACT

Factor by which to increase or de creaSe step length (same as W47).

9

RSTART

Nonzero to initialize numerical integration, zero to continue integration.

These parameters are calculated in program NITIAL (some are
temporarily reset in subroutine BACK UP) and are used in subroutine
RKAM.

53

Table 6.

Definition of the Parameters in Common Block IRINI

Postion in
Common

Variable
Name

1,2,3

MODRIN

Description of ve rsion of RIND EX in
BCD.

4

COLL

= 1 if this version of RINDEX in-

Definition

cludes collisions, = 0 otherwise.

5

FIELD

= 1 if this version of RINDEX includes the earth's magnetic field,
= 0 otherwise.

6

SPACE

TRUE, if the ray is in a nondeviative, nonabsorbing medium.

7,8

KAY2

k 2 , square of the complex phase
2
•
refractive index times w2

Ic

9,10

H

Hamiltonian (complex)

11, 12

PHPT

13 , 14

PHPR

15, 16

PHPTH

17, 18

PHPPH

19,20

PHPOM

oH/ot (complex)
oH/or (complex)
oH/oe (complex)
oH/oc:p (complex)
oH/ow (complex)

21,22

PHPKR

oH/ok

23,24

PHPKTH

25,26

PHPKPH

27,28

KPHPK

oH/oke (complex)
oH/ok (complex)
~
c:p ~
k . oH/ok (complex)
= k r oH/okr + k eoH/ok e + k c:p oH/okc:p

29,30

POLAR

r

(complex)

Characteristic polarization of the
wave; equal to the ratio of the component of the electric field perpendicular with the earth's magnetic
field to the transverse component of
the electric field parallel with the
earth's magnetic field (complex)
(Budden, 1961, p. 49, eq. (5. 13)}.

54

Table 6.

position in
Common

Variable
Name

(Continued)

Definition

31,32

LPOLAR

Characteristic longitudinal polariza tion of the wave; equal to the ratio of
the longitudinal component of the
electric field to the component of the
electric field perpendicular with the
earth's magnetic field. (complex)
Budden, 1961, p. 54, eq. (5.38}).

33

SGN

= +1 or -1; used for ray tracing in
complex space.

These parameters are calculated in subroutine RINDEX and used in
subroutine HAMLTN.
Note: In some subroutines, the real and imaginary parts of the com plex variables have separate names.

55

Table 7.

Position in
Common
1

Definitions of the Param e ters in Common Block /F LG /
(Se e Subroutin e TRACE)

Variable
Name

Definition

NTYP

= 1 for extraordinary, = 2 for no
field,
= 3 for ordinary

2

NEWWR

Set equal to . TRUE. to t e ll subroutine RAYPLT th e r e is a new W
a rray .

3

NEWWP

S e t equ a l to . TRUE. to t e ll subroutine PRINTR there is a new W
array.

4

PENET

Set equ a l to . TRUE . if th e ray just
penetrat ed .

5

LINES

Numbe r of lin es printed on the cu rrent page .

6

IHOP

Hop number ( at the beg inning of e ach
r ay, subroutine TRACE sets this
paramet e r to ze ro so that subroutine
RAYPLT w ill begin a n ew line in
plotting th e r ay path a nd subroutine
PRINTR w ill print column h ead ings
a nd punc h a transmitt e r r ay set).

7

HPUNCH

The height to be punc h e d on th e raysets.

56

Tabl e 8.

Position in
Common

Definitions of the Parameters in Common Block /XX/

Variable
Name

D efinition

1

MODX( 1)

BCD name of th e electron density
sub routine.

2

MODX(2)

BCD n ame of th e subroutine defining
a p e rturbation to the e lectron density
model.

3

x

X in Appleton -Hartree formul a,
squar e of the ratio of the plasma
frequency to the wave frequency.

4

PXPR

or

5

PXPTH

6

PXPPH

7

PXPT

8

HMAX

0X

oX

oG

oX
ocp
oX

ot

wh e r e t is time; used for calculating Doppl e r shifts .

H e ight of maximum e l ect ron d e nsity.

Th ese parameters are calculated in subroutine ELECTX, possib l y
modified in subroutine ELECTl, and are mainly used in subroutine
RlNDEX.

57

Table 9.

Position in
.Common

Definitions of the Parameters in Common Block /YY /

Variabl e
Name

Definition

1

MODY

BCD name of the subroutine defining
the earth's magnetic field.

2

Y

Y in the Appleton-Hartree formula,
ratio of the e l ectron gyrofrequency
to the wave frequency.

3

PYPR

oY
or

4

PYPTH

oY
08

5

PYPPH

oY
oql

6

YR

Y , proportional to the component of
th';, earth's magnetic field in the r
direction.

I•

oY

r
or

7

PYRPR

8

PYRPT

9

PYRPP

r
Oql

10

YTH

Y

11

PYTPR

12

PYTPT

oY

r
08

oY

8

oY 8
or
oY

8
08

58

Table 9.

(Continued)

position in
Common

Variable
Name

13

PYTPP

14

YPH

Y

15

PYPPR

~

16

PYPPT

~

17

PYPPP

---'E
ocp

Definition

cp

oY
or
oY
09

oY

Th ese parameters are calculated in subroutine MAGY and are mainly
us ed in subroutine RIND EX .

59

Table 10.

Position in
Comtnon

Definitions of the Parameters in Common Block /ZZ/

Variable
Name

Definition

1

MODZ

BCD name of the collision frequency
sub routine.

2

Z

Z in the Appleton-Hartree formula,
ratio of the electron -neutral collision
frequency to the angular wave frequency.

3

PZPR

4

PZPTH

5

PZPPH

oZ

or

oZ
09

oZ
o<;p

These parameters are calculated in subroutine COLFRZ and are mainly
used in subroutine RIND EX.

60

Table 11.

Position in
Common

Definitions of the Parameters in Common Block /TRAC/

Variable
Name

Definition

1

GROUND

· TRUE. if the ray is on the surface
of the earth.

2

PERIGE

· TRUE. if the ray has just made a
perigee.

3

THERE

· TRUE. if the ray is at the receiver
height.

4

MIND IS

· TRUE. if the ray has just made a
closest approach to the receiver
height.

5

NEWRAY

Set equal to . TRUE. to tell subroutine REACH that this is a new
ray.

6

SMT

An estimation of the vertical distance
to an apogee or perigee of the ray.

These parameters are used for communication between subroutine
TRACE and subroutines REACH and BACK UP.

Table 12.

Position in
ComITIon

1

Definition of the Parameter in Common Block /COORD/

Variable
Name
S

Definition
The straight line distance along the
ray from the position of the ray
where REACH was called to the present
position.

This parameter is used for communication between subroutine REACH
and subroutine POL CAR.

61

Table 13.

Definitions of the Parameters in Common Block /PLT/

Position in
Common

Variable
Name

1

XMINO,XL

The x coordinate of the left side of
the plotting area in kilometers.

2

XMAXO,XR

The x coordinate of the right side of
the plotting area in kilometers.

3

XMINO, YB

The y coordinate of the bottom of the
plotting area in kilometers.

4

YMAXO, YT

The y coordinate of the top of the
plotting area in kilometers.

5

RESET

Set equal to one whenever the plotting
area is changed.

Definition

These parameters are used for communication between subroutine
RAYPLT and subroutine PLOT.

62

Table 14.

Position in
Common

Definitions of the Parameters in Common Block /DD/

Variable
Name

Definition

1

IN

Intensity.
IN = 0 specifies normal intensity.
IN = 1 specifies high intensity.

2

IOR

Orientation.
lOR = 0 specifies upright orientation.
lOR = 1 specifies rotated orientation
(90 0 counterclockwise).

3

IT

Italic s (Font).
IT = 0 specifies non-Italic (Roman)
symbols.
IT = 1 specifies Italic symbols.

4

IS

Symbol size.
IS = 0 specifies miniature size.
IS = 1 specifies small size.
IS = 2 specifies medium size.
IS = 3 specifies large size.

5

IC

Symbol case.
IC = 0 specifies upper case.
IC = 1 specifies lowe r case.

6

ICC

Character code, 0 - 63 (R1 format).
ICC and IC together specify the
symbol plotted.

7

IX

X -co ordinate, 0 -102 3.

8

IY

Y -coordinate, 0 -1023.

63

We also want to thank those who have used our program and have
pointed out errors or made suggestions.

In particular, we are grate -

ful to Dr. T. M. Georges of the Wave Propagation Laboratory, National
Oceanic and Atmospheric: Administ ration, for his suggestions resulting
from extensive use of the program, for development of some of the
ionospheric models (DCHAPT, DTORUS, WAVE, WAVE 2). and for
financing part of the development of ray tracing through a spitze.
Examples of us e of the ray tracing program are shown in the
reports by Stephenson and Georges (1969) and Georges (1971).
15.

REFERENCES

Bennett, J. A. (1967), The calculation of Doppler shifts due to a
changing ionosphere, J. Atmosph. Terr. Phys. ~, p. 887.
Budden, K. G. (19 6 1), Radio Waves in the Ionosphere; the Mathematical Theory of the Reflection of Radio Waves from Stratified Ionized
Layers (University Press, Cambridge, England).
Budden, K. G., and G. W. Jull (1964). Reciprocity and nonreciprocity
with magnetoionic rays, Can. J. Phys. 42, p. 113.
Budden, K. G ., and P. D. Terry (1971), Radio ra y tracing in complex
space, Proc. Roy. Soc. London A. 321, p. 275.
Cain, Joseph C. and Ronald E. Sweeney (1970). Magnetic field mapping
of the inner magnetosphere, J. Geophys. Res. li, pp. 43 60 -43 6 2.
Cain, Joseph C., Shirley Hendricks, Walter E. Daniels, and Duane C.
J ensen (1968), Computation of the main geomagnetic field from
sphe rical harmonic expansions, Data users' note NSSDC 68-11
(update of NASA report GSFC X - 61 1- 64 -31 6, October 1964).
National Space Science Data Center, Goddard Space Flight Center,
Code 60 1, Greenbelt. Maryland 20771.
Chapman, Sydney, and Julius Bartels (1940), Geomagnetism, (Clarendon
Press, Oxford, England). pp. 609-611. 637-639.

64

Croft, T. A., and L. Gregory (1963) , A fast, versatil e ray - tracing
program for IBM 7090 digital compute r s, Rept. SEL - 63 -1 07 (TR 82,
Contract No. 225( 64), Stanford Electronics Laboratori es, Stanford,
California.
Croft, T. A. and Harry Hoogasian (1968), Exact ray calculations in a
quasi - parabolic ionosphere with no magnetic f iel d, Radio Science ~,
1, pp. 69 - 74.
Davies, Kenneth (1965), Ionospheric radio propagation, NBS monograph
80.
Dudziak , W. F. (1961), Three - dimensional ray trace computer program
for electromagnetic wave propagation studi es, RM 61 TMP - 32, DASA
1232 , G. E. TEMPO, Santa Barbara, California.
Eckhouse, Richard H., Jr. (1964), A FOR TRAN computer program for
determining the earth's magnetic field, report , Electrical Engineer ing Re search Laboratory, Engineering Experiment Station, University
of Illino is, Ur bana, Illinois.
Georges, T . M. (1971), A program for calculating three-dimensional
acoustic - gravity ray paths in the atmosphere, NOAA Technical
Report ERL 212 - WPL 16.
Haselgrove, J. (1954), Report of Conference on the Physics of the
Ionosphere (London Physical Society), p. 355.
Jones, Harold Spencer, and P . F. Melotte (1953), The harmonic analysis of the ear th's magnetic field, for epoch 1942, Monthly Notices of
the Royal Astronomical Society, Geophysical Supplement, ~, p. 409.
Jones, R. Michael (1966), A three-dimensional ray tracing computer
program, ESSA Tech . Rept, IER 17 - ITSA 17.
Jones, R. Michael ( 1970), Ray theory for lossy media, Radio Science .?'
pp. 793-801.
Lighthill, M. J. (1965), Group velocity, J. Institute of Mathematics
and Its Applications .!.' p. 1.
Sen, H. K., and A. A. Wyller (1960), On the generalization of the
Appleton - Hartree magnetoionic formulas, J. Geophys. Re s. 65,
pp. 3931-3950.

65

Stephenson, Judith J., and T. M. Georges (1969), Computer routines
for synthesizing ground backscatter from three -dimensional raysets,
ESSA Tech. Rept. ERL 120-ITS 84 .
Suchy, Kurt (1972), Ray tracing in an anisotropic absorbing medium,
J . Plasma Physics ~, Pt. 1, p. 53.

66

APPENDIX 1.
LISTINGS OF THE MAIN PROGRAM AND
SUBROUTINES IN THE MAIN DECK
T his appendix contains listings of the m.ain program. and those subroutine s that have only one version (with the exception of subroutine
RAYPLT, which has a do - nothing version for users lacking a plotter to
plot ray paths).

Thus, the routines which form. the contents of this appen-

dix will be used in all ray path calculations.
Additionally, this appendix contains the m.ain input param.eter form.
for ray tracing and the input param.eter form.s for plotting.

These form.s

are very useful when using the program. because they indicate the input
parameters needed for ray path calculations
The contents of this appendix are arranged as follows:
a.

Main input param.eter form.

68

b.

Program. NITIAL

69

c.

Subroutine READ W

72

d

Subroutine TRACE

72

e.

Subroutine BACKUP

74

f.

Subroutine REACH

76

g.

Subroutine POLCAR

77

h.

Subroutine PRINTR

78

i.

Input param.eter form.s for plotting

82

j.

Subroutine RAYPLT

84

k.

Subroutine PLOT

86

1.

Subroutine LABPLT

87

m..

Subroutine RKAM

88

n.

Subroutine

90

HAMLTN

67

INPUT PARAMETER FORM
FOR THREE-DIMENSIONAL RAY PATHS
Name

- - - - - - - - - - - - Project No. ----- Date- - - - -

Ionospheric ID (3 characters) _ _ _ __
Title (75 characters)
Models:

Transmitter:

Receiver:

------------------------------------

Electron density
Perturbatio:l
Magnetic field
Ordinary
Extraordinary
Collision frequency

+ 1.)
-_
- (Wl=
__
(WI - - 1.)

Height
Latitude
Longitude
Frequency, initial
final
step
Azimuth angle , initial
final
step
Elevation angle, initial
final
step

Height

Penetrating rays:

_ _ _ _ krn, nautical miles, feet (W3)
_ _ _ _ rad, deg, km (W4)
_ _ _ _ rad, deg, km (W5)
_ _ _ _ MHz (W7)
(W8)

(W9)
_ _ _ _ rad, deg clockwise of north (W 11)
(WI2)
(WI3)
_ _ _ _ rad, deg (WI5)
(WI6)
(WI7)
_ _ _ _ km, nautical miles, feet (W20)
_ _ _ (W21 = 0,)
_ _ _ (W21 = 1.)

Wanted
Not wanted

Maximum number 0: hops

_ _ _ (W22)

Maximum number of steps per bop

_ _ _ (W23)

Maximum allowable error per step

_ _ _ (W42)

::: 1. to integrate

Addition.al calculations:

::: 2. to integrate and p:-:int
_ _ _ (W 57)

Phase path
Absorption
Doppler shift

_ _ _ (W58)

_ _ _ (W59)
_ _ _ (W 60)

Path length
Other

Printout:

Every _ _ _ _ steps of the ray trace (W71)
_ _ _ (W72 = 1.)

Punched cards (raysets):

68

r.

PROGRAM NlII~L
SE TS THE INITIAL CONOITIONS FOR EACH RAY ANO CALLS TRACE
JINENSION MFLO(2'

NIT 1001
NITIOC2
NITI003

COMMON tCDNSTI PI.PIT2,PI02.0~GS,RAO,K,C,LOGTEN
:OMHON IFLGI NTYP,NEWHR,NEWWP,PENET,LINES,IHOP,HPUNCH

NITI004
NIlIOOS

:OMHON IRINI

1

:OHHON IRKI

P100~IN('3) .COLL,F[ELO.S=-ACE,N2,N2I.PNP(tO},?JlAR.
LPOUR.SGN
N,STEP,HOOE,EIMAX,El~I~.E2HAX,EZMIN,FACT,~START

:;OHMON IX'1..I "'001(2) ,X,PXPR,P)( :tTH,P I( :lPH,P XP T,HMAX
CONNON IVYI "00Y.Y(16' IlU NJOl.Z{f.'

NITI006

NITI007

NITtOOS

NITI009
NITI010
COMMON R(ZQ},T,STP,O~OT(20) /JiW/ 1)(10),HQ,W(ItOOI
NITrOl1
EQUIVALENCE (R.AY .. W(U),(EARTH~,W(2),(XMTRH,W{3)},(TLAT,"(It»,
NITI012
1 <TLON,W(SlJ,(F,W(6»,(FBEG,\oI(71),(FENO,WUH),(FSTEP,IH9»,
NITIOl3
2 (AZ1,WUOJ) ,(AZ3EG,W(111) ,(AZEND.WClZ», (AlSTE"P,W(13J),
NITI014
3 (BETA,W(11t)',(ELBEG,HUS)J,CELENO,WC1&)),(ELSTEP,W(17l',
NITI01S
:. (ONLY,W(2lt), (HOP,W(2Z», 01AKST',W(Z3», (PLAT,W(Z4») ,(PLON,W(Z5' 'NITIOt&
S. (lNTYP,WC't1), (HAXERR,W(!.tZ»), (ERATlO,WC43", (SlEP1,W(Lt4»),
NITI017
& (STPHAX,W(45J ',(STPMIN,W(4&1', (FA :::TR,W(47)I, (SI(IP,W(71)),
NITr018
7 (RAYSET,W(72).(PLT,W(81)',C'ERl,,..(150')
NITI019
LOGICAL SPACE,NEWWq,NEWWP,PENET
NITIOZO
~EAL NZ.N2I,LJGlEN,K,MAXSTP,I~TYP,1AXERR,MU
NIlIOZ1
COM PLEX PNP,POlAR,LPOlAR
NITIOZZ
NQATE=IDATECQJ
NITIOZ5
SECONO=KLOCK(O)".OOl
NIT 1026
<OLL'4H
~J
NITI027
IF (C OLL.NE.O.' (OLL=4HWITH
NITI028
C'" .......... CONSTANTS
NIT IOZ9
PI=3.1415n6536
NIT 1030
PIT2=2."PI
NITI031
'I02=PI/2.
NIT 1032
OEGS=180.IPI
NITIOH
RA O=PI/18D.
NITI034
;=2.997925E5
NITI035
K=2.81785E-15"C"21PI
NITI036
LOGTEN=AL):;11D.1
NIT 1037
C.. •••••••• INITIALIZE SOME VARIABLES IN THE H ARRAY
NITI038
00 5 NW=1 •• 00
NITI039
5 W(NH'=Q.
NITIG40
PLON=O.
NITI041
PLAT=P102
NITI042
EARTHR=6370.
NITI043
INTYP=3.
NIT 1044
~AXERR=1.E·4
NITI045
ERATIO=50.
NIT 1046
STEP1=1.
NIT 1047
HPMAX=100.
NIT 1048
STPMIN=1.E·8
NITI049
FACTR=0.5
NITI050
HAXSTP=l~OO.
NIT1051
"HOP=l.
NIT 1052
C· .. ••••••• REAO W ARRAY AND PRINT NON-ZE~O VALUES
NIlI053
10 CALL REAO W
NITI054
F=BETA=AZ1=O.
NIT 1055
IF (SKIP.EQ.O.' SKIP=HAXSTP
NITI056
12
RAY :SIGNll .. RAYI
NITI057
~TYP:Z.+FIELO·RAY
NITI05S
GO TO (13.14,15). NTYP
NITI059
13 HFLOI1l:8HEXTRAORO
NITI060
NFLO(2':5HINARY
NIT 1061
;0 TO 16
NIT 1062
14 NFLOI1l:8HNO FIELO
NIT 1063
MFLOIZ.:1N
NITI064
:;0 TO 16
NIT 1065

69

15 MFLDIII=8HORDINARY
MFLDI21=8H
16 MODSAV=MODXI21
IF (PERT.Ea.o.1 MODX(21=6H
IF

(RAYSET.NE.O.I PUNCH 2000,

ID,MODXI!I,(WINW),NW=101,101),

1 MOOX(2I,(W(NWI ,NW=151.157) ,MODY,I'WINWI ,NW=201,Z071,

2 MODl,(WINW I ,NW=251,2571
2000 FORMAT (lOA8,4(/A8.2X.1EIO.31)
PR I NT 1000. 10 ,NUA TE ,MOD"- • MOul' • MOOZ ,MOCR 1 N .MfLu .KOLL
1000 FORMAT (lHl,lOA8,25X,1\8/4(lX'A/jJ'L4X'~A!j'lX'AO'A:>'L};'A4'

NITI066
NITI061
NITI068
NITI069
NITI07Q

NITI011
NI Tl012
NITI013
'''0 I aU 14

NJTIU'~

I IlH COLLISIONS/i
NITI016
PRINT In 50
NITIOl1
1050 FORMAT 185H INITIAL VALUES FOR THE W AR~AY -- ALL ANGLtS IN RADIAN"u I JU 10
IS. ONLY NONZERO VALUES PRINTED/I
NJ I lU79
DO 17 NW=1,400
NIII080
IF (WCNWI.NE.o.1 PRINT 1700. NW,WINWI
NITl081
1700 FORMAT (14,EI9.111
NITI082
]7 CONTINUE
NITI083
c********* LET SUBROUTINES PRtNTR AND RAYPLT KNOW THERE IS A NEW W ARRAYNITIOB4
NEWWP=.TRUE.
NIT 1085
NEWWR=.TRUE.
NITI086
c********* INITIALIZE PARAMETERS FOR INTEGRATION SUBROUTINE RKAM
NITI081
N=6
NITI088
DO 20 NR=7,20
NITI089
IF (W(50+NRI.NE.O.1 N=N+l
NIT 1090
20 CONTINUE
NJ I lu91
MOOE=INTYP
NITIOn
STEP=STEPI
NI I 1093
ElMAX=MAXERR
NIIIU94
EIMIN=MAXERR/ERATIO
NlTI095
E2MAX=STPMAX
NlTI096
E2MIN=STPMIN
NITI091
FACT·FACTR
NITl098
C********* DETERMINE TRANSMITTER LOCATI ON IN COMPUTATIONAL COO~OINATE
NIT 1099
c********* SYSTEM (GEOMAGNETIC COOROINATES IF DIPOLE FIELD IS U~EDI
N(lllOO
RO<EARTHR+XMTRH
NlTIIOl
SP=SIN IPLATI
NlTII02
CP-SIN IPID2-PLATI
NITl103
SDPH=SIN I TLON-PLON I
N1.T1104
CDPH=SIN IPID2-ITLON-PLONII
N 111105
SL=SIN fTLATI ·
NlTll06
CL=SIN IPI02-TLATI
NITII01
ALPHA=ATAN2(-SDPH*CP,-CDPH*CP*SL+SP*CLI
NITll08
THO=ACOs (CDPH*CP*CL+SP* SLJ
NIT 1109
PHO=ATAN2(SDPH*CL,CDPH*SP*CL-CP*SLI
NITIIIO
NITllll
C********* LOOP ON FREQUENCY, AZIMUTH ANGLE' AND ELEVATION ANGLE
Nl111l2
NFREQ=1
Ni l 111 ~
IF (FSTEP.NE.O.I NFREQ.{fENO-F~~GI/~Slt~+l.~
NI II114
NAZ=1
NITIl15
IF (AZSTEP.NE.O.1 NAZ=(AZEND-AZBEGIIAL~ltP+l.~
NlTIl16
NBETA=1
NITll11
IF IELSTEP.NE.O.I NBETA=IELEND-ELBEGI/ELSTEP+I.5
NITI1l8
DO 50 NF=l.NFREQ
NlTI1l9
F=FBEG+INF-ll*FSTEP
NITl120
DO 45 J=l,NAZ
NIT1121
AZl=AZBEG+IJ-ll*AZSTEP
N111122
AZA=AZl*OEGS
N1I1123
GAMMA=PI-AZ1+ALPHA
NITI124
SGAMMA<SIN IGAMMAI
NITI125
CGAMMA=SIN (PID2-GAMMAI
NITll26
00 40 I=l,NBETA
NlTI121
BETA=ELBEG+II-ll*ELSTEP

70

~L=AETA*nFr,s

NITII2e

CBETA=SIN (PID?-BETAl
R(l}=RO
R(2)=THO
RI11=PHn
R(4)=SIN (BETAl

NITI12q

R(Sl=CBETA*CGAM~A

NITI13 0
NITI131
NITI132
NITII31
NITI134

R(6)=CAET~4SGAM~A

Nlr113~

T=r1.
RSTART=I.
C
SGN=l.
(NEt:D FOR RAY TRACINCl IN COr.1PLEx SPACE.)
c********* ALLOW 10NO~PHERIC MOD~L SU~ROUTINES TO READ AND PRIN1 DATA
CALL RINOfX
IF (I.NE.l.AND.NPAGE.LT.3.AND.LINES.L~.l7) GO 1025

NITIl3£,
NITIl37
NITI138
NITt139
NITIl4U
NIl I141
~PAGE~LINFS=n
NITJ142
PRINT lnoo, JD,NDATE,rv.O()X,t··, U()Y,~Of)L,."1V[)1-<11\j,MI-L[)'''ULL
NT r 1143
PRINT 2400, F,AZA
NITf144
2400 FORMAT (18X,11HFREQUENCY =,FI2.6,37H MHZ, AZIMlJTH ANGLE OF TRANSMINITI145
lSSION = ,F12.6,4H DEG)
NITI146
25 NPAGE=NPAGE+l
NITI147
PRINT 2500, EL
NITr148
250n FORMAT U31X,33HELfVATION ANGLI: 01- TRANSMl~.slUN =,l-l£.6,4H [)EG/I NIlr149
IF (N2.GT.n.l GO Tn 30
NIT1150
CALL ELECTX
NITI15l
FN=SIGN (SORT (ABS (Xll*F,XI
NIT"Il5?
PR I NT 7 Q on, FN
NITr151
2900 FORMAT (58HOTRANSMITTER IN EVANfSCENT REGION, TRANSMISSION IMPOSSINITI154
lBLE/20HoPLASMA FRECUENCY = ,El7.]01
NITI155
GO TO 44
NITI156
30 MU =SQRT (N2/(R(41**2+R{5 1**2+R(61**21)
NITI157
DO 34 NN =4,6
NITIl~8
34 R ( NN1=R ( NN1*~U
NITI159
DO 35 NN=7,N
NITI160
35 R(NN1 =O.
NITI161
CALL TRACE
NITI162
OSEC =SECOND
NITll63
SECOND=KLnCKlol*.OOl
NITI166
DIFF=SECONO-OSEC
NITIl65
PRINT 3500, DIFF
NITI166
3500 FORMAT (36X,26HTHIS RAY CALCULATION TOOK ,FB.3,4H SEC)
NTTI167
IF ( PENET.AND.ON LY.NE.n •• ANO.IHOP.fO.ll GO TO 44
NITI168
40 CONTINUE
NITIl69
44 IF (P LT.NE.O.) CALL ENDPLT
NITI170
45 CONT I NUE
NITIl71
IF( PENET.AND.ONLY.NE.O •• AND.IHOP.EO.l.AND.NAZ.EQ.l,AND.NBETA.EQ.llNITI172
1 GO TO 5S
NITI173
50 CONT I NUE
NITI174
5C;
IF ( RAYSET.NE~O.1 PUNCH 5000
NITI175
soon FOR~AT (78X,lH- l
NITI176
MODXI21=MODSAV
NIT1177
GO TO 10
NITIl78
END
NITIl79 -

71

SUBROUTINE REAO W

READOOI
REAOS W ARRAY
READ002
A 1 IN THE FOLLOWING COLUMNS WILL MAKE THE DESCRIBED CONVERSIONSREAD003
COL IS
DEGREES TO RADIANS
READ004
COL 19
GREAT CIRCLE DISTANCE IN KM TO RADIANS
READ005
COL 20
NAUTICAL MILE S TO KM
READ006
COL 21
FEET TO KM
READOO 7
(
READOOS
(OMMON ICONSTI PI,P[T2,PID2,DEG S ,RAD.DUMf3 1
READ009
(OMMON /WW/ IDflOl,W Q,Wf4001
READOlO
EQUIVALENCE fEARTHR,W(21)
READOll
INTEGER DEG,FEET
READ012
READ 10nO, ID
READO 13
1000 FORMAT (IOAS)
READ014
IF fEOF,60J 3,4
READ015
3 CALL EX IT
READ016
4 READ 1100, NW,W{NW1,DEG,KM,NM,FEET
READO 17
11no FORMAT (13,E14.7.511 )
READ OIS
IF fNW.E0.0 1 GO Tn 10
READ019
IF INW.GT.O.ANO.NW.L E.4 00) GO TO 5
READ020
PRINT 4noo. NW
READ02l
4000 FORMAT(15HITHE SUBSCRIPT ,r3,77H ON THE W-ARRAY INPUT IS UUT OF BOREAD 0 22
lUNDS. ALLOWABLE VALUES ARE 1 THR OUGH 400. )
READ023
CALL EX IT
REA0024
5 IF IDEG.NE.O.) WINW ) =WINW1*RAD
READ025
IF (KM.NE.O' WINW)=WINW)/EARTHR
READ026
IF (NM.NE.OJ W(NWJ=W{NWI*].852
READ 02 7
IF (FEET.NE.Ol W(NW)=W(NW1*3.048 006096E -4
READ02S
GO TO 4
READ029
10 RETURN
RE ADO 3 0
END
READ03lC
C

SUBROUTINE

TRAC001
RAY PATH
TRAC002
DIHENSION ROLO(20) ,OROLJ(20)
TRAC003
COMMON IRKI N,STEP,HOOE,E1HAX,E1HIN,E2HAX,EZHIN,FACT,RSTART
TRACOO~
COHMON IFLGI NTYP,NfHHR,NEWWP,PENET,LINES,IHOP,HPUNCH
TRACOOS
COHHON ITRA:I GROUNO,PE~IGE,THERE,HINOIS,NEWRAy,SHT
TRAC006
CJHHON IRINI HOORIN(3),COLL,FIElO.SPACE,N2,PNP(lO),POlAR.LPOlAR
TRAC007
COHHON IXXI HOOX(ZI,X,PXPR,PXPTH,PXPPH,PXPT,HHAX
TRAC008
COHMON R(20) ,T,STF.OROT{ZO) IWWI IO(1 0 ),HQ,W(ltOOI
TRAC009
LOGICAL SPA:E,HOHE,WASNT,UNDRGD,GROUNO,PERIGE,THERE,MINDIS,NEMHR, TRAC010
1
NEWj.lP,PENET,NEWRAY,WAS
TRACOl1
REAL MAXSTP
TRAC012
COHPLEX N2,PNP,POLAR,LPOLAR
TRAC013
ElU I V Al ENe E (E ART HR. W(211 , (RCV RH, j.I {2 0 » " ( HOP, H ( 22) ) , OUXS T P, W( 2 3 ) ) TRA C0 lit
1, (SKIP,M<7U), (RAYSET,W<7Z)), (PlT,W(8U)
TRACD15
N~OP=HOP
TRA C01&
MAX =HAXST?
TRAC017
TRAC018
NSKIP =SKIP
RSTART =1.
TRAC019
CALL HAHLTN
TRAC020
HOHE'=ORO T( 1) • (R (11 -EART~ ~ - RC VRH) • GE. o.
TRAC 021
C••• • ••••• IHOP = O TELLS PRINTR TO PRINT HEADING AND PUNCH A TRANSMITTER TRAC022
TRAC023
C•••• • •• •• RAys::r AND TELLS RAY'PLT TO ST·ART A NEW RAY
IHOP=O
TRAC024
CALL PRINTR (8HXHTR
,0.)
TRAC025
IF (PLT.NE.O.) CALL RAYPLT
TRAC026
HTHAX=O.
TRAC027
NE"RAY=.TRUE.
TRAC028
T~ERE=R(l)-EARTHR.EO.RCVR~
TRAC029

C

T~~CE
CAlCJL~ES THE

72

c·········
lOOP ON ~UMBER OF HOPS
lD IHOP=IHOP+1
IF (IHOP •• T.NHOP)
PENET=.FALSE.
APHT=RC ~RH

RETURN

C········· LOOP ON MAXIMUM NUMBER OF STEPS PER HOP
00 79 J=l. HAX
H=R (ll-EARTHR
IF (ABS(H-RC~~H) .GT.ABS(A'HT-RCYRH)) APHT=H
HTHAX=AHAX1(H.HTHAX)
IF (.NOT.SPACE) GO TO lZ
CALL REACH
RSTART: 1.
H:R (ll-EARTHR
IF (ABS (H-RC~RH) • GT • ABS (A PHT -RCYRH)) A PHT =H
HTHAX=AHAX1(H.HTHAX)
IF (.NOT.SPACE) GO TO lZ
IF (PERIGE) CALL PRINTR (8HPERIGEE .D.)
IF !THERE) :;0 TO 51
IF (MINOIS) GO TO .0
IF (GROUND) :;0 TO oD
IF (PU.NE.D.) CALL RAYPU
IF (PERI.E) GO TO 79
lZ ~O 13 L=l.N
ROLO(L) 'R(Ll
13 OROLO(L)=DROT(L)
TOLD=T
WAS=THERE
CALL RKA"
H=R (lI-EARTHR

TriERE=.FALSE.
4ASNT=.~OT.HOHE

HOHE=OROT(l)·(H-RCVRH).GE.D.
UP= (OROHlI-OR
0 (1) ) +!T-TQ LO)
SHT=D.
IF (THP.NE.D.) SHT=D.S'(R(1) -ROLO(ll+D.S'THP)"ZlABS!THP)
IF « (rl-R;H,j) +(ROLO(lI-EARTHR-RCVRH) .LT.D .. ANO •• NOr.WAS) .00..
1 (WAS.ANO.ORaT(U+OROLO(ll.LT.D .. ANO.HOHE)) GO TO SO
IF (HOHE.ANO.4ASNT) GO TO 30

a..

IF

(H.LT.O •• OR.DROT(U.:;T.O •• ANO.DROlO(U.LT.O •• ANO.SHT.GT.H)

1 GO TO ZU
IF (OROLO(l) .LT.D .. ANO.ORDT(lI.GT.O.) CALL PRINTR(8HPERIGEE .0.)
IF (oROLO(ll.'T.D •• ANO.ORJT(ll.LT.O.) CALL PRINTR(SHAPOGEE
.0.)
IF (OROLO(Z)·JROT(Z).LT.D.) CALL PRINTR(8HHAX LAT .0.)
IF (OROLO(3)+OROT(3).LT.0.) CALL PRINTR(8HMAX LONG.o.)
)0 14 1=4,6
IF (ROLO(I)'R(Il.LT.O') ;ALL PRINTR(8HHAVE REV.o')
H
CONTINUE
GO TO 75

c·········
RAY WENT UNOERGROUNJ
ZO CALL BACK UP(D.)
GO TO 00
c····· ..
·. RAY MAY
HADE A CLOSEST APPROACH
~AVE

30 CALL GRAZE(RC~RH)
IF (THERE) GO TO 51
.0 DROHll :0.
HPUNCH=R(l)-EARTHR
CALL PRINTR(8HHIN OIST.RAYSET)
IF (PLT.NE.o.) CALL RAYPLT
IF IIHO>.GE.~~OP) RETURN.
IHOP:IHOP+1
CALL PRINTR (8HlUN OIST.RAYSETl
GO TO 89

73

TRACD30
TRACD31
TRAC03Z
TRACD33
TRACD3.
TRACD35
TRACD30
TRACD37
TRACD38
TRAC039
TRACo .. o
TRACD.1
TRACo .. Z
TRACo .. 3
TRACo ....
TRACo .. 5
Tuca.o
TRACo .. ?
TRACo .. 8
TRACo.9
TRAC05D
TRAC051
TRACoSZ
TUCoS3
TRACoS ..
TRAC055
TRAC050
TRACoS7
TRACoS8
TRAC059
TRACDoa
TRACool
TRACDoZ
TRACo03
TRACoo"
TRACDoS
TRACOoo
TRACo07
TRA C 008
TRACo09
TRA CD7D
TRAC071
TRAC07Z
TRAcon
TRACOH
TRAC075
TRAC070
TRAcon
TRAC078
TRAC079
TRACoSO
TRACDSI
TRAC08Z
TRAC083
TRAC08"
TRAC08S
TRAC080
TRAC087
TRAC088
TRAC089
TRA C 09 0
TRAC091
TRAC09Z

c·········
RAY CROSSED
50 CALL BACK

RECEr~ER

HEIGHT

UP(~C~RHI

THERE=. TRUE.
51 R(l'=EARTHR+RCtRH
HTHA X=AHAX1(RCVRH,HTHAXI
HPUN CH= APH T
;ALL PRINTR(8~RCYR
,RAYSETI
IF (PLT.NE.O.I CALL RAYPLT
IF (RCYRH.NE.O.I GC TO 89
IF (IHOP.GE.NHOPI RETURN
IHOP=IHOP+l
APHT=RCVRH

C········· GROUND REFLE CT
&0 R(1)=EARTHR
IF (ABS(RCYHI.GT.ABS(APHT-RCYRHII
R(41=ABS (R(41 I
OROT(ll=AaS (OROT(111
RSTART=1.
HPUNCH=HT HAX
CALL PRINTR(8HGRNO REF,RAYSETI
HTHAX=O.
IF (RCYRH.NE.O.I GO TO &;
THERE=. TRUE.
HPUNCH=APHT
CALL PRINTR (8HRCYR
,~AYSETI
GO TO 89
:'5 H=O.
THERE=.FALSE.

APHT=O.

C·········
75 IF (PLT.NE.O.I CALL RAYPLT

IF (H.GT.HHH.ANO.H.GT.RCYRH.ANO.OROTlll.GT.O.I GO TO 90
IF (H OO(J,NSKIPI.EQ.OI CALL PRINTR(8H
,0.1
79 ;ONTINUE

C········· EXCEEDED MA XIMUM NUMBER OF STEPS
HPUNCH=H
CALL PRINTR(8HSTEP HAX,RAYSETI
RETURN

C·········
S9 HOHE=.TR UE.
GO TO 10
C. · . ... ••••• RAY

PE~ETRATf O

90 PENEr=. TRU E.
HPUNCH=H
CAll

P R I N T R (6~PEN E TRAT,RAfSET)

RET URN
END

TRAC093
TRAC09"
TRAC095
TRAC09&
TRAC097
TRAC098
TRACQ99
TRAC100
TRAC101
TRAC102
TRAC103
TRAC10"
TRAC105
TRAC10&
TRAC107
TRAC108
TRAC109
TRAC110
TRAC111
TRAC112
TRAC113
TRAC114
TRAC115
TRAC11&
TRAC117
TRAC118
TRAC119
TRAC120
TRAC121
TRAC122
TRAC123
TRAC124
TRAC125
TRAC12&
TRAC127
TRAC128
TRAC129
TRAC130
TRAC131
TRA C132
TRAC133
TRAC134
TRAC13S
TRA C13&
TRA Cl37
TRAC13 8

SUBR OUT I NE BA CK UPIHSI
BACKOOI
CO MMON IRKI N, STEP,MOO E, EI MAX,E IM I N, E2MAX . E2MIN,F AC T. RS TA RT
BAC K002
COMMON I TRACI GROUNO ,P ERI GE,T HER E , MINDIS , NE WR AY,SMT
BAC K003
COMMON R(2 0),T , STP'DRO TI20 } IWWI I DIIO} , WO .W( 400)
BA CK00 4
EQUIVA LENCE IE ARTHR, W( 211 , IINTYP,W{4111 , {ST EPl , W(4411
BA CK005
RE AL I NTYP
BACK006
LOG ICAL G R O UN D . PER I GE .THE R F' ~ I NO I S . NE W RAY 'H O ME
BACK 007
c ****** * * * DI AG NOSTI C PRI NT OUT
BAC KOOa
C
CALL PRI NTR (BHBACK UPO . O. 1
BACK009
C* * .*** ·** GO I NG AWAY FROM THE HE IGH T HS
BACKO I O
HOME=ORD T( 1 1* ( R( 1 1- EARTHR - HS1 . GE.O .
BACK OI I
IF IHS . GT. O•• ANO •• NOT .H OME . OR . HS . EO . O•• ANO . OROT{ ll. GT. O.1 GO TO 30 BA CKOl2

74

C********* FIND NEAREST INTERSECTION OF RAY WITH THE HEIGHT HS
no 10 1=1,10
STEP=-IRI11-EARTHR-HS'/DRDTI!.
STEP=SIGNCAMINl(ABSCSTP).ABSCSTEPI).STEPJ
IF IABSIRII'-EARTHR-HS •• LT •• 5E-4.AND.ABSISTEP •• LT.!.' GO TO 60
c* •• ·.**** DIAGNOSTIC PRINTOUT
C
CALL PRINTRC8HBACK UP1.Q.)
MODE=I
RSTART=I.
CALL RKAM
10 RSTART=I.
C

c********* FIND NEAREST CLOSEST APPROACH OF RAY TO THE HEIGHT HS
ENTRY GRAZE
THERE=.FALSE.
c******·** DIAGNOSTIC PRTNTOUT
C
CALL PRINTR 18HGRAZE 0 .0.'
IF ISMT.GT.ABSIRII'-EARTHR-HS" GO TO 30
DO 20 1=1,10
STEP=-R(41/DRDT(4)
STEP=S JGN (AM INI (ASS (STP) .ABS( STEP) ) .STEP I
IF (ABSCR(4 1 ).LE.l.E-6.AND.ABSCSTEP).LT.l.) GO TO 60
C.·.*··.** DIAGNOSTIC PRINTOUT
C
CALL PRINTR 18HGRAlE ! .0.'
MODE=I
RSTARTzl.
CALL RKAM
RSTART=l.
IF IDRDTI4'*IRII'-EARTHR-HS'.LT.D.1 GO TO 30
IFCR(5).EO.0 •• AND.R(61.EO.0.) GO TO 60
20 CONTINUE
C**····*** IF A CLOSEST APPROACH COULD NOT 8E FOUND TN 10 STEPS. IT
c****·**** PROBABLY MEANS THAT THE RAY INTERSECTS THE HEIGHT HS
30 CONTINUE
c******·** DIAGNOSTIC PRINTOUT
C
CALL PRINTR (BHBACK UP2,0.1
MODE=!
c*·******· ESTIMATE DISTANCE TO NEAREST INTERSEcTION OF ~AY WITH HEIGHT
c******* •• HS BEHIND THE PRESENT RAY POINT
STEP=(-RC4)-SORT(R(41**2-2.*(RCI1-EARTHR-HSJ*DRDTC4))1IDRDT(4)
RSTART=I.
CALL RKAM
RSTART=!.
c*·******* FINO NEAREST INTERSECTION OF RAY WITH HEIGHT HS
DO 40 1=1,10
S TEP=-(R(lJ-EARTH~-H SJ/DRDT(l)

STEP=SIGN(AMINICABSfSTPI.ABSCSTEPI).STEP)
IF IABSIRII 1-EARTHR-HS •• LT •• 5E -4. AND.ABSISTEP1.LT.I.' GO To 60
c**.**·*** DIAGNOSTIC PRINTOUT
C
CALL PRINTR (BHBACK UP3.0.1
MODE=!
RSTART=!.
CALL RKAM
40 RSTART=I.
50 THERE =- TRUE.
c********* RESET STANDARD MODE AND INTEGRATION TYPE
60 MOOE=INTYP
STEP=STEPI
RETURN
END

75

BACKO!3
BACKO!4
BACKO!5
BACKO!6
BACKO!7
BACKOl8
BACKOl9
BACK020
BACK021
BACK022
BACKOZ3
BACKOZ4
BACKOZ5
BACKOZ6
BACKOZ7
BACK028

BACK029
BACK030
BACK03!
BACK032
BACK033
BACK034
BACK035
BACK036
BACK037
BACK038
BACK039
BACK040
BACK041
BACK042
BACK043
BACK044
BACK045
BACK046
BACK047
BACK048
BACK049
BACK050
BACK05!
BACK052
BACK053
BACK054
BACK055
BACK056
BACK0 57
BACK058
BACK059
BACK060
BACK06!
BACK062
BACK063
BACK064
BACK065
BACK066
BACK067
BACK068
BACK069
BACK070
BACK07!
BACK072-

SUBROUTINE REACH
CALCULATES THE STRAIGHT LINE RAY PATH I!"ETWEEN THE EARTH
AND THE IONOSPHERE OR BETWEEN IONOSPHERIC LAYERS

C
C

COMMON I~KI N,STEP,HOOE,El~AX,~lMrN,E2MAX,E2HIN,FACT,RSTART
Cor-a'1ON ITRACI GROUND, PE~IGE, THERE ,MINOIS, NEWRAY .SMT
COMMON /C08RD/ S
CO~MON

1

I~INI

HOORINe31,COLL,FIELO,SPACE,N2,NZI,PNPC10I,POlAk,

LPOLAR
COPMON IXXI MODXC2J,X,PXPR,PXPTH,PXPPH,PXPT,HMAX

REACO!)l
REAC002
REACO 03
REACCO~

REACt 'J3

R€ACC06
PEACJ07

RC:ACCGS
R':ACC c q

COt-'MON ~C2:J),T,STP,DROT(20) IHHI IDC10I,WQ,W(4QO)
f.QUIVALENe=. (fARTHR,W(2JI,eXHTRH,W(3»),(RCVRH,H(20)
LOGICAL CPOSS,CROSSG,CROSSR,SPACE,GROUND,P£RIGE,THERE,MINors,
1
N::-WRAY,RSPACE
R.f:A L N2,N2I
PNP,POlAR,LPOLAR
DATA (NST"P=SOOI
CALL HHUN
H=R (ll-lA"lHR
IF (.NOT.NEWRAY.ANO .. NOT.RSPACEI CALL PRINTR(8HEXIT ION.O.I
CO~PLEX

P,EAC(:10
~:::ACOll
R~AC( 12

REAC,13

REAC 1 ...
RtAC 15
ROC 16
~f.AC

17

R.EAC

1~

REAC 1')

N£WRAY=-.FALSE.

REAC

V;SQRT(RC4)·~2~R(5)··Z+R(o'··2)

'I.E AC 21
'<E AC 22
REAC 23

C········· NORMALIZE

TH~

WAVE NORMAL DIR£CTION TO ONE

R(41 ='<1 4l/V
;U5, =R(5'/ij'
R("I=R( "I/V

C········· NEGATIVE OF

C·········
OF EA~TH
UP;R(lJ ·R(.J

2J

iF AC 2 ..
Rc.AC 23
DISTANC~

ALONG RAY TO CLOSEST APPROACH TO CENTER R.EAC

26

REAC 27
Rf.AC 21t

RADG;EAKTH~··2-R(1)··Z·(~(5'··2+R(0'··ZI

R.~AC

21

DISTG=SORT (AMAX1(O .. RADGII

~£AC

30

C········· DISTANCE ALONG
TO FIRST INTERSECTION WITH OR
C·········
APPROACH TO
EARTH
SG= -UP- 01 ST G
~AY

CLOS~ST

C········· CROSSG IS TRUE IF THE RAY WILL INTERSECT OR TOUCH THt iARTH
CROSSG=-UP.LT.O •• ANO.RAOG.GE.O.
~AO R= (E AR. THR. RC VRH, •• Z-Q (1) ··2'" (R (5' ··Z ~R (0' ··2)
DISTR=SORT IAHAX1(0 •• RADRII

C········· DISTANCE ALONG RAY TO THE FIRST INTERSECTION WITH

C·········

R::AC 31
R':A( 32
RcAC 33

TH~

O~

REAC 3 ...

REAC 35
REAC 3&
REAC 37

CLOSEST ,<"AC 38

APPROACH TO THE R_ECEIVER HEIGHT

SR=DISTR-UP
IF (UP.LT.O •• AND.DISTR.LT.-UP.AND.R(ll.NE.EARTHR+RCVRHI SR=-OISTR
1 -UP
CROSSR IS T~UE IF THE RAY WILL INTERSECT WITH OR MAKo A

R~AC

3q

REAC

4~

REAC .1

REAC 42
REAC 43
REAC 4.
RECEIVE~
ROC 45
eRO SS=C PO SSG. OR.C ROSSR
REAC 46
C········· !'IAXIMUH DISTANCE IN WHICH TO LOOK FOR THE IONOSPHERE
RE AC 47
Sl=AHINlISR.SGI
REAC 46
REAC 4q
IFf.NOT.CROSSGI S1=SR
IF (UP.GE.O.1 GO TO 15
REAC 50
CROSS=.TRUE.
REAC 51
IF RAY IS GOING DOWN, Sl IS AT MOST THE DISTANCE TO A PERIGEEREAC 52
Sl=AHINlIS1.-UPI
REAC 53
REAC 5.
CONVERT THE POSITION AND OIRECTION JF THE RAY TO CARTESIAN
c~········ COORDINATES
REAC 55
REAC 5&
15 CALL POL CAR
REAC 57
SSTEP=l 00.
S=S!STEP
REAC 56
RfAC sq
DO 20 I=l.NSTEP
IF IIS-SSToPI.GT.S1.AND.CROSSI GO TO 25
REAC 60
C········· CONVERT POSITION AND DIRECTION TO SPHERICAL POLAR COORDINATESREAC 61
C········· AT A DISTANCE S ALONG THE RAY
REAC 62
CALL CA R POL
REAC 63
REAC 6.
CALL ELEClX
C········· FREE SPACE
REAC 65

c·········
C·········
ClOSfST APPROACH TO THE
HEIGHT
CROSSR=RI 41 .L T. O•• OR. R( 11 • LT. IE ARTHR+RCVRHI

c·········
C······.··

76

IF IX.EO.C. I GO TO 20
CAL L RI NOO
C········· eFFECTIVELY FREE SPAC~
IF (SPACE) GO TO 2D
IF ISSTEP.LT.O.5E-4) GO TO 25
RAY IN THE IONOSPHERE. STEP BACK O~T
S=S-SSTfP
DECREASE STEP SIZE
SSTEP=SST"P/10.
20 S=S"SSTt.P
PRINT 2COQ, NSTEP
2000 FORMAT (gH EXCEEOEO.I5.25H STEPS IN SUBROUTINE REACHI
CALL ::X IT
25 IF(CQOSS) S=HIN1 (S.S1)
CONVE~T POSITION AND DIRECTION TO SPHERICAL POLA~
AT A DISTANCf S ALONG TH~ RAY
CALL CAP POL
c· •••• •••• .o.VOIO THE. ~AY BEING SLIGHTLY UNO:=:R:G~OlJNO
Q(1)=AMAXitP(t) ,EARTH~'
c········ .. ONE STEP INTEGRATION
IF IN.LT.71 GO TO 31

REAC 66

REAC 67
REAC 66
REAC 69
R€AC 70
REAC 71
RfAC 72

c·.···.···
c·········

c··.· ... ·.
c·······.·

00

30

Rt::AC 73
RfAC "'i+

R:=:AC 75
R:_AC
R[AC

7\

R~AC

79

COuRJINAT~SR t.AG

~J

R7:AC

~2

R':AC 8 3
Rt.AC

84

REAC BS
R':AC .6
87

REAC 6~
REAC R9
R~AC

gO

P~RIG[E

R~AC

91

PEFIGE=S.~Q.(-UP'

RtAC

g2

c··.···.·· AT A
c·········
HINOR ERRORS
IF (PERIGfl Q(4)=D.
c······.··
KEEP CONSISTENCY AFTER CORRECTING MINOR ERRORS
QROTllI=Ql")
COR~~CT

c······· •• ON TH~ GROUND
GROUNO=S.EQ.SG.ANO.CROSSG
AT THE RECEIVER HEIGHT
THERE=S.EO.SR.ANO.CROSSR.ANO •• NOT.PERIGE
AT A CLOSEST APPROACH TO THE REC£IV~R HE IG HT
MINOI S= PERIGE. ANO. S. EQ. S~.ANO. C ROSSR
RSPACE=SPACE
V=SQRT(N2/(R(4'··2+R(5'··2+RC6)··21J
c •••• ••••• R~NORHAlIZE THE WAVE NORMAL DIRECTION TO = SaRT(REAL(N"·2')

c·.···.··.
c·········

R(I+)=~(4'·1J

R(5)=R( 5)'W
R(6)=R(61'W
RST AR T= 1.
IF (.NOT.SPACE) CALL PRINTR 16HENTR ION.D.I
RETURN
END

SUBROUTINE POL CAR
DIMENSION XOl61 ,X(61 ,RO{41
COMMON R(6) /CQQRDI S
COMMON /CONSTI Pt,PtT2,PID2,DUMI5J

C

R':AC 61

RfAC

NN=7,N

30 R(NN' =p INN' +S·OROT(NN'
31 T=l+S
CALL qINOEX

C

76

R, AC 77

CONVERTS SPHERICAL COORDINATES TO CARTESIAN
IF (R(51.EQ.O •• ANO.R(6'.EQ.O.l GO TO 1
VERT=O.
SINA=SINIR(21 1
COSA=SINIPI02-R(21 1
SINP=SINIR(31 I
COSP=SIN(PID2-R(3' I
XQ(l)=R(ll*SINA*COSP
XQ(ZI=RIIJ*SINA*SINP
XO(31=R(ll*COSA

77

REAC q3
REA C g ..
RE AC 95

REAC 96
REAC 97
R[AC g~
R"AC 99
RfAC10J
REAC10i
REAC102
REAC103
R£AClG ..
REAC105
REAC1J6
REACH7
REAC106
REAC10q

REACl1D
REAC111
REAC112-

POLCOOl
POLC002
POL C003
POLc004

POLC005
POLc006
POLC007
POLC008

POLC009
POLCOlO
POLCO 11
POLC012
POLC013
POLC014
POLCOl5

C

X(4)cR(41*SINA*COSP+RI51*CO SA*C OS P-RCbl*SINP
X(5)=R(4)*SINA*SINP+R(5'*C OS A*SINP+R(61·CQSP
X(6)=RI4J*COSA-RI51*SINA
RETURN
VERTICAL INCIDENCE
1 VERT=1.
RO(ll=R(lI
RO(2 l =R(2l
RO(3l=R("ll
RQ(4)=SIGN (1.,RC4))
RETURN

C
C
C

POLCO 16
PO Lc017
POLC018
POLC019
POLC OZO
POLC 021
POLC022
POLCOZ3
POLCOZ4
POLCOZ5
POLC026

STEPS THE RAY A DISTANCE S. AND THEN
CONVERTS CARTESIAN COORDINATES TO SPHERICAL COORDINATfS
ENTRY CAR POL
IF (VERT.NE.O.) GO TO 2
XIll=XOllJ+S*X(4)
X(21=XO(2J+S*X(S'
X(31=XOI31+S.XI6'
TEMP=SQRT(Xlll**Z+XCZ'**2)
RIIJ=SORT(X(ll**Z+X(2J**Z+X{31**2'
R(2)=ATAN2ITEMP,X{3)1
R(3J=ATAN2IX(2 1 ,XIlll
R(4)={X{11*X(41+X(ZI*X(S)+X{31*X(6)J/RIll

R (5 I = (X ( 3 1*( X (1) *X (4) +X ( 2 J * X (5 J )- (X ( II **2+X ( 2) **2) *x (6 I ) I
1 (R<llHEMPl

R(61=(XIll*X(SI-XI21*X(411/T EM P

RETURN
VERTICAL INCIDENCE

C

2 R ( 1 ) =RO (11 +RQ (41 *S

R(2l=RO(2l
R(3l=RO( 3 l
R(4l-RO(4l
RI51:z0.

R{61=O.

RETURN
END

C

SUBROUTINE PRINTRINWHY.CAROI
PRINTS OUTPUT AND PUNCHES RAYSETS WHEN REQUESTED
DIHENSION GI3,31.G113.31.TYPEI31.HEADR1IZ01.HEADRZIZOI.UNITSIZOI.
1
HEA 0 1( Z DI • HEAOZ 1 Z0 I • UNIT 1ZDI • RP RINT< ZDI • NPR ( Z0 I
COHHON ICONSTI PI.PITZ.PIOZ. OEGS.RAO.OUHI31
COHMON

IFLGI -. TY p, NEWWR, ~ EWMP, PENE T, LINES, IHOP, HPUNCH

COHHON IRINI NOORIN(3).COLL.FIELO,SPACE.NZ.NZI.PNPll01.POLARIZI,
1
LPOLARIZI
COHHON RIZDI,T IW~I IOltal.WO.W(400)
ElU IVAL ENCE <THET A .R 1Z)) • IPH I. R (311
EQU I VAL EN CE 1EART ~R. W1ZII • 1XHT RH. W( 31 I • 1TLAT • W1411 • 1TL ON. WI 51 I •
1
~

( F , W(&) ) , (4 Z 1 , W( 1 0 ) ) , (BE T A, W( 14) ) , (RC VRH , \of ( 20 ) ) , (H OP, W( 22) ) ,
(PLAT,W(Z4»,(PLON,W(Z5»,(RAYSEf,W(7Z)
LOGICAL SPACE,NEWWR,NEWWP,PENET
~EAL NZ,NZI,LPOlAR

COMPLEX PHP
OA fA IT YPE=lHX .1HN ,1HO)
~,(HEAOR1(71 = €d

Pt-IAS)'(H::AORZ(7)=&HE

PATH) ,(UNlfS(7J=&H

1(f'1) t

3 IHEAOR1I81=6H ABSOI. (HEAORZI81 =6HRPTION). (UNITSI81=6H
OB I.
"IHEAOR1I91 =6H
OOPI.(HEAORZI91=6HPLER I,(UNITSI91=6H CIS I.
, IHEAOR1Il01=5H PATH 1.IHEAORZI101=6HLENGTHI.IUNITS(101 =6H
XH
CALL RINOEX
IF (.NOT.NEWW'I GO TO 10

78

PDLCOZ7
POLC028
POLc029
POLC030
POLC031
POLC032
POLC033
POLC034
POLC035
POLC036
POLC037
POLC038
POLC039
POLc040
POLC041
POLc04Z
POLC043
POLC044
POLC045
POLc046
POLC047
POLC048
POLC049
POLC050
POLC051
POLC 52PRINODl
PRINDDZ
PRI NOO 3
PRIN004
PRINODS
PRIN006
PRIN007
PRINOO!
PRIN009
PRIN010
PRINOl1
PRIN01Z
PRI N013
PRI N014
PRIN015
PRIND16
PRIN017
PRIND18
PRI ND19
PRINDZD
PRINOZ3
PRINOZ4
PRINDZS

c.. • .. •••••• NEW W ARRAY -- REINITIAlIZE

PRIN026

NEWWP=. fALSE.
SPL=SIN (PLON-TLONI
GPL=SIN (PIOZ- (FLON-TLONI I
SP=SIN IPLATI
~P=SIN (PIOZ-?LATI
SL=SIN (fLAT!
CL=SIN IPIOZ-TLATI

PRIN027
PRINOZ6
PRINOZ9
PRIN030
PRIN031
PRIN03Z
PRIN033

C...... •• ... •• MATRIX TO ROTATE COORDINATES
G (1,1) =CPl·Sp· CL -C P·SL

PIUN03'4
PRIN035

GI1.ZI=SPL·SP
G(1.31=-SL·SP·e fL-eL'ep
GIZ.11=-SPL·GL
GIZ.ZI=CPL
GIZ.31=SL·SPL

PRIN036
PIUN037
PRIN036
PRIN039
PRIN040

G(3,1)=Cl·CP·~PL+SP·SL

PRIN041

GI3.21=CP·SPL
GI3.31=-SL·CP·eFL+SP·CL

PRIN042
PRIN043

OENH=G(1,1)"'G(Z,Z)"'G(3.3)+G(1,Z)"'G(3,1)"'G(Z,3)+G(Z,1)'"G(3,Z)·G(1,3PRIN044
lJ-G(Z,Z)·G(3,1)"'G(1,3)-G(1.Z)·G(Z,1)·G(3,J)-G(l.1)·G(3,2)·G(2,3)
PRIN045

C·········
THE "ATRIX G1 IS THE INVERSE OF THE HATRIX G
G111.11=(GI2.ZI·GI3.31-GI3.ZI'GIZ.311/0ENH
G111.21=IGI3.ZI·GI1.31-GI1.ZI·GI3.311/0ENH

PRIN046
PRIN047
PRIN048

Gl(1,3)~(G(1,2)·G(2,3)-G(2,2)"'G(lt3»)/OENH

PRIN049

G1IZ.11'IGI3.11·GI2.31"GIZ.11'GI3.311/0ENH
G1 12.Z1 = (G 11.U·G 13.31 -GI 3 .il·G (1,31 I/OENH
G1IZ.31=IGIZ.11·GI1.31-GI1.11·GIZ.311/0ENH
G113.11=IG(Z.11·GI3.21-GI3.11·GI2.211/0ENH
G113.ZI=IGI3.11·G(1.21-GI1.11'GI3.211/0ENH
G113.31=IGI1.11'GI2.ZI-GI2.11·GI1.211/0ENH
RO=EARTHR+XHTRH
e.. • .... •• CARTESIAN COORDINATES OF TRANSHITTER
XR=RO·GI1.11
YR=RO·GI2.11
ZR=RO·GI3.11
eTHR=GI3.11
STHR=SIN lAeos leTHRI I
PHIR=ATANZ IYR. XRI
ALPH=ATlN2(GI3.ZI.GI3.311

PRINOSO
PRINOS1
PRIN052
PRIN053
PRINOS4
PRINOS5
PRIN05&
PRINOS7
PRIN058
PRIN059
PRIN060
PRIN061
PRIN062
PRIN063
PRIN064

e···· ........
·
NR=6

PRINO&5

PRIN066
NP=O
PRIN067
00 7 NN=7.20
PRIN068
IF IWINN+SOI .EIl.. O. I GO TO 7
PRIN069
DEPENDENT VARIABLE N~HBER NN IS BEING INTEGRATED
PRIN070
NR IS THE NUMBER OF DEPENDENT VARIABLES BEING INTEGRATED
PRIN071
NR=NR+1
PRIN072
IF IW INN+SOI .NE.2. I GO TO 7
PRINOT3
DEPENDENT VARIABLE NJHBER NN IS BEING INTEGRATED AND PRINTED.PRINOT4
NP IS THE NUMBER OF DEPENDENT VARIABLES BEING INTEGRATED AND PRIN075
c.. ••••• .. •• PRINTE)
PRIN07&
NP=NP+1
PRIN07T
SAVE THE INDEX OF THE DEPENDENT VARIABLE TO PRINT
PRINOT8
PRI N079
NP RINPI =NR
PRIN080
~EA01 INPI =HEADR1 INNI
PRIN081
HEADZ IN?I =HEADR ZINNI
PRI N08Z
UNITINPI=UNITSINNI
PRIN083
7 CONTINUE
PRIN084
W1=HINO INP. 31
PRI N085
PDEV=ABSOR8=DOPP=O.

C·········
C·········

C·········
C·········
c·········

79

c·.·· ... ·· PRINT COLUMN HEADINGS AT THE BEGINNING OF EACH RAY

PRIN08&

IF <IHOP.NE.O) GO TO 12
PRIN087
PRINT 1100. (HEA01(NN) .HEA02(NN).NN=1.NP1)
PRIN088
1100 FORMAT (I.4X.7,jAZIMUTH/43(.9HOEVIATION.6X.9HELEVATIONI
PRIN089
1 19X.16HHEIGHT
RANGE.1X.2(SX.12HXMTR
LOCAL).SX.26HPOLARIZATIPRIN090
20N
GROUP PATH. SA6.AS)
PRIN091
PRINT l1S0. (JNIT(NN) .NN=I.NPll
PRINOn
til

115.:1 FORMAT C13X,2C8X,2HKM',ZJ(,Z{&X,3HOEG,5X,3HDEG1,&X,12HREAL
1 7X,ZHKH,4X,3(4X,A&,2X»

IHAG.PRtN093
PRIN094

IF (RAYSET .EQ. 0.) GO TO 12
C·· ...... •• .. • PUNC"f A TRANSMITTER

PRIN09S

RA~SET

PRIN09&

TLONO=TLON'OEGS
IF <TLONO.LT.O.) TLONO=TLONO.360.
TLATO=TLAT'OEGS
IF <TLATO.LT.O.) TLATQ=TLATO'360.
AZ=AZ1'OE,S
EL=BETA'OEGS
NHOP=HOP

PRIN097
PRIN096
PRIN099
PRIN100
PRIN101
PRIN102
PRIN103

PUNCH 1200, 10(i) ,TYPE(NTYP) ,XMTRH,TLATD, TLONO,RC'lfRH,F,AZ,EL,POLARPRIN104
1,NHOP,lHT
PRIN10S
1200 FORHAT (A3,A1,4PF9.0,3PlFEJ.O,4PZF9.0,5PZF10.0,5X,2P2F5.0. Il,AU
PRIN10&
PRIN107

C·· 12
. · . ··V=O.. ·
IF

PRIN106

(Nl.NE.O.l

'If=(R(4)··2+~(5)"·2+R(o)··Z)/N2-1.

PRIN109

H=R(1)-EARTHR
PRIN110
STH=SIN (THETA)
PRIN111
CTH=SIN (Pro2-THETA)
PRIN112
CARTESIAN COOROINATES OF RAY POINT. ORIGIN AT TRANSMITTER
PRIN113
XP=R(1) 'STH'SIN (PI02-PHI) -XR
PRIN114
YP=R(1)'STH'SIN (PHI)-YR
PRIN115
ZP=R(1)'CTH-ZR
PRIN116
CARTESIAN COORDINATES OF RAY POINT. ORIGIN AT TRANSMITTER ANOPRIN117

C·········

C········.
C·········
ROTATED
EP5=Xp· G1 (1,1) +yp. G1< 1,2) + Zp·G 1 (1, 3)
~CE2=ETA··2+ZETA··2

PRIN116
~I N1l 9
PRIN1Z0
PRt N121
PRIN12Z

<CE=SQRT (R"EZ)

PRIN1Z3

ETA=Xp·Gl(Z,1) +VP·Gl(l,Z)+ZP·G1(Z,3)
ZE T A%:XP.Gl (3,1) +yp. Gl (3,2) +ZP.G 1( 3,3)

C········· GROUND

~ANGE

PRIN124

RANGE=EART HR' ATAN2 (RCE. EA RTHR'EPS)

PRI N1Z5

C········· ANGLE OF WAVE NORMAL WITH LOCAL HORIZONTAL

ELL=ATANZ(R(') .SQRT (R(5)"ZtR(6)"Z))'OEGS
OISTAN~E FROM TRANSMITTER TO RAY POINT

PRIN1Z6

IF (NP.LT.ll GO TO 16
DO 1S I=1.N?
NN;NPR(I)
15 RPRINT(I)=R[NN)
16 IF (SR •• E.1.E-6) GO TO ZO
TOO CLOSE TO TRANSMITTER TO CALCULATE OIRECTION FRO"

PRIN1Z7
PRIN128
PRIN1Z9
PRIN130
PRIN131
PRIN13Z
PRIN133
PRIN134
PRIN13S

C.· •• • •• •• TRANSMITTER
PRINT 1500, V,NWHt,H,RANGE,ELL,POLAR,T,(RPRINT (NN' ,NN=l,NPU
1500 FORHAT (lX,E&.O,lX,A8,Fl0.4,F11.4,Z6X,F6.3,F9.3,F6.3,4F1Z.4)

PRIN13&
PRIN137
PRIN138

C········· STRAIGHT
LINE
(RCEZ'EPS"Z)
S~=SQRT

C.· .•.• ··•

.0 TO 40

PRIN139
PRIN140
PRIN1.1
IF (RCE.GE.1.E-6) GO TO 30
PRIN1.Z
C•• •• ••• •• NEARLY DIRECTLY ABOVE OR BELOW TRANSMITTER. CAN NOT CALCULATEPRIN143

C·········
ELEVATION ANGLE OF RAY POINT FROM TRANSMITTER
ZO EL=ATANZ(EPS.RCE)·OEGS

C............ AZIH~T~ DIRECTION FROM TRANSMITTER ACCURATELY
PRINT 2500, ~INWH",H,RANGE,EL,ELL,POLAR,TI(RPRINT(NN),NN%:l,NP1)
2500 FORHAT (lXIEo.0,lX,A6,Fl0.~,Fl1.4,17X,F9.3,F8.3,~q.3,F8.3,

1 .F1Z.,)
GO TO .0

PRIN144
PRIN145
PRIN146

PRIN147
PRIN148

80

C···~·····

AZIMUTH ANGLE OF RAY POINT FROM TRANSMITTER

30 ANGA=ATAN2(ETA,ZETAI
AZOEV=180. -AHOO (54 0.- (AZ1-ANGAl 'OEGS, 360.1
IF (R(51.NE.0 .. OR.R(61.NE.0.l GO TO 34

PRIN1~q

PRIN150
PRI N151
PRIN152

C········· HA~E NORMAL IS VERTICAL. SO AZIMUTH OIRECTION CANNOT BE
PRIN153
C········· CALCULATED
PRIN15~
PRINT 3000. ~.NWH"H,RAN;~.AZOEV,EL,ELl,~OLAR,T,(RPRINT(NN).NN=l, PRIN155
1 NPll

PRIN156

3000 FORHAT

(lX,E&.0,lX,A8,Fl0.~.Fl1.~.Fq.Jt8X,Fq.J,FS.3,Fq.3.F8.3,

~RIN151

1 4F12.41
GO TO 40
34 ANA=AN,A-ALPH
SANA=SIN (ANAl
SPHI=SANA'STHRISTH
CPHI=-SIN (PIOZ-ANAl'SIN (PIOZ-(PHI-PHIRll +SANA'SIN (PHI-PHIRI

PRIN158
PRIN159
PRIN160
PRIN161
PRIN162
PRIN163

1

.CTHR

PRIN16~

(540. - ( ATA ,~ 2 ( S PH I ,CP HI I - ATANZ (R ( 61 ,R (51 I I • 0 EGS , 360 • I PR IN 165

AZ A= 18 0 • - AHO 0

PRINT 3500,

V.NWHY.H,RAN~E,AZOEV.AZA,EL,ELLtPOLARtTt(RPRINT(NN),NN PRIN16&

1 =l,NPll

3500 FORHAT

PRIN167

(1(,E&.0,lX,A8.Fl0.4,Fl1.~,Z(Fq.3.F8.3},F9.3,F8.3,

1 4F1Z.41

PRIN169

C·········

PRIN170

40 LINE5=LINES+l
IF (NP.LE.31 GO TO 45
ADDITIONAL LINE TO PRINT REHAINING OEPENOENT INTEGRATION

C·········
C········· VARIABLES
c

c·········
PUNCH A RAVSET
IF (AlOEV.LT.-90.1
IF (AlA.LT.-90.1
TOEV=T-SR
NR=6
IF (W(571.EQ.0.l

AlOEV=AlOE~+360.

AlA=AZA+360.
GO TO 47

C········· PHASE PATH
NR=NR+l
POEV=R(NRl-S~

(W(581.EQ.0.l

c••• •••• •• ABSO~PTION

GO TO 48

NR=NR+1
ABSORB=R(NRI

C·········
48 IF

OO~PlER

SHIFT

(W(591.NE.O,1

~UNCH

~5QO,

PRIN171
PRIN172
PRIN173

PRIN174

F'RINT 4000, (RPRINT(NNl,NN=4,NPl
4000 FORHAT (99X,3F1Z,41
LINES=LINES+l
45 IF (CARO.EQ.O.l RETURN

.7 IF

PRIN1&8

OOPP=R(NR+ll

H~UNCH,RANGE,AZOEV.AZA,ELL,SR,TOEV,POEV.ABSORB,OOPP.

1 POLAR,IHOP,NWHY
4500 FORHAT (4P2F9.0,3P3F6.0,3PF8.0,3P4F6.0,2P2F5.0,Il.Al1
RETURN
ENO

81

PRIN175
PRIN176
PRIN177
PRIM178
PRIN179
PRI N180
PRI N181
PRIN182
PRIN183
PRIN184
PRIN185
PRIN186
PUN187
PRI N188
PRI N189
PRIN190
PRIN191
PRI N192
PRIN193
PRIN194
F'RIN195
PRIN196
PRI N197
PRIN198
PIUN199-

INPUT PARAMETER FORM FOR PLO TTING THE PROJECTION
OF THE RAY PATH ON A VERTICAL PLANE

Coor dinate s of the left edge of the graph:

Latitude

=- - - - - - -

Longitude = ________

rad
deg north (W83)
krn
rad
deg east (W84)
krn

Coordinates of the right edge of the graph:

Latitude

=

-------

Longitude = ________

rad
deg north (W85)
krn
rad
deg east (W 86)
krn

Height above the ground of the bottom of the graph = _ _ _ _ krn (W88)
rad
Distance between tic marks = _ _ _ _ _ _
de g (W87)
krn

(W81 = 1.)

82

INPUT PARAMETER FORM FOR PLOTTING THE PROJECTION
OF THE RAY P ATH ON THE GROUND

Coordinates of the left edge of the graph:

Latitude

=

- - - -- -

Longitude = ________

rad
deg
krn

north (W83)

rad
deg
krn

east (W84)

Coordinates of the right edge of the graph:

Latitude

=

------

Longitude = _ _ _ _ _ _ __

rad
deg
krn

north (W85)

rad
deg
krn

east (W86)

Factor to expand lateral deviation scale by = ______

(W82)

rad
Distance between tic Inarks on range scale = ______ deg (W87)
kIn

(W8l = 2. )

83

C
C

SU BR OUTINf RAYPLT
REPLACES SUBROUTINES RAYPLT,PLOT, AND LABPLT IF PLOTS ARE
NOT WAN fED OR IF A PLOTT fR IS NOT AVA I LABL E
COMMON I WW I IDIIO),WQ,W(4001
EQU IV ALENCE (PL T,WI8 11J
PLT=O.
EN TRY ENDPLT
RETURN
END

YPLTODl
YPL T002
YPL T003
YPL T004
YPL T005
YPL T006
YPL T007
YPL T008
YPLT 9 -

SUBROUTINE RAYPLT
RAYPOOI
WIBl)=l. PL OTS PROJE CTI ON OF RAYPATH ON VERTICAL PLANE
RAYP002
C
=2. PLOTS PROJE CTI ON OF RA YPATH ON GROUND
RAYP003
COM MON IP LT I XL,XR.YB,YT,RESET
RAYP004
COMMON ICONS TI PI,PIT2,PID2,DUM(5)
RA YP005
COMMON I FLGI NTYP,NEW WR,N EW WP,P ENET ,LI NES ,IH OP,HP UNCH
RAYP006
CO~MON RI61
IW'WI IDfl OI,W o ,W(4 00 1
RAYP007
EQUIVALENCE (TH,Rf2)),(PH,R(?,11
RAYPOOB
EQU IVA LENCE (EA RTHR ,WI2 1 ), (P LAT,WI 24JI ,(PL ON ,W(25) I ,(PLT,W(B l ll, RAYP009
1 IF ACTR ,W I 82 J I , (LLA T, W(8 3 I J , f LL ON , W{8 4 I J , (RLA T ,W ( 85 I I , (RLON ,w (86 J IR AYPO 1 0
RA.YPOll
2 .(TI C,W I B7J}' (H8,W(881 J
REAL LLA T,LLON,LTIC
RAYP012
LOGICAL NEWWR,NEWWP,PENET
RAYP013
IF (.NOT.NEWW R) GO TO 5
RAYP014
C
RA YP DI5
C
NEW W ARRAY - - REINITIALIlE
RAYP016
NEWWR=.FALSE.
RAYPOl1
RESET=I.
RAYP018
CONVERT COO RDI NA TES OF VERTICAL PLANE FROM GEOGRAPHIC TO GEOMAGNETIC
RAYP019
SW" S IN (PLAT)
RA YPD 20
CW=SIN (PID2-PLAT)
RAYP021
S LM= SIN (LLATI
RAYP022
CLM=SIN (PI02-LLAT)
RAYP023
SRM=SIN (RLAT)
RA YP024
CRM=SIN (PID2 - RLAT)
RAYP025
CDPHI=SIN (PI02-(LLON-PLONJ)
RAYP026
PHL=ATAN2(SIN ILLON-PLONI*ClM,CDPHr*SW*CLM- CW*SLMI
RAYP021
CTHL=CDPHI*CW*C LM+SW*SLM
RAYP028
STHL=SIN (ACOS (CTHL))
RAYP029
CDPHI=SIN (PID2-(RLON-PL ON) )
RAYP030
PHR=ATAN2ISIN IRLON - PL ON I* CRM .CDPHI*SW*CRM - CW*SRM)
RA YP031
CTHR~CDPHI*CW*CRM+SW*SRM
RAYP032
STHR=SIN (ACOS (CTHR))
RAYP033
CLR=CTHl*CTHR+S THL*STHR*SIN (PJ02-(PHL-PHRI I
RAYP034
SLR~SORT Il.-CLR**2 J
RAYP035
IF (PLT.EQ.2.) GO TO 3
RA YPO 36
FACTR=l.
RAYP031
RO = EARTHR+HB
RA YPO 38
ALPHA:.S*ACOS ( CLRI
RAYP039
XR=RO*SIN (ALPHA)
RAYP040
XL=-XR
RAYP041
YB=RO*SIN (PID2-ALPHA)
RAYP042
YT=YB+2.*XR
RAYP043
GO TO 5
RAYP044
3 IF (FACTR.EO.O.1 FACTRcl.
RAYP045
ALPHl:ATAN2(STHR*SIN (PHR-PHL),ICTHR - CTHL*ClRI/STHLI
RAYP046
XL"'O.
RAYP041
XR,EARTHR*ACOS (CLR)
RAYP048
YT=O.S*XR/FACTR
RAYP049
YB =-YT
RAYP050
C

84

C

RAYP051
RAYP052
RAYP053
RAYP054
RAYP055
RAYP056
RAYP 0 57
IF (IHOP.NE.O) NE'Io/=n
RAYP058
IF (PLT.Eo.2. 1 GO TO 10
RAYP059
CA LL PLOT (R1l)*SINICEA - ALPHA),RI11*SINIPrD2 -lcEA-ALPHA1 ).NEW)
RAYP060
RETURN
RAYP061
SL=SQRT (1.-CL**21
RAYP062
TMPl=STH*SIN (PH-PHLI
RAYP063
TMP2=(CTH-(THL*CL)/STHL
RAYP064
ALPH2=O .
RAYP065
IF (TMPl.NE.O •• OR.TMP2.NE.O.J ALPH2=ATAN2(TMPl,TMP21
RAYP066
CALL PLOT (EARTHR*CEA,EARTHR*ASJNISL*SIN (ALPHl-A LPH 21) , NEWI
RAYP067
RETURN
RAYP068
RAYP069
DRAW AXES AND CALL FOR LABELING AND TERMINATION OF THIS PLOT RAYP070
EN TR Y ENDPL T
RAYP 071
TICKX=Q.Ol*IYT-YBl
RA ypon
IF (PL T.EO.2.) GO TO 25
RAYP073
Rl=EARTHR-TICKX
RAYP074
X""XL
RAYP075
Y=yB
RAYP076
CALL PLOT (X,Y,11
RAYP077
NTIC =2
RAYP078
IF ITIC.NE.D.) NTIC=NTIC+2.*AlPHA/TIC
RAYP079
NLINE=MAXO 11.100/NTICl
RAYP080
DO 20 I=bNTIC
RAYPO 81
ANG =-ALPHA+ ( I-I).TIC
RAYP082
CALL PLOT (Rl*SIN (ANG),Rl*5IN (PID2 -ANG ),Q)
RAYP083
CALL PLOT (X,y,aJ
RAYP084
DO 20 J=bNLINE
RAYP085
ANG=ANG+TIC/NLINE
RAYP086
X-EARTHR-SIN IANGl
RAYP087
Y=EARTHR*SIN (PJ02-ANG)
RAYP088
CALL PLOT (X,y,o)
RAYP089
CALL PLOT (XR,YB.OI
RAYP090
GO TO 50
RAYP091
DTIC=TIC_EARTHR
RAYP092
L TIC=DTICIFACTR
RAYP093
TICY=XL+O.Ol*IXR -XL )
RAYP094
NTIC=YT ILT IC
RAYP095
T IC1=-L TIC-NT IC
RAYP096
CALL PLOT (XL,YB,ll
RAYP097
NTIC'2*NTIC+l
RAYP098
00 30 1=1 ,NT Ie
RAYP099
Y.TICl+( I-I)*LTIC
RA YP 100
CALL PLOT (XL,Y,O)
RAYPI0l
CALL PLOT (TIC Y,Y,O)
RAYPI02
CALL PLOT (Xl,Y,OJ
RAYPI03
CALL PLOT (XL,YT,O)
RAYPI04
CALL PLOT (XL,O.,11
RAYPI05
NTIC·IXR-XLl/DTIC
RAYPI06
00 40 I=I,NTJC
RAYPI07
X-I-DTIC
RAYPI08
CALL PLOT (X,O.,OI
RAYPI09
CALL PLOT (X,TICKX,OI
RAYPllO
CALL PLOT (X,O.,OI
RAYPlll
CALL PLOT IXR,O.,OI
RAYPI12
CALL LABPL T
RAYP113
CALL PLTEND
RAYP1l4
RETURN
RAYP115
END
RAYPl16-
