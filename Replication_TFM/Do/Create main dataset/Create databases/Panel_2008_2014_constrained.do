clear all
set more off
set maxvar 10000


use "$path/Data/panel_2008_2014.dta", clear



****************************************************************************************************************************************
****************************************************************************************************************************************
****** Sample and variables selection
****************************************************************************************************************************************
****************************************************************************************************************************************


egen id=group(imputation h_2014)
	xtset id year, delta(3)

forvalues i=1/9{
g age_`i'=year-p1_2b_`i'
}


forvalues i=1/9{
	replace pan_`i'=. if year==2008
}

g mark=0
forvalues i=1/9{
replace mark=1 if pan_`i'<=0 & age_`i'>19
} 
bys imputation h_2014: egen mark_sum=sum(mark) 
drop if mark_sum!=0



drop mark mark_sum
g mark=0
forvalues i=1/9{
    forvalues j=1/9{
replace mark=1 if pan_`i'==1 & year==2011
replace mark=1 if pan_`j'==`i' & year==2014
} 
}
bys imputation h_2014: egen mark_sum=sum(mark) 
drop if mark_sum!=2


drop mark mark_sum
g mark=0
forvalues i=1/9{
replace mark=1 if pan_`i'==1 & year==2014
} 
bys imputation h_2014: egen mark_sum=sum(mark) 
drop if mark_sum==0

drop mark mark_sum
g couple=0
forvalues i=1/9{
		replace couple=`i' if p1_3_`i'==2 & year==2011
}

bys imputation h_2014: egen couple_sum=sum(couple)


g mark=0
forvalues j=1/9{
forvalues i=1/9{
	replace mark=1 if couple_sum==`i' & pan_`j'==`i' & year==2014
	replace mark=1 if couple_sum==`i' & pan_`i'!=. & pan_`i'!=0 & year==2011
	}
}
bys imputation h_2014: egen mark_sum=sum(mark)
drop if mark_sum<=1 & couple_sum!=0

drop mark mark_sum couple couple_sum



sort imputation h_2014 year
bysort imputation h_2014: g pan_1_2011=pan_1[2]

g mark=0
forvalues i=2/9{
   replace mark=1 if pan_1_2011==`i' & p1_3_`i'!=2 & year==2008 
}
bys imputation h_2014: egen mark_sum=sum(mark)
drop if mark_sum!=0
drop pan_1_2011
drop mark mark_sum


**********************
* We organize the members of the household
**********************

forvalues j=1/9{
forvalues i=2008(3)2014{
g pan_`j'_`i'=pan_`j' if year==`i'
bys imputation h_2014: egen pan_`j'_`i'_prueba=sum(pan_`j'_`i')  
replace pan_`j'_`i'_prueba=. if pan_`j'_`i'_prueba==0 
drop pan_`j'_`i'
rename  pan_`j'_`i'_prueba pan_`j'_`i'
}
}




forvalues i=1/9{
g jobdur_`i'=0
replace jobdur_`i'= 1 if p6_17_`i'_1<=1 & p6_17_`i'_1!=.
replace jobdur_`i'= 2 if p6_17_`i'_1>1 & p6_17_`i'_1<=5
replace jobdur_`i'= 3 if p6_17_`i'_1>5 & p6_17_`i'_1!=.
}


forvalues i=1/9{
rename p6_21_`i'_1 expect_`i'
}


forvalues i=1/9{
rename p6_13_`i'_1 p6_13_`i'
}

local vlist ""
local vlist `vlist'  jobdur_ p1_1_ p1_2b_ p6_1c1_ p6_1c2_ p6_1c3_ p6_1c4_ p6_1c5_ p6_1c6_ p6_1c7_ p6_1c8_ p1_3_  ///
p1_7_ p1_5_ p6_3_ p6_4_ p6_63c1_ p6_63c2_ p6_63c3_ p6_63c4_ p6_63c5_ p6_63c6_ p6_63c7_ p6_63c8_  expect_ p6_13_


forvalues i=1/9{
foreach var in `vlist'{
g `var'`i'_intermedio=`var'`i' if year==2011
}
}


* Linking 2008 and 2011
forvalues i=1/9{
forvalues j=1/9{
foreach var in `vlist'{
replace `var'`i'_intermedio=`var'`j' if pan_`i'_2011==`j' & year==2008
}
}
}

* Linking 2014 and 2011
forvalues i=1/9{
forvalues j=1/9{
foreach var in `vlist'{
replace `var'`i'_intermedio=`var'`j' if pan_`j'_2014==`i' & year==2014
}
}
}


forvalues i=1/9{
foreach var in `vlist'{
g `var'`i'_prueba=`var'`i'_intermedio if year==2008 | year==2011 | year==2014
}
}



drop *intermedio


g pareja=0
forvalues i=2/9{
replace pareja=`i' if p1_3_`i'==2 & year==2011
}

bys imputation h_2014: egen pareja_prueba=sum(pareja)



foreach var in `vlist'{ 
g `var'pareja=`var'2_prueba if pareja_prueba==2
}

forvalues i=3/9{
foreach var in `vlist'{ 
replace `var'pareja=`var'`i'_prueba if pareja_prueba==`i'
}
}


********* We repair by hand clear mistakes regarding the sex of the members of the households

bys imputation h_2014: egen p1_prueba_sd=sd(p1_1_1_prueba)
br imputation h_2014 year p1_1_1_prueba if p1_prueba_sd!=0
drop p1_prueba_sd

