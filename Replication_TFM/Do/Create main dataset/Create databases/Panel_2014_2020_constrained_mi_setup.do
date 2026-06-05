clear all
set more off
set maxvar 10000

use "$path/Data/panel_2014_2020_constrained.dta", clear

**********************************************************************
**********************************************************************
** Variables and multiple imputation (2014-2020)
**********************************************************************
**********************************************************************

* Age
g gage=0
replace gage=1 if age_1_prueba>=25 & age_1_prueba<35
replace gage=2 if age_1_prueba>=35 & age_1_prueba<45
replace gage=3 if age_1_prueba>=45 & age_1_prueba<55
replace gage=4 if age_1_prueba>=55 & age_1_prueba<65
replace gage=5 if age_1_prueba>=65 & age_1_prueba<75
replace gage=6 if age_1_prueba>=75

label variable gage "Groups of age of the reference person"
label define gage 1 "25-34 years old" 2 "35-44 years old" 3 "45-54 years old" 4 "55-64 years old" 5 "65-74 years old" 6 ">=75 years old"
label values gage gage 
bys imputation: su gage

* Gender of the reference person
tab p1_1_1_prueba, mi
g gender=0
replace gender=1 if p1_1_1_prueba==1
label variable gender "Gender of the reference person"
label define gender 0 "Female" 1 "Male"
label values gender gender
bys imputation: su gender

* Kind of ownership
tab p2_1, mi
g ownership=0
replace ownership=p2_1
recode ownership (97=4)
label variable ownership "Type of ownership of the main residence"
label define ownership 1 "Rent" 2 "Owner" 3 "Free transfer" 4 "Other"
label values ownership ownership
bys imputation: su ownership

* Size of the HH
tab p1, mi
g size=p1
label variable size "Size of the household"
bys imputation: su size

* Liquidity constraints
bys imputation: tab p9_16, mi
g liqcons=0
replace liqcons=1 if p9_16==1
label variable liqcons "Delays in the payment of a debt"
label define liqcons 0 "Otherwise" 1 "Yes" 
label values liqcons liqcons
bys imputation: su liqcons

* Financial risk profile
g risk=0
replace risk=1 if inrange(p9_11,1,3) // willing to take financial risk
label variable risk "Financial risk dummy"
label define risk 0 "Otherwise" 1 "Willing to take financial risk"
label values risk risk
bys imputation: su risk

* Type of contract
bys imputation: tab p6_13_1_prueba
g contract=0
replace contract=1 if p6_13_1_prueba==1
replace contract=2 if p6_13_1_prueba==2 | p6_13_1_prueba==3 | p6_13_1_prueba==4
replace contract=3 if p6_1c2_1_prueba==1 & p6_1c1_1_prueba!=1
label variable contract "Tipo de contrato"
label define contract 0 "No contract" 1 "Permanente" 2 "Temporal" 3 "Autonomos"
label value contract contract
bys imputation: tab contract, mi

* Employment situation of the reference person
g employment=0
replace employment=1 if p6_1c1_1_prueba==1 | p6_1c2_1_prueba==1
replace employment=2 if p6_1c3_1_prueba==1 & employment!=1
replace employment=3 if p6_1c4_1_prueba==1 & employment!=1 & employment!=2 
replace employment=4 if employment!=1 & employment!=2 & employment!=3

label variable employment "Employment status"
label define employment 1 "Employed" 2 "Unemployed" 3 "Retired" 4 "Inactive"
label value employment employment
bys imputation: tab employment, mi

* Categorical sectors (Agricultural==1, Industry==2, Construction==3, Others==4)
g sector=0
replace sector=1 if p6_4_1_prueba==1 & year==2014 & employment==1
replace sector=2 if p6_4_1_prueba==2 & year==2014 & employment==1 | p6_4_1_prueba==3 & year==2014 & employment==1 | p6_4_1_prueba==4 & year==2014 & employment==1 | p6_4_1_prueba==5 & year==2014 & employment==1
replace sector=3 if p6_4_1_prueba==6 & year==2014 & employment==1
replace sector=4 if p6_4_1_prueba>6 & year==2014 & p6_4_1_prueba!=. & employment==1

