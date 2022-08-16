$ONTEXT;
Global Timber Model - baseline
Code originally written by B. Sohngen, sohngen.1@osu.edu

This code used for baseline in 
Austin, K.G., Baker, J.S., Sohngen, B.L., Wade, C.M., Daigneault, A., Ohrel, S.B., Ragnauth, S. and Bean, A., 2020. The economic costs of planting, preserving, and managing the world’s forests to mitigate climate change. Nature communications, 11(1), pp.1-9.

Which was updated from version published in 
Tian, X, B Sohngen, J Baker, S Ohrel, and A Fawcett. 2018. Will US Forests Continue to Be a Carbon Sink?  Land Economics. 94(1): 97-113.

$OFFTEXT;

*Initialize some sets
SETS T            time periods  / 1 * 20/
     A1          age classes of trees  /1 * 15/
     CTRY      regions  /1*16/
     LC1          forest land classes        /1*85/
     AA                        /1*15/
     T1                        /1 * 30/
     TT        set to help with yield  /1*10/
     TS set for soil carbon calculations /1*15/
     DATA number of data parameters /1 * 50/
     YEAR(T)
     YEAR2(T1)
     RSET1(LC1)     accessible regions
     RLAST1(LC1)
     TFIRST(T)    first period
     TLAST(T)     last period
     AFIRST1(A1)  first age
     ALAST1(A1)   last age
     AALAST(AA)
     FINT(T)
;


FINT(T) =YES$(ORD(T) EQ CARD(T));
YEAR(T) = YES$(ORD(T) LT CARD(T));


YEAR2(T1) = YES$(ORD(T1) LT (CARD(T) +1));
TFIRST(T)   = YES$(ORD(T) EQ 1);
TLAST(T)    = YES$(ORD(T) EQ CARD(T));
AFIRST1(A1)  = YES$(ORD(A1) EQ 1) ;
ALAST1(A1)   = YES$(ORD(A1) EQ CARD(A1)) ;
AALAST(AA) = YES$(ORD(AA) EQ CARD(AA));

$ONTEXT;
PARAM2 - PARAMETERS FOR FORESTRY MODEL
data    1       m yield function parameter
data    2       n yield function parameter
data    3       c not used
data    4       max proportion logs per ha harvested
data    5       not used
data    6       not used
data    7       not used
data    8       initial forest stocking density
data    9       elasticity of management intensity
data    10      harvesting cost and transport to mill $/m3
data    11      Faustmann SS rotation age calculated externally
data    12      temperate inaccessible harvesting cost parameter constant "a"
data    13      temperate inaccessible harvesting cost parameter elasticity "b"
data    14      tropical inaccessible harvesting cost parameter constant "a"
data    15      tropical inaccessible harvesting cost parameter elasticity "b"
data    16      rent parameter a constant
data    17      rent parameter b elasticity
data    18      rent parameter Z
data    19      trop initial hectares
data    20      not used
***********************************************************
$OFFTEXT;

TABLE PARAM2(CTRY,LC1,DATA)
$ondelim
$include param2n_042120.csv
$offdelim
;

$ONTEXT;
PARAM3 - PARAMETERS FOR FORESTRY MODEL
data    1       fast growing plantation type/yield growth 1=yes
data    2       rental function shift parameter a
data    3       rental function shift parameter b
data    4       timber type quality adjustment factor
data    5       accessible forest type =1
data    6       temperate inaccessible forest type = 1
data    7       tropical inaccessible forest type = 1
data    8       tropical replanted low management intensity type =1
data    9       decadal increase in yield (% per decade) applies only to highly managed plantations
data    10      not used
data    11      not used
data    12      not used
data    13      not used
data    14      initial estimate of timber harvest used for pulp
data    15      not used
data    16     dedicated biomass (1,0)
data    17     dedicated biomass establishment costs
data    18     dedicated biomass transportation distance
data    19     dedicated biomass $/m3/mile
data    20     dedicated biomass pulp substitution quality adjustment factor
$OFFTEXT;


TABLE PARAM3(CTRY,LC1,DATA)
$ondelim
$include param3_042420.csv
$offdelim
;

*harvesting cost parameters
TABLE PARAM4(CTRY,LC1,DATA)
$ondelim
$include param4_042220.csv
$offdelim
;

PARAM2('3','6',DATA) = 0;
PARAM3('3','6',DATA) = 0;
PARAM4('3','6',DATA) = 0;


*define for later use
PARAMETER CSA(CTRY,LC1,DATA);
CSA(CTRY,LC1,DATA) = PARAM4(CTRY,LC1,DATA);

*CPARAM
*carbon estimation parameters
*some different parameters, including yield and cost data
*1 = growth parameter 1
*2 = growth parameter 2
*3 = Carbon conversion factor for standing stock (Mg C / m3)
*4=Carbon conversion factor for harvested timber (Mg C/m3)
*5=Steady state carbon storage in soils
*6=Initial soil C (Mg ha-1)
*7=Soil C Growth Rate
*8=Discounted Soil C Addition for new land (Mg ha-1)
*9 = slash decomposition
*10= proportion solidwood
*11= parameter F from Smith et al
*12= parameter G from Smith
*13= parameter H from Smith
*14= D for IPCC GPG
*15= BEF for IPCC GPG
*16= R for IPCC GPG
*17=C % for IPCC GPG
*18=Net IPCC GPG Equation
*19=init emission
*20=pulp turnover
*21 =sawtimber turnover

TABLE CPARAM2(CTRY,LC1,DATA)
$ondelim
$include cparam_p6_042220.csv
$offdelim
;

*******************************************************************************
*sets the number of regions considered in this run - max is lt 17
*******************************************************************************
PARAMETER CTRYIN(CTRY,LC1);
CTRYIN(CTRY,LC1) =1$(ORD(CTRY) LT 17);

DISPLAY CTRYIN;

* Dedicated biofuel plantations in the US
PARAMETER DEDBIO(CTRY,LC1);
DEDBIO(CTRY,LC1) = 1$(PARAM3(CTRY,LC1,'16') EQ 1);

*1 if accessible region
PARAMETER R1FOR(CTRY,LC1);
R1FOR(CTRY,LC1) = 1$(PARAM3(CTRY,LC1,'5') EQ 1);
R1FOR(CTRY,LC1)= R1FOR(CTRY,LC1)*CTRYIN(CTRY,LC1);

*1 if temperate inaccessible region
PARAMETER TEMPINAC(CTRY,LC1);
TEMPINAC(CTRY,LC1) = 1$(PARAM3(CTRY,LC1,'6') EQ 1);
TEMPINAC(CTRY,LC1)= TEMPINAC(CTRY,LC1)*CTRYIN(CTRY,LC1);


*1 if tropical inaccessible region
PARAMETER TROPINAC(CTRY,LC1);
TROPINAC(CTRY,LC1) = 1$(PARAM3(CTRY,LC1,'7') EQ 1);
TROPINAC(CTRY,LC1)= TROPINAC(CTRY,LC1)*CTRYIN(CTRY,LC1);


*1 if tropical low quality revegetated region
PARAMETER TROPLOW(CTRY,LC1);
TROPLOW(CTRY,LC1) = 1$(PARAM3(CTRY,LC1,'8') EQ 1);
TROPLOW(CTRY,LC1)= TROPLOW(CTRY,LC1)*CTRYIN(CTRY,LC1);

PARAMETER TROPALL(CTRY,LC1);
TROPALL(CTRY,LC1) = TROPINAC(CTRY,LC1)+TROPLOW(CTRY,LC1);

*this is for parameters
PARAMETER ALLIN(CTRY,LC1);
ALLIN(CTRY,LC1) = R1FOR(CTRY,LC1) + TEMPINAC(CTRY,LC1)+ TROPINAC(CTRY,LC1)+DEDBIO(CTRY,LC1);

*this is for harvest equation, cannot include biomass stuff
PARAMETER ALLIN2(CTRY,LC1);
ALLIN2(CTRY,LC1) = R1FOR(CTRY,LC1) + TEMPINAC(CTRY,LC1)+ TROPINAC(CTRY,LC1);


DISPLAY R1FOR,TEMPINAC,TROPINAC, ALLIN;

*climate change parameters set to 0 in this scenario
PARAMETER CHG1(CTRY,LC1,T,DATA);
CHG1(CTRY,LC1,T,DATA)=0;

*Accessible forest initial inventory
TABLE FORINV2(CTRY,LC1,A1)
$ondelim
$include forinv2_p6_2020.csv
$offdelim
;

*inaceessible forest initial inventory
TABLE IFORIN2(CTRY,LC1,A1)
$ondelim
$include iforin2_p6_2020.csv
$offdelim
;

*inaccessible forest types
PARAMETER INACI2(CTRY,LC1,A1);
INACI2(CTRY,LC1,A1) = IFORIN2(CTRY,LC1,A1);

*calculate average age of timber in inaccessible forest types
PARAMETER AVAGEINAC1(CTRY,LC1,A1);
LOOP(A1,AVAGEINAC1(CTRY,LC1,A1) = IFORIN2(CTRY,LC1,A1)*ORD(A1));

DISPLAY AVAGEINAC1;
PARAMETER AVAGEINAC(CTRY,LC1);

PARAMETER SUMIFORIN2(CTRY,LC1);
SUMIFORIN2(CTRY,LC1) =SUM(A1,IFORIN2(CTRY,LC1,A1));

DISPLAY SUMIFORIN2;


AVAGEINAC(CTRY,LC1)$(TEMPINAC(CTRY,LC1) EQ 1) =
        SUM(A1,AVAGEINAC1(CTRY,LC1,A1))/SUM(A1,IFORIN2(CTRY,LC1,A1));

AVAGEINAC(CTRY,LC1) = ROUND(AVAGEINAC(CTRY,LC1))

DISPLAY AVAGEINAC;

*maximum forest area by continent, derived from MC1/2 baseline model
PARAMETER FORLIMIT(CTRY)
/	1	495.5	,
	2	573.2	,
	3	634.5	,
	4	603.3	,
	5	1056.1	,
	6	432.4	,
	7	170.2	,
	8	89.0	,
	9	115	,
	10	440.6	,
	11	593.2	,
	12	438.0	,
	13	210.0	,
	14	33.0	,
	15	70.4	,
	16	22.9	/;


SCALARS
EPSILON small value for making derivatives work /1.0E-6/
CONSTFO demand function constant for integration /100/;

*discounting
SCALAR R /.05/;
PARAMETER  RHO(T)  discount factor ;
RHO(T) = (1/(1+R)**(((ORD(T)-1)*10)));

*Decadal discount factor
PARAMETER RHOYR(TT);
RHOYR(TT) = (1/(1+R)**(((ORD(TT)-1))));

PARAMETER DDISC;
DDISC = SUM(TT,RHOYR(TT));

$ONTEXT;
*******************************************************************************
DEMAND
Constant elasticity demand function
Q = A*[(Y/N)^h]*[P^e]
P = (Q/(A*[(Y/N)^h]))^(1/e)
IntQ = {(1/((1/e)+1))/(A*[(Y/N)^h])^(1/e))}*(Q)^((1/e)+1)

Y/N = GDP per capita
h = income elasticity = varies over time
e = price elasticity = -1.05
*******************************************************************************
$OFFTEXT;

PARAMETER POPGR(T)

/1	0.009178869	,
2	0.007122997	,
3	0.005144479	,
4	0.003240344	,
5	0.001489032	,
6	4.33998E-05	,
7	0	,
8	0	,
9	0	,
10	0	,
11	0	,
12	0	,
13	0	,
14	0	,
15	0	,
16	0	,
17	0	,
18	0	,
19	0	,
20	0	/;

PARAMETER GDPGR(T)
/1	0.055488205	,
2	0.030968395	,
3	0.016704423	,
4	0.010162539	,
5	0.007691498	,
6	0.006364073	,
7	0.004996875	,
8	0.004218621	,
9	0.003735014	,
10	0.0035	,
11	0.003245938	,
12	0.002746563	,
13	0.002247188	,
14	0.001747813	,
15	0.001248438	,
16	0.000749063	,
17	0.000249688	,
18	0	,
19	0	,
20	0	/;

*GDPPC is consumption per capita in $/person

PARAMETER GDPPC(T);
GDPPC('1') =6158;
LOOP[T,GDPPC(T+1) = GDPPC(T)*(1+GDPGR(T))**10];

PARAMETER POPGR2(T);
POPGR2('1') = 1;
LOOP[T,POPGR2(T+1) = POPGR2(T)*(1+POPGR(T))**10];

*income elasticity
PARAMETER FINCELAS(T);
FINCELAS('1')=0.85;
LOOP(T,FINCELAS(T+1)=FINCELAS(T)*EXP(0.0001*10));
DISPLAY FINCELAS;


SCALARS
BF demand elasticity /1.1/;

*technical change parameter in timber processing sector
PARAMETER FORTCHG(T);
FORTCHG('1') = 1;
LOOP(T,FORTCHG(T+1) = FORTCHG(T)*(1+.015*EXP(-.013*ORD(T)*10))**(-10));

* US ONLY: USADJUST /0.15/;
*adjust for full market model = 0.5

SCALAR USADJUST adjustment for world demand /0.5/;

USADJUST =0.5;

PARAMETER AF(T);
AF(T) = USADJUST*POPGR2(T)*2300*FORTCHG(T)*(GDPPC(T)**FINCELAS(T));


PARAMETER AFP(T);
AFP(T) = AF(T)*.20;

PARAMETER AFS(T);
AFS(T) = AF(T) - AFP(T);

SCALAR PULPADJUST /1.0/
*0.4 if not using cost functions

DISPLAY GDPPC, FINCELAS,FORTCHG;

DISPLAY AF, AFP;

*****************************************************************
*Parameters for residue harvesting cost function
* cost = ca + cb*RESQ+ cc*(RESQ^2)
* RESQ = residue quantity
*****************************************************************
* original ca=0; cb=30; cc=0.05;
scalars
         ca /0/
         cb /30/
         cc /.05/
;
*****************************************************************

$ONTEXT;
This section calculates shifts in the rental functions to account for exogenous changes in demand for alternative uses of land
$OFFTEXT;

PARAMETER RNTSHFT(CTRY,LC1,T);
RNTSHFT(CTRY,LC1,'1') = 1;
LOOP[T, RNTSHFT(CTRY,LC1,T+1)=
        {RNTSHFT(CTRY,LC1,T)*(1+PARAM3(CTRY,LC1,'2')*
                ((1-PARAM3(CTRY,LC1,'3'))**{ORD(T)-1}))}$(PARAM3(CTRY,LC1,'2') NE 0)+

        RNTSHFT(CTRY,LC1,T)$(PARAM3(CTRY,LC1,'2') EQ 0)];

DISPLAY RNTSHFT;

PARAMETER RENTA(CTRY,LC1,T);
RENTA(CTRY,LC1,T) =
        PARAM2(CTRY,LC1,'16')*RNTSHFT(CTRY,LC1,T)$(R1FOR(CTRY,LC1) EQ 1)+

        PARAM2(CTRY,LC1,'16')*RNTSHFT(CTRY,LC1,T)$(DEDBIO(CTRY,LC1) EQ 1)+

        PARAM2(CTRY,LC1,'16')*RNTSHFT(CTRY,LC1,T)$(TROPINAC(CTRY,LC1) EQ 1);

PARAMETER RENTB(CTRY,LC1);
RENTB(CTRY,LC1)=PARAM2(CTRY,LC1,'17');

SCALAR GRENTB /0.3/;
GRENTB = RENTB('1','1');

PARAMETER RENTAF(CTRY,LC1);
RENTAF(CTRY,LC1) = SUM[T$(FINT(T)),RENTA(CTRY,LC1,T)$(FINT(T))];

PARAMETER RENTZ(CTRY,LC1,T);
RENTZ(CTRY,LC1,T) = PARAM2(CTRY,LC1,'18')*(1/RNTSHFT(CTRY,LC1,T));

PARAMETER RENTHA(CTRY,LC1,T);
RENTHA(CTRY,LC1,T) =
{[RENTZ(CTRY,LC1,T)/RENTA(CTRY,LC1,T)]**RENTB(CTRY,LC1)}$(TROPINAC(CTRY,LC1) EQ 1);

DISPLAY RENTA,RENTZ,RENTHA;


$ONTEXT;
FINPTEL adjusts parameter that affects the elasticity of management inputs in forestry to account for technology change.  Currently assume 0.3% per decade growth in elasticity
$OFFTEXT;

PARAMETER FINPTEL(CTRY,LC1,T);
FINPTEL(CTRY,LC1,'1')$(R1FOR(CTRY,LC1) EQ 1)=
        PARAM2(CTRY,LC1,'9');
LOOP[T,FINPTEL(CTRY,LC1,T+1)$(R1FOR(CTRY,LC1) EQ 1)=
                FINPTEL(CTRY,LC1,T)*(1.003)];

FINPTEL(CTRY,LC1,'1')$(DEDBIO(CTRY,LC1) EQ 1)=
        PARAM2(CTRY,LC1,'9');
LOOP[T,FINPTEL(CTRY,LC1,T+1)$(DEDBIO(CTRY,LC1) EQ 1)=
                FINPTEL(CTRY,LC1,T)*(1.003)];

DISPLAY FINPTEL;

PARAMETER FINPTELF(CTRY,LC1);
FINPTELF(CTRY,LC1) = SUM[T$(FINT(T)),FINPTEL(CTRY,LC1,T)$(FINT(T))];

DISPLAY FINPTELF;


*Generate forest yield functions
* GINIT = decadal forest growth
* note that these include adjustments to forest growth to account for climate change through CHG1, but 
* those parameters are set to 0 in the baseline.
PARAMETER GINIT1(CTRY,LC1,A1,T);
GINIT1(CTRY,LC1,A1,T)$(ALLIN(CTRY,LC1) EQ 1) = 0$(ORD(A1) LT PARAM2(CTRY,LC1,'3')) +
                0$(ORD(A1) EQ PARAM2(CTRY,LC1,'3')) +

                SUM(TT,(1+CHG1(CTRY,LC1,T,'1'))*

                ((PARAM2(CTRY,LC1,'2')/(((ORD(A1)-PARAM2(CTRY,LC1,'3')-1)*10+ORD(TT)-.5)**2))*
                EXP(PARAM2(CTRY,LC1,'1')-PARAM2(CTRY,LC1,'2')/((ORD(A1) -
                                PARAM2(CTRY,LC1,'3')-1)*10 +
                ORD(TT)-.5))))$(ORD(A1) GT PARAM2(CTRY,LC1,'3'));

