;/*************************************************************************************
    @title:  CAMPBELL, LETTAU, MALKIEL, AND XU (2001) VARIANCE DECOMPOSITION TIME SERIES
    -----------------------------------------------------------------------------------    
    @author: Alex Chinco
    @date:   01/05/2013
    -----------------------------------------------------------------------------------    
    @desc:   This program recreates the monthly data series containing the market,
             industry, and firm level variance time series from the Campbell, Lettau,
             Malkiel, and Xu (2001) article.
**************************************************************************************/



    

;/*************************************************************************************
    @section: SPECIFY OPTIONS AND FILE LOCATIONS
    -----------------------------------------------------------------------------------    
    @desc:    This section specifies the options and file locations used in the code
              below.
**************************************************************************************/

LIBNAME crsp '/wrds/crsp/sasdata/a_stock';
LIBNAME ff   '/wrds/ff/sasdata';

%LET START_DATE = '01JUL1965'd;
%LET END_DATE   = '31DEC2012'd;
    
    
    
    
    
    




    
    
;/*************************************************************************************
    @section: PULL DAILY STOCK DATA
    -----------------------------------------------------------------------------------    
    @desc:    This section pulls in the daily CRSP stock file, and creates a new SAS
              data set. It then restricts the raw data by removing observations with
              invalid exchange codes, invalid share codes, missing return data, missing
              price data, missing SIC code data, missing share count data, and a price
              below $1.
**************************************************************************************/

PROC SQL;
    CREATE TABLE retData AS
        SELECT a.permno,
               a.date,
               a.ret,
               a.prc,
               a.shrout,
               a.hsiccd,
               b.exchcd,
               b.shrcd
        FROM crsp.dsf(KEEP = date permno ret prc shrout hsiccd) AS a LEFT JOIN crsp.dseall(KEEP = date permno exchcd shrcd) AS b
        ON (a.permno = b.permno) AND (a.date = b.date)
        WHERE (&START_DATE <= a.date <= &END_DATE);
QUIT;

PROC SORT
    DATA = retData;
    BY permno date;
RUN;

DATA retData;
    SET retData;
    BY permno date;
    RETAIN lexchcd lshrcd;
    IF first.permno THEN
        DO;
        lexchcd = exchcd;
        lshrcd  = shrcd;
        END;
    ELSE
        DO;
        IF MISSING(exchcd) THEN
            DO;
            exchcd = lexchcd;
            END;
        ELSE
            DO;
            lexchcd = exchcd;
            END;
        IF MISSING(shrcd) THEN
            DO;
            shrcd = lshrcd;
            END;
        ELSE
            DO;
            lshrcd = shrcd;
            END;
        END;
    IF (exchcd IN (1,2,3));
    IF (shrcd IN (10,11));
    IF (NOT MISSING(ret));
    IF (ret NOT IN (-66.0,-77.0,-88.0,-99.0));
    IF (NOT MISSING(prc));
    IF (NOT MISSING(shrout));
    IF (hsiccd = 0) THEN
        DO;
        hsiccd = .;
        END;
    siccd = hsiccd;
    IF (prc < 0) THEN
        DO;
        prc = ABS(prc);
        END;
    shrout = 1000 * shrout;
    mktCap = prc * shrout;
    year   = YEAR(date);
    month  = MONTH(date);
    DROP lexchcd lshrcd hsiccd shrcd exchcd prc shrout;
RUN;

PROC SQL;
    CREATE TABLE retData AS
        SELECT a.*,
               b.rf
        FROM retData AS a LEFT JOIN ff.factors_daily(KEEP = date rf) AS b
        ON (a.date = b.date)
        WHERE (&START_DATE <= a.date <= &END_DATE);
QUIT;

DATA retxData;
    SET retData;
    retx = ret - rf;
    DROP rf;
RUN;

PROC MEANS
    DATA = retxData
    n nmiss mean median std min max;
    VAR ret retx mktCap siccd year month;
RUN;

PROC PRINT
    DATA = retxData(obs = 10);
    TITLE 'First 10 observations of cleaned daily CRSP data.'; 
RUN;










;/*************************************************************************************
    @section: MERGE ON INDUSTRY CLASSIFICATIONS
    -----------------------------------------------------------------------------------    
    @desc:    Merge on Fama and French (1997) industry classification codes. Print first
              10 observations. Export data set of number of stocks per month.
**************************************************************************************/

