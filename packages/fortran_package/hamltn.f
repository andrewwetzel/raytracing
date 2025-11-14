SUBROUTINE HAMLTN
SUBROUTINE LABPLT
These rO:ltine5
SUBROUTINE PLOT
make .~p the
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

5 STH=SIN ITHI
CTH=SIN IPID2-THI
CR%CTHR*CTH+STHR*STH*SIN IPIOZ-IPHR-PHI'
CL=CTHL*CTH+ST~L*STH*SIN (PID2-IPHL-PHll
CEA=ATAN2(CR-CL*CLR,CL*SLRI
NEW=1

10

C
C

20
25

30

40
50

85

SUBROUTINE PLOT (X.Y.NEWI
COMMON IPLTI XMINO.XMAXO .YMrN O.YMAXn .RESET
(OMMON 1001 INT,IORdTdSdCdC(,IXdY
DATA (INITAL=11 ,IMINX= OI ,IMINY=OI ,(M AXX= 10231 .(MAXY=10231.
1 IMINXO=231,IMINYO=23J,(MAXXO=1023),IMAXYO=1023J
C

C

INITIALIZE LIBRARY PLOTTING ROUTINES
IF (INITAL.EO.OI GO TO I
INITAL=n
CALL DDINIT (l,lH I

C

C

COMPUTE SCALE FACTORS
IF (RESET.EO.O.I (,0 TO 5
RESET=O.
XSCALE=(MAXXC-MINXQI/(XMAXO-XMINOJ
YSCALE={MAXYO-MINYOI/CYMAXO-YMINO'
XMIN =XMINO-IMINXQ- MJNXJ/XSCALE
YMIN=YMINO-IMINYO-MINYI/YSCALE
XMAX=XMAXo+IMAXX-MAXXOI/XSCALE
YMAX=YMAXQ+IMAXY-MAXYOJ/YSCALE

C

C

STA~T A NEW LINE
5 IF (NEW.EO.OI GO TO 10
IX=MINXQ+IX-XMIN OI*XSCA LE
IYzMINYO+(Y - YMINOJ*VSCALE
IF CIX .GE.MINX.ANO.IX.LE.MAXX .ANO.I Y. GE.MINY.AND.IY.LE .MAXYI
I CALL DDBP
GO TO 50

C

C

C

C

C

HORIZONTAL DISPLACEMENT
10 XS=X-XOLD
YS=Y-YOLD
IF (XSI llt12,16
NEGATIVE
II XI=XMAX
X2=XMIN
GO TO 20
ZERO
12 IF CYSI 13,50,14
13 SI=(YMAX -YOLDI /ys
S2=(YMIN-YOLDI/yS
GO TO 40
14 SI=(YMIN-YOLOI/yS
S2=IYMAX-YOLDI/YS
GO TO 4"
POSITIVE
16 XI=XMIN
X2=XMAX

C

C
C

C

(

VERTICAL DISPLACEMENT
20 IF IYS) 21-22,26
NEGATIVE
21 Y!=YMAX
Y2=YMIN
G6 TO 30
ZERO
72 S I=( XI - XO LOI/ XS
S2 =I X2-XOLOJ/XS
GO TO 40
POSITIVE
26 Y1=YM;!N
Y2 =YMAX

C

':10 Sl=AM;AXli {X1-XOLDI/XS,IYI-YOLD)/YSI
S2=AMI N1 ( I X2-XOLD I IXS, (V2- YOLD) IYS J

86

PLOTOO I
PLOT002
PLOT003
PLOT004
PLOT005
PLOT006
PLOT007
PLOT008
PLOT009
PLOTOIO
PLOTO II
PLOTOl2
PLOT Ol3
PLOTOl4
PLOTOl5
PLOTOl6
PLOTOl7
PLOTOl8
PLOTOl9
PLOT020
PLOT021
PLOTO 2 2
PLOT023
PLOT024
PLOT025
PLOT026
PLOT027
PLOT028
PLOT029
PLOT030
PLOT031
PLOT032
PLOT033
PL OT034
PLOT035
PLOT036
PLOT037
PLOT038
PLOT039
PLOT 040
PLOT041
PLOT042
PLOT043
PLOT044
PLOT045
PLOT046
PLOT047
PLOT048
PLOT049
PLOT050
PLOT051
PLOT052
PLOT053
PLOT054
PLOT055
PLOTO 56
PLOT057
PLOT058
PLOT059
PLOT06 0
PL OT061
PLOT062
PLOT063
PLOT064
PLOT065

C
C

PLOT LINE -- CHECKING FOR BORDER CROSSINGS
40 S=SQRTIX5**2+YS**21
IF {S2.LT.O •• OR.S*Sl-S.GT.O.1 GO TO 50
IF

C

(S1_lT.a.1

Gf') TO 42

PREVIOUS POINT OFF GRAPH
IX=MINXO+(XOLD+XS*Sl-XMINO'*XSCALE+O.S
IY=MI NY O+IYOLD+YS*Sl-YMI N01*YSCALE+n.5
CALL DDBP
42 IF (S*S2-S.GT.O.1 GO TO 44
CIJRREN T POINT OFF GRAPH
IX =MINXQ+(XOLD+XS* S2 -X MIN01*XSCAlE+O.S
IY=MINYO+(YOLD+YS*S2-YMINo1*YSCAlE+O.5
CALL DOVC
GO Tn 50
CURRENT POINT ON GRAPH
44 IX=MINXQ+{X-XMINOI*XSCALf+O.5
IY=MINYO+(Y-YMINOI*YSCALE+O.5
CALL DOVC

C

C

C
C

EXIT ROUTINE
SO XOLD =X
YOLO=Y
RETURN

C
C

TERMINATE THE CURRENT PLOT
ENTRY PL TEND
CALL ODFR
RETURN
END

C

SUdRouTINE LA3PLT
LABEL THE CURRENT PLOT

LABPao 1

JIMENSIDN lABEL(9) ,TYPE(3)

LABPJ03

LABPOG2

COMMON IJOI INT,IOR,IT,IS,IC,ICC,IX,IY
CO~MON

ICO~STI

LARPJ04

PI,PIT2,PI02,OEGS,QUM(4)

COHMON /FLG/ NTYP,NlWWP,NEWWP,PENET,LINES,IHOP,HPUNCH
CJMHON IWW/ ID(lO)tWO,W(~OJ)
1

PLOT066
PLOT067
PLOT068
PLOT069
PLOT070
PLOT07!
PLOT072
PLOT073
PLOT074
PLOT075
PLOT076
PLOT077
PLOT07B
PLOT079
PLOTOBO
PLOTOB!
PLOTOB2
PLOT083
PLOT084
PLOTOB5
PLOT086
PLoTOB7
PLOTOBB
PLOTOB9
PLOT090
PLOT09!
PLOT092
PLOT093
PLOT094
PLOT 95-

EQUIVALENCE tEART"'R,W(2», (F,W(6») ,(AZ1,W (10», (PLT,W(8U),
(FACTR,W(8Z)),(TIC,W(87))
LJGICA L NEWWR,NEW,,"P,PENET
~EAL LTre
JATA (TYPE::;8H::XTR.AORO,8H~O FIELO,8t-iORDINARYl

IOR=IT=O
IS=2
IX::;O

LABP005
LABPJ06
LABPl)07

LABPJOB
LABPilOg

LABPQ10
LABPill1

LABP012
LABPJ13
LABP014

$

IY::;1023

$

CALL DOTAB

$

CALL OOTEXT (7.IO)

LA8POl5
LABPOl6
LAB P017
AZA::;AZ1"OEGS
LABPOl8
OT IC=TI C'EARTHR
LABP019
ENCODE (72,100Q,LABEL)
~,AZA,TYPE(NTYP),DTIC
LABP020
1000 FORMAT (3HF =,F 7.3,6H, Al =,F7 .2,2H, ,A8,2H, ,F7.2,24H K~ BETWEEN LABP021
ITICK MARKS'.)
LABP022
IX=O
$
1.=991
$ CALL OOTAS
$
CALL OOTEXT (9.LABEL)
LABP023
IF (PLT.EQ.1.) RETURN
LABP02 ..
LTIC=DHC/FACTR
LABP025
ENCODE (32.2000.LAB[L)
LTIC
LABP026
200n FORHAT (F7.2.2 .. H KM BETWEEN TICK HARKS'.)
LABP027
IOR=I
LABP028
IX=O
$
H =O
$
CALL OOTAB $ CALL OOTEXT ( ... LABEll
LABP029
IOR=O
LABP030
RETURN
LABP031
END
LABP 32NOATE =IOAT E( 0)
CALL DOTEKT (I.NOAT.)

87

C

SUBROUTINE RKAH
NUMERICAL INTEGRATION OF DIFFERENTIAL EQUATIONS
COHMON IR(I NN,SPACE,HOOE.E1HAX.E1HIN,EZHAX,EZHIN,FACT,RSTART
COHHON H20) .T.STEP.OYOT(ZO)
OIHENSION OELY(".20).BET(').XV(S).FV( ... 20).YU(S.20)
TYPE OOJBLE YU
IF (RSTART.E~.O.) GO TO 1000
LL=HH=1
IF (HOOE.Eo..lI HH="

ALPHA=T
E~t1:;O.O

BET(lI=BET(Z)=O.S
BET(3)=I.J
BET (")=0.0
STEP=SPACE
~=19.01270 .0
X;<HH)=T
IF (EU4IN.LE.O.l E1HIN=EUAX/SS.
IF (FACT.LE.O.) FACT=O.S
CALL HAHLTN
OJ 320 I=I.NN
FV(HM,I)=DYOT<I)
320 YU ( tiM , I ) :; '( (I)
~S TART= O.

GO TO 1001
1000 IF (HOOE.NE.lI GO TO 2000
C
RUNGE-KUTTA
C
lUJl 00 103 .. K=I, ..
00 13S0 I=1.NN
OELY(K,I)=STEP·F~(HH,I)

Z=YU(HH,I)
13S0 Y(I)=Z+BET(K)·OELY(K.I)
T=BET(K)·STEP.XV(HH)
CALL HAHLrN

00 1034 I=l.NN
103 .. FV(MH.I)=OYOT(I)
00 1039 I=I.NN

OEL=(OELY(1.I)+2.0·0ELY(2,I'+Z.O·DELY(3.t)+OELY(4,I»1&.0
1039 YU(HH+l.I'=YU(HH,I,tOEL

MM=HM+l
XV(HH)=XV(HH-ll+STEP
00 1 .. 00 I=I.NN
y(I)=YU(HH.I)
T=XV(MH)
CALL HAHL TN
IF (HOOE.EQ.l) GO TO .. 2
00 ISO I=I.NN
ISO FV (HH, I I =OYOT< Il
IF (HM.LE.3)
TO 1001

.0

C
AOAH;-~OJLTON
C
2000 00 20 .. 6 1=1. NN
OEL=STEP'(55.·FV(~.1)-59.'FV(3.1).37.·FV(2.I)-q.·FV(1.1))/2 ...

Y(I)bYU(4.I)+OEL
OELY(1.Il=Y<Il
T=XV( .. )+STEP
CALL HAHLrN
XV(S)=T
DO 20S1 1=1. NN
OEL=STEP·(9.·OYOT(I)+19.·FV( ... 1r-5.·FV(3.1)+FV(Z.I))/Z ...
YU (5, I) =YU (4, I' +0 El
20S1 HI) =YU (S,!)
CALL HAHLrN
IF (HOOE.LE.2) GO TO .. 2

88

RKAHOOI
RKAH002
RKAHOOJ
RKA HOO ..
RKAH005
RKAHOO&
RKAH007
RKAH006
RKA H009
RKAH010
RKA HOll
RKA H012
RKAH013
RKAH01"
RKAM01S
RKAM01&
RKA MOl7
RKAH016
RKA H019
RKA H020
RKAH021
RKA H022
RKAH023
RKA M02 ..
RKA M025
RKAH02&
RKAH027
RKAH026
RKAH029
RKAM030
ROH031
RKAM032
RKAHOJ3
RKAHOJ ..
RKAH035
RKA M03&
RKA H037
RKAH036
RKAHOJ9
RKA HO .. O
RKA H041
RKAHO .. 2
RKA HO .. 3
RKAHO ....
RKAMO .. S
RKA H O~&
RKAHO .. 7
RKA H046
RKAHO .. 9
RKAH050
RKAH051
RKAH052
RKAMOS3
RKAH054
RKAH055
RKAH05&
RKAH057
RKAH058
RKAH059
RKAHO&O
RKAH061
RKAH062
RKAH063
RKlH06 ..
RKAH065

c
C

ERROR ANALYSIS
SSE=O.O
DO 3033 1=1. NN
EPSIL=R·ABS(Y(I)-oELY(l.I))
IF (HOoE.EQ.3.ANo.Y(!) .NE.O.) EPSIL=EPSIL/ABS(y(I))
IF (SSE.LT.EPSILl SSE=EPSIL
3033 CONTINUE
IF (E1MAX.GT .SSE) GO TO 3035
IF (ABS(STEP).LE.E2MIN) ;;0 TO ~2
LL=HH=l

STEP=STEP·FI\::;r
GO TO 1001
3035 IF (LL.LE.l.0~.SSE.GE.El~IN.OR.E2MAX.LE.ABS(STEP))
LL= 2
~M=3
X~(2)=XV(3)

X~(3)=X~(5)

DO 5363 I:::l t N"
F'J(Z,I'=FV'(3,I)
F~(3.Il=OYOT(!)

YU(Z,I) =YJ<3,I)
531)3 YU(3,lJ =,('.)(5,1)

5TEP=2.0·STEf)
GO TO 1001

C
C

EXIT ROUTINE
42 LL=2
MM=4
)0 12 K=1.3
X~(K)=X~(K+1)

00 12 l=l.NN

F'J(K,I.:FV(K+1,I)
12 YU(K,U=YU(I(+1 , D

XV(4)=XV(S)
00 52 l=l . NN
n(4.Il=oYoT(!)

52 YU(4,I)=YU(S,I)
IF (HOOE.LE.2) RETURN
E=ABS(XV(4)-ALPHA)
IF (E.LE . EPM) GO TO 2000
EPH=E
RETURN
END

89

GO TO

~2

RKAH066
RKAH067
RKAH068
RKAH069
RKAH070
RKAH071
RKAH072
RKAH073
RKAH074
RKA H075
RKAM07c
RKA H077
RKAM078
RKAH079
RKAH080
RKAH081
RKAH082
RKAH083
RKAM084
RKA M085
RKAH08c
RKAH087
RKAH086
RKAH089
RKA H090
RKAM091
RKAH092
RKA H093
RKAH094
RKA H095
RKAH096
RKAH097
RKAH098
RKAH099
RKA H10 0
RKA H 10 1
RKAH102
RKAH103
RKA Hl04
RKAH105
RKAH10c
RKAH107
RKAH108
RKA Hl09-

SUBROUTINE HAMLTN

HAML001
HAML002
HAML003
HAML004

C·········
CALCULATES HAMILTONS EQUATIONS FOR RAY TRACING
COHMON ICONSTI PI,PIT2,PI02,DEGS,RAO,K,C,LOGTEN
COHMON IRINI MOORIN(3) ,COLL,FIELO,SPACE,KAY2,KAYZI,

1
~,

H,HI,PHPT,PHPTI,PHPR,PHPRI,PHPTH,PHPTHI,?HPPH,PHP?HIHAHl005
PHPKPH,PHPKPI
HAML006

PHPOH,PHPO"I.PHPKRtPHP(~ItPHPKTH.PHPKTI,

3 ,KPHPK, KPHPKI, POLAR, POLARI, LPOLAR,LPOLRI
COMMON RIZO),T,STP,OROTIZO) IWW/IO(10),WO,WI400)

HAML007
HAML008

EQUIVALENCE UH,R{Z)),(PH,R.(3)),CKR,R(4)),(KTH,R(S)),CKPH.R(6)',

HAHL009

1 IOTHOT ,OROHZ», I OPHOT ,DROT (3», IDKROT,ORDT(4», (OKTHOT, OROTlS»
Z CDKPHOT,ORDTlG»,(F,WIG»
REAL KR.KTH,KPH,KPHPK,KPrlPKltlPOLA~tLPOLRItlOGTEN.KtKAY2tKA Y2I
DH;PITZ·l.Eo"c
STH:SIN(TH)
CTH=SIN(PIO?-TH)
RSTH=R( U'STH
RCTH:R(1)'CTH
CALL RINOEX
ORO T:-PHPKRI (PHPOH'C)
OTHOT:-PH'KTH/(PHPOM'R(1)'C)
OPHOT=-PHPKPH/(PHPOH'RSTH'C)
DKROT=PHPR/(?HPOM'C)+KTH'DTHOT+KPH'STH'OPHOT
DKTHDT=(PHPTHI (PHPOM'C)-(TH'OROT+KPH'RCTH'DPHDT) IR(1)
OKPHOT: (PHPPHI (PHPOM'C)-KPH'STH'OROT-KPH'RCTH'OTHOT)/R STH
NR=G

,HAML010
HAML011
HAHL012
HAHL013
HAHL014
HAML01S
HAML01&
HAML017
HAML018
HAHL019
HAHL020
HAML021
HAHL022
HAHL023
HAHL024
HAML02S

C········· PHASE PATH

IF (W(S7l.EQ.O.) GO TO 10
NR:NR+1
OROTlNR) =KPHPK/PHPJM/OH
C········· ABSORPTION
10 IF (W(SS) .D.O') GO TO 15
~R=NR+l

ORDT(NR); 10./LOGTEN"KPHPK"KAY21/(KR"KRtKTH"KTHtKPH"KPH)/PHPOH/C

HAHL026

HAHL027
HAML028
HAML029
HAHL030
HAML031
HAHL032
HAHl033

C · · · · · · · · · DOPPLER SHIFT

HAI'1LD34

15 IF (WI59) .EQ.Ool
NR=NR+l

HAHL035
HAHL03G

GO TO 20

D~DT (NR) :::-PH~T IPHPOM/C/PI T2
C·· .. • .. •••• GEOt.fET~I::AL PATH LEN:;rH

HAML037
HAI'1L038

20 IF (W(GO) .EQ.O,) GO TO 25

HAHL039

~R~NR+l

ORDT(NR):::-SQRr(PHP~R··2+PHP~TH··Z+PHPKPH··2)/PHPOH

c····2S . ····
CONTINUE

OTHER CALCULATIONS

Ie

HAML040
HAML041
HAI'1L042

HAML043
HAHL044
HAHL04S-

RETURN
END

90

APPENDIX 2.

VERSIONS OF THE REFRACTIVE INDEX
SUBROUTINE (RINDEX)

This ray tracing program gains versatility without sacrificing speed

by having several versions of some of the subroutines.

For example,

the 8 versions of the refractive index subroutine allow the user to decide
for each ra y path calculation whether to include or ignore various as pects
of the propagation medium such as the earth's magneti c field or collisions
between electrons and neutral air molecules.
If collisions are included, the user has the option of using the Apple-

ton_Hartree form.ula (which assumes a constant collision frequency) or the
Sen- Wyller formula (which assumes a Maxwell distribution of electron
energies and a collision frequency proportional to energy).

The Sen-

Wyller formula is generally assumed to be more accurate, especially
in the l ower ionosphere, but the Appleton-Hartree formula can often be
used with an effective collision frequency profile to save computer time.
When the effect of the earth's magnetic field is included and ray
paths are calculated near vertical incidence, a spitze (Davies, 1965, p.
202) often occurs in the ray path.

(At a spitze, the usual formulas for

refractive index become indeterminate because the wave normal is parallei with the earth's magnetic field and the wave frequenc y equals the
local plasma frequency.)

Two versions of the refr active index subrou -

tine have been developed to calculate ray paths through a sp it ze .

These

two versions will also work in the absen ce of a spitze, but the standard
versions are much faster.
The input to the refractive index subroutines is through blank common and common blocks /XX / , / yy /, and / ZZ/.
mon block /RIN /.
entry RINDEX.
tion.

Output is through com-

The refractive index subroutine is called through the

The subroutine names are used only for user identifica-

The following 8 versions of the refractive index subroutine are

91

listed in this appendix:
a.

Subroutine AHWFWC (Appleton-Hartree formula
with field, with collisions)

93

Subroutine AHWFNC (Appleton-Hartree formula
with field, no collisions)

94

Subroutine AHNFWC (Appleton-Hartree formula
no field, with collisions)

96

Subroutine AHNFNC (Appleton-Hartree formula
no field, no collisions)

97

Subroutine BQWFWC (Booker Quartic with field,
with collisions)

98

Subroutine BQWFNC (Booker Quartic with field,
no collisions)

100

g.

Subroutine SWWF (Sen- Wyller formula with field)

102

h.

Subroutine SWNF (Sen-Wyller no field)
Subroutine FGSW
Subroutine FSW
Fresnel integral function C
Fresnel integral function S

105
106
106
108
108

b.
c.
d.
e.
f.

92

C
C

SUBROUTINE Ai~fWC
CALCULATES THE REfRACTIVE INDEX AND ITS GRADIENT USING THE
APPLETON-HARTREE FJ~~ULA WITH FIELO, WITH COLLISIONS

WfWC001
WfWC002
WFWC003

COHMON ICONSTI PI,PIT2,PI02,OEGS,RADIAN,K,C,lOGTEN

WFWCD04

COHHON /RINI MOORIN(3) ,CJ_L,FIELJ,SPACE,KAY2,H,PHPT,PHPR,PHPTH,

WFWC005

PHPPH,PHPOH,PHPKR,PHPKTH,PHPKPH,I(PHPK,POLAR,LPOLAR

HfWC006

1
COMMON

IXXI 1'1:10)((2) ,X,PX?R,PXPTH,PXPPH,PXPT,HMAX

WFWCOQ7

COHHON IYYI "OOY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR\PYRPT,PXRPP,YTH,PYTPRWFWC008
1
,PYTPT,PYTPP,YPH,PYPPR,PYPPT,PYPPP
WFHCOOq
COMMON IZZI MOOZ,Z,PZPR,PZPTH,PZPPH
COHMON R,TH,Pri,KR,KTH,KPH
IWWI IO(10J,HO.W(400)
COMMON IRKI N,STEP,MOOE,£1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
EQUIVALENCE (RAy,~(ll) ,(F,W(6))
LOGICAL SPACE
REAL KR,KTH,KPH,K2

WFWC010
WFWC011
WFWC012
WFWC013
WFWC014
WFWC01S

COMPLEX N2,PNPR,PNPTH,PNPPH,PNPVR,PNPVTH,PNPVPH,NNP,PNPT ,

WFWC016

1

PO LA R. l POL ARt I, U , RAO ,0, PNPPS, P NPX, PNPY t PNPZ, UX ,UX 2 ,[)2,

?

KAY2.~,PHPT,PHPR,PHPTH,PHPPH,PHPOH,PHPK~tPHPKTH,PHPKPH,

3

KPHPK
lATA (MOORIN=8HAPPLETON,8H-HARTREE,8H FORMULA) ,(COLL=1.),
(fIELO=1.),
1
2
(X=O . I,(PXPR=O.),(PXPTH=O.),(PXPPH=O.),(PXPT=O.),
(Y = 0 • ) , (P Y PR= O. ) , (pr? T H =0 .) , ( PY PP H=O • ) , (Y R= O. ) • (PYRP R =0 • ) ,
3
(PYRPT=O.) , (PYRPP=O.) , (YTH=Q.), (PYTPR=O.) , (PYTPT=O.) ,
"
:;
(PYTPP=O.), (YPH=O.), (PVPPR=O.), (PYPPT=O.),(PYPPP::cO.)
:;
,(Z=O.J,(PZPR=O.),(PZ?TH=O.),(PZPPH=O.),
7
tI=(0 .. 1.)),(ABSLlH=1.E-S)
ENTRY RINOEX
OH=PITZ'1.E6"
C2=C'C
K2=KR'KR+KT~' KTH+KPH'KPH
OH2=OM'OH
VR =C/OH'KR
~TH=C/OH'KTH
~PH=C/OH·KP .1

CALL ELECTX
CALL MAGY
~2;VR""2+~TH·.2+VPH··2

VOO TY=~ R' r R+VTH'Y T H+VPH'rPH
YLV=VOOTY/V2
YL2=VOOTY"21V2
YT2=Y"2-YL2

WFW C017
WFHC016
Wf'W C01. 9
WfWC020
WfWC021
WfWC022
WF WC02 3
WFWC024
WFWC025
WFWC02&
WFWC027
WFliC028
WFWC029
WFWC030
WFWC031
WfWC032
WfNC033
WfWC034
WFWC03S
WFWC036
WfWC037
WFWCQJ8
WfN C039
WFWCO~O

NFIIC041
NfNCO~2

YT~=YTZ'YT2

WFNCO~3

CALL COLfRZ
U=CHPLX(1.,-Z)
UX=U-X
UX2=UX'UX
RAO=RAY 'CSQRT (Yh+4 .·YL2·UX2)
0=2 •• U·UX-YT2+RAO
02=0-0
N2=1.-2.-X'UX/O
PNPPS=2 •• X'UX'(-1.+(YT2-2.'UXZ)/RAO)/02
PPSPR =YL2/Y"?YPR -(VR"PYRPR+VTH.PYTPR+VPH"PVPPR).YlV

WfWC044
WFNCO~S

WfWC046
WfWCO~7

WFWC 0~8
WFWC049
WfNCOSD
WFWCOS1
WFWCOS2
WFWC053
PPSPTH=YLZ/Y.PYPTH-(VR.PYRPT+VTH"pYrpT+VPH·PYPPT).YL~
WFWC054
PPSPPH=VL2/Y.~YPPH-(VR"PYRPP+VTH.PYTPP+VPH.PYPPP).YlV
WFHC05S
PNPX=-(Z."U"UX2-YTZ.(U-Z •• X)+(YT4.(U-Z •• X)+4 •• VL2.UX·UXZ)/RAO)/OZ WFWC05&
?NPY=2 •• X.UX. (-YTZ+ ('1T4+2 ."YL2"UXZ) IRAO) I (OZ·V)
HFWC057
PNP Z= I- X. (-2.' U XZ- YTZ +YTIt IRA 0) 102
WfW COS 8
PNPR =PNPX·PXPR +PNP'1.PYPR +PNPZ·PZPR +PNPPS.PPSPR
WFWC059
?NPTH=PN?X+PX~TH+PNP'1.P.YPTH+PNPZ.PZPTH+PNPPS·PPSPTH
WFWCO&O
PNPPH=PNPX.PXPPH+PNPY.PY~PH+PNPZ.PZPPH+PNPPS.PPSPPH
WFWCO&1
PNPVR =PNPPS"(VR ·YL2/V2-YU'·YR )
WFWCO&Z
PNP VTH= PNPPS. (VTH" Yl21 V2-YLV. Y TH)
WFW C 063
PNPVPH=PNPPS' (VPH.YL21 V2-YLV.YPH)
WFWC064
NNP=N2-(Z.4X.PNPX+Y4PNPY+Z4PNPZ)
WFWCO&5

93

P ,\ lPT=PN PX" PXPT

SPACE;RE AL (N ZI • Ell.. 1.. AND. ABS (A I HAG (NZ I I. LT. ABSLIH
POLAR;-I·SQRT(VZI·(-YTZ.~AOI/(Z.·VOOTY·UXI

;4M=(-YT2+RAO'/(2.·UX,
LPOLAR=I"X"SQRT(YT2)/(UX"(U+GAM))

KAYZ;OHZlCZ'NZ
IF(RSTA~T.EQ.O.I GO TO 1
SCALE=SlRT(REALIKAYZ'/KZI
KR =SCALE'KR
KTH=SCALE"KTH
KPH=SCALE"KPH
1
CONTINUE
C.... ~·~·· .. • CAlCULAT£S A HAHllTJNIAN H
H=.S·(CZ·KZ/OHZ-NZI

C· .. ••••••• AND

HFHC07~

ITS PARTIAL DERIvATIVES WITH RESPECT TO
THETA, PHI, OMEGA, KR, KTHETA. AND KPHI ..

C········· TIME, R..

PHPT =-PNPT
PMPR =-PNPR
PHPTH=-PNPTH
eHPPH=-PNPP;
PHPOH=-NNP/OH
PHPKR =CZ/OHZ'KR -C/OH"PN?VR
PHPKTH= CZI OHZ' KTH -C/OH' PN PHH

WFWC081

HFHC08~

HFWC08S
HFHC086
WFWC087
HFHC088
WFWC089
WFWC090
WFWC091
WFWC09Z

PHPKPH=CZ/OHZ'KPH-C/OH"P~PVPH

SUBROUTINE AHWFNC
CALCULATES THE REFRACTIVE INOEX ANO ITS GRAOIENT USING THE
APPLETON-HARTREE FOR~ULA wITH FIELO, NO COLLISIONS
COHNON ICONSTI PI,PITZ,PI02;OEGS,RAOIAN,K,C,LOGTEN
~ONHON IRINI ~OOR!N(3I,COLL,FIELO,SPACE,KAY2,KAYZI,

WFNC001
WFNCOOZ
WFNC003
WFNCOO~

WFNCOOS

H,HI,PHPT,P~PTI,PHPR,PHPRI,PHPTH,PHPTHI,PHPPH,PHPPHIWF NCaD6
,PH POM, PHPOMI, PH~K.R, PHPKR I ,PHPI<TH, PHPKT I , PHPICPH, PHPKPIWFHCaa 7

1
2

3
COHMON
COHMON

,K PHPK ,KPHPKI, PO LA R,POLARI,LPOLAR, LPOLRI, SGN
WFNC 00 6
IXXI ~OOX(2),X,PXPRtPXPTH,PXPPH,PXPT,HHAX
WFNC009
IYYI HOOY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRPT.PVRPP,YTH,PYTPRHFNC010

1

,PYTPT,PYTPP,VPH,PYPPR,PYPPT,PYPPP

CJNHON Illl HOOl,l(~1
COHHON IRKI N,STEP,HOOE,E1HAX,E1NIN,EZHAX,EZHIN,FACT,RSTART
~OHHON ~,TH,~H,KR,KTH,KPti
IWH/IO(lD},WO,W(4DO'
EQUIVALENCE (UY,H(1II,(F,W(611
LOGICAL SPACE
REAL

KR.KTH,KPH,K2,KPHPK,KPHPKI,ICAY2,KAY2I,N2,N~P,LPOlAR,LP OLRI

DATA (HOORIN=6HAPFLETON,8H-HARTREE,8H FORMULAI,(COLL=O.I,
1
(FI EL 0= 1. I , ( KAYZ I =0. I , ( HI = O. I , ( PH PTI = O. I , ( PHPR 1= 0 .) ,
2
(PHPTHI=O.I,(PHPPHI=O') ,IPHPOHI=O.I, (PHPKRI=O.I,(PHPKTI=O .1,
3
(PHPKPI=D.I,(KPHPKI=O.I,(POLAR=O.I,(LPOLAR=O.I,
(X=O . ), (DXPR=O.), (PXPTH=O.),(P)(PPH=O.),(PXPT=O.).
(Y = 0 • , t (P Y PR= 0 • ) , (PY P T H =0 • ) , ( PY PP H=D • ) , (Y R= 0 • ) , ( PYR?R=O • ) ,
(PYRPT=O.) ,(P'YRPP=O.) t (YTH=O.), (PYTPR=O.) ,(PYTPT=O.) t
t P Y T PP= o. } • ( Y PH= 0 • ) t (P Y PP R = 0 • ) , (P YP;:) T= 0 • ) , ( py ppp = 0 .) ,

It
:;;

51
7

6

HFH C07S
HFHC076
HFHC077
HFWC078
WFHC079
WFHC080
WFHC08Z
HFHC083

KPHPK=NZ
RETURN
ENO

C
C

HFHC066
HFHC067
HFHC066
HFHC069
HFHC070
HFHC 071
WFHC07Z
HFHC073

(MOOl=lM I, (U=1.1
ENTRY RINJE X

WFHe011

WFNC012
WFNC013
WFNe01,.

WFNC01S
WFNC016
WFNCD17

WFNC016
WFN COL 9
WFNCOZO
WFNCOZ1
WFNCD22
WFN C02 3
WFNC024
HF NCO 2 5

"FNCOZ6
WFNCOZ7

OH=prT2.1.Eo·~

WFNC026

CZ=C"C

WFNCOZ9

K2=KR.KR+KTH.KTH+KPH.KPH

WFNC030

J .~2=OH'OH

VTH=C/OM"KT1

WFNC031
WFNCOJZ
WFNCOJ3

~PH=C/O~.(P~

WFNC034

V~

=C/OH"~R

94

CALL ELECTX
:ALL MAGY
~2=~R··Z+~TH··2+~PH··Z
~OOTY=~R·YR+~TH·YTH+~PH·YPH

YLV=VOOTYIV2
YL2=vDOTY··ZI1/2
YT2=Y··Z-YL2

YTI+=YT2".,T2
UX=U-X
UX2=UX·UX
RAO=RAY·SlRTIYT4+4.·YL2·UX21
O=Z."UK-YTZ+RAO
02 =O' 0
N2=1.-2.·x·UX/O
PNPPS=2.·X·UX"(-1.+(YT2-Z."UXZ)/RAOl/02
??SPR= YL2/Y.'YPR -(VR·PYRPR+"TH.PYTPR+VPH.PYPPR).YL~

PPSPTH=YLZ/Y·PYPTH-{VR·PYRPT+VTH"PYTPT+V'PH·PYPPT)·Ylv
PPSPPH=YLZ/Y·PYPPH-(VR"PYRPPtVTHiJPVTPP+V'PH"PYPPP)·YLV
PNPX=-(2.·UX2-YT2·(U-2.·X)+(YT~·(U-2.·X)+4.·YL2·UX·UXZ J/RAOJ/OZ

PNPY=2."X·UX·(-YT2+(YT4+2.·YLZ·UXZ'/RAO)/(OZ"Y)
NNP=N2-(2.·X·~NPX+Y·PNPY)

PNPR =PNPX"PXPR tPNPY·PYPR tPNPPS.PPSPR
PNPTH=PNPK·PXPTH+PNPY·PY~TH+PNPPS·PPSPTH

PNPPH=PNPX·PXPPHtPNPY·PYPPH+PNPPS·PPSPPH
PNPVR =PNPPS'IVR 'YL2-VOOTY'YR I/V2
PNPVTH=PNPPS'IVTH'YL2-VOOTY'YTH)IV2
PNPVPH=PNPPS'IVPH'YL2-VOOTY'YPH)/V2
PNPT=PNPX< PX PT

SP'ACE=NZ.EQ.1.
POLARI=SQRTIVZ)·IYT2-RAOIIIZ.·VOOTY·UXI

GAH=(-YT2+RAO)/ (Z •• UX)
LPOLRI=X'SQRTIYT21/IUX'IU+GAMI)
~AY2=OMZI:2'N2

IFIRSTART.EQ.O.) GO TO 1
SCALE=SQRTIKAr2I(2)
KR :SCALE'KR
KTH=SCALE'KTH
K~H=SCALE'K?~

1

CONTINUE

C········· CALCULATES A HA"ILTO~IAN H
H=.5·IC2·K210~2-N2)

C······
••• AND ITS PARTIAL DERIVATIVES WITH RESPECT TO
C········· TIME, R, THETA, PHI, OMEGA, KR, KTHETA, AND KPHI.
PHPT =-PNPT
P~PR =-PNPR
PHPTH=- PNPT~
PHPPH=-PNPPH
?HPOM=-NNP/O~

PHPKR =C2/0~Z'KR -C/OM'P~PVR
PHPKTH=CZ/OMZ'KTH-C/OH'PNPVTH
PHPKPH=C210M2'KPH-CIOM'PNPVPH
KPHPK=N2
RETURN
ENO

95

WFNC035
WFNC036
WFNC037
WFNC038
WFNC039
WFNCO.O
WFNC041
WFNC042
WFNC043
WFNCO.4
WFNC045
WFNCQ46

WFNC047
WFNC048
WFNCO.9
WFNCOSO
WFNC051
WFNCOS2
WFNCOS3
WFNCOS4
WFNCOSS
WFNC056
WFNC057
WFNCOS8
WFNCOS9
WFNC060
WFNC061
WFNC062
WFNC063
WFNC064
WFNC06S
WFNC066
WFNCOf>7
WFNC068
WFNC069
WFNC070
WFNC071
WFNC072
WFNC073
WFNC074
WFHC075
WFHC076
WFHC077
WFHC078
WFHC079
WFHC080
WFNC081
WFNC082
WFNC083
WFNC084
WFNC08S
WFNC086
WFNC087
WFNC088-

C
C

SUBROUTINE ~~NFWC
CALCULAToS THE REFRACTIVE INOEX ANO ITS GRAOIENT USING THE
APPLETON-HARTREE FO~.ULA -- NO FIELO, WITH COLLISIONS
~OMHON ICONSTI PI,PIT2,PIJ2,OEGS.R4DIAN,K,C,LOGTEN
:OHH ON IRINI MODRIN(3),CJLltFIELO,SPACEtKAY2,H,PHPT.PHP~,PHPTH,

NFWC014

f»HPPH, PHPOI1, 'HPKR, PHPKTH, PH? J(PH, I(PHPK, POLAR, lPOLAR,

NF WCOl5

1

2

NFWC01&
NFHC 017
NFWC018

COMMON IZlt 110DZ,Z,PZPR,PZPTH,PZPPH

NFW C019

COHMON IR(I

NFWC020

N,STEP.HODE,E1H~X,E1MIN,E2HAXtE2HINtFACT,RSTART

110110/1 10(10',1010,'''<400)

NFWC021

EQUIvALENCE (RAY,W(1}), (F,W(6»)

NFWC022

LOGICAL SPACE
REAL KR,KTH,KPH,K2
COMPLEX KAYZ,H,PHPT,PHPR,PHPTH,PHPPH,PHPOH,PHPKR,PHPKTH,PHPKPH.

NFWC023
NFWCOZ4
NFWCOZ5

KPHPK,POLAR,LPOLAR,U,I,PNPX,PNPZ.
N2,PNPR,PNPTH,PNPPH,PNPVR.PNPVTH,PNPVPH,NNP,PNPT

NFWC026
NFWCOZ7

1

2

DHA

(~OORIN:8HAPPLETON,8H-HARTREE.8H

FORMULA), (COLL:1.),

NFWC028

(FIELO = O.), (POlAR=(O.,l.» ,(LPOLAR=(O •• O.»,
(X = O.),(PXPR=O.), (PXPTH=O.), (PXPPH=O.), (PXPT=O.),

NFWCOZ9
NFWC030

3

(HJOY:1H ),

NFWCQ31

~

(Z=O.},(PZPR=O.),(PZPTH=O.),(PZPPH::rO.),

NFWC032

2

,

1

NFW C0 13

SGN
COMMON IXKI HOOX(Z),X,PXPR,PXPTH,PXPPH,PXPT,HHAX
COMHON I H I MOOy,~ ' (1&)
COHMON K,TH,P"I,KR,KTH,KPti

1

NFWC010
NFWC011
NFWC01Z

({:(O •• l.)), (ABSLIM:l.E-5) ,(PNPVR:O,),(PNPVTH:O,) ,(PNPVPH:O,)NFWC033
ENTRY RINOEX
NFWC034
OH:PITZ'l.Eo'<
NFWC035
C2 : C'C
NFWC03&
(Z=KR·KR+KTH"KTH+KPH·KPH

NFWC037

OM2:0M'OM
VR :C/OH'XR
VTH:C/O.·XTH
VPH : C/OH'KPH
CALL ELECTX
CA LL COLFRZ
U:1.-I'Z

NFWC038
NFWC039
NFWC040
NFWC041
NFHC042
NFHCQ43
NFWC044

N2=1.-X/U

NFWCO~5

PNPX=-1./(2.'U)
PNPZ:-I'X/(2,'U"2)
NNP=N2-(2,'X'PNPX+Z'PNPZ)
PNPR =PNPX'PX?R +PNPZ'PZ?R
PNPTH=PNPX'PXPTH+PNPZ'PZ'TH

NFWCQ40
NFHC047
NFWC048
NFWC049
NFWC050

PNPPH=PNPX·PXPPH+PNPZ"PZP~H

NFWC051

PNPT =PNPX'PXPt
SPACE=REAL (NZ) ,EQ.1., ANO, ABS (AIMAG (N2)).LT .ABSLIM
(AY2 : 0MZIC2'NZ
IF(RSTART.EQ.O,) GO TO 1
SCALE=SQRT(REAL(KJY2)/K2)
KR =SCALE'KR
XTH=SCALE'KTH
KPH=SCALE'KPH
CONTINUE

NFWC052
NFWC053
NFHC054
NFWCQ55
NFHC050
NFWC057
NFWC058

C·· .. • .. • .. •• CALCULATES A HAMILTJNIAN H
~:.5·(C2·KZ/0~2-N2)

C········· ANO ITS PARTIAL DERIVATIVES WITH RESPECT TO
C...... •• ..... • TIME. ~, THETA. PHI, OMEGA, !CR, KTHETA, AND KPHI.
PHPT =-PNPT
P~PR :-PNPR
PHPTH=-PNPTH
PHPPH:-PNPPH
PHPOH=-NNP/OH
PHPKR =C2/OH2'KR
PHPKTH=C2/0H2'KTH
PHPKPH=C210H2'KPH
KPHPK=NZ
RETURN
ENO

~FWC059

NFWCOoQ
NFWC061

NFWCQo2
NFWC063
NFWC064

NFHC065
NFWC066
NFWC067
NFHC068
NFHCQ69
NFWC070
NFWCQ71
NFWC072
NFWC073
NFWC074
NFWC 075-

96

SUBROUTINE AHNFNC
CALCULATES THE REFRACTIVE INOEX AND ITS GRAOIENT USING THE
APPLETO~-HARTREE FO~~ULA -- NO FIELD, NO COLLISIONS
COHMON ICDNSTI PI,PIT2,PI02,OEGS,RAOIAN,K,C.LOGTEN

C
C

:~HMON

IRINI

1

2

~ODRIN(3),CJLL,FIELO,SPACE,KAY2,KAY2It
NFNC005
H t HI, PHPT, PH?T I t ?HPR, PHPR.I. PHPTH, PHPTHI, PHPPH, PHP'P"'l r, NFNC006

PHPO~,PHPOHI,PHPKR.PHP~RltPHPKTH,PHPKTI,PHP~PHtPHPKPIN FNC007

,(PHPK ,KPHPKI, PO L AR, POLAR! .LPOLAR, lPCLRI, SGN

3
COHMON

IX't-/ 110QX(Z) ,X,PXPR,PXPTH,PXPPH,PXPT,HHAX

COHHON IYYI

~ODy,Y(lbl

Illl HDDl,l(41

COHMON IRK/

N,STEP,HOOE,~lMAX,E1HIN,E2I1AXtE2I1rN.FACT,RSTART

NFNC008
NFNC009

NFNCD10

NFNC011

1\0/101/ IO(10),HOdH400)
EJuIVALENCE (RAY,W(II1'(F,W(bU
LOGICAL SPACE

NFNC013
NFNCD14

REAL NZ.NNP,KR.KTH,KPH.K2,KPHPK,I(PHPKI.KAYZ,KAYZI,lPOLAR,LPOLRI

NFNC015

COMMON R,TH,PH,KR,KTH,KPH

DATA
1
2
1
!.t

(HODHN=eHAppLETON,6~-"ARTREE,8H

FORHULAI, (COLL=O.I,
(FIELO=D.I,(KAYZI=D.I,(HI = D.I ,(PHPTI=O.I, (PHPRI=D.I,
(PHPTHI=D.I,(PHPPHI=D.I,(PHPOMI=D.I,(PHPKRI=D.I,(PHPKTI=0.1,
(PHPKPI=D.I, (KPHPKI=D.I,(POLAR=D.I'(POLARI = I.I,(LPOLAR=D.I,
(LPOLRI:::l.) t

NFNC012

NFNCDlb
NFNCD17
NFNCD16
NFNCD1Q
NFNCQ20

!.t

U=O.),(PXPR=O.),(PXPTH=O.),(PXPPH=O.J,(PXPT = O.',

NFNC021

5
:.

(MODY=IH I, (HODl=IH I,
(NNP = 1. I , ( PI( P X=-0 .51 , ( PH P V R= 0 .1 , (PNP VTH = 0 • I , (PNPV PH= 0 .1
ENTRY UNOEX
JH=PITZ·I.Eo·F
CZ=C'C
K2=KR'KR+KTH'KTH+KPH'KPH
DH2=OH+DM
VR =C/OH+CR
V TH=C/OH+UH

NFNCDZZ
NF NCD Z 3
NFNCDZ4
NFNCDZS
NFNCDZb
NFNCD21
NFNCD2e
NFNCD2Q
NFNC03D
NFNC031
NFNCD32
NFNCD33
NFNC034
NFNC03S
NFNC03b
NFNCD37
NFNCD3e
NFNCD3Q
NFNC04D
NFNCD41
NFNCD4Z

VPH=C/O~'KPH

1

NFNCDD1
NFNCQDZ
NFNCDD3
NFNC004

CALL ELECTX
PNPR =PNPX'PXoR
PNPTH=PNPX'PXPTH
PNPPH=PNPX+PXPPH
PNPT=PNPX'PXPT
N2=1.-X
SPACE=NZ.EQ.1.
KAYZ=OHZ/CZ'NZ
IF(RSTART.EQ.O.I GO TO 1
SCALE=SlRT(KAYZ/KZI
KR =SCALE'KR
KTH=SCALE'KTH
KPH=SCALE'KP"
CONTINUE

NFNCD~3

NFNC044
NFNCD4S

C········. CALCULATES A HAHILT~NIAN H

NFNCO~&

H=.S·(CZ·KZ/OHZ-NZI
AND ITS PARTIAL DERI·VATIVES WITH RESPECT TO

C·· .. ·....

C···· .. •••• TIME, R, THETA, PHI,

OMEGA. !CR, KTHETA,

PHPT =-PNPT
PHPR =-PNPR
PHPTH=-PNPTH
PHPPH=-PNPPH
PHPOH=-NNP/OH
?~PKR =CZIOHZ'KR
PHPKTH=CZIOHZ'KTH
PHPKPH=CZIOHZ'KPH
KPHPK=NZ
RETURN
END

AND KPHI.

NFNCD47
NFNCD~8

NFNCO~9

NFNCDSD
NFNCD51
NFHCD52
NFNCD53
NFNCD54
NFNCD55
NFNCD5b
NFNC057
NFNC058
NFNCD5Q
NFNCD60

97

SUBROUTINE BQWFWC
C········· CALCULATES A HAMILTONIAN H
C·········

(=

BOOKER QUARTIC FOR VERTICAL INCIDENCE,

5=0, C=U

BQWC001
8QWCOOZ
BQWC003

C········· ANO ITS PARTIAL OERIVATIVES WITH RESPECT TO

8QWCOO~

c.. • .. •••••• TIME, ~.

BQWC005

THETA, PHI. OMEGA, KR.,

KTHETA,

AND KPHI.

C········· WITH FIELD, ~ITH COLLISIONS
BQWC006
COHMON ICONSTI PI,PIT2,PI02,OEGS,RAOIAN,K,C,LOGTEN
BQWC007
~JHHON IRINI HOORIN(3),CJLL,FIELO,SPACE,KAY2,H,PHPT,PHPR,PHPTH,
BQWC008
1
~HPPH,PHPOM,PHPKR,PHPKTH,PHPKPH,KPHPK,POLAR.,LPOLAR,
BQWC009
2
SGN
BQWC010
CJHHON IXXI HODX(Z),X,PXPR,PXPTH,PXPPH,PXPT,HHAX
8QWC011
:OHHON IVY/ HOOY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRPT,PYRPP,YTH,PYTPR B~WC01Z
1

,?YTPT,PVTPP,YPH,PYPPR,PVPPT,PYPPP

COHMON IZZI HJDZ,Z,PZPR,PZPTH,PZPPH
COMMON R,TH,PH,KR,KTH,KPI't
IWW/IO(10),WQ,W(400J
;OMMON IRKI N,STEP,HOO(,E1MAX.E1MIN,E2MAX,E2MIN,FACT,RSTART
;OMMOH IFlGI NTYP,NEWWR,NEWWP,PENET,LINES,IHOP,HPUNCH
EQUIVALENCE (RAY,W(U), (F,W(o))
LOGICAL SPACE
REAL KR,KTH,KPH,K2,KOOTY,(4,KOOTYZ
COMPLEX KAY2.i,PHPT,PHPR,PHPTH,PHPPH.PHPOM,PHPKR,PHPKTH,PHPKPH,
1
POLAR,LPOLAR,I,U,RAO,O,PNPPS,PNPX,PNPY,PNPZ,UX,UX2,02,
~
KPHP(,U2,A,B,ALPI'tA,BETA,GAMHA,PHPX,PHPYl,PHPKl,PHPU,PHPZ.
3
N2,PNPR,PNPTH,P~P~H,PNPVR.PNPVTHtPNPVPH.NNPtPNPT
OA TA (MOORIN=8HBOO KER Q,8HUARTIC, ,8HS=O, C=ll, (COLL=l.),
1
(FIELD=1.),
2
(X=O.), (PXPR=O.), (PXPTH=O.) ,(.PXPPH=O.), (PXPT=O.),
3
(Y ;;; 0 • ) , (? YPR = 0 • ) , (py ~ TH;;; 0 • ) , (PY PP H= 0 • ) , (y R;;; 0 • ) , (P YRP R=Q • ) ,
It
( P YRP T;;; a• ) t (PY RPP;;; Q• ) , (Y TH=O • ) , (PYTP R=O .) , {PY TPT = 0 • J ,
5
{P '( T PP= 0 • ) t ( Y PH= 0 • ) , (P Y PP R= o. ) , (fi' ypp T =0 .) , (py PPP =a• )

o
7

,(Z=O.},{PZPR=O.J,(PZPTH=O.J,CPZPPH=O.',

<I=(O.,l.)), (ABSLlM=1.E-S) ,eSGN=l.)
ENTRY RINOEX
JM=PITZ·1.Eo·F
C2=C'C
K2;;;KR·KR+KT~·KTH+KPH·KPH

OMZ=OH'OH
CALL ELECTX
IFeX.Lr •• ll GJ TO Z

8QWC014
BQWC015
8QWC01&
BlWC017
SQWC018
B~WCOlq

SQWCOZO
8QWC021
SQWC022
SQWCOl3
SQWCOl4
BQWC025
BQWCOZo
BQWCOZ7
BQW C02 8
BQW C0 Z9
8QW C030
8QWC031
BQWC03Z
BQWC033
BQWC034
BQWC035
SQWC036
BQWC037
BQWCQ38
BQWC03Q

~4=K2'KZ

BQWCO~O

OM4=OHZ'OMZ

BQWC041
BQWC04Z

C~=CZ'CZ

CALL HAGY
Y2=Y'Y
~OO TV =KRoy R+KTH'Y TH+KPH'Y PH
<OOTYZ=KOOTY"KOOTY
CALL COLFRZ
U=CHPLX(1.,-Z)
U2=U'U
UX=U-X
UXz=ux'UX
A=UX'UZ-U'YZ
8:·Z.·U·UXZ+YZ·(Z.·U·X)
ALPHA=A·C4·K4+X·KOOTYZ-C4·K2
3ETA=B'CZ'012'KZ-X'KOOTrZ'CZ'OHZ
GAHHA=(UXZ-YZ) 'UX'OH4

BQWCO~3
BQWCO~~
BQWCO~5

BQWCO~o

BQWC047
BQWC048
BQWCO~Q

H=A~PHA.BETA.:;AHHA
PHPX=·UZ·C4.K4+KOOTYZ·C~·KZ+(4.·U·UX-Y2)·CZ·OMZ.KZ·KOO TYZ·CZ.OHZ+

1

eQWC013

e-3.·UXZ.Y2)·OH~

PH?Y Z=-U. C4·1(4 + (Z. ·U-X)·C Z· OMZ·KZ-UX·O H4
PHPKYZ
=x'GZ'eCZ'KZ-OMZ)
PHPU;;;(Z.·U·UX+U2-YZ'·C4·K4+Z.·(YZ-UXZ-Z.·U·UX)·CZ·KZ·O ~Z+(J •• UX2

1 -YZ)'OH4
PHPZ=-I'PHPU
PHPKZ;;;Z •• A.:~.K2+X.KOOTYZ.C4+B.C2·0H2

98

BQWC050
BQWC051
BQWC05Z
BQWC053
BQWC054
BQWC055
BQWC056
BQWC057
SQWC058
BQNC05Q
BQW C060
BQWC061
BQWC06Z
BQWC063
BQWC06~

BQWC065

PHPT=PHPXOPXPT

BQWC066
BQWC067
1 (KR·PYRPR+KTH·PYTPR+KPH*PYPPR) +PHPZ.PZPR
BQWC068
PHPTH=PHPK·PKPTH+PHPYZ*Z.*Y·PYPTH+PHPKYZ .Z •• KOOTY.
BQWC069
1 (KR·PYRPT+(T",4PYTPT+KPH"PYPPT) +PHPZ.PZPTH
BQWC070
PHPPH=PHPX·~XPPH+PHPY2·Z.·Y·PYPPi+PHPKY2
"2."KOOTY.
BQWC071
1 (KR·PYRPP+KTH.PYTPP.KPH~PYPPP) +PHPZ·PZPPH
BQWC072
~HPOM=(2.·BET~+~.·GAHHA)/OH
BQWC073
1 -2.·P~PX·X/O~-Z.·PHPY2·Y2/0H-2.·PHPKY2 "KDOTYZ/OH -PHPZ.Z/OH
BQWCOH
PHPKR= 2."PHPKZ"KR +2."KJOTY·PHPKY2 .YR
BQWC075
PHPKTH=2."PHPKZ"KTH+2."KDOTY·PHPKY2 .YTH
BQWC076
PHPKPH=2."PHPKZ·KPH+Z."KJJTY·PHPKY2 .YPH
BQWC077
<AY2=K2·(-BETA+SGN·RAY·CSQRT(aETA··2-~.·ALPHA·GAM"A)1 CZ."ALPHA)
BlWC07S
C
BQWC079
IF(RSTART.E •• O.) GO TO 1
BQWC080
5CALE=SQRT((-REAL(BETA)+5~N"RAY"SQRT(REAL(BETA)""Z
BQ.WC081
1 -'."REAL(ALP~A)"REAL(GAHHAI)) I (Z."REALlALPHA)) I
BQWC08Z
<R =SCALE"KR
BQWC083
(TH=SCALE"KTH
BQ.WCOa.
KPH=SCALE'KP~
BQWC085
1
:ONTIN:JE
BQ.WC086
C········· THE FOLLJWING 3 CARDS USED FOR RAY TRACING IN COHPLEX SPACE BQ.W C08 7
C
IF(CABS((-BETA-SGN"RAY"CSQRT(BETA""Z-'."ALPHAoGAHHAIIIALPHA-Z.I. BQWC088
C
lLT.CABS((-BET'+SGN"RAY'CS.RT(BETA"'Z-'."ALPHA'GAHMA))IAL?HA-Z.)
BQ.WC089
C
Z .AND.RSTART.EQ..O.I SGN=-SGN
BQWC090
KPHPK=~.·.L?rlA+2.·BETA
BQWC091
5PACE=CABS (CZ"KAY2IOHZ-l. I .L T.ABSLIH
BQWC09Z
POLAR =SQRT(KZ)"(U+X"OMZ/(CZ"KAYZ-OHZ))/KDOTY'I
BQWC093
LPOLR = S~RT (rZ -KDOTYZlKZ I lUX" (1. -CZ"KAY2IOHZ)" I
BQWC094
RETURN
BQ.WC095
C
CALCULATES THE REFRACTI~E INDEX AND ITS GRADIENT USING THE
BQWC096
C
APPLETON-HARTREE FO .~HULA WITH FIELD. WITH COLLISIONS
BQ.WC097
2
;ONTINUE
BQ.WC09S
~R =C/OH"KR
BQWC099
~TH=C/OH"HH
BQWC100
~PH=C/OH"KPH
BQWC10l
~UL MAGY
BQWC10Z
V2=VR"'·Z+VTH"'·Z+VPH"'·Z
BQWC103
VOQTY=VR"'YR+VTH"'YTH+VPH"'YPH
BQWC10.
YLV=VOOTY/VZ
BQ.WC105
YL2=VOOTY·"'ZI'II2
BQWC106
YT2=Y··Z-YLZ
BQWC107
YH=YTZ'YTZ
BQWC108
CALL COLFRZ
BQ.WC109
U=CHPLX (1 •• -Zl
BQ.WC110
UX=U-X
BQ.WC111
UXZ=UX"UX
BQ.WC11Z
~AD=SGN"RAY" C SQ.RT(YT'+'.·YLZ"UXZ)
BQ.WC113
O=Z."U·UX-YTZ+RAO
BQ.WC11.
OZ=O"O
BQWC115
NZ=1.-2."')("'UX/O
BQWC116
PNPPS~Z.·X"UX·(-1.+(YTZ-Z."UX21/RAOI/DZ
BQWC117
PPSPR= YLZ/yoPYPR -(VR"PYRPR+VTHoPYTPR+VPH"PYPPR)"YLV
BQWC118
PPSPTH= YL2IY 'PYPT H- (VR"pr RPJ + VTHoPYTPT+VP H"PYPPTl"YLV
BQWC119
PPSPPH=YLZ/Y"PYPPH-(VR"PYRPP+VTH"PYtPP+VPH"PYPPP)"YL~
BQWC1Z0
PNPX=-(Z.·U·UX2-YT2·(U-Z.·X).(YT~·(U-2.·X'+4.·YL2·UX·U XZI/RAO)/DZ BQWC1Zl
PNPY=Z.·X·UX-(-YTZ+(YT4+Z."'YLZ"'UXZI/RAO)/(OZ"'Y)
8QWC1Zl
PNPZ=I"X"(-Z."UXZ-YTZ+YT~/RAO)/OZ
BQ.WCll3
PHPR

~PHPK·PXPR

+PHPYZ·Z.·Y·PYPR +PHP~YZ

.Z.4KDOTY.

NNP=N2- (2. ·X"'NPX+ Y·PNPY+Z"'PNPZ)

BQWCll~

PNPR =PNPX"PXPR +PNPY"PYP~ +PNPZ'PZPR +PNPPS"PPSPR
PNPTH=PNPX"PXPTH+PNPY"PYPTH+PNPZ"PZPTH+PNPPS"PPSPTH
PNPPH=PNPX"PXPPH+PNPY"PYPPH+PNPZ'PZPPH+PNPPS"PPSPPH
PNPVR =PNPPS"(VR "YLZ-VDDTY"YR I/VZ

8QWC125
8QWC1Z6
8Q.WCll7
BlWC1ZS
8Q.WC129
8QWC130

PNPVTH=PNPPS'(~TH'YLZ-VDOTY"YTH)/VZ

PNPVPH=PNPPS"(VPH"YLZ-VDOTY"YPH)/VZ

99

PNPT=PNPX'PXPT
SPACE=REA LIN Z) • Ell.. 1 •• AND. ABS (AI HAG (NZ ) ). LT. AB SLIM
POLAR=-I'SQRTI~Z)·(-YTZ.RAD)/IZ.·VDOTY·UX)

GAH=(-YT2+RAO)/(Z.·UX)
LPOLAR=I·X·SQ~T(YT2)/(UX·(U+GAH»
KAY2 = 0P12/:;2H~2

IF(RSTART.EQ.D.)

GO TO 3

SCALE=S~RTIREAL(KAYZ)/KZ)

KR =SCALE'KR
<TH=SCALE'KTH
KPH =S CALE·KPrl

CONTINUE

3

~=.5·(C2·K2/0~2-N2)

PHPT =-~ NPT
PHPR =-PNPR

PHPTH=-PNPTH
PHPPH=-PNPPH
PHPOH =-NNP/ OH

PHPKR =C2/0HZ.KR -C/OH·PNPVR
PHPKTH=CZIOHZ'KTH-C/OH'PNPVTH
PHPKPH=CZIOHZ'KPH-C/OH'PNPVPH
KPHPK =NZ
RETURN
ENO

SUBROUTINE

BQ~FNC

C·········

CALCJL~T~S

C·········

(=

BQNCOOI

A HAHIlTO~IAN H
BOOKER QUARTIC FOR VERTICAL INCIDENCE,

C········· AND ITS
C········· TIME,

~,

~ARTIAL

BQNC002
$=0. C=1)

DERIVATIVES WITH RESPECT TO

THETA, PHI,

OMEGA, KR,

KTHETA,

ANO KPHI.

C········· wITH FIELD, NO COLLISIONS
1
2

8QWC131
8QWC13Z
BQWC133
BQWC134
BQH C135
BQHC 136
BQHC137
BQWC138
BQHC139
BQHC14D
BQHCl41
BQHC1 .. Z
BQHC1 .. 3
BJHC1 ....
BQWC1 .. 5
BQHC1 .. 6
BQWC1 .. 7
BQH C 1" 8
BQHC1 .. 9
BQWC150
BQHC151
BQWC15Z
BQW C 15 3
BQWCI5 ..

8QNC003
BQNCOa~

BQNC005

BQNC006

CJHHON ICON5TI PI,PITZ,PIDZ,DEGS,RADIAN,K,C,LDGTEN

BQNC007

COHMON IRINI HOORIN(3),CJLl,FIELD,SPACE.KAY2,KAY2I,

BQNCD08

~,HltPHPT,PHPTI,PHPR,PHPRI,PHPTH,PHPTHI,PHPPH,PHPPHI,B QNC009
~HPO~,PHPO~I,PHPKR,PHPKRI,PHPKTH,PHPKTltPHPKPH,PHPKPIB QNC010

3

,KPHPK, KPHPKI, POLA R, PO LA R I, lP OlAR. LPoufI, SGN
8C,NC011
COMMON IXXI MOaX(ZJ,X,PXPR,PXPTH,?XPPH,PXPT,HHAX
BQNC01Z
COHHON IYYI "OOY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRPT,PYRPP,YTH,PYTPRBQNC013
1
,PfTPT,PYTPP,,(:JH,PYPPR,PYPPT,PYPPP
BQNC014
COHHON Illl ~DDl,ll")
BQNC015
COHHON IR~I N,STEP,MDDE,E1HAX,E1HIN,EZHAX,EZHIN,FACT,RSTART
BQNCD16
COMMON R,TH,P-t,KR,KTH,KP-t
11011011 IO(10),WO,lU400)
BC,NC011
EQUIVALENCE (RAY,Wll)) ,1F,W(6))
BQNC018
LOGICAL S'ACE
SQNC019
REA L NZ, NNP, LPOLA R, L POLARI, KR, KTH, KPH, KZ, KOOTY t Kit, KOOTYZ,
BQNC Q2Q
1
KPHPK,KPHPKI,KAY2,KAY21
BQNCOZI
BQNCOZZ
DATA (~ODRIN=8HBOOKER Q,8.HUARTIC, ,8HS =O, G=I), ICOll=O.),
(F I E L 0= 1. ) , ( K Av Z I =0. ) , I HI = 0.) , I PH PTI = 0 .) , I PHPRI=.O• ) ,
BIl.NC 02 3
1
IPHPTHI=D.),IPHPPHI=O.),(PHPOHI=O.),(PHPKRI=O.),(PHPKTI=0.), BQNC024
2
IPHPKPI=D'), (KPHPKI=D.) ,(POlAR=O.),(LPOlAR=O.),
BIl.NCDZ5
3
(X=O.),(PXPR=O.),(PKPTH=O.),IPKPPH=O.),IPKPT=D.),
BQNCOZ6
..
5
n=o.}, (PVPR=O.', {PYPTH=Q." (PYPPH=O.l, (YR=Q.), (PYRPR=O.',
BQNC027
(PYRPT=O.), (PYRPP=Q.) ,(yTH=O.', (PYTPR=O.) ,(PYTPT=O.) t
8QNC026
5
7
I P YT PP= 0 • ) , ( YPH= 0 • ) , (py PPR= 0 • ) , (P YPP T=O .) , I PYPPP= 0,) ,
BIl.N C DZ9
(HODZ=IH ), (U=I.) ,WZ=1.)
BIl.NC030
8
BQNCOJI
ENTRY RINDEX
O~=PITZ·I.E&·<
BQNCD3Z
C2=C'C
BQNCDJ3
(Z =KR·KR. KTH'KTH.KPH·KPH
BQNCOJ ..
OH2=OH'OH
BIl.NCD35

100

CALL ELECTX
IF(X.LT •• ll GO TO 2

BQ.NC036
SQ.NCOJ7
BQ.NC03S
BQ.NC039

<~=K2'K2

0"4=0t12"0"2

V4::CZ·CZ
CALL HAGY

SQ.NCO~O

12=Y"Y

BQ.NCO.l
SQ.NCO.2

KOOTY=KR·YR+~T~·YTH+KPH·rpH

SQ.NCO~3

KDOTY2=KDOTY'KDOTY

SQ.NCO ••
ux=u-x
SQ.NCO.5
UX2=Ux"UX
SQ.NC046
t!,=UX·U2 "'U· Y'2
SQ.NCO.7
4
B=-2. U·UX2+'(2" (2 .·U-X)
SQ.NC048
tl,LPHA=A·C~·K4+X·KOOTY2·C4·K2
SQNCO.9
aETA=S"CZ"OHZ"K2-X·KOOTYZ"CZ·0t12
SQ.NC050
~AMHA=(UX2-r2)·UX·0t14
SQ.NC051
H=ALPHA+SETA+GAHHA
SQ.NC052
PrlPX=-UZ"C4"<4+KOOTYZ·C .. "(2+(4."U·UX-YZ)·CZ"OHZ4K2-KOOTYZ.CZ.OH2+ SQ.NC053

1 (-3."U)(2+Y2).0"4
PHPY2=-U·C .. "K4+(Z.·U-X)·CZ"OHZ·K2-UX·OH4
~HPKY2
=X·CZ·(CZ"K2-0MZ)

BQ.NC05~

PrlPKZ=Z."A·C .. ·K2+X·KOOTYZ·C4+B·CZ·OM2
PHPT=PHPX·PXPT

PHPR =PHPX·PXPR +PHPYZ"Z.·Y·PY?R +PHPKYZ
1 (KR·PY RPR +(TIi"PYT PR+KPH"PYPPR)
PHPTH=PHPX·PX?TH+PHPYZ"Z.·Y·PYPTH+PHPKYZ

1

·Z •• KDOTY.
"2."KOOTY.

(KR.pYRpr+(T~.pYTPT+KPH.PYPPT)

PHPPH=PHP~·?X~PH+PHPY2·2.·Y·PYPP~+PHPKY2

.Z.-KOOTY-

1 (KR*PYRPP+I<Ht.PYTPP+KPH"PYPPPJ
PHPOH=CZ.·BETA+~.·GAHHA)/OH

1

1

-2.·PHPX·X/~~-2.·PHPYZ.Y2/0H-2 •• PHPKYZ
.KOOTY2/0M
PHPKR= Z.·PHPKZ·KR +2.-KOOTY-PHPKYZ .YR
PHPKTH=Z.'P~PKZ'KTH+2.'KDOTY'PHPKYZ
'YTH
PHPI<PH=Z.·PHPI<Z·KPH+Z.·KOOTY·PHPKYZ -YPH
KAYZ = (2
'(-SETA+RAY'S~RT(SETA'·2-4.'ALPHA'GAHHA'l/(2.'ALPHA'
IF(RSTART.EQ..O.l GO TO 1
SCALE=SQ.RT«AYZ/K2l
KR =SCALE'KR
UH=SCALE'KTH
KPH=SCALE'KPH

CONTINUE
KPHPK=~.·AL~HA+2.·BETA
SPACE=KAYZ.E~.OHZIC2

PDLARI=SQ.RT(K2'"(U+X'OH2/(CZ'KAY2-0H2ll/KDOTY
LPOLRI= S~RT(Y2-KOOTY2/KZl/UX"(1.-C2'KAY2/0H2l
RETURN
CALCULATES THE REFRACTIVE I~OEX AND ITS GRADIENT USING THE
APPLETON-HARTREE FORMULA WITH FIELD. NO :OLLISIONS

C
C
2

~ONTINUE

WR =C/DH'KR
IJTH=C/OP1*)(TH
VPH=C/DH'KPH
CALL HAGY
V2=VR··Z+VTH**Z+V?H··Z
VOOTY=YR·YR+VTH*YTH+VPH·YPH
YLW=VDOTV/W2
YL 2=VOO TV" '21W 2
YT2=Y*·Z-YLZ
VTIt:zYTZ·YTZ
JX=U-X
UX2=UX'UX
RAO=RAY"S~RT(YT4+4.'YL2"JX2'

O=Z.*UX-YTZ+RAO
02=0·0
N2=1.-2.·X·UX/0

101

SQ.NC055
SQ.NC056
SQ.NCOS7
SQ.NC058
SQ.NCOS9
SQ.NC060
SQ.NC06l
SQ.NC062
SQ.NC063
SQ.NC06.
SQ.NCOGS
SQ.NC066
SQ.NCOG7
BQ.NCOG8
SQ.NC069
SQ.NC070
S~NC07l

BQ.NC072
SQ.NCOn
SQ.NC07~
S~NC07S

SQ.NC076
BQ.NC077
SQNC078
SQ.NC079
SQ.NC080
SQ.NC081
BQ.NC082
SQNCOB3
SQ.NCOB.
SQ.NCOB5
SQNC08G
BQ.NCOB7
SQNC088
BQ.NC089
SQNC090
SQ.NC09l
BQNC092
SQ.NC093
SQ.NC09.
SQ.NC09S
SQ.NC096
BQ.NC097
SQ.NC09S
SQ.NC099
SQNC100

~N~~S=Z.·X·U(·(-1.+(YT2-2.·UX2)/RAO)/02

~~S~R=

YL2/Y'~Y~R

-(VR'~YR~R+VTH'PYTPR+VPH'PYPPR)'YLV

~PSPTH=YL2/f'?YPTH-(VR'PYRPT+VTH'PYTPT+VPH'PYPPT)'YLV
~~SPPH=YL2/Y'~Y~~H-(VR'PYR~P+VTH'~YTP~+VPH'~Y~P~)'YLV

PNPX=-(Z.-UX2-YTZ·(U-2.-X)+(YT4·(U-2.·X)+4.·YLZ·UX·UX2)/RAO)/02
PNPY=Z.·X·UX·(-YT2+(YT4+2.·YlZ·UXZ'/RAO)/(OZ·Y)
NNP=N2-(2.·X·~NPX+Y·PNPY)

~NPR

=PNPX'PX'R +PNPY'~Y~R +PNPPS'PPSPR

~NPTH=PNPX'~XPTH+PNPY'PY~TH+~NP~S'PPSPTH

PNPPH=PNPX·PXPPH+PNPY·PYPPH+PNPPS·PPSPPH

?NPVR =PN?PS4(VR ·YL2-VOJTY.YR )/VZ
PNPVTH=PNPPS·(VTH·Yl2-VOOTY·YTH)/V2
PNPVPH=~NP~S'(VPH'YL2-VOOTY'Y~H)/V2

B~NC1H

RETURN
END

BQNC115
BQNC116
BQNC117
BQNC118
BQNC 119
BQNC120
BQNC 121
BQNC122
BQNC123
BQNC124
BQNC125
BQNC126
BQNC127
BQNC128
BQNC129
BQNC1JO
BQNC131
BQNC1J2
BQNC1J3
BQNC1J4
BQNC135
BQNC136
BQNC137-

SUBROUTINE SWWF
CALCULATES THE REFRA:TIVE INOEX AND ITS GRADIENT USING THE
SEN-WYLLER FORHULA -- WITH FIELD
NEEDS SUBROUTINE FSW AND FUNCTIONS C AN~ S.
COHHON ICONSTI PI,PIT2,PI02,OEGS,RAOIAN,K,SEA,LOGTEN
:OHHON IRI NI HOOR IN (3) ,CaLL, FI ELO, SPACE, KAY2, H, PHPT ,PHPR, PHPTH,

SWWFOOl
SWWF002
SWWF003
SWWF004
SWWf005
SWW F006

PH PP H, PHPOH, PH PKR t PHPKTH, PHPKPH. K PHPK. POLAR, LPOLAR,

SWWFOO 7

KPH=SCALE'K~H

CONTINUE
"=.5·(CZ·K2/0~2-N2)
~HPT

=-~NPT

~HPR

=-PN~R

PHPTH=-PNPTH
PHPPH=-PNPPH
PHPOH=-NN~/O~

PHPKR =CZIOHZ.KR

-C/OH.P~PVR

~HPKTH=C2/0H2'KTH-C/OH'P~~VTH

PHPKPH=CZIOHzoKPH-C/OHoPNPVPH
K~HPK=N2

1

BQNC112
BQNC 113

PNPT:PNPX·PXPT
~OLARI=SQRT(V2)·(YT2-RAO)/(2.·VOOTY·UX)

C
C
C

B~NC111

SPACE=N2.EQ.1.
GAH=(-YT2+RAO)/(2.·UX)
LPOLRI=X'SQRT(YT2)/(UX'(J+GAH))
KAYZ=OH2ICZ'NZ
IF(RSTART.EQ.O.) GO TO 3
,:ALE=SQRT(KAY2/K2)
KR =SCALE'KR
KTH=SCALE"KTH
3

BQNC10l
BQNC102
BQNC10J
BQNC104
BQNC105
BQNC106
BQNC107
BQNC108
BQNC109
BQNC110

2

SGN
SWWF008
COHMON IXXI HOOX(Z),X,PXPR,PXPTH,PXPPH,PXPT,HHAX
SHWFQ09
COMHON IYYI HOOY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRPT,PYRPP,YTH,PYTPRSWWFD1D
1
,PYTPT,PYTPP,YPH,PYPPR,PYPPT,PYPPP
SWWF011
COHHO~ IZZI HOOZ,Z,PZPR,PZPTH,PZPPH
SWWF012
COHHON IRKI N,STEP,HOOE,E1HAX,E1HIN,E2HAX,E2HIN,FACT,RSTART
SWWF01J
::;OHHON R,TH,Pi,KR,KTH,KP"I
IWW/IO(10),ND,W(c.IlIJ)
swwrD14
EQUIVALENCE (RAY,W(1)),(F,W(6))
SWWF015
LOGICAL S~ACE
SWWF016
REAL KR,KTH,KPH,K2
SWWF017
CONPLEX KAY2,H,PHPT,PHPR,PHPTH,PHPPH,PHPOH,PHPKR,PHPKTH,PHPKPH,
SWWF018
1
KPHPK,POLAR~LPOLAR,I,UtRAO,O,pNpps,PNPX,PNPy,PNPZ,UX.u xz, SWNF019
2
AlPHA,BETA,GAHHA,A,B,C,TEHP1,TEMP2,TEHPJ.AlPOAL,BEPOBE,
SWWFD20
l
GAPOGA.CB2,N2H1,J2.02GA,QAL,OBET.OGAH,OAOy,OADl.OBOy,DBDl,SWWFOZ1
4
OCOY,OCOZ,OUOZ,OT10X,OT10Y,OT10Z,OT10PS,OT20X,OT20Y,DT20Z,SWWFOZ2
:;
0 fZOPS, ORA OOX, OR4 DOY, ORAOOl, DROOPS, 000 x, OOOY, OilDZ. OOOPX. SWW FOZ3

102

o

U~X,N2,PNPR,PNPTi,PNPPH,PNPYR,PNPVTH,PNPVPH,NNP,PNPT

OATA (HOORIN-SH
S£,6iN-WYLL£R,6H FORHULAI, ICOLL=1.I,
1
IFI£LO=1.I,(LPOLAR=(0.,O.II,
OC =0 • ) , (P XPR= a • ) , (PI( PT H=O • ) • ( PX PP H=Q • ) , ( P XPT= O. ) ,

~

3

I Y=0 • I , I PY PR= 0 • I , (PY PTH=O • I , I PY PP H= 0 • I , ( YR= O. I , I PYRPR=O .I ,
<0
(PYRPT=O. I, (PYRPP=O. I , (YTH=O. I, (PYTPR=O. I, (PHPT=O. I,
5
IPHPP= O. I , IYPH=O.l , I PYPPR=O. I , I PYPP T=O. I ,I PYPPP=O. I ,
•
(Z=O.I, IPZPR=O.l, (PlPTH=O.l,IPZPPH=O.I,
7
II=(O.,l.II,(ABSLIH=1.£-51
£NTRY RINO£X
OH=PITZ·1.E6"F
CZ=SEA'S£A
KZ=KRoKR+KTH"KTH+KPHoKPH
~HZ=OH·OH

SWWF037

SWHF036

~TH=SEA/O"·(T~
~PH=SEA/O"+~P~

$WWF039
SWWF040

~ALL ELECTX
CALL HAGY

SWHFO<01
SHWFO<oZ

OPV=l.+Y

SWWF043

OHY=1.-Y
CALL COLFRZ
ZZ=Z'Z

SWWFO<O<O
SWWFO<o5
SWWFO<O&

:ALL FSW(1./Z,ALP~A,OAL)

SWWF047

ALPOAL=OAL/ALPHA
CALL FSW(OMY/Z,BETA,OBETl
B£POB£=OB£T/BETA
CALL FSW(OPY/Z,GAMHA,OGA~I
DUOZ=I1.+ALPJ~L/Z I/ALPHA
UZ=U'U
UX=U-X
UPX=U+X
B=ALPHA/BETA
D30Y=B"BEP03E1 Z
OBOZ=-B'(ALPOAL-OHY'BEPOBEI/ZZ
C=ALPHA/GAHHA
OCOY=-C"GAPOGA/Z
O:OZ=-C" (ALPOlL-OPY'GAPa:;uIZZ
A=.5·(B+CI-l.
OAOY=.5·IOBOroOCOYI
OAOZ=.5·(OBOZ+OCOZI
TEHP3=11.-B"CloUZ+A"U·UPX

SWWFO<o6
SWWFO<09
SWWF050
SWWF051
SHWF05Z
SHWF053
SWWF05<o
SHWF055
SWWF05&
SWWF057
SHWF056
SWWF059
SWWF060
SWWFO&1
SWWF06Z
SHWF063
SWWFO&<O
SWWF065
SHWF066
SWWF067

IIZ=

SwWF068

GAPOGA=~GAHlGAHHA

VR··Z+VTH··Z+VPH··Z

'JOOTY=I/ R.·Y R+ \I T H+ Y T H+VPH·Y' PH
SWW F 069
YLZ=VOOTY'"Z/VZ
SWWF070
YTZ=Y"Z-rLZ
SHWFon
YZ=Y.Y
SWWF07Z
SZPSI=YTZ/YZ
SHWF073
CZPSI=YLZ/Y2
SWWF07<O
UXZ=UX'UX
SWWF075
CBZ=(C-BI"'Z
SWWF076
TEHP1=TEHP3'SZPSI
SWWF077
0T10X= A"U"SZPSI
SWWF078
OT10Y=IU'UPX'OAOY-UZ'IB"OCOY+C'OBOYII'SZPSI
SWWF079
OT10Z=(Z.·U·DUOZ·(1.-S·C+A)+A·X·OUOZ-UZ·(S·OCDZ+C·080Z)+U.UPX.OADZSWWFoeo
L I"SZPSI
SWWF061
11/lLYT! O/OPSIITEHPll
SWWF06Z
OTLOPS=2.·T£HP1/YTZ
SWWF063
TEHPZ=UZ'CBZOJX ZOCZPSI
SWWF064
OT ZOX=UX'UZ"CBZ'CZPSI
SWWF065
OTZOY=Z.·UZ·UXZ·CZPSI·(C-BI·lOCOY-OBOYI
SHWF066
OTZOZ=2.·UZ"UXZ·C2PSI·IC-BI·IOCOZ-OBOZI+Z."T£HPZ·11./U+1./UXI'OUOZSHWF067
11IYLYTl O/OPSl(T£HPZI
SHWF066
OTZOPS=-Z.·TEHPZ/YLZ
SHWFoe9

z.·

C

Siol N F 027

SWW F OZ 6
SWWFOZ9
SWWF030
SWWF031
SWWF03Z
SWWF033
SWWF03<O
SWWF035
SWWF036

vR =SEA/OH"KR

U=Z/ALPHA

C

SWWF024

SWWFOZ5
SWWFOZ&

103

RAO=RAY"CSQRT(TEHP1""2+TE~P2)

ORAOOX'(TEN?1"OT10X +.5
"OT20X )/RAO
ORAOOY=(TEHP1"OT1DY +
.5"OT20Y)/RAO
ORAOOZ=(TEH~1'OT10Z +
.;"DT20Z )/RAO
I1/YLY Tl O/DPSIlRAO)
OROOPSz(TEHP1'OT10PS+
.;"OT20PS)/RAO

C

O=2.·U·UX"Cl.+A)-TEMP1+RAD+2."A"U·X·SZPSI
000 X=-Z." U-OT 10 X+OR.AOOX+2.·A ".U·S2PSI

OODY= 2."U·UX.OAOY-DT10Y+DRAODY+2."U·S2PSr"OAOY
ODDI=2."Cl.+A)·OUDZ"CU+UX)+l."U·UX·OAOI-OT1Dl+DRAODI+2."X·SZPSI"
1

C

(A"OUOZtJ"ilAOn
(1/YLYT) O/OPSI(O)

OODPS;-OT1DPS+ORODPS+2."A"U·X/Y2
N2Ml =-2 .·X·(UX+U·~·S2PSII/O

N2=1.+N2"1
N OtOX{N)

C

PNPX =-(J X+U"A"S2PSI)" Cl .-X"DDOX/OI/O+X/O

c

N O/OYlN)

PNPY=-X·U·S2PSI/O·OAOY-.S"N2Ml/0·000Y
N O/OZ(N)

C

PNPZ= -X·(1.+A'S2P SI)/O·O~DZ - X·U·S2PSI /O·OADZ-.S· N2Hl/0 "0001

(N/YLYT)

C

D/OPSII~)

PNPPS=-X·U"AI(O"YZ)

-.5"N2Ml/0·00DPS

YLV=VOOTY/V2
IYLYT) O/OR(PSI)

C

PPsPR=YL2/Y'PYPR-(VR'PYRP~+vrH,pYTPR+VPH'PYPPR)'YLV

c

(YLYT)

J/OTHETA(PSIl

PPSPTH=YL2/Y·PYPTH-(~R·PYRPT+VTH·PYTPT+~PH·PYPPT)·YLV

(YLYT)

C

O/OPHIIPSll

~PSPPH=YL2/Y"~YPPH-(VR"PYRPP+VTH"PYTPP+VPH"PYPP~)"YL~
PNPR=PNPX"P~PR+PNPY"PYPR+PNPZ"PZPR+PN~PS"PPSPR

PNPTH=PNPX"~xpiH+PNPY·PYPTH+PNPZ·PZPTH+PNPPS·PPSPTH
PNPPH=~NPX·~XPPH+PNPY"PYP'H+PNPZ·PZPPH+PNPPS"PPSPPH

PNPVR=PNPPS"(VR'YLZ/VZ-YLV"YR)
PNPvT H= PNPPS. (V TH" YL2/ '12 - YLV'Y TH)
?N?VPH=PNPPS·(V?H"YLZ/VZ-YLV"YPH'

NNP=NZ-(Z.'X"PNPX+Y"PNPY+Z·PNPZ)
PNPT=PNPX"PXPT
POLAR=I'ITENP1-RAO)"Y'SQRT(V2)/(U'UX"IC-B)'VOOTY)
COSPSI=VOOTY/(Y'SQRT(V2))
LPOLAR=(.S"I·IC-B)·POLAR+A"COSPSI)·SQRTIS2PSI)1
1

(POLAR"(JX·(l.+.S·I·(C-B)·COSPSI"POLAR)+A"(U-X'CZPSI))
SPACE=REALlN2) • EQ. 1 .. ANO. ABS I A IHAG (N2) ). L T .ABS LIN

(AYZ =OH2/:;Z'N2
IF(RSTART.EQ.D.) GO TO 1
SCALE=SQRT(REAL(KAY2)/K2)
KR =SCALEoKR
KTH:SCAL EoKTH
<PH = SCALE'K~H

1

CONTINUE

C',······· CALCULATES A HAMILTONIAN H
H=.5"IC2"K2/0H2-N2)

C······,·· AND ITS PARTIAL DERIVATIVES WITH RESPECT TO
C········· TIHE, R, THETA, PHI, OMEGA, KR, I(THETA, AND KPHI.
~HPT =-PNPT
PHPR =-PHPR
PHPTH=- PHP TH
PHPPH=-PNPPH
~HPOH=-NN~/OM

PHPKR =C2/0HZ'KR -SEA/OH'PHPVR
PHPKTH=C2/OH2'KTH-SEA/OH'?HPVTH
~~PKPH=C2/0H2'KPH-SEA/OH'PNPVPH

KPHPK=N2
RETURN
ENO

104

SWW F090
SWWF091
SWWF092
SWWFD93
SWWF09"
SWWFD9S
SWW F D96
SWW FD97
SWWF098
SWWF D99
SWWF10D
SWWFiD1
SWWF102
SWWF103
swwn04
SWWF10S
SWWF106
SWWF107
SWWF108
SWWF109
sww F 110
SwWF 111
SWWF112
SWWF113
SWWFJt"
SWWF11S
SWWF116
SWWF117
SWWF118
SWWF 11 9
SWHF120
SWWF121
sww F 122
SWW F123
SWW F124

SWWF125
SWWF126
SWWF127
SWWFi28
S,W WFi29
sww F 13 0
SWWFi31
SW WF 132
SWWF133
SWWF13"
SWWF135
SWWFi36
SWWF137
SWW F138
SWWF139
SWWFi"O
SWWFi"1
SW WF 1"2
SWWF 1"3
SWWF 1"4
SWWF145
SWWF146
SWW F147
SWWF1"8
SWWF149
SWWF1S0
SWWF151
SWWF152
SWWF153
SWWF154-

SUBROUTINE SHNF
CALCULATES THE REFRACTIVE INOEX ANO ITS GRAOIENT USING THE
SEN-HYLL£R FORMULA -- NO FIELO
NEEOS SUBROUTINES FGSW ANO FSW ANO FUNCTIONS C ANO S.

C
C
C

;OMMON ICONSTI PI,PITZ,PIJ2,OEGS,RADIAN,K,C,LOGTEN
COMMON IRINI MOORIN(3',COLL,FIElO,SPACE,KAY2,H,PHPT,PHPR,PHPTH,
1
PHPPH,PHPOH,PHPKR,PHPKTH,PHPKPH,KPHPK,POlAR.LPOLAR.
2

5GN

COHMON IXXI HOOX(Z),X,PXPR,PXPTH,PXPPH,PXPT,HHAX
COMHON Iyrl MOOY.Y(101
:OHHON 1111 HOOZ.Z,PZPR,~ZPTH.PZPPH

COHMON IRK! N,STEP,MODE,E1HAX,E1HIN,EZHAX,EZHIN,FACT,RSTART
COHMON R.TH,PH,KR,KTH,KPH
INWI IO(10),WO,w(~oa)
ElUIVALENCE (~AY.W(lll.(F.W(oll
LOGICAL SPACE

REAL KR,KTH,KPH,K2
:)HPLEX
1

KPHP<,POLARtLPOLA~,PNPX,PNPZ,Fl,OFtGltOG1,

2

NZ,PNPR,PNPTH,PNPPH,PNPVR,PNPVTH,PNPVPH,NNP,PNPT
OATA

1

KAY2,~,PHPT,PHPR,~HPTH.PHPPH,PHPOH,PHPKR,PHPKTH,PHPKPH,

(~OORIN=6H

SE.6~N-WYLLER.SH FORMULAI. (COLL=1.1.
(F I EL 0= 0 • ) , ( POLAR.: (0. , 1.) ) , (L POL AR= ( 0 • , 0 • ) ) ,

2

(x=o.), (PXPRz:O.', (PXPTH=O.),(PXPPH=O.), {PXPT=O.J ,

3
4

(HOOV=lH I.
(Z <0 • I. (P Z PR= 0 .J • (PZ P T H= 0 • ) • ( PZ PP H= 0 • I •

~

(A8SLIM=1.E-5),(PHP~~=O.),(PHPVTH=O.),(PNPVPH%O.)

ENTRY RINJEX

OM=PITZ·l.Eo·F
CZ=Coc
K2=KR·K~+KTH·(TH+KPH·KPH

OH2=0"'''OH
VR =C/OKoKR
vtH=C/O~oKTH
VPH=C/O~oKPH

CALL ELECTX
CALL COLFRZ

CALL FGSW(1./Z,Fl,OF1,Gl,OG1)
NZ =l.-xoGl
PNPX=-.soGl

PNPZ=.S·X·.OG1/Z··2
P~PR=PNPX·PX?R+PNPZ·PZPR

PNPTH=PHPX·PXPTH+PNPZ·PZPTH
PNPPH=PNPX·PXPPH+PNPZ·PZPPH
NNP=N2-(Z.·X·PNPX+Z·PNPZ}
PNPT=PNPX·PXPT
S PACE=RE AL (NZI • EO. .1 •• ANO. ABS (A IHAG (NZ) I. LT. ABS LIH
KAYZ=OH2ICzoNZ
IF(RSTART.El.D . I GO TO 1
SCALE=So.RT(REAL(KAYZI/KZI
KR =SCAlPKR
KTH=SCALEoKT ~

<PH=SCAlE·KPH
1

~ONTINUE

C•••• • ••• • CALCULATES A H~HILTONIAN H
H=.S"(:?·K2/0M2-N2'

C••• •• ... •• AND ITS PARTIAL DERIVATIVES WITH RESPECT TO

c ....... • .. •• TIHE, R, THETA, PHI, OHEGA, KR, KTHETA, AND KPHI.
PtiPT =-PNPT
PHPR = -PNPR
PHPTH=-PNPTH
PHPPH=-PNPPH
PHPOH=-NNP/O~

PMPKR =C2/0~Z'KR
PHPKTH=CZIOHZ'KTH
PHPKPH=CZIOHZ'KPH
KPHPK =NZ
RETURN
ENO

105

SWNFOOl
SWNF002
SWNF003
SWNF004
SWNF005
SWNFOOo
SWNF087
SWNF008
SWNFOD9
SWNF010
SWNFDl1
SWNFD1Z
SHNFD13
SWNFD14
SWNF015
SWNFD10
SWNFD17
SWNFD18
SWNFD19
SWNFOZO
SWNF021
SWNFD22
SWNFDZ3
SWN FD24
SHNFDZ5
SHNFD20
SWNF027
SWNFOZ6
SWHF029
SWNFOJO
SWHFOJl
SWNF032
SWNF03J
SWNFOJ4
SWNF035
SNNFOJ6
SNNFOJ7
SWNFOJS
SHNF039
SHNF040
SWNF041
SHNF04Z
SHNFD43
SWNF044
SWNF045
SWNF040
SWNF047
SWNF048
SWNF049
SWNFOSO
SWNFOSI
SHNFOSZ
SWNFOS3
SHNF054
SHNFOSS
SWNF05&
SWH F 05 7
SWN F 05 8
SWNFOS9
SWNFOoO
SNNFOol
SWN F OOZ
SWNFOoJ
SWN F 004
SWNFOoS
SWNF 000
SWNF067-

SUBROUTINE FGSW ( X,F ,DF,G,or.l
FGSWOOI
COMPLEX F,DF, G, DG
FGSWO OZ
CALL FSW (X,F, DFI
FGSW0 03
IF(ABS(Xl.GT.S O. ) GO TO 1
FGSW 00 4
G=X*F
FGSW OO S
DG =F+X*DF
FGSW 00 6
RETURN
FGSW 007
XZ=X * X
FGSW OOS
X3 =XZ*X
FGSW 009
TZ=Z.*XZ
FGS WOIO
T3=3.*XZ
FGSWOll
T4=4.*X?
FGSW OI Z
T8=8.*XZ
FGSW 0 13
TIZ=lZ.*X2
FGSW014
T16=16.*X 2
FGSWOlS
G=CMPLX(1.-3S.IT4*<1.-99.IT4*{1. -1 95.IT4*{1. - 323.IT4)) )IT4,
FGSW016
lZ.5*{1.-6 3 ./T4* (1 .-143./T4* ( 1.-255. I T4* (1 .-399./T4) I ))/X)
FGSWOl1
DG=.5*CMPLX(3S.*(1.-99./TZ*<1.-585.ITS*(1.-323./T 3* ( 1. -241S./T1611FGSW018
1 J )/X3,
FGSW019
2-5.*(1. -189 ./T4*{l.-11S./T12*(1.-357.IT4*(1. - 513.IT41 )II/XZ)
FGSW 0 2 0
RETURN
F GS W021
END
FGSW 22-

C
C
C

C

C

100

300

SUBROUTINE FSW IZ,F,OF)
FSW
FIZ) = Z'C312IZ) + 2.S'I'CS/2IZ)
AND
DFlll = DF/DZ
FSW
WHERE THE INPUT Z IS REAL AND THE OUTPUT F AND OF ARE COMPLEX. FSW
NEEDS TiE SUBPROGRAMS <OR THE FRESNEL INTEGRAL FUNCTIONS SAND CFSW
DIMENSION All0),Bll0),OI10)
FSW
COMPLEX F,O!=',Cl,C2,C3,C8, If,TEHP,I
FSW
DATA 11=10.,1.)), IPI=3.1lt15926536), IA3=1.333333333)
FSW
DATA IC2=ll.,l.)), IC3=<1.,-1.)) ,ICIt=.79788456
),IC6=1.333333333) FSW
C4=SQRTI2./PI)
FSW
JATAIA=.36230545E-02,.29579186E+00 •• 23193588E+Ol,.91J55870E+Ol,
FSW
1.25856287E+02,.60488560E+02,.12562218E+03,.24214980E+OJ,
FSW
2.44918106E+03 •• 84244774E+03),
FSW
3 I B= doH 7It 79€- 02, .8479626 OE- 01 •• 252650 OLE +00, .2266585 TE+O 0,
FSW
4.83871933 E -01, • 138118 75E- 01, .98017 4HE -0 3,.202 991"8E-0 4,
FSW
i.19761GO&E-OEl, • 187811t7&E-tJ 'H ,
FSW
5(O:.100IJOo53E-03, .461179ItlE-Ol, .38507&1t3E+OO, .&8507885E+OQ,
FSW
7.426481 05E +0 0, • 10742102E+00, .10 985920E -0 1,. "0924533E-0 3,
FSW
6.41881263E-05, ."'513142E-08) ,IG=1.5045055)
FSW
Cl:Z./3. 4 r
FSW
~8=C2'A3'SQRTIPI/Z.)
FSW
X=Z
FSW
.(Z=X"X
FSW
)(3=XZ·X
FSW
IFIABSIO.GT.;O.) GO TO 500
FSW
IFIABSIX).GT.6.) GO TO 1
FSW
IFIABSIX).LT •• 05)GO TO ZOO
FSW
FRESNEL
FSW
IFIX.GT.O.) GO TO 300
FSW
Y,C4'SQRT I-X)
FSW
)(2=X·X
FSW
!of= (COS( X) +r.SIN (X) 4( 1.-C3 4 (C(Y) +14S (Y»))
FSW
F =Cl+:&.(X+:3.X.X/Y.W)
FSW
OF:A3·CMPLX( 1., Xl +CHPLXU. 5, Xl 4A3·C3·X/Y·W
FSW
;o.ETURN
FSW
Y=C4'SQRT I X)
FSW
XZ=X·X
FSW
W= ICOS( X) +1' SIN IX) )' I 1.-CZ' IC I V) -I 'S Iv)))
FSW
F
=CltCo'(X-:Z'X'X/Y'W)
FSW
OF=A3·CMPLX(1.,X)-CMPLX(1.5,X)·A3·CZ·X/Y·W
FSW
RETURN
FSW

106

001
002
003
004
005
006
007
008
009
010
011
012
013
014
015
010
017

Die
019
020
021
022
023

OZ4
025
026
027

OZ6
OZ9
030
031
032
033
03<0
035
03&
037
038
039
040

C

POWER SERIES
ZOO

TEMP=-C6' SQRTlXI'CEXP(I'XI

FSW
FSW
FSW
FSW
FSW
FSW
FSW

F=CHPLX(4./J.*X-16./9 •• X3+64./315 •• X5.2./3.+6./3 •• X2-3 2./45 •• X4)

FSW 046

~=ABS(ZI
~2=X"X
X3=~2"X

X,=X"X3
~5=X"X'

1

1
2

+TEptP·1(
OF=CHPLX(,./3.-16./3."X2+&~./63.'X •• 16./3."X-126.1'5." X3
+256./9~5.'X51

+TEHP"GHPLX (1. 5.XI
IF(Z.GE .O.I RETURN
F=-CONJG(FI
JF=CONJG(OFI
RETURN

C
1

X~

= X··2

HERHITE

X2=XQ
FR = O.
FI = O.
OFR = O.
OFI = O.
00 2 J = 1.10
SS = A(J) + XQ
SB = S(JI/SS
SO = O(JI/SS
FR = FR + sa
FI = FI + SO
OFR = OFR + S3/SS
2 OFI = OFI • SO/SS
F = CHPLX(X'F~.FII"G
OF = G'(FR - 2.'~'CHPLX(X'OFR.OFIll
RETURN
C
ASYMPTOTIC
500 ~2=X"X
X3=X2'X
X~=X3.( ·

X5 =X4-X
TZ=2.'X2
T3=3.'X2
T~=4 •• (2
T6=6.'X2
T16=16.'X2
T26=26.'X2
F=CHPLX«l.-35./T"(1.-99./T"(1.-195./T"(l.-323./T41II)/X
1.5.'(1.-63./T"(1.-143./T"(1.-255./T"(l.-399./T~111 I/T21
OF=-CHPLX«1. -105./T"(l.-165./T"

RETURN
END

0~2
0~3
O~~
0~5
0~6

0~7

FSW

049

FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW
FSW

050
051
052
053
05~

055
056
057
058
059
060
061
062
063
06~

065
066
067
068
069
070
071
072
073
07.
075
076
077

FSW 078
FSW 079

FSW 080
FSW 061
FSW 082

FSW
FSW
FSW
FSW
FSW

(l.-273./T~'(l.-2907./T281111/X2FSW

1,5 •• (1.-63.IT2.U.-429./TS.(1.-255.IT3.U.-1995./T1&") )/X3)

0~1

083
08.
065
066
067
088

FSWaeq

FSW 090
FSW 91-

107

FUNCTION C(XI
DOUB LEPRECISION
PIH, XD .. Y.. V. A, OZ, ON, 0, Z
DATA (Al=O.31830991,(A2= O. 10132),{Bl=O.0968),{B2=0.154)
PIH = 1.570796326794897
XA

= ASS!Xi

IF

(XA.GT.4.1

XD

=X

Y
V

PIH*XD*XD

A =

1. DO

c

GOTa 20

c
c
c

c

A
M
15.*CXA + 1.1
DO 10
I = 1, ~
KZ=2*( I-I)
KV=4*( I-I)

c

c
c
c
c
c

KV + 1

ON = IKl + 1)*{KZ + ZI*IKV + 51
Q

= OZION

A
10 Z

- A*O*V

c
c
c
c
c
c
c

Z + A

l*XD
Z

RETURN

c
20

c

W = PIH*X*X
XV~XA**4

c

RETURN
END

c

C=O.5+(AI - BI/XV)*SINCW1/XA-(A2-B2/XV1*COSIW 1/XA**3
IF (X.LT.O.)
C = -C

c

c

FUNC TI ON SeX)

S

PIH, XD, y, V, A. OZ. ON, O. Z
DATA CAl=0. 3 183 099 ),(A 2 =0.lOI321,(Bl=O. 0 968),(B2=0.1541
PIH = 1.5707963Z679~897

S

XA = AAS(XI
IF (XA.GT.4.1

S
S
S
S
S

XD
Y
V

GO TQ

20

= X

S
S

PIH*XO*XI)
Y*Y

S

S

A

Y/3.DO

S

Z

A

M

1~.*(XA

S
S
S

+ 1.)
J = 1. M

00 10

KZ=2*(I-l)
KV=4*(I-IJ
OZ
KV + 3
ON
CKZ + 2)4CKl + 3 1*CKV
Q

S
S

S

+

s

71

OZION

S
S
S
S
S
S

A :::r -A*Q*V
10 Z
l

=Z + A
= l*XD

S = Z
RETURN

20

c
c

DOUBLfPR~ctSION

c

c

c
c
c
c
c

2

Z
C

c

c

y*y

QZ

c

S

W = PIH*X*X
XV=XA**4
S=0.S -(AI-BI/XVJ*CO S(WI/XA -IA2-B2/XVI4 SIN (W 1 / XA**3
IF IX.LT.O.1
S = -S

S
S

RETURN
END

S
S

108

S
S

001
002
003
004
005
006
007
008
009
010
0 11
0 12
013
0 14
015
016
017
018
019
020
021
022
023
024
025
026
027
028
029
030
31-

001
002
003
00 4
005
006
007
008
009
010
011
012
013

014
0 15
0 16
017
018
019
020
021
022
023
024
025
026
027
028
029
030
031
32-

APPENDIX 3 .

ELECTRON DENSITY SUBROUTINES WITH
INPUT PARAMETER FORMS

The following electron density models are available.

The input

parameter forms, which describe the model, and the subroutine listings
are given on the pages shown.

a.

Tabular profiles (TABLEX)
Subroutine GA USEL
Chapman layer with tilts, ripples, and
gradients (CHAPX)
Chapman layer with variable scale height
(VCHAPX)
Double, tilted a -Chapman layer (DCHAPT)
Linear Layer (LINEAR)
Plain or quasi-parabolic layer (QPARAB)
Analyti c equatorial model (BULGE)
Exponential profile (EXPX)

b.
c.

d.
e.
f.

g.
h.
i.

lli
113
115
117
118
120
121
122
124

A further sourc e of versatility in this ray tracing program is the
ease with which specific ionospheric models, suited to the users needs,
may be introduced.

To add electron density models not included in the

program, the user must write a subroutine that calculates . the normalized electron density (X) and its gradient (oX/a r, aX/a8, oX/acp) as a
function of position in spherical coordinates (r, 8, cp ).
where N

(X = 80.5xIO- 6 N/f 2 ,

is the electron density in cm --3 and f is the wave frequency in

MHz . )
Both X

and its gradient must be continuous functions of position.

The formulas for

oX /a r, oX/ae, and aX/ocp

variation of X with r,

8, and cp .

Otherwise,

must be consistent with the
the program will run

slowly and give inc o rrect results.
The coordinates

r, 8 , cp

refer to the computational coordinate sys-

tem, which may not be the same as geographic coordinates.

In particular,

they are geomagnetic coordinates when the earth- centered dipole model
of the earth's magnetic field is us ed.
The input to the subroutine (r, 8, ¢) is through blank common.

109

(See

Table 3.)

The output is through common block IXX/.

(See Table 8 . )

It

is useful if the name of the subroutine suggests the model to which it cor responds.

The subroutine should have an entry point ELECTX so that

other subroutines in the program can call it.

Any parameters needed by

the subroutine should be input into WIOI through W149 of the Warray.
(See Table 2.)

If the model needs massive amounts of data,' these should

be read in by the subroutine following the example of TABLEX.

As in

the already existing electron density subroutines, provision should be
made for perturbations to the electron density model (irregularities) by
having the statement
IF(PERT.NE.O.) CALL ELECTl
before the RET URN statement at the end of the subroutine.

110

INPUT PARAMET ER FORM

FOR S UBROUTINE TABL E X

IOiWSPIiERIC ELECTROIl DEIISITY PROFILE
Fir s t card tells how many profile pointe in 14 format.
The cards following the first
c ard give the height and electron density of the profile points one point per card in F8. 2,
E Il.4 forITlat. The h e ights must be in in c reasing order. Set WIOO = 1. 0 to read in a new
pr o file. After the cards are read, T ABLEX will reset WIOO = O. O. This subroutine
m akes an exponential extrapolation down using the bot tom 2 points in the profile .

I ' 1.3i4,5 6,7la 9 10!II 111 3 : 14 1 15 , 16 ~ 17 : la : 19 i10 I 111314' 5 6171ai911OH 1111'31141
1511611711al191101

i

HEIGHT
h
km

HEIGHT

ELECTRON DENSITY
N
ELECTRONs/em'

h
km

, I

I

,

ELECTRON DENSITY
N
ELECTRor~s/e m '
I
I I I I I
I I
I I I I I f-I--+--t-f-l-I-

-+-t-+
I

I

I

,

,

,

111

SUBROUTINE TABLEX
C
CALCULATES ELECTRON OENSITY ANO GRADIENT FROM PROFILFS HAVING
THE SAME FORM AS THOSE USED BY CROFTS RAY TRACING PROGRAM
C
C MAKES AN EXPONENTIAL EXTRAPOLATION DOWN USING THE BOTTOM TWO POINTS
C
NEEDS SUBROUTINE GAuSEL

TABXOOI
TABX002

TABX003
TABXOU4

DIMENSION HP(C250),FN2C(250)'ALPHA(250),BETA(2S0),GAMMAC250),

TABX005
TABX006

1 DFLTAf?tinl , SLOPF:f?liOI,MATI4,'i)

TA8X007

(OMMON ICONST/ PI,PIT2,PID2,DEGS,RAD.K.DUMI21
cOMMON IXX; MOOX(2).X,PXPR,PXPTH,PXPPH,PXPT,HMAX

TABX008
TABX009
COMMON R(61 /'WW/ lOtIO) ,WO,WI40QI
TABX OIO
E.QUIVALENCE (EARTHR.W(2») ,(F,W{6)) ,(READFN.WI 100) ) ,(PERT,W( 150) I
TABXOII
REAL MAT,K
TABXOl2
DATA {MOnXflJ=6HTAALEXI
TAAX013
ENTRY ELECTX
TABX014
IF fREADFN.EQ.O.l GO TO 10
TABX015
READFN=n.
TABX016
READ 1000, NOC,(HPCCJ),FN2CCII,I=1,NOCI
TABX017
1000 FORMAT (I4/(F8.2,E12.411
TABXOl8
PRINT 1200, (HPCIIl,FN2C(Ild=1,NOCI
TABX019
1200 FORMATIIHl,14X,6HHEIGHT,4X,16HELECTRON DENSITY/IIX,F20.IO,E20.101ITABX020
A=O.
TABX021
IFIFN2CCII.NE.0.1 A=ALOG CFN2C C21/FN2C C11 II CHPC C2 I-HPC CII I
TABX022
FN2CCli=K*FN2CCll
TABX023
FN2C(21=K*FN2C(Z)
TABX024
SLOPECII=A*FN2CCII
TABX025
SLOPECNOCI=O.
TABX026
NMAX=1
TABX027
DO 6 I=2,NOC
TABX028
IF CFN2CCII.GT.FN2CCNMAXII NMAX=I
TABX029
IF CI. EO. NOC I GO TO 4
TABX030
FNZC(I+l'=K*FN2C( 1+1'
TABX031
DO 3 J=1,3
TABX032
M=I+J-2
TABX033
MATIJ,ll=l.
TABX034
MATIJ,21=HPC{MI
TABX035
~AT(J,31=HPC(M)**2
TABX036
~AT(J,4)=FN2C(MJ
3
TABX037
CALL GA USEL (MAT,4,~,4,NRANKI
TABX03B
IF CNRANK.LT03 1 GO TO 60
TABX039
SLOPEII)=MAT(2,4'+Z.*MATI3,4 J *HPClt)
TABX040
400 5 J=1.2
TABX041
M=I+J-2
TABX042
MA T(J ,l) =l.
TABX043
MATIJ,Z' =HPC{MI
TABX044
MATIJ'3'=HPCCM)**Z
TABX045
MATIJ,4J=HPCCM'**3
TABX046
MAT IJ,SI=FN2C(MI
TABX047
L=J+2
TABX048
MATIL,l'=O.
TAB X049
MATIL,ZI=l.
TABX050
MA TIL,31=2.*HPCIMI
TABX051
~A T{l'41=3.*HPC{MI**2
TABX 052
5 MAT(L.SI=SLOPE(MI
TABX053
CALL ~AUSEL (MAT,4,4.5,NRANKI
TA8X054
IF (NRANK.LT.4) Go TO 60
TABXd-55
ALPHA ( I I =MAT (I, "i I
AFTA(j)=MAT(2,5J

TABXO,6
TAAX057

GAM¥A(TI=MAT(~,"i1

TABX058

6 DELTA(IJ =MAT(4,1j)

TA8XOlj9

HMAX=HPC(NMAX)
F2=F*F

TABX060
TABX061
TABX062
TABX063

PXPR=O.

TA8X064

NH=2

10 H=RCII-[ARTHR
IF CH.GE.HPCIIII 0,0 TO 12
11 NH=2
X=O.

TABX065
TABX066
TABX067

112

TABX068
T ABX06Q
TABX070
PXPR=A*X
TABX071
GO TO 50
TABX072
12 IF IH.GE.HPCINOCII GO TO 18
TABX073
NSTEP=1
TABX074
IF IH.lT.HPCINH-11 I NSTEP=-1
TABX 0 75
15 IF IHPCINH-II.lE.H.AND.H.lT.HPCINHII GO TO 16
TABX076
NH=NH+NSTEP
TABX071
GO TO 1~
TABX078
16 X=(ALPHAINH'+H*'BETAINHI+H*IGAMMA(NHI+H*OELTA{NHIIII/F 2
TABX079
PXPR= (SETA( NH) +H* (2 •• GAMMA (NH I+H* 3 .-DEL TA (NH) II IF2
TABX080
GO TO 50
TABX081
18 X=FN2CINOC'/F2
TABX082
50 IF IPERT.NE.O.I CAll ELECT}
TABX083
RETURN
T ABX084
60 PRINT 6000. I .HPC( J)
6000 FORMATI4H THE.I4.55HTH POINT IN THE ELECTRON DENSITY PHOFIlE HAS TTABX085
TABX086
lHE HEIGHT,F8.2.40H KM. WHICH IS THE SAME AS ANOTHER POINT.)
TABX087
CAll EXIT
TABX088
END
IFIFN?Clll.EQ.O.1 Gn Tn 50
X=FN?C{l l *EXPIA*(H-HPCll lll tF/.

SUBROUTINE GAUSEL {(,NRD,NRR,NCC.NSFI
C·*·*···· * SAMf AS SUBROUTINE GAUSSEL WRITTEN BY L. DAVID LEWiS

C

DIMENSION C(NRO,~CC1,L(128,21
SITS = 2.*.-18
DATA IBIT S=3.8146972656E-61
NR=NRR
NC=NCC

GAUS003
GAUS004
GAUS005
GAUS006
GAUS007
GAUS008
GAUSQ09

C

INITIALIZE.

C

NSF=O
NRM=NR-l
NRP=NR+l
D=l.

lSD=1
1)0 1 KR=l.NR

LIKR.!'=KR
LIKR.2)=O
IFINR.EO.ll GO TO 42
C

C

ELIMINATION PHASE.
DO 41

KP= l.NRM

KPP=KP+l
PM=O.
MPN=O
C

C

SEARCH COLUMN KP FROM DIAGONAL DOWN FOR MAX PIVOT.
DO 2 KR·KP.NR
LKR=LIKRd)

2

PT=ABSICILKR,KPJ 1
IFIPT.lE.PMI GO TO 2
PH=PT
MPN=KR
lMP=lKR
cONT INUE

C

C

GAUSOOI

...... **· ...... ·GAUS002

IF MAX PIVOT IS ZERO. MATRIX IS SINGULAR.
IFIMPN.EO.O' GO TO 9
NSF=NSF+l
IFIMPN.EO.KPI GO TO 3

113

GAUS010
GAUSOll
GAUS012
GAUS013
GAUS014
GAUS015
GAUS016
GAUS017
GAUS018
GAUS019
GAUS020
GAUS021
GAUS022
GAUS023
GAUS024
GAUS025
GAUS026
GAUS027
GAUS028
GAUS029
GAUS030
GAUS031
GAUS032
GAUS033
GAUS034
GAUS035
GAUS036
GAUSO.37
GAUS038
GAUS039
GAUS040

(

(

NEW ROW NUMBER KP HAS MAX PIVOT.
LSD=-LSD
L{KP,2)=L(~PN,1)=L(KP,11

GAUS044

L(KP'I1=L~P
(

(
3

ROW OPERATIONS TO ZERO (OLUMN KP BELOW DIAGONAL.
MKP=LCKP,11
P=CI!o1KP,KPI
D:::ID*P

DO 41 KR=KPP,NR
MKR=L (KR, II
Q=CI~KR,KP)/P

IFCQ.EO.O.) GO TO 41
(

C

SUBTRAC T 0 * PIVOT ROW FROM ROW KR.
DO 4 LC=KPP,N C
R=O*CIMKP,LCI
C(~KR ,LC1=C{~KR'LCI-R

4
41

IF(ABS(C{~KR'LCll.LT.ABSIRI*BrTSI

C(~KR'LCI = O.

(O NTINUE

(

(
42

LOWER RIGHT HAND (ORNER.
LNR=lINR,ll
P=CCLNR,NRI
IFCP.EQ.O.I GO TO 9
NSF=NSF+l
D=O*P*LSo
IF'NR.Eo.N(1 GO TD 8

(

(

BACK SOLUTION PHASE.
DO 61 MC=NRP,NC
C (LNR.~CI=C{LNR,MCI/P

IF'NR.EO.II GO TO 61
DO 6 LL=l ,NR~

KR=NR -LL
MR=L(KR,ll
KRP"'KR+l
DO 5 M$=KRP,NR
LMS=LIMSdl

5

6
61

R=C(MR,MSI*C{LMS,MCl
CIMR,MCI=CCMR.MCI -R
IFIABS(CCMR,MCII.LT.ABSIRI*BITSI CIMR,MCI=O.
CIM R.MC1=CIMR,MCI/(IMR,KRI
(ONTINUE

(

(

SHUFFLE SOLUTION ROWS BACK TO NATURAL ORDER.
DO 71 lL=l,NRM

KR=NR-LL
MKRzL{KR,2)
IF'~KR.EO.OI

GO TO 71

MKP=LiKR,ll
DO 7 LC=NRP,NC

7
71

Q=«MKR.LCI
C(MKR,LCI=CIMKP,LCI
C{MKP,LCi=O
CONTINUE

(

(
B
q

GAUSO.l
GAUS042
GAUSO.3

NORMAL AND SINGULAR RETURNS.
C{1,1i=D
GO TO 91
(<1,11=0.

91 RETURN
END

114

GOOD SOLUTION (OULD HAVE D=O.

GAUS045
GAUS046
GAUS047
GAUS048
GAUS049
GAUS050
GAUS051
GAUS052
GAUS053
GAUS054
GAUS055
GAUS056
GAUS057
GAUS058
GAUS059
GAUS060
GAUS061
GAUS062
GAUS063
GAUS064
GAUS065
GAUS066
GAUS067
GAUS068
GAUS069
GAUS070
GAUS071
GAUS072
GAUS073
GAUS074
GAUS075
GAUS076
GAUS077
GAUS078
GAUS079
GAUS080
GAUS081
GAUS082
GAUS083
GAUS08.
GAUS085
GAUS086
GAUS087
GAUS088
GAUS089
GAUS090
GAUS091
GAUSD92
GAUS093
GAUS094
GAUS095
GAUS096
GAUS097
GAUS098
GAUS099
GAUSI00
GAUSI0l
GAUSI02
GAUSI03
GAUSI04-

INPUT PARAMETER FORM FOR SUBROUTINE

CHAPX

An ionospheric electron density model cons isting of a Chapman layer with
tilts, ripple 5, and gradients

r

:2

-z "

fC exp ,,- Ci (l-z-e
h - h

=

z

h

c

h

max

max

H

=<0

2

f

)/

( I +ASin ( 2T1 (e - D/B)+C "e

rnax o

~

E

-%) )

(e - ~
'I R o
2 ",,'

IN is the plasma frequency
h is the height above the ground
Ro is the radius of the earth in km
and

e is the colatitude in radians.

Specify:
Critical frequency at the equator,

f

Co

= _________MHz (WIDI)

H e ight of the maximum electron density at the equator,

Scale height,

h

=

max o

km (WI02)

H = _ _ _ _ _ _ _ km (WI03)

'" = _ _ _ _ _ (WI04, 0.5 for an

Ci

Chapman layer,

1. 0 for a

8 Chapman layer)
2

Amplitude of periodic variation of Ie with latitude,

Period of variation of £2 with latitud e,
c
Coefficient of linear variation of

Tilt of the layer,

l

B =

with latitude,

E = _ _ _ _ _ _ _ rad (WIOS)

115

= ______ (WIOS)

rad
deg (WI06)
- - - - - - km

C

deg

A

C = _ __

rad- 1 (WIO?)

SU8ROUTINE CHAPX
CHAPMAN LA YER WITH TILTS~ RIPP LES. ANO GRAOlENTS
W{1041 = 0 . 5 FOR AN ALPHA - CHAPMAN LAYER
= 1.0 FOR A 8ETA - CHA PMAN LAYER
COMMON ICONST! Pr , P tT2,PI02' DUM(51
COMMON /XX/ MODX(21, X,P XPR,PXPTH ,P XPPH,PXPT ,HMAX

C
C
C

COMVON R(6)

/~W/

EQUrVAlE:N CE
EJU IVALENCE

(THET A.RIzJ 1

ID ( l O ),W Q,W(40 0 1

iEARTHR.W(2 J) .tF.W(6)),(FC.WIIOll),(HM,WllOZ)).

1 ISH,WII03)),(ALPHA,WII 04) ),(A.W(lOSJ),(S.Wtl06) ),(C.W(107)1.
2

(E.W(lOa) ),(PERT,W(1 50 1 )

DA TA (MOOXIll=6H CHAPX I
ENTRY ELECTX
THETAl=THETA-PIDl
HMAX =HM+EARTHR*E*TH ETA2
H=R'll -EARTHR
l=IH-HMAXI/SH
0 =0.
IF CB.NE.O.l D=PIT2/8
TEMP =1.+A*SINI D* THET A21+C*THETA2
EXl =I.-E XP' - Zl
X=IFC/FI**Z*TEMP*EXPIALPHA*(EXl -ZI I
PXPR =-AL PHA *X*E XZ/SH
PxPTH =X*ID*A*SINIPJD2 - D*THETA21+CI/TEMP-P XPR*EARTHR*E
IF ,PERT.NE.O.l CALL ELECTI
RETURN
END

116

CHAPOOI
CHAPOOl
CHAP003
CHAP004
CHAP005
CHAP006
CHAP007
CHAP008
CHAP009
CHAPOIO
CHAPOII
CHAPOll
CHAPOl3
CHAPOl4
CHAPOl5
CHAPOl6
CHAPOl7
CHAPOIS
CHAPOl9
CHAPOlO
CHAPOll
CHAPOll
CHAPOZ3
CHAPOl4
CHAPOl5
CHAPOl6
CHAP l7 -

INPUT PARAMETER FORM FOR SUBROUTINE VCHAPX
An ionospheric electron density model consisting of a Chapman layer
with variable scale height

h is th e height above the ground.

Specify:
critical frequency, fc = _ _ _ _ _ M~z (WlGl)
height of maximum electron density, h
)(

max

= ______ km (WI02)

~----- (WI03)

SUBROUTINE VCHAPX
CHAP~AN LAYER WITH VARIABLE SCALE HEIGHT
cOMMON

IXX/ MODX(21,X,PXPR,PXPTH,PX'PPH,PXPT,HMAX

COMMON R(6i /WW/ IO{lOI.WQ.W(40Ql
1

EQUIVALENCf (EARTHR,W(211 ,(F,W{611 ,(Fe.WI 101)) ,(HM,W( 102)1,
(CHI,WQ031 J ,(PERT.WIl501 I

DATA (~ODX(lJ=6HVCHAPX)
EN TRY ELECTX
HMAX=HM
X=PXPR=O.

H=R(jl-EARTHR
IF (H.LE.n.1 GO TO 50
TAU=IHM/H1**CHI
X=(FC/FI**2*SQRT(TAU1*EXP{O.S*<1. -TAUJ I
PXPR=.S*X*/TAU-l.I*CHI/H

SO IF (PERT.NE.O.l CALL ELECTl
RETURN
END

117

VCHAOOI
VCHA002
VCHA003
VCHA004
VCHA005
VCHA006
VCHA007
VCHA008
VCHA009
VCHAOjO
VCHAOll
VCHAOl2
VCHA013
VCHAOl4
VCHA015
VCHAOl6
VCHA017
VCHAOl8-

INPUT PARAMETER FORM FOR SUBROUTINE DCHAPT

(1-

An ionospheric electron density m.odel consisting of a double, tilted
Chapm.an layer

lN = fZcl exp -Z1 (l-z 1 - e -Zl ) + f ZcZ exp 21 ( l - z Z -e -Z2 )
h-h

h-hm.l

zl

=

fZ
cl

= fZclO C(8 -n/Z)

Zz

HI

=

m.Z

HZ

Z
l cZ = f czo
C(S-n/Z)
n

n

fT

n

h

h
+ R 0 E ( 180 ) (8 - -Z)
m.l = m.lO

h

+ R E ( 180 ) ( e - -)
Z
m.Z = hm.ZO
0

Specify:

=

MHz (f

at equator)

(W 101)

=

Km. (hm.l at equator)

(W 10Z)

HI

=

Km.

(W 103)

f

=

MHz (f cZ at equator)

(W 104)

=

Km. (hm.Z at equator)

(W 105)

HZ

=

Km.

(W 106)

C

=

rad

E

=

deg

f

dO

h

h

m.lO

cZO
m.ZO

-1

cl

(fractional change in fCl' fcZ.
position for increases southward)
(positive for upward tilt to the south)

118

(WI07)
(WI08)

SUBROUTINE DCHAPT
TWO CHAPMAN LAYERS WITH TILTS
COMMON ICONS T/ PI,PIT2,PID2,OUM(5)
COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
COM ~·10N

R(6)

/WWI

IOIIOI,WQ,WI4001

EQUiVALENCE (EARTHR,W(2J1,(F,W(6)),{FCl,WllOll),(HMl.Wl102)).
1
2

(SHbW( 103) I ,(FC2,W(104) ) , (Hf-12,W( 1(1511 ,(SH2,WCI 0611, ((,WIID7)),
(E,WII08),(PERT,w(150))

DATA

(~ODX(lJ=6HDCHAPTl

ENTRY ELECTX
EARTHE =EARTHR*E
THElAZ=R(Zl -PID2
HMAX=HMl+EARTHE*THETA2
X=PXPR=PXPTH=a.
H=RCIJ-EARTHR
IF (H .ll.O.) GO TO 50
ll=(H-HMAX1/SHl

EXPZl=l.-FXP(-Zll
TEMP=1.+C*THETA2
X=(FCI/F1**2*TEMP*EXP(.S*(EXPZI-Zl'l
PXPR=-O.5*X*EXPll/SHl

PXPTH=X*C/TEMP-PXPR*EARTHE
IF (Fe2.EO.o.) GO TO 50
l2=(H-HM?-EARTHE*THETA21/$H2
EXPZ2=1.-EXP(-Z2)

X2=(FC2 / FI**2*TEMP*EXPI.S*IEXPZ2-Z2)'
X=X+X2
PXPR2=-O.S*X2*EXPZ2/SH2
PXPR=PXPR+PXPR2
PXPTH=PXPTH+X2*C/TEMP-PXPR2*EARTHE
50 IF (PERT.NE.D.l CALL ELECTl
RETURN
END

119

OCHAOOl
DCHAODZ
DCHA003
DCHAOD4
DCHAD05
DCHAD06
DCHA007
DCHAOD8
DCHAOD9
DCHAOIO
DCHADll
DCHA012
DCHADl3
DCHA014
DCHA015
DCHADl6
DCHAOl7
DCHA018
DCHA019
DCHADZO
DCHAOZI
DCHADZZ
DCHAOZ3
DCHAOZ4
DCHADZ5
DCHAOZ6
DCHAOZ7
DCHADZ8
DCHAD29
DCHA030
DCHA031
DCHA032
DCHA033-

INPUT PARAMETER FORM FOR SUBROUTINE LINEAR
An ionospheric electron density :model consisting of a linear layer
for h < h

N=O

-

N = A(h - h

for h> h

. )
rnm

.

mln

.
rnm

The ray will penetrate if h> h

max

.

Spec ify:
A = _ _ _ _ _ electrons/crn3 /

krn (WIOI)

hrnax= _ _ _ _ _ krn (WI02)
h

min

= _____ krn (WI03)

SUBROUTINE LINEAR
LINE AR ELECTRON DEN S ITY MODEL

C

CO MMON ICONST! PI .pr T2,P ID2,OEGS,RAD,K,DUM{21

CO MMON /XX/ MODX(ZI,X,PXPR,PXPTH,PXPPH,PXPT,HMAX
COMMON R(6)
EQU 1 VA LENCE

/WW/ I D(lO).,W(),WI4001
(EAR THR, W{ 2 I I , ( F, W(6 I J , (F ACT, w( 101 ) I , (HM, W( 102 I I ,

1 (Hr-t IN,WII 03)},(PERT,W(lSOI)
REAL K

DATA (MODX(11=6HLINEAR)
EN T~Y ELECT X
H=R(1) - EAR THR
HMAX=H~

X",PXPR =O.
IF

(H.LE.HMINI

GO TO 50

PXPR=K*FACT/F**2
50

X=PXPR*(H-HMIN)
IF (PERT.NE.D.I
RETURN
END

CALL ELECTI

120

L1NE ODI
LI NEOOZ
LI NE003
LI NED04
L1NE005
LINEOD6
LINE007
UNE ODa
LINE 009
LI NED 10
LINEDl!
LINEOIZ
L1NEOI3
L1NEOI4
LINE015
L1NEDI6
LINE017
L1NEOla
Ll NEOI9-

INPUT PARAMETER FORM FOR SUBROUTINE QPARAB
An ionospheric electron density model consisting of a parabolic or a
quasi-parabolic layer ( concentric)

,

f N

~

f

c

h-h

"

[1.

y

max . C

,
1

,. f f

N

> O.

m

fN

C

c

O.

otherwise.

1.

for a parabolic layer

R

+h

o

whE>re R

max
R +h
o

o

Y

m

for a quasi-paraboli c layer

is the radius of the ea rth .

Specify :

Critical f r equency .. fc = ______ Mc/s (W I Dl)
Height of maximum electron density , h

S e mi -thickness, Y

m

max

_ _ _ _ _ km. (WI02)

_ _ _ _---'km. (W I03)

Type of profile:
Plain parabolic _ _ _ _ _ _ _ (W I 04 = O.

Quasi-parabolic

C
C
C

(WI04 = 1.

SUBROUTINE QPARAB
PLAIN PARABOLIC OR QUASI-PARABOLIC PROFILE
W(lO~)
= O. FOR A PLAIN PARABOLIC PROFILE
1. FOR A QUASI-PARABOLIC PROFILE
COMMON IXX/ MOOX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
CO~MON R(6) /WIN/ IDIIO),WQ,W(4001
EQUIVALENCE

IEARTH R ,W(2)),(F,W(61),(FC,W1I Ol)) ,(HM,W(102)),

1 (Y ." 1,W(103)),CQUASI,\!,'(!04)J,CPERT,WI150))
DATA IMOJXIll=6HOPARABI
ENTRY ELECTX
HMAX=HM
PXPR=O.
H=RIII-EARTHR
FCF2=(FC/FI**2
CONST=!.
IF (QUASI.EQ.I.) CONST=(EARTHR+HM-YM)/R(I)
Z=CH-HM1/YM*CONST
X=MAXIFfO.,FCF2*(1.-Z*ZII
IF (X.EO.O.) GO TO 50
IF (QUASr.EO.I.) CONST=(EARTHR+HMI*IEARTHR+HM-YM )/ R(1)**2
PXPR=-2.*Z*FCF2/YM*CONST
50 IF (PERT.NE.O.) CALL ELEcT 1
RETURN
END

121

PARA OO l
PARA002
PARA003
PARA004
PARA005
PARA006
PARA001
PARAOOB
PARA009
PARAOIO
PARAOII
PARAO!2
PARA013
PARAO!4
PARAOI5
PARAOI6
PARAOI7
PARAOIB
PARAOI9
PARA020
PARA02I
PARA022
PARA023
PARA024-

INPUT PARAMETER FORM FOR SUBROUTINE BULGE
An analytic ionospheric electron density model which represents the
general latitude variation of the equatorial ionosphere (afternoon,
equinox, sunspot maximum) - see the center panel of figure 3.18b,
page 133 of Davies (1965) .
The model is an alpha Chapman layer with parameters which vary
with geomagnetic latitude.
1

e

z(l-z-e

_z

)

h - h
max
where z = --::-:..::::=:.:
H

fN is the plasma frequency
f

is the critical frequency
c
h
is the height of the maximum electron density
max
H is the scale height
h is height
f , h
, H vary with geomagnetic latitude in the following way:
c
max
if h<lOO krn, h
= 350 km, f = 15 Mc/s
max
c

-------=
For h;;, 100 km,
h

= 350 if A;;' 24

0

max
(180 )
= 430 + 80 cos 24 A if A < 24
max
A is the geomagnetic latitude in degrees
0

h

In all cases H is determined by the constraint that
f

N

= 2 Mc/s at 100 km.

122

C
C

C
C

C

C

C

SUBROUTINE BULGE
ANALYTICAL MODEL OF THE VARIATION OF THE EQUATORIAL F2 LAYER
IN GEOMAGNETIC LATITUDE
(EQUATORIAL BULGE AND ANOMALY)
SEE FIGURE 3.18B, PAGE 133 IN DAVIES 11965J.
THIS MODEL HA S NO VARIA TION IN GEOMAGNETIC LONGITUDE.
COMM ON I CQNSTI PI,PI T 2,PID2t DU ~(5)
COM MON I XX! ~ODX{2 J , X , cXPR tPXPTH.PXPPH,PXPT'HMAX

BULGOOI
BULG002
BULG003
BULG004
BULG005
BULG006
BULG007
(OW·ION RIb) tWWI I D tl O ),W Q ,W(4QQI
BULG008
EQU I V AL ENCE (EARTH R .W ( 2 1) ,(F.W(6J),(PERT,W(15 0 1J
BULG009
DATA (~ODX(lJ=6H 8 ULGFJ
BULGOIO
EN TR Y ELECTX
BULGOII
H=RIl)-EARTHR
BULGOI2
PHMPTH=PFC2PTH=Q.
BULGOI3
HMA X=35 0 .
BULGOI4
FC2;225.
BULGOI5
IFIH.LT.IOO') GO TO 2
BULGOI6
EQUA TOR I AL BULGE
BULGOI7
BULLAT=7.5*IPID2 - R(2))
BULGOI8
IFIABSIBUL LAT).GE.PI)
GO n 1
BULGOI9
HMAX=43Q.+SO.*CQSISULlATI
BULG020
PHMPTH=600.*SIN(BUL lAT)
BULG02I
EQUATORIAL ANOMALY
BULG022
ANMLAT;22.5*IPID2 - R(2))/PI
BULG023
POW=2.-ABSIANM LAT)
BULG024
FC2=50.*ANM LAT**2*EXP {
POW
) + 40.
BULG025
PF C2PTH=- 1125./PI*P QW*ANMLAT*EXPIPOWl
BULG026
FORCING PLASMA FREQ AT 1 00 KM TO BE 2 MHl IN ORDER
CALCULATE SH BULG027
2 ALPHA =2.·ALO;(FC2/~.).1.
BULG028
l100; -ALOG (ALPHA)
BULG029
DO 3 1=1,5
BULG030
3 l100; -ALD GI ALPHA-ZlOO)
BULG03I
SH=II00.-HMAX)/ZIOO
BULG032
Z=IH-HMAXI/SH
BULG033
EXZ=l.-EXPI -Zl
BULG034
X~FC2*EXP (.5* (EXZ-Z ) I/F**Z
BULG035
PXPR=-O.5*X*EXZ/SH
BULG036
PXPTH=-PXPR*(l.-lIZlOO)*PHMPTH+(I. -Z*E XZ/(ZlOO*(I.-EXP( -lI OO}}l)
BULG037
I
*X/FCZ*PFCZPTH
BULG038
IF IPERT.NE.O.) CALL ELECT I
BULG039
RETURN
BULG040
END
BULG041-

,0

123

INPUT PARAMETER FORM FOR SUBROUTINE EXPX
An exponential electron density profile

N =N

h

o

e

a(h-bo )

is the height above the ground .

Specify:
= _______,cm - 3 (WIDI)

the electron density at th e h eight h ,N

o

C

0

the reference h eight, ho = ______km

(WID2)

the exponential increase of N with height,

a = _ _ _ _---'km

SUBROUT INE EXPX
EXPONENTIAL ELECTRON DENSITY MODEL
COMMON teONSTI PI,PIT2,PID2,DEGS,RAD,K'DUM(21
COMMON IXX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT'~IMAX
(OMMON RIb!

/WWI

ID(l O ),WQ,W(400J

EQJ IVALENCE (EARTHR,W(2),IF,W(6 1 1,
1 q"O,W(lOlJ) '(HQ,WII IJ2) I '(A,WfI03) I,{PERT,WI 15 0))
REAL Nt NO 'K

DA TA (MODX(lJ=4HEXPX1,{HMAX=350 . )
EN TRY ELf'cTX
H=RIII-EARTHR
N =NO * EXP(A*fH-HOll
X=K*N/F**2
PXPR=A*X
IF (PERT.NE.O.l CALL ELECT 1
RETURN
END

124

-I

(WI0 3)

EXPXOOI
EXPXOOz
EXPX003
EXPX004
EXPXOOS
EXPX006
EXPX007
EXPX008
EXPX009
EXPXOI0
EXPXOll
EXPXOIZ
EXPX013
EXPXO 14
EXPX015
EXPX016
EXPXO 17-

APPENDIX 4. PERTURBATIONS TO ELECTRON DENSITY
MODELS WITH INPUT PARAMETER FORMS
The following perturbations to electron density models (irregularities) are available.

The input parameter forms, which describe the

perturbation, and the subroutine listings are given on the pages shown.
a.
b.

Do-nothing perturbation (ELECT1)
East - we st irregularity with an elliptical cro s ssection above the equator (TORUS)
c. Two east-west irregularities with elliptical
cross -s ections above the equator (DTORUS)
d . Increase in electron density at any latitude
(TROUGH)
e. Increase in electron density produced by a
shock wave (SHOCK)
f. "Gravity - wave" irregularity (WAVE)
g. "Gravity-wave" irregularity (WAVE2)
h. Height profile of time derivative of ele.ctron
density for calculating Doppler shift (DOPPLER)

126
127
129
131
132
134
136
138

To add other perturbations to electron density models the user must
write a subroutine to modify the normalized electron density (X) and its
gradient (aX I or, aX / a e, aX / aqJ) as a function of position in spherical
polar coordinates {r,

e, CIl.

The restrictions on electron density models also apply to perturbations.

Again, the coordinates r, e, qJ refer to the computational coordi-

nate system, which may not be the same as geographic coordinates.

In

particular, they are geomagnetic coordinates when the earth -centered
dipole model of the earth's magnetic field is used.
Th e input to the subroutine is through blank common (see Table 3 )
for the position (r,

e, cp ) and through common block / XX / (see Table 8 )

for the unperturbed electron density and its gradient.
through common block / XX /.

The output is

It is useful if the name of the subroutine

suggests the perturbation model to which it corresponds.

It should have

an entry point ELECTI so that it may be called by an electron density
subroutine.

Any parameters needed by the subroutine should be input

into WI 51 through W 199 of the W array.
125

(See Table 2. )

If no perturbation is wanted, the following subroutine should be used.

C

SUBROUTINE ELE CTl
USE WHEN AN ELE CTRON DENSITY PERTURBAT I ON IS NOT WANTED
(OMMON /XXI MODX(2),X(6)
COMMON /WW/ IDIIO),WQ,W(4QO)
EQUIVALENCE
DATA

(PERT,WC1501 I

(~O~X(21=6H

NONE)

PERT=O.
RETURN
END

126

ELEC OOl
ELEC002
ELEC003
ELEC004
ELEC005
ELEC006
ELEC007
ELECOOB
ELEC009 -

INPUT PARAMETER FORM FOR SUBROUTINE TORUS
A perturbation to an ionospheric electron density model consisting of
an East-West irregularity with an elliptical cross section above the
equator

N = No (1 + ll)

ll= Co exp { - [

(Ro + Ho){ 8 - n /2) cos S + (R - Ro - Ho) sin B ] 2
A

_ [ (R - Ro - Ha) cos SB- (Ro +Ho}{8-n/2) sin S

Ro is the radius of the earth.
R, 8, cp give the position in spherical polar coordinates.
No (R, 8, cp) is any ionospheric electron density model.
Specify:
Co = _ _ _ _ • (W15I)
Semi-major axis of ellipse, A = ______km (W152)
Semi-minor axis of ellipse, B =

km (WI 53)

Tilt of ellipse, S = _ _ _ _ _ degrees
Height of torus from ground, Ho =

(W154)

- - - - km (W155)

(W150: = 1. to use perturbation, -= O. to ignore perturbation)

127

T}

SUBROUTINE TORUS
COMMON ICONST/ PI,PrT2,PJD2,DUM(51
(OMMON IXXI MODX(2),X,P XPR ,PXPTH,PXPPH,PXPT,HMAX

TOR 001
TOR 002
TOR 003
(OHMQN R(61 /WW/ IDflO),WO,W(4QQI
TOR 004
Eau ! VA LENC E (EAR THR ,W ( 2 I ) , ( C () ,w ( 151 I I , ( A' W( 152 I ) , ( B' W( 153 I I ,
TOR 005
1 (BETA,ItJ( ~C:;4J 1,(HQ.W(15S1 )
TOR 006
REA L LA~\RDA
TOR 007
DATA (P DPP =O.J,(~ODX(21=6H TORUS)
TOR 008
EN TRY ELECTI
TOR 009
IF (X.Eo.O •• AND.PXPR.EQ.O •• AND.PXPTH.EQ.O •• AND.PXPPH.EQ.O.) RETURNTOR 010
IF (C o . EO ,O.1 RETURN
TOR 011
RO =EARTHR+HO
TOR 012
Z;R(IJ-RO
TOR 013
LAMBDA=R O*tR( 2)-PJD2)
TOR 014
SINBET ; S IN(eETAJ
TOR 015
(OSBET;(OS(BETAJ
TOR 016
P=LAMBDA*CQSBET+Z*SINBET
TOR 017
Y=Z*COSBET-LAMBDA*SINBET
TOR 018
DEL TA=CO* EXP{ -fP/A1**2-(Y/SJ·*ZI
TOR 019
DELl;DELTA+I .
TOR 020
PDPR=-2.*OElTA*IP*SINBET/A**z+v*caSBET/S**21
TOR 021
POPT=-2.*OELTA*fP*RO*COSBET/A**2-Y*RO*SINBET/S**21
TOR 022
PXPR =PXPR*OELl+X*PDPR
TOR 023
PXPTH=PXPTH*OELl+X*PDPT
TOR 024
PXPPH =PXPPH*DEL1+X*PDPP
TOR 025
X=X*DELl
TOR 026
RETURN
TOR 027
END
TOR 028-

128

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

130

INPUT PARAMETER FORM FOR SUBROUTINE TROUGH
A perturbation to an ionospheric electron density model consisting of an

increas e in electron density n ear any latitude
W = B for ~ - 6 - A ;, 0

N = ( I + 6 ) No (R. 6 . cp )

Z

,rr /Z- 6 - A , 2 ,.

6 = A exp ( - \.

No (R,
R,

W

)

rr

W = B X C for "2 - 6 - A < 0

)

e. cp ) is a ny ionosph e ri c electron density mode l.

e, cp give the position in spherical polar coordinates.

Specify:

Amplitude of the perturbation , A ;;; _ _ _ __
half width of the pertur bation , B ;:: _ _ _ __
latitude of the perturbation, A ;;; _ _ _ __

(WI 51)
deg rees (WI5Z)

degr ees (WI 53)

w idth facto r for South of t rough, C ;;; _ _ _ __

(WI 54)

(WI 50: ;;; 1. to use perturbation, ;;; O. to ignore pe rturba t ion)

C

SUBROU TINE TR OUGH
A PERTURBATI ON TO AN ELECTRON DENSITY MODEL
COMMON ICONS T I PI,PIT2, P ID2,DUM(SI

T~OUOOI

TROU002
TROU003

COM MON lX X/ MODX(21,X,PXPR ,PXPTH,PXPPH,PXPT,HMA X

TROU004

COM MON R(61 /WWI ID{lOJ,WQ,W{40Q)

T~ OU00 5

EQU IVALENCE (A,WI151)),IE,WII5211,IALATt'wI1531),IFACTOR,WI1541)
THOU006
DA TA (MODX IZ)=6HTR OUG HI
TRO U007
ENTRY ELECTl
TROU008
IF IX . EQ.O •• AND.PXPR.EO.O •• AND . PXPTH . EO. O•• ANO.PXP~H.EQ.O.1 RET URNTROU009
IF IA.EO.a . 1 RETURN
TROUOIO
ANG LE=RI2J+ALAT - PID2
TROUOll
WIOTH=B
TROUalZ
IF IANGLE .GT.O.J
WIDTH=FACTOR*B
TROU 0 13
ANG LE=ANGLE/WIDTH
TRO U0 14
OELTA=A*EXP I-ANGLE**Z)
TROU015
DEL1= DEL TA+l.
TROU016
PXPR =PXPR*DELI
TROU017
PXPTH=PXP TH *OELI - Z.*X*ANGLE*OELTA/WIDTH
TROUOlS
PXPP H=PXPPH*OELI
TROUOI9
X=X*DEL I
TROU020
RETURN
TROU021
END
TROU022 -

1 31

INPUT PARAMETER FORM FOR SUBROUTINE SHOCK
A perturbation to an ionospheric electron density model consisting of
an increase in electron density produced by a shock wave
N(R, 8, cp ) = No(R, 8, cp )[l + P exp(- 9(Pc; P:)]

Pc = s (h - h o ) - w
P = R[cos- 1 [cos(cp - CPo ) cos (A - 1,.0)] [

No (R, 8, cp ) is the ambient electron density specified by any electron
dens·ity model.
R, 8, cp give the position in spherical polar coordinates.
h = R - a is the height above the surface of the earth.
a is the radius of the earth.
TT

A = 2" - e is the latitude.
Specify:
Relative increase in electron density, P = _____ (WI 51).
Width of the disturbance, w =

- - - - km (WI 52) •

Latitude of the center of the disturbance, 1,.0 =
radians or degrees
(WI53).
--Longitude of the center of the disturbance, CPo =
radians or
degrees (W154).
---Slope measured from vertical - rate of increase of Pc with height,
s =
(W155).
Height to the bottom of the disturbance, ho = ____ km (WI 56).
(W150: = 1. to use perturbation, = O. to ignore perturbation)

132

C

SUBROUTINE SHOCK
SHOCOOl
A PERTURBATION TO AN ELECTRON DENSITY MODEL SIMULATING A SHOCK WAVE SHOC002
COMMON ICONST/ PI,PIT2,PI02,QUM(5 1
5HO(003
COMMON IXX/ MODX(2I,X,PXPR,PXPTH,PXPPH,PXPT,liMAX
SHOC004
(OHMQN R(61 /'NW/ IO(lOI,WQ,W(40QI
EOUIVALENCE {EAR TH R ,W (21 J , (P,W( 1511) ,(WW,W( 152»
1 (ALON,W(1541),(S,\;I(155 1 )dHQ,\-J1l561 J
RE:AL LAT ,LON

,(ALAT,W(153 1),

SHOC005
SHOC006
5HOC007
SHOC008

DATA (~ODX(2) =~H SHOCK)
SHOCQ09
ENTRY ELECTl
SHOCOlO
IF (X.EQ.O •• AND.PXPR.EQ.O •• AND.PXPTH.EQ.O •• ANO.PXPPH.EQ.O.) RETURNSHOCOll
IF (P.EQ. Q•• OR.WW.E O.O.1
RETURN
SHOC012
H=RIll -EA RTHR
SHOCOl3
QHQC=5*(H-H01-WW
5HOC014
LON=RI3 - ALON
SHOCOl5
'
LAT=PID2-RI21-ALAT
SHOCOl6
COSLON=COSILONI
SHOCOl7
COSLAT=COSILATI
SHOC018
U=CaSLON*CQSLAT
5HOC019
RHO=RIll*ACOSIUI
SHOC020
DIF=RHOC - RHO
SHOC021
CON =-9 ./WIA'** 2

SHOC022

CONS=P*EXP(CON*DIF**21

SHOC023

CONST=l.+CONS

SHOC024

CON=Z.*CON*CONS*OIF
PXPR=PXPR*CONST+X*CON*IS-RHO/R(l»)
CONS=R(1)*ll./SQRTll.-U**2)
PXPTH=PXPTH*CONST+X*CON*CONS*COSLON*SINILAT)
PXPPH=PXPPH*CONST-X*CON*CONS*COSLAT*SrNILON)
X=X*CONS T
RETURN
EN D

SHOc025
SHOC026
SHOC027
SHOC028
SHOC029
SHOC030
SHOC031
SHOC032-

133

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

135

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

