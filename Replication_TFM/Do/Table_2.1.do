*****************************************************************************************************************************
* SCRIPT PARA LA TABLA DE RESULTADOS - VARIABLES INSTRUMENTALES (IV) + SHOCK + WHtM (PROPIETARIOS)
* VERSION 2: 2 IVs (l2_debty_w  y  shock x l2_debty_w) -> 2 F-STATS POR PANEL
*   F_stat1 -> First-stage de la endogena l1_debty_w
*   F_stat2 -> First-stage de la endogena (shock x l1_debty_w)
*
* NOTA: Stata NO permite usar interacciones de factor (c.X#c.Y) como variable
* dependiente. Por eso en cada panel creamos a mano:
*    shock_l1debty = shock * l1_debty_w   (endogena 2)
*    shock_l2debty = shock * l2_debty_w   (instrumento 2)
* Estas se usan SOLO en la 2a first-stage. El ivregress final mantiene la
* sintaxis original con c.shock#c.l1_debty_w = c.shock#c.l2_debty_w para no
* alterar los coeficientes ni los errores estandar respecto a la tabla previa.
*****************************************************************************************************************************

clear all
set more off
set maxvar 10000

*****************************************************************************************************************************
* PANEL 2002-2008
*****************************************************************************************************************************
use "$path/Data/panel_2002_2008_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real refin debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3
                
mi import flong, m(imputation) id(h_2008 year) imputed(liqcons risk edu_h_1 edu_m_1 job_h_1 income_dev income_expect durable members_working sector mrenthog renthog consumption_real actfinanc_real actreales_real vdeuda real_debt fin_debt nonfin_inc_real riquezabr riquezanet constraints health_1 gen_constraints years_house shock) clear
mi register regular(pareja gage gender ownership size kids employment contract)

mi xtset h_2008 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap) 

mi passive: g cy=consumption_real/nonfin_inc_real
mi passive: g wy=riquezanet/nonfin_inc_real
mi passive: g debty=vdeuda/nonfin_inc_real

mi xeq: sort h_2008 year; g l1_size=l.size
mi xeq: sort h_2008 year; g d_size=d.size
mi xeq: sort h_2008 year; g l1_kids= l.kids 
mi xeq: sort h_2008 year; g d_members_working= d.members_working 
mi xeq: sort h_2008 year; g l1_members_working= l.members_working 
mi xeq: sort h_2008 year; g d_kids=d.kids
mi xeq: sort h_2008 year; g l1_gage=l.gage
mi xeq: sort h_2008 year; g l1_employment=l.employment
mi xeq: sort h_2008 year; g l1_ownership=l.ownership
mi xeq: sort h_2008 year; g l1_durable=l.durable
mi xeq: sort h_2008 year; g l1_income_dev=l.income_dev
mi xeq: sort h_2008 year; g l1_risk=l.risk
mi xeq: sort h_2008 year; g l1_gen_constraints=l.gen_constraints
mi xeq: sort h_2008 year; g l1_income_expect=l.income_expect
mi xeq: sort h_2008 year; g l1_health_1=l.health_1
mi xeq: sort h_2008 year; g d_health_1=d.health_1
mi xeq: sort h_2008 year; g l1_edu_h_1=l.edu_h_1 
mi xeq: sort h_2008 year; g l1_edu_m_1=l.edu_m_1 
mi xeq: sort h_2008 year; g l1_job_h_1=l.job_h_1
mi xeq: sort h_2008 year; g l1_gender=l.gender
mi xeq: sort h_2008 year; g l1_pareja=l.pareja
mi xeq: sort h_2008 year; g l1_sector=l.sector
mi xeq: sort h_2008 year; g l1_contract=l.contract