DATA retxData;
    SET retxData;
    ind     = 49;
    indAbrv = 'NoInd';
    if missing(siccd) then do; ind=49; indAbrv='NoInd'; end;
    else if 0100<=siccd<=0199 then do; ind=1; indAbrv='Agric'; end;
    else if 0200<=siccd<=0299 then do; ind=1; indAbrv='Agric'; end;
    else if 0700<=siccd<=0799 then do; ind=1; indAbrv='Agric'; end;
    else if 0910<=siccd<=0919 then do; ind=1; indAbrv='Agric'; end;
    else if 2048<=siccd<=2048 then do; ind=1; indAbrv='Agric'; end;
    else if 2000<=siccd<=2009 then do; ind=2; indAbrv='Food'; end;
    else if 2010<=siccd<=2019 then do; ind=2; indAbrv='Food'; end;
    else if 2020<=siccd<=2029 then do; ind=2; indAbrv='Food'; end;
    else if 2030<=siccd<=2039 then do; ind=2; indAbrv='Food'; end;
    else if 2040<=siccd<=2046 then do; ind=2; indAbrv='Food'; end;
    else if 2050<=siccd<=2059 then do; ind=2; indAbrv='Food'; end;
    else if 2060<=siccd<=2063 then do; ind=2; indAbrv='Food'; end;
    else if 2070<=siccd<=2079 then do; ind=2; indAbrv='Food'; end;
    else if 2090<=siccd<=2092 then do; ind=2; indAbrv='Food'; end;
    else if 2095<=siccd<=2095 then do; ind=2; indAbrv='Food'; end;
    else if 2098<=siccd<=2099 then do; ind=2; indAbrv='Food'; end;
    else if 2064<=siccd<=2068 then do; ind=3; indAbrv='Soda'; end;
    else if 2086<=siccd<=2086 then do; ind=3; indAbrv='Soda'; end;
    else if 2087<=siccd<=2087 then do; ind=3; indAbrv='Soda'; end;
    else if 2096<=siccd<=2096 then do; ind=3; indAbrv='Soda'; end;
    else if 2097<=siccd<=2097 then do; ind=3; indAbrv='Soda'; end;
    else if 2080<=siccd<=2080 then do; ind=4; indAbrv='Beer'; end;
    else if 2082<=siccd<=2082 then do; ind=4; indAbrv='Beer'; end;
    else if 2083<=siccd<=2083 then do; ind=4; indAbrv='Beer'; end;
    else if 2084<=siccd<=2084 then do; ind=4; indAbrv='Beer'; end;
    else if 2085<=siccd<=2085 then do; ind=4; indAbrv='Beer'; end;
    else if 2100<=siccd<=2199 then do; ind=5; indAbrv='Smoke'; end;
    else if 0920<=siccd<=0999 then do; ind=6; indAbrv='Toys'; end;
    else if 3650<=siccd<=3651 then do; ind=6; indAbrv='Toys'; end;
    else if 3652<=siccd<=3652 then do; ind=6; indAbrv='Toys'; end;
    else if 3732<=siccd<=3732 then do; ind=6; indAbrv='Toys'; end;
    else if 3930<=siccd<=3931 then do; ind=6; indAbrv='Toys'; end;
    else if 3940<=siccd<=3949 then do; ind=6; indAbrv='Toys'; end;
    else if 7800<=siccd<=7829 then do; ind=7; indAbrv='Fun'; end;
    else if 7830<=siccd<=7833 then do; ind=7; indAbrv='Fun'; end;
    else if 7840<=siccd<=7841 then do; ind=7; indAbrv='Fun'; end;
    else if 7900<=siccd<=7900 then do; ind=7; indAbrv='Fun'; end;
    else if 7910<=siccd<=7911 then do; ind=7; indAbrv='Fun'; end;
    else if 7920<=siccd<=7929 then do; ind=7; indAbrv='Fun'; end;
    else if 7930<=siccd<=7933 then do; ind=7; indAbrv='Fun'; end;
    else if 7940<=siccd<=7949 then do; ind=7; indAbrv='Fun'; end;
    else if 7980<=siccd<=7980 then do; ind=7; indAbrv='Fun'; end;
    else if 7990<=siccd<=7999 then do; ind=7; indAbrv='Fun'; end;
    else if 2700<=siccd<=2709 then do; ind=8; indAbrv='Books'; end;
    else if 2710<=siccd<=2719 then do; ind=8; indAbrv='Books'; end;
    else if 2720<=siccd<=2729 then do; ind=8; indAbrv='Books'; end;
    else if 2730<=siccd<=2739 then do; ind=8; indAbrv='Books'; end;
    else if 2740<=siccd<=2749 then do; ind=8; indAbrv='Books'; end;
    else if 2770<=siccd<=2771 then do; ind=8; indAbrv='Books'; end;
    else if 2780<=siccd<=2789 then do; ind=8; indAbrv='Books'; end;
    else if 2790<=siccd<=2799 then do; ind=8; indAbrv='Books'; end;
    else if 2047<=siccd<=2047 then do; ind=9; indAbrv='Hshld'; end;
    else if 2391<=siccd<=2392 then do; ind=9; indAbrv='Hshld'; end;
    else if 2510<=siccd<=2519 then do; ind=9; indAbrv='Hshld'; end;
    else if 2590<=siccd<=2599 then do; ind=9; indAbrv='Hshld'; end;
    else if 2840<=siccd<=2843 then do; ind=9; indAbrv='Hshld'; end;
    else if 2844<=siccd<=2844 then do; ind=9; indAbrv='Hshld'; end;
    else if 3160<=siccd<=3161 then do; ind=9; indAbrv='Hshld'; end;
    else if 3170<=siccd<=3171 then do; ind=9; indAbrv='Hshld'; end;
    else if 3172<=siccd<=3172 then do; ind=9; indAbrv='Hshld'; end;
    else if 3190<=siccd<=3199 then do; ind=9; indAbrv='Hshld'; end;
    else if 3229<=siccd<=3229 then do; ind=9; indAbrv='Hshld'; end;
    else if 3260<=siccd<=3260 then do; ind=9; indAbrv='Hshld'; end;
    else if 3262<=siccd<=3263 then do; ind=9; indAbrv='Hshld'; end;
    else if 3269<=siccd<=3269 then do; ind=9; indAbrv='Hshld'; end;
    else if 3230<=siccd<=3231 then do; ind=9; indAbrv='Hshld'; end;
    else if 3630<=siccd<=3639 then do; ind=9; indAbrv='Hshld'; end;
    else if 3750<=siccd<=3751 then do; ind=9; indAbrv='Hshld'; end;
    else if 3800<=siccd<=3800 then do; ind=9; indAbrv='Hshld'; end;
    else if 3860<=siccd<=3861 then do; ind=9; indAbrv='Hshld'; end;
    else if 3870<=siccd<=3873 then do; ind=9; indAbrv='Hshld'; end;
    else if 3910<=siccd<=3911 then do; ind=9; indAbrv='Hshld'; end;
    else if 3914<=siccd<=3914 then do; ind=9; indAbrv='Hshld'; end;
    else if 3915<=siccd<=3915 then do; ind=9; indAbrv='Hshld'; end;
    else if 3960<=siccd<=3962 then do; ind=9; indAbrv='Hshld'; end;
    else if 3991<=siccd<=3991 then do; ind=9; indAbrv='Hshld'; end;
    else if 3995<=siccd<=3995 then do; ind=9; indAbrv='Hshld'; end;
    else if 2300<=siccd<=2390 then do; ind=10; indAbrv='Clths'; end;
    else if 3020<=siccd<=3021 then do; ind=10; indAbrv='Clths'; end;
    else if 3100<=siccd<=3111 then do; ind=10; indAbrv='Clths'; end;
    else if 3130<=siccd<=3131 then do; ind=10; indAbrv='Clths'; end;
    else if 3140<=siccd<=3149 then do; ind=10; indAbrv='Clths'; end;
    else if 3150<=siccd<=3151 then do; ind=10; indAbrv='Clths'; end;
    else if 3963<=siccd<=3965 then do; ind=10; indAbrv='Clths'; end;
    else if 8000<=siccd<=8099 then do; ind=11; indAbrv='Hlth'; end;
    else if 3693<=siccd<=3693 then do; ind=12; indAbrv='MedEq'; end;
    else if 3840<=siccd<=3849 then do; ind=12; indAbrv='MedEq'; end;
    else if 3850<=siccd<=3851 then do; ind=12; indAbrv='MedEq'; end;
    else if 2830<=siccd<=2830 then do; ind=13; indAbrv='Drugs'; end;
    else if 2831<=siccd<=2831 then do; ind=13; indAbrv='Drugs'; end;
    else if 2833<=siccd<=2833 then do; ind=13; indAbrv='Drugs'; end;
    else if 2834<=siccd<=2834 then do; ind=13; indAbrv='Drugs'; end;
    else if 2835<=siccd<=2835 then do; ind=13; indAbrv='Drugs'; end;
    else if 2836<=siccd<=2836 then do; ind=13; indAbrv='Drugs'; end;
    else if 2800<=siccd<=2809 then do; ind=14; indAbrv='Chems'; end;
    else if 2810<=siccd<=2819 then do; ind=14; indAbrv='Chems'; end;
    else if 2820<=siccd<=2829 then do; ind=14; indAbrv='Chems'; end;
    else if 2850<=siccd<=2859 then do; ind=14; indAbrv='Chems'; end;
    else if 2860<=siccd<=2869 then do; ind=14; indAbrv='Chems'; end;
    else if 2870<=siccd<=2879 then do; ind=14; indAbrv='Chems'; end;
    else if 2890<=siccd<=2899 then do; ind=14; indAbrv='Chems'; end;
    else if 3031<=siccd<=3031 then do; ind=15; indAbrv='Rubbr'; end;
    else if 3041<=siccd<=3041 then do; ind=15; indAbrv='Rubbr'; end;
    else if 3050<=siccd<=3053 then do; ind=15; indAbrv='Rubbr'; end;
    else if 3060<=siccd<=3069 then do; ind=15; indAbrv='Rubbr'; end;
    else if 3070<=siccd<=3079 then do; ind=15; indAbrv='Rubbr'; end;
    else if 3080<=siccd<=3089 then do; ind=15; indAbrv='Rubbr'; end;
    else if 3090<=siccd<=3099 then do; ind=15; indAbrv='Rubbr'; end;
    else if 2200<=siccd<=2269 then do; ind=16; indAbrv='Txtls'; end;
    else if 2270<=siccd<=2279 then do; ind=16; indAbrv='Txtls'; end;
    else if 2280<=siccd<=2284 then do; ind=16; indAbrv='Txtls'; end;
    else if 2290<=siccd<=2295 then do; ind=16; indAbrv='Txtls'; end;
    else if 2297<=siccd<=2297 then do; ind=16; indAbrv='Txtls'; end;
    else if 2298<=siccd<=2298 then do; ind=16; indAbrv='Txtls'; end;
    else if 2299<=siccd<=2299 then do; ind=16; indAbrv='Txtls'; end;
    else if 2393<=siccd<=2395 then do; ind=16; indAbrv='Txtls'; end;
    else if 2397<=siccd<=2399 then do; ind=16; indAbrv='Txtls'; end;
    else if 0800<=siccd<=0899 then do; ind=17; indAbrv='BldMt'; end;
    else if 2400<=siccd<=2439 then do; ind=17; indAbrv='BldMt'; end;
    else if 2450<=siccd<=2459 then do; ind=17; indAbrv='BldMt'; end;
    else if 2490<=siccd<=2499 then do; ind=17; indAbrv='BldMt'; end;
    else if 2660<=siccd<=2661 then do; ind=17; indAbrv='BldMt'; end;
    else if 2950<=siccd<=2952 then do; ind=17; indAbrv='BldMt'; end;
    else if 3200<=siccd<=3200 then do; ind=17; indAbrv='BldMt'; end;
    else if 3210<=siccd<=3211 then do; ind=17; indAbrv='BldMt'; end;
    else if 3240<=siccd<=3241 then do; ind=17; indAbrv='BldMt'; end;
    else if 3250<=siccd<=3259 then do; ind=17; indAbrv='BldMt'; end;
    else if 3261<=siccd<=3261 then do; ind=17; indAbrv='BldMt'; end;
    else if 3264<=siccd<=3264 then do; ind=17; indAbrv='BldMt'; end;
    else if 3270<=siccd<=3275 then do; ind=17; indAbrv='BldMt'; end;
    else if 3280<=siccd<=3281 then do; ind=17; indAbrv='BldMt'; end;
    else if 3290<=siccd<=3293 then do; ind=17; indAbrv='BldMt'; end;
    else if 3295<=siccd<=3299 then do; ind=17; indAbrv='BldMt'; end;
    else if 3420<=siccd<=3429 then do; ind=17; indAbrv='BldMt'; end;
    else if 3430<=siccd<=3433 then do; ind=17; indAbrv='BldMt'; end;
    else if 3440<=siccd<=3441 then do; ind=17; indAbrv='BldMt'; end;
    else if 3442<=siccd<=3442 then do; ind=17; indAbrv='BldMt'; end;
    else if 3446<=siccd<=3446 then do; ind=17; indAbrv='BldMt'; end;
    else if 3448<=siccd<=3448 then do; ind=17; indAbrv='BldMt'; end;
    else if 3449<=siccd<=3449 then do; ind=17; indAbrv='BldMt'; end;
    else if 3450<=siccd<=3451 then do; ind=17; indAbrv='BldMt'; end;
    else if 3452<=siccd<=3452 then do; ind=17; indAbrv='BldMt'; end;
    else if 3490<=siccd<=3499 then do; ind=17; indAbrv='BldMt'; end;
    else if 3996<=siccd<=3996 then do; ind=17; indAbrv='BldMt'; end;
    else if 1500<=siccd<=1511 then do; ind=18; indAbrv='Cnstr'; end;
    else if 1520<=siccd<=1529 then do; ind=18; indAbrv='Cnstr'; end;
    else if 1530<=siccd<=1539 then do; ind=18; indAbrv='Cnstr'; end;
    else if 1540<=siccd<=1549 then do; ind=18; indAbrv='Cnstr'; end;
    else if 1600<=siccd<=1699 then do; ind=18; indAbrv='Cnstr'; end;
    else if 1700<=siccd<=1799 then do; ind=18; indAbrv='Cnstr'; end;
    else if 3300<=siccd<=3300 then do; ind=19; indAbrv='Steel'; end;
    else if 3310<=siccd<=3317 then do; ind=19; indAbrv='Steel'; end;
    else if 3320<=siccd<=3325 then do; ind=19; indAbrv='Steel'; end;
    else if 3330<=siccd<=3339 then do; ind=19; indAbrv='Steel'; end;
    else if 3340<=siccd<=3341 then do; ind=19; indAbrv='Steel'; end;
    else if 3350<=siccd<=3357 then do; ind=19; indAbrv='Steel'; end;
    else if 3360<=siccd<=3369 then do; ind=19; indAbrv='Steel'; end;
    else if 3370<=siccd<=3379 then do; ind=19; indAbrv='Steel'; end;
    else if 3390<=siccd<=3399 then do; ind=19; indAbrv='Steel'; end;
    else if 3400<=siccd<=3400 then do; ind=20; indAbrv='FabPr'; end;
    else if 3443<=siccd<=3443 then do; ind=20; indAbrv='FabPr'; end;
    else if 3444<=siccd<=3444 then do; ind=20; indAbrv='FabPr'; end;
    else if 3460<=siccd<=3469 then do; ind=20; indAbrv='FabPr'; end;
    else if 3470<=siccd<=3479 then do; ind=20; indAbrv='FabPr'; end;
    else if 3510<=siccd<=3519 then do; ind=21; indAbrv='Mach'; end;
    else if 3520<=siccd<=3529 then do; ind=21; indAbrv='Mach'; end;
    else if 3530<=siccd<=3530 then do; ind=21; indAbrv='Mach'; end;
    else if 3531<=siccd<=3531 then do; ind=21; indAbrv='Mach'; end;
    else if 3532<=siccd<=3532 then do; ind=21; indAbrv='Mach'; end;
    else if 3533<=siccd<=3533 then do; ind=21; indAbrv='Mach'; end;
    else if 3534<=siccd<=3534 then do; ind=21; indAbrv='Mach'; end;
    else if 3535<=siccd<=3535 then do; ind=21; indAbrv='Mach'; end;
    else if 3536<=siccd<=3536 then do; ind=21; indAbrv='Mach'; end;
    else if 3538<=siccd<=3538 then do; ind=21; indAbrv='Mach'; end;
    else if 3540<=siccd<=3549 then do; ind=21; indAbrv='Mach'; end;
    else if 3550<=siccd<=3559 then do; ind=21; indAbrv='Mach'; end;
    else if 3560<=siccd<=3569 then do; ind=21; indAbrv='Mach'; end;
    else if 3580<=siccd<=3580 then do; ind=21; indAbrv='Mach'; end;
    else if 3581<=siccd<=3581 then do; ind=21; indAbrv='Mach'; end;
    else if 3582<=siccd<=3582 then do; ind=21; indAbrv='Mach'; end;
    else if 3585<=siccd<=3585 then do; ind=21; indAbrv='Mach'; end;
    else if 3586<=siccd<=3586 then do; ind=21; indAbrv='Mach'; end;
    else if 3589<=siccd<=3589 then do; ind=21; indAbrv='Mach'; end;
    else if 3590<=siccd<=3599 then do; ind=21; indAbrv='Mach'; end;
    else if 3600<=siccd<=3600 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3610<=siccd<=3613 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3620<=siccd<=3621 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3623<=siccd<=3629 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3640<=siccd<=3644 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3645<=siccd<=3645 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3646<=siccd<=3646 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3648<=siccd<=3649 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3660<=siccd<=3660 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3690<=siccd<=3690 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3691<=siccd<=3692 then do; ind=22; indAbrv='ElcEq'; end;
    else if 3699<=siccd<=3699 then do; ind=22; indAbrv='ElcEq'; end;
    else if 2296<=siccd<=2296 then do; ind=23; indAbrv='Autos'; end;
    else if 2396<=siccd<=2396 then do; ind=23; indAbrv='Autos'; end;
    else if 3010<=siccd<=3011 then do; ind=23; indAbrv='Autos'; end;
    else if 3537<=siccd<=3537 then do; ind=23; indAbrv='Autos'; end;
    else if 3647<=siccd<=3647 then do; ind=23; indAbrv='Autos'; end;
    else if 3694<=siccd<=3694 then do; ind=23; indAbrv='Autos'; end;
    else if 3700<=siccd<=3700 then do; ind=23; indAbrv='Autos'; end;
    else if 3710<=siccd<=3710 then do; ind=23; indAbrv='Autos'; end;
    else if 3711<=siccd<=3711 then do; ind=23; indAbrv='Autos'; end;
    else if 3713<=siccd<=3713 then do; ind=23; indAbrv='Autos'; end;
    else if 3714<=siccd<=3714 then do; ind=23; indAbrv='Autos'; end;
    else if 3715<=siccd<=3715 then do; ind=23; indAbrv='Autos'; end;
    else if 3716<=siccd<=3716 then do; ind=23; indAbrv='Autos'; end;
    else if 3792<=siccd<=3792 then do; ind=23; indAbrv='Autos'; end;
    else if 3790<=siccd<=3791 then do; ind=23; indAbrv='Autos'; end;
    else if 3799<=siccd<=3799 then do; ind=23; indAbrv='Autos'; end;
    else if 3720<=siccd<=3720 then do; ind=24; indAbrv='Aero'; end;
    else if 3721<=siccd<=3721 then do; ind=24; indAbrv='Aero'; end;
    else if 3723<=siccd<=3724 then do; ind=24; indAbrv='Aero'; end;
    else if 3725<=siccd<=3725 then do; ind=24; indAbrv='Aero'; end;
    else if 3728<=siccd<=3729 then do; ind=24; indAbrv='Aero'; end;
    else if 3730<=siccd<=3731 then do; ind=25; indAbrv='Ships'; end;
    else if 3740<=siccd<=3743 then do; ind=25; indAbrv='Ships'; end;
    else if 3760<=siccd<=3769 then do; ind=26; indAbrv='Guns'; end;
    else if 3795<=siccd<=3795 then do; ind=26; indAbrv='Guns'; end;
    else if 3480<=siccd<=3489 then do; ind=26; indAbrv='Guns'; end;
    else if 1040<=siccd<=1049 then do; ind=27; indAbrv='Gold'; end;
    else if 1000<=siccd<=1009 then do; ind=28; indAbrv='Mines'; end;
    else if 1010<=siccd<=1019 then do; ind=28; indAbrv='Mines'; end;
    else if 1020<=siccd<=1029 then do; ind=28; indAbrv='Mines'; end;
    else if 1030<=siccd<=1039 then do; ind=28; indAbrv='Mines'; end;
    else if 1050<=siccd<=1059 then do; ind=28; indAbrv='Mines'; end;
    else if 1060<=siccd<=1069 then do; ind=28; indAbrv='Mines'; end;
    else if 1070<=siccd<=1079 then do; ind=28; indAbrv='Mines'; end;
    else if 1080<=siccd<=1089 then do; ind=28; indAbrv='Mines'; end;
    else if 1090<=siccd<=1099 then do; ind=28; indAbrv='Mines'; end;
    else if 1100<=siccd<=1119 then do; ind=28; indAbrv='Mines'; end;
    else if 1400<=siccd<=1499 then do; ind=28; indAbrv='Mines'; end;
    else if 1200<=siccd<=1299 then do; ind=29; indAbrv='Coal'; end;
    else if 1300<=siccd<=1300 then do; ind=30; indAbrv='Oil'; end;
    else if 1310<=siccd<=1319 then do; ind=30; indAbrv='Oil'; end;
    else if 1320<=siccd<=1329 then do; ind=30; indAbrv='Oil'; end;
    else if 1330<=siccd<=1339 then do; ind=30; indAbrv='Oil'; end;
    else if 1370<=siccd<=1379 then do; ind=30; indAbrv='Oil'; end;
    else if 1380<=siccd<=1380 then do; ind=30; indAbrv='Oil'; end;
    else if 1381<=siccd<=1381 then do; ind=30; indAbrv='Oil'; end;
    else if 1382<=siccd<=1382 then do; ind=30; indAbrv='Oil'; end;
    else if 1389<=siccd<=1389 then do; ind=30; indAbrv='Oil'; end;
    else if 2900<=siccd<=2912 then do; ind=30; indAbrv='Oil'; end;
    else if 2990<=siccd<=2999 then do; ind=30; indAbrv='Oil'; end;
    else if 4900<=siccd<=4900 then do; ind=31; indAbrv='Util'; end;
    else if 4910<=siccd<=4911 then do; ind=31; indAbrv='Util'; end;
    else if 4920<=siccd<=4922 then do; ind=31; indAbrv='Util'; end;
    else if 4923<=siccd<=4923 then do; ind=31; indAbrv='Util'; end;
    else if 4924<=siccd<=4925 then do; ind=31; indAbrv='Util'; end;
    else if 4930<=siccd<=4931 then do; ind=31; indAbrv='Util'; end;
    else if 4932<=siccd<=4932 then do; ind=31; indAbrv='Util'; end;
    else if 4939<=siccd<=4939 then do; ind=31; indAbrv='Util'; end;
    else if 4940<=siccd<=4942 then do; ind=31; indAbrv='Util'; end;
    else if 4800<=siccd<=4800 then do; ind=32; indAbrv='Telcm'; end;
    else if 4810<=siccd<=4813 then do; ind=32; indAbrv='Telcm'; end;
    else if 4820<=siccd<=4822 then do; ind=32; indAbrv='Telcm'; end;
    else if 4830<=siccd<=4839 then do; ind=32; indAbrv='Telcm'; end;
    else if 4840<=siccd<=4841 then do; ind=32; indAbrv='Telcm'; end;
    else if 4880<=siccd<=4889 then do; ind=32; indAbrv='Telcm'; end;
    else if 4890<=siccd<=4890 then do; ind=32; indAbrv='Telcm'; end;
    else if 4891<=siccd<=4891 then do; ind=32; indAbrv='Telcm'; end;
    else if 4892<=siccd<=4892 then do; ind=32; indAbrv='Telcm'; end;
    else if 4899<=siccd<=4899 then do; ind=32; indAbrv='Telcm'; end;
    else if 7020<=siccd<=7021 then do; ind=33; indAbrv='PerSv'; end;
    else if 7030<=siccd<=7033 then do; ind=33; indAbrv='PerSv'; end;
    else if 7200<=siccd<=7200 then do; ind=33; indAbrv='PerSv'; end;
    else if 7210<=siccd<=7212 then do; ind=33; indAbrv='PerSv'; end;
    else if 7214<=siccd<=7214 then do; ind=33; indAbrv='PerSv'; end;
    else if 7215<=siccd<=7216 then do; ind=33; indAbrv='PerSv'; end;
    else if 7217<=siccd<=7217 then do; ind=33; indAbrv='PerSv'; end;
    else if 7219<=siccd<=7219 then do; ind=33; indAbrv='PerSv'; end;
    else if 7220<=siccd<=7221 then do; ind=33; indAbrv='PerSv'; end;
    else if 7230<=siccd<=7231 then do; ind=33; indAbrv='PerSv'; end;
    else if 7240<=siccd<=7241 then do; ind=33; indAbrv='PerSv'; end;
    else if 7250<=siccd<=7251 then do; ind=33; indAbrv='PerSv'; end;
    else if 7260<=siccd<=7269 then do; ind=33; indAbrv='PerSv'; end;
    else if 7270<=siccd<=7290 then do; ind=33; indAbrv='PerSv'; end;
    else if 7291<=siccd<=7291 then do; ind=33; indAbrv='PerSv'; end;
    else if 7292<=siccd<=7299 then do; ind=33; indAbrv='PerSv'; end;
    else if 7395<=siccd<=7395 then do; ind=33; indAbrv='PerSv'; end;
    else if 7500<=siccd<=7500 then do; ind=33; indAbrv='PerSv'; end;
    else if 7520<=siccd<=7529 then do; ind=33; indAbrv='PerSv'; end;
    else if 7530<=siccd<=7539 then do; ind=33; indAbrv='PerSv'; end;
    else if 7540<=siccd<=7549 then do; ind=33; indAbrv='PerSv'; end;
    else if 7600<=siccd<=7600 then do; ind=33; indAbrv='PerSv'; end;
    else if 7620<=siccd<=7620 then do; ind=33; indAbrv='PerSv'; end;
    else if 7622<=siccd<=7622 then do; ind=33; indAbrv='PerSv'; end;
    else if 7623<=siccd<=7623 then do; ind=33; indAbrv='PerSv'; end;
    else if 7629<=siccd<=7629 then do; ind=33; indAbrv='PerSv'; end;
    else if 7630<=siccd<=7631 then do; ind=33; indAbrv='PerSv'; end;
    else if 7640<=siccd<=7641 then do; ind=33; indAbrv='PerSv'; end;
    else if 7690<=siccd<=7699 then do; ind=33; indAbrv='PerSv'; end;
    else if 8100<=siccd<=8199 then do; ind=33; indAbrv='PerSv'; end;
    else if 8200<=siccd<=8299 then do; ind=33; indAbrv='PerSv'; end;
    else if 8300<=siccd<=8399 then do; ind=33; indAbrv='PerSv'; end;
    else if 8400<=siccd<=8499 then do; ind=33; indAbrv='PerSv'; end;
    else if 8600<=siccd<=8699 then do; ind=33; indAbrv='PerSv'; end;
    else if 8800<=siccd<=8899 then do; ind=33; indAbrv='PerSv'; end;
    else if 7510<=siccd<=7515 then do; ind=33; indAbrv='PerSv'; end;
    else if 2750<=siccd<=2759 then do; ind=34; indAbrv='BusSv'; end;
    else if 3993<=siccd<=3993 then do; ind=34; indAbrv='BusSv'; end;
    else if 7218<=siccd<=7218 then do; ind=34; indAbrv='BusSv'; end;
    else if 7300<=siccd<=7300 then do; ind=34; indAbrv='BusSv'; end;
    else if 7310<=siccd<=7319 then do; ind=34; indAbrv='BusSv'; end;
    else if 7320<=siccd<=7329 then do; ind=34; indAbrv='BusSv'; end;
    else if 7330<=siccd<=7339 then do; ind=34; indAbrv='BusSv'; end;
    else if 7340<=siccd<=7342 then do; ind=34; indAbrv='BusSv'; end;
    else if 7349<=siccd<=7349 then do; ind=34; indAbrv='BusSv'; end;
    else if 7350<=siccd<=7351 then do; ind=34; indAbrv='BusSv'; end;
    else if 7352<=siccd<=7352 then do; ind=34; indAbrv='BusSv'; end;
    else if 7353<=siccd<=7353 then do; ind=34; indAbrv='BusSv'; end;
    else if 7359<=siccd<=7359 then do; ind=34; indAbrv='BusSv'; end;
    else if 7360<=siccd<=7369 then do; ind=34; indAbrv='BusSv'; end;
    else if 7370<=siccd<=7372 then do; ind=34; indAbrv='BusSv'; end;
    else if 7374<=siccd<=7374 then do; ind=34; indAbrv='BusSv'; end;
    else if 7375<=siccd<=7375 then do; ind=34; indAbrv='BusSv'; end;
    else if 7376<=siccd<=7376 then do; ind=34; indAbrv='BusSv'; end;
    else if 7377<=siccd<=7377 then do; ind=34; indAbrv='BusSv'; end;
    else if 7378<=siccd<=7378 then do; ind=34; indAbrv='BusSv'; end;
    else if 7379<=siccd<=7379 then do; ind=34; indAbrv='BusSv'; end;
    else if 7380<=siccd<=7380 then do; ind=34; indAbrv='BusSv'; end;
    else if 7381<=siccd<=7382 then do; ind=34; indAbrv='BusSv'; end;
    else if 7383<=siccd<=7383 then do; ind=34; indAbrv='BusSv'; end;
    else if 7384<=siccd<=7384 then do; ind=34; indAbrv='BusSv'; end;
    else if 7385<=siccd<=7385 then do; ind=34; indAbrv='BusSv'; end;
    else if 7389<=siccd<=7390 then do; ind=34; indAbrv='BusSv'; end;
    else if 7391<=siccd<=7391 then do; ind=34; indAbrv='BusSv'; end;
    else if 7392<=siccd<=7392 then do; ind=34; indAbrv='BusSv'; end;
    else if 7393<=siccd<=7393 then do; ind=34; indAbrv='BusSv'; end;
    else if 7394<=siccd<=7394 then do; ind=34; indAbrv='BusSv'; end;
    else if 7396<=siccd<=7396 then do; ind=34; indAbrv='BusSv'; end;
    else if 7397<=siccd<=7397 then do; ind=34; indAbrv='BusSv'; end;
    else if 7399<=siccd<=7399 then do; ind=34; indAbrv='BusSv'; end;
    else if 7519<=siccd<=7519 then do; ind=34; indAbrv='BusSv'; end;
    else if 8700<=siccd<=8700 then do; ind=34; indAbrv='BusSv'; end;
    else if 8710<=siccd<=8713 then do; ind=34; indAbrv='BusSv'; end;
    else if 8720<=siccd<=8721 then do; ind=34; indAbrv='BusSv'; end;
    else if 8730<=siccd<=8734 then do; ind=34; indAbrv='BusSv'; end;
    else if 8740<=siccd<=8748 then do; ind=34; indAbrv='BusSv'; end;
    else if 8900<=siccd<=8910 then do; ind=34; indAbrv='BusSv'; end;
    else if 8911<=siccd<=8911 then do; ind=34; indAbrv='BusSv'; end;
    else if 8920<=siccd<=8999 then do; ind=34; indAbrv='BusSv'; end;
    else if 4220<=siccd<=4229 then do; ind=34; indAbrv='BusSv'; end;
    else if 3570<=siccd<=3579 then do; ind=35; indAbrv='Comps'; end;
    else if 3680<=siccd<=3680 then do; ind=35; indAbrv='Comps'; end;
    else if 3681<=siccd<=3681 then do; ind=35; indAbrv='Comps'; end;
    else if 3682<=siccd<=3682 then do; ind=35; indAbrv='Comps'; end;
    else if 3683<=siccd<=3683 then do; ind=35; indAbrv='Comps'; end;
    else if 3684<=siccd<=3684 then do; ind=35; indAbrv='Comps'; end;
    else if 3685<=siccd<=3685 then do; ind=35; indAbrv='Comps'; end;
    else if 3686<=siccd<=3686 then do; ind=35; indAbrv='Comps'; end;
    else if 3687<=siccd<=3687 then do; ind=35; indAbrv='Comps'; end;
    else if 3688<=siccd<=3688 then do; ind=35; indAbrv='Comps'; end;
    else if 3689<=siccd<=3689 then do; ind=35; indAbrv='Comps'; end;
    else if 3695<=siccd<=3695 then do; ind=35; indAbrv='Comps'; end;
    else if 7373<=siccd<=7373 then do; ind=35; indAbrv='Comps'; end;
    else if 3622<=siccd<=3622 then do; ind=36; indAbrv='Chips'; end;
    else if 3661<=siccd<=3661 then do; ind=36; indAbrv='Chips'; end;
    else if 3662<=siccd<=3662 then do; ind=36; indAbrv='Chips'; end;
    else if 3663<=siccd<=3663 then do; ind=36; indAbrv='Chips'; end;
    else if 3664<=siccd<=3664 then do; ind=36; indAbrv='Chips'; end;
    else if 3665<=siccd<=3665 then do; ind=36; indAbrv='Chips'; end;
    else if 3666<=siccd<=3666 then do; ind=36; indAbrv='Chips'; end;
    else if 3669<=siccd<=3669 then do; ind=36; indAbrv='Chips'; end;
    else if 3670<=siccd<=3679 then do; ind=36; indAbrv='Chips'; end;
    else if 3810<=siccd<=3810 then do; ind=36; indAbrv='Chips'; end;
    else if 3812<=siccd<=3812 then do; ind=36; indAbrv='Chips'; end;
    else if 3811<=siccd<=3811 then do; ind=37; indAbrv='LabEq'; end;
    else if 3820<=siccd<=3820 then do; ind=37; indAbrv='LabEq'; end;
    else if 3821<=siccd<=3821 then do; ind=37; indAbrv='LabEq'; end;
    else if 3822<=siccd<=3822 then do; ind=37; indAbrv='LabEq'; end;
    else if 3823<=siccd<=3823 then do; ind=37; indAbrv='LabEq'; end;
    else if 3824<=siccd<=3824 then do; ind=37; indAbrv='LabEq'; end;
    else if 3825<=siccd<=3825 then do; ind=37; indAbrv='LabEq'; end;
    else if 3826<=siccd<=3826 then do; ind=37; indAbrv='LabEq'; end;
    else if 3827<=siccd<=3827 then do; ind=37; indAbrv='LabEq'; end;
    else if 3829<=siccd<=3829 then do; ind=37; indAbrv='LabEq'; end;
    else if 3830<=siccd<=3839 then do; ind=37; indAbrv='LabEq'; end;
    else if 2520<=siccd<=2549 then do; ind=38; indAbrv='Paper'; end;
    else if 2600<=siccd<=2639 then do; ind=38; indAbrv='Paper'; end;
    else if 2670<=siccd<=2699 then do; ind=38; indAbrv='Paper'; end;
    else if 2760<=siccd<=2761 then do; ind=38; indAbrv='Paper'; end;
    else if 3950<=siccd<=3955 then do; ind=38; indAbrv='Paper'; end;
    else if 2440<=siccd<=2449 then do; ind=39; indAbrv='Boxes'; end;
    else if 2640<=siccd<=2659 then do; ind=39; indAbrv='Boxes'; end;
    else if 3220<=siccd<=3221 then do; ind=39; indAbrv='Boxes'; end;
    else if 3410<=siccd<=3412 then do; ind=39; indAbrv='Boxes'; end;
    else if 4000<=siccd<=4013 then do; ind=40; indAbrv='Trans'; end;
    else if 4040<=siccd<=4049 then do; ind=40; indAbrv='Trans'; end;
    else if 4100<=siccd<=4100 then do; ind=40; indAbrv='Trans'; end;
    else if 4110<=siccd<=4119 then do; ind=40; indAbrv='Trans'; end;
    else if 4120<=siccd<=4121 then do; ind=40; indAbrv='Trans'; end;
    else if 4130<=siccd<=4131 then do; ind=40; indAbrv='Trans'; end;
    else if 4140<=siccd<=4142 then do; ind=40; indAbrv='Trans'; end;
    else if 4150<=siccd<=4151 then do; ind=40; indAbrv='Trans'; end;
    else if 4170<=siccd<=4173 then do; ind=40; indAbrv='Trans'; end;
    else if 4190<=siccd<=4199 then do; ind=40; indAbrv='Trans'; end;
    else if 4200<=siccd<=4200 then do; ind=40; indAbrv='Trans'; end;
    else if 4210<=siccd<=4219 then do; ind=40; indAbrv='Trans'; end;
    else if 4230<=siccd<=4231 then do; ind=40; indAbrv='Trans'; end;
    else if 4240<=siccd<=4249 then do; ind=40; indAbrv='Trans'; end;
    else if 4400<=siccd<=4499 then do; ind=40; indAbrv='Trans'; end;
    else if 4500<=siccd<=4599 then do; ind=40; indAbrv='Trans'; end;
    else if 4600<=siccd<=4699 then do; ind=40; indAbrv='Trans'; end;
    else if 4700<=siccd<=4700 then do; ind=40; indAbrv='Trans'; end;
    else if 4710<=siccd<=4712 then do; ind=40; indAbrv='Trans'; end;
    else if 4720<=siccd<=4729 then do; ind=40; indAbrv='Trans'; end;
    else if 4730<=siccd<=4739 then do; ind=40; indAbrv='Trans'; end;
    else if 4740<=siccd<=4749 then do; ind=40; indAbrv='Trans'; end;
    else if 4780<=siccd<=4780 then do; ind=40; indAbrv='Trans'; end;
    else if 4782<=siccd<=4782 then do; ind=40; indAbrv='Trans'; end;
    else if 4783<=siccd<=4783 then do; ind=40; indAbrv='Trans'; end;
    else if 4784<=siccd<=4784 then do; ind=40; indAbrv='Trans'; end;
    else if 4785<=siccd<=4785 then do; ind=40; indAbrv='Trans'; end;
    else if 4789<=siccd<=4789 then do; ind=40; indAbrv='Trans'; end;
    else if 5000<=siccd<=5000 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5010<=siccd<=5015 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5020<=siccd<=5023 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5030<=siccd<=5039 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5040<=siccd<=5042 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5043<=siccd<=5043 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5044<=siccd<=5044 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5045<=siccd<=5045 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5046<=siccd<=5046 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5047<=siccd<=5047 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5048<=siccd<=5048 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5049<=siccd<=5049 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5050<=siccd<=5059 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5060<=siccd<=5060 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5063<=siccd<=5063 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5064<=siccd<=5064 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5065<=siccd<=5065 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5070<=siccd<=5078 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5080<=siccd<=5080 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5081<=siccd<=5081 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5082<=siccd<=5082 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5083<=siccd<=5083 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5084<=siccd<=5084 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5085<=siccd<=5085 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5086<=siccd<=5087 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5088<=siccd<=5088 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5090<=siccd<=5090 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5091<=siccd<=5092 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5093<=siccd<=5093 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5094<=siccd<=5094 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5099<=siccd<=5099 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5100<=siccd<=5100 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5110<=siccd<=5113 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5120<=siccd<=5122 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5130<=siccd<=5139 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5140<=siccd<=5149 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5150<=siccd<=5159 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5160<=siccd<=5169 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5170<=siccd<=5172 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5180<=siccd<=5182 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5190<=siccd<=5199 then do; ind=41; indAbrv='Whlsl'; end;
    else if 5200<=siccd<=5200 then do; ind=42; indAbrv='Rtail'; end;
    else if 5210<=siccd<=5219 then do; ind=42; indAbrv='Rtail'; end;
    else if 5220<=siccd<=5229 then do; ind=42; indAbrv='Rtail'; end;
    else if 5230<=siccd<=5231 then do; ind=42; indAbrv='Rtail'; end;
    else if 5250<=siccd<=5251 then do; ind=42; indAbrv='Rtail'; end;
    else if 5260<=siccd<=5261 then do; ind=42; indAbrv='Rtail'; end;
    else if 5270<=siccd<=5271 then do; ind=42; indAbrv='Rtail'; end;
    else if 5300<=siccd<=5300 then do; ind=42; indAbrv='Rtail'; end;
    else if 5310<=siccd<=5311 then do; ind=42; indAbrv='Rtail'; end;
    else if 5320<=siccd<=5320 then do; ind=42; indAbrv='Rtail'; end;
    else if 5330<=siccd<=5331 then do; ind=42; indAbrv='Rtail'; end;
    else if 5334<=siccd<=5334 then do; ind=42; indAbrv='Rtail'; end;
    else if 5340<=siccd<=5349 then do; ind=42; indAbrv='Rtail'; end;
    else if 5390<=siccd<=5399 then do; ind=42; indAbrv='Rtail'; end;
    else if 5400<=siccd<=5400 then do; ind=42; indAbrv='Rtail'; end;
    else if 5410<=siccd<=5411 then do; ind=42; indAbrv='Rtail'; end;
    else if 5412<=siccd<=5412 then do; ind=42; indAbrv='Rtail'; end;
    else if 5420<=siccd<=5429 then do; ind=42; indAbrv='Rtail'; end;
    else if 5430<=siccd<=5439 then do; ind=42; indAbrv='Rtail'; end;
    else if 5440<=siccd<=5449 then do; ind=42; indAbrv='Rtail'; end;
    else if 5450<=siccd<=5459 then do; ind=42; indAbrv='Rtail'; end;
    else if 5460<=siccd<=5469 then do; ind=42; indAbrv='Rtail'; end;
    else if 5490<=siccd<=5499 then do; ind=42; indAbrv='Rtail'; end;
    else if 5500<=siccd<=5500 then do; ind=42; indAbrv='Rtail'; end;
    else if 5510<=siccd<=5529 then do; ind=42; indAbrv='Rtail'; end;
    else if 5530<=siccd<=5539 then do; ind=42; indAbrv='Rtail'; end;
    else if 5540<=siccd<=5549 then do; ind=42; indAbrv='Rtail'; end;
    else if 5550<=siccd<=5559 then do; ind=42; indAbrv='Rtail'; end;
    else if 5560<=siccd<=5569 then do; ind=42; indAbrv='Rtail'; end;
    else if 5570<=siccd<=5579 then do; ind=42; indAbrv='Rtail'; end;
    else if 5590<=siccd<=5599 then do; ind=42; indAbrv='Rtail'; end;
    else if 5600<=siccd<=5699 then do; ind=42; indAbrv='Rtail'; end;
    else if 5700<=siccd<=5700 then do; ind=42; indAbrv='Rtail'; end;
    else if 5710<=siccd<=5719 then do; ind=42; indAbrv='Rtail'; end;
    else if 5720<=siccd<=5722 then do; ind=42; indAbrv='Rtail'; end;
    else if 5730<=siccd<=5733 then do; ind=42; indAbrv='Rtail'; end;
    else if 5734<=siccd<=5734 then do; ind=42; indAbrv='Rtail'; end;
    else if 5735<=siccd<=5735 then do; ind=42; indAbrv='Rtail'; end;
    else if 5736<=siccd<=5736 then do; ind=42; indAbrv='Rtail'; end;
    else if 5750<=siccd<=5799 then do; ind=42; indAbrv='Rtail'; end;
    else if 5900<=siccd<=5900 then do; ind=42; indAbrv='Rtail'; end;
    else if 5910<=siccd<=5912 then do; ind=42; indAbrv='Rtail'; end;
    else if 5920<=siccd<=5929 then do; ind=42; indAbrv='Rtail'; end;
    else if 5930<=siccd<=5932 then do; ind=42; indAbrv='Rtail'; end;
    else if 5940<=siccd<=5940 then do; ind=42; indAbrv='Rtail'; end;
    else if 5941<=siccd<=5941 then do; ind=42; indAbrv='Rtail'; end;
    else if 5942<=siccd<=5942 then do; ind=42; indAbrv='Rtail'; end;
    else if 5943<=siccd<=5943 then do; ind=42; indAbrv='Rtail'; end;
    else if 5944<=siccd<=5944 then do; ind=42; indAbrv='Rtail'; end;
    else if 5945<=siccd<=5945 then do; ind=42; indAbrv='Rtail'; end;
    else if 5946<=siccd<=5946 then do; ind=42; indAbrv='Rtail'; end;
    else if 5947<=siccd<=5947 then do; ind=42; indAbrv='Rtail'; end;
    else if 5948<=siccd<=5948 then do; ind=42; indAbrv='Rtail'; end;
    else if 5949<=siccd<=5949 then do; ind=42; indAbrv='Rtail'; end;
    else if 5950<=siccd<=5959 then do; ind=42; indAbrv='Rtail'; end;
    else if 5960<=siccd<=5969 then do; ind=42; indAbrv='Rtail'; end;
    else if 5970<=siccd<=5979 then do; ind=42; indAbrv='Rtail'; end;
    else if 5980<=siccd<=5989 then do; ind=42; indAbrv='Rtail'; end;
    else if 5990<=siccd<=5990 then do; ind=42; indAbrv='Rtail'; end;
    else if 5992<=siccd<=5992 then do; ind=42; indAbrv='Rtail'; end;
    else if 5993<=siccd<=5993 then do; ind=42; indAbrv='Rtail'; end;
    else if 5994<=siccd<=5994 then do; ind=42; indAbrv='Rtail'; end;
    else if 5995<=siccd<=5995 then do; ind=42; indAbrv='Rtail'; end;
    else if 5999<=siccd<=5999 then do; ind=42; indAbrv='Rtail'; end;
    else if 5800<=siccd<=5819 then do; ind=43; indAbrv='Meals'; end;
    else if 5820<=siccd<=5829 then do; ind=43; indAbrv='Meals'; end;
    else if 5890<=siccd<=5899 then do; ind=43; indAbrv='Meals'; end;
    else if 7000<=siccd<=7000 then do; ind=43; indAbrv='Meals'; end;
    else if 7010<=siccd<=7019 then do; ind=43; indAbrv='Meals'; end;
    else if 7040<=siccd<=7049 then do; ind=43; indAbrv='Meals'; end;
    else if 7213<=siccd<=7213 then do; ind=43; indAbrv='Meals'; end;
    else if 6000<=siccd<=6000 then do; ind=44; indAbrv='Banks'; end;
    else if 6010<=siccd<=6019 then do; ind=44; indAbrv='Banks'; end;
    else if 6020<=siccd<=6020 then do; ind=44; indAbrv='Banks'; end;
    else if 6021<=siccd<=6021 then do; ind=44; indAbrv='Banks'; end;
    else if 6022<=siccd<=6022 then do; ind=44; indAbrv='Banks'; end;
    else if 6023<=siccd<=6024 then do; ind=44; indAbrv='Banks'; end;
    else if 6025<=siccd<=6025 then do; ind=44; indAbrv='Banks'; end;
    else if 6026<=siccd<=6026 then do; ind=44; indAbrv='Banks'; end;
    else if 6027<=siccd<=6027 then do; ind=44; indAbrv='Banks'; end;
    else if 6028<=siccd<=6029 then do; ind=44; indAbrv='Banks'; end;
    else if 6030<=siccd<=6036 then do; ind=44; indAbrv='Banks'; end;
    else if 6040<=siccd<=6059 then do; ind=44; indAbrv='Banks'; end;
    else if 6060<=siccd<=6062 then do; ind=44; indAbrv='Banks'; end;
    else if 6080<=siccd<=6082 then do; ind=44; indAbrv='Banks'; end;
    else if 6090<=siccd<=6099 then do; ind=44; indAbrv='Banks'; end;
    else if 6100<=siccd<=6100 then do; ind=44; indAbrv='Banks'; end;
    else if 6110<=siccd<=6111 then do; ind=44; indAbrv='Banks'; end;
    else if 6112<=siccd<=6113 then do; ind=44; indAbrv='Banks'; end;
    else if 6120<=siccd<=6129 then do; ind=44; indAbrv='Banks'; end;
    else if 6130<=siccd<=6139 then do; ind=44; indAbrv='Banks'; end;
    else if 6140<=siccd<=6149 then do; ind=44; indAbrv='Banks'; end;
    else if 6150<=siccd<=6159 then do; ind=44; indAbrv='Banks'; end;
    else if 6160<=siccd<=6169 then do; ind=44; indAbrv='Banks'; end;
    else if 6170<=siccd<=6179 then do; ind=44; indAbrv='Banks'; end;
    else if 6190<=siccd<=6199 then do; ind=44; indAbrv='Banks'; end;
    else if 6300<=siccd<=6300 then do; ind=45; indAbrv='Insur'; end;
    else if 6310<=siccd<=6319 then do; ind=45; indAbrv='Insur'; end;
    else if 6320<=siccd<=6329 then do; ind=45; indAbrv='Insur'; end;
    else if 6330<=siccd<=6331 then do; ind=45; indAbrv='Insur'; end;
    else if 6350<=siccd<=6351 then do; ind=45; indAbrv='Insur'; end;
    else if 6360<=siccd<=6361 then do; ind=45; indAbrv='Insur'; end;
    else if 6370<=siccd<=6379 then do; ind=45; indAbrv='Insur'; end;
    else if 6390<=siccd<=6399 then do; ind=45; indAbrv='Insur'; end;
    else if 6400<=siccd<=6411 then do; ind=45; indAbrv='Insur'; end;
    else if 6500<=siccd<=6500 then do; ind=46; indAbrv='RlEst'; end;
    else if 6510<=siccd<=6510 then do; ind=46; indAbrv='RlEst'; end;
    else if 6512<=siccd<=6512 then do; ind=46; indAbrv='RlEst'; end;
    else if 6513<=siccd<=6513 then do; ind=46; indAbrv='RlEst'; end;
    else if 6514<=siccd<=6514 then do; ind=46; indAbrv='RlEst'; end;
    else if 6515<=siccd<=6515 then do; ind=46; indAbrv='RlEst'; end;
    else if 6517<=siccd<=6519 then do; ind=46; indAbrv='RlEst'; end;
    else if 6520<=siccd<=6529 then do; ind=46; indAbrv='RlEst'; end;
    else if 6530<=siccd<=6531 then do; ind=46; indAbrv='RlEst'; end;
    else if 6532<=siccd<=6532 then do; ind=46; indAbrv='RlEst'; end;
    else if 6540<=siccd<=6541 then do; ind=46; indAbrv='RlEst'; end;
    else if 6550<=siccd<=6553 then do; ind=46; indAbrv='RlEst'; end;
    else if 6590<=siccd<=6599 then do; ind=46; indAbrv='RlEst'; end;
    else if 6610<=siccd<=6611 then do; ind=46; indAbrv='RlEst'; end;
    else if 6200<=siccd<=6299 then do; ind=47; indAbrv='Fin'; end;
    else if 6700<=siccd<=6700 then do; ind=47; indAbrv='Fin'; end;
    else if 6710<=siccd<=6719 then do; ind=47; indAbrv='Fin'; end;
    else if 6720<=siccd<=6722 then do; ind=47; indAbrv='Fin'; end;
    else if 6723<=siccd<=6723 then do; ind=47; indAbrv='Fin'; end;
    else if 6724<=siccd<=6724 then do; ind=47; indAbrv='Fin'; end;
    else if 6725<=siccd<=6725 then do; ind=47; indAbrv='Fin'; end;
    else if 6726<=siccd<=6726 then do; ind=47; indAbrv='Fin'; end;
    else if 6730<=siccd<=6733 then do; ind=47; indAbrv='Fin'; end;
    else if 6740<=siccd<=6779 then do; ind=47; indAbrv='Fin'; end;
    else if 6790<=siccd<=6791 then do; ind=47; indAbrv='Fin'; end;
    else if 6792<=siccd<=6792 then do; ind=47; indAbrv='Fin'; end;
    else if 6793<=siccd<=6793 then do; ind=47; indAbrv='Fin'; end;
    else if 6794<=siccd<=6794 then do; ind=47; indAbrv='Fin'; end;
    else if 6795<=siccd<=6795 then do; ind=47; indAbrv='Fin'; end;
    else if 6798<=siccd<=6798 then do; ind=47; indAbrv='Fin'; end;
    else if 6799<=siccd<=6799 then do; ind=47; indAbrv='Fin'; end;
    else if 4950<=siccd<=4959 then do; ind=48; indAbrv='Other'; end;
    else if 4960<=siccd<=4961 then do; ind=48; indAbrv='Other'; end;
    else if 4970<=siccd<=4971 then do; ind=48; indAbrv='Other'; end;
    else if 4990<=siccd<=4991 then do; ind=48; indAbrv='Other'; end;
