*****************************************************************************************************************************
*****************************************************************************************************************************
* TABLA 2 - VERSION LIQUIDEZ DE LA DEUDA
*   Descompone Debt/Y en:
*     - Deuda ILIQUIDA (colateralizada / inmobiliaria):  debtil_y  = real_debt / Y
*     - Deuda LIQUIDA  (no garantizada / consumo):        debtliq_y = fin_debt  / Y
*   Cada componente (en nivel t-1) interactua con el Shock de desempleo.
*
* Replica EXACTAMENTE la estrategia IV del Tabla_2.do original (ivregress 2sls,
* instrumentando cada regresor endogeno con su lag t-2, mi estimate + svy
* bootstrap, reglas de Rubin), pero ahora hay CUATRO regresores endogenos por
* panel:
*     l1_debtil_y_w                 (deuda iliquida t-1)
*     l1_debtliq_y_w                (deuda liquida t-1)
*     shock x l1_debtil_y_w         (interaccion iliquida)
*     shock x l1_debtliq_y_w        (interaccion liquida)
* instrumentados respectivamente con:
*     l2_debtil_y_w, l2_debtliq_y_w, shock x l2_debtil_y_w, shock x l2_debtliq_y_w
*
* Se reportan 4 F-stats de primera etapa por panel (una por endogena).
*
* DEFINICION DE LIQUIDA / ILIQUIDA (a partir de los *_wealth.do):
*   `v_vdeuda' = dvivpral + deuoprop + phipo + pperso + potrasd + ptmos_tarj
*   real_debt = dvivpral + deuoprop                         -> ILIQUIDA
*   fin_debt  = phipo + pperso + ptmos_tarj + potrasd        -> LIQUIDA
*   (Nota: phipo = prestamos con garantia hipotecaria/real esta clasificado
*    dentro de fin_debt en el pipeline original. Si se prefiere una particion
*    estrictamente colateralizada vs no-colateralizada, habria que mover phipo
*    al bloque iliquido en los *_wealth.do; aqui se respeta la definicion ya
*    existente en el dataset.)
*****************************************************************************************************************************

clear all
set more off
set varabbrev off
set maxvar 10000

*****************************************************************************************************************************
* PANEL 2002-2008
*****************************************************************************************************************************
use "$path/Data/panel_2002_2008_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real refin debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3

* --- nombres robustos de variables monetarias (con o sin sufijo _real) ---
* Detecta automaticamente si las variables llevan sufijo _real en este .dta.
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
* dos ratios de deuda sobre renta no financiera
mi passive: g debtil_y  = `RD'/`v_nonfin_inc'
mi passive: g debtliq_y = `FD'/`v_nonfin_inc'

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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

* endogenas e instrumentos interactivos (depvar no admite c.X#c.Y en 1a etapa)
mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w

* lista de instrumentos (solo para la parte iliquida, endogena)
* solo la deuda iliquida y su interaccion se instrumentan (la liquida es
* control exogeno: su lag t-2 es un instrumento debil, F<5, ver version previa)
local Z l2_debtil_y_w shock_l2debtil

sort h_2008 year

* 1a. First-stage: deuda iliquida t-1
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debtil_y_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2008 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)


* 1c. First-stage: shock x deuda iliquida
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debtil dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2008 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)


