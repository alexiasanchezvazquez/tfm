*==============================================================================*
* IMAGENES.do  --  Replica en Stata las 5 figuras de la seccion D (Tesis)
*
*   FIGURA 4.1  efecto marginal del shock de desempleo sobre Delta(C/Y) segun
*               apalancamiento previo (Debt/Y), una sub-grafica por ola, IC 90%
*   FIGURA 4.2  A) densidades del share de deuda iliquida por ola (un panel)
*               B) composicion de la cartera de deuda de los deudores por ola
*   FIGURA 4.3  trayectorias del consumo por perfil de shock x apalancamiento (IC95)
*   FIGURA 4.4  relevancia del instrumento IV (binscatter first-stage)
*   FIGURA 4.5  coefplot de beta_3 = Shock x Debt/Y, agregada vs iliquida
*
*   Lee directamente los panel_*_constrained_mi.dta. Usa solo la 1a imputacion.
*   Exporta 5 PDF independientes al directorio imagenes/.
*==============================================================================*

version 14
clear all
set more off
set scheme s2color

*--- Paquetes necesarios (instalar si faltan) ---------------------------------
cap which grstyle
if _rc ssc install grstyle, replace
cap which palettes
if _rc ssc install palettes, replace
cap which colrspace
if _rc ssc install colrspace, replace

*--- Rutas --------------------------------------------------------------------
global path     "/Users/usuario/Documents/Replication_TFM_Entregar"
global data_dir "$path/Data"
global out_dir  "$path/imagenes"
cap mkdir "$out_dir"

*--- Paleta (consistente con el codigo R) -------------------------------------
global BLUE   "0 0 102"      // azul UC3M
global RED    "176 24 43"    // rojo profundo
global INK    "40 40 40"
global GRID   "210 210 210"
global COBALT "8 81 156"     // azul cobalto first-stage
global GRAY   "189 189 189"

*--- Estilo base estilo paper -------------------------------------------------
grstyle clear
grstyle init
grstyle set plain, horizontal grid
grstyle color background white
grstyle color major_grid "$GRID"
grstyle linewidth major_grid thin
grstyle yesno draw_major_hgrid yes
grstyle yesno draw_major_ygrid yes
grstyle gridline_width major_grid vthin
grstyle set legend, nobox

