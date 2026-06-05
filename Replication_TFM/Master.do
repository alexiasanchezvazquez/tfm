****************************************************************************************************************************************************
****************************************************************************************************************************************************
********************** When Debt Bites: Household Leverage and the Consumption Cost of Unemployment Shocks. Evidence from Spain ********************
******************************************* by Alexia·Sánchez·Vázquez               ****************************************************************
********************************************Master Do-file,  September 2026          ***************************************************************
****************************************************************************************************************************************************
****************************************************************************************************************************************************
* Run in Stata/MP v 19.5 (Windows / Mac)
clear all


cd "/Users/usuario/Documents/Replication"


// Define global paths for graphs and tables
global path "/Users/usuario/Documents/Replication"
global graphs "$path/Graphs"
global tables "$path/Tables"
global coeff "$path/Data/Figures"


* These files creates the main datasets used in the paper

do "$path/Do/Create main dataset/Create databases/Panel_2002_2008.do"
do "$path/Do/Create main dataset/Create databases/Panel_2005_2011.do"
do "$path/Do/Create main dataset/Create databases/Panel_2008_2014.do"
do "$path/Do/Create main dataset/Create databases/Panel_2011_2017.do"
do "$path/Do/Create main dataset/Create databases/Panel_2014_2020.do"
do "$path/Do/Create main dataset/Create databases/Panel_2017_2022.do"

do "$path/Do/Create main dataset/Create databases/Panel_2002_2008_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2005_2011_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2008_2014_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2011_2017_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2014_2020_constrained.do"
do "$path/Do/Create main dataset/Create databases/Panel_2017_2022_constrained.do"

do "$path/Do/Create main dataset/Create databases/Panel_2002_2008_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2005_2011_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2008_2014_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2011_2017_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2014_2020_constrained_mi_setup.do"
do "$path/Do/Create main dataset/Create databases/Panel_2017_2022_constrained_mi_setup.do"


**************************************************************
**************************************************************
** Manuscript results
**************************************************************
**************************************************************

* do "$path/Do/Figure 1.do"
* do "$path/Do/Figure 2.do"
do "$path/Do/Table 1_nuevo.do"
* do "$path/Do/Figure 3.do"
* do "$path/Do/Figure 4.do"
* do "$path/Do/Table 2.do"
* do "$path/Do/Figures 5 and 6.do"
* do "$path/Do/Table 3.do"
* do "$path/Do/Figure 7.do"


**************************************************************
**************************************************************
** Appendix materials
**************************************************************
**************************************************************

* do "$path/Do/Table A2.do"
* do "$path/Do/Table A3.do"
* do "$path/Do/Table A4.do"

* do "$path/Do/Table A5/Create database Table A5/create_data_tabA5.do"
* do "$path/Do/Table A5/Table A5.do"

* do "$path/Do/Table A6/Create database Table A6/create_data_tabA6.do"
* do "$path/Do/Table A6/Table A6.do"

* do "$path/Do/Table A7/Create database Table A7/create_data_tabA7.do"
* do "$path/Do/Table A7/Table A7.do"

* do "$path/Do/Table A8.do"
* do "$path/Do/Table A9.do"
* do "$path/Do/Table A10.do"
* do "$path/Do/Table A11.do"
* do "$path/Do/Table A12.do"
* do "$path/Do/Table A13.do"
* do "$path/Do/Table A14.do"
* do "$path/Do/Table A15.do"
* do "$path/Do/Figure A1.do"
