clear all
set more off
set maxvar 10000

****************************************
****************************************
* PANEL 2017-2022
****************************************
**************

* ======================================
* 1. PREPARAR DATOS 2017
* ======================================
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


* ======================================
* 2. PREPARAR DATOS 2020
* ======================================
forvalues q=1/5{
	tempfile eff_2020_`q'
	use "$path/Datasets/EFF/2020/seccion6_2020_imp`q'.dta", clear
	g imputation=`q'
	
	merge 1:1 h_2020 using "$path/Datasets/EFF/2020/otras_secciones_2020_imp`q'.dta"
	drop _merge
	do "$path/Do/Create main dataset/Create wealth variables/2020_wealth.do"
	merge 1:1 h_2020 using "$path/Datasets/EFF/2020/replicate_weights_2020.dta"
	drop _merge ntimesr_*
	g year=2020
	save `eff_2020_`q''
}

use `eff_2020_1', clear
forvalues q=2/5{
	append using `eff_2020_`q''
}
tempfile eff_2020
save `eff_2020'


* ======================================
* 3. PREPARAR DATOS 2022
* ======================================
forvalues q=1/5{
	tempfile eff_2022_`q'
	use "$path/Datasets/EFF/2022/seccion6_2022_imp`q'.dta", clear
	g imputation=`q'
	
	merge 1:1 h_2022 using "$path/Datasets/EFF/2022/otras_secciones_2022_imp`q'.dta"
	drop _merge
	do "$path/Do/Create main dataset/Create wealth variables/2022_wealth.do"
	merge 1:1 h_2022 using "$path/Datasets/EFF/2022/replicate_weights_2022.dta"
	drop _merge ntimesr_*
	g year=2022
	save `eff_2022_`q''
}

use `eff_2022_1', clear
forvalues q=2/5{
	append using `eff_2022_`q''
}

tempfile eff_2022
save `eff_2022'


* ======================================
* 4. UNIR PANEL 2017 CON 2020
* ======================================
use `eff_2017', clear
append using `eff_2020'

replace hogarpanel=0 if year==2017
sort h_2017 imputation
bys h_2017 imputation: g dd=1 if hogarpanel==1
bys h_2017 imputation: egen ddsum=sum(dd)
keep if ddsum==1

sort imputation h_2017 year
bysort imputation h_2017: replace h_2020=h_2020[2] 

egen id=group(h_2020 imputation)
xtset id year

drop h_2017 id


* ======================================
* 5. UNIR PANEL CON 2022
* ======================================
append using `eff_2022'

drop dd ddsum
sort h_2020
sort h_2020 imputation
bys h_2020 imputation: g dd=1 if hogarpanel==1
bysort h_2020 imputation: egen ddsum=sum(dd)

keep if ddsum==2

sort imputation h_2020 year
bysort imputation h_2020: replace h_2022=h_2022[3]

egen id=group(h_2022 imputation)
xtset id year

bys imputation: su h_2020

drop h_2020 id


* ======================================
* 6. AÑADIR DATOS DE INFLACIÓN Y LIMPIAR
* ======================================
* CPI data
merge m:1 anno mes using "$path/Datasets/cpi.dta"

drop if _merge!=3
drop _merge

* Se mantiene h_2022 como identificador principal del hogar al final del periodo
keep h_2022 year pan* p1 p1_1_*	p1_2b_* p2_1 p2_19 p1_3_* p1_5_* p1_7_* p6_17_*_1 p6_21_*_1 p6_1c1_* ///
p6_1c2_* p6_1c3_* p6_1c4_* p6_1c5_* p6_1c6_* p6_1c7_* p6_1c8_* p6_60g p6_60h p6_3_* p6_4_* p6_13_* ///  
 p6_63c1_* p6_63c2_* p6_63c3_* p6_63c4_* p6_63c5_* p6_63c6_* p6_63c7_* p6_63c8_* p9_1 ///
 p9_11  p9_16  renthog  mrenthog ///
 p6_64_* p6_66_* p6_68_* p6_70_* p6_72_* p6_74_* p6_74b_* p6_74c_* p6_75b  p6_75d1 p6_75d2 p6_75d3 p6_75d4 p6_76b p6_75f    riquezanet riquezabr dvivpral deuoprop phipo ///
 p3_13s* p3_12a p3_12b   p6_21_*_1 ///
pperso potrasd ptmos_tarj actreales actfinanc vdeuda wt3r_* imputation cpi* p2_3 p2_69 p2_73 p2_77 p2_85 /// 
p2_8 p2_8a p2_13_* p2_12_* p2_14_* p2_17_* ///
p2_18_* p2_61_* p3_11_* p8_5b p2_55_* p3_6_* p8_5a p2_57_* p3_8_* p2_11* facine3 p2_5  p2_9a_* p2_16_* p2_62 p2_63 p2_33 p2_36* p2_26 p4_25 p4_16 p4_8_* p4_36 p4_40

save "$path/Data/panel_2017_2022", replace