*Also decadal growth
PARAMETER GROWTH1(CTRY,LC1,A1,T);
GROWTH1(CTRY,LC1,A1,T)$(ALLIN(CTRY,LC1) EQ 1) = 0$(ORD(A1) LT PARAM2(CTRY,LC1,'3')) +
                0$(ORD(A1) EQ PARAM2(CTRY,LC1,'3')) +

                SUM(TT,(1+CHG1(CTRY,LC1,T,'1'))*
                ((PARAM2(CTRY,LC1,'2')/(((ORD(A1)-PARAM2(CTRY,LC1,'3')-1)*10+
                                ORD(TT)-.5)**2))*
                EXP(PARAM2(CTRY,LC1,'1')-PARAM2(CTRY,LC1,'2')/((ORD(A1) -
                                PARAM2(CTRY,LC1,'3')-1)*10 +
                ORD(TT)-.5))))$(ORD(A1) GT PARAM2(CTRY,LC1,'3'));

*initial age class growth in each time period
PARAMETER YINIT1(CTRY,LC1,A1,T);
YINIT1(CTRY,LC1,'1',T) = GINIT1(CTRY,LC1,'1',T);
LOOP(A1,YINIT1(CTRY,LC1,A1+1,T) = YINIT1(CTRY,LC1,A1,T) + GINIT1(CTRY,LC1,A1+1,T));

DISPLAY GINIT1,YINIT1;

*YIELD2 is growth function, summed over decadal growth
PARAMETER YIELD2(CTRY,LC1,A1,T) yield function;

YIELD2(CTRY,LC1,A1,T) = YINIT1(CTRY,LC1,A1,T)$TFIRST(T);
YIELD2(CTRY,LC1,A1,T)$AFIRST1(A1) = GROWTH1(CTRY,LC1,A1,T)$AFIRST1(A1);
LOOP(T,LOOP(A1,YIELD2(CTRY,LC1,A1+1,T+1)=YIELD2(CTRY,LC1,A1,T)+
        GROWTH1(CTRY,LC1,A1+1,T+1)));

*create YIELDORIG(CTRY,LC1,A1,T) which is used later for carbon calculations
* Use YIELD2 divided by quality adjustment parameter
PARAMETER YIELDORIG(CTRY,LC1,A1,T);
YIELDORIG(CTRY,LC1,A1,T) = YIELD2(CTRY,LC1,A1,T);

*Quality adjustment – accounts for value differences across logs from different regions.
YIELD2(CTRY,LC1,A1,T) = YIELD2(CTRY,LC1,A1,T)*PARAM3(CTRY,LC1,'4');


DISPLAY YIELD2;

*Add in underlying productivity changes in yields for productive species
*original method of shifting yields
*these are 6% per decade for many plantation types, and 3% per decade for others following
* estimates in Scholze et al. (2006)
PARAMETER YDGRTH(CTRY,LC1,T);
YDGRTH(CTRY,LC1,'1') = 1;

LOOP(T,YDGRTH(CTRY,LC1,T+1) = YDGRTH(CTRY,LC1,T) +
((PARAM3(CTRY,LC1,'9'))*YDGRTH(CTRY,LC1,T)*
       (.99**[(ORD(T)-1)*10]))$(PARAM3(CTRY,LC1,'1') EQ 1)+
(PARAM3(CTRY,LC1,'9'))*YDGRTH(CTRY,LC1,T)$(PARAM3(CTRY,LC1,'1') EQ 0)
);

PARAMETER YDGRTH2(CTRY,LC1,T);
YDGRTH2(CTRY,LC1,'1') = 1;

LOOP(T,YDGRTH2(CTRY,LC1,T+1) = YDGRTH2(CTRY,LC1,T) +
((PARAM3(CTRY,LC1,'9'))*YDGRTH2(CTRY,LC1,T)*(.99**[(ORD(T)-1)*10])));


YIELD2(CTRY,LC1,A1,T)= YIELD2(CTRY,LC1,A1,T)*YDGRTH(CTRY,LC1,T);
YIELDORIG(CTRY,LC1,A1,T) = YIELDORIG(CTRY,LC1,A1,T)*YDGRTH(CTRY,LC1,T);

DISPLAY YDGRTH, YIELD2;


*Technology change adjustment for merchantable timber out of biomass stock
*Not included in this version; assumed to be 0
PARAMETER TSWCHG(CTRY,LC1);
TSWCHG(CTRY,LC1) = 0;

PARAMETER MXSWTM(CTRY,LC1,T);
MXSWTM(CTRY,LC1,'1')$(ALLIN(CTRY,LC1) EQ 1)=
        PARAM2(CTRY,LC1,'4')$(ALLIN(CTRY,LC1) EQ 1);
LOOP[T,MXSWTM(CTRY,LC1,T+1) $(ALLIN(CTRY,LC1) EQ 1) =
        MXSWTM(CTRY,LC1,T)*(1+ TSWCHG(CTRY,LC1))];


$ONTEXT;
 The following routines adjust the yield function to account for the merchantable proportion of stock
 on each hectare.
The final result below takes the original yield function from above and multiplies by a factor that adjusts the biomass on site for the proportion that is merchantable, depending on the age class.

YIELD2 = YIELD2*SWPERC2A

$OFFTEXT;

PARAMETER SWGRTH(CTRY,LC1);
SWGRTH(CTRY,LC1) =2.0$(PARAM2(CTRY,LC1,'11') EQ 1)+
1.0$( PARAM2(CTRY,LC1,'11') EQ 2)+
0.9$( PARAM2(CTRY,LC1,'11') EQ 3)+
0.6$( PARAM2(CTRY,LC1,'11') EQ 4)+
0.5$( PARAM2(CTRY,LC1,'11') GT 4);


PARAMETER SWPERC2A(CTRY,LC1,A1,T);
SWPERC2A(CTRY,LC1,A1,T)$(ALLIN(CTRY,LC1) EQ 1)=

{MXSWTM(CTRY,LC1,T)*[1-EXP((-0.4/(PARAM2(CTRY,LC1,'11')*10-ORD(A1)*10+10))*
(ORD(A1)*10))]**2}$(ORD(A1) LT PARAM2(CTRY,LC1,'11'))+

{MXSWTM(CTRY,LC1,T)*[1-EXP((-SWGRTH(CTRY,LC1)/10)*
(ORD(A1)*10))]**2}$(ORD(A1) EQ PARAM2(CTRY,LC1,'11'))+

{MXSWTM(CTRY,LC1,T)*[1-EXP((-SWGRTH(CTRY,LC1)/10)*
(ORD(A1)*10))]**2}$(ORD(A1) GT PARAM2(CTRY,LC1,'11'));

*AGETR age to start counting sawtimber quantity
PARAMETER AGETR(CTRY,LC1);
AGETR(CTRY,LC1) = PARAM2(CTRY,LC1,'6');

*SWPC2A shifts SWPERC2A up by the number of decades in AGETR.
PARAMETER SWPC2A(CTRY,LC1,A1,T);
LOOP[A1,SWPC2A(CTRY,LC1,A1,T) = 0$(ORD(A1) LT AGETR(CTRY,LC1)) +
       0$(ORD(A1) EQ AGETR(CTRY,LC1))+
       SWPERC2A(CTRY,LC1,A1-AGETR(CTRY,LC1),T)$(ORD(A1) GT AGETR(CTRY,LC1))];

DISPLAY SWPC2A;

SWPERC2A(CTRY,LC1,A1,T)$(ALLIN(CTRY,LC1) EQ 1)=SWPC2A(CTRY,LC1,A1,T);

SWPERC2A(CTRY,LC1,A1,T)$(ALLIN(CTRY,LC1) EQ 1) = MIN[SWPERC2A(CTRY,LC1,A1,T),10];

YIELD2(CTRY,LC1,A1,T)$(ALLIN(CTRY,LC1) EQ 1)=YIELD2(CTRY,LC1,A1,T)*SWPERC2A(CTRY,LC1,A1,T);

DISPLAY SWPERC2A, YIELD2;

PARAMETER YIELD2F(CTRY,LC1,A1);
YIELD2F(CTRY,LC1,A1)=SUM[T$(FINT(T)),YIELD2(CTRY,LC1,A1,T)$(FINT(T))];

*create inaccessible yield functions – already adjusted for merch proportion
PARAMETER YLDINAC(CTRY,LC1,A1,T);
YLDINAC(CTRY,LC1,A1,T) = YIELD2(CTRY,LC1,A1,T);

execute_unload "GLOBALTIMBERMODEL2020.gdx"

*Estimate terminal values
SCALAR PTERM terminal potential timber price /130/;
SCALAR MANT max management $perha /10000/;

*a discount factor
PARAMETER DELTA1(CTRY,LC1);
DELTA1(CTRY,LC1) = 1/[(1-EXP(-R*PARAM2(CTRY,LC1,'11')*10))$(ALLIN(CTRY,LC1) EQ 1) +
                                1$(ALLIN(CTRY,LC1) EQ 0)];

*Estimate terminal management values
PARAMETER MNG1(CTRY,LC1);
MNG1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) =
SUM(A1,{[{[(1/(1+R))**(-PARAM2(CTRY,LC1,'11')*10)]*

(1/((PTERM - PARAM2(CTRY,LC1,'10')$(ALLIN(CTRY,LC1) EQ 1))*
PARAM2(CTRY,LC1,'8')$(ALLIN(CTRY,LC1) EQ 1)*FINPTELF(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1)*
        YIELD2F(CTRY,LC1,A1)$(ALLIN(CTRY,LC1) EQ 1)+EPSILON))}**(1/( FINPTELF(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1)-1))]
-1}$(ORD(A1) EQ PARAM2(CTRY,LC1,'11')));

MNG1(CTRY,LC1) = MAX[MNG1(CTRY,LC1),0];

PARAMETER MNG1A(CTRY,LC1);
MNG1A(CTRY,LC1)=MIN[MNG1(CTRY,LC1),MANT];

DISPLAY MNG1, MNG1A;


*alternate calculation of MNG1/A
PARAMETER ZIM1(CTRY,LC1);
ZIM1(CTRY,LC1)=0;
LOOP(CTRY,
LOOP[LC1$(ALLIN(CTRY,LC1) EQ 1),
WHILE(

SUM{A1,[(1+R)**(-10*ORD(A1))]*(PTERM - PARAM2(CTRY,LC1,'10'))*
        (PARAM2(CTRY,LC1,'8')*FINPTELF(CTRY,LC1)*
        (ZIM1(CTRY,LC1)+1+EPSILON)**(FINPTELF(CTRY,LC1)-1))*
        YIELD2F(CTRY,LC1,A1)$(ORD(A1) EQ PARAM2(CTRY,LC1,'11'))}


GT 1,

ZIM1(CTRY,LC1)= ZIM1(CTRY,LC1)+1);
]
)
;

PARAMETER MNG1A(CTRY,LC1);
MNG1A(CTRY,LC1)=MIN[ZIM1(CTRY,LC1),MANT];
MNG1(CTRY,LC1) = MNG1A(CTRY,LC1);

*determine rotation age and net present values

SETS
        AC1      age of trees for carbon calculation /1*15/;

PARAMETER NC1(CTRY,LC1,A1);
NC1(CTRY,LC1,A1)=0;
PARAMETER NPVCS1(CTRY,LC1,AC1);
NPVCS1(CTRY,LC1,AC1)=0;

PARAMETER NPVSS1(CTRY,LC1,A1);
NPVSS1(CTRY,LC1,A1) =
{(PTERM - PARAM2(CTRY,LC1,'10'))*
        {(PARAM2(CTRY,LC1,'8')*(MNG1A(CTRY,LC1)+1+EPSILON)** FINPTELF(CTRY,LC1))*
        YIELD2F(CTRY,LC1,A1)*((1+R)**(-ORD(A1)*10))}+
        SUM(AC1,NPVCS1(CTRY,LC1,AC1)$(ORD(AC1) EQ ORD(A1)))
        - MNG1A(CTRY,LC1)}/{1-((1+R)**(-ORD(A1)*10))};

DISPLAY NPVSS1;

PARAMETER NPVT1;

PARAMETER NPVT2

PARAMETER TMAGE1(CTRY,LC1);
TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) = 1;

LOOP(CTRY,
LOOP(LC1$(ALLIN(CTRY,LC1) EQ 1),
LOOP(A1, NPVT1=NPVSS1(CTRY,LC1,A1);
        NPVT2 = NPVSS1(CTRY,LC1,A1+1);


IF (NPVT1<NPVT2, TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) =TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1)+1;
        ELSEIF (NPVT1=NPVT2), TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) =TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1)+1;
        ELSE TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) = TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1));
        );
IF (NPVT1 <0, TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) = TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1)-1;
        ELSE TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) = TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) ;
        );
        );
      );

DISPLAY TMAGE1;
PARAM2(CTRY,LC1,'11')$(ALLIN(CTRY,LC1) EQ 1)=TMAGE1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1);


*Determine SS area of accessible forests
*calculate decadal rental value
PARAMETER PVADDA1(CTRY,LC1);
PVADDA1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) =
        SUM[A1,NPVSS1(CTRY,LC1,A1)$(ORD(A1) EQ PARAM2(CTRY,LC1,'11'))]-
        SUM[A1,NPVSS1(CTRY,LC1,A1)$(ORD(A1) EQ PARAM2(CTRY,LC1,'11'))]/(1+R);

PARAMETER TFINAC1(CTRY,LC1);
TFINAC1(CTRY,LC1)$(R1FOR(CTRY,LC1) EQ 1) =
        [PVADDA1(CTRY,LC1)/RENTAF(CTRY,LC1)]**RENTB(CTRY,LC1);

TFINAC1(CTRY,LC1)$(TROPINAC(CTRY,LC1) EQ 1) =
        [PVADDA1(CTRY,LC1)/RENTAF(CTRY,LC1)]**RENTB(CTRY,LC1);

DISPLAY PVADDA1,TFINAC1;

TFINAC1(CTRY,LC1)$(ALLIN(CTRY,LC1) EQ 1) = TFINAC1(CTRY,LC1)/PARAM2(CTRY,LC1,'11');

PARAMETER FINAC1(CTRY,LC1,A1);
FINAC1(CTRY,LC1,A1)$(ALLIN(CTRY,LC1) EQ 1) =
        TFINAC1(CTRY,LC1)$(ORD(A1) LT (PARAM2(CTRY,LC1,'11')+1));

LOOP(CTRY,
LOOP(LC1$(ALLIN(CTRY,LC1) EQ 1),
       IF((PARAM2(CTRY,LC1,'11')) = 15,
       LOOP[A1, FINAC1(CTRY,LC1,A1) = 0$(ORD(A1) LT (PARAM2(CTRY,LC1,'11')))+
       TFINAC1(CTRY,LC1)*PARAM2(CTRY,LC1,'11')$(ORD(A1) EQ (PARAM2(CTRY,LC1,'11')))];
        ELSE LOOP(A1,
       IF (ORD(A1)< (PARAM2(CTRY,LC1,'11')+1),
                FINAC1(CTRY,LC1,A1) = TFINAC1(CTRY,LC1);
                ELSE FINAC1(CTRY,LC1,A1) =0;
       ););
        );
);
);

TFINAC1(CTRY,LC1)=TFINAC1(CTRY,LC1)*PARAM2(CTRY,LC1,'11');

DISPLAY TFINAC1,FINAC1;

*Estimate Terminal Conditions
PARAMETER ALPHAK1(CTRY,LC1,A1);

ALPHAK1(CTRY,LC1,A1) = (PTERM - PARAM2(CTRY,LC1,'10'))*
        (PARAM2(CTRY,LC1,'8')*(MNG1(CTRY,LC1)+1+EPSILON)**FINPTELF(CTRY,LC1))*
        YIELD2F(CTRY,LC1,A1)-MNG1A(CTRY,LC1);

PARAMETER ALPHA1(CTRY,LC1);
ALPHA1(CTRY,LC1)=SUM(A1,ALPHAK1(CTRY,LC1,A1)$(ORD(A1) EQ PARAM2(CTRY,LC1,'11')));

DISPLAY ALPHAK1,ALPHA1;

PARAMETER ALPHAK1(CTRY,LC1,A1);
ALPHAK1(CTRY,LC1,A1) = (PTERM - PARAM2(CTRY,LC1,'10'))*
        (PARAM2(CTRY,LC1,'8')*(MNG1(CTRY,LC1)+1+EPSILON)**FINPTELF(CTRY,LC1))*
        YIELD2F(CTRY,LC1,A1)-MNG1A(CTRY,LC1);


PARAMETER BETA1(CTRY,LC1);
BETA1(CTRY,LC1) = SUM(A1, [(PTERM - PARAM2(CTRY,LC1,'10'))*
        (PARAM2(CTRY,LC1,'8')*FINPTELF(CTRY,LC1)*
       (MNG1(CTRY,LC1)+1+EPSILON)**(FINPTELF(CTRY,LC1)-1))*
        YIELD2F(CTRY,LC1,A1)]$(ORD(A1) EQ PARAM2(CTRY,LC1,'11')));
DISPLAY BETA1;

BETA1(CTRY,LC1) =0;
LOOP{A1,

BETA1(CTRY,LC1) = BETA1(CTRY,LC1)+
        [(PTERM - PARAM2(CTRY,LC1,'10'))*
        (PARAM2(CTRY,LC1,'8')*FINPTELF(CTRY,LC1)*
       (MNG1(CTRY,LC1)+1+EPSILON)**(FINPTELF(CTRY,LC1)-1))*
        YIELD2F(CTRY,LC1,A1)]$(ORD(A1) EQ PARAM2(CTRY,LC1,'11'))
};


