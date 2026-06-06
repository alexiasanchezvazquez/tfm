clear all
set more off

* --- paths (defined here so the file is self-contained: clear all drops globals) ---
global path   "/Users/usuario/Documents/Replication_TFM"
global tables "$path/Tables"
global graphs "$path/Graphs"
global coeff  "$path/Data/Figures"

set varabbrev off
set maxvar 10000

*****************************************************************************************************************************
* PANEL 2002-2008
*****************************************************************************************************************************
use "$path/Data/panel_2002_2008_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real refin debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3


foreach base in real_debt fin_debt vdeuda riquezanet riquezabr mrenthog renthog nonfin_inc {
    capture confirm variable `base'_real
    if !_rc {
        local v_`base' `base'_real
    }
    else {
        local v_`base' `base'
    }
}
local RD `v_real_debt'
local FD `v_fin_debt'

mi import flong, m(imputation) id(h_2008 year) imputed(liqcons risk edu_h_1 edu_m_1 job_h_1 income_dev income_expect durable members_working sector `v_mrenthog' `v_renthog' consumption_real actfinanc_real actreales_real `v_vdeuda' `RD' `FD' `v_nonfin_inc' `v_riquezabr' `v_riquezanet' constraints health_1 gen_constraints years_house shock) clear
mi register regular(pareja gage gender ownership size kids employment contract)

mi xtset h_2008 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap)

mi passive: g cy = consumption_real/`v_nonfin_inc'
mi passive: g wy = `v_riquezanet'/`v_nonfin_inc'

mi passive: g debtil_y  = `RD'/`v_nonfin_inc'
mi passive: g debtliq_y = `FD'/`v_nonfin_inc'
mi passive: g debty = `v_vdeuda'/`v_nonfin_inc'

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
* niveles t-1 y t-2 de cada deuda (t-2 = instrumento)
mi xeq: sort h_2008 year; g l1_debtil_y =l.debtil_y
mi xeq: sort h_2008 year; g l2_debtil_y =l2.debtil_y
mi xeq: sort h_2008 year; g l1_debtliq_y=l.debtliq_y
mi xeq: sort h_2008 year; g l2_debtliq_y=l2.debtliq_y
mi xeq: sort h_2008 year; g l1_debty =l.debty
mi xeq: sort h_2008 year; g l2_debty =l2.debty

forvalues i=1/5{
forvalues j=2002(3)2008{
capture xtile qui_wealth_`i'_`j'=`v_riquezanet' if imputation==`i' & year==`j' , nq(10)
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
capture xtile qui_income_`i'_`j'=`v_renthog' if imputation==`i' & year==`j' , nq(10)
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)


mi passive: g shock_l1debty = shock * l1_debty_w
mi passive: g shock_l2debty = shock * l2_debty_w


local Z l2_debty_w shock_l2debty

sort h_2008 year


mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2008 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)



mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2008 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)



mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2008 & ownership==2 & l1_ownership==2
estimate store m_2008
* --- ATE ---
quietly summarize l1_debty_w if year==2008 & ownership==2 & l1_ownership==2 & imputation==1 [aw=facine3]
scalar mDY_2008 = r(mean)
estimates restore m_2008
lincom _b[shock] + mDY_2008*_b[c.shock#c.l1_debty_w]
scalar ate_2008  = r(estimate)
scalar atese_2008 = r(se)
display "ATE agregado 2008 = " ate_2008 "  (SE " atese_2008 ")"
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2005-2011
*****************************************************************************************************************************
use "$path/Data/panel_2005_2011_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight interest_rate share_fixed_rate debt_service_fin_assets_real debt_service_real_assets_real precautionary debt_service_real refin spec_1 spec_3 p2_5_real spec_2


foreach base in real_debt fin_debt vdeuda riquezanet riquezabr mrenthog renthog nonfin_inc {
    capture confirm variable `base'_real
    if !_rc {
        local v_`base' `base'_real
    }
    else {
        local v_`base' `base'
    }
}
local RD `v_real_debt'
local FD `v_fin_debt'