RUN;


PROC PRINT
    DATA = retxData(obs = 10);
    TITLE 'First 10 observations of cleaned daily CRSP data with industry codes.'; 
RUN;


PROC SORT
    DATA = retxData;
    BY year month indAbrv permno;
RUN;

PROC MEANS
    DATA = retxData
    NOPRINT;
    BY year month indAbrv permno;
    OUTPUT OUT = obsPerMonthData
           N   = obsPerMonth;
RUN;

PROC SORT
    DATA = obsPerMonthData;
    BY year month indAbrv;
RUN;

PROC MEANS
    DATA = obsPerMonthData
    NOPRINT;
    BY year month indAbrv;
    OUTPUT OUT = obsPerMonthData
           N   = obsPerMonth;
RUN;

PROC EXPORT
    DATA    = obsPerMonthData
    OUTFILE = "clmx01-observations-per-month.csv"
    DBMS    = CSV
    REPLACE;    
RUN;










    
;/*************************************************************************************
    @section: COMPUTE MARKET VARIANCE
    -----------------------------------------------------------------------------------
    @desc:    Compute value weighted daily market return. Compute value weighted market
              variance. Print summary statistics of the value weighted market variance.
**************************************************************************************/

PROC SORT
    DATA = retxData;
    BY year month date;
