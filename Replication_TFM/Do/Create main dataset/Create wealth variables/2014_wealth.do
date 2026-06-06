


*DEFINITIONS_2014.DOC;

*NOTA GENERAL:
*Tanto los cuadros referidos a la situación financiera de las familias en 2014 como los referidos a 2011, se proporcionan en ambos casos en euros de 2014 para variables relativas al valor de los activos, deuda, renta o gasto. Para ajustar activos y deudas a euros de 2014, los datos de la EFF2011 se han multiplicado por 1,0205. Para ajustar la renta del hogar del año anterior a la encuesta a euros de 2014, los factores aplicados han sido 1,0448 para 2011 y 0,9896 para 2014;
*GENERAL NOTE:
*The tables referring to the financial position of households in 2014 and in 2011 have both been included, the variables relating to the value of assets, debt, income and spending being expressed in 2014 euro in both cases. To adjust assets and debts to 2014 euro, the EFF2011 data were multiplied by 1.0205. To adjust the household’s income for the year prior to the survey to 2014 euro, the factors applied were 1.0448 for 2011 and 0.9896 for 2014;

*CAMBIOS RESPECTO A EFF2005:
*- Las preguntas sobre los negocios por trabajo por cuenta propia se plantean en la sección 4 para el conjunto del hogar. En la sección 6 se han mantenido algunas preguntas específicas para trabajadores por cuenta propia;
*- Se han introducido nuevas preguntas encaminadas a conseguir información sobre carteras gestionadas;
*CHANGES IN RESPECT OF EFF2005:
*- Questions on self-employment businesses are asked in section 4 for all the household members. Section 6 has some specific questions for self-employed. 
*- New questions have been included in the EFF2005 in order to collect information on portfolios under management;

*DEFINICIÓN DE LAS VARIABLES ECONÓMICAS UTILIZADAS EN LOS CUADROS;
*DEFINITION OF THE ECONOMIC VARIABLES USED IN THE TABLES; 

*CUADROS 1.A y 1.B: RIQUEZA Y RENTA;
*TABLES 1.A AND 1.B: NET WEALTH AND INCOME;

*La variable de riqueza neta (riquezanet) se define al final del programa, tras definir los varios activos y deudas;
*The net wealth variable (riquezanet) is defined at the end of the program, after defining the different assets and debts;

*Para renta se utiliza la variable renthog calculada como la suma de rentas laborales y no laborales de todos los miembros del hogar en el año 2013. Cuando el hogar no ha proporcionado valor para alguno de estos componentes, se lleva a cabo una imputación directa de esta renta total;
*For income the variable used is renthog. It is calculated as the sum of labour and non-labour incomes for all household members in 2013. When the household fails to provide a value for one of these components, a direct imputation of total income is performed;

*CUADROS 3 Y 5: TENENCIA Y VALOR DE LOS ACTIVOS FINANCIEROS Y REALES;
*TAMBIEN PARA CUADROS 2 Y 4;
*TABLES 3 AND 5: HOLDING AND VALUE OF FINANCIAL AND REAL ASSETS;
*ALSO FOR TABLES 2 AND 4;

*1.- PARA LA PROPORCION DE HOGARES QUE POSEEN EL ACTIVO;
*1.- FOR THE PERCENTAGE OF HOUSEHOLDS OWNING THAT ASSET;

*ACTIVOS REALES;
*REAL ASSETS;

*VIVIENDA PRINCIPAL;
*MAIN RESIDENCE;
*Para calcular la proporción de hogares que poseen la vivienda principal generamos una nueva variable;
*To calculate the percentage of households that own their main residence we generate a new variable;

gen np2_1=(p2_1==2 & p2_5>0 & p2_5~=.)

*OTRAS PROPIEDADES INMOBILIARIAS;
*OTHER REAL ESTATE PROPERTIES;
*Para calcular la proporción de hogares que poseen otras propiedades inmobiliarias generamos una nueva variable;
*To calculate the percentage of households that own other real estate properties we generate a new variable; 

gen np2_32=((p2_32==1 & p2_33>=1 & p2_33~=. & p2_39_1>0 & p2_39_1~=.)| ///
            (p2_32==1 & p2_33>=2 & p2_33~=. & p2_39_2>0 & p2_39_2~=.)| ///
            (p2_32==1 & p2_33>=3 & p2_33~=. & p2_39_3>0 & p2_39_3~=.)| ///
            (p2_32==1 & p2_33>3  & p2_33~=. & p2_39_4>0 & p2_39_4~=.))
			
*JOYAS, OBRAS DE ARTE, ANTIGUEDADES;
*JEWELLERY, WORKS OF ART, ANTIQUES;
*Para calcular la proporción de hogares que poseen joyas, obras de arte, antigüedades generamos una nueva variable;
*To calculate the percentage of households that own jewellery, works of art and antiques we generate a new variable;

gen np2_82=(p2_82==1 & p2_84>0 & p2_84~=.)

*VALOR DEL NEGOCIO POR TRABAJOS POR CUENTA PROPIA;
*VALUE OF BUSINESSES RELATED TO SELF-EMPLOYMENT;
*Para calcular la proporción de hogares que poseen negocios por cuenta propia utilizamos las variable p4_101 y p4_111;
*To calculate the percentage of households with some business we use the variables p4_101 and p4_111; 

gen haveneg =(p4_101==1)

gen valhog =0
replace valhog =valhog + p4_111_1 if p4_101==1 & p4_111_1>0 & p4_111_1~=.
replace valhog =valhog + p4_111_2 if p4_101==1 & p4_111_2>0 & p4_111_2~=.
replace valhog =valhog + p4_111_3 if p4_101==1 & p4_111_3>0 & p4_111_3~=.
replace valhog =valhog + p4_111_4 if p4_101==1 & p4_111_4>0 & p4_111_4~=.
replace valhog =valhog + p4_111_5 if p4_101==1 & p4_111_5>0 & p4_111_5~=.
replace valhog =valhog + p4_111_6 if p4_101==1 & p4_111_6>0 & p4_111_6~=.