mi import flong, m(imputation) id(h_2011 year) imputed(liqcons risk edu_h_1 edu_m_1 job_h_1 income_dev income_expect durable members_working sector `v_mrenthog' `v_renthog' consumption_real actfinanc_real actreales_real `v_vdeuda' `RD' `FD' `v_nonfin_inc' `v_riquezabr' `v_riquezanet' constraints gen_constraints years_house shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 contract)

mi xtset h_2011 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap)

mi passive: g cy = consumption_real/`v_nonfin_inc'
mi passive: g wy = `v_riquezanet'/`v_nonfin_inc'
mi passive: g debtil_y  = `RD'/`v_nonfin_inc'
mi passive: g debtliq_y = `FD'/`v_nonfin_inc'
mi passive: g debty = `v_vdeuda'/`v_nonfin_inc'

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
mi xeq: sort h_2011 year; g l1_debtil_y =l.debtil_y
mi xeq: sort h_2011 year; g l2_debtil_y =l2.debtil_y
mi xeq: sort h_2011 year; g l1_debtliq_y=l.debtliq_y
mi xeq: sort h_2011 year; g l2_debtliq_y=l2.debtliq_y
mi xeq: sort h_2011 year; g l1_debty =l.debty
mi xeq: sort h_2011 year; g l2_debty =l2.debty