replace sector=1 if p6_4_1_prueba==1 & year==2017 & employment==1
replace sector=2 if p6_4_1_prueba==2 & year==2017 & employment==1 | p6_4_1_prueba==3 & year==2017 & employment==1 | p6_4_1_prueba==4 & year==2017 & employment==1 | p6_4_1_prueba==5 & year==2017 & employment==1
replace sector=3 if p6_4_1_prueba==6 & year==2017 & employment==1
replace sector=4 if p6_4_1_prueba>6 & year==2017 & p6_4_1_prueba!=. & employment==1

replace sector=1 if p6_4_1_prueba==1 & year==2020 & employment==1
replace sector=2 if p6_4_1_prueba==2 & year==2020 & employment==1 | p6_4_1_prueba==3 & year==2020 & employment==1 | p6_4_1_prueba==4 & year==2020 & employment==1 | p6_4_1_prueba==5 & year==2020 & employment==1
replace sector=3 if p6_4_1_prueba==6 & year==2020 & employment==1
replace sector=4 if p6_4_1_prueba>6 & year==2020 & p6_4_1_prueba!=. & employment==1

label variable sector "Economic sector of the reference person"
label define sector 0 "No sector" 1 "Agricultural" 2 "Industry" 3 "Construction" 4 "Others"
label value sector sector
bys imputation: tab sector, mi

* Number of Employed adults
forvalues i=1/9{
g members_empl_`i'=0
replace members_empl_`i'=1 if p6_1c1_`i'==1  | p6_1c2_`i'==1 
}

egen members_working=rowtotal(members_empl_*)
label variable members_working "Number of household members working"
tab members_working, mi
bys imputation: su members_working

* Number of kids under 16 or dependents below 25
forvalues i=1/9{
g kids_`i'=0
replace kids_`i'=1 if p1_3_`i'==3 & age_`i'<17
replace kids_`i'=1 if p1_3_`i'==3 & age_`i'>16 & age_`i'<26 & p6_1c5_`i'==1
}  

egen kids=rowtotal(kids_*)
label variable kids "Number of kids under 17 in the household"
bys imputation: su kids

* -------------------------------------------------------------------------
* CREACIÓN DE VARIABLE SHOCK (Aportación)
* -------------------------------------------------------------------------
* 0. Declarar el panel formalmente para rezagos (salto regular de 3 años)
capture drop id
egen id=group(imputation h_2020)
xtset id year, delta(3)

* 1. Componente principal (Aprovechamos la variable 'employment' del original)
gen byte employed_bin   = (employment == 1)
gen byte unemployed_bin = (employment == 2)

gen byte shock_main = (L.employed_bin == 1 & unemployed_bin == 1) ///
    if !missing(L.employed_bin, unemployed_bin)
label var shock_main "Transición empleo→paro del cabeza de familia"

* 2. Componente complementario (Aprovechamos 'members_working' del original)
gen byte shock_workers = (members_working < L.members_working) ///
    if !missing(L.members_working)

* 3. Construir la variable FINAL de Shock
gen byte shock = (shock_main == 1 | shock_workers == 1) ///
    if !missing(shock_main, shock_workers)
label var shock "Shock por desempleo del hogar"

* Borrar las variables intermedias
drop employed_bin unemployed_bin shock_main shock_workers
* -------------------------------------------------------------------------

* Health status (GOOD==1 OTHER==0)
 g health_1=0
 replace health_1=1 if p1_7_1_prueba==1 | p1_7_1_prueba==2 
label variable health_1 "Health status of the reference person"
label define health_1 0 "Otherwise" 1 "Good, Very Good"
label values health_1 health_1
tab health_1, mi
bys imputation: su health_1