gen havenegval =(haveneg==1 & valhog>0)

*ALGUN TIPO DE ACTIVO REAL;
*SOME KIND OF REAL ASSET;

gen  tienereal=(np2_1==1|np2_32==1|np2_82==1| havenegval==1)

*ACTIVOS FINANCIEROS;
*FINANCIAL ASSETS;

*CUENTAS Y DEPOSITOS UTILIZABLES PARA REALIZAR PAGOS;
*ACCOUNTS AND DEPOSITS USABLE FOR PAYMENTS;
*Para calcular la proporción de hogares que poseen cuentas y depósitos para realizar pagos y que declaran un valor estrictamente positivo para el saldo de estas cuentas generamos una nueva variable;
*To calculate the percentage of households that own accounts and deposits usable for payments and that declare a strictly positive value for the balance of those accounts we generate a new variable;

gen np4_5=(p4_5==1 & p4_7_3>0 & p4_7_3~=.)

*ACCIONES COTIZADAS EN BOLSA;
*LISTED SHARES;
*Para calcular la proporción de hogares que poseen acciones cotizadas y que declaran un valor estrictamente positivo para dicha cartera generamos una nueva variable;
*To calculate the percentage of households that own listed and that declare a strictly positive value for that portfolio we generate a new variable;

gen np4_10=(p4_10==1 & p4_15>0 & p4_15~=.)

*ACCIONES NO COTIZADAS EN BOLSA Y PARTICIPACIONES;
*UNLISTED SHARES AND OTHER EQUITY;
*Para calcular la proporción de hogares que poseen acciones no cotizadas y participaciones y que declaran un valor estrictamente positivo para dicha cartera generamos una nueva variable;
*To calculate the percentage of households that own unlisted shares and other equity and that declare a strictly positive value for that portfolio we generate a new variable;

gen np4_18=(p4_18==1 & p4_24>0 & p4_24~=.)

*VALORES DE RENTA FIJA;
*FIXED-INCOME SECURITIES;
*Para calcular la proporción de hogares que poseen valores de renta fija y que declaran un valor estrictamente positivo para dicha cartera generamos una nueva variable;
*To calculate the percentage of households that own fixed-income securities and that declare a strictly positive value for that portfolio we generate a new variable;

gen np4_33=(p4_33==1 & p4_35>0 & p4_35~=.)

*FONDOS DE INVERSION;
*MUTUAL FUNDS;
*Para calcular la proporción de hogares que poseen fondos de inversión y que declaran un valor estrictamente positivo para dicha cartera generamos una nueva variable;
*To calculate the percentage of households that own mutual funds and that declare a strictly positive value for that portfolio we generate a new variable;

gen np4_27=((p4_27==1 & p4_28>=1 & p4_28~=. & p4_31_1>0 & p4_31_1~=.)| ///
            (p4_27==1 & p4_28>=2 & p4_28~=. & p4_31_2>0 & p4_31_2~=.)| ///
            (p4_27==1 & p4_28>=3 & p4_28~=. & p4_31_3>0 & p4_31_3~=.)| ///
            (p4_27==1 & p4_28>=4 & p4_28~=. & p4_31_4>0 & p4_31_4~=.)| ///
            (p4_27==1 & p4_28>=5 & p4_28~=. & p4_31_5>0 & p4_31_5~=.)| ///
            (p4_27==1 & p4_28>=6 & p4_28~=. & p4_31_6>0 & p4_31_6~=.)| ///
            (p4_27==1 & p4_28>=7 & p4_28~=. & p4_31_7>0 & p4_31_7~=.)| ///
            (p4_27==1 & p4_28>=8 & p4_28~=. & p4_31_8>0 & p4_31_8~=.)| ///
            (p4_27==1 & p4_28>=9 & p4_28~=. & p4_31_9>0 & p4_31_9~=.)| ///
            (p4_27==1 & p4_28>9 & p4_28~=. & p4_31_10>0 & p4_31_10~=.))

*CUENTAS VIVIENDA Y CUENTAS NO UTILIZABLES PARA REALIZAR PAGOS;
*HOUSE-PURCHASE SAVINGS ACCOUNTS AND ACCOUNTS NOT USABLE FOR PAYMENTS;
*Para calcular la proporción de hogares que poseen cuentas vivienda y/o cuentas y depósitos para realizar pagos y que declaran un valor estrictamente positivo para el saldo de estas cuentas generamos una nueva variable;
*To calculate the percentage of households that own house-purchase saving accounts and/or accounts not usable for payments and that declare a strictly positive value for the balance of those accounts we generate a new variable;

gen cuentas=((p4_3==1 & p4_7_1>0 & p4_7_1~=.)|(p4_4==1 & p4_7_2>0 & p4_7_2~=.))



*PLANES DE PENSIONES;
*PENSION SCHEMES;
*Para calcular la proporción de hogares que poseen planes de pensiones y que declaran un valor estrictamente positivo para el valor de estos planes generamos una nueva variable;
*To calculate the percentage of households that own pension schemes and that declare a strictly positive value for the balance of those pension schemes we generate a new variable;