RUN;

PROC MEANS
    DATA = retxData
    NOPRINT;
    BY year month date;
    WEIGHT mktCap;
    VAR retx;
    OUTPUT OUT  = vwMktRetxData
           MEAN = vwMktRetx;
RUN;

PROC MEANS
    DATA = vwMktRetxData
    NOPRINT;
    BY year month;
    VAR vwMktRetx;
    OUTPUT OUT = mktVarData
           VAR = mktVar;
RUN;

PROC MEANS
    DATA = mktVarData
    n nmiss mean median std min max;
    VAR year month mktVar;
RUN;

PROC PRINT
    DATA = mktVarData(obs = 10);
RUN;








;/*************************************************************************************
    @section: COMPUTE EXPECTED INDUSTRY VARIANCE
    -----------------------------------------------------------------------------------
    @desc:    Compute value weighted daily industry return. Compute monthly average
              market cap for each industry. Compute daily value weighted industry return
              in excess of market return for each industry. Compute monthly variance of
              value weighted industry return in excess of market return for each industry.
              Compute value weighted industry specific variance.  Print summary statistics
              of the value weighted industry specific variance.
**************************************************************************************/

PROC SORT
    DATA = retxData;
    BY year month date ind;
RUN;

PROC MEANS
    DATA = retxData
    NOPRINT;
    BY year month date ind;
    WEIGHT mktCap;
    VAR retx;
    OUTPUT OUT  = vwIndRetxData
           MEAN = vwIndRetx;
