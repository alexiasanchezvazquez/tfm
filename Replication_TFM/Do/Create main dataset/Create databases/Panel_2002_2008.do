clear all
set more off
set maxvar 10000



****************************************
****************************************
* PANEL 2002-2008
****************************************
****************************************

forvalues q=1/5{
	tempfile eff_2002_`q'
use "$path/Datasets/EFF/2002/seccion6_2002_imp`q'.dta", clear
g imputation=`q'
merge 1:1 h_number using "$path/Datasets/EFF/2002/otras_secciones_2002_imp`q'.dta"
drop _merge
do "$path/Do/Create main dataset/Create wealth variables/2002_wealth.do"
merge 1:1 h_number using "$path/Datasets/EFF/2002/replicate_weights_2002.dta"
drop _merge ntimesr_*
g year=2002
save `eff_2002_`q''
}


use `eff_2002_1', clear
forvalues q=2/5{
append using `eff_2002_`q''
}
	tempfile eff_2002
save `eff_2002'




forvalues q=1/5{
	tempfile eff_2005_`q'
use "$path/Datasets/EFF/2005/seccion6_2005_imp`q'.dta", clear
g imputation=`q'

merge 1:1 h_2005 using "$path/Datasets/EFF/2005/otras_secciones_2005_imp`q'.dta"
drop _merge
do "$path/Do/Create main dataset/Create wealth variables/2005_wealth.do"
merge 1:1 h_2005 using "$path/Datasets/EFF/2005/replicate_weights_2005.dta"
drop _merge ntimesr_*
g year=2005
save `eff_2005_`q''
}


use `eff_2005_1', clear
forvalues q=2/5{
append using `eff_2005_`q''
}

	tempfile eff_2005
save `eff_2005'



forvalues q=1/5{
	tempfile eff_2008_`q'
use "$path/Datasets/EFF/2008/seccion6_2008_imp`q'.dta", clear
g imputation=`q'
merge 1:1 h_2008 using "$path/Datasets/EFF/2008/otras_secciones_2008_imp`q'.dta"
drop _merge
do "$path/Do/Create main dataset/Create wealth variables/2008_wealth.do"
merge 1:1 h_2008 using "$path/Datasets/EFF/2008/replicate_weights_2008.dta"
drop _merge ntimesr_*
g year=2008
save `eff_2008_`q''
}


use `eff_2008_1', clear
forvalues q=2/5{
append using `eff_2008_`q''
}

	tempfile eff_2008
save `eff_2008'




* 2002 to 2005
use `eff_2002', clear
append using `eff_2005'

sort h_number imputation
bys h_number imputation: g dd=1 if hogarpanel==1
bys h_number imputation: egen ddsum=sum(dd)
keep if ddsum==1


sort imputation h_number year
bysort imputation h_number: replace h_2005=h_2005[2] 

egen id=group(h_2005 imputation)
xtset id year

drop h_number id


* 2005 with 2008


append using `eff_2008'

drop dd ddsum
sort h_2005
sort h_2005 imputation
bys h_2005 imputation: g dd=1 if hogarpanel==1
bysort h_2005 imputation: egen ddsum=sum(dd)



drop if h_2005==5799 // This household are two different ones in 2008


keep if ddsum==2


sort imputation h_2005 year
bysort imputation h_2005: replace h_2008=h_2008[3]

egen id=group(h_2008 imputation)
xtset id year, delta(3)

bys imputation: su h_2005 h_2008

drop  h_2005 id



* CPI data
merge m:1 anno mes using "$path/Datasets/cpi.dta"

drop if _merge!=3

drop _merge



keep h_2008 year pan* p1 p1_1_*	p1_2b_* p2_1 p2_19 p1_3_* p1_5_* p1_7_* p6_17_*_1 p6_21_*_1 p6_1c1_* ///
p6_1c2_* p6_1c3_* p6_1c4_* p6_1c5_* p6_1c6_* p6_1c7_* p6_1c8_* p6_60g p6_60h p6_3_*  p6_4_* p6_13_* ///  
 p6_63c1_*  p6_63c2_*  p6_63c3_*  p6_63c4_*  p6_63c5_*  p6_63c6_*  p6_63c7_*  p6_63c8_*  p9_1 ///
 p9_11  p9_16  renthog  mrenthog ///
p6_64_* p6_66_* p6_68_* p6_70_* p6_72_*  p6_74_* p6_76 p6_76b p6_75b p6_75d p6_75f ///
 riquezanet riquezabr dvivpral deuoprop phipo ///
 p3_13s*   p3_14 p3_16 p6_21_*_1 ///
pperso potrasd ptmos_tarj actreales actfinanc vdeuda wt3r_* imputation cpi* p2_3 p2_69 p2_73 p2_77 p2_85 ///
p2_8 p2_8a p2_13_* p2_12_* p2_14_* p2_17_*  ///
p2_18_* p2_61_* p3_11_* p8_5b p2_55_* p3_6_* p8_5a p2_57_* p3_8_* p2_11* facine3 p2_5 p2_9a_* p2_16_* p2_62 p2_63 p2_33 p2_36* p2_26 p4_25 p4_16 p4_8_* p4_36 p4_40





save "$path/Data/panel_2002_2008", replace