DISPLAY MNG1,BETA1;

*LAMBDA1 is actual terminal condition in $/ha for each age class
PARAMETER LAMBDA1(CTRY,LC1,A1);
LAMBDA1(CTRY,LC1,A1)$(ALLIN(CTRY,LC1) EQ 1) = {[(1/(1+R))**([PARAM2(CTRY,LC1,'11') - ORD(A1)]*10)]*
        DELTA1(CTRY,LC1)*ALPHA1(CTRY,LC1)}$(ORD(A1) LT (PARAM2(CTRY,LC1,'11')+1)) +
       {(DELTA1(CTRY,LC1)-1)*ALPHA1(CTRY,LC1) + ALPHAK1(CTRY,LC1,A1)}$(ORD(A1) GT PARAM2(CTRY,LC1,'11'));

LAMBDA1(CTRY,LC1,A1)$(ALLIN(CTRY,LC1) EQ 1)=
LAMBDA1(CTRY,LC1,A1)$(ORD(A1) LT PARAM2(CTRY,LC1,'11')+1)+
0$(ORD(A1) GT PARAM2(CTRY,LC1,'11'));

*PSI1 is actual terminal condition for $ spent on management
PARAMETER PSI1(CTRY,LC1,A1);
PSI1(CTRY,LC1,A1)$(ALLIN(CTRY,LC1) EQ 1) =
        {[(1/(1+R))**([PARAM2(CTRY,LC1,'11')-ORD(A1)]*10)]*BETA1(CTRY,LC1)}$(ORD(A1)
       LT (PARAM2(CTRY,LC1,'11')+1)) + 0$(ORD(A1) GT PARAM2(CTRY,LC1,'11'));


DISPLAY LAMBDA1,PSI1;

*adjust initial forest management
PARAMETER MTFIN1(CTRY,LC1,A1);
MTFIN1(CTRY,LC1,A1) = MNG1(CTRY,LC1);

PARAMETER MTINIT(CTRY,LC1,A1);
MTINIT(CTRY,LC1,A1) = MTFIN1(CTRY,LC1,A1)/2.5;

MTINIT('2',LC1,A1) = MTFIN1('2',LC1,A1)/3;

*adjust south inventories in US
MTINIT('1','1',A1) = MTFIN1('1','1',A1)/5;
MTINIT('1','4',A1) = MTFIN1('1','4',A1)/5;
MTINIT('1','26',A1) = MTFIN1('1','26',A1)/8.5;
MTINIT('1','27',A1) = MTFIN1('1','27',A1)/8.5;
MTINIT('1','28',A1) = MTFIN1('1','28',A1)/8.5;
MTINIT('1','29',A1) = MTFIN1('1','29',A1)/8.5;
MTINIT('1','30',A1) = MTFIN1('1','30',A1)/8.5;
MTINIT('1','31',A1) = MTFIN1('1','31',A1)/8.5;
MTINIT('1','32',A1) = MTFIN1('1','32',A1)/8.5;

$ONTEXT;

MODEL VARIABLES AND EQUATIONS

$OFFTEXT;

VARIABLES       
                NPVFOR1;

POSITIVE VARIABLES
          PROPPULP(CTRY,LC1,T) proportion of harvest that is pulp
          PULPQ(T) total pulp quantity global only used in conopt
          SAWQ(T) total sawtimber quant global only in conopt
                CS(T) consumer surplus only in conopt
          MC(T) harvest costs only in conopt
          MCOSTS(CTRY,LC1,T) sawtimber harvest costs only in conopt
          MCOSTP(CTRY,LC1,T) pulpwood harvest costs only in conopt
          RESCOST(CTRY,LC1,T) residue costs for biomass only in conopt
          DEDBIOQUANT(CTRY,LC1,T) dedicated biomass plantations only in US in conopt
          DEDBIOCOST(CTRY,LC1,T) cost for ded biomass plant only in US and only in conopt
          PLANTC(T) planting costs only in conopt
          RENTC(T) rental costs only in conopt
          TC total costs only in conopt
                YACRE2(CTRY,LC1,A1,T) area of accessible ha
                YACRE3(CTRY,LC1,A1,T) area of regenerated forests in tropics
                ACHR2(CTRY,LC1,A1,T) accessible harvest area
                ACHR3(CTRY,LC1,A1,T) tropics regenerated forests harvests
                ACPL2(CTRY,LC1,T) replanting
                MGMT1(CTRY,LC1,A1,T)  management intensity variable
                IMGMT1(CTRY,LC1,T) initial management intensity variable age class one only
                ACPL3(CTRY,LC1,T) replanting of TEMPERATE semi-accessible forests
                ACPL4(CTRY,LC1,T) replanting of tropical inaccessible into semi-accessible
                ACPL5(CTRY,LC1,T) replanting of tropical semi-accessible into tropical semi-accessible
                ACPL6(CTRY,LC1,T) planting of new tropical semi-accessible forests.

          NEWACPLBIO(CTRY,LC1,T)  brand new hectares planted to dedicated biofuel
          ACPLBIO(CTRY,LC1,T)  replanted hectares in biofuel

                YACRIN1(CTRY,LC1,A1,T) area of inaccessible forestland
                ACHRIN1(CTRY,LC1,A1,T) area of inaccessible forestland harvested
                CHQ1(CTRY,LC1,T)  cumulative hectares harvested in inaccessible regions
                CNAC1(CTRY,LC1,T) used for soil carbon calculations in carbon models
	  TOTALFOREST(T) total global forest area
	FORAREALC(CTRY,LC1,T) total forest area by forest type lc
*******************************************************************************
* New Biomass Based Variables
*******************************************************************************
                BIOTIMBS(CTRY,LC1,A1,T) biomass timber
                BIOTIMBP(CTRY,LC1,A1,T) biomass timber
                PROPBIOS(CTRY,LC1,T) proportion of sawtimber harvest converted to biomass
                PROPBIOP(CTRY,LC1,T) proportion of pulpwood harvest converted to biomass
          RES(CTRY,LC1,A1,T) amount of residue harvested from sites
******************************************************************************
;

EQUATIONS
          COSTS2(T) conopt only - costs
          PULPQUANT(T) conopt only
          SAWQUANT(T) conopt only 
          CONSUMER(T) conopt only 
          COSTS(CTRY,LC1,T) conopt only 
          RENT(T) conopt only 
          PLANT(T) conopt only 
          COSTP(CTRY,LC1,T) conopt only 
          RCOST(CTRY,LC1,T) conopt only 
          TERMINAL conopt only 
          BENFORX conopt benefit function
                MOTION11(CTRY,LC1,A1,T)  equation of motion to move stock to new year
                MOTSIN11(CTRY,LC1,A1,T)       equation of motion for TEMPERATE semi-accessible timberland
                MOTIN11(CTRY,LC1,A1,T)         equation of motion for TEMPERATE inaccessible timberland
                MOTRPSIN1(CTRY,LC1,A1,T) equation of motion for semi-accessible timberland in tropical  zone
                MOTRPSIN2(CTRY,LC1,A1,T) equation of motion to move stock to new year for low quality types in trop
                MOTRPIN1(CTRY,LC1,A1,T) equation of motion for inaccessible timberland in tropical zone
                MOTION21(CTRY, LC1, A1,T)  equation of motion for management intensity var
                MOTION11BIO(CTRY,LC1,A1,T)
          MOTION21BIO(CTRY,LC1,A1,T)
          REPDEDBIO(CTRY,LC1,T) replanting dedicated biofuel plantations
          REPSLIN1(CTRY,LC1,T)  replanting for temperate semi-accessible timberland
                REPSLIN2(CTRY,LC1,T)  replanting for tropical semi-accessible timberland
                REPSLIN3(CTRY,LC1,T)  replanting for tropical semi-accessible timberland
                MAXFOR(CTRY,LC1,T) setting maximum forest area by type
	  MAXFORCTRY(CTRY,T) setting max forest area by region
	  MAXFORLC(CTRY,LC1,T) calculating forest area by region & land class
                HARVEST1(CTRY,LC1,A1,T)  harvest by age class
                HARVSIN1(CTRY,LC1,A1,T)  harvest from semi-accessible region
                HARVIN1(CTRY,LC1,A1,T)  harvest from inaccessible region
                HARVSIN2(CTRY,LC1,A1,T)  harvest from semi-accessible region
                HARVIN2(CTRY,LC1,A1,T)  harvest from inaccessible region
                HARVEST1BIO(CTRY,LC1,A1,T)
          DEDBIOEQ(CTRY,LC1,T)
          DEDBIOCOSTEQ(CTRY,LC1,T)
          CUMAC1(CTRY,LC1,T)  eqn for cumulative ha harvested from inac region in temperate
                CUMAC2(CTRY,LC1,T)  eqn for cumulative ha harvested from inac region in tropics
                TCHARV1(CTRY,LC1,A1,T)
                TCHARV2(CTRY,LC1,A1,T)
                CUNAC1(CTRY,LC1,T)
                BENFOR1 benefit function used for minos version
                BENEFC
                MAXPLT2(CTRY,LC1,T)
                MAXPLT3(CTRY,LC1,T)
          TFORESTAREA(T) equation for total forest area
;
*******************************************************************************
* equation for total forest area
TFORESTAREA(T).. TOTALFOREST(T)=E= 
	SUM(CTRY,SUM(LC1,SUM(A1,
	YACRE2(CTRY,LC1,A1,T)$(R1FOR(CTRY,LC1) EQ 1)+
         YACRE2(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)+
         YACRE2(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)+
         YACRE2(CTRY,LC1,A1,T)$(DEDBIO(CTRY,LC1) EQ 1)+
         YACRE3(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)+
         YACRIN1(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)+
         YACRIN1(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1))

));

*equation of motion for accessible timberland
MOTION11(CTRY,LC1,A1,T)$(R1FOR(CTRY,LC1) EQ 1)..
YACRE2(CTRY,LC1,A1,T)$(R1FOR(CTRY,LC1) EQ 1) =E= YACRE2(CTRY,LC1,A1-1,T-1) - ACHR2(CTRY,LC1,A1-1,T-1) +
ACPL2(CTRY,LC1,T-1)$AFIRST1(A1) +
FORINV2(CTRY,LC1,A1)$TFIRST(T) +
YACRE2(CTRY,LC1,A1,T-1)$ALAST1(A1) - ACHR2(CTRY,LC1,A1,T-1)$ALAST1(A1);

*equation of motion for management on accessible forests
MOTION21(CTRY,LC1,A1,T)$(R1FOR(CTRY,LC1) EQ 1)..
MGMT1(CTRY,LC1,A1,T)$(R1FOR(CTRY,LC1) EQ 1) =E= MGMT1(CTRY,LC1,A1-1,T-1) +
IMGMT1(CTRY,LC1,T-1)$AFIRST1(A1) + MTINIT(CTRY,LC1,A1)$TFIRST(T);

*equation of motion for dedicated biofuel plantations
MOTION11BIO(CTRY,LC1,A1,T)$(DEDBIO(CTRY,LC1) EQ 1)..
YACRE2(CTRY,LC1,A1,T)$(DEDBIO(CTRY,LC1) EQ 1) =E= YACRE2(CTRY,LC1,A1-1,T-1) - ACHR2(CTRY,LC1,A1-1,T-1) +
NEWACPLBIO(CTRY,LC1,T-1)$AFIRST1(A1) +
ACPLBIO(CTRY,LC1,T-1)$AFIRST1(A1) +
FORINV2(CTRY,LC1,A1)$TFIRST(T) +
YACRE2(CTRY,LC1,A1,T-1)$ALAST1(A1) - ACHR2(CTRY,LC1,A1,T-1)$ALAST1(A1);

*equation of motion for management of dedicated biofuel plantations
MOTION21BIO(CTRY,LC1,A1,T)$(DEDBIO(CTRY,LC1) EQ 1)..
MGMT1(CTRY,LC1,A1,T)$(DEDBIO(CTRY,LC1) EQ 1) =E= MGMT1(CTRY,LC1,A1-1,T-1) +
IMGMT1(CTRY,LC1,T-1)$AFIRST1(A1) + MTINIT(CTRY,LC1,A1)$TFIRST(T);


*equation of motion for TEMPERATE semi-accessible timberland
MOTSIN11(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)..
YACRE2(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1) =E= YACRE2(CTRY,LC1,A1-1,T-1)-ACHR2(CTRY,LC1,A1-1,T-1) +
0$TFIRST(T) +ACPL3(CTRY,LC1,T-1)$AFIRST1(A1) +
YACRE2(CTRY,LC1,A1,T-1)$ALAST1(A1)-ACHR2(CTRY,LC1,A1,T-1)$ALAST1(A1);

*equation of motion for TEMPERATE inaccessible timberland
MOTIN11(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)..
YACRIN1(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)  =E=
        YACRIN1(CTRY,LC1,A1-1,T-1) -
        ACHRIN1(CTRY,LC1,A1-1,T-1)+INACI2(CTRY,LC1,A1)$TFIRST(T)+
YACRIN1(CTRY,LC1,A1,T-1)$ALAST1(A1)- ACHRIN1(CTRY,LC1,A1,T-1)$ALAST1(A1)
;

*equation of motion for TROPICAL semi-accessible timberland
*YACRE2 for tropical holds the higher value tropical forest types
MOTRPSIN1(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)..
YACRE2(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1) =E= YACRE2(CTRY,LC1,A1-1,T-1)-ACHR2(CTRY,LC1,A1-1,T-1) +
0$TFIRST(T)+ ACPL6(CTRY,LC1,T-1)$AFIRST1(A1)+
YACRE2(CTRY,LC1,A1,T-1)$ALAST1(A1)-ACHR2(CTRY,LC1,A1,T-1)$ALAST1(A1);

*YACRE3 for tropical holds the lower value replanted-regenerated forests.
MOTRPSIN2(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)..
YACRE3(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1) =E= YACRE3(CTRY,LC1,A1-1,T-1)- ACHR3(CTRY,LC1,A1-1,T-1) +
ACPL5(CTRY,LC1,T-1)$AFIRST1(A1)+
YACRE3(CTRY,LC1,A1,T-1)$ALAST1(A1)-ACHR3(CTRY,LC1,A1,T-1)$ALAST1(A1);

*equation of motion for TROPICAL inaccessible timberland
MOTRPIN1(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)..
YACRIN1(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)  =E=
        YACRIN1(CTRY,LC1,A1-1,T-1) -
        ACHRIN1(CTRY,LC1,A1-1,T-1)+INACI2(CTRY,LC1,A1)$TFIRST(T)+
YACRIN1(CTRY,LC1,A1,T-1)$ALAST1(A1)- ACHRIN1(CTRY,LC1,A1,T-1)$ALAST1(A1);

*replanting for TEMPERATE semi-accessible timberland
REPSLIN1(CTRY,LC1,T)$(TEMPINAC(CTRY,LC1) EQ 1)..
ACPL3(CTRY,LC1,T) $(TEMPINAC(CTRY,LC1) EQ 1) =E=
        SUM(A1,ACHRIN1(CTRY,LC1,A1,T)) + SUM(A1,ACHR2(CTRY,LC1,A1,T));

*replanting dedicated biofuel plantations
REPDEDBIO(CTRY,LC1,T)$(DEDBIO(CTRY,LC1) EQ 1)..
ACPLBIO(CTRY,LC1,T) =L= SUM(A1, ACHR2(CTRY,LC1,A1,T));

*MAXFOR sets the maximum forest area 
*set to a high level so it is not constraining, but can be adjusted with exogenous information.
PARAMETER MXFORA;
MXFORA=10;

MAXFOR(CTRY,LC1,T)$(R1FOR(CTRY,LC1) EQ 1)..
SUM(A1,YACRE2(CTRY,LC1,A1,T))=L= SUM(A1,FORINV2(CTRY,LC1,A1))* MXFORA;

MAXFORCTRY(CTRY,T)..
SUM(LC1$(R1FOR(CTRY,LC1) EQ 1),SUM(A1,YACRE2(CTRY,LC1,A1,T)))+ 
SUM(LC1$(TEMPINAC(CTRY,LC1) EQ 1),SUM(A1,YACRE2(CTRY,LC1,A1,T)))+
SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),SUM(A1,YACRE2(CTRY,LC1,A1,T)))+
SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),SUM(A1,YACRE3(CTRY,LC1,A1,T)))+
SUM(LC1$(TEMPINAC(CTRY,LC1) EQ 1),SUM(A1,YACRIN1(CTRY,LC1,A1,T)))+
SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),SUM(A1,YACRIN1(CTRY,LC1,A1,T)))
	=L= FORLIMIT(CTRY);

MAXFORLC(CTRY,LC1,T)..
SUM(A1,YACRE2(CTRY,LC1,A1,T)$(R1FOR(CTRY,LC1) EQ 1)) + 
SUM(A1,YACRE2(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)) +
SUM(A1,YACRE2(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)) +
SUM(A1,YACRE3(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)) +
SUM(A1,YACRIN1(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)) +
SUM(A1,YACRIN1(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)) 
=E=
FORAREALC(CTRY,LC1,T);


*harvesting constraint, harvest must be less than total hectares available.
HARVEST1(CTRY,LC1,A1,T)$(ALLIN2(CTRY,LC1) EQ 1)..
ACHR2(CTRY,LC1,A1,T)$(ALLIN2(CTRY,LC1) EQ 1) =L= YACRE2(CTRY,LC1,A1,T);

HARVEST1BIO(CTRY,LC1,A1,T)$(DEDBIO(CTRY,LC1) EQ 1)..
ACHR2(CTRY,LC1,A1,T)$(DEDBIO(CTRY,LC1) EQ 1) =L= YACRE2(CTRY,LC1,A1,T);

*harvest constraint for inaccessible and semi-accessible timberland
HARVSIN1(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)..
ACHR2(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1) =L= YACRE2(CTRY,LC1,A1,T);

