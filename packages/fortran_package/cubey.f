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