g health_pareja=0
replace health_pareja=1 if p1_7_pareja==1 | p1_7_pareja==2
label variable health_pareja "Health status of the partner"
label define health_pareja 0 "Otherwise" 1 "Good, Very Good"
label values health_pareja health_pareja
tab health_pareja, mi
bys imputation: su health_pareja

* Educational attainment of the reference person and its partner
tab p1_5_1_prueba, mi

g edu_h_1=0
 replace edu_h_1=1 if p1_5_1_prueba==10 | p1_5_1_prueba==1001 |p1_5_1_prueba==1002 | p1_5_1_prueba==11 | p1_5_1_prueba==12
label variable edu_h_1 "Educational dummy =1 if the reference person has at least an University degree"
bys imputation: su edu_h_1

g edu_m_1=0
replace edu_m_1=1 if p1_5_1_prueba>=6 & p1_5_1_prueba<=9
label variable edu_m_1 "Educational dummy =1 if the reference person has at least la Segunda etapa de Secundaria and maximum de Bachiller"
bys imputation: su edu_m_1

* Job skills of the reference person and its partner
tab p6_3_1_prueba
g job_h_1=0
replace job_h_1=1 if p6_3_1_prueba==1 | p6_3_1_prueba==2
label variable job_h_1 "Job skills dummy =1 if the reference person works as a Manager or a scientific or professional Technician and Professional"
bys imputation: su job_h_1

g job_h_pareja=0
replace job_h_pareja=1 if p6_3_pareja==1 | p6_3_pareja==2
label variable job_h_pareja "Job skills dummy =1 if the partner works as a Manager or a scientific or professional Technician and Professional"
bys imputation: su job_h_pareja

* Current level of income above/below normality
tab p6_60g, mi
g income_dev=0
replace income_dev=1 if p6_60g==1
replace income_dev=2 if p6_60g==2
label variable income_dev "How would you define your current level of income?"
label define income_dev 0 "Normal" 1 "Higher than usual" 2 "Lower than usual"
label values income_dev income_dev
bys imputation: su income_dev

* Expected future level of income above/below normality
tab p6_60h, mi
g income_expect=0
replace income_expect=1 if p6_60h==1
replace income_expect=2 if p6_60h==2
label variable income_expect "How do you think your future income is gonna be?"
label define income_expect 0 "The same" 1 "Larger" 2 "Smaller"
label values income_expect income_expect
bys imputation: su income_expect

* Consumption of durable goods
tab p2_19, mi
g durable=0
replace durable=1 if p2_19==1 /* Reforms in the house */
replace durable=1 if p2_69==1 /* Electrodomésticos */
replace durable=1 if p2_73==1 /* Cars */
replace durable=1 if p2_77==1 /* Other transport */

label variable durable "Dummy =1 if there has been reforms in the main residence of bought any durable goods in the main residence in the last 12 months"
bys imputation: su p2_19

* Credit constraints      
g constraints=0
replace constraints=1 if p3_12a==1 & year==2014 | p3_12b==1 & year==2014 | p3_13s1==4 & year==2014 | p3_13s2==4 & year==2014 | p3_13s3==4 & year==2014 | p3_13s4==4 & year==2014 | p3_13s5==4 & year==2014

replace constraints=1 if p3_12a==1 & year==2017 | p3_12b==1 & year==2017 | p3_13s1==4 & year==2017 | p3_13s2==4 & year==2017 | p3_13s3==4 & year==2017 | p3_13s4==4 & year==2017 | p3_13s5==4 & year==2017

replace constraints=1 if p3_12a==1 & year==2020 | p3_12b==1 & year==2020 | p3_13s1==4 & year==2020 | p3_13s2==4 & year==2020 | p3_13s3==4 & year==2020 | p3_13s4==4 & year==2020 | p3_13s5==4 & year==2020

label variable constraints "Dummy takes value 1 if the household does not ask a credit because they do not think would be conceded or the household receive a smaller credit than the one asked"
bys imputation: su constraints