HARVIN1(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)..
ACHRIN1(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1) =L= YACRIN1(CTRY,LC1,A1,T);

HARVSIN2(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)..
ACHR2(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1) =L= YACRE2(CTRY,LC1,A1,T);

HARVIN2(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)..
ACHRIN1(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1) =L= YACRIN1(CTRY,LC1,A1,T);

*cumulative harvests in temperate zone inaccessible forests
CUMAC1(CTRY,LC1,T)$(TEMPINAC(CTRY,LC1) EQ 1)..
CHQ1(CTRY,LC1,T)$(TEMPINAC(CTRY,LC1) EQ 1) =E= CHQ1(CTRY,LC1,T-1)+ SUM(A1,ACHRIN1(CTRY,LC1,A1,T));

*harvest all hectares in last period to impose terminal condition.
TCHARV1(CTRY,LC1,A1,T)$TLAST(T)..
ACHR2(CTRY,LC1,A1,T) =E=
        YACRE2(CTRY,LC1,A1,T)$(ALLIN(CTRY,LC1) EQ 1);

TCHARV2(CTRY,LC1,A1,T)$TLAST(T)..
ACHR3(CTRY,LC1,A1,T) =E=
        YACRE3(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1);

*Calculating Net Surplus for the forestry only scenario
BENFOR1.. NPVFOR1 =E= SUM(T$YEAR(T),RHO(T)*[

*benefit from sawtimber production
[AFS(T)**(1/BF)]*[1/((-1/BF)+1)]*

{( SUM(CTRY,

*accessible timber - with proportion going to Biomass
SUM[LC1$(R1FOR(CTRY,LC1) EQ 1),
SUM(A1, 
(1-PROPPULP(CTRY,LC1,T)+EPSILON)*
(ACHR2(CTRY,LC1,A1,T)+EPSILON)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+

* Temperate semi-inaccessible
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),

SUM(A1, (1-PROPPULP(CTRY,LC1,T) +EPSILON)*
(ACHR2(CTRY,LC1,A1,T)+EPSILON)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+
*******************************************************************************
*temperate inaccessible
* use merchantable yield functions less management effects.
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),
        (1-PROPPULP(CTRY,LC1,T) +EPSILON)*PARAM2(CTRY,LC1,'8')*
       SUM(A1,(ACHRIN1(CTRY,LC1,A1,T) +EPSILON)*
       YLDINAC(CTRY,LC1,A1,T))]+

*tropical semi-inaccessible
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1, (1-PROPPULP(CTRY,LC1,T) +EPSILON)*
(ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+

*tropical low harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1, (1-PROPPULP(CTRY,LC1,T) +EPSILON)*
(ACHR3(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*0.5*PARAM2(CTRY,LC1,'8'))]+

*tropical inacessible – harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        (1-PROPPULP(CTRY,LC1,T) +EPSILON)*PARAM2(CTRY,LC1,'8')*
SUM(A1,(ACHRIN1(CTRY,LC1,A1,T) +EPSILON)*YLDINAC(CTRY,LC1,A1,T))]+

EPSILON) + EPSILON)**((-1/BF)+1)}$YEAR(T)

-[AFS(T)**(1/BF)]*[1/((-1/BF)+1)]*{CONSTFO**((-1/BF)+1)}$YEAR(T)

+

*benefit from pulpwood production
[AFP(T)**(1/BF)]*[1/((-1/BF)+1)]*

{( SUM(CTRY,


*accessible timber - with proportion going to Biomass
SUM[LC1$(R1FOR(CTRY,LC1) EQ 1),
SUM(A1, (PROPPULP(CTRY,LC1 ,T) +EPSILON)*
(ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+

*dedicated fastgrowing plantations - with proportion going to Biomass
SUM[LC1$(DEDBIO(CTRY,LC1) EQ 1),
 PARAM3(CTRY,LC1,'20')*{SUM(A1,((ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T))$(DEDBIO(CTRY,LC1) EQ 1)))}]


+

* Temperate semi-inaccessible
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),

SUM(A1, (PROPPULP(CTRY,LC1 ,T) +EPSILON)*
(ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+
*******************************************************************************
*temperate inaccessible
* use merchantable yield functions less management effects.
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),
        (PROPPULP(CTRY,LC1 ,T) +EPSILON)*
        PARAM2(CTRY,LC1,'8')*SUM(A1,(ACHRIN1(CTRY,LC1,A1,T) +EPSILON)*
       YLDINAC(CTRY,LC1,A1,T))]

+

*tropical semi-inaccessible
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1, (PROPPULP(CTRY,LC1 ,T) +EPSILON)*
(ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+

*tropical low harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1, (PROPPULP(CTRY,LC1 ,T) +EPSILON)*
        (ACHR3(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*0.5*PARAM2(CTRY,LC1,'8'))]+

*tropical inacessible – harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        (PROPPULP(CTRY,LC1 ,T) +EPSILON)*PARAM2(CTRY,LC1,'8')*
       SUM(A1,(ACHRIN1(CTRY,LC1,A1,T) +EPSILON)*YLDINAC(CTRY,LC1,A1,T))]+

EPSILON) + EPSILON)**((-1/BF)+1)}$YEAR(T)

-[AFP(T)**(1/BF)]*[1/((-1/BF)+1)]*{CONSTFO**((-1/BF)+1)}$YEAR(T)

*costs of sawtimber production on accessible lands
-(
SUM(CTRY,SUM(LC1,

(1-PROPPULP(CTRY,LC1,T) +EPSILON)*
CSA(CTRY,LC1,'1')*SUM(A1,(ACHR2(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(R1FOR(CTRY,LC1) EQ 1)

+

[
{(1-PROPPULP(CTRY,LC1,T) +EPSILON)*SUM(A1,(ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'2')]$(R1FOR(CTRY,LC1) EQ 1)

*cost of sawtimber production on temperate semi-accessible lands
+
(1-PROPPULP(CTRY,LC1,T) +EPSILON)*
CSA(CTRY,LC1,'3')*SUM(A1,(ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*
     PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(TEMPINAC(CTRY,LC1) EQ 1)

+
[{(1-PROPPULP(CTRY,LC1,T) +EPSILON)*SUM(A1,(ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*
     PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'4')]$(TEMPINAC(CTRY,LC1) EQ 1)

*cost of sawtimber production on tropical semi-accessible lands
+
(1-PROPPULP(CTRY,LC1,T) +EPSILON)*
CSA(CTRY,LC1,'3')*SUM(A1,[ACHR2(CTRY,LC1,A1,T) +EPSILON]*
        YIELD2(CTRY,LC1,A1,T)*
        PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(TROPINAC(CTRY,LC1) EQ 1)

+

[
{(1-PROPPULP(CTRY,LC1,T) +EPSILON)*SUM(A1,[ACHR2(CTRY,LC1,A1,T) +EPSILON]*
        YIELD2(CTRY,LC1,A1,T)*
        PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'4')]$(TROPINAC(CTRY,LC1) EQ 1)


*cost of harvesting temperate inaccessible lands
+
(1-PROPPULP(CTRY,LC1,T) +EPSILON)*
SUM(A1,ACHRIN1(CTRY,LC1,A1,T) +EPSILON)*
PARAM2(CTRY,LC1,'12')*{CHQ1(CTRY,LC1,T)+EPSILON}**(1/PARAM2(CTRY,LC1,'13'))$(TEMPINAC(CTRY,LC1) EQ 1)


*cost of harvesting tropical inaccessible lands
+
(1-PROPPULP(CTRY,LC1,T) +EPSILON)*
{SUM(A1,ACHRIN1(CTRY,LC1,A1,T)+ ACHR3(CTRY,LC1,A1,T))+EPSILON}*
PARAM2(CTRY,LC1,'14')*
{SUM(A1,ACHRIN1(CTRY,LC1,A1,T)+ ACHR3(CTRY,LC1,A1,T))+EPSILON}**(1/PARAM2(CTRY,LC1,'15')) $(TROPINAC(CTRY,LC1) EQ 1)
))
*end of cost of sawtimber harvesting
)

-

*costs of pulpwood production
(
SUM(CTRY,SUM(LC1,
(PROPPULP(CTRY,LC1,T)+EPSILON)*
CSA(CTRY,LC1,'5')*SUM(A1,(ACHR2(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(R1FOR(CTRY,LC1) EQ 1)

+
[
{(PROPPULP(CTRY,LC1,T)+EPSILON)*
SUM(A1,(ACHR2(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'6')]$(R1FOR(CTRY,LC1) EQ 1)

*cost of harvesting temperate semi-accessible lands
+
(PROPPULP(CTRY,LC1,T)+EPSILON)*
CSA(CTRY,LC1,'7')*SUM(A1,(ACHR2(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*
     PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(TEMPINAC(CTRY,LC1) EQ 1)

+
[
{(PROPPULP(CTRY,LC1,T) +EPSILON)*
SUM(A1,(ACHR2(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*
     PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'8')]$(TEMPINAC(CTRY,LC1) EQ 1)

*cost of harvesting tropical semi-accessible lands
+
(PROPPULP(CTRY,LC1,T)+EPSILON)*
CSA(CTRY,LC1,'7')*SUM(A1,[ACHR2(CTRY,LC1,A1,T) +EPSILON]*
        YIELD2(CTRY,LC1,A1,T)*
        PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(TROPINAC(CTRY,LC1) EQ 1)
+

[
{(PROPPULP(CTRY,LC1,T)+EPSILON)*SUM(A1,[ACHR2(CTRY,LC1,A1,T) +EPSILON]*
        YIELD2(CTRY,LC1,A1,T)*
        PARAM2(CTRY,LC1,'8')*((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'8')]$(TROPINAC(CTRY,LC1) EQ 1)


*cost of harvesting temperate inaccessible lands
+
(PROPPULP(CTRY,LC1,T)+EPSILON)*
SUM(A1,ACHRIN1(CTRY,LC1,A1,T) +EPSILON)*
PARAM2(CTRY,LC1,'12')*{CHQ1(CTRY,LC1,T)+EPSILON}**(1/PARAM2(CTRY,LC1,'13'))$(TEMPINAC(CTRY,LC1) EQ 1)

*cost of harvesting tropical inaccessible lands
+
(PROPPULP(CTRY,LC1,T)+EPSILON)*
{SUM(A1,ACHRIN1(CTRY,LC1,A1,T)+ ACHR3(CTRY,LC1,A1,T))+EPSILON}*
PARAM2(CTRY,LC1,'14')*
{SUM(A1,ACHRIN1(CTRY,LC1,A1,T)+ ACHR3(CTRY,LC1,A1,T))+EPSILON}**(1/PARAM2(CTRY,LC1,'15'))$(TROPINAC(CTRY,LC1) EQ 1)
*end of cost of pulpwood harvesting
))
)

-
(
SUM(CTRY,SUM(LC1,
*dedicated biofuel harvesting costs
CSA(CTRY,LC1,'5')*[ SUM(A1,((ACHR2(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T))$(DEDBIO(CTRY,LC1) EQ 1)))]+
(SUM(A1,((ACHR2(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T))$(DEDBIO(CTRY,LC1) EQ 1)))+EPSILON)**CSA(CTRY,LC1,'6')

*transportation costs
+
[SUM(A1,((ACHR2(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T))$(DEDBIO(CTRY,LC1) EQ 1)))]*PARAM3(CTRY,LC1,'18')*PARAM3(CTRY,LC1,'19')
))
*end of dedicated biofuel harvesting costs
)

-
(
*planting costs accessible lands
+SUM(CTRY,SUM(LC1$(R1FOR(CTRY,LC1) EQ 1),(IMGMT1(CTRY,LC1,T) +EPSILON)*(ACPL2(CTRY,LC1,T) +EPSILON)))$YEAR(T)

*planting costs dedicated biofuels
+SUM(CTRY,SUM(LC1$(DEDBIO(CTRY,LC1) EQ 1),
(IMGMT1(CTRY,LC1,T) +EPSILON)*[ACPLBIO(CTRY,LC1,T)+NEWACPLBIO(CTRY,LC1,T) +EPSILON]))$YEAR(T)

*planting costs dedicated biofuels
+SUM(CTRY,SUM(LC1$(DEDBIO(CTRY,LC1) EQ 1),PARAM3(CTRY,LC1,'17')*(NEWACPLBIO(CTRY,LC1,T) +EPSILON)))$YEAR(T)

*planting costs TEMPERATE ZONE inaccessible
+SUM(CTRY, SUM(LC1$(TEMPINAC(CTRY,LC1) EQ 1),(IMGMT1(CTRY,LC1,T) +EPSILON)*(ACPL3(CTRY,LC1,T) +EPSILON)))$YEAR(T)

*planting costs TROPICAL ZONE inaccessible original with ACPL6 only
+SUM(CTRY, SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),[IMGMT1(CTRY,LC1,T)+2000]*
        [ACPL6(CTRY,LC1,T) +EPSILON]
        ))$YEAR(T)
*end of planting costs
)

-
*land rental costs
(
DDISC*{SUM[CTRY,

*accessible forests
SUM(LC1$(R1FOR(CTRY,LC1) EQ 1),
SUM(A1,YACRE2(CTRY,LC1,A1,T)+EPSILON)*
RENTA(CTRY,LC1,T)*
[(EPSILON+(TOTALFOREST(T)/TOTALFOREST('1')))**(1/GRENTB)]*
         {SUM(A1,YACRE2(CTRY,LC1,A1,T)+EPSILON)**(1/RENTB(CTRY,LC1))}
)

+
*accessible forests
SUM(LC1$(DEDBIO(CTRY,LC1) EQ 1),
SUM(A1,YACRE2(CTRY,LC1,A1,T)+EPSILON)*
[RENTZ(CTRY,LC1,T)*(EPSILON+(TOTALFOREST(T)/TOTALFOREST('1')))**(1/GRENTB)+

RENTA(CTRY,LC1,T)*
[(EPSILON+(TOTALFOREST(T)/TOTALFOREST('1')))**(1/GRENTB)]*
         {SUM(A1,YACRE2(CTRY,LC1,A1,T)+EPSILON)**(1/RENTB(CTRY,LC1))}
]
)

*+YACRE3(CTRY,LC1,A1,T)

*use alternative for tropical forests
+
*inaccessible forests tropical zone
SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),
-RENTZ(CTRY,LC1,T)*
[(EPSILON+(TOTALFOREST(T)/TOTALFOREST('1')))**(1/GRENTB)]*
[SUM(A1,YACRE2(CTRY,LC1,A1,T) +YACRE3(CTRY,LC1,A1,T) +YACRIN1(CTRY,LC1,A1,T))+EPSILON]+
{1/((1/RENTB(CTRY,LC1))+1)}*
RENTA(CTRY,LC1,T)*
[(EPSILON+(TOTALFOREST(T)/TOTALFOREST('1')))**(1/GRENTB)]*
[SUM(A1,YACRE2(CTRY,LC1,A1,T) +YACRE3(CTRY,LC1,A1,T) +YACRIN1(CTRY,LC1,A1,T))+EPSILON]**{(1/RENTB(CTRY,LC1))+1}
)

-
*subtract out negative part
SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),
-RENTZ(CTRY,LC1,T)*[RENTHA(CTRY,LC1,T)]+
{1/((1/RENTB(CTRY,LC1))+1)}*
RENTA(CTRY,LC1,T)*
[(EPSILON+(TOTALFOREST(T)/TOTALFOREST('1')))**(1/GRENTB)]*
        [RENTHA(CTRY,LC1,T)+EPSILON]**{(1/RENTB(CTRY,LC1))+1}
)

]}$YEAR(T)
*end of rental costs
)

* ]end of country sum
]
* )end of time sum
)

*terminal conditions

+ SUM(T,

RHO(T)*[SUM(CTRY, SUM(LC1$(R1FOR(CTRY,LC1) EQ 1),SUM(A1,LAMBDA1(CTRY,LC1,A1)*
        ACHR2(CTRY,LC1,A1,T) -
        LAMBDA1(CTRY,LC1,A1)*(ACHR2(CTRY,LC1,A1,T) -
        FINAC1(CTRY,LC1,A1)+EPSILON)*(ACHR2(CTRY,LC1,A1,T)-
        FINAC1(CTRY,LC1,A1)+EPSILON))))]$FINT(T)

+
RHO(T)*[SUM(CTRY, SUM(LC1$(TEMPINAC(CTRY,LC1) EQ 1),SUM(A1,LAMBDA1(CTRY,LC1,A1)*
        [ACHR2(CTRY,LC1,A1,T)+ACHR3(CTRY,LC1,A1,T)])))]$FINT(T)

+
RHO(T)*[SUM(CTRY, SUM(LC1$(R1FOR(CTRY,LC1) EQ 1),SUM(A1,PSI1(CTRY,LC1,A1)*
        FINAC1(CTRY,LC1,A1)*(MGMT1(CTRY,LC1,A1,T) -
        (MGMT1(CTRY,LC1,A1,T) -
        MTFIN1(CTRY,LC1,A1)+EPSILON)*(MGMT1(CTRY,LC1,A1,T)-
        MTFIN1(CTRY,LC1,A1)+EPSILON)))))]$FINT(T)
+
RHO(T)*[SUM(CTRY, SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1), SUM(A1,LAMBDA1(CTRY,LC1,A1)*
        YACRIN1(CTRY,LC1,A1,T))))]$FINT(T)

)
;


*******************************************************************************
* CHANGED LIMROW AND LIMCOL TO SHOW EQUATIONS IN LIST FILE (PRIOR, BOTH = 0)
*******************************************************************************
OPTION LIMROW = 5,
      LIMCOL =  3 ;

OPTION ITERLIM = 50000000;
OPTION RESLIM = 50000000;
*OPTION BRATIO=1;

* Can solve using either MINOS or CONOPT but recommend MINOS for this formulation
OPTION NLP= MINOS;
OPTION DOMLIM=1000000;
*OPTION SYSOUT = ON;
*OPTION PROFILE =3;
*OPTION DMPSYM;


MODEL DYNFONLYM / MOTION11, MOTSIN11, MOTIN11, MOTRPSIN1, MOTRPSIN2,MOTRPIN1,
MOTION21, MOTION11BIO, MOTION21BIO, REPSLIN1, REPDEDBIO, MAXFOR, MAXFORCTRY,  MAXFORLC, HARVEST1,HARVSIN1,HARVIN1,
HARVSIN2,HARVIN2, HARVEST1BIO , CUMAC1 ,TCHARV1,TCHARV2, BENFOR1, TFORESTAREA 
/;


*initialize some variables for solve
PARAMETER YACRE2ZERO(CTRY,LC1);
YACRE2ZERO(CTRY,LC1) = 1-R1FOR(CTRY,LC1) - TEMPINAC(CTRY,LC1) -TROPINAC(CTRY,LC1)- DEDBIO(CTRY,LC1);

YACRE2.L(CTRY,LC1,A1,T) = FORINV2(CTRY,LC1,A1)*0;
ACHR2.L(CTRY,LC1,A1,T) = YACRE2.L(CTRY,LC1,A1,T)/2;

YACRIN1.L(CTRY,LC1,A1,T) = INACI2(CTRY,LC1,A1);
ACHRIN1.L(CTRY,LC1,A1,T) =0;

MGMT1.L(CTRY,LC1,A1,T) = MTFIN1(CTRY,LC1,A1)/1.4;
IMGMT1.L(CTRY,LC1,T) = MTFIN1(CTRY,LC1,'1')/1.4;

*set upper and lower bounds on management intensity
IMGMT1.LO(CTRY,LC1,T) = MTFIN1(CTRY,LC1,'1')*0;
IMGMT1.UP(CTRY,LC1,T) = MTFIN1(CTRY,LC1,'1')*4;
MGMT1.LO(CTRY,LC1,A1,T) = MTFIN1(CTRY,LC1,'1')*0;
MGMT1.UP(CTRY,LC1,A1,T) = MTFIN1(CTRY,LC1,'1')*4;

YACRE2.LO(CTRY,LC1,A1,T) = FORINV2(CTRY,LC1,A1)*0;
YACRE2.UP(CTRY,LC1,A1,T) = 10000;

YACRE2.LO(CTRY,LC1,A1,T)$(YACRE2ZERO(CTRY,LC1) EQ 1) = 0;
YACRE2.UP(CTRY,LC1,A1,T)$(YACRE2ZERO(CTRY,LC1) EQ 1) = 0;

PROPPULP.L(CTRY,LC1 ,T) = PARAM3(CTRY,LC1,'14');

MXFORA=10;

YACRE3.L(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)=0;

TOTALFOREST.L(T) = SUM(CTRY,SUM(LC1,SUM(A1,
         YACRE2.L(CTRY,LC1,A1,T)$(R1FOR(CTRY,LC1) EQ 1)+
         YACRE2.L(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)+
         YACRE2.L(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)+
         YACRE3.L(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1)+
         YACRIN1.L(CTRY,LC1,A1,T)$(TEMPINAC(CTRY,LC1) EQ 1)+
         YACRIN1.L(CTRY,LC1,A1,T)$(TROPINAC(CTRY,LC1) EQ 1))
));

PROPPULP.UP(CTRY,LC1 ,T) =1;

*create option file
FILE BBBM /MINOS.OPT/;
  PUT BBBM;
          PUT 'superbasics limit = 10000'/;
  PUTCLOSE BBBM;

DYNFONLYM.WORKSPACE = 900;

DYNFONLYM.OPTFILE = 1;
DYNFONLYM.SCALEOPT= 1;

MGMT1.SCALE(CTRY,LC1,A1,T)=10;

BENFOR1.SCALE =1000000;
NPVFOR1.SCALE =1000000;

SOLVE DYNFONLYM USING NLP MAXIMIZING NPVFOR1;


* PLACES ALL OUTPUT TO A GDX FILE
* redo this at end
execute_unload "GLOBALTIMBERMODEL2020.gdx";


$ONTEXT;
The rest of the file creates output and puts it into a set of tables that are placed into a PUT file
Which can be imported directly into Excel.  

Carbon calculations are also provided below.
$OFFTEXT;

PARAMETER RENTACC(CTRY,LC1,T);
RENTACC(CTRY,LC1,T)$(ALLIN(CTRY,LC1) EQ 1)=
-RENTZ(CTRY,LC1,T) +
RENTA(CTRY,LC1,T)*{[SUM(A1,YACRE2.L(CTRY,LC1,A1,T) + YACRE3.L(CTRY,LC1,A1,T) +
YACRIN1.L(CTRY,LC1,A1,T))+ EPSILON]**(1/RENTB(CTRY,LC1))}

PARAMETER RENTAMT(CTRY,LC1,T);
RENTAMT(CTRY,LC1,T)$(TROPINAC(CTRY,LC1) EQ 1) =
*inaccessible forests tropical zone
-RENTZ(CTRY,LC1,T)*
[SUM(A1,YACRE2.L(CTRY,LC1,A1,T) +YACRE3.L(CTRY,LC1,A1,T) +YACRIN1.L(CTRY,LC1,A1,T))+EPSILON]+
{1/((1/RENTB(CTRY,LC1))+1)}*RENTA(CTRY,LC1,T)*
[SUM(A1,YACRE2.L(CTRY,LC1,A1,T) +YACRE3.L(CTRY,LC1,A1,T) +YACRIN1.L(CTRY,LC1,A1,T))+EPSILON]**{(1/RENTB(CTRY,LC1))+1}
-
*subtract out negative part
(
-RENTZ(CTRY,LC1,T)*[RENTHA(CTRY,LC1,T)]+
{1/((1/RENTB(CTRY,LC1))+1)}*RENTA(CTRY,LC1,T)*
        [RENTHA(CTRY,LC1,T)+EPSILON]**{(1/RENTB(CTRY,LC1))+1}
);

DISPLAY RENTACC, RENTAMT;

PARAMETER RENTTOTAL(CTRY,LC1,T);
RENTTOTAL(CTRY,LC1,T) =
*inaccessible forests tropical zone
-RENTZ(CTRY,LC1,T)*
[SUM(A1,YACRE2.L(CTRY,LC1,A1,T) +YACRE3.L(CTRY,LC1,A1,T) +YACRIN1.L(CTRY,LC1,A1,T))+EPSILON]+
{1/((1/RENTB(CTRY,LC1))+1)}*RENTA(CTRY,LC1,T)*
[SUM(A1,YACRE2.L(CTRY,LC1,A1,T) +YACRE3.L(CTRY,LC1,A1,T) +YACRIN1.L(CTRY,LC1,A1,T))+EPSILON]**{(1/RENTB(CTRY,LC1))+1}

-
*subtract out negative part
(
-RENTZ(CTRY,LC1,T)*[RENTHA(CTRY,LC1,T)]+
{1/((1/RENTB(CTRY,LC1))+1)}*RENTA(CTRY,LC1,T)*
        [RENTHA(CTRY,LC1,T)+EPSILON]**{(1/RENTB(CTRY,LC1))+1}
);

PARAMETER RENTTOTALCTRY(CTRY,T);
RENTTOTALCTRY(CTRY,T) = SUM(LC1,RENTTOTAL(CTRY,LC1,T));

*quantity of sawtimber harvested by region
PARAMETER QFS(CTRY,T);
QFS(CTRY,T) =


*accessible timber - with proportion going to Biomass
SUM[LC1$(R1FOR(CTRY,LC1) EQ 1),
SUM(A1,(1-PROPPULP.L(CTRY,LC1,T))*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+

* Temperate semi-inaccessible
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),

SUM(A1, (1-PROPPULP.L(CTRY,LC1,T))*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+
*******************************************************************************
*temperate inacessible - harvest at the average age of the old stuff
* harvest average timber age; the 0.6 is the merchantable proportion.
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),
        (1-PROPPULP.L(CTRY,LC1,T))*PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)*
        YLDINAC(CTRY,LC1,A1,T))]+

*tropical semi-inaccessible
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1, (1-PROPPULP.L(CTRY,LC1,T))*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+

*tropical low harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1, (1-PROPPULP.L(CTRY,LC1,T))*
ACHR3.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*0.5*PARAM2(CTRY,LC1,'8'))]+

*tropical inacessible - harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        (1-PROPPULP.L(CTRY,LC1,T))*
PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)* YLDINAC(CTRY,LC1,A1,T))]
;

*quantity of sawtimber harvested by region and land class
PARAMETER QFSLC(CTRY,LC1,T);
QFSLC(CTRY,LC1,T) =

*accessible timber - with proportion going to Biomass
[SUM(A1, (1-PROPPULP.L(CTRY,LC1,T))*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]$(R1FOR(CTRY,LC1) EQ 1)+

* Temperate semi-inaccessible
[SUM(A1, (1-PROPPULP.L(CTRY,LC1,T))*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]$(TEMPINAC(CTRY,LC1) EQ 1)+
*******************************************************************************
*temperate inacessible - harvest at the average age of the old stuff
* harvest average timber age; the 0.6 is the merchantable proportion.
[(1-PROPPULP.L(CTRY,LC1,T))*PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)*
        YLDINAC(CTRY,LC1,A1,T))]$(TEMPINAC(CTRY,LC1) EQ 1)+

*tropical semi-inaccessible
[SUM(A1, (1-PROPPULP.L(CTRY,LC1,T))*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]$(TROPINAC(CTRY,LC1) EQ 1)+

*tropical low harvest
[SUM(A1, (1-PROPPULP.L(CTRY,LC1,T))*
ACHR3.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*0.5*PARAM2(CTRY,LC1,'8'))] $(TROPINAC(CTRY,LC1) EQ 1)+

*tropical inacessible - harvest
[(1-PROPPULP.L(CTRY,LC1,T))*
PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)* YLDINAC(CTRY,LC1,A1,T))] $(TROPINAC(CTRY,LC1) EQ 1)
;

*quantity of sawtimber harvested globally
PARAMETER TAFS(T);
TAFS(T) = SUM(CTRY,QFS(CTRY ,T));

*global price of sawtimber 
PARAMETER FPS(T);
FPS(T) = (1/1)*{AFS(T)**(1/BF)}*{(TAFS(T)+EPSILON)**(-1/BF)};

DISPLAY QFS, TAFS, FPS;

*quantity of pulpwood harvested regionally
PARAMETER QFP(CTRY,T);
QFP(CTRY,T) =


*accessible timber - with proportion going to Biomass
SUM[LC1$(R1FOR(CTRY,LC1) EQ 1),
SUM(A1, PROPPULP.L(CTRY,LC1 ,T)*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+

* Temperate semi-inaccessible
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),

SUM(A1, PROPPULP.L(CTRY,LC1 ,T)*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+
*******************************************************************************
*temperate inacessible - harvest at the average age of the old stuff
* harvest average timber age; the 0.6 is the merchantable proportion.
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),
        PROPPULP.L(CTRY,LC1 ,T)*
        PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)*
        YLDINAC(CTRY,LC1,A1,T))]+

*tropical semi-inaccessible
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1, PROPPULP.L(CTRY,LC1 ,T)*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+

*tropical low harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1, PROPPULP.L(CTRY,LC1 ,T)*
        ACHR3.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*0.5*PARAM2(CTRY,LC1,'8'))]+

*tropical inacessible - harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        PROPPULP.L(CTRY,LC1 ,T)*PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)* YLDINAC(CTRY,LC1,A1,T))]
;

*quantity of sawtimber harvested regionally and by land class
PARAMETER QFPLC(CTRY,LC1,T);
QFPLC(CTRY,LC1,T) =

*accessible timber - with proportion going to Biomass
[SUM(A1, PROPPULP.L(CTRY,LC1 ,T)*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]$(R1FOR(CTRY,LC1) EQ 1)+

* Temperate semi-inaccessible
[SUM(A1, PROPPULP.L(CTRY,LC1 ,T)*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]$(TEMPINAC(CTRY,LC1) EQ 1)+
*******************************************************************************
*temperate inacessible - harvest at the average age of the old stuff
* harvest average timber age; the 0.6 is the merchantable proportion.
[        PROPPULP.L(CTRY,LC1 ,T)*
        PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)*
        YLDINAC(CTRY,LC1,A1,T))]$(TEMPINAC(CTRY,LC1) EQ 1)+

*tropical semi-inaccessible
[SUM(A1, PROPPULP.L(CTRY,LC1 ,T)*
ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))] $(TROPINAC(CTRY,LC1) EQ 1)+

*tropical low harvest
[SUM(A1, PROPPULP.L(CTRY,LC1 ,T)*
        ACHR3.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*0.5*PARAM2(CTRY,LC1,'8'))] $(TROPINAC(CTRY,LC1) EQ 1)+

*tropical inacessible - harvest
[PROPPULP.L(CTRY,LC1 ,T)*PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)* YLDINAC(CTRY,LC1,A1,T))]$(TROPINAC(CTRY,LC1) EQ 1)
;

