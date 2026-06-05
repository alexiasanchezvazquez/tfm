
*********************************************************************************************************************
*****************************ESTIMATION WEALTH 2002 **********************************************
*********************************************************************************************************************



*1.- PARA LA PROPORCION DE HOGARES QUE POSEEN EL ACTIVO;
*1.- FOR THE PERCENTAGE OF HOUSEHOLDS OWNING THAT ASSET;

*ACTIVOS REALES;
*REAL ASSETS;

*VIVIENDA PRINCIPAL;
*MAIN RESIDENCE;
*Para calcular la proporción de hogares que poseen la vivienda principal utilizamos la variable p2_1;
*To calculate the percentage of households that own their main residence we use the variable p2_1;

*OTRAS PROPIEDADES INMOBILIARIAS;
*OTHER REAL ESTATE PROPERTIES;
*Para calcular la proporción de hogares que poseen otras propiedades inmobiliarias utilizamos la variable p2_32;
*To calculate the percentage of households that own other real estate properties we use the variable p2_32; 

*JOYAS, OBRAS DE ARTE, ANTIGUEDADES;
*JEWELLERY, WORKS OF ART, ANTIQUES;
*Para calcular la proporción de hogares que poseen joyas, obras de arte, antigüedades utilizamos la variable p2_82;
*To calculate the percentage of households that own jewellery, works of art and antiques we use the variable p2_82;

*VALOR DEL NEGOCIO POR TRABAJOS POR CUENTA PROPIA;
*VALUE OF BUSINESSES RELATED TO SELF-EMPLOYMENT;
gen haveneg=(p6_1c2_1==1|p6_1c2_2==1|p6_1c2_3==1|p6_1c2_4==1|p6_1c2_5==1|p6_1c2_6==1)


*PRIMERO;
*CALCULAR PARA CADA TRABAJO POR CTA PROPIA DE CADA MIEMBRO LOS VALORES DE 
* (i)INMUEBLES Y EDIFICIOS,DESCONTANDO EL VALOR DE LOS ACTIVOS YA DECLARADOS COMO PROPIEDADES INMOBILIARIAS

 * (ii)NEGOCIO INCLUIDO MAQUINARIA Y VEHICULOS. (AQUI NO SE DESCUENTAN VEHICULOS YA INCLUIDOS PORQUE NO SE CONSIDERAN VEHICULOS EN RIQUEZA SI NO QUE FORMAN PARTE DE NEGOCIO);

*LUEGO SE SUMA ESTOS DOS CONCEPTOS DE VALOR NETOS;
*LUEGO A ESA SUMA SE LE APLICA EL COEFICIENTE DEL PORCENTAJE QUE PERTENECE AL MIEMBRO (PARA PROFESIONALES, PROP.UNICOS, AUTONOMOS -opcion 1 en las p6_37- SE SUPONE QUE ES 1);

*FIRST;
*DETERMINE FOR EACH SELF-EMPLOYMENT JOB OF EACH MEMBER THE VALUES OF
* (i)REAL ESTATE PROPERTIES AND BUILDINGS, SUBSTRACTING THE VALUE OF THE ASSETS ALREADY DECLARED AS REAL ESTATE PROPERTIES
* (ii)BUSINESS INCLUDING MACHINERY AND VEHICLES. (HERE WE DO NOT SUBSTRACT VEHICLES ALREADY INCLUDED BECAUSE VEHICLES ARE NOT CONSIDERED WEALTH IF THEY ARE NOT PART OF A BUSINESS);  
 
*THEN BOTH NET VALUES ARE ADDED;
*THEN TO THAT RESULT WE APPLY THE COEFFICIENT OF THE PERCENTAGE THAT BELONGS TO THE MEMBER (FOR INDEPENDENT PROFESSIONALS, SOLE PROPRIETORS, SELF-EMPLOYED.-option 1 in p6_37- 1 is assumed);