* Liquidity or credit constraints 
g gen_constraints=0
replace gen_constraints=1 if constraints==1 | liqcons==1

* Precaution
g preca_1=1 if expect_1_prueba>50 & expect_1_prueba!=. & year==2014 | expect_1_prueba>50 & expect_1_prueba!=. & year==2017 | expect_1_prueba>50 & expect_1_prueba!=. & year==2020 
replace preca_1=1 if employment==2

g precautionary=0
replace precautionary=1 if preca_1==1 
drop preca_1 
bys imputation: su precautionary
label variable precautionary "Dummy takes value 1 if the reference person is afraid of losing their job in the future or it is unemployed"

* Collateral
g collateral=0
replace collateral=1 if p2_26==1

* Remaining mortgages for the main residence
g pending_loans=0
replace pending_loans=1 if p2_8==1

* Number of remaining mortgages for the main residence
g number_pending_loans=0
replace number_pending_loans=number_pending_loans+p2_8a if p2_8a>0 & p2_8a!=.

* Years remaining to pay back the mortgage
g years_pending=0
replace years_pending=years_pending+p2_17_1 if p2_8==1
replace years_pending=0 if years_pending<0

g interest_rate=0
replace interest_rate=p2_13_1 if p2_8==1
replace interest_rate=interest_rate/100 if year==2002

g interest_rate_type=0
replace interest_rate_type=1 if p2_14_1==1 & p2_8==1 | p2_14_1==22 & p2_8==1

* Weighted years remaining
egen total_mortgage=rowtotal(p2_12_1 p2_12_2 p2_12_3 p2_12_4)
g years_pending_weight=0
replace years_pending_weight=years_pending_weight+(p2_12_1/total_mortgage)*p2_17_1 if p2_12_1>0 & p2_12_1!=. & p2_17_1>=0 & p2_17_1!=.
replace years_pending_weight=years_pending_weight+(p2_12_2/total_mortgage)*p2_17_2 if p2_12_2>0 & p2_12_2!=. & p2_17_2>=0 & p2_17_2!=.
replace years_pending_weight=years_pending_weight+(p2_12_3/total_mortgage)*p2_17_3 if p2_12_3>0 & p2_12_3!=. & p2_17_3>=0 & p2_17_3!=.
replace years_pending_weight=years_pending_weight+(p2_12_4/total_mortgage)*p2_17_4 if p2_12_4>0 & p2_12_4!=. & p2_17_4>=0 & p2_17_4!=.

* Percentage of the loan  pending to return
egen remaining_mortgage=rowtotal(p2_12_1 p2_12_2 p2_12_3 p2_12_4)
egen initial_mortgage=rowtotal(p2_11_1 p2_11_2 p2_11_3 p2_11_4)

g share_remaining_mortgage=0
replace share_remaining_mortgage=remaining_mortgage/initial_mortgage if initial_mortgage!=0
replace share_remaining_mortgage=1 if share_remaining_mortgage>1 & share_remaining_mortgage!=.