global baseline_controls d_size l1_size d_members_working l1_members_working d_kids l1_kids i.l1_gage i.l1_employment l1_health_1 d_health_1 l1_edu_h_1 l1_edu_m_1 l1_job_h_1 i.durable i.l1_durable l1_pareja l1_gender i.income_dev i.l1_income_dev i.risk i.l1_risk i.gen_constraints i.l1_gen_constraints i.income_expect i.l1_income_expect i.l1_contract i.l1_sector years_house 

mi xeq: sort h_2008 year; g dwy=d.wy
mi xeq: sort h_2008 year; g dcy=d.cy
mi xeq: sort h_2008 year; g l1_debty=l.debty 
mi xeq: sort h_2008 year; g l2_debty=l2.debty   // INSTRUMENTO

forvalues i=1/5{
forvalues j=2002(3)2008{
capture xtile qui_wealth_`i'_`j'=riquezanet if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_wealth=.
forvalues i=1/5{
forvalues j=2002(3)2008{
capture replace qui_wealth=qui_wealth_`i'_`j' if imputation==`i' & year==`j'
} 
}

forvalues i=1/5{
forvalues j=2002(3)2008{
capture xtile qui_income_`i'_`j'=renthog_real if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_income=.
forvalues i=1/5{
forvalues j=2002(3)2008{
capture replace qui_income=qui_income_`i'_`j' if imputation==`i' & year==`j'
} 
}

mi xeq: sort h_2008 year; g l1_qui_wealth=l.qui_wealth
mi xeq: sort h_2008 year; g l1_qui_income=l.qui_income

winsor2 l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

* Generamos manualmente la endogena interactiva y el instrumento interactivo
* (necesario porque depvar no admite c.X#c.Y en la 2a first-stage)
mi passive: g shock_l1debty = shock * l1_debty_w
mi passive: g shock_l2debty = shock * l2_debty_w

sort h_2008 year

* 1a. First-stage de la endogena l1_debty_w  -> F_stat1
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2008 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat1 = r(F)

* 1b. First-stage de la endogena (shock x l1_debty_w)  -> F_stat2
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2008 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat2 = r(F)

* 2. Regresion IV principal (sintaxis ORIGINAL con c.shock#c.l1_debty_w)
mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2008 & ownership==2 & l1_ownership==2
estimate store m_2008
estadd scalar F_stat1
estadd scalar F_stat2
      
*****************************************************************************************************************************
* PANEL 2005-2011
*****************************************************************************************************************************
use "$path/Data/panel_2005_2011_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight interest_rate share_fixed_rate debt_service_fin_assets_real debt_service_real_assets_real precautionary debt_service_real refin spec_1 spec_3 p2_5_real spec_2

mi import flong, m(imputation) id(h_2011 year) imputed(liqcons risk edu_h_1 edu_m_1 job_h_1 income_dev income_expect durable members_working sector mrenthog renthog consumption_real actfinanc_real actreales_real vdeuda real_debt fin_debt nonfin_inc_real riquezabr riquezanet constraints gen_constraints years_house shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 contract)

mi xtset h_2011 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap) 

mi passive: g cy=consumption_real/nonfin_inc_real
mi passive: g wy=riquezanet/nonfin_inc_real
mi passive: g debty=vdeuda/nonfin_inc_real

mi xeq: sort h_2011 year; g l1_size=l.size
mi xeq: sort h_2011 year; g d_size=d.size
mi xeq: sort h_2011 year; g l1_kids= l.kids 
mi xeq: sort h_2011 year; g d_members_working= d.members_working 
mi xeq: sort h_2011 year; g l1_members_working= l.members_working 
mi xeq: sort h_2011 year; g d_kids=d.kids
mi xeq: sort h_2011 year; g l1_gage=l.gage
mi xeq: sort h_2011 year; g l1_employment=l.employment
mi xeq: sort h_2011 year; g l1_ownership=l.ownership
mi xeq: sort h_2011 year; g l1_durable=l.durable
mi xeq: sort h_2011 year; g l1_income_dev=l.income_dev
mi xeq: sort h_2011 year; g l1_risk=l.risk
mi xeq: sort h_2011 year; g l1_gen_constraints=l.gen_constraints
mi xeq: sort h_2011 year; g l1_income_expect=l.income_expect
mi xeq: sort h_2011 year; g l1_health_1=l.health_1
mi xeq: sort h_2011 year; g d_health_1=d.health_1
mi xeq: sort h_2011 year; g l1_edu_h_1=l.edu_h_1 
mi xeq: sort h_2011 year; g l1_edu_m_1=l.edu_m_1 
mi xeq: sort h_2011 year; g l1_job_h_1=l.job_h_1
mi xeq: sort h_2011 year; g l1_gender=l.gender
mi xeq: sort h_2011 year; g l1_pareja=l.pareja
mi xeq: sort h_2011 year; g l1_sector=l.sector
mi xeq: sort h_2011 year; g l1_contract=l.contract

global baseline_controls d_size l1_size d_members_working l1_members_working d_kids l1_kids i.l1_gage i.l1_employment l1_health_1 d_health_1 l1_edu_h_1 l1_edu_m_1 l1_job_h_1 i.durable i.l1_durable l1_pareja l1_gender i.income_dev i.l1_income_dev i.risk i.l1_risk i.gen_constraints i.l1_gen_constraints i.income_expect i.l1_income_expect i.l1_contract i.l1_sector years_house 

mi xeq: sort h_2011 year; g dwy=d.wy
mi xeq: sort h_2011 year; g dcy=d.cy
mi xeq: sort h_2011 year; g l1_debty=l.debty 
mi xeq: sort h_2011 year; g l2_debty=l2.debty // INSTRUMENTO
 
forvalues i=1/5{
forvalues j=2005(3)2011{
capture xtile qui_wealth_`i'_`j'=riquezanet if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_wealth=.
forvalues i=1/5{
forvalues j=2005(3)2011{
capture replace qui_wealth=qui_wealth_`i'_`j' if imputation==`i' & year==`j'
} 
}

forvalues i=1/5{
forvalues j=2005(3)2011{
capture xtile qui_income_`i'_`j'=renthog_real if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_income=.
forvalues i=1/5{
forvalues j=2005(3)2011{
capture replace qui_income=qui_income_`i'_`j' if imputation==`i' & year==`j'
} 
}

mi xeq: sort h_2011 year; g l1_qui_wealth=l.qui_wealth
mi xeq: sort h_2011 year; g l1_qui_income=l.qui_income

winsor2 l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debty = shock * l1_debty_w
mi passive: g shock_l2debty = shock * l2_debty_w

sort h_2011 year

* 1a. First-stage de la endogena l1_debty_w  -> F_stat1
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2011 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat1 = r(F)

* 1b. First-stage de la endogena (shock x l1_debty_w)  -> F_stat2
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2011 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat2 = r(F)

* 2. Regresion IV principal (sintaxis ORIGINAL con c.shock#c.l1_debty_w)
mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2011 & ownership==2 & l1_ownership==2
estimate store m_2011
estadd scalar F_stat1
estadd scalar F_stat2

*****************************************************************************************************************************
* PANEL 2008-2014
*****************************************************************************************************************************
use "$path/Data/panel_2008_2014_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real spec_1 spec_2 spec_3 debt_service_fin_assets_real debt_service_real_assets_real
    
mi import flong, m(imputation) id(h_2014 year) imputed(liqcons risk edu_h_1 edu_m_1 job_h_1 income_dev income_expect durable sector mrenthog renthog consumption_real actfinanc_real actreales_real vdeuda real_debt fin_debt nonfin_inc_real riquezabr riquezanet constraints gen_constraints years_house shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 contract members_working)

mi xtset h_2014 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap) 

mi passive: g cy=consumption_real/nonfin_inc_real
mi passive: g wy=riquezanet/nonfin_inc_real
mi passive: g debty=vdeuda/nonfin_inc_real

mi xeq: sort h_2014 year; g l1_size=l.size
mi xeq: sort h_2014 year; g d_size=d.size
mi xeq: sort h_2014 year; g l1_kids= l.kids 
mi xeq: sort h_2014 year; g d_members_working= d.members_working 
mi xeq: sort h_2014 year; g l1_members_working= l.members_working 
mi xeq: sort h_2014 year; g d_kids=d.kids
mi xeq: sort h_2014 year; g l1_gage=l.gage
mi xeq: sort h_2014 year; g l1_employment=l.employment
mi xeq: sort h_2014 year; g l1_ownership=l.ownership
mi xeq: sort h_2014 year; g l1_durable=l.durable
mi xeq: sort h_2014 year; g l1_income_dev=l.income_dev
mi xeq: sort h_2014 year; g l1_risk=l.risk
mi xeq: sort h_2014 year; g l1_gen_constraints=l.gen_constraints
mi xeq: sort h_2014 year; g l1_income_expect=l.income_expect
mi xeq: sort h_2014 year; g l1_health_1=l.health_1
mi xeq: sort h_2014 year; g d_health_1=d.health_1
mi xeq: sort h_2014 year; g l1_edu_h_1=l.edu_h_1 
mi xeq: sort h_2014 year; g l1_edu_m_1=l.edu_m_1 
mi xeq: sort h_2014 year; g l1_job_h_1=l.job_h_1
mi xeq: sort h_2014 year; g l1_gender=l.gender
mi xeq: sort h_2014 year; g l1_pareja=l.pareja
mi xeq: sort h_2014 year; g l1_sector=l.sector
mi xeq: sort h_2014 year; g l1_contract=l.contract

global baseline_controls d_size l1_size d_members_working l1_members_working d_kids l1_kids i.l1_gage i.l1_employment l1_health_1 d_health_1 l1_edu_h_1 l1_edu_m_1 l1_job_h_1 i.durable i.l1_durable l1_pareja l1_gender i.income_dev i.l1_income_dev i.risk i.l1_risk i.gen_constraints i.l1_gen_constraints i.income_expect i.l1_income_expect i.l1_contract i.l1_sector years_house 

mi xeq: sort h_2014 year; g dwy=d.wy
mi xeq: sort h_2014 year; g dcy=d.cy
mi xeq: sort h_2014 year; g l1_debty=l.debty 
mi xeq: sort h_2014 year; g l2_debty=l2.debty // INSTRUMENTO

forvalues i=1/5{
forvalues j=2008(3)2014{
capture xtile qui_wealth_`i'_`j'=riquezanet if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_wealth=.
forvalues i=1/5{
forvalues j=2008(3)2014{
capture replace qui_wealth=qui_wealth_`i'_`j' if imputation==`i' & year==`j'
} 
}

forvalues i=1/5{
forvalues j=2008(3)2014{
capture xtile qui_income_`i'_`j'=renthog_real if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_income=.
forvalues i=1/5{
forvalues j=2008(3)2014{
capture replace qui_income=qui_income_`i'_`j' if imputation==`i' & year==`j'
} 
}

mi xeq: sort h_2014 year; g l1_qui_wealth=l.qui_wealth
mi xeq: sort h_2014 year; g l1_qui_income=l.qui_income

winsor2 l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debty = shock * l1_debty_w
mi passive: g shock_l2debty = shock * l2_debty_w

sort h_2014 year

* 1a. First-stage de la endogena l1_debty_w  -> F_stat1
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2014 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat1 = r(F)

* 1b. First-stage de la endogena (shock x l1_debty_w)  -> F_stat2
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2014 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat2 = r(F)

* 2. Regresion IV principal (sintaxis ORIGINAL con c.shock#c.l1_debty_w)
mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2014 & ownership==2 & l1_ownership==2
estimate store m_2014
estadd scalar F_stat1
estadd scalar F_stat2


*****************************************************************************************************************************
* PANEL 2011-2017
*****************************************************************************************************************************
use "$path/Data/panel_2011_2017_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3
                
mi import flong, m(imputation) id(h_2017 year) imputed(liqcons risk job_h_1 income_dev income_expect durable sector mrenthog renthog consumption_real actfinanc_real actreales_real vdeuda real_debt fin_debt nonfin_inc_real riquezabr riquezanet constraints gen_constraints years_house contract shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 members_working edu_h_1 edu_m_1 )
 
mi xtset h_2017 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap) 

mi passive: g cy=consumption_real/nonfin_inc_real
mi passive: g wy=riquezanet/nonfin_inc_real
mi passive: g debty=vdeuda/nonfin_inc_real

mi xeq: sort h_2017 year; g l1_size=l.size
mi xeq: sort h_2017 year; g d_size=d.size
mi xeq: sort h_2017 year; g l1_kids= l.kids 
mi xeq: sort h_2017 year; g d_members_working= d.members_working 
mi xeq: sort h_2017 year; g l1_members_working= l.members_working 
mi xeq: sort h_2017 year; g d_kids=d.kids
mi xeq: sort h_2017 year; g l1_gage=l.gage
mi xeq: sort h_2017 year; g l1_employment=l.employment
mi xeq: sort h_2017 year; g l1_ownership=l.ownership
mi xeq: sort h_2017 year; g l1_durable=l.durable
mi xeq: sort h_2017 year; g l1_income_dev=l.income_dev
mi xeq: sort h_2017 year; g l1_risk=l.risk
mi xeq: sort h_2017 year; g l1_gen_constraints=l.gen_constraints
mi xeq: sort h_2017 year; g l1_income_expect=l.income_expect
mi xeq: sort h_2017 year; g l1_health_1=l.health_1
mi xeq: sort h_2017 year; g d_health_1=d.health_1
mi xeq: sort h_2017 year; g l1_edu_h_1=l.edu_h_1 
mi xeq: sort h_2017 year; g l1_edu_m_1=l.edu_m_1 
mi xeq: sort h_2017 year; g l1_job_h_1=l.job_h_1
mi xeq: sort h_2017 year; g l1_gender=l.gender
mi xeq: sort h_2017 year; g l1_pareja=l.pareja
mi xeq: sort h_2017 year; g l1_sector=l.sector
mi xeq: sort h_2017 year; g l1_contract=l.contract

global baseline_controls d_size l1_size d_members_working l1_members_working d_kids l1_kids i.l1_gage i.l1_employment l1_health_1 d_health_1 l1_edu_h_1 l1_edu_m_1 l1_job_h_1 i.durable i.l1_durable l1_pareja l1_gender i.income_dev i.l1_income_dev i.risk i.l1_risk i.gen_constraints i.l1_gen_constraints i.income_expect i.l1_income_expect i.l1_contract i.l1_sector years_house 

mi xeq: sort h_2017 year; g dwy=d.wy
mi xeq: sort h_2017 year; g dcy=d.cy
mi xeq: sort h_2017 year; g l1_debty=l.debty 
mi xeq: sort h_2017 year; g l2_debty=l2.debty // INSTRUMENTO
 
forvalues i=1/5{
forvalues j=2011(3)2017{
capture xtile qui_wealth_`i'_`j'=riquezanet if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_wealth=.
forvalues i=1/5{
forvalues j=2011(3)2017{
capture replace qui_wealth=qui_wealth_`i'_`j' if imputation==`i' & year==`j'
} 
}

forvalues i=1/5{
forvalues j=2011(3)2017{
capture xtile qui_income_`i'_`j'=renthog_real if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_income=.
forvalues i=1/5{
forvalues j=2011(3)2017{
capture replace qui_income=qui_income_`i'_`j' if imputation==`i' & year==`j'
} 
}
  
mi xeq: sort h_2017 year; g l1_qui_wealth=l.qui_wealth
mi xeq: sort h_2017 year; g l1_qui_income=l.qui_income

winsor2 l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)
  
mi passive: g shock_l1debty = shock * l1_debty_w
mi passive: g shock_l2debty = shock * l2_debty_w

sort h_2017 year

* 1a. First-stage de la endogena l1_debty_w  -> F_stat1
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2017 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat1 = r(F)

* 1b. First-stage de la endogena (shock x l1_debty_w)  -> F_stat2
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2017 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat2 = r(F)

* 2. Regresion IV principal (sintaxis ORIGINAL con c.shock#c.l1_debty_w)
mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2017 & ownership==2 & l1_ownership==2
estimate store m_2017
estadd scalar F_stat1
estadd scalar F_stat2
        
*****************************************************************************************************************************
* PANEL 2014-2020
*****************************************************************************************************************************
use "$path/Data/panel_2014_2020_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3
                
mi import flong, m(imputation) id(h_2020 year) imputed(liqcons risk job_h_1 income_dev income_expect durable sector mrenthog renthog consumption_real actfinanc_real actreales_real vdeuda real_debt fin_debt nonfin_inc_real riquezabr riquezanet constraints gen_constraints years_house contract shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 members_working edu_h_1 edu_m_1 )
 
mi xtset h_2020 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap) 

mi passive: g cy=consumption_real/nonfin_inc_real
mi passive: g wy=riquezanet/nonfin_inc_real
mi passive: g debty=vdeuda/nonfin_inc_real

mi xeq: sort h_2020 year; g l1_size=l.size
mi xeq: sort h_2020 year; g d_size=d.size
mi xeq: sort h_2020 year; g l1_kids= l.kids 
mi xeq: sort h_2020 year; g d_members_working= d.members_working 
mi xeq: sort h_2020 year; g l1_members_working= l.members_working 
mi xeq: sort h_2020 year; g d_kids=d.kids
mi xeq: sort h_2020 year; g l1_gage=l.gage
mi xeq: sort h_2020 year; g l1_employment=l.employment
mi xeq: sort h_2020 year; g l1_ownership=l.ownership
mi xeq: sort h_2020 year; g l1_durable=l.durable
mi xeq: sort h_2020 year; g l1_income_dev=l.income_dev
mi xeq: sort h_2020 year; g l1_risk=l.risk
mi xeq: sort h_2020 year; g l1_gen_constraints=l.gen_constraints
mi xeq: sort h_2020 year; g l1_income_expect=l.income_expect
mi xeq: sort h_2020 year; g l1_health_1=l.health_1
mi xeq: sort h_2020 year; g d_health_1=d.health_1
mi xeq: sort h_2020 year; g l1_edu_h_1=l.edu_h_1 
mi xeq: sort h_2020 year; g l1_edu_m_1=l.edu_m_1 
mi xeq: sort h_2020 year; g l1_job_h_1=l.job_h_1
mi xeq: sort h_2020 year; g l1_gender=l.gender
mi xeq: sort h_2020 year; g l1_pareja=l.pareja
mi xeq: sort h_2020 year; g l1_sector=l.sector
mi xeq: sort h_2020 year; g l1_contract=l.contract

global baseline_controls d_size l1_size d_members_working l1_members_working d_kids l1_kids i.l1_gage i.l1_employment l1_health_1 d_health_1 l1_edu_h_1 l1_edu_m_1 l1_job_h_1 i.durable i.l1_durable l1_pareja l1_gender i.income_dev i.l1_income_dev i.risk i.l1_risk i.gen_constraints i.l1_gen_constraints i.income_expect i.l1_income_expect i.l1_contract i.l1_sector years_house 

mi xeq: sort h_2020 year; g dwy=d.wy
mi xeq: sort h_2020 year; g dcy=d.cy
mi xeq: sort h_2020 year; g l1_debty=l.debty 
mi xeq: sort h_2020 year; g l2_debty=l2.debty // INSTRUMENTO
 
forvalues i=1/5{
forvalues j=2014(3)2020{
capture xtile qui_wealth_`i'_`j'=riquezanet if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_wealth=.
forvalues i=1/5{
forvalues j=2014(3)2020{
capture replace qui_wealth=qui_wealth_`i'_`j' if imputation==`i' & year==`j'
} 
}
 
forvalues i=1/5{
forvalues j=2014(3)2020{
capture xtile qui_income_`i'_`j'=renthog_real if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_income=.
forvalues i=1/5{
forvalues j=2014(3)2020{
capture replace qui_income=qui_income_`i'_`j' if imputation==`i' & year==`j'
} 
}
  
mi xeq: sort h_2020 year; g l1_qui_wealth=l.qui_wealth
mi xeq: sort h_2020 year; g l1_qui_income=l.qui_income

winsor2 l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)
  
mi passive: g shock_l1debty = shock * l1_debty_w
mi passive: g shock_l2debty = shock * l2_debty_w

sort h_2020 year

* 1a. First-stage de la endogena l1_debty_w  -> F_stat1
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2020 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat1 = r(F)

* 1b. First-stage de la endogena (shock x l1_debty_w)  -> F_stat2
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2020 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat2 = r(F)

* 2. Regresion IV principal (sintaxis ORIGINAL con c.shock#c.l1_debty_w)
mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2020 & ownership==2 & l1_ownership==2
estimate store m_2020
estadd scalar F_stat1
estadd scalar F_stat2
      
*****************************************************************************************************************************
* PANEL 2017-2022
*****************************************************************************************************************************
use "$path/Data/panel_2017_2022_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3

g wave = 1 if year==2017
replace wave = 2 if year==2020
replace wave = 3 if year==2022
                
mi import flong, m(imputation) id(h_2022 year) imputed(liqcons risk job_h_1 income_dev income_expect durable sector mrenthog renthog consumption_real actfinanc_real actreales_real vdeuda real_debt fin_debt nonfin_inc_real riquezabr riquezanet constraints gen_constraints years_house contract shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 members_working edu_h_1 edu_m_1 wave)

mi xtset h_2022 wave
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap) 

mi passive: g cy=consumption_real/nonfin_inc_real
mi passive: g wy=riquezanet/nonfin_inc_real
mi passive: g debty=vdeuda/nonfin_inc_real

mi xeq: sort h_2022 wave; g l1_size=l.size
mi xeq: sort h_2022 wave; g d_size=d.size
mi xeq: sort h_2022 wave; g l1_kids= l.kids 
mi xeq: sort h_2022 wave; g d_members_working= d.members_working 
mi xeq: sort h_2022 wave; g l1_members_working= l.members_working 
mi xeq: sort h_2022 wave; g d_kids=d.kids
mi xeq: sort h_2022 wave; g l1_gage=l.gage
mi xeq: sort h_2022 wave; g l1_employment=l.employment
mi xeq: sort h_2022 wave; g l1_ownership=l.ownership
mi xeq: sort h_2022 wave; g l1_durable=l.durable
mi xeq: sort h_2022 wave; g l1_income_dev=l.income_dev
mi xeq: sort h_2022 wave; g l1_risk=l.risk
mi xeq: sort h_2022 wave; g l1_gen_constraints=l.gen_constraints
mi xeq: sort h_2022 wave; g l1_income_expect=l.income_expect
mi xeq: sort h_2022 wave; g l1_health_1=l.health_1
mi xeq: sort h_2022 wave; g d_health_1=d.health_1
mi xeq: sort h_2022 wave; g l1_edu_h_1=l.edu_h_1 
mi xeq: sort h_2022 wave; g l1_edu_m_1=l.edu_m_1 
mi xeq: sort h_2022 wave; g l1_job_h_1=l.job_h_1
mi xeq: sort h_2022 wave; g l1_gender=l.gender
mi xeq: sort h_2022 wave; g l1_pareja=l.pareja
mi xeq: sort h_2022 wave; g l1_sector=l.sector
mi xeq: sort h_2022 wave; g l1_contract=l.contract

global baseline_controls d_size l1_size d_members_working l1_members_working d_kids l1_kids i.l1_gage i.l1_employment l1_health_1 d_health_1 l1_edu_h_1 l1_edu_m_1 l1_job_h_1 i.durable i.l1_durable l1_pareja l1_gender i.income_dev i.l1_income_dev i.risk i.l1_risk i.gen_constraints i.l1_gen_constraints i.income_expect i.l1_income_expect i.l1_contract i.l1_sector years_house 

mi xeq: sort h_2022 wave; g dwy=d.wy
mi xeq: sort h_2022 wave; g dcy=d.cy
mi xeq: sort h_2022 wave; g l1_debty=l.debty 
mi xeq: sort h_2022 wave; g l2_debty=l2.debty // INSTRUMENTO
 
forvalues i=1/5{
foreach j in 2017 2020 2022 {
capture xtile qui_wealth_`i'_`j'=riquezanet if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_wealth=.
forvalues i=1/5{
foreach j in 2017 2020 2022 {
capture replace qui_wealth=qui_wealth_`i'_`j' if imputation==`i' & year==`j'
} 
}
 
forvalues i=1/5{
foreach j in 2017 2020 2022 {
capture xtile qui_income_`i'_`j'=renthog_real if imputation==`i' & year==`j' , nq(10) 
    }
}
g qui_income=.
forvalues i=1/5{
foreach j in 2017 2020 2022 {
capture replace qui_income=qui_income_`i'_`j' if imputation==`i' & year==`j'
} 
}
  
mi xeq: sort h_2022 wave; g l1_qui_wealth=l.qui_wealth
mi xeq: sort h_2022 wave; g l1_qui_income=l.qui_income

winsor2 l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)
  
mi passive: g shock_l1debty = shock * l1_debty_w
mi passive: g shock_l2debty = shock * l2_debty_w

sort h_2022 wave

* 1a. First-stage de la endogena l1_debty_w  -> F_stat1
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2022 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat1 = r(F)

* 1b. First-stage de la endogena (shock x l1_debty_w)  -> F_stat2
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock l2_debty_w shock_l2debty $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2022 & ownership==2 & l1_ownership==2
mi test l2_debty_w shock_l2debty
scalar F_stat2 = r(F)

* 2. Regresion IV principal (sintaxis ORIGINAL con c.shock#c.l1_debty_w)
mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2022 & ownership==2 & l1_ownership==2
estimate store m_2022
estadd scalar F_stat1
estadd scalar F_stat2
      
*****************************************************************************************************************************
* IMPRESION DE LA TABLA FINAL
*****************************************************************************************************************************

estout m_* using "$tables/Tab2.txt", cells(b(fmt(%9.3f))se(par star fmt(3))) ///
stats(N F_stat1 F_stat2, fmt(%9.0f %9.3f %9.3f) labels("Observations" "F-stat (Debt/Y)" "F-stat (Shock x Debt/Y)")) ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
varlabels(dwy_w "$\Delta{\frac{W_t}{Y_t}}$" l1_debty_w "$\frac{Debt_{t-1}}{Y_{t-1}}$" shock "Unemployment Shock" c.shock#c.l1_debty_w "Shock $\times \frac{Debt_{t-1}}{Y_{t-1}}$") ///
keep(dwy_w shock l1_debty_w c.shock#c.l1_debty_w) ///
order(dwy_w shock l1_debty_w c.shock#c.l1_debty_w) ///
indicate("Wealth FE=*.l1_qui_wealth" "Income FE=*.l1_qui_income" "Controls=l1_size") ///
replace msign(-) style(tex) modelwidth(8) varwidth(25)