set more off
forvalues m=1/6{
	forvalues j=1/3{
	display _newline(1) `m' `j'
	gen valter_`m'_`j'=0
	gen valneg_`m'_`j'=0

	
	gen indter_`m'_`j'=(p6_391_`m'_`j'==1)
	gen indc1_`m'_`j'=(p6_392c1_`m'_`j'==1)
	gen indc2_`m'_`j'=(p6_392c2_`m'_`j'==1)
	gen indc3_`m'_`j'=(p6_392c3_`m'_`j'==1)
	gen indc4_`m'_`j'=(p6_392c4_`m'_`j'==1)
	gen indc5_`m'_`j'=(p6_392c5_`m'_`j'==1)
	
	
	
	replace valter_`m'_`j'=p6_39_`m'_`j' if (p6_39_`m'_`j'>0 & p6_39_`m'_`j'~=.)
	replace valter_`m'_`j'=valter_`m'_`j'- p2_5*(indter_`m'_`j')*(indc1_`m'_`j') if (p2_5>0 & p2_5~=.)
		

	replace valter_`m'_`j'=valter_`m'_`j'- p2_39_1*(indter_`m'_`j')*(indc2_`m'_`j') if (p2_39_1>0 & p2_39_1~=.)
	replace valter_`m'_`j'=valter_`m'_`j'- p2_39_2*(indter_`m'_`j')*(indc3_`m'_`j') if (p2_39_2>0 & p2_39_2~=.)
	replace valter_`m'_`j'=valter_`m'_`j'- p2_39_3*(indter_`m'_`j')*(indc4_`m'_`j') if (p2_39_3>0 & p2_39_3~=.)
	replace valter_`m'_`j'=valter_`m'_`j'- p2_39_4*(indter_`m'_`j')*(indc5_`m'_`j') if (p2_39_4>0 & p2_39_4~=.)

	display _newline(1)

	replace valter_`m'_`j'=0 if valter_`m'_`j'<0


	display _newline(1)
	
	replace valneg_`m'_`j'=p6_40_`m'_`j' if (p6_40_`m'_`j'>0 & p6_40_`m'_`j'~=.)
      
	display _newline(1)
	gen coef_`m'_`j'=1
	replace coef_`m'_`j'=(p6_3824_`m'_`j')/100 if (p6_3824_`m'_`j'>0 & p6_3824_`m'_`j'~=. & p6_37_`m'_`j'==2)

	replace coef_`m'_`j'=(p6_3832_`m'_`j')/100 if (p6_3832_`m'_`j'>0 & p6_3832_`m'_`j'~=. & p6_37_`m'_`j'==3)
	gen valind_`m'_`j'=(valter_`m'_`j'+valneg_`m'_`j')*coef_`m'_`j'
	
	}

	}


*SEGUNDO;
*PARA NO REPETIR VALORES DE UN MISMO NEGOCIO EN QUE TRABAJAN VARIOS MIEMBROS DEL HOGAR:
* (i) PARA MIEMBROS EMPRESA FAMILIAR O NO FAMILIAR.
 *    (-opciones 2 o 3 en la p6_37)  COMO SE LES APLICA EL COEFICIENTE INDIDUAL,  SE SUMA Y NO SE DUPLICA 
 *(ii)PARA PROFESIONALES, AUTONOMOS (opcion 1 en p6_37) SE HACE LO SIGUIENTE
*	(a) SE SUMA SIEMPRE QUE DIGA QUE SOLO EL TRABAJA EN ESE NEGOCIO (P6_35==1)
*	(b) PARA P6_35>1
		*SE SUMA SIEMPRE SI ES LA PERSONA DE REFERENCIA;
		*SI ES 2º MIEMBRO SOLO SE SUMA 
 *            SI NO HAY NINGUN TRABAJO COMO CTA PROPIA
*		 DE LA PERSONA DE REFERENCIA EN QUE P6_35>1
		*SI ES 3er MIEMBRO SOLO SE SUMA 
 *            SI NO HAY NINGUN TRABAJO COMO CTA PROPIA

*		 DE LA PERSONA DE REFERENCIA EN QUE P6_35>1 
 *            NI NINGUN TRABAJO COMO CTA PROPIA
*		 DEL 2º MIEMBRO EN QUE P6_35>1
		*Y ASI SUCESIVAMENTE PARA EL RESTO DE MIEMBROS;

*SECOND;
*TO AVOID DOUBLE COUNTING OF THE SAME BUSINESS IN WHICH SEVERAL HOUSEHOLD MEMBERS ARE WORKING:
 *(i) FOR MEMBERS OR PARTNERS OF A FAMILY OR NON-FAMILY FIRM.
  *   (-options 2 or 3 in p6_37)  SINCE INDIVIDUAL COEFFICIENTS ARE APPLIED, NO DOUBLE COUNTING
 *(ii)FOR PROFESSIONALS, SELF-EMPLOYED (OPTION 1 IN P6_37):
*(a)	ADDED WHENEVER THE HOUSEHOLD MEMBER IS THE ONLY ONE WORKING IN THAT BUSINESS (P6_35==1)
*(b)	FOR P6_35>1
*IT IS ALWAYS ADDED IF THE HOUSEHOLD MEMBER IS THE REFERENCE PERSON;
*IF THE HOUSEHOLD MEMBER IS THE SECOND MEMBER IT IS ONLY ADDED IF THERE IS NO SELF-EMPLOYMENT JOB OF THE REFERENCE PERSON IN WHICH P6_35>1;
*IF THE HOUSEHOLD MEMBER IS THE THIRD MEMBER IT IS ONLY ADDED IF THERE IS NO SELF-EMPLOYMENT JOB OF THE REFERENCE PERSON IN WHICH P6_35>1 NOR ANY SELF-EMPLOYMENT JOB OF THE SECOND MEMBER IN WHICH P6_35>1;
*THE SAME PROCEDURE APPLIES FOR THE REST OF THE HOUSEHOLD MEMBERS; 


gen valhog=0

gen noinsum2=(p6_35_1_1>1 & p6_35_1_1~=. & p6_37_1_1==1| p6_35_1_2>1 & p6_35_1_2~=. & p6_37_1_2==1| p6_35_1_3>1 & p6_35_1_3~=. & p6_37_1_3==1)
gen noinsum3=(noinsum2==1| p6_35_2_1>1 & p6_35_2_1~=. & p6_37_2_1==1| ///
		  p6_35_2_2>1 & p6_35_2_2~=. & p6_37_2_2==1| ///
		  p6_35_2_3>1 & p6_35_2_3~=. & p6_37_2_3==1) 
gen noinsum4=(noinsum3==1| ///
		  p6_35_3_1>1 & p6_35_3_1~=. & p6_37_3_1==1| ///
		  p6_35_3_2>1 & p6_35_3_2~=. & p6_37_3_2==1| ///
		  p6_35_3_3>1 & p6_35_3_3~=. & p6_37_3_3==1) 
gen noinsum5=(noinsum4==1| ///
		  p6_35_4_1>1 & p6_35_4_1~=. & p6_37_4_1==1| ///
		  p6_35_4_2>1 & p6_35_4_2~=. & p6_37_4_2==1| ///
		  p6_35_4_3>1 & p6_35_4_3~=. & p6_37_4_3==1)
gen noinsum6=(noinsum5==1| ///
		  p6_35_5_1>1 & p6_35_5_1~=. & p6_37_5_1==1| /// 
		  p6_35_5_2>1 & p6_35_5_2~=. & p6_37_5_2==1| ///
		  p6_35_5_3>1 & p6_35_5_3~=. & p6_37_5_3==1)
	

	
	
forvalues m=1/6{
	forvalues j=1/3{
	replace valhog=valhog+valind_`m'_`j' if ((valind_`m'_`j'>0 & valind_`m'_`j'~=.) & (p6_37_`m'_`j'==2|p6_37_`m'_`j'==3| p6_37_`m'_`j'==1 & p6_35_`m'_`j'==1| p6_37_`m'_`j'==1 & p6_35_`m'_`j'>1 & p6_35_`m'_`j'~=. & `m'==1| p6_37_`m'_`j'==1 & p6_35_`m'_`j'>1 & p6_35_`m'_`j'~=. & `m'==2 & noinsum2==0|  p6_37_`m'_`j'==1 & p6_35_`m'_`j'>1 & p6_35_`m'_`j'~=. & `m'==3 & noinsum3==0|  p6_37_`m'_`j'==1 & p6_35_`m'_`j'>1 & p6_35_`m'_`j'~=. & `m'==4 & noinsum4==0| p6_37_`m'_`j'==1 & p6_35_`m'_`j'>1 & p6_35_`m'_`j'~=. & `m'==5 & noinsum5==0| p6_37_`m'_`j'==1 & p6_35_`m'_`j'>1 & p6_35_`m'_`j'~=. & `m'==6 & noinsum6==0))
	
	}

	}


	

*Para calcular las proporciones de hogares con algo de cuenta propia generamos una nueva variable que tiene en cuenta que se declare un valor positivo para el negocio;
*To calculate the percentages of households with some business we generate a new variable that takes into account that a positive value is held for the business; 

gen havenegval =(haveneg==1 & valhog>0)

 

*ALGUN TIPO DE ACTIVO REAL;
*SOME KIND OF REAL ASSET;

gen  tienereal=(p2_1==2|p2_32==1|p2_82==1| havenegval==1)


*ACTIVOS FINANCIEROS;
*FINANCIAL ASSETS;

*CUENTAS Y DEPOSITOS UTILIZABLES PARA REALIZAR PAGOS;
*Para calcular la proporción de hogares que poseen cuentas y depósitos para realizar pagos y que declaran un valor estrictamente positivo para el saldo de estas cuentas generamos una nueva variable;

*ACCOUNTS AND DEPOSITS USABLE FOR PAYMENTS;
*To calculate the percentage of households that own accounts and deposits usable for payments and that declare a strictly positive value for the balance of those accounts we generate a new variable;

gen np4_5=(p4_5==1 & p4_7_3>0 & p4_7_3~=.)

*ACCIONES COTIZADAS EN BOLSA;
*Para calcular la proporción de hogares que poseen acciones cotizadas utilizamos la variable p4_10;

*LISTED SHARES;
*To calculate the percentage of households that own listed shares we use the variable p4_10;

*ACCIONES NO COTIZADAS EN BOLSA Y PARTICIPACIONES;
*Para calcular la proporción de hogares que poseen acciones no cotizadas y participaciones y que declaran un valor estrictamente positivo para dicha cartera generamos una nueva variable;

*UNLISTED SHARES AND OTHER EQUITY;
*To calculate the percentage of households that own unlisted shares and other equity and that declare a strictly positive value for that portfolio we generate a new variable;

gen np4_18=(p4_18==1 & p4_24>0 & p4_24~=.)

*VALORES DE RENTA FIJA;
*Para calcular la proporción de hogares que poseen valores de renta fija utilizamos la variable p4_33;

*FIXED-INCOME SECURITIES;
*To calculate the percentage of households that own fixed-income securities we use the variable p4_33;

*FONDOS DE INVERSION;
*Para calcular la proporción de hogares que poseen fondos de inversion utilizamos la variable p4_27;

*MUTUAL FUNDS;
*To calculate the percentage of households that own mutual funds we use the variable p4_27;

*CUENTAS VIVIENDA Y CUENTAS NO UTILIZABLES PARA REALIZAR PAGOS;
*Para calcular la proporción de hogares que poseen cuentas y depósitos no utilizables para realizar pagos generamos una nueva variable cuentas;

*HOUSE-PURCHASE SAVINGS ACCOUNTS AND ACCOUNTS NOT USABLE FOR PAYMENTS;
*To calculate the percentage of households that own accounts and deposits not usable for payments we generate a new variable cuentas;

gen cuentas=(p4_3==1|p4_4==1)

*PLANES DE PENSIONES;

*Para calcular la proporción de hogares que poseen planes de pensiones utilizamos la variable p5_1;

*PENSION SCHEMES;
*To calculate the percentage of households that own pension schemes we use the variable p5_1;


*SEGUROS DE VIDA;
*Para calcular la proporción de hogares que tienen seguros tipo unit linked o mixto generamos una nueva variable;

*To calculate the percentage of households that own unit-linked or mixed life insurance we generate a new variable;

gen seguro=(p5_13_1==2| p5_13_2==2| p5_13_3==2| p5_13_4==2| p5_13_5==2| p5_13_6==2| p5_13_1==3| p5_13_2==3| p5_13_3==3| p5_13_4==3| p5_13_5==3| p5_13_6==3)

*PLANES DE PENSIONES INCLUYENDO SEGUROS DE VIDA DE INVERSION O MIXTOS;
*PENSION SCHEMES INCLUDING UNIT-LINKED OR MIXED LIFE INSURANCE;

gen penseg=(p5_1==1|seguro==1)

*OTROS ACTIVOS FINANCIEROS;
*OTHER FINANCIAL ASSETS; 

*Para calcular la proporción de hogares a los que les debe dinero o bien el negocio u otras personas generamos una nueva variable sideuda;
*To calculate the percentage of households to whom the business or other people owe money we generate the variable sideuda; 


*PROGRAMA PARA CALCULAR LO QUE LES DEBEN LOS NEGOCIOS A LOS DISTINTOS MIEMBROS DEL HOGAR (P6_44);
*PROGRAM TO OBTAIN WHAT THE BUSINESSES OWE TO THE DIFFERENT HOUSEHOLD MEMBERS (P6_44);

gen valdeuhog=0
gen havedeuhog=0

forvalues m=1/6   {

	forvalues j=1/3 {

	display _newline(1) `m' `j'
	

	replace valdeuhog=valdeuhog+p6_44_`m'_`j' if (p6_44_`m'_`j'>0 & p6_44_`m'_`j'~=.)

	replace havedeuhog=1 if (p6_43_`m'_`j'==1)


	}

}
	
gen sideuda=((havedeuhog ==1 & valdeuhog>0)|(p4_37==1 & p4_38>0 & p4_38~=.))


*ALGUN TIPO DE ACTIVO FINANCIERO;
*SOME TYPE OF FINANCIAL ASSET;

gen tienefin=(np4_5==1|p4_10==1|np4_18==1|p4_33==1|p4_27==1|cuentas==1|p5_1==1|seguro==1|sideuda==1)

*ALGUN TIPO DE ACTIVO;
*SOME TYPE OF ASSET;

gen tiene=(tienereal==1|tienefin==1)


*2.- PARA EL VALOR DE DICHOS ACTIVOS;
*2.- FOR THE VALUE OF THOSE ASSETS;

*ACTIVOS REALES;
*REAL ASSETS;

*VIVIENDA PRINCIPAL;
*Para calcular el valor de la vivienda principal utilizamos la variable p2_5;

*MAIN RESIDENCE;
*To obtain the value of the main residence we use the variable p2_5;

*OTRAS PROPIEDADES INMOBILIARIAS;
*Para calcular el valor de las otras propiedades inmobiliarias generamos una nueva variable;

*OTHER REAL ESTATE PROPERTIES;
*To obtain the value of the other real estate properties we generate a new variable;

gen otraspr=0
replace otraspr=otraspr+p2_39_1*(p2_37_1/100) if (p2_33>=1 & p2_33~=. & p2_39_1>=0 & p2_39_1~=. & p2_37_1>0 & p2_37_1~=.)
replace otraspr=otraspr+p2_39_2 *(p2_37_2/100) if (p2_33>=2 & p2_33~=. & p2_39_2>=0 & p2_39_2~=. & p2_37_2>0 & p2_37_2~=.)
replace otraspr=otraspr+p2_39_3* (p2_37_3/100) if (p2_33>=3 & p2_33~=. & p2_39_3>=0 & p2_39_3~=. & p2_37_3>0 & p2_37_3~=.)
replace otraspr=otraspr+p2_39_4 if (p2_33>3 & p2_33~=. & p2_39_4>=0 & p2_39_4~=.)

*JOYAS, OBRAS DE ARTE, ANTIGUEDADES;
*Para calcular el valor de las joyas, obras de arte, antigüedades utilizamos la variable p2_84;

*JEWELLERY, WORKS OF ART, ANTIQUES;
*To obtain the value of the jewellery, works of art and antiques we use the variable p2_84;

*VALOR DEL NEGOCIO POR TRABAJOS POR CUENTA PROPIA;
*la mediana del valor del negocio será la mediana de valhog if havenegval==1; 

*VALUE OF THE BUSINESS RELATED TO SELF-EMPLOYMENT;
*The median of the business value is equal to the median of valhog if havenegval==1;


*ACTIVOS FINANCIEROS;
*FINANCIAL ASSETS;

*CUENTAS Y DEPOSITOS UTILIZABLES PARA REALIZAR PAGOS;
*Para calcular el saldo de las cuentas y depósitos para realizar pagos utilizamos la variable p4_7_3;

*ACCOUNTS AND DEPOSITS USABLE FOR PAYMENTS;
*To obtain the balance of the accounts and deposits usable for payments we use the variable p4_7_3;

*ACCIONES COTIZADAS EN BOLSA;
*Para calcular el valor de las acciones cotizadas utilizamos la variable p4_15;

*LISTED SHARES;
*To obtain the value of the listed shares we use the variable p4_15;

*ACCIONES NO COTIZADAS EN BOLSA Y PARTICIPACIONES;
*Para calcular el valor de las acciones no cotizadas y participaciones utilizamos la variable p4_24;

*UNLISTED SHARES ANDOTHER EQUITY;
*To obtain the value of the unlisted shares and other equity we use the variable p4_24;

*VALORES DE RENTA FIJA;
*Para calcular el valor de los valores de renta fija utilizamos la variable p4_35;

*FIXED-INCOME SECURITIES;
*To obtain the value of the fixed-income securities we use the variable p4_35

*FONDOS DE INVERSION;
*Para calcular el valor total de los fondos de inversión utilizamos la variable allf calculada como (i) la suma de los valores de cada uno de los fondos de inversión que posee el hogar (p4_31_i; i=1,…,10) si el número de estos fondos es menor o igual a 10, y (ii) el valor total de los fondos de inversión del hogar si posee más de 10 fondos (p4_28a);

egen allf=rowtotal(p4_31_1 p4_31_2 p4_31_3 p4_31_4 p4_31_5 p4_31_6 p4_31_7 p4_31_8 p4_31_9 p4_31_10) if p4_28<11
replace allf = p4_28a if p4_28>10
replace allf = 0 if allf==.


*MUTUAL FUNDS;
*To obtain the total value of mutual funds we use the variable allf calculated as (i) the addition of the values of each mutual fund that the household owns (p4_31_i; i=1,…,10) if the number of these funds is 10 or less, and (ii) the household mutual funds’ total value if this one owns more than 10 (p4_28a);

*CUENTAS VIVIENDA Y CUENTAS NO UTILIZABLES PARA REALIZAR PAGOS;
*Para calcular el saldo de las cuentas y depósitos no utilizables para realizar pagos generamos una nueva variable;

*HOME-PURCHASE SAVINGS ACCOUNTS AND ACCOUNTS NOT USABLE FOR PAYMENTS;
*To obtain the balance of the accounts and deposits not usable for payments we generate a new variable;  

gen salcuentas=0
replace salcuentas = salcuentas +p4_7_1 if (p4_3==1 & p4_7_1>=0 & p4_7_1~=. )
replace salcuentas = salcuentas + p4_7_2 if (p4_4==1 & p4_7_2>=0 & p4_7_2~=.)

*PLANES DE PENSIONES;
*Para calcular valor actualizado de los planes de pensiones generamos una nueva variable;

*PENSION SCHEMES;
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

*No consideramos las mutualidades (2.51% de los planes de pensiones);

*We do not consider mutual insurance (2.51% of pension schemes);

*SEGUROS DE VIDA;
*Para calcular el valor de estos seguros tipo unit linked o mixto generamos una nueva variable;

*LIFE INSURANCE;
*To obtain the value of the unit-linked or mixed life insurance we generate a new variable;


gen valseg=0

replace valseg = valseg +p5_14_1 if ((p5_13_1==2| p5_13_1==3) & p5_14_1>0 & p5_14_1~=.)
replace valseg = valseg +p5_14_2 if ((p5_13_2==2| p5_13_2==3) & p5_14_2>0 & p5_14_2~=.)
replace valseg = valseg +p5_14_3 if ((p5_13_3==2| p5_13_3==3) & p5_14_3>0 & p5_14_3~=.)
replace valseg = valseg +p5_14_4 if ((p5_13_4==2| p5_13_4==3) & p5_14_4>0 & p5_14_4~=.)
replace valseg = valseg +p5_14_5 if ((p5_13_5==2| p5_13_5==3) & p5_14_5>0 & p5_14_5~=.)
replace valseg = valseg +p5_14_6 if ((p5_13_6==2| p5_13_6==3) & p5_14_6>0 & p5_14_6~=.)

*PLANES DE PENSIONES INCLUYENDO SEGUROS DE VIDA DE INVERSION O MIXTOS;
*PENSION SCHEMES INCLUDING UNIT-LINKED OR MIXED LIFE INSURANCE;

gen valpenseg=valor+valseg

*OTROS ACTIVOS FINANCIEROS;
*Para calcular el valor de la mediana de lo que se debe al hogar, utilizamos las variables valdeuhog y p4_38 y generamos una nueva variable;

*OTHER FINANCIAL ASSETS;
*To obtain the median of how much is owed to the household, we use the variables valdeuhog and p4_38 and generate a new variable; 

gen odeuhog=0

replace odeuhog = odeuhog +valdeuhog if (valdeuhog>0)
replace odeuhog = odeuhog +p4_38 if (p4_38>0 & p4_38~=.)

*CUADRO 7: PROPORCION DE HOGARES Y MEDIANA DEL VALOR DE LOS DISTINTOS TIPOS DE DEUDA PENDIENTES;
*TABLE 7: PERCENTAGE OF HOUSEHOLDS AND VALUE’S MEDIAN OF THE DIFFERENT TYPES OF OUTSTANDING DEBT;

*DEUDAS  CLASIFICADAS POR TIPO DE ACTIVO INMOBILIARIO (TODO TIPO DE PRESTAMOS);
*DEBT CLASSIFIED BY TYPE OF REAL ESTATE ASSET (ALL KIND OF LOANS);

*VIVIENDA PRINCIPAL;

*Para calcular la proporción de hogares que tienen deudas pendientes de préstamos solicitados para la adquisición de la vivienda principal utilizamos p2_8;

*MAIN RESIDENCE;
*To obtain the percentage of households that have outstanding debt from loans used to purchase their main residence, we use p2_8;

*Para calcular el valor de las deudas pendientes de préstamos solicitados para la adquisición de la vivienda principal, generamos una nueva variable;
*To obtain the value of the outstanding debts from loans used to purchase their main residence, we generate a new variable;

gen dvivpral=0

replace dvivpral= dvivpral +p2_12_1 if  (p2_8a>=1 & p2_8a~=. & p2_12_1>0 & p2_12_1~=.)

replace dvivpral= dvivpral + p2_12_2 if (p2_8a>=2 & p2_8a~=. &  p2_12_2>0 & p2_12_2~=.)

replace dvivpral= dvivpral +p2_12_3  if (p2_8a>=3 & p2_8a~=. & p2_12_3>0 & p2_12_3~=.)

replace dvivpral= dvivpral +p2_12_4  if (p2_8a>3 & p2_8a~=. & p2_12_4>0 & p2_12_4~=.)


*OTRAS PROPIEDADES INMOBILIARIAS DIFERENTES DE LA VIVIENDA PRINCIPAL;
*OTHER REAL ESTATE PROPERTIES DIFFERENT FROM THE MAIN RESIDENCE;

*Para calcular la proporción de hogares que tienen deudas pendientes de préstamos solicitados para la adquisición de otras propiedades inmobiliarias diferentes de la vivienda principal, generamos una nueva variable;

*To obtain the percentage of households that have outstanding debts from loans used to purchase other real estate properties different from the main residence, we generate a new variable;

gen dpdte=(p2_50_1==1|p2_50_2==1|p2_50_3==1|p2_50_4==1)

*Para calcular el valor de las deudas pendientes de préstamos solicitados para la adquisición de otras propiedades inmobiliarias diferentes de la vivienda principal, generamos cuatro nuevas variable;

*To obtain the value of the outstanding debts from loans used to purchase other real estate properties different from the main residence, we generate four new variables;

*PARA LA PRIMERA PROPIEDAD INMOBILIARIA;
*FOR THE FIRST REAL ESTATE PROPERTY;

gen dprop1=0

replace dprop1= dprop1+p2_55_1_1 if (p2_51_1>=1 & p2_51_1~=.  &  p2_55_1_1>0 & p2_55_1_1~=.)

replace dprop1= dprop1+ p2_55_1_2 if (p2_51_1>=2 & p2_51_1~=.  & p2_55_1_2>0 & p2_55_1_2~=.)

replace dprop1= dprop1+p2_55_1_3  if (p2_51_1>=3 & p2_51_1~=.  & p2_55_1_3>0 & p2_55_1_3~=.)

*PARA LA SEGUNDA PROPIEDAD INMOBILIARIA;
*FOR THE SECOND REAL ESTATE PROPERTY;

gen dprop2=0

replace dprop2= dprop2+p2_55_2_1 if (p2_51_2>=1 & p2_51_2~=. & p2_55_2_1>0 & p2_55_2_1~=.)

replace dprop2= dprop2+ p2_55_2_2 if (p2_51_2>=2 & p2_51_2~=. & p2_55_2_2>0 & p2_55_2_2~=.)

replace dprop2= dprop2+ p2_55_2_3  if (p2_51_2>=3 & p2_51_2~=. & p2_55_2_3>0 & p2_55_2_3~=.)


*PARA LA TERCERA PROPIEDAD INMOBILIARIA;
*FOR THE THIRD REAL ESTATE PROPERTY;

gen dprop3=0

replace dprop3= dprop3+p2_55_3_1 if (p2_51_3>=1 & p2_51_3~=. & p2_55_3_1>0 & p2_55_3_1~=.)

replace dprop3= dprop3+ p2_55_3_2 if (p2_51_3>=2 & p2_51_3~=. & p2_55_3_2>0 & p2_55_3_2~=.)

replace dprop3= dprop3+ p2_55_3_3  if (p2_51_3>=3 & p2_51_3~=. & p2_55_3_3>0 & p2_55_3_3~=.)


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

replace deuhipv= deuhipv + p2_12_1 if (p2_8a>=1 & p2_8a~=. & p2_9_1==1 & p2_12_1>0 & p2_12_1~=.)

replace deuhipv = deuhipv + p2_12_2 if (p2_8a>=2 & p2_8a~=. & p2_9_2==1 &  p2_12_2>0 & p2_12_2~=.)

replace deuhipv= deuhipv +p2_12_3  if (p2_8a>=3 & p2_8a~=. & p2_9_3==1 &  p2_12_3>0 & p2_12_3~=.)

replace deuhipv= deuhipv +p2_12_4  if (p2_8a>3 & p2_8a~=. & p2_8a~=. & p2_9_4==1 &  p2_12_4>0 & p2_12_4~=.)


*OTRAS DEUDAS PENDIENTES NO ASOCIADAS A LA ADQUISICION DE ACTIVOS INMOBILIARIOS;
*OTHER OUTSTANDING DEBT NOT RELATED TO THE PURCHASE OF REAL ESTATE ASSETS;

*DEUDAS PENDIENTES DE PRESTAMOS HIPOTECARIOS Y OTROS PRESTAMOS CON GARANTIA REAL;
*OUTSTANDING DEBTS FROM MORTGAGES AND OTHER SECURED LOANS);

*Para calcular la proporción de hogares que tienen deudas pendientes por prestamos hipotecarios y otros préstamos con garantía real generamos una nueva variable;
*To obtain the percentage of households that have outstanding debts from mortgages and other secured loans we generate a new variable;

gen hipo=(p3_2_1==1| p3_2_2==1| p3_2_3==1| p3_2_4==1| p3_2_1==2| p3_2_2==2| p3_2_3==2| p3_2_4==2)

*Para calcular el valor de las deudas pendientes por prestamos hipotecarios y otros préstamos con garantía real generamos una nueva variable;
*To obtain the value of the outstanding debts from mortgages and other loans with real guarantee we generate a new variable;



gen phipo=0

replace phipo = phipo +p3_6_1 if ((p3_2_1==1|p3_2_1==2) & p3_6_1>0 & p3_6_1~=.)

replace phipo = phipo +p3_6_2 if ((p3_2_2==1| p3_2_2==2) & p3_6_2>0 & p3_6_2~=.)

replace phipo = phipo +p3_6_3 if ((p3_2_3==1| p3_2_3==2)  & p3_6_3>0 & p3_6_3~=.)

replace phipo = phipo +p3_6_4 if ((p3_2_4==1| p3_2_4==2) & p3_6_4>0 & p3_6_4~=.)


*DEUDAS PENDIENTES DE PRESTAMOS PERSONALES;
*OUTSTANDING DEBTS FROM PERSONAL LOANS;

*Para calcular la proporción de hogares que tienen deudas pendientes por prestamos personales generamos una nueva variable;
*To obtain the percentage of households that have outstanding debts from personal loans we generate a new variable;

gen perso=(p3_2_1==3| p3_2_2==3| p3_2_3==3| p3_2_4==3)

*Para calcular el valor de las deudas pendientes por prestamos personales generamos una nueva variable;
*To obtain the value of the outstanding debts from personal loans we generate a new variable;

gen pperso=0

replace pperso = pperso +p3_6_1 if (p3_2_1==3 & p3_6_1>0 & p3_6_1~=.)

replace pperso = pperso +p3_6_2 if (p3_2_2==3 & p3_6_2>0 & p3_6_2~=.)

replace pperso = pperso +p3_6_3 if (p3_2_3==3 & p3_6_3>0 & p3_6_3~=.)

replace pperso = pperso +p3_6_4 if (p3_2_4==3 & p3_6_4>0 & p3_6_4~=.)



*OTRAS DEUDAS PENDIENTES;
*OTHER OUTSTANDING DEBTS;

*Para calcular la proporción de hogares que tienen otras deudas pendientes generamos una nueva variable;
*To obtain the percentage of households that have other outstanding debts we generate a new variable;

gen otrasd=(p3_2_1==4| p3_2_2==4| p3_2_3==4| p3_2_4==4|p3_2_1==5| p3_2_2==5| p3_2_3==5| p3_2_4==5|p3_2_1==6| p3_2_2==6| p3_2_3==6| p3_2_4==6|p3_2_1==7| p3_2_2==7| p3_2_3==7| p3_2_4==7|p3_2_1==8| p3_2_2==8| p3_2_3==8| p3_2_4==8|p3_2_1==9| p3_2_2==9| p3_2_3==9| p3_2_4==9|p3_2_1==97| p3_2_2==97| p3_2_3==97| p3_2_4==97)


*Para calcular el valor de las otras deudas pendientes generamos una nueva variable;
*To obtain the value of the other outstanding debts we generate a new variable;


gen potrasd =0

replace potrasd = potrasd +p3_6_1 if ((p3_2_1==4| p3_2_1==5| p3_2_1==6| p3_2_1==7| p3_2_1==8|p3_2_1==9|p3_2_1==97) & p3_6_1>0 & p3_6_1~=.)

replace potrasd = potrasd +p3_6_2 if ((p3_2_2==4| p3_2_2==5|  p3_2_2==6| p3_2_2==7| p3_2_2==8|p3_2_2==9|p3_2_2==97) & p3_6_2>0 & p3_6_2~=.)

replace potrasd = potrasd +p3_6_3 if ((p3_2_3==4| p3_2_3==5| p3_2_3==6| p3_2_3==7| p3_2_3==8|p3_2_3==9|p3_2_3==97) & p3_6_3>0 & p3_6_3~=.)

replace potrasd = potrasd +p3_6_4 if ((p3_2_4==4| p3_2_4==5| p3_2_4==6| p3_2_4==7| p3_2_4==8|p3_2_4==9|p3_2_4==97) & p3_6_4>0 & p3_6_4~=.)



*ALGUN TIPO DE DEUDA PENDIENTE;
*SOME TYPE OF OUTSTANDING DEBT;

*Para calcular la proporción de hogares que tienen algun tipo de deuda pendiente generamos una nueva variable;
*To obtain the percentage of households that have some type of outstanding debt we generate a new variable;

gen adeuda= (p2_8==1| dpdte==1| p3_1>0)


*Para calcular el valor de las deudas pendientes generamos una nueva variable;
*To obtain the value of the outstanding debt we generate a new variable;


gen vdeuda= dvivpral + deuoprop+ phipo+ pperso+ potrasd


*VARIABLES DE RIQUEZA TOTAL Y RIQUEZAS INTERMEDIAS;
*TOTAL AND INTERMEDIATE WEALTH VARIABLES;


*ACTIVOS REALES;
*REAL ASSETS;

gen actreales=0
replace actreales=actreales+p2_5 if (p2_5>0 & p2_5~=.)
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
replace actfinanc=actfinanc+salcuentas
replace actfinanc=actfinanc+valor
replace actfinanc=actfinanc+valseg
replace actfinanc=actfinanc+odeuhog

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





*********************************************************************************************************************
*********************************************************************************************************************
*********************************************************************************************************************