RUN;

PROC SORT
    DATA = retxData;
    BY year month ind permno;
RUN;

PROC MEANS
    DATA = retxData
    NOPRINT;
    BY year month ind permno;
    VAR mktCap;
    OUTPUT OUT  = firmMktCapData
           MEAN = firmMktCap;
RUN;

PROC SORT
    DATA = firmMktCapData;
    BY year month ind;
RUN;

PROC MEANS
    DATA = firmMktCapData
    NOPRINT;
    BY year month ind;
    VAR firmMktCap;
    OUTPUT OUT = indMktCapData
           SUM = indMktCap;
RUN;

PROC SQL;
    CREATE TABLE vwIndSpecRetxData AS 
        SELECT a.year,
               a.month,
               a.date,
               a.ind,
               (a.vwIndRetx - b.vwMktRetx) as vwIndSpecRetx
        FROM vwIndRetxData AS a,
             vwMktRetxData AS b
        WHERE (a.date = b.date);
QUIT;

PROC SORT
    DATA = vwIndSpecRetxData;
    BY year month ind;
RUN;

PROC MEANS
    DATA = vwIndSpecRetxData
    NOPRINT;
    BY year month ind;
    VAR vwIndSpecRetx;
    OUTPUT OUT = indSpecRetxVarData
           VAR = indSpecRetxVar;