bys imputation h_2014: egen p1_pareja_sd=sd(p1_1_pareja)
br imputation h_2014 year p1_1_pareja if p1_pareja_sd!=0 & p1_pareja_sd!=.
drop p1_pareja_sd



drop age_*
forvalues i=1/9{
g age_`i'_prueba=year-p1_2b_`i'_prueba
}

forvalues i=1/9{
g age_`i'=year-p1_2b_`i'
}



g mark=0
replace mark=1 if age_1_prueba<25
bys h_2014: egen marksum=sum(mark)

drop if marksum!=0


g exo_inter=0
replace exo_inter=1 if p2_3<=2008 & year==2014

bys h_2014: egen exo_sum=sum(exo_inter)
g exo=0
replace exo=1 if exo_sum!=0

g signal_inter=0
replace signal_inter=1 if p2_1!=2
bys h_2014: egen signal_sum=sum(signal_inter)

g signal=0
replace signal=1 if signal_sum!=0

keep if signal_sum==0

keep if exo==1
drop exo* signal*


g years_house=year-p2_3



capture drop p6_17_*  ///
jobdur_1 jobdur_2 jobdur_3 jobdur_4 jobdur_5 jobdur_6 jobdur_7 jobdur_8 jobdur_9  p1_1_1  p1_1_2  p1_1_3  p1_1_4  p1_1_5  p1_1_6  p1_1_7  p1_1_8  p1_1_9 ///
  p6_1c3_1 p6_1c4_1 p6_1c6_1 p6_1c7_1 p6_1c8_1  p1_7_1 p1_5_1 p6_3_1 p6_4_1 p6_62_1 p6_63c1_1 p6_63c2_1 p6_63c3_1 ///
p6_63c4_1 p6_63c5_1 p6_63c6_1 p6_63c7_1 p6_63c8_1  expect_1  p6_1c3_2 p6_1c4_2 p6_1c6_2 p6_1c7_2 p6_1c8_2  p1_7_2 p1_5_2 ///
p6_3_2 p6_4_2 p6_62_2 p6_63c1_2 p6_63c2_2 p6_63c3_2 p6_63c4_2 p6_63c5_2 p6_63c6_2 p6_63c7_2 p6_63c8_2  expect_2   p6_1c3_3 p6_1c4_3 ///
p6_1c6_3 p6_1c7_3 p6_1c8_3  p1_7_3 p1_5_3 p6_3_3 p6_4_3 p6_62_3 p6_63c1_3 p6_63c2_3 p6_63c3_3 p6_63c4_3 p6_63c5_3 p6_63c6_3 p6_63c7_3 p6_63c8_3 expect_3  ///
 p6_1c3_4 p6_1c4_4 p6_1c6_4 p6_1c7_4 p6_1c8_4 p1_7_4 p1_5_4 p6_3_4 p6_4_4 p6_62_4 p6_63c1_4 p6_63c2_4 p6_63c3_4 p6_63c4_4 p6_63c5_4 p6_63c6_4  ///
p6_63c7_4 p6_63c8_4  expect_4   p6_1c3_5 p6_1c4_5 p6_1c6_5 p6_1c7_5 p6_1c8_5  p1_7_5 p1_5_5 p6_3_5 p6_4_5 p6_62_5 p6_63c1_5 ///
p6_63c2_5 p6_63c3_5 p6_63c4_5 p6_63c5_5 p6_63c6_5 p6_63c7_5 p6_63c8_5  expect_5  p6_1c3_6 p6_1c4_6 p6_1c6_6 p6_1c7_6 p6_1c8_6  p1_7_6 ///
p1_5_6 p6_3_6 p6_4_6 p6_62_6 p6_63c1_6 p6_63c2_6 p6_63c3_6 p6_63c4_6 p6_63c5_6 p6_63c6_6 p6_63c7_6 p6_63c8_6  expect_6   p6_1c3_7 p6_1c4_7  ///
p6_1c6_7 p6_1c7_7 p6_1c8_7  p1_7_7 p1_5_7 p6_3_7 p6_4_7 p6_62_7 p6_63c1_7 p6_63c2_7 p6_63c3_7 p6_63c4_7 p6_63c5_7 p6_63c6_7 p6_63c7_7 p6_63c8_7  expect_7  ///
 p6_1c3_8 p6_1c4_8  p6_1c6_8 p6_1c7_8 p6_1c8_8  p1_7_8 p1_5_8 p6_3_8 p6_4_8 p6_62_8 p6_63c1_8 p6_63c2_8 p6_63c3_8 p6_63c4_8 p6_63c5_8 p6_63c6_8 p6_63c7_8 ///
p6_63c8_8  expect_8 p1_2b_9  p6_1c3_9 p6_1c4_9 p6_1c6_9 p6_1c7_9 p6_1c8_9 p1_7_9 p1_5_9 p6_3_9 p6_4_9 p6_62_9 p6_63c1_9 p6_63c2_9 p6_63c3_9 ///
p6_63c4_9 p6_63c5_9 p6_63c6_9 p6_63c7_9 p6_63c8_9  expect_9 


bys imputation h_2014: egen ddsum=sum(pareja)
drop pareja
g pareja=0
replace pareja=1 if ddsum!=0 & ddsum!=.
drop ddsum


save "$path/Data/panel_2008_2014_constrained.dta", replace