* 2. IV: solo la deuda iliquida (nivel e interaccion) es endogena, instrumentada
*    con su t-2; la deuda liquida y su interaccion entran como controles exogenos.
mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock ///
   l1_debtliq_y_w c.shock#c.l1_debtliq_y_w ///
   $baseline_controls i.l1_qui_wealth i.l1_qui_income ///
   (l1_debtil_y_w c.shock#c.l1_debtil_y_w = l2_debtil_y_w c.shock#c.l2_debtil_y_w) ///
   if year==2008 & ownership==2 & l1_ownership==2
estimate store m_2008
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2005-2011
*****************************************************************************************************************************
use "$path/Data/panel_2005_2011_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight interest_rate share_fixed_rate debt_service_fin_assets_real debt_service_real_assets_real precautionary debt_service_real refin spec_1 spec_3 p2_5_real spec_2

* --- nombres robustos de variables monetarias (con o sin sufijo _real) ---
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w

* solo la deuda iliquida y su interaccion se instrumentan (la liquida es
* control exogeno: su lag t-2 es un instrumento debil, F<5, ver version previa)
local Z l2_debtil_y_w shock_l2debtil

sort h_2011 year
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debtil_y_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2011 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debtil dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2011 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock ///
   l1_debtliq_y_w c.shock#c.l1_debtliq_y_w ///
   $baseline_controls i.l1_qui_wealth i.l1_qui_income ///
   (l1_debtil_y_w c.shock#c.l1_debtil_y_w = l2_debtil_y_w c.shock#c.l2_debtil_y_w) ///
   if year==2011 & ownership==2 & l1_ownership==2
estimate store m_2011
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2008-2014
*****************************************************************************************************************************
use "$path/Data/panel_2008_2014_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real spec_1 spec_2 spec_3 debt_service_fin_assets_real debt_service_real_assets_real

* --- nombres robustos de variables monetarias (con o sin sufijo _real) ---
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w

* solo la deuda iliquida y su interaccion se instrumentan (la liquida es
* control exogeno: su lag t-2 es un instrumento debil, F<5, ver version previa)
local Z l2_debtil_y_w shock_l2debtil

sort h_2014 year
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debtil_y_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2014 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debtil dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2014 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock ///
   l1_debtliq_y_w c.shock#c.l1_debtliq_y_w ///
   $baseline_controls i.l1_qui_wealth i.l1_qui_income ///
   (l1_debtil_y_w c.shock#c.l1_debtil_y_w = l2_debtil_y_w c.shock#c.l2_debtil_y_w) ///
   if year==2014 & ownership==2 & l1_ownership==2
estimate store m_2014
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2011-2017
*****************************************************************************************************************************
use "$path/Data/panel_2011_2017_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3

* --- nombres robustos de variables monetarias (con o sin sufijo _real) ---
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w

* solo la deuda iliquida y su interaccion se instrumentan (la liquida es
* control exogeno: su lag t-2 es un instrumento debil, F<5, ver version previa)
local Z l2_debtil_y_w shock_l2debtil

sort h_2017 year
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debtil_y_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2017 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debtil dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2017 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock ///
   l1_debtliq_y_w c.shock#c.l1_debtliq_y_w ///
   $baseline_controls i.l1_qui_wealth i.l1_qui_income ///
   (l1_debtil_y_w c.shock#c.l1_debtil_y_w = l2_debtil_y_w c.shock#c.l2_debtil_y_w) ///
   if year==2017 & ownership==2 & l1_ownership==2
estimate store m_2017
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2014-2020
*****************************************************************************************************************************
use "$path/Data/panel_2014_2020_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3

* --- nombres robustos de variables monetarias (con o sin sufijo _real) ---
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w

* solo la deuda iliquida y su interaccion se instrumentan (la liquida es
* control exogeno: su lag t-2 es un instrumento debil, F<5, ver version previa)
local Z l2_debtil_y_w shock_l2debtil

sort h_2020 year
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debtil_y_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2020 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debtil dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2020 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock ///
   l1_debtliq_y_w c.shock#c.l1_debtliq_y_w ///
   $baseline_controls i.l1_qui_wealth i.l1_qui_income ///
   (l1_debtil_y_w c.shock#c.l1_debtil_y_w = l2_debtil_y_w c.shock#c.l2_debtil_y_w) ///
   if year==2020 & ownership==2 & l1_ownership==2
estimate store m_2020
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* PANEL 2017-2022  (panel irregular: salto 3 anos y luego 2 anos)
*****************************************************************************************************************************
use "$path/Data/panel_2017_2022_constrained_mi.dta", clear

drop interest_rate_type number_pending_loans pending_loans share_remaining_mortgage years_pending years_pending_weight debt_service_real interest_rate share_fixed_rate precautionary p2_5_real debt_service_fin_assets_real debt_service_real_assets_real spec_1 spec_3

* --- nombres robustos de variables monetarias (con o sin sufijo _real) ---
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

* indicador de ola para el panel irregular (debe existir antes del mi import)
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

winsor2 l1_debtil_y l2_debtil_y l1_debtliq_y l2_debtliq_y, cuts(0 99) by(imputation year)
winsor2 dcy dwy , cuts(1 99) by(imputation year)

mi passive: g shock_l1debtil  = shock * l1_debtil_y_w
mi passive: g shock_l2debtil  = shock * l2_debtil_y_w
mi passive: g shock_l1debtliq = shock * l1_debtliq_y_w
mi passive: g shock_l2debtliq = shock * l2_debtliq_y_w

* solo la deuda iliquida y su interaccion se instrumentan (la liquida es
* control exogeno: su lag t-2 es un instrumento debil, F<5, ver version previa)
local Z l2_debtil_y_w shock_l2debtil

sort h_2022 wave
mi estimate, cmdok vceok esampvaryok post: svy: reg l1_debtil_y_w dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2022 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_il = r(F)
mi estimate, cmdok vceok esampvaryok post: svy: reg shock_l1debtil dwy_w shock `Z' $baseline_controls i.l1_qui_wealth i.l1_qui_income if year==2022 & ownership==2 & l1_ownership==2
mi test `Z'
scalar F_ilx = r(F)

mi estimate, cmdok vceok esampvaryok post: svy: ivregress 2sls dcy_w dwy_w shock ///
   l1_debtliq_y_w c.shock#c.l1_debtliq_y_w ///
   $baseline_controls i.l1_qui_wealth i.l1_qui_income ///
   (l1_debtil_y_w c.shock#c.l1_debtil_y_w = l2_debtil_y_w c.shock#c.l2_debtil_y_w) ///
   if year==2022 & ownership==2 & l1_ownership==2
estimate store m_2022
estadd scalar F_il
estadd scalar F_ilx

*****************************************************************************************************************************
* IMPRESION DE LA TABLA FINAL
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