gen np5_1=((p5_1==1 & p5_1a>=1 & p5_1a~=. & p5_7_1>0 & p5_7_1~=.)| ///
           (p5_1==1 & p5_1a>=2 & p5_1a~=. & p5_7_2>0 & p5_7_2~=.)| ///
           (p5_1==1 & p5_1a>=3 & p5_1a~=. & p5_7_3>0 & p5_7_3~=.)| ///
           (p5_1==1 & p5_1a>=4 & p5_1a~=. & p5_7_4>0 & p5_7_4~=.)| ///
           (p5_1==1 & p5_1a>=5 & p5_1a~=. & p5_7_5>0 & p5_7_5~=.)| ///
           (p5_1==1 & p5_1a>=6 & p5_1a~=. & p5_7_6>0 & p5_7_6~=.)| ///
           (p5_1==1 & p5_1a>=7 & p5_1a~=. & p5_7_7>0 & p5_7_7~=.)| ///
           (p5_1==1 & p5_1a>=8 & p5_1a~=. & p5_7_8>0 & p5_7_8~=.)| ///
           (p5_1==1 & p5_1a>=9 & p5_1a~=. & p5_7_9>0 & p5_7_9~=.)| ///
           (p5_1==1 & p5_1a>9 & p5_1a~=. & p5_7_10>0 & p5_7_10~=.))

*SEGUROS DE VIDA;
*LIFE INSURANCE;
*Para calcular la proporción de hogares que tienen seguros tipo unit linked o mixto generamos una nueva variable;
*To calculate the percentage of households that own unit-linked or mixed life insurance we generate a new variable;

gen seguro=((p5_9a==1 & p5_10a>=1 & p5_10a~=. & p5_13_1==2 & p5_14_1>0 & p5_14_1~=.)| ///
                    (p5_9a==1 & p5_10a>=2 & p5_10a~=. & p5_13_2==2 & p5_14_2>0 & p5_14_2~=.)| ///
                    (p5_9a==1 & p5_10a>=3 & p5_10a~=. & p5_13_3==2 & p5_14_3>0 & p5_14_3~=.)| ///
                    (p5_9a==1 & p5_10a>=4 & p5_10a~=. & p5_13_4==2 & p5_14_4>0 & p5_14_4~=.)| ///
                    (p5_9a==1 & p5_10a>=5 & p5_10a~=. & p5_13_5==2 & p5_14_5>0 & p5_14_5~=.)| ///
                    (p5_9a==1 & p5_10a>5 &   p5_10a~=. & p5_13_6==2 & p5_14_6>0 & p5_14_6~=.)| ///
	       (p5_9a==1 & p5_10a>=1 & p5_10a~=. & p5_13_1==3 & p5_14_1>0 & p5_14_1~=.)| ///
                    (p5_9a==1 & p5_10a>=2 & p5_10a~=. & p5_13_2==3 & p5_14_2>0 & p5_14_2~=.)| ///
                    (p5_9a==1 & p5_10a>=3 & p5_10a~=. & p5_13_3==3 & p5_14_3>0 & p5_14_3~=.)| ///
                    (p5_9a==1 & p5_10a>=4 & p5_10a~=. & p5_13_4==3 & p5_14_4>0 & p5_14_4~=.)| ///
                    (p5_9a==1 & p5_10a>=5 & p5_10a~=. & p5_13_5==3 & p5_14_5>0 & p5_14_5~=.)| ///
                    (p5_9a==1 & p5_10a>5 &   p5_10a~=. & p5_13_6==3 & p5_14_6>0 & p5_14_6~=.))	

*PLANES DE PENSIONES INCLUYENDO SEGUROS DE VIDA DE INVERSION O MIXTOS;
*PENSION SCHEMES INCLUDING UNIT-LINKED OR MIXED LIFE INSURANCE;

gen penseg=(np5_1==1|seguro==1)

*CARTERAS GESTIONADAS;
*PORTFOLIOS UNDER MANAGEMENT;

gen cart_gest=((p4_41==1 & p4_42==1) & p4_43>0 & p4_43~=.)

*OTROS ACTIVOS FINANCIEROS;
*OTHER FINANCIAL ASSETS; 
*Para calcular la proporción de hogares a los que les debe dinero o bien el negocio u otras personas generamos una nueva variable sideuda;
*To calculate the percentage of households to whom the business or other people owe money we generate the variable sideuda; 

*PROGRAMA PARA CALCULAR LO QUE LES DEBEN LOS NEGOCIOS A LOS DISTINTOS MIEMBROS DEL HOGAR (P4_116);
*PROGRAM TO OBTAIN WHAT THE BUSINESSES OWE TO THE DIFFERENT HOUSEHOLD MEMBERS (P4_116);