RUN;

PROC SQL;
    CREATE TABLE indVarData AS 
        SELECT a.year,
               a.month,
               a.ind,
               a.indSpecRetxVar,
               b.indMktCap
        FROM indSpecRetxVarData AS a,
             indMktCapData AS b
        WHERE (a.year = b.year) AND (a.month = b.month) AND (a.ind = b.ind);
QUIT;

PROC SORT
    DATA = indVarData;
    BY year month;
RUN;

PROC MEANS
    DATA = indVarData
    NOPRINT;
    BY year month;
    WEIGHT indMktCap;
    VAR indSpecRetxVar;
    OUTPUT OUT  = indVarData
           MEAN = indVar;
RUN;

PROC MEANS
    DATA = indVarData
    n nmiss mean median std min max;
    VAR year month indVar;
RUN;

PROC PRINT
    DATA = indVarData(obs = 10);
RUN;




;/*************************************************************************************
    @section: COMPUTE EXPECTED FIRM LEVEL VARIANCE
    -----------------------------------------------------------------------------------
    @desc:    Compute value weighted daily industry return. Compute monthly average
              market cap for each firm. Compute daily return for each firm in excess of
              the value weighted industry return. Compute monthly variance of excess
              daily firm returns. Compute value weighted firm specific variance. Print
              summary statistics of the value weighted firm specific variance.
**************************************************************************************/