*quantity of pulpwood harvested globally
PARAMETER TAFP(T);
TAFP(T) = SUM(CTRY,QFP(CTRY ,T));

*global price of pulpwood
PARAMETER FPP(T);
FPP(T) = {AFP(T)**(1/BF)}*{((TAFP(T)/PULPADJUST)+EPSILON)**(-1/BF)};

DISPLAY QFS, TAFS, FPS, QFP, TAFP, FPP;

*timber harvested in accessible forest types by region
PARAMETER QFACCESS(CTRY,T);
QFACCESS(CTRY,T) =
***********************************************************************
*accessible timber for roundwood
SUM[LC1$(R1FOR(CTRY,LC1) EQ 1),
SUM(A1, ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))];

*accessible timber for bioenergy
PARAMETER QBACCESS(CTRY,T);
QBACCESS(CTRY,T) =

SUM[LC1$(R1FOR(CTRY,LC1) EQ 1),
SUM(A1, ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))];
***********************************************************************
***********************************************************************
PARAMETER QFTEMPINAC(CTRY,T);
QFTEMPINAC(CTRY,T) =
*temperate semi-inaccessible
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),
SUM(A1, ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+
***********************************************************************
*temperate inaccessible - harvest 50 years of age
SUM[LC1$(TEMPINAC(CTRY,LC1) EQ 1),
        PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)*
       YIELD2(CTRY,LC1,A1,T))];
***********************************************************************
PARAMETER QFTROPINAC(CTRY,T);
QFTROPINAC(CTRY,T) =
*tropical semi-inaccessible
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1,ACHR2.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]+
*tropical low harvest
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1,ACHR3.L(CTRY,LC1,A1,T)*YIELD2(CTRY,LC1,A1,T)*0.5*PARAM2(CTRY,LC1,'8'))]+
*tropical inacessible - harvest 50 years of age
SUM[LC1$(TROPINAC(CTRY,LC1) EQ 1),
        PARAM2(CTRY,LC1,'8')*SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)*YLDINAC(CTRY,LC1,A1,T))]
;


PARAMETER TEMPINACHA(CTRY ,T);
TEMPINACHA(CTRY ,T) = SUM(LC1$(TEMPINAC(CTRY,LC1) EQ 1),
        SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)));

PARAMETER TEMPSEMIACHA(CTRY ,T);
TEMPSEMIACHA(CTRY ,T) = SUM(LC1$(TEMPINAC(CTRY,LC1) EQ 1),
        SUM(A1,YACRE2.L(CTRY,LC1,A1,T)));

PARAMETER TROPINACHA(CTRY ,T);
TROPINACHA(CTRY ,T) = SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)));

PARAMETER TROPSEMIACHA(CTRY ,T);
TROPSEMIACHA(CTRY ,T) = SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1,YACRE2.L(CTRY,LC1,A1,T)))+
 SUM(LC1$(TROPINAC(CTRY,LC1) EQ 1),
        SUM(A1,YACRE3.L(CTRY,LC1,A1,T)));

PARAMETER SUBTRPLT(CTRY,T);
SUBTRPLT(CTRY,T)= SUM(LC1$(PARAM3(CTRY,LC1,'1') EQ 1),
        SUM(A1,YACRE2.L(CTRY,LC1,A1,T)));

PARAMETER FORACI1(CTRY,T);
FORACI1(CTRY,T) = SUM(LC1, SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)));

PARAMETER TFOREST(CTRY,T);
TFOREST(CTRY,T)= SUM(LC1,SUM(A1,YACRE2.L(CTRY,LC1,A1,T)))+ SUM(LC1,SUM(A1,YACRE3.L(CTRY,LC1,A1,T)))+
        SUM(LC1, SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)));

PARAMETER TFORESTLC(CTRY,LC1,T);
TFORESTLC(CTRY,LC1,T)= SUM(A1,YACRE2.L(CTRY,LC1,A1,T))+ SUM(A1,YACRE3.L(CTRY,LC1,A1,T)+
YACRIN1.L(CTRY,LC1 ,A1,T));

PARAMETER ALLTIMBER(T);
ALLTIMBER(T)= SUM(CTRY,
SUM(LC1,SUM(A1,YACRE2.L(CTRY,LC1,A1,T)))+ FORACI1(CTRY,T));

*******************************************************************************
*PRINT OUTPUT TO PUT FILE AND DO CARBON CALCULATIONS BELOW
*******************************************************************************

SET RC /1*13/;

PARAMETER PANDQ(RC,T);
PANDQ(RC,T) = FPS(T)$(ORD(RC) EQ 1) + TAFS(T)$(ORD(RC) EQ 2) +
FPP(T)$(ORD(RC) EQ 3) + TAFP(T)$(ORD(RC) EQ 4);


FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT 'HARVESTS (MMm3/dec) AND PRICE (2010 US $/m3)';
PUT / 'YEAR';
PUT 'TIMBER PRICE';
PUT 'TIMBER QUANTITY';
PUT 'PULP PRICE';
PUT 'PULP QUANTITY';
PUT '';
LOOP(T, PUT / T.TE(T);LOOP(RC, PUT PANDQ(RC,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONALM SAWTIMBER HARVESTS - INCLUDING INACCESSIBLE but NOT TIMBER FOR BIOMASS (MMm3/dec)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT QFS(CTRY,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONALM PULP HARVESTS - INCLUDING INACCESSIBLE but NOT TIMBER FOR BIOMASS (MMm3/dec)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT QFP(CTRY,T)););



FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL HARVESTS - ACCESSIBLE (MMm3/dec)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT QFACCESS(CTRY,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL HARVESTS - TEMPERATE INACCESSIBLE (MMm3/dec)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT QFTEMPINAC(CTRY,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL HARVESTS - TROPICAL INACCESSIBLE (MMm3/dec)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT QFTROPINAC(CTRY,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL HECTARES -TOTAL (Million)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TFOREST(CTRY,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL TEMPERATE INACCESSIBLE HECTARES -TOTAL (Million)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TEMPINACHA(CTRY ,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL TEMPERATE SEMI-ACCESSIBLE HECTARES -TOTAL (Million)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TEMPSEMIACHA(CTRY ,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL TROPICAL INACCESSIBLE HECTARES -TOTAL (Million)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TROPINACHA(CTRY ,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL TROPICAL SEMI-ACCESSIBLE HECTARES -TOTAL (Million)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TROPSEMIACHA(CTRY ,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL SUBTROPICAL PLANTATION HECTARES -TOTAL (Million)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT SUBTRPLT(CTRY,T)););

PARAMETER DEDBIOAREALC(CTRY,LC1,T);
DEDBIOAREALC(CTRY,LC1,T)$(DEDBIO(CTRY,LC1) EQ 1) =
SUM(A1,YACRE2.L(CTRY,LC1,A1,T)$(DEDBIO(CTRY,LC1) EQ 1));

PARAMETER DEDBIOAREA(CTRY,T);
DEDBIOAREA(CTRY,T)=SUM(LC1,DEDBIOAREALC(CTRY,LC1,T));

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL DEDICATED BIOFUEL CROPS (Million)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT DEDBIOAREA(CTRY,T)););

PARAMETER QFACCUS(LC1,T);
QFACCUS(LC1,T) =

*accessible timber
SUM(A1,ACHR2.L('1',LC1,A1,T)*YIELD2('1',LC1,A1,T)*PARAM2('1',LC1,'8')*
       ((1+MGMT1.L('1',LC1,A1,T))**FINPTEL('1',LC1,T)));

PARAMETER QFINACUS(LC1,T);
QFINACUS(LC1,T) =
*temperate semi-inaccessible
SUM(A1,ACHR2.L('1',LC1,A1,T)*YIELD2('1',LC1,A1,T)*PARAM2('1',LC1,'8')*
       ((1+MGMT1.L('1',LC1,A1,T))**FINPTEL('1',LC1,T)))$(TEMPINAC('1',LC1) EQ 1)+

PARAM2('1',LC1,'8')*SUM(A1,ACHRIN1.L('1',LC1,A1,T)*YLDINAC('1',LC1,A1,T));

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US SAWTIMBER OUTPUT';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) LT 26), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) LT 26), PUT QFSLC('1',LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US SAWTIMBER OUTPUT INACCESSIBLE';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 25), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 25), PUT QFSLC('1',LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US SAWTIMBER OUTPUT INACCESSIBLE';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 50), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 50), PUT QFSLC('1',LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US PULPWOOD OUTPUT';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) LT 26), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) LT 26), PUT QFPLC('1',LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US PULPWOOD OUTPUT INACCESSIBLE';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 25), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 25), PUT QFPLC('1',LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US PULPWOOD OUTPUT INACCESSIBLE';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 50), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 50), PUT QFPLC('1',LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US ACCESSIBLE OUTPUT';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) LT 26), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) LT 26), PUT QFACCUS(LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US ACCESSIBLE OUTPUT';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 25), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 25), PUT QFACCUS(LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US ACCESSIBLE OUTPUT';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 50), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 50), PUT QFACCUS(LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US INACCESSIBLE OUTPUT';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) LT 26), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) LT 26), PUT QFINACUS(LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US INACCESSIBLE OUTPUT';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 25), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 25), PUT QFINACUS(LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US INACCESSIBLE OUTPUT';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 50), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 50), PUT QFINACUS(LC1,T)););


*******************************************************************************
* OUTPUT HECTARES BY US FOREST TYPE
*******************************************************************************

PARAMETER TUSFORESTACC(LC1,T);
TUSFORESTACC(LC1,T)= SUM(A1,YACRE2.L('1',LC1,A1,T));

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US HECTARES BY FOREST TYPE - ACCESSIBLE (Million)';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) LT 26), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) LT 26), PUT TUSFORESTACC(LC1,T)););

PARAMETER TUSFORESTINACC(LC1,T);
TUSFORESTINACC(LC1,T)= SUM(A1,YACRIN1.L('1',LC1,A1,T));

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US HECTARES BY FOREST TYPE - INACCESSIBLE (Million)';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 25) , PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1, PUT TUSFORESTINACC(LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US HECTARES BY FOREST TYPE - INACCESSIBLE (Million)';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 50), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 50), PUT TUSFORESTINACC(LC1,T)););

PARAMETER TUSFORESTSEMACC(LC1,T);
TUSFORESTSEMACC(LC1,T)= SUM(A1,YACRE2.L('1',LC1,A1,T)$(TEMPINAC('1',LC1) EQ 1));

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US HECTARES BY FOREST TYPE - SEMI ACCESSIBLE (Million)';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 50), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1, PUT TUSFORESTSEMACC(LC1,T)););

FILE GLOBALTIMBERMODEL2020; PUT GLOBALTIMBERMODEL2020; GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US HECTARES IN DEDICATED BIOMASS ENERGY (Million)';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) LT 25), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1, PUT DEDBIOAREALC('1',LC1,T)););


*******************************************************************************
*******************************************************************************
* CARBON ACCOUNTING AND CARBON OUTPUTS
*******************************************************************************
*******************************************************************************

*carbon yield functions – use original yield functions.
PARAMETER CYIELD (CTRY, LC1,A1,T) yield function;
CYIELD(CTRY,LC1,A1,T) = YIELDORIG(CTRY,LC1,A1,T);

PARAMETER CYA (CTRY,LC1,A1,T);
CYA(CTRY,LC1,A1,T) = CYIELD(CTRY,LC1,A1,T);

CYIELD(CTRY,LC1,A1,T) = CYA(CTRY,LC1,A1,T)$(ORD(A1) LT 10) + 
	CYA(CTRY,LC1,'10',T)$(ORD(A1) GT 9);

*adjust tropical plantation types so not too much accumulation beyond MSA
*****************************
PARAMETER CADJTROP(CTRY,LC1);
CADJTROP(CTRY,LC1) = 1$(ORD(CTRY) EQ 3) + 1$(ORD(CTRY) EQ 8) + 1$(ORD(CTRY) EQ 9) + 1$(ORD(CTRY) EQ 10) + 1$(ORD(CTRY) EQ 11) + 1$(ORD(CTRY) EQ 12);

CADJTROP(CTRY,LC1)=CADJTROP(CTRY,LC1)*PARAM3(CTRY,LC1,'1');

LOOP(A1,
CYIELD(CTRY,LC1,A1,T)$(CADJTROP(CTRY,LC1) EQ 1) = 
CYA(CTRY,LC1,A1,T)$(ORD(A1) LT (PARAM2(CTRY,LC1,'11')+1)) + 
	CYIELD(CTRY,LC1,A1-1,T)$(ORD(A1) GT PARAM2(CTRY,LC1,'11'))
);
*****************************

PARAMETER CYLDINAC(CTRY,LC1,A1,T);
CYLDINAC(CTRY,LC1,A1,T) = CYIELD(CTRY,LC1,A1,T)$(ORD(A1) LT 10) + 
	CYIELD(CTRY,LC1,'10',T)$(ORD(A1) GT 9);


****    Standing Timber calculated with Smith, Heath et al, for US ****
*
*       Live-tree mass density = F · (G + (1-e(-volume/H)))
*********************************************************

PARAMETER ABVCHEATH(CTRY,LC1,T);
ABVCHEATH(CTRY,LC1,T) =

0.5*
[
SUM(A1, YACRE2.L(CTRY,LC1,A1,T)*

CPARAM2(CTRY,LC1,'11')*
(
CPARAM2(CTRY,LC1,'12') +
(1-EXP(-CYIELD(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,A1,T)+1+EPSILON)**FINPTEL(CTRY,LC1,T))/
CPARAM2(CTRY,LC1,'13'))
)
)

)
]

+

*temperate inaccessible TYPES A &B

0.5*
[
SUM(A1,
YACRIN1.L(CTRY,LC1,A1,T)*
CPARAM2(CTRY,LC1,'11')*
(
CPARAM2(CTRY,LC1,'12') +
(1-EXP(-CYLDINAC(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')/
CPARAM2(CTRY,LC1,'13'))
)
)

)
]

+

*tropical semi-inaccessible type
[CPARAM2(CTRY,LC1,'3')*SUM(A1,YACRE2.L(CTRY,LC1,A1,T)*CYIELD(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*
((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]$(TROPINAC(CTRY,LC1) EQ 1)
+

*tropical low management type
[CPARAM2(CTRY,LC1,'3')*SUM(A1,YACRE3.L(CTRY,LC1,A1,T)*CYIELD(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8'))] $(TROPINAC(CTRY,LC1) EQ 1)
+

*tropical inaccessible type
[CPARAM2(CTRY,LC1,'3')*PARAM2(CTRY,LC1,'8')*SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)*
CYLDINAC(CTRY,LC1,A1,T))] $(TROPINAC(CTRY,LC1) EQ 1)
;

****    Standing Dead Timber calculated with Smith, Heath et al, for US ****
*
*       Live-tree mass density = F · (G + (1-e(-volume/H)))
* Dead-tree mass density = (Estimated live-tree mass density) · A · e(-((volume/B)^C))

*********************************************************

PARAMETER ABVDEADCHEATH(CTRY,LC1,T);
ABVDEADCHEATH(CTRY,LC1,T) =

0.5*
[
SUM(A1, YACRE2.L(CTRY,LC1,A1,T)*


{
CPARAM2(CTRY,LC1,'11')*
(
CPARAM2(CTRY,LC1,'12') +
(1-EXP(-CYIELD(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,A1,T)+1+EPSILON)**FINPTEL(CTRY,LC1,T))/
CPARAM2(CTRY,LC1,'13'))
)
)}*
CPARAM2(CTRY,LC1,'24')*
EXP(-((
PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,A1,T)+1+EPSILON)**FINPTEL(CTRY,LC1,T))/ CPARAM2(CTRY,LC1,'25'))**CPARAM2(CTRY,LC1,'26')))

)
]

+

*temperate inaccessible TYPES A &B

0.5*
[
SUM(A1,
YACRIN1.L(CTRY,LC1,A1,T)*

{CPARAM2(CTRY,LC1,'11')*
(
CPARAM2(CTRY,LC1,'12') +
(1-EXP(-CYLDINAC(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')/
CPARAM2(CTRY,LC1,'13'))
)
)}*
CPARAM2(CTRY,LC1,'24')*
EXP(-((
PARAM2(CTRY,LC1,'8')*CYLDINAC(CTRY,LC1,A1,T)/ CPARAM2(CTRY,LC1,'25'))**CPARAM2(CTRY,LC1,'26')))

)
]

*The calculations for tropical areas are incorrect and would need to be updated if used.
+

*tropical semi-inaccessible type
[CPARAM2(CTRY,LC1,'3')*SUM(A1,YACRE2.L(CTRY,LC1,A1,T)*CYIELD(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*
((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]$(TROPINAC(CTRY,LC1) EQ 1)
+

*tropical low management type
[CPARAM2(CTRY,LC1,'3')*SUM(A1,YACRE3.L(CTRY,LC1,A1,T)*CYIELD(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8'))] $(TROPINAC(CTRY,LC1) EQ 1)
+

*tropical inaccessible type
[CPARAM2(CTRY,LC1,'3')*PARAM2(CTRY,LC1,'8')*SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)*
CYLDINAC(CTRY,LC1,A1,T))] $(TROPINAC(CTRY,LC1) EQ 1)
;


*     *********** Standing Timber ***********
*calculated with IPCC methods per GPG for rest of world
* C = V*D*BEF*(1+R)*CF

*V = m3/ha
*D = wood density (parameter 14)
*BEF = biomass expansion factor (parameter 15)
*R = root/shoot ratio (parameter 16)
*CF= carbon % = 0.5 (parameter 17)
****************************************


PARAMETER ABVCACRGPG(CTRY,LC1,T);
ABVCACRGPG(CTRY,LC1,T) =

CPARAM2(CTRY,LC1,'14')*CPARAM2(CTRY,LC1,'15')*(1+CPARAM2(CTRY,LC1,'16'))*
CPARAM2(CTRY,LC1,'17')*[SUM(A1, YACRE2.L(CTRY,LC1,A1,T)*CYIELD(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,A1,T)+1+EPSILON)**FINPTEL(CTRY,LC1,T)))] $(R1FOR(CTRY,LC1) EQ 1)
+


CPARAM2(CTRY,LC1,'14')*CPARAM2(CTRY,LC1,'15')*(1+CPARAM2(CTRY,LC1,'16'))*
CPARAM2(CTRY,LC1,'17')*[SUM(A1, YACRE2.L(CTRY,LC1,A1,T)*CYLDINAC(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,A1,T)+1+EPSILON)**FINPTEL(CTRY,LC1,T)))] $(TEMPINAC(CTRY,LC1) EQ 1)
+

*temperate inaccessible TYPE A
[
CPARAM2(CTRY,LC1,'14')*CPARAM2(CTRY,LC1,'15')*(1+CPARAM2(CTRY,LC1,'16'))*
CPARAM2(CTRY,LC1,'17')*
SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)*CYLDINAC(CTRY,LC1,A1,T))*
PARAM2(CTRY,LC1,'8')]$(R1FOR(CTRY,LC1) EQ 1)
+

*temperate inaccessible type B
[
CPARAM2(CTRY,LC1,'14')*CPARAM2(CTRY,LC1,'15')*(1+CPARAM2(CTRY,LC1,'16'))*
CPARAM2(CTRY,LC1,'17')*PARAM2(CTRY,LC1,'8')*
SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)*
        CYLDINAC(CTRY,LC1,A1,T))]$(TEMPINAC(CTRY,LC1) EQ 1)
+

*tropical semi-inaccessible type
*use CYLDINAC to limit yield increases past 100
[
CPARAM2(CTRY,LC1,'14')*CPARAM2(CTRY,LC1,'15')*(1+CPARAM2(CTRY,LC1,'16'))*
CPARAM2(CTRY,LC1,'17')*SUM(A1,YACRE2.L(CTRY,LC1,A1,T)*CYLDINAC(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*
((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))]$(TROPINAC(CTRY,LC1) EQ 1)
+

*tropical low management type
*use CYLDINAC to limit yield increases past 100
[
CPARAM2(CTRY,LC1,'14')*CPARAM2(CTRY,LC1,'15')*(1+CPARAM2(CTRY,LC1,'16'))*
CPARAM2(CTRY,LC1,'17')*SUM(A1,YACRE3.L(CTRY,LC1,A1,T)*CYLDINAC(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8'))] $(TROPINAC(CTRY,LC1) EQ 1)
+

*tropical inaccessible type
*use CYLDINAC to limit yield increases past 100
 [
CPARAM2(CTRY,LC1,'14')*CPARAM2(CTRY,LC1,'15')*(1+CPARAM2(CTRY,LC1,'16'))*
CPARAM2(CTRY,LC1,'17')*PARAM2(CTRY,LC1,'8')*
SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)*CYLDINAC(CTRY,LC1,A1,T))] $(TROPINAC(CTRY,LC1) EQ 1)
;


**** Standing Timber calculated with Smith, Heath et al, for US ****
*       calculated for each age class
*       Live-tree mass density = F · (G + (1-e(-volume/H)))
*********************************************************

PARAMETER ABVCHEATHAGE(CTRY,LC1,A1,T);
ABVCHEATHAGE(CTRY,LC1,A1,T) =

0.5*
[
 YACRE2.L(CTRY,LC1,A1,T)*

CPARAM2(CTRY,LC1,'11')*
(
CPARAM2(CTRY,LC1,'12') +
(1-EXP(-CYIELD(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,A1,T)+1+EPSILON)**FINPTEL(CTRY,LC1,T))/
CPARAM2(CTRY,LC1,'13'))
)
)
]



+
*temperate inaccessible TYPES A & b
0.5*
[
YACRIN1.L(CTRY,LC1,A1,T)*

CPARAM2(CTRY,LC1,'11')*
(
CPARAM2(CTRY,LC1,'12') +
(
1-EXP(-CYLDINAC(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')/
CPARAM2(CTRY,LC1,'13'))
)
)
]$(ORD(A1) EQ CARD(A1))

;

PARAMETER ABVHEATHBYHA(CTRY,LC1,A1,T);
ABVHEATHBYHA(CTRY,LC1,A1,T) =
ABVCHEATHAGE(CTRY,LC1,A1,T)/(
YACRE2.L(CTRY,LC1,A1,T)+YACRIN1.L(CTRY,LC1,A1,T)+EPSILON);



*     *********** Standing Timber ***********

* aboveground carbon
* calculated the original way

****************************************


PARAMETER ABVCACRAGE(CTRY,LC1,A1,T);
ABVCACRAGE(CTRY,LC1,A1,T) =

CPARAM2(CTRY,LC1,'3')*[YACRE2.L(CTRY,LC1,A1,T)*CYIELD(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,A1,T)+1+EPSILON)**FINPTEL(CTRY,LC1,T))] $(R1FOR(CTRY,LC1) EQ 1)
+