forvalues i=1/5{
forvalues j=2005(3)2011{
capture xtile qui_wealth_`i'_`j'=`v_riquezanet' if imputation==`i' & year==`j' , nq(10)
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
capture xtile qui_income_`i'_`j'=`v_renthog' if imputation==`i' & year==`j' , nq(10)
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w


local Z l2_debty_w shock_l2debty

sort h_2011 year
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2011 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2011 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2011 & ownership==2 & l1_ownership==2
estimate store m_2011
* --- ATE ---
quietly summarize l1_debty_w if year==2011 & ownership==2 & l1_ownership==2 & imputation==1 [aw=facine3]
scalar mDY_2011 = r(mean)
estimates restore m_2011
lincom _b[shock] + mDY_2011*_b[c.shock#c.l1_debty_w]
scalar ate_2011  = r(estimate)
scalar atese_2011 = r(se)
display "ATE agregado 2011 = " ate_2011 "  (SE " atese_2011 ")"
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2008-2014
*****************************************************************************************************************************
use "$path/Data/panel_2008_2014_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real spec_1 spec_2 spec_3 debt_service_fin_assets_real debt_service_real_assets_real


foreach base in real_debt fin_debt vdeuda riquezanet riquezabr mrenthog renthog nonfin_inc {
    capture confirm variable `base'_real
    if !_rc {
        local v_`base' `base'_real
    }
    else {
        local v_`base' `base'
    }
}
local RD `v_real_debt'
local FD `v_fin_debt'

mi import flong, m(imputation) id(h_2014 year) imputed(liqcons risk edu_h_1 edu_m_1 job_h_1 income_dev income_expect durable sector `v_mrenthog' `v_renthog' consumption_real actfinanc_real actreales_real `v_vdeuda' `RD' `FD' `v_nonfin_inc' `v_riquezabr' `v_riquezanet' constraints gen_constraints years_house shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 contract members_working)

mi xtset h_2014 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap)

mi passive: g cy = consumption_real/`v_nonfin_inc'
mi passive: g wy = `v_riquezanet'/`v_nonfin_inc'
mi passive: g debtil_y  = `RD'/`v_nonfin_inc'
mi passive: g debtliq_y = `FD'/`v_nonfin_inc'
mi passive: g debty = `v_vdeuda'/`v_nonfin_inc'

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
mi xeq: sort h_2014 year; g l1_debtil_y =l.debtil_y
mi xeq: sort h_2014 year; g l2_debtil_y =l2.debtil_y
mi xeq: sort h_2014 year; g l1_debtliq_y=l.debtliq_y
mi xeq: sort h_2014 year; g l2_debtliq_y=l2.debtliq_y
mi xeq: sort h_2014 year; g l1_debty =l.debty
mi xeq: sort h_2014 year; g l2_debty =l2.debty

forvalues i=1/5{
forvalues j=2008(3)2014{
capture xtile qui_wealth_`i'_`j'=`v_riquezanet' if imputation==`i' & year==`j' , nq(10)
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
capture xtile qui_income_`i'_`j'=`v_renthog' if imputation==`i' & year==`j' , nq(10)
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w


local Z l2_debty_w shock_l2debty

sort h_2014 year
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2014 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2014 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2014 & ownership==2 & l1_ownership==2
estimate store m_2014
* --- ATE ---
quietly summarize l1_debty_w if year==2014 & ownership==2 & l1_ownership==2 & imputation==1 [aw=facine3]
scalar mDY_2014 = r(mean)
estimates restore m_2014
lincom _b[shock] + mDY_2014*_b[c.shock#c.l1_debty_w]
scalar ate_2014  = r(estimate)
scalar atese_2014 = r(se)
display "ATE agregado 2014 = " ate_2014 "  (SE " atese_2014 ")"
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2011-2017
*****************************************************************************************************************************
use "$path/Data/panel_2011_2017_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3


foreach base in real_debt fin_debt vdeuda riquezanet riquezabr mrenthog renthog nonfin_inc {
    capture confirm variable `base'_real
    if !_rc {
        local v_`base' `base'_real
    }
    else {
        local v_`base' `base'
    }
}
local RD `v_real_debt'
local FD `v_fin_debt'

mi import flong, m(imputation) id(h_2017 year) imputed(liqcons risk job_h_1 income_dev income_expect durable sector `v_mrenthog' `v_renthog' consumption_real actfinanc_real actreales_real `v_vdeuda' `RD' `FD' `v_nonfin_inc' `v_riquezabr' `v_riquezanet' constraints gen_constraints years_house contract shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 members_working edu_h_1 edu_m_1 )

mi xtset h_2017 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap)

mi passive: g cy = consumption_real/`v_nonfin_inc'
mi passive: g wy = `v_riquezanet'/`v_nonfin_inc'
mi passive: g debtil_y  = `RD'/`v_nonfin_inc'
mi passive: g debtliq_y = `FD'/`v_nonfin_inc'
mi passive: g debty = `v_vdeuda'/`v_nonfin_inc'

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
mi xeq: sort h_2017 year; g l1_debtil_y =l.debtil_y
mi xeq: sort h_2017 year; g l2_debtil_y =l2.debtil_y
mi xeq: sort h_2017 year; g l1_debtliq_y=l.debtliq_y
mi xeq: sort h_2017 year; g l2_debtliq_y=l2.debtliq_y
mi xeq: sort h_2017 year; g l1_debty =l.debty
mi xeq: sort h_2017 year; g l2_debty =l2.debty

forvalues i=1/5{
forvalues j=2011(3)2017{
capture xtile qui_wealth_`i'_`j'=`v_riquezanet' if imputation==`i' & year==`j' , nq(10)
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
capture xtile qui_income_`i'_`j'=`v_renthog' if imputation==`i' & year==`j' , nq(10)
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w


local Z l2_debty_w shock_l2debty

sort h_2017 year
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2017 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2017 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2017 & ownership==2 & l1_ownership==2
estimate store m_2017
* --- ATE ---
quietly summarize l1_debty_w if year==2017 & ownership==2 & l1_ownership==2 & imputation==1 [aw=facine3]
scalar mDY_2017 = r(mean)
estimates restore m_2017
lincom _b[shock] + mDY_2017*_b[c.shock#c.l1_debty_w]
scalar ate_2017  = r(estimate)
scalar atese_2017 = r(se)
display "ATE agregado 2017 = " ate_2017 "  (SE " atese_2017 ")"
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2014-2020
*****************************************************************************************************************************
use "$path/Data/panel_2014_2020_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3


foreach base in real_debt fin_debt vdeuda riquezanet riquezabr mrenthog renthog nonfin_inc {
    capture confirm variable `base'_real
    if !_rc {
        local v_`base' `base'_real
    }
    else {
        local v_`base' `base'
    }
}
local RD `v_real_debt'
local FD `v_fin_debt'

mi import flong, m(imputation) id(h_2020 year) imputed(liqcons risk job_h_1 income_dev income_expect durable sector `v_mrenthog' `v_renthog' consumption_real actfinanc_real actreales_real `v_vdeuda' `RD' `FD' `v_nonfin_inc' `v_riquezabr' `v_riquezanet' constraints gen_constraints years_house contract shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 members_working edu_h_1 edu_m_1 )

mi xtset h_2020 year, delta(3)
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap)

mi passive: g cy = consumption_real/`v_nonfin_inc'
mi passive: g wy = `v_riquezanet'/`v_nonfin_inc'
mi passive: g debtil_y  = `RD'/`v_nonfin_inc'
mi passive: g debtliq_y = `FD'/`v_nonfin_inc'
mi passive: g debty = `v_vdeuda'/`v_nonfin_inc'

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
mi xeq: sort h_2020 year; g l1_debtil_y =l.debtil_y
mi xeq: sort h_2020 year; g l2_debtil_y =l2.debtil_y
mi xeq: sort h_2020 year; g l1_debtliq_y=l.debtliq_y
mi xeq: sort h_2020 year; g l2_debtliq_y=l2.debtliq_y
mi xeq: sort h_2020 year; g l1_debty =l.debty
mi xeq: sort h_2020 year; g l2_debty =l2.debty

forvalues i=1/5{
forvalues j=2014(3)2020{
capture xtile qui_wealth_`i'_`j'=`v_riquezanet' if imputation==`i' & year==`j' , nq(10)
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
capture xtile qui_income_`i'_`j'=`v_renthog' if imputation==`i' & year==`j' , nq(10)
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w


local Z l2_debty_w shock_l2debty

sort h_2020 year
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2020 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2020 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2020 & ownership==2 & l1_ownership==2
estimate store m_2020
* --- ATE ---
quietly summarize l1_debty_w if year==2020 & ownership==2 & l1_ownership==2 & imputation==1 [aw=facine3]
scalar mDY_2020 = r(mean)
estimates restore m_2020
lincom _b[shock] + mDY_2020*_b[c.shock#c.l1_debty_w]
scalar ate_2020  = r(estimate)
scalar atese_2020 = r(se)
display "ATE agregado 2020 = " ate_2020 "  (SE " atese_2020 ")"
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2017-2022  (panel irregular: salto 3 anos y luego 2 anos)
*****************************************************************************************************************************
use "$path/Data/panel_2017_2022_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3


foreach base in real_debt fin_debt vdeuda riquezanet riquezabr mrenthog renthog nonfin_inc {
    capture confirm variable `base'_real
    if !_rc {
        local v_`base' `base'_real
    }
    else {
        local v_`base' `base'
    }
}
local RD `v_real_debt'
local FD `v_fin_debt'


g wave = 1 if year==2017
replace wave = 2 if year==2020
replace wave = 3 if year==2022

mi import flong, m(imputation) id(h_2022 year) imputed(liqcons risk job_h_1 income_dev income_expect durable sector `v_mrenthog' `v_renthog' consumption_real actfinanc_real actreales_real `v_vdeuda' `RD' `FD' `v_nonfin_inc' `v_riquezabr' `v_riquezanet' constraints gen_constraints years_house contract shock) clear
mi register regular(pareja gage gender ownership size kids employment health_1 members_working edu_h_1 edu_m_1 wave)

mi xtset h_2022 wave
mi svyset, bsrweight(wt3r_1-wt3r_999) vce(bootstrap)

mi passive: g cy = consumption_real/`v_nonfin_inc'
mi passive: g wy = `v_riquezanet'/`v_nonfin_inc'
mi passive: g debtil_y  = `RD'/`v_nonfin_inc'
mi passive: g debtliq_y = `FD'/`v_nonfin_inc'
mi passive: g debty = `v_vdeuda'/`v_nonfin_inc'

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
mi xeq: sort h_2022 wave; g l1_debtil_y =l.debtil_y
mi xeq: sort h_2022 wave; g l2_debtil_y =l2.debtil_y
mi xeq: sort h_2022 wave; g l1_debtliq_y=l.debtliq_y
mi xeq: sort h_2022 wave; g l2_debtliq_y=l2.debtliq_y
mi xeq: sort h_2022 wave; g l1_debty =l.debty
mi xeq: sort h_2022 wave; g l2_debty =l2.debty

forvalues i=1/5{
foreach j in 2017 2020 2022 {
capture xtile qui_wealth_`i'_`j'=`v_riquezanet' if imputation==`i' & year==`j' , nq(10)
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
capture xtile qui_income_`i'_`j'=`v_renthog' if imputation==`i' & year==`j' , nq(10)
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y l1_debty l2_debty, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w


local Z l2_debty_w shock_l2debty

sort h_2022 wave
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debty_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2022 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debty dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2022 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock $baseline_controls i.l1_qui_wealth i.l1_qui_income (l1_debty_w c.shock#c.l1_debty_w = l2_debty_w c.shock#c.l2_debty_w) if year==2022 & ownership==2 & l1_ownership==2
estimate store m_2022
* --- ATE ---
quietly summarize l1_debty_w if year==2022 & ownership==2 & l1_ownership==2 & imputation==1 [aw=facine3]
scalar mDY_2022 = r(mean)
estimates restore m_2022
lincom _b[shock] + mDY_2022*_b[c.shock#c.l1_debty_w]
scalar ate_2022  = r(estimate)
scalar atese_2022 = r(se)
display "ATE agregado 2022 = " ate_2022 "  (SE " atese_2022 ")"
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PRINT RESULTS
*****************************************************************************************************************************
estout m_* using "$tables/Tab2_liquidez.txt", cells(b(fmt(%9.3f))se(par star fmt(3))) ///
stats(N F_il F_ilx, fmt(%9.0f %9.3f %9.3f) ///
      labels("Observations" "F-stat (Illiq Debt/Y)" "F-stat (Shock x Illiq)")) ///
starlevels(* 0.1 ** 0.05 *** 0.01) ///
varlabels(dwy_w "$\Delta{\frac{W_t}{Y_t}}$" shock "Unemployment Shock" ///
   l1_debtil_y_w  "$\frac{Debt^{Illiq}_{t-1}}{Y_{t-1}}$ (endog.)" ///
   l1_debtliq_y_w "$\frac{Debt^{Liq}_{t-1}}{Y_{t-1}}$ (exog.)" ///
   c.shock#c.l1_debtil_y_w  "Shock $\times \frac{Debt^{Illiq}_{t-1}}{Y_{t-1}}$ (endog.)" ///
   c.shock#c.l1_debtliq_y_w "Shock $\times \frac{Debt^{Liq}_{t-1}}{Y_{t-1}}$ (exog.)") ///
keep(dwy_w shock l1_debtil_y_w c.shock#c.l1_debtil_y_w l1_debtliq_y_w c.shock#c.l1_debtliq_y_w) ///
order(dwy_w shock l1_debtil_y_w c.shock#c.l1_debtil_y_w l1_debtliq_y_w c.shock#c.l1_debtliq_y_w) ///
indicate("Wealth FE=*.l1_qui_wealth" "Income FE=*.l1_qui_income" "Controls=l1_size") ///
replace msign(-) style(tex) modelwidth(8) varwidth(30)


*****************************************************************************************************************************
* PRINT ATE 
*****************************************************************************************************************************
capture file close fB
file open fB using "$tables/Tab_ATE_aggregate.txt", write replace
file write fB "Panel & ATE (illiquid) \\" _n
foreach yr in 2008 2011 2014 2017 2020 2022 {
    local b  = string(ate_`yr',  "%9.3f")
    local s  = string(atese_`yr', "%9.3f")
    file write fB "`yr' & `b' (`s') \\" _n
}
file close fB
display "ATE agregado escrito en $tables/Tab_ATE_aggregate.txt"
