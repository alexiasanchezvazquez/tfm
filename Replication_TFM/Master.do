****************************************************************************************************************************************************
****************************************************************************************************************************************************
********************** When Debt Bites: Household Leverage and the Consumption Cost of Unemployment Shocks in Spain ********************************
******************************************* by Alexia·Sánchez·Vázquez               ****************************************************************
******************************************** Master Do-file,  September 2026         ***************************************************************
****************************************************************************************************************************************************
****************************************************************************************************************************************************
* Run in Stata/MP v 19.5 (Windows / Mac)
clear all


cd "/Users/usuario/Documents/Replication"


// Define global paths for graphs and tables
global path "/Users/usuario/Documents/Replication_TFM"
global graphs "$path/Graphs"
global tables "$path/Tables"
global coeff  "$path/Data/Figures"


****************************************************************************************************************************************************
****************************************************************************************************************************************************
** STEP 1 — Create wealth variables (one per EFF wave)
****************************************************************************************************************************************************
****************************************************************************************************************************************************

do "$path/Do/Create main dataset/Create wealth variables/2002_wealth.do"
do "$path/Do/Create main dataset/Create wealth variables/2005_wealth.do"
do "$path/Do/Create main dataset/Create wealth variables/2008_wealth.do"
do "$path/Do/Create main dataset/Create wealth variables/2011_wealth.do"
do "$path/Do/Create main dataset/Create wealth variables/2014_wealth.do"
do "$path/Do/Create main dataset/Create wealth variables/2017_wealth.do"
do "$path/Do/Create main dataset/Create wealth variables/2020_wealth.do"
do "$path/Do/Create main dataset/Create wealth variables/2022_wealth.do"


****************************************************************************************************************************************************
****************************************************************************************************************************************************
** STEP 2 — Create main panel datasets
****************************************************************************************************************************************************
****************************************************************************************************************************************************

* --- Baseline (unconstrained) panels ---
do "$path/Do/Create main dataset/Create databases/Panel_2002_2008.do"
do "$path/Do/Create main dataset/Create databases/Panel_2005_2011.do"
do "$path/Do/Create main dataset/Create databases/Panel_2008_2014.do"
do "$path/Do/Create main dataset/Create databases/Panel_2011_2017.do"
do "$path/Do/Create main dataset/Create databases/Panel_2014_2020.do"
do "$path/Do/Create main dataset/Create databases/Panel_2017_2022.do"

* --- Constrained panels ---
do "$path/Do/Create main dataset/Create databases/Panel_2002_2008_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2005_2011_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2008_2014_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2011_2017_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2014_2020_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2017_2022_constrained.do"

* --- Constrained panels with multiple-imputation setup ---
do "$path/Do/Create main dataset/Create databases/Panel_2002_2008_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2005_2011_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2008_2014_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2011_2017_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2014_2020_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2017_2022_constrained_mi_setup.do"


****************************************************************************************************************************************************
****************************************************************************************************************************************************
** STEP 3 — Manuscript results
****************************************************************************************************************************************************
****************************************************************************************************************************************************

* --- Chapter 2 tables ---
do "$path/Do/Table_2.1.do"
do "$path/Do/Table_2.2.do"

* --- Chapter 3 tables ---
do "$path/Do/Table_3.1.do"
do "$path/Do/Table_3.2.do"
do "$path/Do/Table_3.3.do"
do "$path/Do/Table_3.4.do"

* --- Figures ---
do "$path/Do/Graphs.do"