PROC SORT
    DATA = retxData;
    BY year month date ind;
RUN;

PROC MEANS
    DATA = retxData
    NOPRINT;
    BY year month date ind;
    WEIGHT mktCap;
    VAR retx;
    OUTPUT OUT  = vwIndRetxData
           MEAN = vwIndRetx;
RUN;

PROC SORT
    DATA = retxData;
    BY year month permno;
RUN;

PROC MEANS
    DATA = retxData
    NOPRINT;
    BY year month permno;
    VAR mktCap;
    OUTPUT OUT  = firmMktCapData
           MEAN = firmMktCap;
RUN;

PROC SQL;
    CREATE TABLE firmSpecRetxData AS 
        SELECT a.year,
               a.month,
               a.date,
               a.permno,
               a.ind,
               (a.retx - b.vwIndRetx) as firmSpecRetx,
               a.mktCap
        FROM retxData AS a,
             vwIndRetxData AS b
        WHERE (a.date = b.date) AND (a.ind = b.ind);
QUIT;

PROC SORT
    DATA = firmSpecRetxData;
    BY year month ind permno;
RUN;

PROC MEANS
    DATA = firmSpecRetxData
    NOPRINT;
    BY year month ind permno;
    VAR firmSpecRetx;
    OUTPUT OUT = firmSpecRetxVarData
           VAR = firmSpecRetxVar;