*==============================================================================*
* SUBRUTINA: prep_panel
*   Carga un panel, conserva imputacion==1, construye cy/wy/debty/share_il,
*   primeras diferencias por hogar, winsoriza, y marca esample.
*   Deja los datos en memoria.
*==============================================================================*
program drop _all
program define prep_panel
    args suffix term hid irregular

    use "$data_dir/panel_`suffix'_constrained_mi.dta", clear

    * --- Usar solo la primera imputacion ---
    keep if imputation == 1

    * --- Resolver nombres de variables (con sufijo _real si existe) ---
    * vdeuda
    local v_vdeuda vdeuda
    cap confirm variable vdeuda_real
    if !_rc local v_vdeuda vdeuda_real
    * real_debt
    local v_realdebt real_debt
    cap confirm variable real_debt_real
    if !_rc local v_realdebt real_debt_real
    * nonfin_inc
    local v_nonfin nonfin_inc
    cap confirm variable nonfin_inc_real
    if !_rc local v_nonfin nonfin_inc_real
    * riquezanet
    local v_riqnet riquezanet
    cap confirm variable riquezanet_real
    if !_rc local v_riqnet riquezanet_real
    * consumption
    local v_cons consumption
    cap confirm variable consumption_real
    if !_rc local v_cons consumption_real

    * --- Variable temporal tvar ---
    if `irregular' == 1 {
        gen tvar = .
        replace tvar = 1 if year == 2017
        replace tvar = 2 if year == 2020
        replace tvar = 3 if year == 2022
    }
    else {
        egen tvar = group(year)
    }

    * --- Ratios ---
    gen double cy    = `v_cons'   / `v_nonfin'
    gen double wy    = `v_riqnet' / `v_nonfin'
    gen double debty = `v_vdeuda' / `v_nonfin'
    gen double share_il = .
    replace share_il = `v_realdebt' / `v_vdeuda' if `v_vdeuda' > 0 & `v_vdeuda' < .

    * --- Primeras diferencias por hogar ---
    xtset `hid' tvar
    gen double dcy      = cy - L.cy
    gen double dwy      = wy - L.wy
    gen double l1_debty = L.debty
    gen double l2_debty = L2.debty

    * --- Winsorizacion por ola (year) ---
    * l1_debty_w: [0, p99] ; dcy_w / dwy_w: [p1, p99]
    gen double l1_debty_w = l1_debty
    gen double dcy_w      = dcy
    gen double dwy_w      = dwy
    gen double l2_debty_w = l2_debty

    quietly levelsof year, local(yrs)
    foreach y of local yrs {
        * l1_debty_w en [p0, p99]
        quietly summarize l1_debty if year==`y', detail
        if r(N) > 0 {
            local qhi = r(p99)
            replace l1_debty_w = `qhi' if year==`y' & l1_debty > `qhi' & l1_debty < .
            replace l1_debty_w = r(min) if year==`y' & l1_debty < r(min) & l1_debty < .
        }
        * l2_debty_w en [p0, p99]
        quietly summarize l2_debty if year==`y', detail
        if r(N) > 0 {
            local qhi = r(p99)
            replace l2_debty_w = `qhi' if year==`y' & l2_debty > `qhi' & l2_debty < .
            replace l2_debty_w = r(min) if year==`y' & l2_debty < r(min) & l2_debty < .
        }
        * dcy_w en [p1, p99]
        quietly summarize dcy if year==`y', detail
        if r(N) > 0 {
            local qlo = r(p1)
            local qhi = r(p99)
            replace dcy_w = `qhi' if year==`y' & dcy > `qhi' & dcy < .
            replace dcy_w = `qlo' if year==`y' & dcy < `qlo' & dcy < .
        }
        * dwy_w en [p1, p99]
        quietly summarize dwy if year==`y', detail
        if r(N) > 0 {
            local qlo = r(p1)
            local qhi = r(p99)
            replace dwy_w = `qhi' if year==`y' & dwy > `qhi' & dwy < .
            replace dwy_w = `qlo' if year==`y' & dwy < `qlo' & dwy < .
        }
    }

    * --- Muestra de estimacion: propietarios estables en la ola terminal ---
    gen double l1_ownership = L.ownership
    gen byte esample = (year==`term' & ownership==2 & l1_ownership<. & l1_ownership==2)

    gen wave_lab = `term'
end

*==============================================================================*
* Definicion de los 6 paneles (suffix term hid irregular)
*==============================================================================*
* Se usan tres locals paralelos para iterar
local suf  "2002_2008 2005_2011 2008_2014 2011_2017 2014_2020 2017_2022"
local trm  "2008 2011 2014 2017 2020 2022"
local hids "h_2008 h_2011 h_2014 h_2017 h_2020 h_2022"
local irr  "0 0 0 0 0 1"

*==============================================================================*
* FIGURA 4.1  --  Efecto marginal del shock segun deuda previa (6 sub-graficas)
*==============================================================================*
tempfile fig1data
local first = 1

forvalues k = 1/6 {
    local suffix : word `k' of `suf'
    local term   : word `k' of `trm'
    local hid    : word `k' of `hids'
    local ir     : word `k' of `irr'

    prep_panel "`suffix'" `term' `hid' `ir'

    preserve
        keep if esample==1 & dcy_w<. & l1_debty_w<. & dwy_w<. & shock<.
        count
        if r(N) >= 30 {
            * Regresion lineal con interaccion
            regress dcy_w c.shock##c.l1_debty_w dwy_w

            * Coeficientes y varianzas
            scalar b_sh = _b[shock]
            scalar b_ix = _b[c.shock#c.l1_debty_w]
            matrix V = e(V)
            * posiciones en la matriz de varianzas
            local cn : colfullnames e(b)
            * usamos lincom para obtener el ME y SE en cada punto del grid
            quietly summarize l1_debty_w, detail
            scalar gmin = r(p10)
            scalar gmax = r(p90)

            * grid de 40 puntos
            clear
            set obs 40
            gen panel = "`suffix'"
            gen double x = gmin + (gmax-gmin)*(_n-1)/39
            gen double me = .
            gen double lo = .
            gen double hi = .

            local z90 = 1.6448536269514722
            forvalues i = 1/40 {
                local xv = x[`i']
                * ME = b_sh + b_ix * x ; SE via lincom
                quietly lincom shock + `xv'*c.shock#c.l1_debty_w
                replace me = r(estimate) in `i'
                replace lo = r(estimate) - `z90'*r(se) in `i'
                replace hi = r(estimate) + `z90'*r(se) in `i'
            }

            if `first' == 1 {
                save `fig1data', replace
                local first = 0
            }
            else {
                append using `fig1data'
                save `fig1data', replace
            }
        }
    restore
}

* --- Graficar las 6 sub-graficas (panel = suffix) ---
use `fig1data', clear
gen panel_lab = subinstr(panel, "_", "-", .)
encode panel, gen(pan)

* eje Y comun
quietly summarize lo
local ymin = r(min)
quietly summarize hi
local ymax = r(max)

levelsof pan, local(plist)
local subgraphs ""
local i = 0
foreach p of local plist {
    local i = `i' + 1
    local lbl : label (pan) `p'
    local lbl = subinstr("`lbl'", "_", "-", .)
    twoway ///
        (rarea lo hi x if pan==`p', color("$RED%20") lwidth(none)) ///
        (line me x if pan==`p', lcolor("$RED") lwidth(medium)) ///
        , yline(0, lpattern(dash) lcolor("$INK")) ///
        title("`lbl'", size(medsmall) color("$INK")) ///
        xtitle("") ytitle("") ///
        yscale(range(`ymin' `ymax')) ///
        legend(off) name(g1_`i', replace) nodraw
    local subgraphs "`subgraphs' g1_`i'"
}

graph combine `subgraphs', cols(3) ///
    title("Marginal effect of an unemployment shock on {&Delta}(C/Y)", size(medium) color("$INK")) ///
    subtitle("by prior household leverage (Debt/Y), 90% CI", size(small) color("$INK")) ///
    l1title("Marginal effect on {&Delta}(C/Y)", size(small) color("$INK")) ///
    b1title("Prior leverage  Debt{sub:t-1}/Y{sub:t-1}  (winsorized)", size(small) color("$INK")) ///
    graphregion(color(white)) name(fig1, replace)

graph export "$out_dir/fig_marginal_shock.pdf", replace

*==============================================================================*
* Construir el dataset POOLED (los 6 paneles, solo esample) y el share_df
*==============================================================================*
tempfile poolall sharedf
local firstp = 1
local firsts = 1

forvalues k = 1/6 {
    local suffix : word `k' of `suf'
    local term   : word `k' of `trm'
    local hid    : word `k' of `hids'
    local ir     : word `k' of `irr'

    prep_panel "`suffix'" `term' `hid' `ir'

    * share_df: deudores (ownership==2) en la ola terminal con share_il valido
    preserve
        keep if year==`term' & ownership==2 & share_il<.
        keep share_il
        gen wave = `term'
        if `firsts'==1 {
            save `sharedf', replace
            local firsts = 0
        }
        else {
            append using `sharedf'
            save `sharedf', replace
        }
    restore

    * pooled: solo esample (propietarios estables)
    preserve
        keep if esample==1
        gen wave = `term'
        keep wave wave_lab shock l1_debty debty wy dcy_w l1_debty_w l2_debty_w
        if `firstp'==1 {
            save `poolall', replace
            local firstp = 0
        }
        else {
            append using `poolall'
            save `poolall', replace
        }
    restore
}

*==============================================================================*
* FIGURA 4.2  --  A) densidad del share iliquido  +  B) composicion de cartera
*==============================================================================*
use `sharedf', clear

* gradiente azul (antiguo) -> rojo (reciente)
local c2008 "0 0 102"
local c2011 "55 50 120"
local c2014 "110 70 120"
local c2017 "150 70 100"
local c2020 "180 50 75"
local c2022 "176 24 43"

* Panel A: densidades superpuestas
twoway ///
    (kdensity share_il if wave==2008, lcolor("`c2008'") lwidth(medthin) range(0 1)) ///
    (kdensity share_il if wave==2011, lcolor("`c2011'") lwidth(medthin) range(0 1)) ///
    (kdensity share_il if wave==2014, lcolor("`c2014'") lwidth(medthin) range(0 1)) ///
    (kdensity share_il if wave==2017, lcolor("`c2017'") lwidth(medthin) range(0 1)) ///
    (kdensity share_il if wave==2020, lcolor("`c2020'") lwidth(medthin) range(0 1)) ///
    (kdensity share_il if wave==2022, lcolor("`c2022'") lwidth(medthin) range(0 1)) ///
    , title("A. Distribution of the illiquid debt share, by wave", size(medsmall) color("$INK")) ///
    xtitle("Illiquid debt share  (real debt / total debt)", size(small) color("$INK")) ///
    ytitle("Density", size(small) color("$INK")) ///
    xscale(range(0 1)) xlabel(0(0.25)1) ///
    legend(order(1 "2008" 2 "2011" 3 "2014" 4 "2017" 5 "2020" 6 "2022") ///
        rows(1) size(small) region(lstyle(none))) ///
    graphregion(color(white)) name(figA, replace) nodraw

* Panel B: composicion de cartera de los deudores
gen byte grp = .
replace grp = 3 if share_il >= 0.999          // Only illiquid
replace grp = 1 if share_il <= 0.001          // Only liquid
replace grp = 2 if share_il > 0.001 & share_il < 0.999   // Mixed
label define grpl 1 "Only liquid" 2 "Mixed" 3 "Only illiquid"
label values grp grpl

* porcentajes por ola
preserve
    contract wave grp, freq(n)
    bysort wave: egen tot = total(n)
    gen double pct = 100*n/tot

    * pasar a ancho para barras apiladas
    keep wave grp pct
    reshape wide pct, i(wave) j(grp)
    foreach v in 1 2 3 {
        cap gen pct`v' = 0
        replace pct`v' = 0 if pct`v'>=.
    }
    * apilado: liquid (base) + mixed + illiquid
    gen double s1 = pct1
    gen double s2 = pct1 + pct2
    gen double s3 = pct1 + pct2 + pct3

    local clliq  "110 144 200"   // Only liquid
    local clmix  "183 155 176"   // Mixed
    local clilq  "176 24 43"     // Only illiquid

    twoway ///
        (bar s3 wave, barwidth(2) color("`clilq'")) ///
        (bar s2 wave, barwidth(2) color("`clmix'")) ///
        (bar s1 wave, barwidth(2) color("`clliq'")) ///
        , title("B. Debt-portfolio composition of indebted households, by wave", size(medsmall) color("$INK")) ///
        xtitle("Wave (terminal year)", size(small) color("$INK")) ///
        ytitle("Share of indebted households (%)", size(small) color("$INK")) ///
        xlabel(2008 2011 2014 2017 2020 2022) ///
        legend(order(3 "Only liquid" 2 "Mixed" 1 "Only illiquid") ///
            rows(1) size(small) region(lstyle(none))) ///
        graphregion(color(white)) name(figB, replace) nodraw
restore

graph combine figA figB, cols(1) graphregion(color(white)) name(fig2, replace)
graph export "$out_dir/fig_share_iliquido.pdf", replace

*==============================================================================*
* FIGURA 4.3  --  Trayectorias del consumo por perfil (shock x deuda), IC 95%
*==============================================================================*
use `poolall', clear
keep if shock<. & l1_debty<. & dcy_w<.

gen byte debt_cat  = (l1_debty > 0)        // 1 = Indebted, 0 = Debt-Free
gen byte shock_cat = (shock == 1)          // 1 = Shocked,  0 = Not Shocked

* perfil 1..4: NS-DF, NS-Ind, Sh-DF, Sh-Ind
gen byte profile = .
replace profile = 1 if shock_cat==0 & debt_cat==0
replace profile = 2 if shock_cat==0 & debt_cat==1
replace profile = 3 if shock_cat==1 & debt_cat==0
replace profile = 4 if shock_cat==1 & debt_cat==1

* media y SE por ola x perfil
preserve
    collapse (mean) mean_dcy=dcy_w (sd) sd_dcy=dcy_w (count) n_dcy=dcy_w, ///
        by(wave_lab profile)
    gen double se_dcy = sd_dcy / sqrt(n_dcy)
    gen double lo = mean_dcy - 1.96*se_dcy
    gen double hi = mean_dcy + 1.96*se_dcy

    * pequeno desplazamiento horizontal para que no se solapen
    gen double xpos = wave_lab
    replace xpos = wave_lab - 0.18 if profile==1
    replace xpos = wave_lab - 0.06 if profile==2
    replace xpos = wave_lab + 0.06 if profile==3
    replace xpos = wave_lab + 0.18 if profile==4

    local cNSDF "189 189 189"   // gris neutro
    local cNSIN "82 82 82"      // gris oscuro
    local cSHDF "8 81 156"      // azul cobalto
    local cSHIN "165 15 21"     // rojo carmin

    twoway ///
        (rcap lo hi xpos if profile==1, lcolor("`cNSDF'") lwidth(thin)) ///
        (rcap lo hi xpos if profile==2, lcolor("`cNSIN'") lwidth(thin)) ///
        (rcap lo hi xpos if profile==3, lcolor("`cSHDF'") lwidth(thin)) ///
        (rcap lo hi xpos if profile==4, lcolor("`cSHIN'") lwidth(thin)) ///
        (connected mean_dcy xpos if profile==1, lcolor("`cNSDF'") mcolor("`cNSDF'") msymbol(O) mfcolor(white) lpattern(solid)) ///
        (connected mean_dcy xpos if profile==2, lcolor("`cNSIN'") mcolor("`cNSIN'") msymbol(S) mfcolor(white) lpattern(dash)) ///
        (connected mean_dcy xpos if profile==3, lcolor("`cSHDF'") mcolor("`cSHDF'") msymbol(T) mfcolor(white) lpattern(solid)) ///
        (connected mean_dcy xpos if profile==4, lcolor("`cSHIN'") mcolor("`cSHIN'") msymbol(D) mfcolor(white) lpattern(longdash)) ///
        , yline(0, lcolor(black) lwidth(thin)) ///
        title("D. Consumption Trajectories by Shock and Leverage Profile", size(medsmall) color("$INK")) ///
        subtitle("Average change in consumption-to-income ratio {&Delta}(C/Y), 95% CI", size(small) color("$INK")) ///
        xtitle("Wave (terminal year)", size(small) color("$INK")) ///
        ytitle("Mean {&Delta}(C/Y)", size(small) color("$INK")) ///
        xlabel(2008 2011 2014 2017 2020 2022) ///
        legend(order(5 "Not Shocked - Debt-Free" 6 "Not Shocked - Indebted" ///
                     7 "Shocked - Debt-Free" 8 "Shocked - Indebted") ///
            rows(2) size(small) region(lstyle(none))) ///
        graphregion(color(white)) name(fig4, replace)

    graph export "$out_dir/fig_consumo_tijera.pdf", replace
restore

*==============================================================================*
* FIGURA 4.4  --  Relevancia del instrumento IV (first-stage)
*   y: l1_debty_w (endogena)  x: l2_debty_w (instrumento)
*   Replica el ggplot: nube de puntos de fondo (gris, transparente)
*   + recta de ajuste lineal con banda IC (cobalto)
*   + binscatter de 25 bins como puntos HUECOS (relleno blanco, borde cobalto)
*==============================================================================*
use `poolall', clear
keep if l1_debty_w<. & l2_debty_w<.

local cobalt    "8 81 156"
local graylight "210 210 210"   // gris claro para la nube (sin transparencia)

* --- Recta de ajuste y banda IC calculadas con regress + predict ---
regress l1_debty_w l2_debty_w
predict double yhat, xb
predict double yse, stdp
gen double yhi = yhat + 1.96*yse
gen double ylo = yhat - 1.96*yse

* --- Binscatter manual: 25 grupos por cuantiles del instrumento ---
xtile bin25 = l2_debty_w, nq(25)
preserve
    collapse (mean) bx=l2_debty_w by=l1_debty_w, by(bin25)
    tempfile bins
    save `bins'
restore
merge m:1 bin25 using `bins', nogen

* --- Grafico: capas en orden (fondo -> banda -> recta -> puntos bin) ---
* La banda (rarea) necesita los datos ordenados por x para dibujarse bien.
sort l2_debty_w
twoway ///
    (scatter l1_debty_w l2_debty_w, ///
        msymbol(p) msize(tiny) mcolor("`graylight'")) ///
    (rarea ylo yhi l2_debty_w, ///
        color("`cobalt'") fintensity(15) lwidth(none)) ///
    (line yhat l2_debty_w, ///
        lcolor("`cobalt'") lwidth(medium)) ///
    (scatter by bx, ///
        msymbol(O) msize(medlarge) mfcolor(white) mlcolor("`cobalt'") mlwidth(medthick)) ///
    , title("F. Instrumental Variable Relevance (First-Stage)", size(medsmall) color("$INK")) ///
    subtitle("Pre-shock leverage in t-1 against its historical lag in t-2", size(small) color("$INK")) ///
    xtitle("Instrument: Historical Leverage Debt{sub:t-2}/Y{sub:t-2} (winsorized)", size(small) color("$INK")) ///
    ytitle("Endogenous Regressor: Pre-Shock Leverage Debt{sub:t-1}/Y{sub:t-1} (winsorized)", size(small) color("$INK")) ///
    xscale(range(0 3.5)) yscale(range(0 3.5)) ///
    xlabel(0(1)3) ylabel(0(1)3) ///
    legend(off) ///
    graphregion(color(white)) name(fig6, replace)

graph export "$out_dir/fig_iv_first_stage.pdf", replace

*==============================================================================*
* FIGURA 4.5  --  Coefplot de beta_3 = Shock x Debt/Y (Agregada vs Iliquida)
*   Valores tomados directamente de las Tablas 2.1 y 2.2 de la tesis.
*==============================================================================*
clear
input wave str10 spec b se
2008 "Aggregate" -0.148 0.080
2011 "Aggregate" -0.040 0.049
2014 "Aggregate"  0.073 0.037
2017 "Aggregate"  0.007 0.049
2020 "Aggregate" -0.023 0.026
2022 "Aggregate"  0.068 0.036
2008 "Illiquid"  -0.192 0.110
2011 "Illiquid"  -0.073 0.052
2014 "Illiquid"   0.014 0.037
2017 "Illiquid"   0.019 0.049
2020 "Illiquid"  -0.026 0.028
2022 "Illiquid"   0.068 0.041
end

* IC al 90% (z = 1.645)
local z = 1.6448536269514722
gen double lo = b - `z'*se
gen double hi = b + `z'*se

gen byte agg = (spec=="Aggregate")

* desplazamiento horizontal (dodge)
gen double xpos = wave
replace xpos = wave - 0.22 if agg==1
replace xpos = wave + 0.22 if agg==0

local BLUE "0 0 102"
local RED  "176 24 43"

twoway ///
    (rcap lo hi xpos if agg==1, lcolor("`BLUE'") lwidth(medthin)) ///
    (rcap lo hi xpos if agg==0, lcolor("`RED'")  lwidth(medthin)) ///
    (scatter b xpos if agg==1, mcolor("`BLUE'") msymbol(O) msize(medium)) ///
    (scatter b xpos if agg==0, mcolor("`RED'")  msymbol(T) msize(medium)) ///
    , yline(0, lpattern(dash) lcolor("$INK") lwidth(thin)) ///
    title("The conditional debt-overhang effect {&beta}{sub:3} across the cycle", size(medium) color("$INK")) ///
    subtitle("Coefficient on Shock x Debt/Y, with 90% confidence intervals", size(small) color("$INK")) ///
    xtitle("Wave (terminal year)", size(small) color("$INK")) ///
    ytitle("Estimated {&beta}{sub:3}", size(small) color("$INK")) ///
    xlabel(2008 2011 2014 2017 2020 2022) ///
    legend(order(3 "Aggregate debt (Table 2.1)" 4 "Illiquid debt (Table 2.2)") ///
        rows(1) size(small) region(lstyle(none))) ///
    graphregion(color(white)) name(fig5, replace)

graph export "$out_dir/fig_coefplot_shockdebt.pdf", replace

display as result "=== 5 figuras exportadas a $out_dir ==="
display as result "fig_marginal_shock.pdf"
display as result "fig_share_iliquido.pdf"
display as result "fig_consumo_tijera.pdf"
display as result "fig_iv_first_stage.pdf"
display as result "fig_coefplot_shockdebt.pdf"
