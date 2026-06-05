clear all
set more off
set maxvar 10000


****************************************
****************************************
* PANEL 2011-2017
****************************************
**************

forvalues q=1/5{
	tempfile eff_2011_`q'
use "$path/Datasets/EFF/2011/seccion6_2011_imp`q'.dta", clear
g imputation=`q'

merge 1:1 h_2011 using "$path/Datasets/EFF/2011/otras_secciones_2011_imp`q'.dta"
drop _merge
do "$path/Do/Create main dataset/Create wealth variables/2011_wealth.do"
merge 1:1 h_2011 using "$path/Datasets/EFF/2011/replicate_weights_2011.dta"
drop _merge ntimesr_*
g year=2011
save `eff_2011_`q''
}


use `eff_2011_1', clear
forvalues q=2/5{
append using `eff_2011_`q''
}

	tempfile eff_2011
save `eff_2011'




forvalues q=1/5{
	tempfile eff_2014_`q'
use "$path/Datasets/EFF/2014/seccion6_2014_imp`q'.dta", clear
g imputation=`q'
merge 1:1 h_2014 using "$path/Datasets/EFF/2014/otras_secciones_2014_imp`q'.dta"
drop _merge
do "$path/Do/Create main dataset/Create wealth variables/2014_wealth.do"
merge 1:1 h_2014 using "$path/Datasets/EFF/2014/replicate_weights_2014.dta"
drop _merge ntimesr_*
g year=2014
save `eff_2014_`q''
}


use `eff_2014_1', clear
forvalues q=2/5{
append using `eff_2014_`q''
}
	tempfile eff_2014
save `eff_2014'



forvalues q=1/5{
	tempfile eff_2017_`q'
use "$path/Datasets/EFF/2017/seccion6_2017_imp`q'.dta", clear
g imputation=`q'
merge 1:1 h_2017 using "$path/Datasets/EFF/2017/otras_secciones_2017_imp`q'.dta"
drop _merge
do "$path/Do/Create main dataset/Create wealth variables/2017_wealth.do"
merge 1:1 h_2017 using "$path/Datasets/EFF/2017/replicate_weights_2017.dta"
drop _merge ntimesr_*
g year=2017
save `eff_2017_`q''
}


use `eff_2017_1', clear
forvalues q=2/5{
append using `eff_2017_`q''
}

	tempfile eff_2017
save `eff_2017'



* 2011 to 2014

use `eff_2011', clear
append using `eff_2014'

replace hogarpanel=0 if year==2011
sort h_2011 imputation
bys h_2011 imputation: g dd=1 if hogarpanel==1
bys h_2011 imputation: egen ddsum=sum(dd)
keep if ddsum==1


sort imputation h_2011 year
bysort imputation h_2011: replace h_2014=h_2014[2] 

egen id=group(h_2014 imputation)
xtset id year

drop h_2011 id

* 2014 with 2017

append using `eff_2017'

drop dd ddsum
sort h_2014
sort h_2014 imputation
bys h_2014 imputation: g dd=1 if hogarpanel==1
bysort h_2014 imputation: egen ddsum=sum(dd)

keep if ddsum==2


sort imputation h_2014 year
bysort imputation h_2014: replace h_2017=h_2017[3]

egen id=group(h_2017 imputation)
xtset id year, delta(3)

bys imputation: su h_2014

drop h_2014 id



* CPI data
merge m:1 anno mes using "$path/Datasets/cpi.dta"

drop if _merge!=3

drop _merge



keep h_2017 year pan* p1 p1_1_*	p1_2b_* p2_1 p2_19 p1_3_* p1_5_* p1_7_* p6_17_*_1 p6_21_*_1 p6_1c1_* ///
p6_1c2_* p6_1c3_* p6_1c4_* p6_1c5_* p6_1c6_* p6_1c7_* p6_1c8_* p6_60g p6_60h p6_3_*  p6_4_* p6_13_* ///  
 p6_63c1_*  p6_63c2_*  p6_63c3_*  p6_63c4_*  p6_63c5_*  p6_63c6_*  p6_63c7_*  p6_63c8_*  p9_1 ///
 p9_11  p9_16  renthog  mrenthog ///
 p6_64_* p6_66_* p6_68_* p6_70_* p6_72_* p6_74_* p6_74b_* p6_74c_* p6_75b  p6_75d1 p6_75d2 p6_75d3 p6_75d4 p6_76b p6_75f   riquezanet riquezabr dvivpral deuoprop phipo ///
 p3_13s* p3_12a p3_12b   p6_21_*_1 ///
pperso potrasd ptmos_tarj actreales actfinanc vdeuda wt3r_* imputation cpi* p2_3 p2_69 p2_73 p2_77 p2_85 /// 
p2_8 p2_8a p2_13_* p2_12_* p2_14_* p2_17_* ///
p2_18_* p2_61_* p3_11_* p8_5b p2_55_* p3_6_* p8_5a p2_57_* p3_8_* p2_11* facine3 p2_5  p2_9a_* p2_16_* p2_62 p2_63 p2_33 p2_36* p2_26 p4_25 p4_16 p4_8_* p4_36 p4_40



save "$path/Data/panel_2011_2017", replace