*tropical semi-inaccessible type
[CPARAM2(CTRY,LC1,'3')*YACRE2.L(CTRY,LC1,A1,T)*CYLDINAC(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*
((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T))]$(TROPINAC(CTRY,LC1) EQ 1)
+

*tropical low management type
[CPARAM2(CTRY,LC1,'3')*YACRE3.L(CTRY,LC1,A1,T)*CYLDINAC(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')] $(TROPINAC(CTRY,LC1) EQ 1)
;



*******************************************************************************
*Litter
*******************************************************************************

R1FOR(CTRY,'24') =0;

PARAMETER LITTERACCAGE(CTRY,LC1,A1,T);
LITTERACCAGE(CTRY,LC1,A1,T)$(R1FOR(CTRY,LC1) EQ 1) = YACRE2.L(CTRY,LC1,A1,T)*CPARAM2(CTRY,LC1,'28')*
[CYIELD(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,A1,T)+1+EPSILON)**FINPTEL(CTRY,LC1,T))]/
[EPSILON+CYIELD(CTRY,LC1,'15',T)*PARAM2(CTRY,LC1,'8')*((MGMT1.L(CTRY,LC1,'15',T)+1+EPSILON)**FINPTEL(CTRY,LC1,T))]$(R1FOR(CTRY,LC1) EQ 1);

PARAMETER LITTERINACCAGE(CTRY,LC1,A1,T);
LITTERINACCAGE(CTRY,LC1,A1,T) =

{[CPARAM2(CTRY,LC1,'28')*YACRE2.L(CTRY,LC1,A1,T)*CYIELD(CTRY,LC1,A1,T)]/
[EPSILON + CYIELD(CTRY,LC1,'15',T)]}$(TEMPINAC(CTRY,LC1) EQ 1)

+


*temperate inaccessible TYPE A
{[CPARAM2(CTRY,LC1,'28')*
YACRIN1.L(CTRY,LC1,A1,T)*CYLDINAC(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')]/[EPSILON+CYLDINAC(CTRY,LC1,'15',T)]}$(R1FOR(CTRY,LC1) EQ 1)
+

*temperate inaccessible type B
{[CPARAM2(CTRY,LC1,'28')*PARAM2(CTRY,LC1,'8')*
YACRIN1.L(CTRY,LC1,A1,T)*
        CYLDINAC(CTRY,LC1,A1,T)]/[EPSILON+YLDINAC(CTRY,LC1,'15',T)]}$(TEMPINAC(CTRY,LC1) EQ 1);



PARAMETER LITTERSUMLC(CTRY,LC1,T);
LITTERSUMLC(CTRY,LC1,T) = SUM(A1,LITTERACCAGE(CTRY,LC1,A1,T)+ LITTERINACCAGE(CTRY,LC1,A1,T));

PARAMETER LITTERSUM(CTRY,T);
LITTERSUM(CTRY,T) = SUM(LC1,LITTERSUMLC(CTRY,LC1,T));



*******************************************************************************
* total aboveground carbon using Heath estimates for US and IPCC GPG for rest of world
*******************************************************************************



PARAMETER TABVCR(CTRY,T);
TABVCR(CTRY,T)=SUM(LC1, ABVCHEATH(CTRY,LC1,T)$(ORD(CTRY) EQ 1) +
                               ABVCACRGPG(CTRY,LC1,T)$(ORD(CTRY) GT 1));

PARAMETER TABVCRDEAD(CTRY,T);
TABVCRDEAD(CTRY,T)=SUM(LC1, ABVDEADCHEATH(CTRY,LC1,T)$(ORD(CTRY) EQ 1) +
                ABVCACRGPG(CTRY,LC1,T)*CPARAM2(CTRY,LC1,'27')$(ORD(CTRY) GT 1));


PARAMETER TABVCLIVEANDDEAD(CTRY,T);
TABVCLIVEANDDEAD(CTRY,T)= TABVCR(CTRY,T)+ TABVCRDEAD(CTRY,T);

*allocate US estimates to regions in US for reporting purposes.
PARAMETER TABVUS(DATA,T);
TABVUS('1',T)= SUM(LC1,(ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(ORD(LC1) LT 26));
TABVUS('2',T)= SUM(LC1, (ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(ORD(LC1) LT 59))-TABVUS('1',T);
TABVUS('3',T)= SUM(LC1, (ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(ORD(LC1) GT 58));


PARAMETER SOUTH(T);
PARAMETER NORTH(T);
PARAMETER PNW(T);
PARAMETER WEST(T);
PARAMETER AK(T);
PARAMETER OTHER(T);


SOUTH(T) = SUM(LC1, (ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(PARAM3('1',LC1,'21') EQ 1));
NORTH(T) = SUM(LC1, (ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(PARAM3('1',LC1,'21') EQ 2));
PNW(T) = SUM(LC1, (ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(PARAM3('1',LC1,'21') EQ 3));
WEST(T) = SUM(LC1, (ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(PARAM3('1',LC1,'21') EQ 4));
AK(T) = SUM(LC1, (ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(PARAM3('1',LC1,'21') EQ 5));
OTHER(T) = SUM(LC1, (ABVCHEATH('1',LC1,T)+ ABVDEADCHEATH('1',LC1,T))$(PARAM3('1',LC1,'21') EQ 6));

TABVUS('5',T)=SOUTH(T);
TABVUS('6',T)=NORTH(T);
TABVUS('7',T)=PNW(T);
TABVUS('8',T)=WEST(T);
TABVUS('9',T)=AK(T);
TABVUS('10',T)=OTHER(T);



*******************************************************************************
*Harvested Timber
*******************************************************************************

PARAMETER MKTC(CTRY,LC1,T);
MKTC(CTRY,LC1,T)=
QFPLC(CTRY,LC1,T)*CPARAM2(CTRY,LC1,'4') +
QFSLC(CTRY,LC1,T)*CPARAM2(CTRY,LC1,'4');


*total market carbon
PARAMETER TMKTC(CTRY,T);
TMKTC(CTRY,T)=SUM(LC1, MKTC(CTRY,LC1,T));


*******************************************************************************
* Slash pool
* Calculate what remains on site after removal of harvested material
*ANNSLASHC = annual additions to slash pool
*SLASHCPOOL = slash pool
*Slash decay rate is region specific using CPARAM2(data=9)
*******************************************************************************

*annual slash contribution
PARAMETER ANNSLASHC(CTRY,LC1,T);
ANNSLASHC(CTRY,LC1,T)=
MKTC(CTRY,LC1,T)*CPARAM2(CTRY,LC1,'23');

*accumulate historical slash pool for initial slash quantity
PARAMETER INITSLASHCPOOL(CTRY,LC1,TS);
PARAMETER INITSLASHC(CTRY,LC1);

INITSLASHCPOOL(CTRY,LC1,'1') = ANNSLASHC(CTRY,LC1,'1');
INITSLASHC(CTRY,LC1)= ANNSLASHC(CTRY,LC1,'1');

LOOP(TS, INITSLASHCPOOL(CTRY,LC1,TS+1)= INITSLASHC(CTRY,LC1) + INITSLASHCPOOL(CTRY,LC1,TS)-
10*CPARAM2(CTRY,LC1,'9')*INITSLASHCPOOL(CTRY,LC1,TS));

DISPLAY INITSLASHCPOOL;

PARAMETER SLASHCPOOL(CTRY,LC1,T);
SLASHCPOOL(CTRY,LC1,'1') = INITSLASHCPOOL(CTRY,LC1,'15');
LOOP(T,SLASHCPOOL(CTRY,LC1,T+1)= ANNSLASHC(CTRY,LC1,T) + SLASHCPOOL(CTRY,LC1,T) - 10*CPARAM2(CTRY,LC1,'9')*SLASHCPOOL(CTRY,LC1,T));

PARAMETER SLASHCPOOL2(CTRY,T);
SLASHCPOOL2(CTRY,T) = SUM(LC1,SLASHCPOOL(CTRY,LC1,T));

PARAMETER ANNSLASHCCTRY(CTRY,T);
ANNSLASHCCTRY(CTRY,T) = SUM(LC1, ANNSLASHC(CTRY,LC1,T));

PARAMETER ANNRESCTRY(CTRY,T);
*ANNRESCTRY(CTRY,T) = SUM(LC1,SUM(A1,CPARAM2(CTRY,LC1,'4')*RES.L(CTRY,LC1,A1,T)));
ANNRESCTRY(CTRY,T) = 0;

$ONTEXT;
Set up storage in wood products pool.  Start by initializing stock from historical storage.
$OFFTEXT;

PARAMETER INITPULPCPOOL(CTRY,LC1,TS);
INITPULPCPOOL(CTRY,LC1,'1') =0;

PARAMETER INITPULPC(CTRY,LC1);
INITPULPC(CTRY,LC1) = CPARAM2(CTRY,LC1,'4')*(1-CPARAM2(CTRY,LC1,'20'))*QFPLC(CTRY,LC1,'1');

LOOP(TS, INITPULPCPOOL(CTRY,LC1,TS)= INITPULPC(CTRY,LC1)+
INITPULPCPOOL(CTRY,LC1,TS-1)-
10*CPARAM2(CTRY,LC1,'21')*INITPULPCPOOL(CTRY,LC1,TS-1));

PARAMETER PULPSTORE(CTRY,LC1,T);
PULPSTORE(CTRY,LC1,'1') = INITPULPCPOOL(CTRY,LC1,'15');

LOOP(T, PULPSTORE(CTRY,LC1,T+1) = PULPSTORE(CTRY,LC1,T) +
CPARAM2(CTRY,LC1,'4')*(1-CPARAM2(CTRY,LC1,'20'))*QFPLC(CTRY,LC1,T)
- 10*CPARAM2(CTRY,LC1,'21')*PULPSTORE(CTRY,LC1,T));


*SET UP STORAGE OF C STOCK IN WOOD PRODUCTS FOR SOLIDWOOD

PARAMETER INITSOLIDCPOOL(CTRY,LC1,TS);
INITSOLIDCPOOL(CTRY,LC1,'1') =0;

PARAMETER INITSOLIDC(CTRY,LC1);
INITSOLIDC(CTRY,LC1)=
CPARAM2(CTRY,LC1,'4')*(1-CPARAM2(CTRY,LC1,'20'))*QFSLC(CTRY,LC1,'1');


LOOP(TS, INITSOLIDCPOOL(CTRY,LC1,TS)= INITSOLIDC(CTRY,LC1) + INITSOLIDCPOOL(CTRY,LC1,TS-1)-
10*CPARAM2(CTRY,LC1,'22')*INITSOLIDCPOOL(CTRY,LC1,TS-1));

PARAMETER SOLIDSTORE(CTRY,LC1,T);
SOLIDSTORE(CTRY,LC1,'1') =INITSOLIDCPOOL(CTRY,LC1,'15');

LOOP(T, SOLIDSTORE(CTRY,LC1,T+1) = SOLIDSTORE(CTRY,LC1,T)+
CPARAM2(CTRY,LC1,'4')*(1-CPARAM2(CTRY,LC1,'20'))*QFSLC(CTRY,LC1,T)
- 10*CPARAM2(CTRY,LC1,'22')*SOLIDSTORE(CTRY,LC1,T));


*total annual market carbon
PARAMETER TMKTC(CTRY,T);
TMKTC(CTRY,T)=SUM(LC1, MKTC(CTRY,LC1,T));

*total stock of market carbon
PARAMETER TMKTCNEW(CTRY,T);
TMKTCNEW(CTRY,T) = SUM(LC1,PULPSTORE(CTRY,LC1,T) + SOLIDSTORE(CTRY,LC1,T));

DISPLAY TMKTC, TMKTCNEW;


*calculate soil carbon
*   ************** TEMPERATE ***************
*cumulative net change in hectares in R1FOR and type YACRE2

PARAMETER CCNAC1(CTRY,LC1,T);
CCNAC1(CTRY,LC1,'1')=0;
LOOP(T,CCNAC1(CTRY,LC1,T+1)$(R1FOR(CTRY,LC1) EQ 1) =
ACPL2.L(CTRY,LC1,T) - SUM(A1,ACHR2.L(CTRY,LC1,A1,T)+ACHRIN1.L(CTRY,LC1,A1,T))+
       CCNAC1(CTRY,LC1,T));

PARAMETER CUMNAC1(CTRY,LC1,TS,T);
CUMNAC1(CTRY,LC1,'1',T)$(R1FOR(CTRY,LC1) EQ 1) = MAX[0,CCNAC1(CTRY,LC1,T)-CCNAC1(CTRY,LC1,T-1)];
LOOP(T,CUMNAC1(CTRY,LC1,TS+1,T+1)$(R1FOR(CTRY,LC1) EQ 1) = CUMNAC1(CTRY,LC1,TS,T)) ;

DISPLAY CCNAC1, CUMNAC1;

PARAMETER SOLC1(CTRY,LC1,TS);
SOLC1(CTRY,LC1,TS)=0;
SOLC1(CTRY,LC1,'1')$(R1FOR(CTRY,LC1) EQ 1) = CPARAM2(CTRY,LC1,'6');

DISPLAY SOLC1;

LOOP(TS,SOLC1(CTRY,LC1,TS+1)$(R1FOR(CTRY,LC1) EQ 1) =
SOLC1(CTRY,LC1,TS)*CPARAM2(CTRY,LC1,'7')*[(CPARAM2(CTRY,LC1,'5')-SOLC1(CTRY,LC1,TS))/SOLC1(CTRY,LC1,TS)]+SOLC1(CTRY,LC1,TS));

DISPLAY SOLC1;

PARAMETER SOLCC1(CTRY,LC1,TS,T);
SOLCC1(CTRY,LC1,TS,T)$(R1FOR(CTRY,LC1) EQ 1) =
(SOLC1(CTRY,LC1,TS)-CPARAM2(CTRY,LC1,'6'))*CUMNAC1(CTRY,LC1,TS,T);

DISPLAY SOLCC1;

PARAMETER SOILC1(CTRY,LC1,T);
SOILC1(CTRY,LC1,T)$(R1FOR(CTRY,LC1) EQ 1) = SUM(TS,SOLCC1(CTRY,LC1,TS,T));

DISPLAY SOILC1;

*count lost carbon in land lost, count only the NPV of lost carbon
PARAMETER CSOILR1(CTRY,LC1,T);
CSOILR1(CTRY,LC1,T)$(R1FOR(CTRY,LC1) EQ 1) = CPARAM2(CTRY,LC1,'5')*SUM(A1,FORINV2(CTRY,LC1,A1))+
SOILC1(CTRY,LC1,T)+
CPARAM2(CTRY,LC1,'8')*MIN[CCNAC1(CTRY,LC1,T),0];

DISPLAY CSOILR1;

*  ********* TEMPERATE TYPE B *********************
*cumulative net change in hectares in TEMPINAC and type B inaccessible temperate, YACRIN
PARAMETER CSOILT1(CTRY,LC1,T);
CSOILT1(CTRY,LC1,T)$(TEMPINAC(CTRY,LC1) EQ 1) =
CPARAM2(CTRY,LC1,'5')*(SUM(A1,YACRE2.L(CTRY,LC1,A1,T)+YACRIN1.L(CTRY,LC1,A1,T)))



*  ******* TROPICAL SEMI-ACCESSIBLE ******************
*cumulative net change in hectares in TROPINAC and type YACRE2, ACPL6
*YACRE3 AND ACPL5, IFORIN2, YACRIN2

PARAMETER CCNAC1(CTRY,LC1,T);
CCNAC1(CTRY,LC1,'1')=0;
LOOP(T,CCNAC1(CTRY,LC1,T+1)$(TROPINAC(CTRY,LC1) EQ 1) =
ACPL6.L(CTRY,LC1,T)+ ACPL5.L(CTRY,LC1,T)-
SUM(A1,ACHR2.L(CTRY,LC1,A1,T))- SUM(A1,ACHR3.L(CTRY,LC1,A1,T))-
SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T))
+CCNAC1(CTRY,LC1,T));

PARAMETER CUMNAC1(CTRY,LC1,TS,T);
CUMNAC1(CTRY,LC1,'1',T)$(TROPINAC(CTRY,LC1) EQ 1) = MAX[0,CCNAC1(CTRY,LC1,T)-CCNAC1(CTRY,LC1,T-1)];
LOOP(T,CUMNAC1(CTRY,LC1,TS+1,T+1)$(TROPINAC(CTRY,LC1) EQ 1) = CUMNAC1(CTRY,LC1,TS,T)) ;

DISPLAY CCNAC1, CUMNAC1;

PARAMETER SOLC1(CTRY,LC1,TS);
SOLC1(CTRY,LC1,TS)=0;
SOLC1(CTRY,LC1,'1')$(TROPINAC(CTRY,LC1) EQ 1) = CPARAM2(CTRY,LC1,'6');

DISPLAY SOLC1;

LOOP(TS,SOLC1(CTRY,LC1,TS+1)$(TROPINAC(CTRY,LC1) EQ 1) =
SOLC1(CTRY,LC1,TS)*CPARAM2(CTRY,LC1,'7')*[(CPARAM2(CTRY,LC1,'5')-SOLC1(CTRY,LC1,TS))/SOLC1(CTRY,LC1,TS)]+SOLC1(CTRY,LC1,TS));

DISPLAY SOLC1;

PARAMETER SOLCC1(CTRY,LC1,TS,T);
SOLCC1(CTRY,LC1,TS,T)$(TROPINAC(CTRY,LC1) EQ 1) =
(SOLC1(CTRY,LC1,TS)-CPARAM2(CTRY,LC1,'6'))*CUMNAC1(CTRY,LC1,TS,T);

DISPLAY SOLCC1;

PARAMETER SOILC1(CTRY,LC1,T);
SOILC1(CTRY,LC1,T)$(TROPINAC(CTRY,LC1) EQ 1) = SUM(TS,SOLCC1(CTRY,LC1,TS,T));

DISPLAY SOILC1;

*count lost carbon in land lost, count only the NPV of lost carbon
PARAMETER CSOILTROP1(CTRY,LC1,T);
CSOILTROP1(CTRY,LC1,T)$(TROPINAC(CTRY,LC1) EQ 1) =
CPARAM2(CTRY,LC1,'5')*SUM(A1,IFORIN2(CTRY,LC1,A1))+
SOILC1(CTRY,LC1,T)+
CPARAM2(CTRY,LC1,'8')*MIN[CCNAC1(CTRY,LC1,T),0];

DISPLAY CSOILTROP1;

PARAMETER TSOIL1(CTRY,T);
TSOIL1(CTRY,T) = SUM(LC1,CSOILR1(CTRY,LC1,T))+
SUM(LC1,CSOILT1(CTRY,LC1,T))+
SUM(LC1,CSOILTROP1(CTRY,LC1,T));

DISPLAY TSOIL1;


FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL ABOVEGROUND C -TOTAL (million tons C)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TABVCLIVEANDDEAD(CTRY,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL MARKET C -TOTAL (million tons C)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TMKTCNEW(CTRY,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL SOIL C -TOTAL (million tons C)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TSOIL1(CTRY,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL SLASH POOL C -TOTAL (million tons C)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT SLASHCPOOL2(CTRY,T)););

PARAMETER TOTALCSTORED(CTRY,T);
TOTALCSTORED(CTRY,T)=
TABVCR(CTRY,T)+
TMKTCNEW(CTRY,T)+
TSOIL1(CTRY,T)+
SLASHCPOOL2(CTRY,T);


FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL TOTAL CARBON STORAGE ALL POOLS (million tons C)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TOTALCSTORED(CTRY,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL ANNUAL SLASH CONTRIBUTION C -TOTAL (million tons C)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT ANNSLASHCCTRY(CTRY,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL ANNUAL RESIDUE REMOVAL C -TOTAL (million tons C)';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT ANNRESCTRY(CTRY,T)););

PARAMETER GSV1(CTRY,LC1,A1,T) accessible and semi-accessible ;
GSV1(CTRY,LC1,A1,T) = CYIELD(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       {(1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)}*
       [YACRE2.L(CTRY,LC1,A1,T)];

*GSV1(CTRY,LC1,A1,T) = CYIELD(CTRY,LC1,A1,T)*YACRE2.L(CTRY,LC1,A1,T);


PARAMETER GSV2(CTRY,LC1,T) inaccessible timber in temperate and tropical zone ;
GSV2(CTRY,LC1,T)=
*temperate inaccessible in TYPE A
[PARAM2(CTRY,LC1,'8')*
SUM(A1, CYLDINAC(CTRY,LC1,A1,T)*YACRIN1.L(CTRY,LC1,A1,T))]$(R1FOR(CTRY,LC1) EQ 1)+

*temperate inaccessible in TYPE B
[PARAM2(CTRY,LC1,'8')*
SUM(A1, CYLDINAC(CTRY,LC1,A1,T)*
        YACRIN1.L(CTRY,LC1,A1,T))]$(TEMPINAC(CTRY,LC1) EQ 1)+

*tropical low management type
[SUM(A1,YACRE3.L(CTRY,LC1,A1,T)*CYIELD(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8'))]$(TROPINAC(CTRY,LC1) EQ 1)+

[PARAM2(CTRY,LC1,'8')*SUM(A1,YACRIN1.L(CTRY,LC1,A1,T)
        *CYLDINAC(CTRY,LC1,A1,T))]$(TROPINAC(CTRY,LC1) EQ 1);

PARAMETER GSVLC(CTRY,LC1,T);
GSVLC(CTRY,LC1,T) = SUM(A1,GSV1(CTRY,LC1,A1,T))+GSV2(CTRY,LC1,T);


PARAMETER GSV(CTRY,T);
GSV(CTRY,T) = SUM(LC1,SUM(A1,GSV1(CTRY,LC1,A1,T))+GSV2(CTRY,LC1,T));


PARAMETER CGSVPHECTARELC(CTRY,LC1, T);
CGSVPHECTARELC(CTRY,LC1,T)= (SUM(A1,GSV1(CTRY,LC1,A1,T))+GSV2(CTRY,LC1,T))/
        (SUM(A1,YACRE2.L(CTRY,LC1,A1,T)+ YACRIN1.L(CTRY,LC1,A1,T)
        + YACRIN1.L(CTRY,LC1,A1,T)+ YACRE3.L(CTRY,LC1,A1,T)+EPSILON));


PARAMETER STOCKINGDENLC(CTRY,LC1,A1,T);
STOCKINGDENLC(CTRY,LC1,A1,T) = PARAM2(CTRY,LC1,'8')*
       {(1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)};


PARAMETER AREAHARVESED(CTRY,LC1,T);
AREAHARVESED(CTRY,LC1,T)= SUM(A1,ACHR2.L(CTRY,LC1,A1,T)+ ACHRIN1.L(CTRY,LC1,A1,T) + ACHR3.L(CTRY,LC1,A1,T));

PARAMETER TOTALQLC(CTRY,LC1,T);
TOTALQLC(CTRY,LC1,T) = QFSLC(CTRY,LC1,T)+QFPLC(CTRY,LC1,T);

PARAMETER QPERHA(CTRY,LC1,T);
QPERHA(CTRY,LC1,T)=TOTALQLC(CTRY,LC1,T)/(AREAHARVESED(CTRY,LC1,T)+EPSILON);


FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL GROWING STOCK VOLUME';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT GSV(CTRY,T)););


FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US GSVACCESSIBLE';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) LT 26), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) LT 26), PUT GSVLC('1',LC1,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US GSV INACCESSIBLE';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 32), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 32), PUT GSVLC('1',LC1,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US GSV INACCESSIBLE';
PUT / 'YEAR'; LOOP(LC1$(ORD(LC1) GT 58), PUT LC1.TE(LC1););
LOOP(T, PUT / T.TE(T); LOOP(LC1$(ORD(LC1) GT 58), PUT GSVLC('1',LC1,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'US ABOVEC';
PUT / 'YEAR'; LOOP(DATA$(ORD(DATA) LT 26), PUT DATA.TE(DATA););
LOOP(T, PUT / T.TE(T); LOOP(DATA$(ORD(DATA) LT 26), PUT TABVUS(DATA,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL LITER Tg C VOLUME';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT LITTERSUM(CTRY,T)););

PARAMETER GSVUSTYPE(DATA ,T);
GSVUSTYPE('1' ,T)=SUM(LC1$(ORD(LC1) LT 26), GSVLC('1',LC1,T));
GSVUSTYPE('2' ,T)=SUM(LC1$(ORD(LC1) GT 32), GSVLC('1',LC1,T))- SUM(LC1$(ORD(LC1) GT 58), GSVLC('1',LC1,T));
GSVUSTYPE('3' ,T)= SUM(LC1$(ORD(LC1) GT 58), GSVLC('1',LC1,T));

PARAMETER GSVGROWTHUSTYPE(DATA ,T);
GSVGROWTHUSTYPE('1',T)$(ORD(T) LT 20) =(LOG(GSVUSTYPE('1',T+1)/ GSVUSTYPE('1',T))/10); 
GSVGROWTHUSTYPE('2',T)$(ORD(T) LT 20) =(LOG(GSVUSTYPE('2',T+1)/ GSVUSTYPE('2',T))/10); 
GSVGROWTHUSTYPE('3',T)$(ORD(T) LT 20) =(LOG(GSVUSTYPE('3',T+1)/ GSVUSTYPE('3',T))/10); 

PARAMETER TABVUS2(DATA,T);
TABVUS2('1',T)= TABVUS('1',T)*(1+GSVGROWTHUSTYPE('1',T-1))**(ORD(T) -1);
TABVUS2('2',T)= TABVUS('2',T)*(1+GSVGROWTHUSTYPE('2',T-1))**(ORD(T) -1);
TABVUS2('3',T)= TABVUS('3',T)*(1+GSVGROWTHUSTYPE('3',T-1))**(ORD(T) -1);

PARAMETER TREECARB(T);
TREECARB(T) = SUM(DATA, TABVUS2(DATA,T))+LITTERSUM('1',T)+ SLASHCPOOL2('1',T);

PARAMETER TOTALCARB(T);
TOTALCARB(T) = TREECARB(T)+ TMKTCNEW('1',T)+ TSOIL1('1',T);

PARAMETER CARBONALL(DATA,T);
CARBONALL('1',T) = TREECARB(T);
CARBONALL('2',T) = TMKTCNEW('1',T);
CARBONALL('3',T) = TSOIL1('1',T);
CARBONALL('4',T) = TOTALCARB(T);

**************************************************************************
******* Investment Costs
**************************************************************************
PARAMETER INVESTMENT(CTRY,LC1,T);
INVESTMENT(CTRY,LC1,T)=

*planting costs accessible lands
(IMGMT1.L(CTRY,LC1,T))*(ACPL2.L(CTRY,LC1,T))$(R1FOR(CTRY,LC1) EQ 1)

*planting costs dedicated biofuels
+(IMGMT1.L(CTRY,LC1,T))*[ACPLBIO.L(CTRY,LC1,T)+NEWACPLBIO.L(CTRY,LC1,T)] $(DEDBIO(CTRY,LC1) EQ 1)

*planting costs dedicated biofuels
+ PARAM3(CTRY,LC1,'17')*(NEWACPLBIO.L(CTRY,LC1,T))$(DEDBIO(CTRY,LC1) EQ 1)

*planting costs TEMPERATE ZONE inaccessible
+(IMGMT1.L(CTRY,LC1,T))*(ACPL3.L(CTRY,LC1,T))$(TEMPINAC(CTRY,LC1) EQ 1)
 
*planting costs TROPICAL ZONE inaccessible original with ACPL6 only
+[IMGMT1.l(CTRY,LC1,T)+2000]*[ACPL6.l(CTRY,LC1,T)]$(TROPINAC(CTRY,LC1) EQ 1)
;

PARAMETER INVESTCTRY(CTRY,T);
INVESTCTRY(CTRY,T) =SUM(LC1,INVESTMENT(CTRY,LC1,T));


FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL INVESTMENT COST';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT INVESTCTRY(CTRY,T)););

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL RENTAL COST';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT RENTTOTALCTRY(CTRY,T)););

PARAMETER THARVCOST(CTRY,LC1,T);
THARVCOST(CTRY,LC1,T) = 

*sawtimber harvest cost

(1-PROPPULP.L(CTRY,LC1,T) +EPSILON)*
CSA(CTRY,LC1,'1')*SUM(A1,(ACHR2.L(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(R1FOR(CTRY,LC1) EQ 1)

+

[
{(1-PROPPULP.L(CTRY,LC1,T) +EPSILON)*SUM(A1,(ACHR2.L(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'2')]$(R1FOR(CTRY,LC1) EQ 1)

*cost of sawtimber production on temperate semi-accessible lands
+
(1-PROPPULP.L(CTRY,LC1,T) +EPSILON)*
CSA(CTRY,LC1,'3')*SUM(A1,(ACHR2.L(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*
     PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(TEMPINAC(CTRY,LC1) EQ 1)

+
[{(1-PROPPULP.L(CTRY,LC1,T) +EPSILON)*SUM(A1,(ACHR2.L(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*
     PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'4')]$(TEMPINAC(CTRY,LC1) EQ 1)

*cost of sawtimber production on tropical semi-accessible lands
+
(1-PROPPULP.L(CTRY,LC1,T) +EPSILON)*
CSA(CTRY,LC1,'3')*SUM(A1,[ACHR2.L(CTRY,LC1,A1,T) +EPSILON]*
        YIELD2(CTRY,LC1,A1,T)*
        PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(TROPINAC(CTRY,LC1) EQ 1)

+

[
{(1-PROPPULP.L(CTRY,LC1,T) +EPSILON)*SUM(A1,[ACHR2.L(CTRY,LC1,A1,T) +EPSILON]*
        YIELD2(CTRY,LC1,A1,T)*
        PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'4')]$(TROPINAC(CTRY,LC1) EQ 1)


*cost of harvesting temperate inaccessible lands
+
(1-PROPPULP.L(CTRY,LC1,T) +EPSILON)*
SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T) +EPSILON)*
PARAM2(CTRY,LC1,'12')*{CHQ1.L(CTRY,LC1,T)+EPSILON}**(1/PARAM2(CTRY,LC1,'13'))$(TEMPINAC(CTRY,LC1) EQ 1)


*cost of harvesting tropical inaccessible lands
+
(1-PROPPULP.L(CTRY,LC1,T) +EPSILON)*
{SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)+ ACHR3.L(CTRY,LC1,A1,T))+EPSILON}*
PARAM2(CTRY,LC1,'14')*
{SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)+ ACHR3.L(CTRY,LC1,A1,T))+EPSILON}**(1/PARAM2(CTRY,LC1,'15')) $(TROPINAC(CTRY,LC1) EQ 1)
*end of cost of sawtimber harvesting

+

*costs of pulpwood production

(PROPPULP.L(CTRY,LC1,T)+EPSILON)*
CSA(CTRY,LC1,'5')*SUM(A1,(ACHR2.L(CTRY,LC1,A1,T) +EPSILON)*YIELD2(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(R1FOR(CTRY,LC1) EQ 1)

+
[
{(PROPPULP.L(CTRY,LC1,T)+EPSILON)*
SUM(A1,(ACHR2.L(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*
PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'6')]$(R1FOR(CTRY,LC1) EQ 1)

*cost of harvesting temperate semi-accessible lands
+
(PROPPULP.L(CTRY,LC1,T)+EPSILON)*
CSA(CTRY,LC1,'7')*SUM(A1,(ACHR2.L(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*
     PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(TEMPINAC(CTRY,LC1) EQ 1)

+
[
{(PROPPULP.L(CTRY,LC1,T) +EPSILON)*
SUM(A1,(ACHR2.L(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*
     PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'8')]$(TEMPINAC(CTRY,LC1) EQ 1)

*cost of harvesting tropical semi-accessible lands
+
(PROPPULP.L(CTRY,LC1,T)+EPSILON)*
CSA(CTRY,LC1,'7')*SUM(A1,[ACHR2.L(CTRY,LC1,A1,T) +EPSILON]*
        YIELD2(CTRY,LC1,A1,T)*
        PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))$(TROPINAC(CTRY,LC1) EQ 1)
+

[
{(PROPPULP.L(CTRY,LC1,T)+EPSILON)*SUM(A1,[ACHR2.L(CTRY,LC1,A1,T) +EPSILON]*
        YIELD2(CTRY,LC1,A1,T)*
        PARAM2(CTRY,LC1,'8')*((1+MGMT1.L(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T)))+EPSILON}** CSA(CTRY,LC1,'8')]$(TROPINAC(CTRY,LC1) EQ 1)


*cost of harvesting temperate inaccessible lands
+
(PROPPULP.L(CTRY,LC1,T)+EPSILON)*
SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T) +EPSILON)*
PARAM2(CTRY,LC1,'12')*{CHQ1.L(CTRY,LC1,T)+EPSILON}**(1/PARAM2(CTRY,LC1,'13'))$(TEMPINAC(CTRY,LC1) EQ 1)

*cost of harvesting tropical inaccessible lands
+
(PROPPULP.L(CTRY,LC1,T)+EPSILON)*
{SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)+ ACHR3.L(CTRY,LC1,A1,T))+EPSILON}*
PARAM2(CTRY,LC1,'14')*
{SUM(A1,ACHRIN1.L(CTRY,LC1,A1,T)+ ACHR3.L(CTRY,LC1,A1,T))+EPSILON}**(1/PARAM2(CTRY,LC1,'15'))$(TROPINAC(CTRY,LC1) EQ 1)
*end of cost of pulpwood harvesting

+

*dedicated biofuel harvesting costs
CSA(CTRY,LC1,'5')*[ SUM(A1,((ACHR2.l(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.l(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T))$(DEDBIO(CTRY,LC1) EQ 1)))]+
(SUM(A1,((ACHR2.l(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.l(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T))$(DEDBIO(CTRY,LC1) EQ 1)))+EPSILON)**CSA(CTRY,LC1,'6')

*transportation costs
+
[SUM(A1,((ACHR2.l(CTRY,LC1,A1,T) +EPSILON )*YIELD2(CTRY,LC1,A1,T)*PARAM2(CTRY,LC1,'8')*
       ((1+MGMT1.l(CTRY,LC1,A1,T))**FINPTEL(CTRY,LC1,T))$(DEDBIO(CTRY,LC1) EQ 1)))]*PARAM3(CTRY,LC1,'18')*PARAM3(CTRY,LC1,'19')
;

PARAMETER THARVCOSTCTRY(CTRY,T);
THARVCOSTCTRY(CTRY,T) = SUM(LC1,THARVCOST(CTRY,LC1,T));

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'REGIONAL HARVEST COST';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT THARVCOSTCTRY(CTRY,T)););

PARAMETER TOTALOUTPUT(CTRY,T);
TOTALOUTPUT(CTRY,T) = FPP(T)*QFP(CTRY,T) +FPS(T)*QFS(CTRY,T);

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'TOTAL OUTPUT';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT TOTALOUTPUT(CTRY,T)););

*total harvest

PARAMETER HECTAREHARV(CTRY,T);
HECTAREHARV(CTRY,T)=SUM(LC1,SUM(A1,
ACHR2.L(CTRY,LC1,A1,T)+ACHR3.L(CTRY,LC1,A1,T)+ACHRIN1.L(CTRY,LC1,A1,T)));

FILE  GLOBALTIMBERMODEL2020; PUT  GLOBALTIMBERMODEL2020;  GLOBALTIMBERMODEL2020.PC=5;
PUT / 'HECTARES HARVESTED';
PUT / 'YEAR';
PUT 'US';
PUT 'CHINA';
PUT 'BRAZIL';
PUT 'CANADA';
PUT 'RUSSIA';
PUT 'EU ANNEX I';
PUT 'EU NON ANNEX I';
PUT 'SOUTH ASIA';
PUT 'CENT AMER.';
PUT 'RSAM';
PUT 'SSAF';
PUT 'SE ASIA';
PUT 'OCEANIA';
PUT 'JAPAN';
PUT 'AFME';
PUT 'E ASIA';
LOOP(T, PUT / T.TE(T);LOOP(CTRY, PUT HECTAREHARV(CTRY,T)););



* PLACES ALL OUTPUT TO A GDX FILE
execute_unload "GLOBALTIMBERMODEL2020.gdx"