RUN;

PROC SQL;
    CREATE TABLE firmSpecRetxVarData AS 
        SELECT a.year,
               a.month,
               a.ind,
               a.firmSpecRetxVar,
               b.firmMktCap
        FROM firmSpecRetxVarData AS a,
             firmMktCapData AS b
        WHERE (a.year = b.year) AND (a.month = b.month) AND (a.permno = b.permno);
QUIT;

PROC SORT
    DATA = firmSpecRetxVarData;
    BY year month ind;
RUN;

PROC MEANS
    DATA = firmSpecRetxVarData
    NOPRINT;
    BY year month ind;
    WEIGHT firmMktCap;
    VAR firmSpecRetxVar;
    OUTPUT OUT  = vwFirmSpecRetxVarData
           MEAN = vwFirmSpecRetxVar;
RUN;

PROC SQL;
    CREATE TABLE vwFirmSpecRetxVarData AS 
        SELECT a.year,
               a.month,
               a.ind,
               a.vwFirmSpecRetxVar,
               b.indMktCap
        FROM vwFirmSpecRetxVarData AS a,
             indMktCapData AS b
        WHERE (a.year = b.year) AND (a.month = b.month) AND (a.ind = b.ind);
QUIT;

PROC SORT
    DATA = vwFirmSpecRetxVarData;
    BY year month;
RUN;
    
PROC MEANS
    DATA = vwFirmSpecRetxVarData
    NOPRINT;
    BY year month;
    WEIGHT indMktCap;
    VAR vwFirmSpecRetxVar;
    OUTPUT OUT  = firmVarData
           MEAN = firmVar;
RUN;

PROC MEANS
    DATA = firmVarData
    n nmiss mean median std min max;
    VAR year month firmVar;
RUN;

PROC PRINT
    DATA = firmVarData(obs = 10);
RUN;






    
;/*************************************************************************************
    @section: PRINT DATA TO CSV
    -----------------------------------------------------------------------------------
    @desc:    Create dataset to export as a CSV text file. Export CLMX01 variance
              measures to a CSV text file.
**************************************************************************************/

PROC SQL;
    CREATE TABLE outData AS 
        SELECT a.year,
               a.month,
               a.mktVar,
               b.indVar
        FROM mktVarData AS a,
             indVarData AS b
        WHERE (a.year = b.year) AND (a.month = b.month);
QUIT;

PROC SQL;
    CREATE TABLE outData AS 
        SELECT a.year,
               a.month,
               a.mktVar,
               a.indVar,
               b.firmVar
        FROM outData AS a,
             firmVarData AS b
        WHERE (a.year = b.year) AND (a.month = b.month);
QUIT;

PROC EXPORT
    DATA    = outData
    OUTFILE = "clmx01-variance-decomposition-time-series.csv"
    DBMS    = CSV
    REPLACE;    
RUN;