gen valdeuhog=0
gen havedeuhog=0
forvalues m=1/6   {
	replace valdeuhog=valdeuhog+p4_116_`m' if (p4_116_`m'>0 & p4_116_`m'~=.)
	replace havedeuhog=1 if (p4_115_`m'==1)
	}
gen sideuda=((havedeuhog ==1 & valdeuhog>0)|(p4_37==1 & p4_38>0 & p4_38~=.))

*Nota: En los resultados mostrados para 2014 en la columna “Otros activos financieros” del Cuadro 5 del documento “Encuesta Financiera de las Familias (EFF) 2014: Métodos, Resultados y Cambios desde 2011”, se incluye la tenencia de las carteras gestionadas;
*Note: The results shown for 2014 in column “Other financial assets” from Table 5 of the document “Survey of Household Finances (EFF) 2014: Methods, results and changes since 2011” include the percentage of households that own portfolios under management;

*ALGUN TIPO DE ACTIVO FINANCIERO;
*SOME TYPE OF FINANCIAL ASSET;

gen tienefin=(np4_5==1|np4_10==1|np4_18==1|np4_33==1|np4_27==1|cuentas==1|np5_1==1|seguro==1|sideuda==1|cart_gest==1)

*ALGUN TIPO DE ACTIVO;
*SOME TYPE OF ASSET;

gen tiene=(tienereal==1|tienefin==1)

*2.- PARA EL VALOR DE DICHOS ACTIVOS;
*2.- FOR THE VALUE OF THOSE ASSETS;

*ACTIVOS REALES;
*REAL ASSETS;

*VIVIENDA PRINCIPAL;
*MAIN RESIDENCE;
*Para calcular el valor de la vivienda principal generamos una nueva variable np2_5;
*To obtain the value of the main residence we generate a new variable;

gen np2_5=p2_5 if p2_1b==1
replace np2_5=p2_5*(p2_1c/100) if p2_1b==2

*OTRAS PROPIEDADES INMOBILIARIAS;
*OTHER REAL ESTATE PROPERTIES;
*Para calcular el valor de las otras propiedades inmobiliarias generamos una nueva variable;
*To obtain the value of the other real estate properties we generate a new variable;

gen otraspr=0
replace otraspr=otraspr+p2_39_1*(p2_37_1/100) if (p2_33>=1 & p2_33~=. & p2_39_1>=0 & p2_39_1~=. & p2_37_1>0 & p2_37_1~=.)
replace otraspr=otraspr+p2_39_2 *(p2_37_2/100) if (p2_33>=2 & p2_33~=. & p2_39_2>=0 & p2_39_2~=. & p2_37_2>0 & p2_37_2~=.)
replace otraspr=otraspr+p2_39_3* (p2_37_3/100) if (p2_33>=3 & p2_33~=. & p2_39_3>=0 & p2_39_3~=. & p2_37_3>0 & p2_37_3~=.)
replace otraspr=otraspr+p2_39_4 if (p2_33>3 & p2_33~=. & p2_39_4>=0 & p2_39_4~=.)

*JOYAS, OBRAS DE ARTE, ANTIGUEDADES;
*JEWELLERY, WORKS OF ART, ANTIQUES;
*Para calcular el valor de las joyas, obras de arte, antigüedades utilizamos la variable p2_84;
*To obtain the value of the jewellery, works of art and antiques we use the variable p2_84;

*VALOR DEL NEGOCIO POR TRABAJOS POR CUENTA PROPIA;
*VALUE OF THE BUSINESS RELATED TO SELF-EMPLOYMENT;
*la mediana del valor del negocio será la mediana de valhog if havenegval==1; 
*The median of the business value is equal to the median of valhog if havenegval==1;

*ACTIVOS FINANCIEROS;
*FINANCIAL ASSETS;

*CUENTAS Y DEPOSITOS UTILIZABLES PARA REALIZAR PAGOS;
*ACCOUNTS AND DEPOSITS USABLE FOR PAYMENTS;
*Para calcular el saldo de las cuentas y depósitos para realizar pagos utilizamos la variable p4_7_3;
*To obtain the balance of the accounts and deposits usable for payments we use the variable p4_7_3;

*ACCIONES COTIZADAS EN BOLSA;
*LISTED SHARES;
*Para calcular el valor de las acciones cotizadas utilizamos la variable p4_15;
*To obtain the value of the listed shares we use the variable p4_15;

*ACCIONES NO COTIZADAS EN BOLSA Y PARTICIPACIONES;
*UNLISTED SHARES ANDOTHER EQUITY;
*Para calcular el valor de las acciones no cotizadas y participaciones utilizamos la variable p4_24;
*To obtain the value of the unlisted shares and other equity we use the variable p4_24;

*VALORES DE RENTA FIJA;
*FIXED-INCOME SECURITIES;
*Para calcular el valor de los valores de renta fija utilizamos la variable p4_35;
*To obtain the value of the fixed-income securities we use the variable p4_35;

*FONDOS DE INVERSION;
*MUTUAL FUNDS;
*Para calcular el valor total de los fondos de inversión utilizamos la variable allf calculada como (i) la suma de los valores de cada uno de los fondos de inversión que posee el hogar (p4_31_i; i=1,…,10) si el número de estos fondos es menor o igual a 10, y (ii) el valor total de los fondos de inversión del hogar si posee más de 10 fondos (p4_28a);
*To obtain the total value of mutual funds we use the variable allf calculated as (i) the addition of the values of each mutual fund that the household owns (p4_31_i; i=1,…,10) if the number of these funds is 10 or less, and (ii) the household mutual funds’ total value if this one owns more than 10 (p4_28a);


egen allf=rowtotal(p4_31_1 p4_31_2 p4_31_3 p4_31_4 p4_31_5 p4_31_6 p4_31_7 p4_31_8 p4_31_9 p4_31_10) if p4_28<11
replace allf = p4_28a if p4_28>10
replace allf = 0 if allf==.



*CUENTAS VIVIENDA Y CUENTAS NO UTILIZABLES PARA REALIZAR PAGOS;
*HOME-PURCHASE SAVINGS ACCOUNTS AND ACCOUNTS NOT USABLE FOR PAYMENTS;
*Para calcular el saldo de las cuentas vivienda y las cuentas y depósitos no utilizables para realizar pagos generamos una nueva variable;
*To obtain the balance of the house-purchase saving accounts and the accounts and deposits not usable for payments we generate a new variable;  

gen salcuentas=0
replace salcuentas = salcuentas +p4_7_1 if p4_3==1
replace salcuentas = salcuentas + p4_7_2 if p4_4==1

*PLANES DE PENSIONES;
*PENSION SCHEMES;
*Para calcular valor actualizado de los planes de pensiones generamos una nueva variable;
*To obtain the current value of the pension schemes we generate a new variable;

gen valor=0
replace valor = valor +p5_7_1 if (p5_1==1 & p5_7_1>=0 & p5_7_1~=. )
replace valor = valor + p5_7_2 if (p5_1==1 & p5_7_2>=0 & p5_7_2~=.)
replace valor = valor + p5_7_3 if (p5_1==1 & p5_7_3>=0 & p5_7_3~=.)
replace valor = valor + p5_7_4 if (p5_1==1 & p5_7_4>=0 & p5_7_4~=.)
replace valor = valor + p5_7_5 if (p5_1==1 & p5_7_5>=0 & p5_7_5~=.)
replace valor = valor + p5_7_6 if (p5_1==1 & p5_7_6>=0 & p5_7_6~=.)
replace valor = valor + p5_7_7 if (p5_1==1 & p5_7_7>=0 & p5_7_7~=.)
replace valor = valor + p5_7_8 if (p5_1==1 & p5_7_8>=0 & p5_7_8~=.)
replace valor = valor + p5_7_9 if (p5_1==1 & p5_7_9>=0 & p5_7_9~=.)
replace valor = valor + p5_7_10 if (p5_1==1 & p5_7_10>=0 & p5_7_10~=.)

*No consideramos las mutualidades;
*We do not consider mutual insurance;

*SEGUROS DE VIDA;
*LIFE INSURANCE;
*Para calcular el valor de estos seguros tipo unit linked o mixto generamos una nueva variable;
*To obtain the value of the unit-linked or mixed life insurance we generate a new variable;

gen valseg=0
replace valseg = valseg +p5_14_1 if ((p5_13_1==2| p5_13_1==3) & p5_14_1>=0 & p5_14_1~=.)
replace valseg = valseg +p5_14_2 if ((p5_13_2==2| p5_13_2==3) & p5_14_2>=0 & p5_14_2~=.)
replace valseg = valseg +p5_14_3 if ((p5_13_3==2| p5_13_3==3) & p5_14_3>=0 & p5_14_3~=.)
replace valseg = valseg +p5_14_4 if ((p5_13_4==2| p5_13_4==3) & p5_14_4>=0 & p5_14_4~=.)
replace valseg = valseg +p5_14_5 if ((p5_13_5==2| p5_13_5==3) & p5_14_5>=0 & p5_14_5~=.)
replace valseg = valseg +p5_14_6 if ((p5_13_6==2| p5_13_6==3) & p5_14_6>=0 & p5_14_6~=.)

*PLANES DE PENSIONES INCLUYENDO SEGUROS DE VIDA DE INVERSION O MIXTOS;
*PENSION SCHEMES INCLUDING UNIT-LINKED OR MIXED LIFE INSURANCE;

gen valpenseg=valor+valseg

*CARTERAS GESTIONADAS;
*PORTFOLIOS UNDER MANAGEMENT;
*Para calcular el valor de las carteras gestionadas utilizamos la variable p4_43;
*To obtain the value of the portfolios under management we use the variable p4_43;

*OTROS ACTIVOS FINANCIEROS;
*OTHER FINANCIAL ASSETS;
*Para calcular el valor de la mediana de lo que se debe al hogar, utilizamos las variables valdeuhog y p4_38 y generamos una nueva variable;
*To obtain the median of how much is owed to the household, we use the variables valdeuhog and p4_38 and generate a new variable; 

gen odeuhog=0
replace odeuhog = odeuhog +valdeuhog if (valdeuhog>0)
replace odeuhog = odeuhog +p4_38 if (p4_38>0 & p4_38~=.)

*Nota: En los resultados mostrados para 2014 en la columna “Otros activos financieros” del Cuadro 5 del documento “Encuesta Financiera de las Familias (EFF) 2014: Métodos, Resultados y Cambios desde 2011”, se incluye el valor de las carteras gestionadas.
*Note: The results shown for 2014 in column “Other financial assets” from Table 5 of the document “Survey of Household Finances (EFF) 2014: Methods, results and changes since 2011” include the value of the portfolios under management;


*CUADRO 7: PROPORCION DE HOGARES Y MEDIANA DEL VALOR DE LOS DISTINTOS TIPOS DE DEUDA PENDIENTES;
*TABLE 7: PERCENTAGE OF HOUSEHOLDS AND VALUE’S MEDIAN OF THE DIFFERENT TYPES OF OUTSTANDING DEBT;

*DEUDAS  CLASIFICADAS POR TIPO DE ACTIVO INMOBILIARIO (TODO TIPO DE PRESTAMOS);
*DEBT CLASSIFIED BY TYPE OF REAL ESTATE ASSET (ALL KIND OF LOANS);

*VIVIENDA PRINCIPAL;
*MAIN RESIDENCE;
*Para calcular la proporción de hogares que tienen deudas pendientes de préstamos solicitados para la adquisición de la vivienda principal, generamos una nueva variable;
*To obtain the percentage of households that have outstanding debt from loans used to purchase their main residence, we generate a new variable;

gen np2_8=p2_8
replace np2_8=0 if p2_8==.

*Para calcular el valor de las deudas pendientes de préstamos solicitados para la adquisición de la vivienda principal, generamos una nueva variable;
*To obtain the value of the outstanding debts from loans used to purchase their main residence, we generate a new variable;

gen dvivpral=0
replace dvivpral= dvivpral +p2_12_1 if (p2_8a>=1 & p2_8a~=. & p2_12_1>0 & p2_12_1~=.)
replace dvivpral= dvivpral +p2_12_2 if (p2_8a>=2 & p2_8a~=. & p2_12_2>0 & p2_12_2~=.)
replace dvivpral= dvivpral +p2_12_3 if (p2_8a>=3 & p2_8a~=. & p2_12_3>0 & p2_12_3~=.)
replace dvivpral= dvivpral +p2_12_4 if (p2_8a>3 & p2_8a~=. & p2_12_4>0 & p2_12_4~=.)

*OTRAS PROPIEDADES INMOBILIARIAS DIFERENTES DE LA VIVIENDA PRINCIPAL;
*OTHER REAL ESTATE PROPERTIES DIFFERENT FROM THE MAIN RESIDENCE;

*Para calcular la proporción de hogares que tienen deudas pendientes de préstamos solicitados para la adquisición de otras propiedades inmobiliarias diferentes de la vivienda principal, generamos una nueva variable;
*To obtain the percentage of households that have outstanding debts from loans used to purchase other real estate properties different from the main residence, we generate a new variable;

gen dpdte=(p2_50_1==1|p2_50_2==1|p2_50_3==1|p2_50_4==1)

*Para calcular el valor de las deudas pendientes de préstamos solicitados para la adquisición de otras propiedades inmobiliarias diferentes de la vivienda principal, generamos cuatro nuevas variables;
*To obtain the value of the outstanding debts from loans used to purchase other real estate properties different from the main residence, we generate four new variables;

*PARA LA PRIMERA PROPIEDAD INMOBILIARIA;
*FOR THE FIRST REAL ESTATE PROPERTY;
gen dprop1=0
replace dprop1= dprop1+p2_55_1_1 if (p2_51_1>=1 & p2_51_1~=. & p2_55_1_1>0 & p2_55_1_1~=.)
replace dprop1= dprop1+p2_55_1_2 if (p2_51_1>=2 & p2_51_1~=. & p2_55_1_2>0 & p2_55_1_2~=.)
replace dprop1= dprop1+p2_55_1_3 if (p2_51_1>=3 & p2_51_1~=. & p2_55_1_3>0 & p2_55_1_3~=.)

*PARA LA SEGUNDA PROPIEDAD INMOBILIARIA;
*FOR THE SECOND REAL ESTATE PROPERTY;
gen dprop2=0
replace dprop2= dprop2+p2_55_2_1 if (p2_51_2>=1 & p2_51_2~=. & p2_55_2_1>0 & p2_55_2_1~=.)
replace dprop2= dprop2+p2_55_2_2 if (p2_51_2>=2 & p2_51_2~=. & p2_55_2_2>0 & p2_55_2_2~=.)
replace dprop2= dprop2+p2_55_2_3 if (p2_51_2>=3 & p2_51_2~=. & p2_55_2_3>0 & p2_55_2_3~=.)

*PARA LA TERCERA PROPIEDAD INMOBILIARIA;
*FOR THE THIRD REAL ESTATE PROPERTY;
gen dprop3=0
replace dprop3= dprop3+p2_55_3_1 if (p2_51_3>=1 & p2_51_3~=. & p2_55_3_1>0 & p2_55_3_1~=.)
replace dprop3= dprop3+p2_55_3_2 if (p2_51_3>=2 & p2_51_3~=. & p2_55_3_2>0 & p2_55_3_2~=.)
replace dprop3= dprop3+p2_55_3_3 if (p2_51_3>=3 & p2_51_3~=. & p2_55_3_3>0 & p2_55_3_3~=.)

*PARA EL RESTO DE PROPIEDADES INMOBILIARIAS CUANDO HAY MAS DE TRES;
*FOR THE REST OF REAL ESTATE PROPERTIES WHEN THESE ARE MORE THAN THREE;
gen dprop4=0
replace dprop4= dprop4+p2_55_4 if (p2_55_4>0 & p2_55_4~=.)

*CONSIDERANDO CONJUNTAMENTE TODAS LAS PROPIEDADES INMOBILIARIAS DIFERENTES DE LA VIVIENDA PRINCIPAL;
*CONSIDERING ALL REAL ESTATE PROPERTIES DIFFERENT FROM THE MAIN RESIDENCE;

gen deuoprop= dprop1+ dprop2+ dprop3+ dprop4 
*DEUDAS PENDIENTES DE PRESTAMOS SOLICITADOS PARA LA ADQUISICION DE LA VIVIENDA PRINCIPAL CON GARANTIA HIPOTECARIA;
*OUTSTANDING DEBTS FROM LOANS WITH MORTGAGE GUARANTEE USED FOR THE PURCHASE OF THE MAIN RESIDENCE;
*Para calcular la proporción de hogares que tienen deudas pendientes de préstamos CON garantía hipotecaria solicitados para la adquisición de la vivienda principal, generamos una nueva variable;
*To obtain the percentage of households that have outstanding debts from loans with mortgage guarantee used for the purchase of the main residence, we generate a new variable;

gen dpdtehipo = (p2_9_1==1|p2_9_2==1|p2_9_3==1|p2_9_4==1)

*Para calcular el valor de las deudas pendientes de préstamos CON garantía hipotecaria solicitados para la adquisición de la vivienda principal, generamos una nueva variable;
*To obtain the value of the outstanding debts from loans with mortgage guarantee used for the purchase of the main residence, we generate a new variable;

gen deuhipv =0
replace deuhipv= deuhipv +p2_12_1 if (p2_8a>=1 & p2_8a~=. & p2_9_1==1 & p2_12_1>0 & p2_12_1~=.)
replace deuhipv= deuhipv +p2_12_2 if (p2_8a>=2 & p2_8a~=. & p2_9_2==1 & p2_12_2>0 & p2_12_2~=.)
replace deuhipv= deuhipv +p2_12_3 if (p2_8a>=3 & p2_8a~=. & p2_9_3==1 & p2_12_3>0 & p2_12_3~=.)
replace deuhipv= deuhipv +p2_12_4 if (p2_8a>3   & p2_8a~=. & p2_9_4==1 & p2_12_4>0 & p2_12_4~=.)

*OTRAS DEUDAS PENDIENTES NO ASOCIADAS A LA ADQUISICION DE ACTIVOS INMOBILIARIOS;
*OTHER OUTSTANDING DEBT NOT RELATED TO THE PURCHASE OF REAL ESTATE ASSETS;

*DEUDAS PENDIENTES DE PRESTAMOS HIPOTECARIOS Y OTROS PRESTAMOS CON GARANTIA REAL;
*OUTSTANDING DEBTS FROM MORTGAGES AND OTHER SECURED LOANS);
*Para calcular la proporción de hogares que tienen deudas pendientes por prestamos hipotecarios y otros préstamos con garantía real generamos una nueva variable;
*To obtain the percentage of households that have outstanding debts from mortgages and other secured loans we generate a new variable;

gen hipo=(p3_2_1==1| p3_2_2==1| p3_2_3==1| p3_2_4==1|p3_2_5==1| p3_2_6==1| p3_2_7==1| p3_2_8==1| ///
p3_2_1==2| p3_2_2==2| p3_2_3==2| p3_2_4==2|p3_2_4==2|p3_2_5==2| p3_2_6==2| p3_2_7==2| p3_2_8==2| ///
p3_2_1==10| p3_2_2==10| p3_2_3==10| p3_2_4==10|p3_2_5==10| p3_2_6==10| p3_2_7==10| p3_2_8==10)

*Para calcular el valor de las deudas pendientes por prestamos hipotecarios y otros préstamos con garantía real generamos una nueva variable;
*To obtain the value of the outstanding debts from mortgages and other loans with real guarantee we generate a new variable;

gen phipo=0
replace phipo = phipo +p3_6_1 if ((p3_2_1==1|p3_2_1==2|p3_2_1==10) & p3_6_1>0 & p3_6_1~=.)
replace phipo = phipo +p3_6_2 if ((p3_2_2==1|p3_2_2==2|p3_2_2==10) & p3_6_2>0 & p3_6_2~=.)
replace phipo = phipo +p3_6_3 if ((p3_2_3==1|p3_2_3==2|p3_2_3==10) & p3_6_3>0 & p3_6_3~=.)
replace phipo = phipo +p3_6_4 if ((p3_2_4==1|p3_2_4==2|p3_2_4==10) & p3_6_4>0 & p3_6_4~=.)
replace phipo = phipo +p3_6_5 if ((p3_2_5==1|p3_2_5==2|p3_2_5==10) & p3_6_5>0 & p3_6_5~=.)
replace phipo = phipo +p3_6_6 if ((p3_2_6==1|p3_2_6==2|p3_2_6==10) & p3_6_6>0 & p3_6_6~=.)
replace phipo = phipo +p3_6_7 if ((p3_2_7==1|p3_2_7==2|p3_2_7==10) & p3_6_7>0 & p3_6_7~=.)
replace phipo = phipo +p3_6_8 if ((p3_2_8==1|p3_2_8==2|p3_2_8==10) & p3_6_8>0 & p3_6_8~=.)

*DEUDAS PENDIENTES DE PRESTAMOS PERSONALES;
*OUTSTANDING DEBTS FROM PERSONAL LOANS;
*Para calcular la proporción de hogares que tienen deudas pendientes por prestamos personales generamos una nueva variable;
*To obtain the percentage of households that have outstanding debts from personal loans we generate a new variable;

gen perso=(p3_2_1==3| p3_2_2==3| p3_2_3==3| p3_2_4==3|p3_2_5==3| p3_2_6==3| p3_2_7==3| p3_2_8==3)

*Para calcular el valor de las deudas pendientes por prestamos personales generamos una nueva variable;
*To obtain the value of the outstanding debts from personal loans we generate a new variable;

gen pperso=0
replace pperso = pperso +p3_6_1 if (p3_2_1==3 & p3_6_1>0 & p3_6_1~=.)
replace pperso = pperso +p3_6_2 if (p3_2_2==3 & p3_6_2>0 & p3_6_2~=.)
replace pperso = pperso +p3_6_3 if (p3_2_3==3 & p3_6_3>0 & p3_6_3~=.)
replace pperso = pperso +p3_6_4 if (p3_2_4==3 & p3_6_4>0 & p3_6_4~=.)
replace pperso = pperso +p3_6_5 if (p3_2_5==3 & p3_6_5>0 & p3_6_5~=.)
replace pperso = pperso +p3_6_6 if (p3_2_6==3 & p3_6_6>0 & p3_6_6~=.)
replace pperso = pperso +p3_6_7 if (p3_2_7==3 & p3_6_7>0 & p3_6_7~=.)
replace pperso = pperso +p3_6_8 if (p3_2_8==3 & p3_6_8>0 & p3_6_8~=.)

*DEUDAS PENDIENTES CON TARJETAS DE CREDITO;
*OUTSTANDING CREDIT CARD BALANCES;
*Para calcular la proporción de hogares que tienen deudas pendientes con tarjetas de credito generamos una nueva variable;
*To obtain the percentage of households that have outstanding credit card balances we generate a new variable;

gen deuda_tarj=(p8_5a>0 & p8_5a~=.)

*Para calcular el valor de las deudas pendientes con tarjetas de credito generamos una nueva variable;
*To obtain the value of outstanding credit card balances we generate a new variable;

gen ptmos_tarj=0
replace ptmos_tarj= p8_5a if (p8_5a>0 & p8_5a~=.)






*OTRAS DEUDAS;
*OTHER DEBTS;
*Para calcular la proporción de hogares que tienen otras deudas pendientes generamos una nueva variable;
*To obtain the percentage of households that have other outstanding debts we generate a new variable;

gen otrasd=(p3_2_1==4| p3_2_2==4| p3_2_3==4| p3_2_4==4| p3_2_5==4| p3_2_6==4| p3_2_7==4| p3_2_8==4|p3_2_1==5| p3_2_2==5| p3_2_3==5| p3_2_4==5| p3_2_5==5| p3_2_6==5| p3_2_7==5| p3_2_8==5| p3_2_1==6| p3_2_2==6| p3_2_3==6| p3_2_4==6| p3_2_5==6| p3_2_6==6| p3_2_7==6| p3_2_8==6| p3_2_1==7| p3_2_2==7| p3_2_3==7| p3_2_4==7| p3_2_5==7| p3_2_6==7| p3_2_7==7| p3_2_8==7| p3_2_1==8| p3_2_2==8| p3_2_3==8| p3_2_4==8| p3_2_5==8| p3_2_6==8| p3_2_7==8| p3_2_8==8| p3_2_1==9| p3_2_2==9| p3_2_3==9| p3_2_4==9| p3_2_5==9| p3_2_6==9| p3_2_7==9| p3_2_8==9| p3_2_1==97| p3_2_2==97| p3_2_3==97| p3_2_4==97 | p3_2_5==97| p3_2_6==97| p3_2_7==97| p3_2_8==97)

*Para calcular el valor de las otras deudas pendientes generamos una nueva variable;
*To obtain the value of the other outstanding debts we generate a new variable;

gen potrasd =0
replace potrasd = potrasd +p3_6_1 if ((p3_2_1==4| p3_2_1==5| p3_2_1==6| p3_2_1==7| p3_2_1==8|p3_2_1==9|p3_2_1==97) & p3_6_1>0 & p3_6_1~=.)
replace potrasd = potrasd +p3_6_2 if ((p3_2_2==4| p3_2_2==5|  p3_2_2==6| p3_2_2==7| p3_2_2==8|p3_2_2==9|p3_2_2==97) & p3_6_2>0 & p3_6_2~=.)
replace potrasd = potrasd +p3_6_3 if ((p3_2_3==4| p3_2_3==5| p3_2_3==6| p3_2_3==7| p3_2_3==8|p3_2_3==9|p3_2_3==97) & p3_6_3>0 & p3_6_3~=.)
replace potrasd = potrasd +p3_6_4 if ((p3_2_4==4| p3_2_4==5| p3_2_4==6| p3_2_4==7| p3_2_4==8|p3_2_4==9|p3_2_4==97) & p3_6_4>0 & p3_6_4~=.)
replace potrasd = potrasd +p3_6_5 if ((p3_2_5==4| p3_2_5==5| p3_2_5==6| p3_2_5==7| p3_2_5==8|p3_2_5==9|p3_2_5==97) & p3_6_5>0 & p3_6_5~=.)
replace potrasd = potrasd +p3_6_6 if ((p3_2_6==4| p3_2_6==5| p3_2_6==6| p3_2_6==7| p3_2_6==8|p3_2_6==9|p3_2_6==97) & p3_6_6>0 & p3_6_6~=.)
replace potrasd = potrasd +p3_6_7 if ((p3_2_7==4| p3_2_7==5| p3_2_7==6| p3_2_7==7| p3_2_7==8|p3_2_7==9|p3_2_7==97) & p3_6_7>0 & p3_6_7~=.)
replace potrasd = potrasd +p3_6_8 if ((p3_2_8==4| p3_2_8==5| p3_2_8==6| p3_2_8==7| p3_2_8==8|p3_2_8==9|p3_2_8==97) & p3_6_8>0 & p3_6_8~=.)

*ALGUN TIPO DE DEUDA PENDIENTE;
*SOME TYPE OF OUTSTANDING DEBT;
*Para calcular la proporción de hogares que tienen algún tipo de deuda pendiente generamos una nueva variable;
*To obtain the percentage of households that have some type of outstanding debt we generate a new variable;

gen adeuda= (p2_8==1|dpdte==1|p3_1>0|deuda_tarj==1)

*Para calcular el valor de las deudas pendientes generamos una nueva variable;
*To obtain the value of the outstanding debt we generate a new variable;

gen vdeuda= dvivpral + deuoprop+ phipo+ pperso+ potrasd + ptmos_tarj

*VARIABLES DE RIQUEZA TOTAL Y RIQUEZAS INTERMEDIAS;
*TOTAL AND INTERMEDIATE WEALTH VARIABLES;

*ACTIVOS REALES;
*REAL ASSETS;

gen actreales=0
replace actreales=actreales+np2_5 if (np2_5>0 & np2_5~=.)
replace actreales=actreales+otraspr if (otraspr>0 & otraspr~=.)
replace actreales=actreales+p2_84 if (p2_84>0 & p2_84~=.)
replace actreales=actreales+valhog if (valhog>0 & valhog~=.)

*ACTIVOS FINANCIEROS;
*FINANCIAL ASSETS;

gen actfinanc=0
replace actfinanc=actfinanc+p4_7_3 if (p4_7_3>0 & p4_7_3~=.)
replace actfinanc=actfinanc+p4_15 if (p4_15>0 & p4_15~=.)
replace actfinanc=actfinanc+p4_24 if (p4_24>0 & p4_24~=.)
replace actfinanc=actfinanc+p4_35 if (p4_35>0 & p4_35~=.)
replace actfinanc=actfinanc+allf if (allf>0 & allf~=.)
replace actfinanc=actfinanc+p4_43 if (p4_43>0 & p4_43~=.)
replace actfinanc=actfinanc+salcuentas if (salcuentas>0 & salcuentas~=.)
replace actfinanc=actfinanc+valor if (valor>0 & valor~=.)
replace actfinanc=actfinanc+valseg if (valseg>0 & valseg~=.)
replace actfinanc=actfinanc+odeuhog if (odeuhog>0 & odeuhog~=.)



** Liquidity

g actliq=0
replace actliq=actliq+p4_7_3 if (p4_7_3>0 & p4_7_3~=.)
replace actliq=actliq+p4_15 if (p4_15>0 & p4_15~=.)
replace actliq=actliq+p4_35 if (p4_35>0 & p4_35~=.)
replace actliq=actliq+allf if (allf>0 & allf~=.)


*RIQUEZA BRUTA;
*GROSS WEALTH;

gen riquezabr=0
replace riquezabr=riquezabr+actreales+actfinanc

*RIQUEZA NETA=RIQUEZA BRUTA-DEUDAS;
*NET WEALTH=GROSS WEALTH-DEBTS;

gen riquezanet=riquezabr-vdeuda