* Exposure to a fixed interest rate
egen total_debt=rowtotal(p2_12_* p2_55_* p3_6_* p8_5a)
su total_debt vdeuda
g share_fixed_rate=0
* Main residence
replace share_fixed_rate=share_fixed_rate+p2_12_1 if p2_14_1==1 & p2_12_1>0 & p2_12_1!=. | p2_14_1==22 & p2_12_1>0 & p2_12_1!=.
replace share_fixed_rate=share_fixed_rate+p2_12_2 if p2_14_2==1 & p2_12_2>0 & p2_12_2!=. | p2_14_2==22 & p2_12_2>0 & p2_12_2!=.
replace share_fixed_rate=share_fixed_rate+p2_12_3 if p2_14_3==1 & p2_12_3>0 & p2_12_3!=. | p2_14_3==22 & p2_12_3>0 & p2_12_3!=.
replace share_fixed_rate=share_fixed_rate+p2_12_4 if p2_14_4==1 & p2_12_4>0 & p2_12_4!=. | p2_14_4==22 & p2_12_4>0 & p2_12_4!=.
* Other properties
forvalues i=1/3{
   forvalues j=1/3{
replace share_fixed_rate=share_fixed_rate+p2_55_`i'_`j' if p2_57_`i'_`j'==1 & p2_55_`i'_`j'>0 & p2_55_`i'_`j'!=.
}
}
* Other debts
forvalues i=1/8{
    replace share_fixed_rate=share_fixed_rate+p3_6_`i' if p3_8_`i'==1 & p3_6_`i'>0 & p3_6_`i'!=.
}
replace share_fixed_rate=share_fixed_rate/vdeuda if vdeuda!=0

forvalues i=1/3{
    g diff_`i'=p2_16_`i'-p2_17_`i'
}
g refin=0
replace refin=1 if p2_9a_1==1 & diff_1<=3 | p2_9a_2==1 & diff_2<=3 | p2_9a_3==1 & diff_3<=3

* Speculation
g spec_1=0
replace spec_1=1 if p2_36_1>=2014 & p2_36_1<=2017 | p2_36_2>=2014 & p2_36_2<=2017 | p2_36_3>=2014 & p2_36_3<=2017 | p2_33>3 & p2_33!=. 

g spec_2=0
replace spec_2=1 if p2_62==1  

g spec_3=0
replace spec_3=1 if spec_1==1 | spec_2==1

* Income
egen nonfin_inc=rowtotal(p6_64_* p6_66_* p6_68_* p6_70_* p6_72_* p6_74_* p6_74b_* p6_74c_* p6_75b  p6_75d1 p6_75d2 p6_75d3 p6_75d4 p6_76b p6_75f  )

g nonfin_inc_real=0 
replace nonfin_inc_real=(nonfin_inc/cpi_yearly_lagged)*100 if nonfin_inc!=. 
drop nonfin_inc

* Adjust to CPI 2011 base (cpi.dta only contains cpi_2011 series)
g mrenthog_real=((mrenthog/cpi_2011)*100)*12 if mrenthog!=. 
drop mrenthog

g consumption_real=(((p9_1/cpi_2011))*100)*12 if p9_1!=.

g renthog_real=0 
replace renthog_real=(renthog/cpi_yearly_lagged)*100 if renthog!=. 
drop renthog

* Debt service
egen debt_service=rowtotal(p2_18_* p2_61_* p3_11_* p8_5b)
egen debt_service_real_assets=rowtotal(p2_18_* p2_61_*)
egen debt_service_fin_assets=rowtotal(p2_18_* p2_61_* p3_11_* p8_5b)

foreach var in debt_service debt_service_real_assets debt_service_fin_assets{
g `var'_real=((`var'/cpi_2011)*100)*12 if `var'!=.
drop `var'
}

* Debt
g deuda_viv=0
replace deuda_viv=deuda_viv+dvivpral if (dvivpral>0 & dvivpral!=.)

g deuda_oprop=0
replace deuda_oprop=deuda_oprop+deuoprop if (deuoprop>0 & deuoprop!=.)

g deuda_hip=0
replace deuda_hip=deuda_hip+phipo if (phipo>0 & phipo!=.)

g deuda_per=0
replace deuda_per=deuda_per+pperso if (pperso>0 & pperso!=.)

g deuda_otras=0
replace deuda_otras=deuda_otras+potrasd if (potrasd>0 & potrasd!=.)

g deuda_tarjeta=0
replace deuda_tarjeta=deuda_tarjeta+ptmos_tarj if (ptmos_tarj>0 & ptmos_tarj!=.)

g real_debt=0
replace real_debt=real_debt+dvivpral if dvivpral!=.
replace real_debt=real_debt+deuoprop if deuoprop!=.

g fin_debt=0
replace fin_debt=fin_debt+phipo if phipo!=.
replace fin_debt=fin_debt+pperso if pperso!=.
replace fin_debt=fin_debt+ptmos_tarj if ptmos_tarj!=.
replace fin_debt=fin_debt+potrasd if potrasd!=.


* ==========================================================
* Wealth and debt Deflators (Information from Bank of Spain)
* Bringing all wealth/debt variables to 2011 euros
* Chain: 2020 -> 2017 -> 2014 -> 2011
* Factor 2017-2020: 1.0144
* Factor 2014-2017: 1.0272
* Factor 2011-2014: 1.0205
* ==========================================================

foreach var of varlist  riquezanet  riquezabr actreales actfinanc vdeuda real_debt fin_debt p2_5{

	g `var'_2014=`var' if year==2014

	g `var'_2017=`var' if year==2017
	* Deflactor 2017-2020 (Bank of Spain)
	replace `var'_2017=`var'/1.0144 if year==2020

	* Deflactor 2014-2017 (Bank of Spain)
	replace `var'_2014=`var'_2017/1.0272 if year==2017 | year==2020

	* Deflactor 2011-2014 (Bank of Spain) - to keep consistency with 2011-2017 panel
	g `var'_2011=`var'_2014/1.0205 if year==2014 | year==2017 | year==2020

	drop `var' `var'_2014 `var'_2017
	rename `var'_2011 `var'_real
}

* Outliers
g dd=1 if nonfin_inc_real<=0 
bys h_2020: egen ddsum=sum(dd)
drop if ddsum!=0
drop dd ddsum

g dd=1 if consumption_real<=0
bys h_2020: egen ddsum=sum(dd)
drop if ddsum!=0
drop dd ddsum

 g dd=1 if riquezanet>10000000
 bys h_2020: egen dd_sum=sum(dd)
 drop if dd_sum!=0
 drop dd dd_sum
 
 g dd=1 if nonfin_inc_real<5000
 bys h_2020: egen dd_sum=sum(dd)
 drop if dd_sum!=0
 drop dd dd_sum

* SHOCK AÑADIDO AL KEEP FINAL
keep h_2020 year imputation gage gender ownership size liqcons risk  members_working kids health_1  edu_h_1 edu_m_1   job_h_1  income_dev income_expect wt3r_* cpi* mrenthog_real renthog_real consumption_real actfinanc_real actreales_real  vdeuda_real real_debt_real fin_debt_real riquezabr_real riquezanet_real durable nonfin_inc constraints precautionary pareja contract sector employment years_house gen_constraints pending_loans number_pending_loans years_pending interest_rate interest_rate_type debt_service_real  debt_service_real_assets  debt_service_fin_assets years_pending_weight share_remaining_mortgage share_fixed_rate facine3 p2_5_real refin spec_* collateral shock 

* We create m=0
sort imputation 
expand 2 if imputation==1, gen(missing_flag) 
replace imputation=0 if missing_flag==1
drop missing_flag

* SHOCK AÑADIDO AL BUCLE DE IMPUTACIÓN
foreach var of varlist  gage gender ownership size liqcons risk  members_working kids health_1  edu_h_1 edu_m_1   job_h_1  income_dev income_expect cpi* mrenthog_real renthog_real  consumption_real actfinanc_real actreales_real  vdeuda_real real_debt_real fin_debt_real riquezabr_real riquezanet_real durable nonfin_inc constraints precautionary contract sector employment years_house gen_constraints pending_loans number_pending_loans years_pending interest_rate interest_rate_type debt_service_real  debt_service_real_assets  debt_service_fin_assets years_pending_weight share_remaining_mortgage share_fixed_rate p2_5_real refin spec_* collateral shock {
				capture if !_rc  
				confirm numeric variable `var'
					{
						tempvar sd
						quietly bysort h_2020 year : egen `sd'=sd(`var') 
						quietly replace `var'=. if (`sd'>0 & `sd' <.) & imputation==0 
						drop `sd'
				  } 
				}

save "$path/Data/panel_2014_2020_constrained_mi", replace
