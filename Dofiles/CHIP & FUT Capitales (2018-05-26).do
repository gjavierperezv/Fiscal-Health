*-------------------------------------------------------------------------------------*
* PROGRAMA ESCRITO POR:	KATTY LOZANO & JAVIER PEREZ	  		       					   *
* FECHA:				MARZO 27 DE 2018				  			   				   *
* DESCRIPCION:			ORGANIZAR LAS BASES DE DATOS CONTABLES Y DE FUT DE LAS 		   *
*						CAPITALES DE LOS DEPARTAMENTOS								   *
*																					   *
*						DEL CHIP:													   *
*						1) LA INFORMACIÓN CONTABLE PÚBLICA							   *
*																					   *
*						DEL FUT:													   *
*						1) FUT - DEUDA PÚBLICA					   					   *
*						2) FUT - GASTOS DE FUNCIONAMIENTO							   *
*						3) FUT - GASTOS DE INVERSIÓN								   *
*						4) FUT - INGRESOS											   *
*						5) FUT - SERVICIO DE LA DEUDA								   *
*																					   *
* NIVEL DE AGREGACION: 	CIUDADES (CAPITALES DE DEPARTAMENTO)				           *
*						AÑOS (2005/06 - 2017)					 					   *
*						LA INFORMACIÓN CORRESPONDE AL ÚLTIMO TRIMESTRE DE CADA AÑO	   * 
*		NOTA: TENER CUIDADO. LAS CIFRAS DE 2005/06 HASTA 2016 ESTÁN EN MILES DE PESOS  *
*		CORRIENTES. LOS DE 2017 ESTÁN EN PESOS CORRIENTES.							   *
* 																					   *
*ARCHIVOS DE ENTRADA:		   			   *
*												   					   				   *
*										   						   					   *
*																   					   *
* EXIT FILES:			DEL CHIP:			 					   					   *	 
*						1) LA INFORMACIÓN CONTABLE PÚBLICA: 						   *
*							TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta			   *
*																					   *
*						DEL FUT:													   *
*						1) FUT - DEUDA PÚBLICA					   					   *
*							
*						2) FUT - GASTOS DE FUNCIONAMIENTO							   *
*							
*						3) FUT - GASTOS DE INVERSIÓN								   *
*							
*						4) FUT - INGRESOS											   *
*							
*						5) FUT - SERVICIO DE LA DEUDA								   *
*							
*																					   *
*--------------------------------------------------------------------------------------*
 	
clear all
set more off, permanently
set rmsg on, permanently
*set dp comma
																		*********************************************
																		*********************************************
																		*		INFORMACIÓN CONTABLE PÚBLICA		*
																		*				   (CHIP)					*
																		*********************************************
																		*********************************************
*--------------------------------------*
//Directorio de trabajo y global path// 
*--------------------------------------*

*****************
* RUTA GENERAL  *
*****************
global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

****************************************
*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
****************************************	
global originales_chip		= 	"${pc}Data/CHIP_Contaduria_General/"
global convertidos_chip		= 	"${pc}Data/Convertidos_CHIP/"
global graficos				=	"${pc}Graficos/"
global tablas				=	"${pc}Tablas/"	
global indicadores			= 	"${pc}Data/Indicadores/"			 
*global StatTransfer_path `"C:\Program Files\StatTransfer13-64\st.exe"' 	/*Definiendo Macro para que trabaje con Stat/Transfer*/ /*LIMITACIÓN POR SER EL PROGRAMA DE PRUEBA, EJECUTAR CON LA VERSIÓN COMPLETA*/ 


/*LEYENDO DE EXCEL(DE ARCHIVOS CON FORMATOS Y DEMAS) A EXCEL(ARCHIVOS LIMPIOS, SIN FORMATOS)*/
/*NOTA: LOS DE 2017 SON LOS ÚNICOS QUE ESTÁN EN PESOS, MIENTRAS QUE ENTRE 2005 Y 2016 ESTÁN EN MILES DE PESOS.
		DE MODO QUE POSTERIORMENTE SE PASARÁN A MILES DE PESOS.*/


/***********************************/
/*	LECTURA DE LOS AÑOS 2005 A 2017*/
/***********************************/
/*Se leen desde Excel y se exportan como Excel para eliminar los formatos de las celdas de los archivos originales.
Estos estaban leyendo como texto variables numericas.*/

global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" "Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 

 foreach a of global capitales {
	forvalues b = 2005/2017 {
		capture confirm file "${originales_chip}`a'/`b'.xls"
			if _rc == 0    { 
			import excel using "${originales_chip}`a'/`b'.xls", clear sheet("reporte pag 1") firstrow cellrange(A10) case(lower)
			 
			ds 		/*lists variable names of the dataset currently in memory in a compact or detailed format, and lets you specify subsets of variables to be listed, either by name or by properties (for
					example, the variables are numeric).  In addition, ds leaves behind in r(varlist) the names of variables selected so that you can use them in a subsequent command.*/
			 
			 foreach old_var in `r(varlist)' {
				local old_var = strtoname("`old_var'")		/*strtoname(s[,p]) Description:  s translated into a Stata 13 compatible name.  results in a name that is truncated to 32 bytes. Each character in s that is not allowed in a Stata name is converted to an underscore character, _.*/
			 }
			 			 
			export excel using "${convertidos_chip}`a'/`a'_`b'.xls", replace firstrow(variables)

			}
		}
	}


/*IMPORTANTO DESDE EXCEL LOS ARCHIVOS CREADOS ANTERIORMENTE Y GUARDÁNDOLOS EN STATA*/
/*NOTA: A CADA ARCHIVO EN STATA SE LE HARÁ.
		1. DESTRING DE LAS VARIABLES NUMÉRICAS
		2. SE INCLUIRÁ UNA NUEVA VARIABLE DE AÑO
		3. SE INCLUIRÁ UNA NUEVA VARIABLE CON EL NOMBRE DEL MUNICIPIO*/
		
global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
 foreach a of global capitales {
	forvalues b = 2005/2017 {
		capture confirm file "${convertidos_chip}`a'/`a'_`b'.xls"
				if _rc == 0    { 
					import excel using "${convertidos_chip}`a'/`a'_`b'.xls", clear sheet("Sheet1") firstrow cellrange(A1) case(lower)
					 
					ds 		/*lists variable names of the dataset currently in memory in a compact or detailed format, and lets you specify subsets of variables to be listed, either by name or by properties (for
							example, the variables are numeric).  In addition, ds leaves behind in r(varlist) the names of variables selected so that you can use them in a subsequent command.*/
					 
					 foreach old_var in `r(varlist)' {
						local old_var = strtoname("`old_var'")		/*strtoname(s[,p]) Description:  s translated into a Stata 13 compatible name.  results in a name that is truncated to 32 bytes. Each character in s that is not allowed in a Stata name is converted to an underscore character, _.*/
					 }
					capture destring 	saldoinicialmiles movimientodebitomiles movimientocreditomiles saldofinalmiles saldofinalcorrientemiles saldofinalnocorrientemiles, replace 
					gen year = `b'
					gen mpio = "`a'"
					capture order year mpio codigo nombre saldoinicialmiles movimientodebitomiles movimientocreditomiles saldofinalmiles saldofinalcorrientemiles saldofinalnocorrientemiles
					save "${convertidos_chip}`a'/`a'_`b'.dta", replace 
		}
	}
 }

	/*Antes de realizar el Append, debemos pasar los datos del año 2017 para cada municipio a miles de pesos, y cambiar el nombre de las variables*/
	global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
	foreach a of global capitales {
		use "${convertidos_chip}`a'/`a'_2017.dta", clear
		gen saldoinicialmiles 			= 		saldoinicialpesos/1000 
		gen movimientodebitomiles 		= 		movimientodebitopesos/1000  
		gen movimientocreditomiles 		= 		movimientocreditopesos/1000
		gen saldofinalmiles			 	=		saldofinalpesos/1000
		gen saldofinalcorrientemiles 	= 		saldofinalcorrientepesos/1000
		gen saldofinalnocorrientemiles 	= 		saldofinalnocorrientepesos/1000
		
		drop saldoinicialpesos movimientodebitopesos movimientocreditopesos saldofinalpesos saldofinalcorrientepesos saldofinalnocorrientepesos
		
		format %12.0f saldoinicialmiles movimientodebitomiles movimientocreditomiles saldofinalmiles saldofinalcorrientemiles saldofinalnocorrientemiles
		
		capture order year mpio codigo nombre saldoinicialmiles movimientodebitomiles movimientocreditomiles saldofinalmiles saldofinalcorrientemiles saldofinalnocorrientemiles
		
		save "${convertidos_chip}`a'/`a'_2017.dta", replace
	}


/****************************************************/
/*		HACIENDO APPEND DE LAS CIUDADES Y AÑOS		*/
/****************************************************/
/*Posibles referencias: 
https://www.stata.com/statalist/archive/2010-08/msg00751.html
https://www.statalist.org/forums/forum/general-stata-discussion/general/1319054-loop-over-different-stata-files-in-a-folder
help filelist
*/


global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
foreach a of global capitales {
	*local files: dir "${convertidos_chip}`a'/" files "*.dta"			/*Ubica le ruta en donde se encuentran los archivos con extensión dta*/
	*display `"$files"'												/*Muestra el nombre de cada uno de los archivos ubicados en el comando anterior*/
	*tokenize `"$files"'											/*tokenize divides string into tokens, storing the result in `1', `2', ... (the positional local macros*/
	
	filelist, dir("${convertidos_chip}`a'/") pat("*.dta")  save("${convertidos_chip}`a'/z_dta_datasets_`a'.dta") replace 			/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
																														/*Se antedecede con z para que quede en el último lugar en la carpeta de archivos y en la numeración.*/
	use "${convertidos_chip}`a'/z_dta_datasets_`a'.dta", clear
    gen count 	= _n   
	gen obs		= _N - 1		/*Se resta 1 para que no cuente el último archivo que inicia con z, que es el que corresponde a la descripción de los archivos*/
	save "${convertidos_chip}`a'/z_dta_datasets_`a'.dta", replace
	
	 local obs = _N - 1
     forvalues i = 1/`obs' {
		use "${convertidos_chip}`a'/z_dta_datasets_`a'.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
			local f = dirname + "/" + filename
			use "`f'", clear
			gen source = "`f'"
			tempfile save`i'
			save "`save`i''"
	}

	/*Append de los Años para cada Municipio*/	 
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"
				
		sort year codigo
		
		save "${convertidos_chip}`a'_Panel_hasta_2017.dta", replace
	}
}	

	/*Append de todas las ciudades*/
	filelist, dir("${convertidos_chip}") pat("*.dta")  save("${convertidos_chip}Z_MPIOS_dta_datasets.dta") replace list norecursive maxdeep(1)		/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
	
	use "${convertidos_chip}Z_MPIOS_dta_datasets.dta", clear
	local obs = _N - 1
    forvalues i = 1/`obs' {
		use "${convertidos_chip}Z_MPIOS_dta_datasets.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
		local f = dirname + filename
		use "`f'", clear
		gen source2 = "`f'"
		tempfile save`i'
		save "`save`i''"
	}
	
	/*Append de TODOS los Municipio*/
	/*ESTE SEGMENTO DEBE CORRESRSE SIMULTÁNEAMENTE CON EL ANTERIOR PARA QUE FUNCIONE. ESTO YA QUE IMPLICA ARCHIVOS TEMPORALES*/
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"
						
		save "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TEMP_Panel_Info_Contable_hasta_2017.dta", replace
	}
	
		
	/*Asignando los codigos de los municipios al panel de datos*/
		use "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TEMP_Panel_Info_Contable_hasta_2017.dta", clear
		
		gen cod_dane = 91001 if mpio == "Leticia"
		replace cod_dane = 5001 if mpio == "Medellín"
		replace cod_dane = 81001 if mpio == "Arauca"
		replace cod_dane = 8001 if mpio == "Barranquilla"
		replace cod_dane = 13001 if mpio == "Cartagena"
		replace cod_dane = 15001 if mpio == "Tunja"
		replace cod_dane = 17001 if mpio == "Manizales"
		replace cod_dane = 18001 if mpio == "Florencia"
		replace cod_dane = 85001 if mpio == "Yopal"
		replace cod_dane = 19001 if mpio == "Popayán"
		replace cod_dane = 20001 if mpio == "Valledupar"
		replace cod_dane = 27001 if mpio == "Quibdó"
		replace cod_dane = 23001 if mpio == "Montería"
		replace cod_dane = 11001 if mpio == "Bogotá"
		replace cod_dane = 94001 if mpio == "Inírida"
		replace cod_dane = 95001 if mpio == "San José del Guaviare"
		replace cod_dane = 41001 if mpio == "Neiva"
		replace cod_dane = 44001 if mpio == "Riohacha"			
		replace cod_dane = 47001 if mpio == "Santa Marta"
		replace cod_dane = 50001 if mpio == "Villavicencio"            
		replace cod_dane = 52001 if mpio == "Pasto"
		replace cod_dane = 54001 if mpio == "Cúcuta"
		replace cod_dane = 68001 if mpio == "Bucaramanga"
		replace cod_dane = 86001 if mpio == "Mocoa"
		replace cod_dane = 63001 if mpio == "Armenia"
		replace cod_dane = 66001 if mpio == "Pereira"
		replace cod_dane = 88001 if mpio == "San Andrés"
		replace cod_dane = 70001 if mpio == "Sincelejo"
		replace cod_dane = 73001 if mpio == "Ibagué"
		replace cod_dane = 76001 if mpio == "Cali"
		replace cod_dane = 97001 if mpio == "Mitú"
		replace cod_dane = 99001 if mpio == "Puerto Carreño"
		
		order year mpio cod_dane codigo nombre saldoinicialmiles movimientodebitomiles movimientocreditomiles saldofinalmiles saldofinalcorrientemiles saldofinalnocorrientemiles source
		drop source source2
		
		save "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta", replace

		

																		*********************************************
																		*********************************************
																		*				FUT: DEUDA PÚBLICA			*
																		*				     (FUT)					*
																		*				(Inicia en 2011)			*
																		*********************************************
																		*********************************************
clear all
set more off, permanently
set rmsg on, permanently
																		
*--------------------------------------*
//Directorio de trabajo y global path// 
*--------------------------------------*

*****************
* RUTA GENERAL  *
*****************
global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

****************************************
*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
****************************************	
global originales_fut		= 	"${pc}Data/FUT_DATOS/"
global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
global graficos				=	"${pc}Graficos/"
global tablas				=	"${pc}Tablas/"				 

/*LEYENDO DE EXCEL(DE ARCHIVOS CON FORMATOS Y DEMAS) A EXCEL(ARCHIVOS LIMPIOS, SIN FORMATOS)*/
/*NOTA: LOS DE 2017 SON LOS ÚNICOS QUE ESTÁN EN PESOS, MIENTRAS QUE ENTRE 2011 Y 2016 ESTÁN EN MILES DE PESOS.
		DE MODO QUE POSTERIORMENTE SE PASARÁN A MILES DE PESOS.*/


/***************************************/
/* 1.	LECTURA DE LOS AÑOS 2011 A 2017*/
/***************************************/
/*Se leen desde Excel  y se modifica  para los formatos que se estaban leyendo como texto variables numericas.*/
/*NOTA: A CADA ARCHIVO EN STATA SE LE HARÁ.
		1. DESTRING DE LAS VARIABLES NUMÉRICAS
		2. SE INCLUIRÁ UNA NUEVA VARIABLE DE AÑO
		3. SE INCLUIRÁ UNA NUEVA VARIABLE CON EL NOMBRE DEL MUNICIPIO*/

global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" "Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 

foreach a of global capitales {
	forvalues b = 2011/2017 {
		capture confirm file "${originales_fut}Fut_Deuda_Publica/`a'/`b'.xls"
			if _rc == 0    { 
			import excel using "${originales_fut}Fut_Deuda_Publica/`a'/`b'.xls", clear sheet("reporte pag 1") firstrow cellrange(A10) case(lower)
			 
			ds 		/*lists variable names of the dataset currently in memory in a compact or detailed format, and lets you specify subsets of variables to be listed, either by name or by properties (for
					example, the variables are numeric).  In addition, ds leaves behind in r(varlist) the names of variables selected so that you can use them in a subsequent command.*/
			 
			 foreach old_var in `r(varlist)' {
				local old_var = strtoname("`old_var'")		/*strtoname(s[,p]) Description:  s translated into a Stata 13 compatible name.  results in a name that is truncated to 32 bytes. Each character in s that is not allowed in a Stata name is converted to an underscore character, _.*/
			 }
			 destring `old_var', replace  dpcomma      /* se le hace destring a todas las variables  usando el local de todas las variables ,esto es posible solo si se coloca el comando "dpcomma" ya que hay variables que son numericas y estan en string por la coma */
		
			ds, has(type numeric)           /*se listan y se guardan las variables solo de tipo nuymerico, para despues cambiarles el formato, de no hacerse habria un error por que las variables string no se le puede aplicar formatos numericos*/

				foreach var of varlist `r(varlist)' {
				format  %15.2f `var'   
			 }
				gen year = `b'
				gen mpio = "`a'"	
			
			capture order year mpio codigo-bc
			
			save "${convertidos_fut}FUT_Deuda_Publica/`a'/`a'_`b'.dta", replace 
			}
		}
}

/*Antes de realizar el Append, debemos pasar los datos del año 2017 para cada municipio a miles de pesos, y cambiar el nombre de las variables*/

global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
foreach a of global capitales {
	use "${convertidos_fut}FUT_Deuda_Publica/`a'/`a'_2017.dta" , clear 
		
	gen montoaprobadomonedacreditomiles 	= [montoaprobadomonedacreditope/1000]
	gen montoaprobadomiles 					= [montoaprobadopesos/1000]  
	gen vlrdesembolsadocierrevigmiles 		= [vlrdesembolsadocierrevigencia/1000]
	gen valorpignoradomiles 				= [valorpignoradopesos/1000]
	gen saldocierreviganteriormiles 		= [saldocierrevigenciaanteriorp/1000]
	gen desembolsosenlavigmiles 			= [desembolsosenlavigenciapesos/1000]
	gen interesespagadosenlavigmiles 		= [interesespagadosenlavigencia/1000]
	gen comisionespagadasvigmiles 			= [comisionespagadasvigenciapeso/1000]
	gen amortizacionespagadasvigmiles 		= [amorizacionespagadasvigenciap/1000]
	gen interesesproyectsgtevigmiles 		= [interesesproyectsgtevigencia/1000]
	gen saldodeudacierrevigactualmiles 		= [saldodeudacierrevigenciaactual/1000] 

	/*Renombrando las variables*/
	rename numregdeudapublicaminhacienda	num_reg_deud_minhac
	rename sectorpermitevarios				sector
	rename rentagarantiapermitevarias		renta_garantia
	rename tipodedeuda						tipo_de_deuda
	rename descripcionobjetoproyecto 		descrip_obj_proyec
	rename entidadfinancieranacionoinfis	ent_fina_naci_o_infis
	rename fechafirmadelcontrato			fecha_firm_de_contra
	rename fechadereestructuracion			fecha_de_reestruc
	rename plazounidad						plazo
	rename periododegraciaunidad			periodo_de_gracia
	rename periododevencimientounidad		periodo_de_venc
	rename tipotasainteres					tipo_tasa_interes
	rename tasa_porcentajeadicionaloptos	tasa_porce_adic_o_ptos
	rename porcentajedepignoracionpocent	porce_de_pignor
	rename porcentajegarantizadonacionpo	porce_garantiz_nacion
	rename montoaprobadomonedacreditomiles 	monto_aprob_moneda
	rename montoaprobadomiles 				monto_aprob
	rename vlrdesembolsadocierrevigmiles	vlr_desemb
	rename valorpignoradomiles				vlr_pignor
	rename saldocierreviganteriormiles		saldo_cier_vig_ant
	rename desembolsosenlavigmiles			desemb_vigencia
	rename interesespagadosenlavigmiles		interes_pagad_vig
	rename comisionespagadasvigmiles		comis_pagad_vig
	rename amortizacionespagadasvigmiles	amort_pagad_vig
	rename interesesproyectsgtevigmiles		inter_proyec_sgte_vig
	rename saldodeudacierrevigactualmiles	saldo_deud_cier_vig_act
	rename pesos 							proyec_2017
	rename af								proyec_2018
	rename ag 								proyec_2019
	rename ah								proyec_2020
		
		/*Etiquetado*/
	lab var num_reg_deud_minhac				"Num reg deuda publica minhacienda" 
	lab var sector							"Sector - Permite varios"
	lab var renta_garantia					"Renta garantía - Permite varias"
	lab var tipo_de_deuda					"Tipo de deuda"
	lab var descrip_obj_proyec				"Descripción objeto proyecto"
	lab var ent_fina_naci_o_infis			"Entidad financiera nación o infis"
	lab var fecha_firm_de_contra			"Fecha firma del contrato"
	lab var fecha_de_reestruc				"Fecha de reestructuración"	
	lab var plazo							"Plazo - Unidad"
	lab var periodo_de_gracia				"Período de gracia"
	lab var periodo_de_venc					"Período de vencimiento - Unidad"
	lab var tipo_tasa_interes				"Tipo tasa interes"
	lab var tasa_porce_adic_o_ptos			"Tasa porcentaje adicional o ptos"
	lab var porce_de_pignor					"Porcentaje de pignoración"
	lab var porce_garantiz_nacion			"Porcentaje garantizado nación"
	lab var monto_aprob_moneda				"Monto aprobado moneda crédito(miles)"
	lab var monto_aprob						"Monto aprobado(miles)"
	lab var vlr_desemb						"Valor desembolsado cierre vigencia(miles)"
	lab var vlr_pignor						"Valor pignorado(miles)"
	lab var saldo_cier_vig_ant				"Saldo cierre vigencia anterior(miles)"
	lab var desemb_vigencia					"Desembolsos en la vigencia(miles)"
	lab var interes_pagad_vig				"Intereses pagados en la vigencia(miles)"
	lab var comis_pagad_vig					"Comisiones pagadas vigencia(miles)"
	lab var amort_pagad_vig					"Amortizaciones pagadas vigencia(miles)"
	lab var inter_proyec_sgte_vig			"Intereses proyectados sgte vigencia(miles)"
	lab var saldo_deud_cier_vig_act			"Saldo deuda cierre vigencia actual(miles)"
    lab var proyec_2017						"Saldo deuda proyectado(2017)"
	lab var proyec_2018						"Saldo deuda proyectado(2018)"
	lab var proyec_2019						"Saldo deuda proyectado(2019)"
	lab var proyec_2020						"Saldo deuda proyectado(2020)"  
	
	drop  montoaprobadomonedacreditope montoaprobadopesos vlrdesembolsadocierrevigencia valorpignoradopesos saldocierrevigenciaanteriorp ///
	desembolsosenlavigenciapesos interesespagadosenlavigencia comisionespagadasvigenciapeso amorizacionespagadasvigenciap interesesproyectsgtevigencia saldodeudacierrevigenciaactual
	
	/*Ordenando las variables*/
	order year mpio codigo nombre num_reg_deud_minhac-saldo_deud_cier_vig_act
	
	foreach x in num_reg_deud_minhac ent_fina_naci_o_infis descrip_obj_proyec { 				/*se cambian estas variables a string,si se confirma que estas son numericas*/
	capture confirm numeric var `x'
		if !_rc {
		tostring `x' , force replace
					}
				}
	
	save "${convertidos_fut}FUT_Deuda_Publica/`a'/`a'_2017.dta", replace 
 }
 
/*Preparando y organizando variables del 2011 al 2016*/
foreach a of global capitales {
	forvalues b = 2011/2016 {
		capture confirm file "${convertidos_fut}FUT_Deuda_Publica/`a'/`a'_`b'.dta" 
		if _rc == 0    { 
		use "${convertidos_fut}FUT_Deuda_Publica/`a'/`a'_`b'.dta" , clear 
 
     /*Renombrando variables*/
	rename numregdeudapublicaminhacienda	num_reg_deud_minhac
	rename sectorpermitevarios				sector
	rename rentagarantiapermitevarias		renta_garantia
	rename tipodedeuda						tipo_de_deuda
	rename descripcionobjetoproyecto 		descrip_obj_proyec
	rename entidadfinancieranacionoinfis	ent_fina_naci_o_infis
	rename fechafirmadelcontrato			fecha_firm_de_contra
	rename fechadereestructuracion			fecha_de_reestruc
	rename plazo*							plazo
	rename periododegracia*					periodo_de_gracia
	rename periododevencimiento*			periodo_de_venc
	rename tipotasainteres					tipo_tasa_interes
	rename tasa_porcentajeadicionaloptos	tasa_porce_adic_o_ptos
	rename porcentajedepignoracionpocent	porce_de_pignor
	rename porcentajegarantizadonacionpo	porce_garantiz_nacion
	rename montoaprobadomonedacreditoun 	monto_aprob_moneda
	rename montoaprobadomiles 				monto_aprob
	rename vlrdesembolsadocierrevigencia	vlr_desemb
	rename valorpignoradomiles				vlr_pignor
	rename saldocierrevigenciaanteriorm		saldo_cier_vig_ant
	rename desembolsosenlavigenciamiles		desemb_vigencia
	rename interesespagadosenlavigencia		interes_pagad_vig
	rename comisionespagadasvigenciamile	comis_pagad_vig
	rename amorizacionespagadasvigenciam	amort_pagad_vig
	rename interesesproyectsgtevigencia		inter_proyec_sgte_vig
	rename saldodeudacierrevigenciaactual	saldo_deud_cier_vig_act
	rename miles 							proyec_2017
	rename af								proyec_2018
	rename ag 								proyec_2019
	rename ah								proyec_2020
	
		/*Etiquetado*/
	lab var num_reg_deud_minhac				"Num reg deuda publica minhacienda" 
	lab var sector							"Sector - Permite varios"
	lab var renta_garantia					"Renta garantía - Permite varias"
	lab var tipo_de_deuda					"Tipo de deuda"
	lab var descrip_obj_proyec				"Descripción objeto proyecto"
	lab var ent_fina_naci_o_infis			"Entidad financiera nación o infis"
	lab var fecha_firm_de_contra			"Fecha firma del contrato"
	lab var fecha_de_reestruc				"Fecha de reestructuración"	
	lab var plazo							"Plazo - Unidad"
	lab var periodo_de_gracia				"Período de gracia"
	lab var periodo_de_venc					"Período de vencimiento Unidad"
	lab var tipo_tasa_interes				"Tipo tasa interes"
	lab var tasa_porce_adic_o_ptos			"Tasa porcentaje adicional o ptos"
	lab var porce_de_pignor					"Porcentaje de pignoración"
	lab var porce_garantiz_nacion			"Porcentaje garantizado nación"
	lab var monto_aprob_moneda				"Monto aprobado moneda crédito(miles)"
	lab var monto_aprob						"Monto aprobado(miles)"
	lab var vlr_desemb						"Valor desembolsado cierre vigencia(miles)"
	lab var vlr_pignor						"Valor pignorado(miles)"
	lab var saldo_cier_vig_ant				"Saldo cierre vigencia anterior(miles)"
	lab var desemb_vigencia					"Desembolsos en la vigencia(miles)"
	lab var interes_pagad_vig				"Intereses pagados en la vigencia(miles)"
	lab var comis_pagad_vig					"Comisiones pagadas vigencia(miles)"
	lab var amort_pagad_vig					"Amortizaciones pagadas vigencia(miles)"
	lab var inter_proyec_sgte_vig			"Intereses proyectados sgte vigencia(miles)"
	lab var saldo_deud_cier_vig_act			"Saldo deuda cierre vigencia actual(miles)"
	lab var proyec_2017						"Saldo deuda proyectado(2017)"
	lab var proyec_2018						"Saldo deuda proyectado(2018)"
	lab var proyec_2019						"Saldo deuda proyectado(2019)"
	lab var proyec_2020						"Saldo deuda proyectado(2020)"  
   
	order year mpio codigo nombre num_reg_deud_minhac sector renta_garantia tipo_de_deuda descrip_obj_proyec ent_fina_naci_o_infis ///
	fecha_firm_de_contra reestructurada fecha_de_reestruc moneda monto_aprob_moneda monto_aprob vlr_desemb plazo ///
	periodo_de_gracia periodo_de_venc tipo_tasa_interes tasa_porce_adic_o_ptos vlr_pignor porce_de_pignor porce_garantiz_nacion ///
	saldo_cier_vig_ant desemb_vigencia interes_pagad_vig comis_pagad_vig amort_pagad_vig inter_proyec_sgte_vig saldo_deud_cier_vig_act
	
	foreach x in num_reg_deud_minhac ent_fina_naci_o_infis {
	capture confirm numeric var `x'
		if !_rc {
		tostring `x' , force replace
					}
				}
	save "${convertidos_fut}FUT_Deuda_Publica/`a'/`a'_`b'.dta", replace 

		}
	}
}

/****************************************************/
/*	2.	HACIENDO APPEND DE LAS CIUDADES Y AÑOS		*/
/****************************************************/

global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
foreach a of global capitales {
	*local files: dir "${convertidos_fut/FUT_Deuda_Publica}`a'/" files "*.dta"			/*Ubica le ruta en donde se encuentran los archivos con extensión dta*/
	*display `"$files"'																	/*Muestra el nombre de cada uno de los archivos ubicados en el comando anterior*/
	*tokenize `"$files"'																/*tokenize divides string into tokens, storing the result in `1', `2', ... (the positional local macros*/
	
	filelist, dir("${convertidos_fut}/FUT_Deuda_Publica/`a'/") pat("*.dta")  save("${convertidos_fut}/FUT_Deuda_Publica/`a'/z_dta_datasets_`a'.dta") replace 			/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
																														/*Se antedecede con z para que quede en el último lugar en la carpeta de archivos y en la numeración.*/
	use "${convertidos_fut}/FUT_Deuda_Publica/`a'/z_dta_datasets_`a'.dta", clear
    gen count 	= _n   
	gen obs		= _N - 1		/*Se resta 1 para que no cuente el último archivo que inicia con z, que es el que corresponde a la descripción de los archivos*/
	save "${convertidos_fut}/FUT_Deuda_Publica/`a'/z_dta_datasets_`a'.dta", replace
	
	 local obs = _N - 1
     forvalues i = 1/`obs' {
		use "${convertidos_fut}/FUT_Deuda_Publica/`a'/z_dta_datasets_`a'.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
			local f = dirname + "/" + filename
			use "`f'", clear
			gen source = "`f'"
			tempfile save`i'
			save "`save`i''"
	}

	/*Append de los Años para cada Municipio*/	 
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"
				
		sort year codigo
		
		capture drop ai ai aj ak al am an ao ap aq ar as at au av aw ax ay az ba bb bc
		
		save "${convertidos_fut}/FUT_Deuda_Publica/`a'_Panel_hasta_2017.dta", replace
	}
}	

	/*Append de todas las ciudades*/
	filelist, dir("${convertidos_fut}/FUT_Deuda_Publica/") pat("*.dta")  save("${convertidos_fut}/FUT_Deuda_Publica/Z_MPIOS_dta_datasets.dta") replace list norecursive maxdeep(1)		/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
	
	use "${convertidos_fut}/FUT_Deuda_Publica/Z_MPIOS_dta_datasets.dta", clear
	local obs = _N - 1
    forvalues i = 1/`obs' {
		use "${convertidos_fut}/FUT_Deuda_Publica/Z_MPIOS_dta_datasets.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
		local f = dirname + filename
		use "`f'", clear
		gen source2 = "`f'"
		tempfile save`i'
		save "`save`i''"
	}
	
	/*Append de TODOS los Municipio*/
	/*ESTE SEGMENTO DEBE CORRESRSE SIMULTÁNEAMENTE CON EL ANTERIOR PARA QUE FUNCIONE. ESTO YA QUE IMPLICA ARCHIVOS TEMPORALES*/
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"
		*drop pesos 
		save "${convertidos_fut}/FUT_Deuda_Publica/Z_PANELES/PANEL_DEUDA_PUBLICA/TEMP_Panel_deuda_publica_hasta_2017.dta", replace
	}
	
	
/*Asignando los codigos de los municipios al panel de datos*/
		use "${convertidos_fut}/FUT_Deuda_Publica/Z_PANELES/PANEL_DEUDA_PUBLICA/TEMP_Panel_Deuda_publica_hasta_2017.dta", clear
		
		gen cod_dane = 91001 if mpio == "Leticia"
		replace cod_dane = 5001 if mpio == "Medellín"
		replace cod_dane = 81001 if mpio == "Arauca"
		replace cod_dane = 8001 if mpio == "Barranquilla"
		replace cod_dane = 13001 if mpio == "Cartagena"
		replace cod_dane = 15001 if mpio == "Tunja"
		replace cod_dane = 17001 if mpio == "Manizales"
		replace cod_dane = 18001 if mpio == "Florencia"
		replace cod_dane = 85001 if mpio == "Yopal"
		replace cod_dane = 19001 if mpio == "Popayán"
		replace cod_dane = 20001 if mpio == "Valledupar"
		replace cod_dane = 27001 if mpio == "Quibdó"
		replace cod_dane = 23001 if mpio == "Montería"
		replace cod_dane = 11001 if mpio == "Bogotá"
		replace cod_dane = 94001 if mpio == "Inírida"
		replace cod_dane = 95001 if mpio == "San José del Guaviare"
		replace cod_dane = 41001 if mpio == "Neiva"
		replace cod_dane = 44001 if mpio == "Riohacha"			
		replace cod_dane = 47001 if mpio == "Santa Marta"
		replace cod_dane = 50001 if mpio == "Villavicencio"            
		replace cod_dane = 52001 if mpio == "Pasto"
		replace cod_dane = 54001 if mpio == "Cúcuta"
		replace cod_dane = 68001 if mpio == "Bucaramanga"
		replace cod_dane = 86001 if mpio == "Mocoa"
		replace cod_dane = 63001 if mpio == "Armenia"
		replace cod_dane = 66001 if mpio == "Pereira"
		replace cod_dane = 88001 if mpio == "San Andrés"
		replace cod_dane = 70001 if mpio == "Sincelejo"
		replace cod_dane = 73001 if mpio == "Ibagué"
		replace cod_dane = 76001 if mpio == "Cali"
		replace cod_dane = 97001 if mpio == "Mitú"
		replace cod_dane = 99001 if mpio == "Puerto Carreño"
		
		drop source source2 pesos 
		order year mpio cod_dane codigo nombre num_reg_deud_minhac-saldo_deud_cier_vig_act
		save "${convertidos_fut}/FUT_Deuda_Publica/Z_PANELES/PANEL_DEUDA_PUBLICA/TODOS_MPIOS_Panel_Deuda_publica_hasta_2017.dta", replace
	
	
																						
																		*********************************************
																		*********************************************
																		*				FUT: INGRESOS				*
																		*				     (FUT)					*
																		*				(Inicia en 2008)			*
		
																		*********************************************
																		*********************************************
clear all
set more off, permanently
set rmsg on, permanently
		
		
*--------------------------------------*
//Directorio de trabajo y global path// 
*--------------------------------------*

*****************
* RUTA GENERAL  *
*****************
global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

****************************************
*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
****************************************	
global originales_fut		= 	"${pc}Data/FUT_DATOS/"
global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
global graficos				=	"${pc}Graficos/"
global tablas				=	"${pc}Tablas/"					
			

/*LEYENDO DE EXCEL(DE ARCHIVOS CON FORMATOS Y DEMAS) A EXCEL(ARCHIVOS LIMPIOS, SIN FORMATOS)*/
/*NOTA: LOS DE 2017 SON LOS ÚNICOS QUE ESTÁN EN PESOS, MIENTRAS QUE ENTRE 2008 Y 2016 ESTÁN EN MILES DE PESOS.
		DE MODO QUE POSTERIORMENTE SE PASARÁN A MILES DE PESOS.*/


/***********************************/
/*	LECTURA DE LOS AÑOS 2008 A 2017*/
/***********************************/
/*Se leen desde Excel  y se modifica  para los formatos que se estaban leyendo como texto variables numericas.*/
/*NOTA: A CADA ARCHIVO EN STATA SE LE HARÁ.
		1. DESTRING DE LAS VARIABLES NUMÉRICAS
		2. SE INCLUIRÁ UNA NUEVA VARIABLE DE AÑO
		3. SE INCLUIRÁ UNA NUEVA VARIABLE CON EL NOMBRE DEL MUNICIPIO*/

global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" "Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 

foreach a of global capitales {
	forvalues b = 2008/2017 {
		capture confirm file "${originales_fut}Fut_Ingresos/`a'/`b'.xls"
			if _rc == 0    { 
			import excel using "${originales_fut}Fut_Ingresos/`a'/`b'.xls", clear sheet("reporte pag 1") firstrow cellrange(A10) case(lower)
			 
			ds 		/*lists variable names of the dataset currently in memory in a compact or detailed format, and lets you specify subsets of variables to be listed, either by name or by properties (for
					example, the variables are numeric).  In addition, ds leaves behind in r(varlist) the names of variables selected so that you can use them in a subsequent command.*/
			 
			 foreach old_var in `r(varlist)' {
				local old_var = strtoname("`old_var'")		/*strtoname(s[,p]) Description:  s translated into a Stata 13 compatible name.  results in a name that is truncated to 32 bytes. Each character in s that is not allowed in a Stata name is converted to an underscore character, _.*/
			 }
			 destring `old_var', replace  dpcomma      /* se le hace destring a todas las variables  usando el local de todas las variables ,esto es posible solo si se coloca el comando "dpcomma" ya que hay variables que son numericas y estan en string por la coma */
		
			ds, has(type numeric)           /*se listan y se guardan las variables solo de tipo nuymerico, para despues cambiarles el formato, de no hacerse habria un error por que las variables string no se le puede aplicar formatos numericos*/

				foreach var of varlist `r(varlist)' {
				format  %15.2f `var'   
			 }
				gen year = `b'
				gen mpio = "`a'"	
			
			order year mpio codigo
			
			save "${convertidos_fut}FUT_Ingresos/`a'/`a'_`b'.dta", replace 
		}
	}
}
	
	
*set trace on 
*set tracedepth 1
	
global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
foreach a of global capitales {
	use "${convertidos_fut}FUT_Ingresos/`a'/`a'_2017.dta" , clear 	

		gen presupuestoinicialmiles 	= 		[presupuestoinicialpesos/1000]
		gen presupuestodefinitivomiles 	= 		[presupuestodefinitivopesos/1000]  
		gen recaudoefectivomiles 		= 		[recaudoefectivopesos/1000]
		gen recaudosinsituadefondos		= 		[recaudosinsituacióndefondos/1000]
		gen totalingresosmiles 			= 		[totalingresospesos/1000]
		gen otrasdestvalordestmiles   	=       [otrasdestvalordestinaciónp/1000]
		
		/*Renombrando las variables*/
		
		rename presupuestoinicialmiles		presup_inicial	
		rename presupuestodefinitivomiles	presup_definitivo
		rename recaudoefectivomiles			recaudo_efectivo
		rename recaudosinsituadefondos		recau_sin_situ_de_fond
		rename totalingresosmiles			total_ingresos 
		rename otrasdesttienedocsoporte		otras_dest_doc_soporte
		rename otrasdestnrodocumento		otras_dest_nro_doc
		rename otrasdestdestinaciónpocen	otras_dest_porce_dest
		rename otrasdestvalordestmiles		otras_dest_vlr_dest
								
			/*Etiquetado*/
		lab var presup_inicial 					"Presupuesto inicial(miles)"
		lab var presup_definitivo				"Presupuesto definitivo(miles)"
		lab var recaudo_efectivo  				"Presupuesto efectivo(miles)"
		lab var recau_sin_situ_de_fond 			"Recaudos sin situación de fondos(miles)"
		lab var	total_ingresos				 	"Total ingresos(miles)"
		lab var otras_dest_doc_soporte			"Otras dest - Doc soporte"
		lab var otras_dest_nro_doc				"Otras dest - Nro Doc"
		lab var otras_dest_porce_dest			"Otras dest - % destinacion"
		lab var otras_dest_vlr_dest				"Otras dest - Valor destinación(miles)"
		
		drop presupuestoinicialpesos presupuestodefinitivopesos recaudoefectivopesos recaudosinsituacióndefondos totalingresospesos otrasdestvalordestinaciónp
		
		order year mpio codigo nombre presup_inicial presup_definitivo recaudo_efectivo recau_sin_situ_de_fond total_ingresos otras_dest_doc_soporte otras_dest_nro_doc otras_dest_porce_dest otras_dest_vlr_dest 
	
		save "${convertidos_fut}FUT_Ingresos/`a'/`a'_2017.dta", replace 
 }
 
		 
/*Preparando y organizando variables del 2008 al 2016*/												
																								
/*NOTA:El año 2008, no contiene las variables (A) Y (B) Y  el 2009 y 2010, no contiene la (B)*/
	*A)RECAUDO SIN SITUACIÓN DE FONDOS
	*B)TOTAL INGRESOS
	
/*FUT INGRESOS : Ha tenido ciertos  cambios, que se pueden contemplar en el  DECRETO 3402 DEL 2007 y DECRETO 1536 del 2016.
Para la selección de la cuenta de TOTAL INGRESOS,  se debe  tomar la variable RECAUDO EFECTIVO para el año 2008,///
porque inicialmente no existía la variable separada de RECAUDO SIN SITUACION DE FONDOS(A)///
En el 2009 y 2010 aparece por separado la VARIABLE RECAUDO SIN SITUACIÓN DE FONDOS (A), ///
por lo tanto para se debe sumar el RECAUDO EFECTIVO con el RECAUDO SIN SITUACION DE FONDOS, para obtener el TOTAL INGRESOS, como una nueva variable.///
A partir del 2011, se toma solo la variable TOTAL INGRESOS (B), que si aparece hasta el 2017. */								
	
*****************************************************************
/*modificando variables string para leticia*/
*para poder hacer el append posteriormente.
use "${convertidos_fut}FUT_Ingresos/Leticia/Leticia_2011.dta"
		
replace presupuestoinicialmiles 		= subinstr(presupuestoinicialmiles,"V","",.)		 /*subinstr(s1,s2,s3,n): s1, where the first n occurrences in s1 of s2 have been replaced with s3*/
replace presupuestodefinitivomiles 		= subinstr(presupuestoinicialmiles,"V","",.)
replace recaudoefectivomiles 			= subinstr(recaudoefectivomiles ,"V","",.)
replace recaudosinsituacióndefondos 	= subinstr(recaudosinsituacióndefondos,"V","",.)
replace totalingresosmiles				= subinstr(totalingresosmiles,"V","",.)

destring presupuestoinicialmiles, replace dpcomma
destring presupuestodefinitivomiles, replace dpcomma
destring recaudoefectivomiles, replace dpcomma
destring recaudosinsituacióndefondos, replace dpcomma
destring totalingresosmiles, replace dpcomma

save "${convertidos_fut}FUT_Ingresos/Leticia/Leticia_2011.dta", replace 

***************************************	

set trace on 
set tracedepth 1

foreach a of global capitales {
	forvalues b = 2008/2016 {
		
		capture confirm file "${convertidos_fut}FUT_Ingresos/`a'/`a'_`b'.dta" 
		if _rc == 0    { 
		
		use "${convertidos_fut}FUT_Ingresos/`a'/`a'_`b'.dta" , clear
		
		capture confirm var recaudosinsituacióndefondos			/*Esto se hace debido a lo que se comentó arriba de la no-existencia de esta variable en algunos años.
																La solución es renombrarla siempre que exista en la base correspondiente.*/
		if !_rc {
		rename recaudosinsituacióndefondos		recau_sin_situ_de_fond	
		lab var recau_sin_situ_de_fond 			"Recaudos sin situación de fondos(miles)"
		}

		capture confirm var totalingresosmiles					/*Esto se hace debido a lo que se comentó arriba de la no-existencia de esta variable en algunos años.
																La solución es renombrarla siempre que existe en la base correspondiente.*/
		if !_rc {
		rename totalingresosmiles				total_ingresos
		lab var	total_ingresos				 	"Total ingresos(miles)"
		}
		
		rename presupuestoinicialmiles			presup_inicial	
		rename presupuestodefinitivomiles		presup_definitivo
		rename recaudoefectivomiles				recaudo_efectivo
		rename otrasdesttienedocsoporte			otras_dest_doc_soporte
		rename otrasdestnrodocumento			otras_dest_nro_doc
		rename otrasdestdestinaciónpocen		otras_dest_porce_dest
		rename otrasdestvalordestinaciónm		otras_dest_vlr_dest  
		
		/*Etiquetado*/
		lab var presup_inicial 					"Presupuesto inicial(miles)"
		lab var presup_definitivo				"Presupuesto definitivo(miles)"
		lab var recaudo_efectivo  				"Presupuesto efectivo(miles)"
		lab var otras_dest_doc_soporte			"Otras dest - Doc soporte"
		lab var otras_dest_nro_doc				"Otras dest - Nro Doc"
		lab var otras_dest_porce_dest			"Otras dest - % destinación"
		lab var otras_dest_vlr_dest				"Otras dest - Valor destinación(miles)" 

	save "${convertidos_fut}FUT_Ingresos/`a'/`a'_`b'.dta", replace 	
		
		}
	}
}
	
set trace on 
set tracedepth 1
	
/****************************************************/
/*	2.	HACIENDO APPEND DE LAS CIUDADES Y AÑOS		*/
/****************************************************/

global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
foreach a of global capitales {
	*local files: dir "${convertidos_fut/FUT_Ingresos}`a'/" files "*.dta"			/*Ubica le ruta en donde se encuentran los archivos con extensión dta*/
	*display `"$files"'																	/*Muestra el nombre de cada uno de los archivos ubicados en el comando anterior*/
	*tokenize `"$files"'																/*tokenize divides string into tokens, storing the result in `1', `2', ... (the positional local macros*/
	
	filelist, dir("${convertidos_fut}/FUT_Ingresos/`a'/") pat("*.dta")  save("${convertidos_fut}/FUT_Ingresos/`a'/z_dta_datasets_`a'.dta") replace 			/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
																														/*Se antedecede con z para que quede en el último lugar en la carpeta de archivos y en la numeración.*/
	use "${convertidos_fut}/FUT_Ingresos/`a'/z_dta_datasets_`a'.dta", clear
    gen count 	= _n   
	gen obs		= _N - 1		/*Se resta 1 para que no cuente el último archivo que inicia con z, que es el que corresponde a la descripción de los archivos*/
	save "${convertidos_fut}/FUT_Ingresos/`a'/z_dta_datasets_`a'.dta", replace
	
	 local obs = _N - 1
     forvalues i = 1/`obs' {
		use "${convertidos_fut}/FUT_Ingresos/`a'/z_dta_datasets_`a'.dta" in `i', clear		/*De cada archivo va tomando cada observacion(que tiene cada año) que tiene informacion del nombre del directorio, del archivo, etc.*/
			local f = dirname + "/" + filename
			use "`f'", clear
			gen source = "`f'"
			tempfile save`i'
			save "`save`i''"
	}

	/*Append de los Años para cada Municipio*/	 
	display " ---------------`a'_completo----------------------"
	
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"		
		sort year codigo
		capture drop ai ai aj ak al am an ao ap aq ar as at au av aw ax ay az ba bb bc
		save "${convertidos_fut}/FUT_Ingresos/`a'_Panel_hasta_2017.dta", replace
	}
}	

	/*Append de todas las ciudades*/
	filelist, dir("${convertidos_fut}/FUT_Ingresos/") pat("*.dta")  save("${convertidos_fut}/FUT_Ingresos/Z_MPIOS_dta_datasets.dta") replace list norecursive maxdeep(1)		/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
	
	use "${convertidos_fut}/FUT_Ingresos/Z_MPIOS_dta_datasets.dta", clear
	local obs = _N - 1
    forvalues i = 1/`obs' {
		use "${convertidos_fut}/FUT_Ingresos/Z_MPIOS_dta_datasets.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
		local f = dirname + filename
		use "`f'", clear
		gen source2 = "`f'"
		tempfile save`i'
		save "`save`i''"
	}
	
	/*Append de TODOS los Municipio*/
	/*ESTE SEGMENTO DEBE CORRESRSE SIMULTÁNEAMENTE CON EL ANTERIOR PARA QUE FUNCIONE. ESTO YA QUE IMPLICA ARCHIVOS TEMPORALES*/
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"				
		save "${convertidos_fut}/FUT_Ingresos/Z_PANELES/PANEL_INGRESOS/TEMP_Panel_ingresos_hasta_2017.dta", replace
	}
	
/*Asignando los codigos de los municipios al panel de datos*/
		use "${convertidos_fut}/FUT_Ingresos/Z_PANELES/PANEL_INGRESOS/TEMP_Panel_ingresos_hasta_2017.dta", clear
		
		gen cod_dane = 91001 if mpio == "Leticia"
		replace cod_dane = 5001 if mpio == "Medellín"
		replace cod_dane = 81001 if mpio == "Arauca"
		replace cod_dane = 8001 if mpio == "Barranquilla"
		replace cod_dane = 13001 if mpio == "Cartagena"
		replace cod_dane = 15001 if mpio == "Tunja"
		replace cod_dane = 17001 if mpio == "Manizales"
		replace cod_dane = 18001 if mpio == "Florencia"
		replace cod_dane = 85001 if mpio == "Yopal"
		replace cod_dane = 19001 if mpio == "Popayán"
		replace cod_dane = 20001 if mpio == "Valledupar"
		replace cod_dane = 27001 if mpio == "Quibdó"
		replace cod_dane = 23001 if mpio == "Montería"
		replace cod_dane = 11001 if mpio == "Bogotá"
		replace cod_dane = 94001 if mpio == "Inírida"
		replace cod_dane = 95001 if mpio == "San José del Guaviare"
		replace cod_dane = 41001 if mpio == "Neiva"
		replace cod_dane = 44001 if mpio == "Riohacha"			
		replace cod_dane = 47001 if mpio == "Santa Marta"
		replace cod_dane = 50001 if mpio == "Villavicencio"            
		replace cod_dane = 52001 if mpio == "Pasto"
		replace cod_dane = 54001 if mpio == "Cúcuta"
		replace cod_dane = 68001 if mpio == "Bucaramanga"
		replace cod_dane = 86001 if mpio == "Mocoa"
		replace cod_dane = 63001 if mpio == "Armenia"
		replace cod_dane = 66001 if mpio == "Pereira"
		replace cod_dane = 88001 if mpio == "San Andrés"
		replace cod_dane = 70001 if mpio == "Sincelejo"
		replace cod_dane = 73001 if mpio == "Ibagué"
		replace cod_dane = 76001 if mpio == "Cali"
		replace cod_dane = 97001 if mpio == "Mitú"
		replace cod_dane = 99001 if mpio == "Puerto Carreño"
		
		drop source source2 otras_dest_doc_soporte otras_dest_nro_doc
		
		order mpio cod_dane year codigo
	
	/*GENERANDO LA VARIABLE TOTAL INGRESOS SEGÚN LOS CAMBIOS MENCIONADOS AL INICIO DE ESTA SECCIÓN*/
	/*Para la selección de la cuenta de TOTAL INGRESOS,  se debe  tomar la variable RECAUDO EFECTIVO para el año 2008,///
	porque inicialmente no existía la variable separada de RECAUDO SIN SITUACION DE FONDOS(A)///
	En el 2009 y 2010 aparece por separado la VARIABLE RECAUDO SIN SITUACIÓN DE FONDOS (A), ///
	por lo tanto se debe sumar el RECAUDO EFECTIVO con el RECAUDO SIN SITUACION DE FONDOS, para obtener el TOTAL INGRESOS, como una nueva variable.///
	A partir del 2011, se toma solo la variable TOTAL INGRESOS (B), que si aparece hasta el 2017. */
	
		gen 	total_ingresos_modif = recaudo_efectivo if year == 2008
		replace total_ingresos_modif = (recaudo_efectivo + recau_sin_situ_de_fond) if (year == 2009 | year == 2010)
		replace total_ingresos_modif = total_ingresos if year > 2010
		format 	%12.0f total_ingresos_modif
	
		save "${convertidos_fut}/FUT_Ingresos/Z_PANELES/PANEL_INGRESOS/TODOS_MPIOS_Panel_Ingresos_hasta_2017.dta", replace	
	
	
	
																		*********************************************
																		*********************************************
																		*		FUT: GASTOS DE FUNCIONAMIENTO		*
																		*				     (FUT)					*
																		*				(Inicia en 2008)			*
		
																		*********************************************
																		*********************************************
clear all
set more off, permanently
set rmsg on, permanently
		
		
*--------------------------------------*
//Directorio de trabajo y global path// 
*--------------------------------------*

*****************
* RUTA GENERAL  *
*****************
global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"


****************************************
*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
****************************************	
global originales_fut		= 	"${pc}/Data/FUT_DATOS/"
global convertidos_fut		= 	"${pc}/Data/Convertidos_FUT/"
global graficos				=	"${pc}Graficos/"
global tablas				=	"${pc}Tablas/"	


/***********************************/
/*	LECTURA DE LOS AÑOS 2008 A 2017*/
/***********************************/
/*Se leen desde Excel  y se modifica  para los formatos que se estaban leyendo como texto variables numericas.*/
/*NOTA: A CADA ARCHIVO EN STATA SE LE HARÁ.
		1. DESTRING DE LAS VARIABLES NUMÉRICAS
		2. SE INCLUIRÁ UNA NUEVA VARIABLE DE AÑO
		3. SE INCLUIRÁ UNA NUEVA VARIABLE CON EL NOMBRE DEL MUNICIPIO*/

set trace on
set tracedepth 1
		
global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" "Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 

foreach a of global capitales {
	forvalues b = 2008/2017 {
		capture confirm file "${originales_fut}Fut_Gastos_Funcionamiento/`a'/`b'.xls"
			if _rc == 0    { 
			import excel using "${originales_fut}Fut_Gastos_Funcionamiento/`a'/`b'.xls", clear sheet("reporte pag 1") firstrow cellrange(A10) case(lower)
			 
			ds 		/*lists variable names of the dataset currently in memory in a compact or detailed format, and lets you specify subsets of variables to be listed, either by name or by properties (for
					example, the variables are numeric).  In addition, ds leaves behind in r(varlist) the names of variables selected so that you can use them in a subsequent command.*/
			 
			 foreach old_var in `r(varlist)' {
				local old_var = strtoname("`old_var'")		/*strtoname(s[,p]) Description:  s translated into a Stata 13 compatible name.  results in a name that is truncated to 32 bytes. Each character in s that is not allowed in a Stata name is converted to an underscore character, _.*/
			 }
			 destring `old_var', replace  dpcomma      /* se le hace destring a todas las variables  usando el local de todas las variables ,esto es posible solo si se coloca el comando "dpcomma" ya que hay variables que son numericas y estan en string por la coma */
		
			ds, has(type numeric)           /*se listan y se guardan las variables solo de tipo nuymerico, para despues cambiarles el formato, de no hacerse habria un error por que las variables string no se le puede aplicar formatos numericos*/

				foreach var of varlist `r(varlist)' {
				format  %15.2f `var'   
			 }
				gen year = `b'
				gen mpio = "`a'"	
			
			capture order year mpio codigo-bc 
			/*La variable unidadejecutora contiene los nombres de los niveles(sectores) de administración municipal para los cuales se reporta el gasto. Esta variable solo aparece una sola vez
			al inicio de cada nivel o sector, con la característica que las celdas vacías no corresponden a missing y no son reconocidas como tal, por lo que no permiten ejecutar el siguiente comando
			para duplicar los nombres en las siguientes celdas: replace unidadejecutora = unidadejecutora[_n-1] if missing(unidadejecutora). Por lo tanto se planteó la siguiente alternativa:*/
			 
			 capture confirm var 				unidadejecutora   /* se coloca capture confirm en esta variable, porque para el caso de leticia, ya esta nombrada, desde el archivo excel de esta manera "unidad_ejecutora"*/ 
				if !_rc {
				rename unidadejecutora				unidad_ejecutora
				}

			gen unidad_ejecutora_temp str50 = ""
			gen temp = strpos(unidad_ejecutora, "C")			/*Esto genera una variable temp con el conteo del número de veces que aparece la letra "C" en cada celda (esta u otra que se repita en todos los textos). 
															Esto para reconocer las celdas vacías de unidadejecutora y poder aplicarle el condicional*/
			replace unidad_ejecutora_temp = unidad_ejecutora if temp != 0
			replace unidad_ejecutora_temp = unidad_ejecutora_temp[_n-1] if missing(unidad_ejecutora_temp)
			drop temp unidad_ejecutora
			rename unidad_ejecutora_temp unidad_ejecutora
			order mpio year unidad_ejecutora
			
			save "${convertidos_fut}/FUT_Gastos_Funcionamiento/`a'/`a'_`b'.dta", replace 
		}
	}
}


/*Antes de realizar el Append, debemos pasar los datos del año 2017 para cada municipio a miles de pesos, y cambiar el nombre de las variables*/
	
global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 	
foreach a of global capitales {
	use "${convertidos_fut}/FUT_Gastos_Funcionamiento/`a'/`a'_2017.dta" , clear 	

		
		gen presupuestoinicialmiles		= 	[presupuestoinicialpesos/1000] 
		gen presupuestodefinitivomiles  =	[presupuestodefinitivopesos/1000]
		gen compromisosmiles			=   [compromisospesos/1000]
		gen obligacionesmiles			=   [obligacionespesos/1000]
		gen pagosmiles					=   [pagospesos/1000]
		
		/*Renombrando las variables*/
		
		rename presupuestoinicialmiles		presup_inicial	
		rename presupuestodefinitivomiles	presup_definitivo
		rename compromisosmiles				compromisos
		rename obligacionesmiles			obligaciones
		rename pagosmiles					pagos 
		rename fuentesderecursos			fuentes_recursos
		
								
			/*Etiquetado*/
		lab var presup_inicial 					"Presupuesto inicial(miles)"
		lab var presup_definitivo				"Presupuesto definitivo(miles)"
		lab var compromisos 					"Compromisos(miles)"
		lab var obligaciones 					"Obligaciones(miles)"
		lab var pagos							"Pagos(miles)"
		lab var fuentes_recursos				"Fuentes de recursos"
		
		drop presupuestoinicialpesos presupuestodefinitivopesos compromisospesos obligacionespesos pagospesos 
		
		order year mpio unidad_ejecutora codigo nombre fuentes_recursos nombre presup_inicial presup_definitivo 
	
		save "${convertidos_fut}FUT_Gastos_Funcionamiento/`a'/`a'_2017.dta", replace 
 }
 
	

/*Preparando y organizando variables del 2008 al 2016*/
foreach a of global capitales {
	forvalues b = 2008/2016 {
	
		capture confirm file "${convertidos_fut}FUT_Gastos_Funcionamiento/`a'/`a'_`b'.dta" 
		if _rc == 0    { 
		use "${convertidos_fut}FUT_Gastos_Funcionamiento/`a'/`a'_`b'.dta" , clear
		
		rename presupuestoinicialmiles		presup_inicial	
		rename presupuestodefinitivomiles	presup_definitivo
		rename compromisosmiles				compromisos
		rename obligacionesmiles			obligaciones
		rename pagosmiles					pagos 
		rename fuentesderecursos			fuentes_recursos
		
		/*Etiquetado*/
		lab var presup_inicial 					"Presupuesto inicial(miles)"
		lab var presup_definitivo				"Presupuesto definitivo(miles)"
		lab var compromisos 					"Compromisos(miles)"
		lab var obligaciones 					"Obligaciones(miles)"
		lab var pagos							"Pagos(miles)"
		lab var fuentes_recursos				"Fuentes de recursos"
		
		order year mpio unidad_ejecutora codigo nombre fuentes_recursos nombre presup_inicial presup_definitivo 

		save "${convertidos_fut}FUT_Gastos_Funcionamiento/`a'/`a'_`b'.dta", replace 	
		
		}
	}
}

set trace on 
set tracedepth 1
	
/****************************************************/
/*	2.	HACIENDO APPEND DE LAS CIUDADES Y AÑOS		*/
/****************************************************/

global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
foreach a of global capitales {
	*local files: dir "${convertidos_fut/FUT_Gastos_Funcionamiento}`a'/" files "*.dta"			/*Ubica le ruta en donde se encuentran los archivos con extensión dta*/
	*display `"$files"'																	/*Muestra el nombre de cada uno de los archivos ubicados en el comando anterior*/
	*tokenize `"$files"'																/*tokenize divides string into tokens, storing the result in `1', `2', ... (the positional local macros*/
	
	filelist, dir("${convertidos_fut}/FUT_Gastos_Funcionamiento/`a'/") pat("*.dta")  save("${convertidos_fut}/FUT_Gastos_Funcionamiento/`a'/z_dta_datasets_`a'.dta") replace 			/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
																														/*Se antedecede con z para que quede en el último lugar en la carpeta de archivos y en la numeración.*/
	use "${convertidos_fut}/FUT_Gastos_Funcionamiento/`a'/z_dta_datasets_`a'.dta", clear
    gen count 	= _n   
	gen obs		= _N - 1		/*Se resta 1 para que no cuente el último archivo que inicia con z, que es el que corresponde a la descripción de los archivos*/
	save "${convertidos_fut}/FUT_Gastos_Funcionamiento/`a'/z_dta_datasets_`a'.dta", replace
	
	 local obs = _N - 1
     forvalues i = 1/`obs' {
		use "${convertidos_fut}/FUT_Gastos_Funcionamiento/`a'/z_dta_datasets_`a'.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
			local f = dirname + "/" + filename
			use "`f'", clear
			gen source = "`f'"
			tempfile save`i'
			save "`save`i''"
	}

	/*Append de los Años para cada Municipio*/	 
	display " ---------------`a'_completo----------------------"
	
	use "`save1'", clear
	
	forvalues i=2/`obs' {
		append using "`save`i''"
		
		order mpio year 
				
		capture drop ai ai aj ak al am an ao ap aq ar as at au av aw ax ay az ba bb bc
		
		save "${convertidos_fut}/FUT_Gastos_Funcionamiento/`a'_Panel_hasta_2017.dta", replace
	}
}	

	/*Append de todas las ciudades*/
	filelist, dir("${convertidos_fut}/FUT_Gastos_Funcionamiento/") pat("*.dta")  save("${convertidos_fut}/FUT_Gastos_Funcionamiento/Z_MPIOS_dta_datasets.dta") replace list norecursive maxdeep(1)		/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
	
	use "${convertidos_fut}/FUT_Gastos_Funcionamiento/Z_MPIOS_dta_datasets.dta", clear
	local obs = _N - 1
    forvalues i = 1/`obs' {
		use "${convertidos_fut}/FUT_Gastos_Funcionamiento/Z_MPIOS_dta_datasets.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
		local f = dirname + filename
		use "`f'", clear
		gen source2 = "`f'"
		tempfile save`i'
		save "`save`i''"
	}
	
	/*Append de TODOS los Municipio*/
	/*ESTE SEGMENTO DEBE CORRESRSE SIMULTÁNEAMENTE CON EL ANTERIOR PARA QUE FUNCIONE. ESTO YA QUE IMPLICA ARCHIVOS TEMPORALES*/
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"			
		save "${convertidos_fut}/FUT_Gastos_Funcionamiento/Z_PANELES/PANEL_GASTOS_FUNCIONAMIENTO/TEMP_Panel_gastos_funcionamiento_hasta_2017.dta", replace
	}
		
/*Asignando los codigos de los municipios al panel de datos*/
		use  "${convertidos_fut}/FUT_Gastos_Funcionamiento/Z_PANELES/PANEL_GASTOS_FUNCIONAMIENTO/TEMP_Panel_gastos_funcionamiento_hasta_2017.dta", clear		
		
		gen cod_dane = 91001 if mpio == "Leticia"
		replace cod_dane = 5001 if mpio == "Medellín"
		replace cod_dane = 81001 if mpio == "Arauca"
		replace cod_dane = 8001 if mpio == "Barranquilla"
		replace cod_dane = 13001 if mpio == "Cartagena"
		replace cod_dane = 15001 if mpio == "Tunja"
		replace cod_dane = 17001 if mpio == "Manizales"
		replace cod_dane = 18001 if mpio == "Florencia"
		replace cod_dane = 85001 if mpio == "Yopal"
		replace cod_dane = 19001 if mpio == "Popayán"
		replace cod_dane = 20001 if mpio == "Valledupar"
		replace cod_dane = 27001 if mpio == "Quibdó"
		replace cod_dane = 23001 if mpio == "Montería"
		replace cod_dane = 11001 if mpio == "Bogotá"
		replace cod_dane = 94001 if mpio == "Inírida"
		replace cod_dane = 95001 if mpio == "San José del Guaviare"
		replace cod_dane = 41001 if mpio == "Neiva"
		replace cod_dane = 44001 if mpio == "Riohacha"			
		replace cod_dane = 47001 if mpio == "Santa Marta"
		replace cod_dane = 50001 if mpio == "Villavicencio"            
		replace cod_dane = 52001 if mpio == "Pasto"
		replace cod_dane = 54001 if mpio == "Cúcuta"
		replace cod_dane = 68001 if mpio == "Bucaramanga"
		replace cod_dane = 86001 if mpio == "Mocoa"
		replace cod_dane = 63001 if mpio == "Armenia"
		replace cod_dane = 66001 if mpio == "Pereira"
		replace cod_dane = 88001 if mpio == "San Andrés"
		replace cod_dane = 70001 if mpio == "Sincelejo"
		replace cod_dane = 73001 if mpio == "Ibagué"
		replace cod_dane = 76001 if mpio == "Cali"
		replace cod_dane = 97001 if mpio == "Mitú"
		replace cod_dane = 99001 if mpio == "Puerto Carreño"
		
		drop source source2 
		order mpio cod_dane year 
		
		save "${convertidos_fut}/FUT_Gastos_Funcionamiento/Z_PANELES/PANEL_GASTOS_FUNCIONAMIENTO/TODOS_MPIOS_Panel_Gastos_Funcionamiento_hasta_2017.dta", replace		
													
	
		
			
																		*********************************************
																		*********************************************
																		*		FUT: GASTOS DE INVERSION 			*
																		*				     (FUT)					*
																		*				(Inicia en 2008)			*
		
																		*********************************************
																		*********************************************
		
clear all
set more off, permanently
set rmsg on, permanently
		
		
*--------------------------------------*
//Directorio de trabajo y global path// 
*--------------------------------------*

*****************
* RUTA GENERAL  *
*****************
global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

****************************************
*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
****************************************	
global originales_fut		= 	"${pc}/Data/FUT_DATOS/"
global convertidos_fut		= 	"${pc}/Data/Convertidos_FUT/"
global graficos				=	"${pc}Graficos/"
global tablas				=	"${pc}Tablas/"	


/***********************************/
/*	LECTURA DE LOS AÑOS 2008 A 2017*/
/***********************************/
/*Se leen desde Excel  y se modifica  para los formatos que se estaban leyendo como texto variables numericas.*/
/*NOTA: A CADA ARCHIVO EN STATA SE LE HARÁ.
		1. DESTRING DE LAS VARIABLES NUMÉRICAS
		2. SE INCLUIRÁ UNA NUEVA VARIABLE DE AÑO
		3. SE INCLUIRÁ UNA NUEVA VARIABLE CON EL NOMBRE DEL MUNICIPIO*/

set trace on
set tracedepth 1
		
global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" "Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 

foreach a of global capitales {
	forvalues b = 2008/2017 {
		capture confirm file "${originales_fut}Fut_Gastos_Inversion/`a'/`b'.xls"
			if _rc == 0    { 
			import excel using "${originales_fut}Fut_Gastos_Inversion/`a'/`b'.xls", clear sheet("reporte pag 1") firstrow cellrange(A10) case(lower)
			 
			ds 		/*lists variable names of the dataset currently in memory in a compact or detailed format, and lets you specify subsets of variables to be listed, either by name or by properties (for
					example, the variables are numeric).  In addition, ds leaves behind in r(varlist) the names of variables selected so that you can use them in a subsequent command.*/
			 
			 foreach old_var in `r(varlist)' {
				local old_var = strtoname("`old_var'")		/*strtoname(s[,p]) Description:  s translated into a Stata 13 compatible name.  results in a name that is truncated to 32 bytes. Each character in s that is not allowed in a Stata name is converted to an underscore character, _.*/
			 }
			 destring `old_var', replace  dpcomma      /* se le hace destring a todas las variables  usando el local de todas las variables ,esto es posible solo si se coloca el comando "dpcomma" ya que hay variables que son numericas y estan en string por la coma */
		
			ds, has(type numeric)           /*se listan y se guardan las variables solo de tipo nuymerico, para despues cambiarles el formato, de no hacerse habria un error por que las variables string no se le puede aplicar formatos numericos*/

				foreach var of varlist `r(varlist)' {
				format  %15.2f `var'   
			 }
				gen year = `b'
				gen mpio = "`a'"	
			
			capture order year mpio codigo-bc 
			
			save "${convertidos_fut}FUT_Gastos_Inversion/`a'/`a'_`b'.dta", replace 
		}
	}
}
/*Antes de realizar el Append, debemos pasar los datos del año 2017 para cada municipio a miles de pesos, y cambiar el nombre de las variables*/
	
global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 	
foreach a of global capitales {
	use "${convertidos_fut}FUT_Gastos_Inversion/`a'/`a'_2017.dta" , clear 	
		
		gen presupuestoinicialmiles		= 	[presupuestoinicialpesos/1000] 
		gen presupuestodefinitivomiles  =	[presupuestodefinitivopesos/1000]
		gen compromisosmiles			=   [compromisospesos/1000]
		gen totalobligacionesmiles		=   [totalobligacionespesos/1000]
		gen pagosmiles					=   [pagospesos/1000]
		
		/*Renombrando las variables*/
		rename presupuestoinicialmiles		presup_inicial	
		rename presupuestodefinitivomiles	presup_definitivo
		rename compromisosmiles				compromisos
		rename totalobligacionesmiles		obligaciones
		rename pagosmiles					pagos 
		rename fuentesdefinanciacion		fuentes_de_financiacion

		/*Etiquetado*/
		lab var presup_inicial 				"Presupuesto inicial(miles)"
		lab var presup_definitivo			"Presupuesto definitivo(miles)"
		lab var compromisos 				"Compromisos(miles)"
		lab var obligaciones 				"Total obligaciones(miles)"
		lab var pagos						"Pagos(miles)"
		lab var fuentes_de_financiacion		"Fuentes de financiación"
		
		drop presupuestoinicialpesos presupuestodefinitivopesos compromisospesos totalobligacionespesos pagospesos 
		
		order mpio year codigo nombre 
	
		save "${convertidos_fut}FUT_Gastos_Inversion/`a'/`a'_2017.dta", replace 
 }
 

/*Preparando y organizando variables del 2008 al 2016*/
foreach a of global capitales {
	forvalues b = 2008/2016 {
	
		capture confirm file "${convertidos_fut}FUT_Gastos_Inversion/`a'/`a'_`b'.dta" 
		if _rc == 0    { 
		use "${convertidos_fut}FUT_Gastos_Inversion/`a'/`a'_`b'.dta" , clear
		
		/*Renombrando las variables*/
		rename presupuestoinicialmiles			presup_inicial	
		rename presupuestodefinitivomiles		presup_definitivo
		rename compromisosmiles					compromisos
		rename totalobligacionesmiles			obligaciones
		rename pagosmiles						pagos 
		rename fuentesdefinanciacion			fuentes_de_financiacion
								
		/*Etiquetado*/
		lab var presup_inicial 					"Presupuesto inicial(miles)"
		lab var presup_definitivo				"Presupuesto definitivo(miles)"
		lab var compromisos 					"Compromisos(miles)"
		lab var obligaciones 					"Total obligaciones(miles)"
		lab var pagos							"Pagos(miles)"
		lab var fuentes_de_financiacion			"Fuentes de financiación"
		
		order year mpio codigo nombre fuentes_de_financiacion presup_inicial presup_definitivo 

		save "${convertidos_fut}FUT_Gastos_Inversion/`a'/`a'_`b'.dta", replace 	
		
		}
	}
}

	
/****************************************************/
/*	2.	HACIENDO APPEND DE LAS CIUDADES Y AÑOS		*/
/****************************************************/
set trace on 		/*Traces the execution of programs for debugging*/
set tracedepth 1	/*specifies how many levels to descend in tracing nested programs.  The default is 32000, which is equivalent to infinity*/

global capitales 		= 	`""Leticia" "Medellín" "Arauca" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
foreach a of global capitales {
	*local files: dir "${convertidos_fut/FUT_Gastos_Inversion}`a'/" files "*.dta"		/*Ubica le ruta en donde se encuentran los archivos con extensión dta*/
	*display `"$files"'																	/*Muestra el nombre de cada uno de los archivos ubicados en el comando anterior*/
	*tokenize `"$files"'																/*tokenize divides string into tokens, storing the result in `1', `2', ... (the positional local macros*/
	
	filelist, dir("${convertidos_fut}FUT_Gastos_Inversion/`a'/") pat("*.dta")  save("${convertidos_fut}/FUT_Gastos_Inversion/`a'/z_dta_datasets_`a'.dta") replace 			/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
																														/*Se antedecede con z para que quede en el último lugar en la carpeta de archivos y en la numeración.*/
	use "${convertidos_fut}FUT_Gastos_Inversion/`a'/z_dta_datasets_`a'.dta", clear
    gen count 	= _n   
	gen obs		= _N - 1		/*Se resta 1 para que no cuente el último archivo que inicia con z, que es el que corresponde a la descripción de los archivos*/
	save "${convertidos_fut}FUT_Gastos_Inversion/`a'/z_dta_datasets_`a'.dta", replace
	
	 local obs = _N - 1
     forvalues i = 1/`obs' {
		use "${convertidos_fut}FUT_Gastos_Inversion/`a'/z_dta_datasets_`a'.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
			local f = dirname + "/" + filename
			use "`f'", clear
			gen source = "`f'"
			tempfile save`i'
			save "`save`i''"
	}

	/*Append de los Años para cada Municipio*/	 
	display " ---------------`a'_completo----------------------"
	
	use "`save1'", clear
	
	forvalues i=2/`obs' {
		append using "`save`i''"
				
		sort year codigo
		
		capture drop ai ai aj ak al am an ao ap aq ar as at au av aw ax ay az ba bb bc
		
		save "${convertidos_fut}FUT_Gastos_Inversion/`a'_Panel_hasta_2017.dta", replace
	}
}	

	/*Append de todas las ciudades*/
	filelist, dir("${convertidos_fut}FUT_Gastos_Inversion/") pat("*.dta")  save("${convertidos_fut}/FUT_Gastos_Inversion/Z_MPIOS_dta_datasets.dta") replace list norecursive maxdeep(1)		/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
	
	use "${convertidos_fut}FUT_Gastos_Inversion/Z_MPIOS_dta_datasets.dta", clear
	local obs = _N - 1
    forvalues i = 1/`obs' {
		use "${convertidos_fut}FUT_Gastos_Inversion/Z_MPIOS_dta_datasets.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
		local f = dirname + filename
		use "`f'", clear
		gen source2 = "`f'"
		tempfile save`i'
		save "`save`i''"
	}
	
	/*Append de TODOS los Municipio*/
	/*ESTE SEGMENTO DEBE CORRESRSE SIMULTÁNEAMENTE CON EL ANTERIOR PARA QUE FUNCIONE. ESTO YA QUE IMPLICA ARCHIVOS TEMPORALES*/
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"
		*drop pesos				
		save "${convertidos_fut}FUT_Gastos_Inversion/Z_PANELES/PANEL_GASTOS_INVERSION/TEMP_Panel_gastos_inversion_hasta_2017.dta", replace
	}
		
/*Asignando los codigos de los municipios al panel de datos*/
		use  "${convertidos_fut}FUT_Gastos_Inversion/Z_PANELES/PANEL_GASTOS_INVERSION/TEMP_Panel_gastos_inversion_hasta_2017.dta", clear		
		
		gen cod_dane = 91001 if mpio == "Leticia"
		replace cod_dane = 5001 if mpio == "Medellín"
		replace cod_dane = 81001 if mpio == "Arauca"
		replace cod_dane = 8001 if mpio == "Barranquilla"
		replace cod_dane = 13001 if mpio == "Cartagena"
		replace cod_dane = 15001 if mpio == "Tunja"
		replace cod_dane = 17001 if mpio == "Manizales"
		replace cod_dane = 18001 if mpio == "Florencia"
		replace cod_dane = 85001 if mpio == "Yopal"
		replace cod_dane = 19001 if mpio == "Popayán"
		replace cod_dane = 20001 if mpio == "Valledupar"
		replace cod_dane = 27001 if mpio == "Quibdó"
		replace cod_dane = 23001 if mpio == "Montería"
		replace cod_dane = 11001 if mpio == "Bogotá"
		replace cod_dane = 94001 if mpio == "Inírida"
		replace cod_dane = 95001 if mpio == "San José del Guaviare"
		replace cod_dane = 41001 if mpio == "Neiva"
		replace cod_dane = 44001 if mpio == "Riohacha"			
		replace cod_dane = 47001 if mpio == "Santa Marta"
		replace cod_dane = 50001 if mpio == "Villavicencio"            
		replace cod_dane = 52001 if mpio == "Pasto"
		replace cod_dane = 54001 if mpio == "Cúcuta"
		replace cod_dane = 68001 if mpio == "Bucaramanga"
		replace cod_dane = 86001 if mpio == "Mocoa"
		replace cod_dane = 63001 if mpio == "Armenia"
		replace cod_dane = 66001 if mpio == "Pereira"
		replace cod_dane = 88001 if mpio == "San Andrés"
		replace cod_dane = 70001 if mpio == "Sincelejo"
		replace cod_dane = 73001 if mpio == "Ibagué"
		replace cod_dane = 76001 if mpio == "Cali"
		replace cod_dane = 97001 if mpio == "Mitú"
		replace cod_dane = 99001 if mpio == "Puerto Carreño"
		
		drop source source2 
		
		order mpio cod_dane year codigo nombre
		
		save "${convertidos_fut}FUT_Gastos_Inversion/Z_PANELES/PANEL_GASTOS_INVERSION/TODOS_MPIOS_Panel_Gastos_Inversion_hasta_2017.dta", replace		
	
		
		
																		*********************************************
																		*********************************************
																		*		FUT: SERVICIO DE LA DEUDA			*
																		*				     (FUT)					*
																		*				(Inicia en 2008)			*
																		*********************************************
																		*********************************************
		
clear all
set more off, permanently
set rmsg on, permanently
		
*--------------------------------------*
//Directorio de trabajo y global path// 
*--------------------------------------*

*****************
* RUTA GENERAL  *
*****************
global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

****************************************
*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
****************************************	
global originales_fut		= 	"${pc}/Data/FUT_DATOS/"
global convertidos_fut		= 	"${pc}/Data/Convertidos_FUT/"
global graficos				=	"${pc}Graficos/"
global tablas				=	"${pc}Tablas/"	


/***********************************/
/*	LECTURA DE LOS AÑOS 2008 A 2017*/
/***********************************/
/*Se leen desde Excel  y se modifica  para los formatos que se estaban leyendo como texto variables numericas.*/
/*NOTA: A CADA ARCHIVO EN STATA SE LE HARÁ.
		1. DESTRING DE LAS VARIABLES NUMÉRICAS
		2. SE INCLUIRÁ UNA NUEVA VARIABLE DE AÑO
		3. SE INCLUIRÁ UNA NUEVA VARIABLE CON EL NOMBRE DEL MUNICIPIO*/

/*NOTA: No se incluye dentro del global capitales a "Arauca", porque no se reportan datos. */	
		
set trace on
set tracedepth 1
	
global capitales 	= 	`""Leticia" "Medellín"  "Barranquilla" "Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 

foreach a of global capitales {
	forvalues b = 2008/2017 {
		capture confirm file "${originales_fut}Fut_Servicio_Deuda/`a'/`b'.xls"
			if _rc == 0    { 
			import excel using "${originales_fut}Fut_Servicio_Deuda/`a'/`b'.xls", clear sheet("reporte pag 1") firstrow cellrange(A10) case(lower)
			 
			ds 		/*lists variable names of the dataset currently in memory in a compact or detailed format, and lets you specify subsets of variables to be listed, either by name or by properties (for
					example, the variables are numeric).  In addition, ds leaves behind in r(varlist) the names of variables selected so that you can use them in a subsequent command.*/
			 
			 foreach old_var in `r(varlist)' {
				local old_var = strtoname("`old_var'")		/*strtoname(s[,p]) Description:  s translated into a Stata 13 compatible name.  results in a name that is truncated to 32 bytes. Each character in s that is not allowed in a Stata name is converted to an underscore character, _.*/
			 }
			 destring `old_var', replace  dpcomma      /* se le hace destring a todas las variables  usando el local de todas las variables ,esto es posible solo si se coloca el comando "dpcomma" ya que hay variables que son numericas y estan en string por la coma */
		
			ds, has(type numeric)           /*se listan y se guardan las variables solo de tipo nuymerico, para despues cambiarles el formato, de no hacerse habria un error por que las variables string no se le puede aplicar formatos numericos*/

				foreach var of varlist `r(varlist)' {
				format  %15.2f `var'   
			 }
				gen year = `b'
				gen mpio = "`a'"	
			
			capture order year mpio codigo-bc 
			
			save "${convertidos_fut}FUT_Servicio_Deuda/`a'/`a'_`b'.dta", replace 
		}
	}
}
/*Antes de realizar el Append, debemos pasar los datos del año 2017 para cada municipio a miles de pesos, y cambiar el nombre de las variables*/

global capitales 		= 	`""Leticia" "Medellín"  "Barranquilla" "Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 	
foreach a of global capitales {
	use "${convertidos_fut}FUT_Servicio_Deuda/`a'/`a'_2017.dta" , clear 	
		
		gen presupuestoinicialmiles		= 	[presupuestoinicialpesos/1000] 
		gen presupuestodefinitivomiles  =	[presupuestodefinitivopesos/1000]
		gen compromisosmiles			=   [compromisospesos/1000]
		gen obligacionesmiles			=   [obligacionespesos/1000]
		gen pagosmiles					=   [pagospesos/1000]
		
		/*Renombrando las variables*/
		
		rename presupuestoinicialmiles		presup_inicial	
		rename presupuestodefinitivomiles	presup_definitivo
		rename compromisosmiles				compromisos
		rename obligacionesmiles			obligaciones
		rename pagosmiles					pagos 
		rename fuentederecursos				fuente_de_recursos
		rename tipodedeuda					tipo_de_deuda
		rename tipodeoperación				tipo_de_operacion
					
			/*Etiquetado*/
		lab var presup_inicial 				"Presupuesto inicial(miles)"
		lab var presup_definitivo			"Presupuesto definitivo(miles)"
		lab var compromisos 				"Compromisos(miles)"
		lab var obligaciones 				"Obligaciones(miles)"
		lab var pagos						"Pagos(miles)"
		
		drop presupuestoinicialpesos presupuestodefinitivopesos compromisospesos obligacionespesos pagospesos 
		order year mpio codigo nombre tipo_de_deuda-pagos
		
		save "${convertidos_fut}FUT_Servicio_Deuda/`a'/`a'_2017.dta", replace 
 }
 

/*Preparando y organizando variables del 2008 al 2016*/
foreach a of global capitales {
	forvalues b = 2008/2016 {
	
		capture confirm file "${convertidos_fut}FUT_Servicio_Deuda/`a'/`a'_`b'.dta" 
		if _rc == 0    { 
		use "${convertidos_fut}FUT_Servicio_Deuda/`a'/`a'_`b'.dta" , clear
		
		/*Renombrando las variables*/
		
		rename presupuestoinicialmiles		presup_inicial	
		rename presupuestodefinitivomiles	presup_definitivo
		rename compromisosmiles				compromisos
		rename obligacionesmiles			obligaciones
		rename pagosmiles					pagos 
		rename fuentederecursos				fuente_de_recursos
		rename tipodedeuda					tipo_de_deuda
		rename tipodeoperación				tipo_de_operacion
					
			/*Etiquetado*/
		lab var presup_inicial 				"Presupuesto inicial(miles)"
		lab var presup_definitivo			"Presupuesto definitivo(miles)"
		lab var compromisos 				"Compromisos(miles)"
		lab var obligaciones 				"Obligaciones(miles)"
		lab var pagos						"Pagos(miles)"
		
		order year mpio codigo nombre tipo_de_deuda-pagos
		
		save "${convertidos_fut}FUT_Servicio_Deuda/`a'/`a'_`b'.dta", replace 	
		
		}
	}
}

	
/****************************************************/
/*	2.	HACIENDO APPEND DE LAS CIUDADES Y AÑOS		*/
/****************************************************/
set trace on 
set tracedepth 1

global capitales 		= 	`""Leticia" "Medellín" "Barranquilla" 	"Cartagena" "Tunja" "Manizales" "Florencia" "Yopal" "Popayán" "Valledupar" "Quibdó" "Montería" "Bogotá" "Inírida" "San José del Guaviare" "Neiva" "Riohacha" "Santa Marta" "Villavicencio" "Pasto" "Cúcuta" "Mocoa" "Armenia" "Pereira" "San Andrés" "Bucaramanga" "Sincelejo" "Ibagué" "Cali" "Mitú" "Puerto Carreño""'		 
	
foreach a of global capitales {
	*local files: dir "${convertidos_fut/FUT_Servicio_Deuda}`a'/" files "*.dta"			/*Ubica le ruta en donde se encuentran los archivos con extensión dta*/
	*display `"$files"'																	/*Muestra el nombre de cada uno de los archivos ubicados en el comando anterior*/
	*tokenize `"$files"'																/*tokenize divides string into tokens, storing the result in `1', `2', ... (the positional local macros*/
	
	filelist, dir("${convertidos_fut}/FUT_Servicio_Deuda/`a'/") pat("*.dta")  save("${convertidos_fut}/FUT_Servicio_Deuda/`a'/z_dta_datasets_`a'.dta") replace 			/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
																														/*Se antedecede con z para que quede en el último lugar en la carpeta de archivos y en la numeración.*/
	use "${convertidos_fut}/FUT_Servicio_Deuda/`a'/z_dta_datasets_`a'.dta", clear
    gen count 	= _n   
	gen obs		= _N - 1		/*Se resta 1 para que no cuente el último archivo que inicia con z, que es el que corresponde a la descripción de los archivos*/
	save "${convertidos_fut}/FUT_Servicio_Deuda/`a'/z_dta_datasets_`a'.dta", replace
	
	 local obs = _N - 1
     forvalues i = 1/`obs' {
		use "${convertidos_fut}/FUT_Servicio_Deuda/`a'/z_dta_datasets_`a'.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
			local f = dirname + "/" + filename
			use "`f'", clear
			gen source = "`f'"
			tempfile save`i'
			save "`save`i''"
	}

	/*Append de los Años para cada Municipio*/	 
	display " ---------------`a'_completo----------------------"
	
	use "`save1'", clear
	
	forvalues i=2/`obs' {
		append using "`save`i''"
				
		sort year codigo
		
		capture drop ai ai aj ak al am an ao ap aq ar as at au av aw ax ay az ba bb bc
		
		save "${convertidos_fut}/FUT_Servicio_Deuda/`a'_Panel_hasta_2017.dta", replace
	}
}	

	/*Append de todas las ciudades*/
	filelist, dir("${convertidos_fut}/FUT_Servicio_Deuda/") pat("*.dta")  save("${convertidos_fut}/FUT_Servicio_Deuda/Z_MPIOS_dta_datasets.dta") replace list norecursive maxdeep(1)		/*El comando filelist debe instalarse a través de: ssc install filelist este comando hace un listado y crea un archivo dta con cada uno de los archivos de las carpetas.*/
	
	use "${convertidos_fut}/FUT_Gastos_Inversion/Z_MPIOS_dta_datasets.dta", clear
	local obs = _N - 1
    forvalues i = 1/`obs' {
		use "${convertidos_fut}/FUT_Servicio_Deuda/Z_MPIOS_dta_datasets.dta" in `i', clear		/*De cada archivo va tomando cada observaciion que tiene informacion del nombre del directorio, del archivo, etc.*/
		local f = dirname + filename
		use "`f'", clear
		gen source2 = "`f'"
		tempfile save`i'
		save "`save`i''"
	}
	
	/*Append de TODOS los Municipio*/
	/*ESTE SEGMENTO DEBE CORRESRSE SIMULTÁNEAMENTE CON EL ANTERIOR PARA QUE FUNCIONE. ESTO YA QUE IMPLICA ARCHIVOS TEMPORALES*/
	use "`save1'", clear
	forvalues i=2/`obs' {
		append using "`save`i''"
		*drop pesos				
		save "${convertidos_fut}FUT_Servicio_Deuda/Z_PANELES/PANEL_SERVICIO_DEUDA/TEMP_Panel_Servicio_Deuda_hasta_2017.dta", replace
	}
		
/*Asignando los codigos de los municipios al panel de datos*/
		use  "${convertidos_fut}FUT_Servicio_Deuda/Z_PANELES/PANEL_SERVICIO_DEUDA/TEMP_Panel_Servicio_Deuda_hasta_2017.dta", clear		
		
		gen cod_dane = 91001 if mpio == "Leticia"
		replace cod_dane = 5001 if mpio == "Medellín"
		replace cod_dane = 81001 if mpio == "Arauca"
		replace cod_dane = 8001 if mpio == "Barranquilla"
		replace cod_dane = 13001 if mpio == "Cartagena"
		replace cod_dane = 15001 if mpio == "Tunja"
		replace cod_dane = 17001 if mpio == "Manizales"
		replace cod_dane = 18001 if mpio == "Florencia"
		replace cod_dane = 85001 if mpio == "Yopal"
		replace cod_dane = 19001 if mpio == "Popayán"
		replace cod_dane = 20001 if mpio == "Valledupar"
		replace cod_dane = 27001 if mpio == "Quibdó"
		replace cod_dane = 23001 if mpio == "Montería"
		replace cod_dane = 11001 if mpio == "Bogotá"
		replace cod_dane = 94001 if mpio == "Inírida"
		replace cod_dane = 95001 if mpio == "San José del Guaviare"
		replace cod_dane = 41001 if mpio == "Neiva"
		replace cod_dane = 44001 if mpio == "Riohacha"			
		replace cod_dane = 47001 if mpio == "Santa Marta"
		replace cod_dane = 50001 if mpio == "Villavicencio"            
		replace cod_dane = 52001 if mpio == "Pasto"
		replace cod_dane = 54001 if mpio == "Cúcuta"
		replace cod_dane = 68001 if mpio == "Bucaramanga"
		replace cod_dane = 86001 if mpio == "Mocoa"
		replace cod_dane = 63001 if mpio == "Armenia"
		replace cod_dane = 66001 if mpio == "Pereira"
		replace cod_dane = 88001 if mpio == "San Andrés"
		replace cod_dane = 70001 if mpio == "Sincelejo"
		replace cod_dane = 73001 if mpio == "Ibagué"
		replace cod_dane = 76001 if mpio == "Cali"
		replace cod_dane = 97001 if mpio == "Mitú"
		replace cod_dane = 99001 if mpio == "Puerto Carreño" 
		
		drop source source2 filename dirname fsize
		order mpio cod_dane year codigo nombre
		save "${convertidos_fut}FUT_Servicio_Deuda/Z_PANELES/PANEL_SERVICIO_DEUDA/TODOS_MPIOS_Panel_servicio_deuda_hasta_2017.dta", replace		
	

	
																		*********************************************
																		*********************************************
																		*	BASE OPERACIONES EFECTIVAS DE CAJA		*
																		*				  (DANE)					*
																		*				(2000 - 2016)				*
																		*********************************************
																		*********************************************
		
	clear all
	set more off, permanently
	set rmsg on, permanently
			
	*--------------------------------------*
	//Directorio de trabajo y global path// 
	*--------------------------------------*

	*****************
	* RUTA GENERAL  *
	*****************
	global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

	****************************************
	*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
	****************************************	
	global originales_fut		= 	"${pc}/Data/FUT_DATOS/"
	global convertidos_fut		= 	"${pc}/Data/Convertidos_FUT/"
	global graficos				=	"${pc}Graficos/"
	global tablas				=	"${pc}Tablas/"	


	/***********************************/
	/*	LECTURA DE LOS AÑOS 2000 A 2016*/
	/***********************************/
				
	import excel using "${pc}Data/DNP/Operaciones_Efectivas_Caja/Base Operaciones Efectivas de Caja 2000-2016.xlsx", clear sheet("Base OEC Municipios") firstrow cellrange(G1) case(lower)
	
	/*1.1. Renombrando las columnas con los años*/
		local cols "l m n o p q r s t u v w x y z aa ab"
			local i = 2000
			foreach j of local cols {
				rename `j' _`i'
				local ++i
			}
		
	/*Luego, antes de hacer el destring a la variables numéricas, deben cambiarse los N.D. que aperecn en algunas variables y que impedirían hacer el destring*/
	
	/*1.2. Convirtiendo a Missing los "N.D.# y los "2"*/		
		foreach x of varlist _2000-_2016 {
			capture replace `x' = ""  if `x' == "N.D."	| `x' == "-"		/*Se eliminan los N.D. por missing*/
		}

	/*1.3. Pasando de String a Numérico*/
		ds 		/*lists variable names of the dataset currently in memory in a compact or detailed format, and lets you specify subsets of variables to be listed, either by name or by properties (for
						example, the variables are numeric).  In addition, ds leaves behind in r(varlist) the names of variables selected so that you can use them in a subsequent command.*/
				 
		 foreach old_var in `r(varlist)' {
			local old_var = strtoname("`old_var'")		/*strtoname(s[,p]) Description:  s translated into a Stata 13 compatible name.  results in a name that is truncated to 32 bytes. Each character in s that is not allowed in a Stata name is converted to an underscore character, _.*/
		 }
		 
		 destring `old_var', replace  dpcomma      /* se le hace destring a todas las variables  usando el local de todas las variables ,esto es posible solo si se coloca el comando "dpcomma" ya que hay variables que son numericas y estan en string por la coma */
			
	/*1.4. Poniendo todas las variables en minúscula*/
		drop códigofutcgn
		rename (códigodane códigocuenta) (cod_dane cod_cuenta)
	
	/*1.5. Pasando a panel de datos*/
		/*Nota: No se puede hacer el reshape porque los identificadores de corte transversal no identifican únicamente a un solo municipio. esto porque cada 
		municipio tiene un conjunto amplio de cuentas fiscales*/
			
		/*Extraer y guardar cada año independientemente*/
		local i = 2000
		foreach x of varlist _2000-_2016 {
			preserve
				keep cod_dane municipio cod_cuenta cuenta `x' 
				gen year =  `i'				/*Se genera una variable con el año correspondiente*/
				rename `x' montos			/*Se cambia el nombre que tiene como título cada año de la información por la de "montos"*/
				local ++i
				tempfile save`x'
				save "`save`x''"
			restore
		}
		
		/*Añadiendo cada año en forma de panel de datos*/
		use "`save_2000'", clear
		forvalues j = 2001/2016 {
			append using "`save_`j''"
		}
		
		sort cod_dane year cod_cuenta
		order cod_dane municipio year cod_cuenta cuenta montos
		
		format cod_dane %05.0f 								/*Se pone un cero adelante de los códigos para que todos queden de 5 dígitos.*/
		tostring cod_dane, replace usedisplayformat			/*Covierte el codigo del municipio en String tal como aparece el valor numérico.*/
		gen cod_depto = substr(cod_dane, -5, 2)				/*Se extraen los dos primeros dígitos del código del municipio como código del departamento.*/
		order cod_depto cod_dane municipio year cod_cuenta 	/*Se orden las variables en la base de datos*/ 
		destring cod_dane, replace
		destring cod_depto, replace							/*Se convierte a texto el código del departamento. Esto para hacer el merge con la base del PIB más adelante.*/
				
		save "${pc}Data/Convertidos_Operac_Efect_Caja/Panel_Operaciones_Efectivas_Caja_Colombia_2000_2016.dta", replace
		
		
	
																		*********************************************
																		*********************************************
																		*					PIB						*
																		*				  (DANE)					*
																		*				(2000 - 2016)				*
																		*********************************************
																		*********************************************
		
	clear all
	set more off, permanently
	set rmsg on, permanently
			
	*--------------------------------------*
	//Directorio de trabajo y global path// 
	*--------------------------------------*

	*****************
	* RUTA GENERAL  *
	*****************
	global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

	****************************************
	*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
	****************************************	
	global originales_fut		= 	"${pc}/Data/FUT_DATOS/"
	global convertidos_fut		= 	"${pc}/Data/Convertidos_FUT/"
	global graficos				=	"${pc}Graficos/"
	global tablas				=	"${pc}Tablas/"	


	/***********************************/
	/*	LECTURA DE LOS AÑOS 2000 A 2016*/
	/***********************************/
		
		/*PIB a Precios Corrientes y guardando los archivos WIDE*/
		
		local deptos = "AMAZONASC ANTIOQUIAC ARAUCAC ATLANTICOC BOGOTAC BOLIVARC BOYACAC CALDASC CAQUETAC CASANAREC CAUCAC CESARC CHOCOC CORDOBAC CUNDINAMARCAC GUAINIAC GUAVIAREC HUILAC LAGUAJIRAC MAGDALENAC METAC NARIÑOC NORTEDESANTANDERC PUTUMAYOC QUINDIOC RISARALDAC SANANDRESC SANTANDERC SUCREC TOLIMAC VALLEC VAUPESC VICHADAC"
		
		foreach a of local deptos {
			import excel using "${pc}Data/DANE/PIB_Departamental/PIB_Departamentos_2016provisional.xlsx", clear sheet("`a'") cellrange(A10:R59)
			rename (A B C D E F G H I J K L M N O P Q R) (sector _2000 _2001 _2002 _2003 _2004 _2005 _2006 _2007 _2008 _2009 _2010 _2011 _2012 _2013 _2014 _2015 _2016)
			
			gen depto = "`a'"
			order depto sector _2000-_2016
			
			drop if sector == ""		/*Elimina las observaciones sin información*/
			save "${pc}Data/Convertidos_DANE_PIB/WIDE_`a'_PIB_Precios_Corrientes_2000_2016",replace
		}
		
		/*Se  crean paneles de datos de todos los años para cada Departamento*/
		local deptos = "AMAZONASC ANTIOQUIAC ARAUCAC ATLANTICOC BOGOTAC BOLIVARC BOYACAC CALDASC CAQUETAC CASANAREC CAUCAC CESARC CHOCOC CORDOBAC CUNDINAMARCAC GUAINIAC GUAVIAREC HUILAC LAGUAJIRAC MAGDALENAC METAC NARIÑOC NORTEDESANTANDERC PUTUMAYOC QUINDIOC RISARALDAC SANANDRESC SANTANDERC SUCREC TOLIMAC VALLEC VAUPESC VICHADAC"
		
		foreach a of local deptos {
			use "${pc}Data/Convertidos_DANE_PIB/WIDE_`a'_PIB_Precios_Corrientes_2000_2016", clear
			
				forvalues b = 2000/2016 {
					preserve
						keep depto sector _`b'
						gen year = `b'
						rename _`b' montos
						tempfile save_`a'_`b'
						save "`save_`a'_`b''"
					restore
				}
		}
		
		/*Se realiza el Append de todos los años para cada departamento*/
		local deptos = "AMAZONASC ANTIOQUIAC ARAUCAC ATLANTICOC BOGOTAC BOLIVARC BOYACAC CALDASC CAQUETAC CASANAREC CAUCAC CESARC CHOCOC CORDOBAC CUNDINAMARCAC GUAINIAC GUAVIAREC HUILAC LAGUAJIRAC MAGDALENAC METAC NARIÑOC NORTEDESANTANDERC PUTUMAYOC QUINDIOC RISARALDAC SANANDRESC SANTANDERC SUCREC TOLIMAC VALLEC VAUPESC VICHADAC"
				
		foreach a of local deptos {	
			use "`save_`a'_2000'", clear
			forvalues b = 2001/2016 {
				append using "`save_`a'_`b''"
				order depto year
				save "${pc}Data/Convertidos_DANE_PIB/PANEL_`a'_PIB_Precios_Corrientes_2000_2016",replace
			}	
		}
		
		/*Creando el Panel de datos de  todos los municipios y todos los años*/
			local deptos = "ANTIOQUIAC ARAUCAC ATLANTICOC BOGOTAC BOLIVARC BOYACAC CALDASC CAQUETAC CASANAREC CAUCAC CESARC CHOCOC CORDOBAC CUNDINAMARCAC GUAINIAC GUAVIAREC HUILAC LAGUAJIRAC MAGDALENAC METAC NARIÑOC NORTEDESANTANDERC PUTUMAYOC QUINDIOC RISARALDAC SANANDRESC SANTANDERC SUCREC TOLIMAC VALLEC VAUPESC VICHADAC"
			
			use "${pc}Data/Convertidos_DANE_PIB/PANEL_AMAZONASC_PIB_Precios_Corrientes_2000_2016",clear
			foreach a of local deptos {
				append using "${pc}Data/Convertidos_DANE_PIB/PANEL_`a'_PIB_Precios_Corrientes_2000_2016"
			}
			
		/*Creando los códigos de departamento*/
			gen 	cod_depto = 5 	if depto == "ANTIOQUIAC"
			replace cod_depto = 8 	if depto == "ATLANTICOC"
			replace cod_depto = 11 	if depto == "BOGOTAC"
			replace cod_depto = 13 	if depto == "BOLIVARC"
			replace cod_depto = 15 	if depto == "BOYACAC"
			replace cod_depto = 17 	if depto == "CALDASC"
			replace cod_depto = 18 	if depto == "CAQUETAC"
			replace cod_depto = 19 	if depto == "CAUCAC"
			replace cod_depto = 20 	if depto == "CESARC"
			replace cod_depto = 23 	if depto == "CORDOBAC"
			replace cod_depto = 25 	if depto == "CUNDINAMARCAC"
			replace cod_depto = 27 	if depto == "CHOCOC"
			replace cod_depto = 41 	if depto == "HUILAC"
			replace cod_depto = 44 	if depto == "LAGUAJIRAC"			
			replace cod_depto = 47 	if depto == "MAGDALENAC"
			replace cod_depto = 50 	if depto == "METAC"            
			replace cod_depto = 52 	if depto == "NARIÑOC"
			replace cod_depto = 54 	if depto == "NORTEDESANTANDERC"
			replace cod_depto = 63 	if depto == "QUINDIOC"
			replace cod_depto = 66 	if depto == "RISARALDAC"
			replace cod_depto = 68 	if depto == "SANTANDERC"
			replace cod_depto = 70 	if depto == "SUCREC"
			replace cod_depto = 73 	if depto == "TOLIMAC"
			replace cod_depto = 76 	if depto == "VALLEC"
			replace cod_depto = 81 	if depto == "ARAUCAC"
			replace cod_depto = 85 	if depto == "CASANAREC"
			replace cod_depto = 86 	if depto == "PUTUMAYOC"
			replace cod_depto = 88 	if depto == "SANANDRESC"
			replace cod_depto = 91 	if depto == "AMAZONASC"
			replace cod_depto = 94 	if depto == "GUAINIAC"
			replace cod_depto = 95 	if depto == "GUAVIAREC"
			replace cod_depto = 97 	if depto == "VAUPESC"
			replace cod_depto = 99 	if depto == "VICHADAC"
			
			order cod_depto depto year sector
			sort cod_depto year
			
			save "${pc}Data/Convertidos_DANE_PIB/Panel_PIB_Corrientes_Deptos_2000_2016/PANEL_PIB_Sectores_Prec_Corrientes_Deptos_2000_2016", replace
			
			/*Guardando solo la información del PIB Total de cada departamento y cada año*/
			keep if sector == "PIB TOTAL DEPARTAMENTAL"
			drop sector 
			rename montos pib_tot_deptal
			label var pib_tot_deptal	"PIB Total Departamental"
			
			save "${pc}Data/Convertidos_DANE_PIB/Panel_PIB_Corrientes_Deptos_2000_2016/PANEL_PIB_TOTAL_Prec_Corrientes_Deptos_2000_2016", replace
		
	
	
																		**********************************************
																		*		*******************************		 *
																		*		*******************************		 *
																		*		*    /*TASA DE DESEMPLEO*/    *		 *
																		*		*******************************		 *
																		*		*******************************		 *	
																		**********************************************
								
	
	/* SE CALCULARA LA TASA DE DESEMPLEO CON DOS FUENTES
	  *FUENTE GEIH
	  *FUENTE DANE
	 EN LA PRIMERA FUENTE (GEIH) SE CALCULA DE DOS MANERAS,
	  OPCION 1, TASA DE DESEMPLEO TOTAL ANUAL CON LA BASE MENSUAL(UN SOLO VALOR PARA CADA AÑO EN CADA CIUDAD O ÁREA)
	  OPCION 2, TASA DE DESEMPLEO TRIMESTRE MOVIL CON LA BASE MENSUAL (12 VALORES POR AÑO, CORRESPONDIENTES A LOS TRIMESTRES MOVILES PARA CADA CIUDAD O ÁREA)
	 EN LA SEGUNDA FUENTE(DANE) NO SE CALCULA SINO QUE SE CARGA LA BASE DE EXCEL SUMINISTRADA POR EL DANE,
	  ESTA BASE SE ENCUENTRA TAMBIEN EN TRIMESTRE MOVIL 
	  
	 LUEGO SE PRESTENDE COMPARAR AMBOS TRIMESTRES MOVILES PARA DENOTAR SIMILITUDES */
	 
	*********************************************************************************************************************************************************************
	
 
	*************************************
	*		*-----------------*         *
	*		  **FUENTE GEIH**           *
	*		*-----------------*	        *							
	*************************************
																		
	 
			 *****************************************
			 * *-----------------------------------* *
			 * * ///OPCION 1- AÑO-TOTAL MENSUAL/// * *
			 * *-----------------------------------* *
			 ***************************************** 											
																		
	clear all
	set more off, permanently
	set rmsg on, permanently
	set trace on 
	set tracedepth 1
										
																
	*****************
	* RUTA GENERAL  *
	*****************
	global pc 				=	"//Wcartsrv/ceer/CEER/GEIH/data/"
	global pc_save  		=   "//CART1179376/Fiscal_Health_BID_Libro/Data/Tasa de Desempleo/"   

	****************************************
	*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
	****************************************	

	**************************************************		 
	 *SELECCION DE BASES AREAS Y VARIABLE A UTILIZAR*
	************************************************** 
	forvalues a = 2006/2017 {
		use "${pc}/`a'/Área`a'.dta", clear
		
		keep directorio secuencia_p orden regis mes dpto area fex_c* modulo50 modulo60 modulo70
		gen ano = `a'
		order ano mes dpto area directorio secuencia_p orden regis fex_c* modulo50 modulo60 modulo70
		destring mes dpto area , replace 
		save "${pc_save}/Área_`a'.dta", replace 
	}
	*******************
	  *APPEND AÑOS*
	*******************
	clear
	forvalues a = 2006/2017 {
		append using "${pc_save}/Área_`a'.dta"
		save "${pc_save}/Áreas_hasta_2017.dta", replace 
	}
	
	******************************************
	/*NOTA: El factor de expansión, no esta determinado por la misma variable fex_c_2011 para todos los años, por tanto, los missing,///
	 que en su gran mayoria son los años iniciales, donde no existia este, se remplazaron por el dato de fex_c que se tiene para dichos años,de esta, se unifico y se completo toda la variable */
	use "${pc_save}/Áreas_hasta_2017.dta", clear 
	replace fex_c_2011= fex_c if missing(fex_c_2011) 
	save "${pc_save}/Áreas_hasta_2017.dta", replace 
	******************************************
	
	*****************************************
		/*CALCULO-TASA DE DESMPLEO*/
	*****************************************
	use "${pc_save}/Áreas_hasta_2017.dta", clear
		collapse (sum) modulo60 modulo70 [fw=round(fex_c_2011/12)], by (area ano)
		gen tasa_desempleo=(modulo70/(modulo60+modulo70))*100
		drop modulo60 modulo70
		order area ano
		sort area ano
		rename area cod_dane
		
		/*Etiquetando*/
		
	label define cod_dane_lbl		5 "Medellín A.M." 8 "Barranquilla A.M." 11 "Bogotá" 13 "Cartagena" 17 "Manizales A.M." 23 "Montería" ///
										 50 "Villavicencio" 52 "Pasto" 54 "Cúcuta A.M." 63001 "Armenia" 66 "Pereira A.M." ///
										68 "Bucaramanga A.M."  73"Ibagué" 76 "Cali A.M." 
										
		
	label values cod_dane cod_dane_lbl
		
		
	save "${pc_save}/Áreas_TD_hasta_2017.dta", replace 
	
				 
			 ****************************************
			 * *----------------------------------* *
			 * * ///OPCION 2- TRIMESTRE MOVIL /// * *
			 * *----------------------------------* *
			 ****************************************
			 			
	clear all
	set more off, permanently
	set rmsg on, permanently
	set trace on 
	set tracedepth 1
										
																
	*****************
	* RUTA GENERAL  *
	*****************
	global pc 				=	"//Wcartsrv/ceer/CEER/GEIH/data/"
	global PC  		=   "//CART1179376/Fiscal_Health_BID_Libro/Data/Tasa de Desempleo/"   
	****************************************	
	
	*******************
	  *APPEND AÑOS*
	*******************
	
	clear
	forvalues a = 2006/2017 {
		append using "${PC}/Área_`a'.dta"
		save "${PC}/Áreas_hasta_2017.dta", replace 
	}	
	
	***************************************
	/*NOTA: El factor de expansión, no esta determinado por la misma variable fex_c_2011 para todos los años, por tanto, los missing,///
	 que en su gran mayoria son los años iniciales, donde no existia este, se remplazaron por el dato de fex_c que se tiene para dichos años,de esta, se unifico y se completo toda la variable */
	use "${PC}/Áreas_hasta_2017.dta", clear 
	replace fex_c_2011= fex_c if missing(fex_c_2011) 
	save "${PC}/Áreas_hasta_2017.dta", replace 
	
	************************************
	*CALCULAMOS TASA DESEMPLEO POR MES* 
	***********************************
	use "${PC}/Áreas_hasta_2017.dta", clear
		collapse (sum) modulo60 modulo70 [fw=round(fex_c_2011/12)], by (area mes ano)
		gen tasa_desempleo=(modulo70/(modulo60+modulo70))*100
		drop modulo60 modulo70
		rename area cod_dane
	
	/*Etiquetando codigos área*/
		label define cod_dane_lbl		05 "Medellín A.M." 08 "Barranquilla A.M." 11 "Bogotá" 13 "Cartagena" 17 "Manizales A.M." 23 "Montería" ///
										 50 "Villavicencio" 52 "Pasto" 54 "Cúcuta A.M." 63001 "Armenia" 66 "Pereira A.M." ///
										68 "Bucaramanga A.M."  73"Ibagué" 76 "Cali A.M." 
										
		
		label values cod_dane cod_dane_lbl
		
	sort cod_dane ano mes 
		
	save "${PC}/Áreas_TD_hasta_2017.dta", replace	
	
	*******************
	*TRIMETRE MOVIL*
	*******************
	use "${PC}/Áreas_TD_hasta_2017.dta" , clear
	 
		gen td_trim = ((tasa_desempleo[_n]+tasa_desempleo[_n-1]+tasa_desempleo[_n-2])/3) /* Teniendo la base, previamente organizada por area, año y mes, se procede a utilizar (_n) para tomar los meses anteriores al mes en cuestion, haciendo una promedio de los tres meses antes, incluyendo el mismo*/
		
		gen td_tr_mv = td_trim if ano >= 2007  /*Esto se realiza con la finalidad de que los trimestres moviles sean los correspondientes del 2007 hasta ,solo el mes de enero contiene los meses de noviembre y diciembre del año 2006*/

		keep  cod_dane ano mes tasa_desempleo td_tr_mv    /*solo se mantiene la base de 2007 a 2017 */
		drop if td_tr_mv ==.
		
		save "${PC}/Áreas_TD_2007_2017.dta", replace
		

	*************************************
	*		*-----------------*         *
	*		 **FUENTE DANE **           *
	*		*-----------------*	        *							
	*************************************

	*NOTA: LOS DATOS CORRESPONDEN A TRIMESTRES MOVILES DE CADA CIUDAD Y ÁREA*
		
	clear all
	set more off, permanently
	set rmsg on, permanently
	set trace on 
	set tracedepth 1
										
																
	*****************
	* RUTA GENERAL  *
	*****************
	*************************************************************************************
	global PC  		=   "//CART1179376/Fiscal_Health_BID_Libro/Data/Tasa de Desempleo/"   
	*************************************************************************************

	******************************
	*LECTURA DE DATOS DESDE EXCEL* 
	******************************
	set trace on 
	set tracedepth 1 

	import excel using  "${PC}TD_13_ciudades_trim_mv 2007_2017.xlsx", clear sheet("Hoja1") firstrow 
	
	gen cod_dane = 76 if area == "Cali A.M."
	replace cod_dane = 05 if area == "Medellín A.M."
	replace cod_dane = 08 if area == "Barranquilla A.M."
	replace cod_dane = 13 if area == "Cartagena"
	replace cod_dane = 17 if area == "Manizales A.M."
	replace cod_dane = 23 if area == "Montería"
	replace cod_dane = 11 if area == "Bogotá"
	replace cod_dane = 50 if area == "Villavicencio"         
	replace cod_dane = 52 if area == "Pasto"
	replace cod_dane = 54 if area == "Cúcuta A.M."
	replace cod_dane = 68 if area == "Bucaramanga A.M."
	replace cod_dane = 66 if area == "Pereira A.M."
	replace cod_dane = 73 if area == "Ibagué" 

	/*Etiquetas*/
	
		label define cod_dane_lbl		05 "Medellín A.M." 08 "Barranquilla A.M." 11 "Bogotá" 13 "Cartagena" 17 "Manizales A.M." 23 "Montería" ///
										 50 "Villavicencio" 52 "Pasto" 54 "Cúcuta A.M." 63001 "Armenia" 66 "Pereira A.M." ///
										68 "Bucaramanga A.M."  73"Ibagué" 76 "Cali A.M." 
										
										
		label values cod_dane cod_dane_lbl 
	
	save "${PC}TD_13_ciudades_trim_mv 2007_2017.dta",replace 
	
			*******************************************************
			*******************************************************
			* COMPARANDO TRMIESTRE MOVIL- FUENTE GEIH-FUENTE DANE *
			*******************************************************
			*******************************************************
	
	
	********
	*MERGE*
	********
	
	preserve 
		use "${PC}Áreas_TD_2007_2017.dta",clear 
		merge 1:1 cod_dane mes ano using "${PC}/TD_13_ciudades_trim_mv 2007_2017.dta" 
		drop _merge 
		save "${PC}/TD_DANE_GEIH.dta", replace  
	restore
	
	************************************
	*CALCULAMOS LA TASA DESEMPLEO ANUAL* 
	************************************
	
	*NOTA:SE TOMARA LA MEDIA ARITMÉTICA DE LOS 12 MESES DEL AÑO, QUE CORRESPONDEN AL TRIMESTRE MOVIL.
	
	*summarize  td_tr_mv_dane if cod_dane ==5 & (mes >= 1 & mes <=12) & ano == 2015
   
	use"${PC}TD_13_ciudades_trim_mv 2007_2017.dta", clear 
		collapse (mean) td_tr_mv_dane, by (cod_dane ano)
		order cod_dane ano 
		save "${PC}TD_13_ciudades_ANUAL_2007_2017.dta", replace
	

	
																		***************************************************************************************
																		***************************************************************************************
																		***************************************************************************************
																		***************************************************************************************
																		**		CREACIÓN DE LAS VARIABLES RELEVENTES PARA EL PROYECTO DE FISCAL HEALTH     	 **
																		**																					 **
																		**	  (LA FUENTE DE DATOS CORRESPONDE A LAS DIFERENTES BASES CREADAS ANTERIORMENTE)	 **
																		**																		   			 **
																		***************************************************************************************
																		***************************************************************************************
																		***************************************************************************************
																		***************************************************************************************
*****************
* RUTA GENERAL  *
*****************
global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

****************************************
*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
****************************************	
global originales_chip		= 	"${pc}Data/CHIP_Contaduria_General/"
global convertidos_chip		= 	"${pc}Data/Convertidos_CHIP/"
global graficos				=	"${pc}Graficos/"
global tablas				=	"${pc}Tablas/"	
global indicadores			= 	"${pc}Data/Indicadores/"			 

		
					/********************************/
					/********************************/
					/********************************/
					/*------------------------------*/
					/*   NET FINANCIAL ASSETS		*/
					/*------------------------------*/
					/********************************/
					/********************************/
					/********************************/
		/*Nota: Financial Assets / Financial Liabilities*/
		
		
		/*------------------------*/
		/*   FIANCIAL ASSETS	  */
		/*------------------------*/
		
		use "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta", clear
		
		keep if codigo == "1.1 " | codigo == "1.2 " | codigo == "1.3 " | codigo == "1.4 " | codigo == "1.5 "		/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		
		collapse (sum) saldoinicialmiles movimientodebitomiles saldofinalmiles saldofinalcorrientemiles saldofinalnocorrientemiles, by(year cod_dane)
		order cod_dane year
		sort cod_dane year
		
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
										
										/*	5001 "Antioquia" 
											11001 "Bogotá"
										*/
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen saldo_final_millones = saldofinalmiles/1000
			
		/*Guardando la base de datos*/
			keep cod_dane year saldo_final_millones
			rename saldo_final_millones saldo_final_activos_millones
			save "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Activos_Financieros_2009_2017.dta", replace
	
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline saldo_final_activos_millones if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Avalúo") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(activos_financ_saldo_final_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Activos_Financieros_Netos\Activos_Financieros_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}

		/*------------------------*/
		/*   FINANCIAL LIABILITIES */
		/*------------------------*/
		use "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta", clear
		
		keep if codigo == "2.2 " | codigo == "2.3 " | codigo == "2.4 " | codigo == "2.5 " | codigo == "2.6 "		/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		
		collapse (sum) saldoinicialmiles movimientodebitomiles saldofinalmiles saldofinalcorrientemiles saldofinalnocorrientemiles, by(year cod_dane)
		order cod_dane year
		sort cod_dane year
		
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
										
										/*	5001 "Antioquia" 
											11001 "Bogotá"
										*/
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen saldo_final_millones = saldofinalmiles/1000
	
		/*Guardando la base de datos*/
			keep cod_dane year saldo_final_millones
			rename saldo_final_millones saldo_final_pasivos_millones
			save "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Pasivos_Financieros_2009_2017.dta", replace
			
	
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline saldo_final_pasivos_millones if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(activos_financ_saldo_final_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Activos_Financieros_Netos\Pasivos_Financieros_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
	
	
		*-----------------------------------------------------------------*/
		/*	 NET FINANCIAL ASSETS: FINANCIAL ASSETS/FINANCIAL LIABILITIES */
		/*----------------------------------------------------------------*/
		
		use "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Activos_Financieros_2009_2017.dta", clear
		merge 1:1 cod_dane year using "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Pasivos_Financieros_2009_2017.dta"
		
		/*Cálculo del indicador de ACTIVOS FINANCIEROS NETOS*/
			gen act_financ_netos = saldo_final_activos_millones/saldo_final_pasivos_millones
		
		
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline act_financ_netos if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Unidades" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(activos_financ_netos_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Net_Financial_Assets\Activos_Financieros_NETOS_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
		
		
		save "${indicadores}Panel_Net_Financial_Assets_2005_2017.dta", replace
		
					
					/************************************************/
					/************************************************/
					/************************************************/
					/*----------------------------------------------*/
					/*   TAXES RECEIVABLE RELATIVE TO TAXES LEVIED  */
					/*----------------------------------------------*/
					/************************************************/
					/************************************************/
					/************************************************/
					/*Nota: El numerador corresponde a las Cuentas por Cobrar Tributarias (cuenta 1.3.05), 
					y el denominador al recaudo total (cuenta 4.1.05)*/
		
		
		/*------------------------*/
		/*   TAXES RECEIVABLE	  */
		/*------------------------*/
		
		use "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta", clear
				
		keep if codigo == "1.3.05 " /*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		
		keep year mpio cod_dane codigo nombre saldofinalmiles
				
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
											
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen saldo_final_millones = saldofinalmiles/1000
			
		/*Guardando la base de datos*/
			order cod_dane year saldo_final_millones
			keep cod_dane year saldo_final_millones
			rename saldo_final_millones saldo_final_tax_receiv_millones
			save "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Taxes_Receivable_2005_2017.dta", replace
	
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline saldo_final_tax_receiv_millones if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(taxes_receiv_saldo_final_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Taxes_Receivable_relative_Taxes_Levied\Taxes_Receivable_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}

		/*------------------------*/
		/*   	TAXES LEVIED	  */
		/*------------------------*/
		
		use "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta", clear
				
		keep if codigo == "4.1.05 " /*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		
		keep year mpio cod_dane codigo saldofinalmiles
				
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
											
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen saldo_final_millones = saldofinalmiles/1000
			
		/*Guardando la base de datos*/
			order cod_dane year saldo_final_millones
			keep cod_dane year saldo_final_millones
			rename saldo_final_millones saldo_final_tax_levied_millones
			save "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Taxes_Levied_2005_2017.dta", replace
	
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline saldo_final_tax_levied_millones if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(taxes_levied_saldo_final_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Taxes_Receivable_relative_Taxes_Levied\Taxes_Levied_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
		
		
		*-----------------------------------------------------------------------------*/
		/*	 TAXES RECEIVABLE RELATIVE TO TAXES LEVIED: TAXES RECEIVABLE/TAXES LEVIED */
		/*----------------------------------------------------------------------------*/
		
		use "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Taxes_Receivable_2005_2017.dta", clear
		merge 1:1 cod_dane year using "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Taxes_Levied_2005_2017.dta"
		
		/*Cálculo del indicador de ACTIVOS FINANCIEROS NETOS*/
			gen tax_receiv_tax_levied = (saldo_final_tax_receiv_millones/saldo_final_tax_levied_millones)*100
		
		
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline tax_receiv_tax_levied if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Porcentaje" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(0(10)70, /*format(%10,0fc)*/  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(taxes_receiv_taxes_levied_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Taxes_Receivable_relative_Taxes_Levied\Taxes_Received_Taxes_Levied_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
				
		save "${indicadores}Panel_Taxes_Receivable_relative_Levied_2005_2017.dta", replace

					
					/************************************************/
					/************************************************/
					/************************************************/
					/*----------------------------------------------*/
					/*   		ASSET CONSUMPTION RATIO  			*/
					/*----------------------------------------------*/
					/************************************************/
					/************************************************/
					/************************************************/
		/*Nota: Closing Amortization Balance/(Closing Cost Balance-Land)
				Percentage of Total Capital Assets amortized*/
				/*NUMERADOR(Closing amortization balance): 
				  La depreciación acumulada(de propiedades planta y equipo): cuenta 1.6.85
				  + La amortización acumulada(de bienes de uso público e históricos y culturales): cuenta 1.7.85
				  + La amortización de Bienes inmuebles entregados en administración (1.9.25.02)
				  + La amortización de Bienes inmuebles entregados en comodato (1.9.25.06)
				  + La amortización acumulada de intangibles(software,licencias) (1.9.75)
				  DENOMINADOR(Closing cost balance - Land): 
				  (Propiedad Planta y Equipo(1.6) - Terrenos(1.6.05 + 1.6.37.01 + 1.6.82.01))
				  + Bienes de uso Público en Servicio(1.7.10) 
				  + Bienes de uso publico en servicio en concesión (1.7.11)
				  + Bienes históricos y culturales en servicio(1.7.15) 
				  + Bienes de uso públ e Hist y Cult entregados en Administrac(1.7.20)
				  + Otros Activos - Bienes inmuebles entregados en administración (1.9.20.02) 
				  + Otros Activos - Bienes inmuebles entregados en comodato (1.9.20.06) 
				  + Otros Activos - Bienes inmuebles entregados en concesión (1.9.20.12)
			NO SE TIENEN EN CUENTA LOS RECURSOS NATUARLES NO RENOVABLES(1.8)	 
				 */ 
				  
			
		/*-------------------------------------*/
		/*  	CLOSING AMORTIZATION BALANCE   */
		/*-------------------------------------*/
		
		use "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta", clear
				
		keep if codigo == "1.6.85 " | codigo == "1.7.85 " | codigo == "1.9.25.02 " | codigo == "1.9.25.06 " | codigo == "1.9.75 "	/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		keep year mpio cod_dane codigo saldofinalmiles
		
		collapse (sum) saldofinalmiles, by(year cod_dane)
		order cod_dane year
		sort cod_dane year		
		
		
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
											
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen saldo_final_millones = abs(saldofinalmiles/1000)		/*Se pasó a valores positivos y a millines de pesos*/
			
		/*Guardando la base de datos*/
			rename saldo_final_millones saldo_final_clo_amo_bal_millones
			drop saldofinalmiles
			save "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Closing_Amortization_Balance_2005_2017.dta", replace
		
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline saldo_final_clo_amo_bal_millones if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(clos_amo_bal_sal_fin_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Asset _Consumption_Ratio\Closing_Amortization_Balance_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
		
	
		/*-------------------------------------*/
		/*  	CLOSING COST BALANCE		   */
		/*-------------------------------------*/
	
		use "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta", clear
				
		keep if codigo == "1.6 " | codigo == "1.7.10 " | codigo == "1.7.11 " | codigo == "1.7.15 " | codigo == "1.7.20 " | codigo == "1.9.20.02 " | codigo == "1.9.20.06 " | codigo == "1.9.20.12 "	/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		keep year mpio cod_dane codigo saldofinalmiles
		
		collapse (sum) saldofinalmiles, by(year cod_dane)
		order cod_dane year
		sort cod_dane year		
		
		
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
											
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen saldo_final_millones = saldofinalmiles/1000		/*Se pasó a millOnes de pesos*/
			
		/*Guardando la base de datos*/
			rename saldo_final_millones saldo_final_clo_cost_bal_mill
			drop saldofinalmiles
			save "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Closing_Cost_Balance_2005_2017.dta", replace
	
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline saldo_final_clo_cost_bal_mill if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(clos_cost_bal_sal_fin_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Asset _Consumption_Ratio\Closing_Cost_Balance_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
	
	
		/*-------------------------------------*/
		/*  				LAND			   */
		/*-------------------------------------*/
	
		use "${convertidos_chip}/Z_PANELES/PANEL_INFO_CONTABLE/TODOS_MPIOS_Panel_Info_Contable_hasta_2017.dta", clear
				
		keep if codigo == "1.6.05 " | codigo == "1.6.37.01 " | codigo == "1.6.82.01 " 		/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		keep year mpio cod_dane codigo saldofinalmiles
		
		collapse (sum) saldofinalmiles, by(year cod_dane)
		order cod_dane year
		sort cod_dane year		
		
		
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
											
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen saldo_final_millones = saldofinalmiles/1000		/*Se pasó a millOnes de pesos*/
			
		/*Guardando la base de datos*/
			rename saldo_final_millones saldo_final_land_millones
			drop saldofinalmiles
			save "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Land_2005_2017.dta", replace
	
	
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline saldo_final_land_mill if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(land_sal_fin_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Asset _Consumption_Ratio\Land_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
	
	
		/*-------------------------------------*/
		/*  	ASSET CONSUMPTION RATIO		   */
		/*-------------------------------------*/
	
		use "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Closing_Amortization_Balance_2005_2017.dta", clear
		merge 1:1 cod_dane year using "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Land_2005_2017.dta"
		drop _merge
		merge 1:1 cod_dane year using "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Closing_Cost_Balance_2005_2017.dta"
		drop _merge
		
		gen asset_consumt_ratio = (saldo_final_clo_amo_bal_millones / (saldo_final_clo_cost_bal_mill - saldo_final_land_millones))*100
		keep cod_dane year asset_consumt_ratio
		
		save "${indicadores}Panel_Asset_Consumpt_Ratio_2005_2017.dta", replace

		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline asset_consumt_ratio if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Porcentaje" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, /*format(%10,0fc)*/  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(asset_consump_ratio_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Asset_Consumption_Ratio\Asset_Consumption_Ratio_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}

						/************************************************/
						/************************************************/
						/************************************************/
						/*----------------------------------------------*/
						/*    EXTENT OF INVESTMENT IN CAPITAL ASSETS  	*/
						/*----------------------------------------------*/
						/************************************************/
						/************************************************/
						/************************************************/
			/*Nota: Closing Cost Balance/Closing Net Book Value
					Provides an indication of the extent to which cities have been investing in capital assets 
					by comparing the original cost of the capital assets (closing cost balance) with the original cost less accumulated depreciation (net book value)
					  
					 NUMERADOR: Closing Cost Balance: (ESTA VARIABLE YA FUE CREADA ANTERIORMENTE)
					 DENOMINADOR: Closing Net Book Balance = Closing Cost Balance - Closing Amortization Balance	(ESTA ÚLTIMA VARIABLE TAMBIÉN FUE YA CREADA ANTERIORMENTE)
			*/

			
			use "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Closing_Cost_Balance_2005_2017.dta", clear		
			merge 1:1 cod_dane year using "${convertidos_chip}/Z_Indicadores_Insumos/Panel_Closing_Amortization_Balance_2005_2017.dta"
			drop _merge
			
			gen closing_net_book_value  = saldo_final_clo_cost_bal_mill-saldo_final_clo_amo_bal_millones
			gen extent_invest_capit_assets = (saldo_final_clo_cost_bal_mill / closing_net_book_value)*100
			drop saldo_final_clo_cost_bal_mill saldo_final_clo_amo_bal_millones closing_net_book_value		 
					 
			save "${indicadores}Panel_Extent_Investment_in_Capital_Assets_2005_2017.dta", replace

			local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

			foreach x of local capitales {
				preserve
						keep if cod_dane== `x'
						tsset cod_dane year
						
						#delimit;
						twoway  (tsline extent_invest_capit_assets if year > 2008, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
								/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
						scheme(mono)
						title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
						xtitle(" " "Año", size(small))   
						ytitle("Porcentaje" " ", axis(1) size(medsmall))
						/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
						xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
						ylabel(, /*format(%10,0fc)*/  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
						/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
						plotregion(color(white)) 
						graphregion(color(white) lcolor(white))
						legend(label (1 "") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
						name(exte_inves_cap_assets_`x', replace)
						;
						#delimit cr
						
						graph export "${graficos}Extent_Investment_in_Capital_Assets\Extent_Investment_in_Capital_Assets_`:label(cod_dane) `x''.pdf", as(pdf) replace
				restore	
			}

			
					/********************************/
					/********************************/
					/********************************/
					/*------------------------------*/
					/*   	INCOME PER CAPITA		*/
					/*------------------------------*/
					/********************************/
					/********************************/
					/********************************/
		/*Nota: Total Income / Total Population*/

		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global convertidos_poblac	= 	"${pc}Data/Convertidos_Poblacion/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"			 
		
		
		/*------------------------*/
		/*   TOTAL INCOME		  */
		/*------------------------*/
		
		use "${convertidos_fut}FUT_Ingresos/Z_PANELES/PANEL_INGRESOS/TODOS_MPIOS_Panel_Ingresos_hasta_2017.dta", clear
				
		keep if codigo == "TI " 	/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		format nombre %20s
				
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen total_ingresos_modif_mill = total_ingresos_modif/1000
			
		/*Guardando la base de datos*/
			keep mpio cod_dane year total_ingresos_modif_mill
			format total_ingresos_modif_mill %12.0f
				
			save "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Totales_2008_2017.dta", replace
			
		/*----------------------------------*/
		/*   	TOTAL INCOME PER CÁPITA		*/
		/*----------------------------------*/
			use "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Totales_2008_2017.dta", clear
			merge 1:1 cod_dane year using "${convertidos_poblac}Total_1985_2050/Total_PANEL_Municipal_area_1985-2050.dta"
			drop if _merge==2
			drop codigo_depto depto _merge
			
			gen ingreso_pc = (total_ingreso/poblacion)*1000000
			lab var ingreso_pc 	"Ingreso Per-cápita (en pesos corrientes)"
			
			save "${indicadores}Panel_Income_Per_Capita_2008_2017.dta", replace
	
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline ingreso_pc if year > 2010, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2011(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Ingreso per-cápita") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(ingreso_per_capita_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Income_Per_Capita\Ingreso_Per_Capita_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}


					/*************************************/
					/*************************************/
					/*************************************/
					/*-----------------------------------*/
					/*   	EXPENDITURES PER CAPITA		 */
					/*-----------------------------------*/
					/*************************************/
					/*************************************/
					/*************************************/
		/*Nota: Total Expenditures / Total Population*/
		/*Total Gasto = Gasto de Funcionamiento + Gasto de Inversión + Servicio de la Deuda*/

		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global convertidos_poblac	= 	"${pc}Data/Convertidos_Poblacion/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"			 
		
		
		/*--------------------------------*/
		/*   	OPERATIONAL EXPENSES	  */
		/*--------------------------------*/
		
		use "${convertidos_fut}/FUT_Gastos_Funcionamiento/Z_PANELES/PANEL_GASTOS_FUNCIONAMIENTO/TODOS_MPIOS_Panel_Gastos_Funcionamiento_hasta_2017.dta", clear
				
		keep if codigo == "1.1 " 	/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		
		collapse (sum) presup_inicial presup_definitivo pagos obligaciones compromisos, by(cod_dane year)
		rename pagos gasto_funcionam_pagos
		keep cod_dane year gasto_funcionam_pagos 	/*Se deja como variable total de gastos de funcionamiento la correspondiente a los pagos*/ 
			
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen gasto_funcionam_pagos_mill = gasto_funcionam_pagos/1000
			drop gasto_funcionam_pagos
				
		save "${convertidos_fut}FUT_Gastos_Funcionamiento/Z_Indicadores_Insumos/Panel_Operational_Expenses_2008_2017.dta", replace	
			
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline gasto_funcionam_pagos_mill if year > 2010, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2011(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Gasto de Funcinamiento") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(gasto_funcionam_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Expenditures_Per_Capita\Gasto_Funcion_Per_Capita_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
		
				
		/*--------------------------------*/
		/*   	INVESTMENT EXPENSES	  	  */
		/*--------------------------------*/
		
		use "${convertidos_fut}FUT_Gastos_Inversion/Z_PANELES/PANEL_GASTOS_INVERSION/TODOS_MPIOS_Panel_Gastos_Inversion_hasta_2017.dta", clear
		
		keep if codigo == "A " 	/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		
		collapse (sum) presup_inicial presup_definitivo compromisos pagos obligaciones, by(cod_dane year)
		rename pagos gasto_inversion_pagos
		keep cod_dane year gasto_inversion_pagos 	/*Se deja como variable total de gastos de funcionamiento la correspondiente a los pagos*/ 
			
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen gasto_inversion_pagos_mill = gasto_inversion_pagos/1000
			drop gasto_inversion_pagos
				
		save "${convertidos_fut}FUT_Gastos_Inversion/Z_Indicadores_Insumos/Panel_Investment_Expenses_2008_2017.dta", replace	
			
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline gasto_inversion_pagos_mill if year > 2010, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2011(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Gasto de Inversión") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(gasto_inversion_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Expenditures_Per_Capita\Gasto_Inversion_Per_Capita_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}
		
				
		/*--------------------------------*/
		/*   	DEBT SERVICE EXPENSES	  */
		/*--------------------------------*/
		
		use "${convertidos_fut}FUT_Servicio_Deuda/Z_PANELES/PANEL_SERVICIO_DEUDA/TODOS_MPIOS_Panel_servicio_deuda_hasta_2017.dta", clear
			
		keep if codigo == "T " 	/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		
		collapse (sum) presup_inicial presup_definitivo compromisos pagos obligaciones, by(cod_dane year)
		rename pagos gasto_servdeuda_pagos
		keep cod_dane year gasto_servdeuda_pagos 	/*Se deja como variable total de gastos de funcionamiento la correspondiente a los pagos*/ 
			
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen gasto_servdeuda_pagos_mill = gasto_servdeuda_pagos/1000
			drop gasto_servdeuda_pagos
				
		save "${convertidos_fut}FUT_Servicio_Deuda/Z_Indicadores_Insumos/Panel_DebtService_Expenses_2008_2017.dta", replace	
			
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 85001 86001 88001 91001 95001 97001 99001"		 
		/*No hay información para: 81001(Arauca), 94001(Inírida), */
		
		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline gasto_servdeuda_pagos_mill if year > 2010, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2011(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Gasto en servicio de la deuda") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(gasto_servdeuda_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Expenditures_Per_Capita\Gasto_ServicioDeuda_Per_Capita_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		}	
			
		
		/*--------------------------------*/
		/*   	EXPENDITURES PER-CÁPITA	  */
		/*--------------------------------*/		

			use "${convertidos_fut}FUT_Gastos_Funcionamiento/Z_Indicadores_Insumos/Panel_Operational_Expenses_2008_2017.dta", clear
			merge 1:1 cod_dane year using "${convertidos_fut}FUT_Gastos_Inversion/Z_Indicadores_Insumos/Panel_Investment_Expenses_2008_2017.dta"
			drop _merge
			merge 1:1 cod_dane year using "${convertidos_fut}FUT_Servicio_Deuda/Z_Indicadores_Insumos/Panel_DebtService_Expenses_2008_2017.dta"
			drop _merge
			merge 1:1 cod_dane year using "${convertidos_poblac}Total_1985_2050/Total_PANEL_Municipal_area_1985-2050.dta"
			drop if _merge==2
			drop _merge
						
			/*Generando la variable Gasto Total*/
			egen gasto_total_millones = rowtotal(gasto_funcionam_pagos_mill gasto_inversion_pagos_mill gasto_servdeuda_pagos_mill)	/*La opción rowtotal permite hacer la suma tomando los missing como ceros*/
			gen gasto_pc	= (gasto_total_millones/poblacion)*1000000
			lab var gasto_pc 	"Gasto Per-cápita (en pesos corrientes)"
			
			/*Guardando la base del gasto Total*/		
			preserve
				keep cod_dane year gasto_total_millones
				save "${convertidos_fut}FUT_Gasto_Total/Z_Indicadores_Insumos/Panel_Total_Expenditure_2008_2017.dta", replace	
			restore
			
			/*Guardando la base de Gasto Per-Cápita*/
			keep cod_dane year gasto_pc
			save "${indicadores}Panel_Expenditure_Per_Capita_2008_2017.dta", replace
			
			local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

			foreach x of local capitales {
				preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline gasto_pc if year > 2010, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2011(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Gasto total per-cápita") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(gasto_percapita_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Expenditures_Per_Capita\Gasto_Total_Per_Capita_`:label(cod_dane) `x''.pdf", as(pdf) replace
				restore	
			}	
		
		
		
					/*************************************/
					/*************************************/
					/*************************************/
					/*-----------------------------------*/
					/*   		TAXES PER CÁPITA		 */
					/*-----------------------------------*/
					/*************************************/
					/*************************************/
					/*************************************/
		/*Nota: Total Taxes / Total Population*/
		
		
		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global convertidos_poblac	= 	"${pc}Data/Convertidos_Poblacion/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"			 
		
		
		/*--------------------------------*/
		/*   	TOTAL TAX REVENUE		  */
		/*--------------------------------*/
		
		use "${convertidos_fut}FUT_Ingresos/Z_PANELES/PANEL_INGRESOS/TODOS_MPIOS_Panel_Ingresos_hasta_2017.dta", clear
				
		keep if codigo == "TI.A.1 " 	/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
		format nombre %20s
				
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		label values cod_dane cod_dane_lbl
		
		/*Generandolos valores en millones*/
			gen ingresos_tribut_modif_mill = total_ingresos_modif/1000
			
		/*Guardando la base de datos*/
			keep mpio cod_dane year ingresos_tribut_modif_mill
			format ingresos_tribut_modif_mill %12.0f
				
			save "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Tributarios_2008_2017.dta", replace	
		
			local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

			foreach x of local capitales {
				preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline ingresos_tribut_modif_mill if year > 2010, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Millones de pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2011(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Ingreso tributario") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(ingreso_tribut_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Taxes_Per_Capita\Total_Tax_Revenue_`:label(cod_dane) `x''.pdf", as(pdf) replace
				restore	
			}	
		
			
		/*--------------------------------*/
		/*   		TAXES PER-CAPITA	  */
		/*--------------------------------*/		

		use "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Tributarios_2008_2017.dta", clear
		merge 1:1 cod_dane year using "${convertidos_poblac}Total_1985_2050/Total_PANEL_Municipal_area_1985-2050.dta"
		drop if _merge==2
		drop _merge
					
		/*Generando la variable Impuestos Per-Cápita*/
		gen impuestos_pc	= (ingresos_tribut_modif_mill/poblacion)*1000000
		lab var impuestos_pc 	"Impuestos Per-cápita (en pesos corrientes)"
				
		/*Guardando la base de datos*/
			keep mpio cod_dane year impuestos_pc
				
			save "${indicadores}Panel_Taxes_PerCápita_2008_2017.dta", replace	
		
			local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

			foreach x of local capitales {
				preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline impuestos_pc if year > 2010, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Pesos corrientes" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2011(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Impuestos per-cápita") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(impuestos_percapita_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Taxes_Per_Capita\Taxes_Per_Capita_`:label(cod_dane) `x''.pdf", as(pdf) replace
				restore	
			}		
			
		
					/*************************************/
					/*************************************/
					/*************************************/
					/*-----------------------------------*/
					/*   		POPULATION GROWTH		 */
					/*-----------------------------------*/
					/*************************************/
					/*************************************/
					/*************************************/
			/*Se calculará la tasa de crecimiento poblacional en promedios móviles Bi-Anuales. Primero se calculan las tasas de crecimiento entre un año y otro. 
			Posteriormente, se calculan los promedios móviles cada dos años. Por ejemplo, el dato del 2017 será el promedio de la tasa de crecimiento entre 2016 y 2017,
			el dato de 2016 será el promedio de la tasa de crecimiento entre 2015 y 2016, y así sucesivamente.
			Se calcularán las tasas de crecimiento desde el año 2000 únicamente, esto para homologar los periodos con las demás bases de datos*/
			
		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global convertidos_poblac	= 	"${pc}Data/Convertidos_Poblacion/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"	
		
		
		/*--------------------------------*/
		/*   		POPULATION GROWTH	  */
		/*--------------------------------*/
		
		use "${convertidos_poblac}Total_1985_2050/Total_PANEL_Municipal_area_1985-2050.dta", clear
		
		keep if year > 1999 & year < 2018
		
		/*Seleccionando los codigos correspondientes a las capitales de departamento*/
		
			/*Opción 1*/
			keep if inlist(cod_dane,5001,8001,11001,13001,15001,17001,18001,19001,20001,23001,27001,41001,44001,47001,50001,52001, ///
							54001,63001,66001,68001,70001,73001,76001,81001,85001,86001,88001,91001,94001,95001,97001,99001)
			
			/*Opción 2*/
			egen temp = anymatch(cod_dane), values(5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 ///	/*Crea una dummy para los codigos seleccionados*/
												54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001)
			keep if temp
			drop temp
		
		/*Calculando las tasas de crecimiento*/
			tsset cod_dane year
			bysort cod_dane: gen crec_pobl = (poblacion-l.poblacion)/l.poblacion
		
		/*Calculando el Promedio Móvil Bi-Anual de las Tasas de Crecimiento Poblacional*/
			bysort cod_dane: gen crec_pobl_prom_bianual = ((crec_pobl+l.crec_pobl)/2)*100
		
		/*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		label values cod_dane cod_dane_lbl
			
			
		save "${indicadores}Panel_Population_Growth_2002_2017.dta", replace		
			
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

			foreach x of local capitales {
				preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline crec_pobl_prom_bianual if year > 2010, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Porcentaje" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2011(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Crecimiento poblacional - promedio bianual") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(crecim_poblacion_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Population_Growth\Population_Growth_Bianual_Average_`:label(cod_dane) `x''.pdf", as(pdf) replace
				restore	
			}			
			
			/*Gráficos de Barras para 2016-2017*/
			/*---------------------------------*/			
			#delimit;
			graph hbar crec_pobl_prom_bianual if year == 2017, 
					over(cod_dane, sort(crec_pobl_prom_bianual) descending gap(80) label(labsize(medsmall)))		
					scheme(mono)
					scale(*.7)																		/*Controla el Tamaño de la escala de los nombres de las ciudades*/
					ytitle("")																		/*Esto evita que tengamos el nombre de la variable como título del eje*/
					ylabel(0(0.5)3.5, format(%8.1fc) /*nogrid*/ glcolor(gs14) glwidth(vvthin) labsize(medium) angle(0))
					b1title("Porcentaje", size(medlarge) color(black))								/*Título del eje X*/
					l1title("")																		/*Título del Eje Izquierdo*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(off)
					name(crecim_poblac_2016_2017, replace)	
			;			
						
			graph export "${graficos}Population_Growth\A----Population_Growth_Bianual_Average_2016-2017.pdf", as(pdf) replace			
					
						
			
					/*************************************/
					/*************************************/
					/*************************************/
					/*-----------------------------------*/
					/*   		TAX BASE GROWTH			 */
					/*-----------------------------------*/
					/*************************************/
					/*************************************/
					/*************************************/	
			/*Se tendrá en cuenta la base de los dos impuestos más importantes y representativos en Colombia: Predial e ICA. Para el primero, se tomarán como base 
			los avalúos catastrales para cada municipio y año, y para el ICA se construirá una proxy del PIB*/
			
			/*Se calculará la tasa de crecimiento de las bases tributarias en promedios móviles Bi-Anuales. Primero se calculan las tasas de crecimiento entre un año y otro. 
			Posteriormente, se calculan los promedios móviles cada dos años. Por ejemplo, el dato del 2017 será el promedio de la tasa de crecimiento entre 2016 y 2017,
			el dato de 2016 será el promedio de la tasa de crecimiento entre 2015 y 2016, y así sucesivamente.
			Se calcularán las tasas de crecimiento desde el año 2000 únicamente, esto para homologar los periodos con las demás bases de datos*/
			
			
		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global convertidos_poblac	= 	"${pc}Data/Convertidos_Poblacion/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"	
		
		
		/*----------------------------------------*/
		/*   		PROPERTY TAX BASE GROWTH	  */
		/*----------------------------------------*/
		
			use "${convertidos_poblac}Total_1985_2050/Total_PANEL_Municipal_area_1985-2050.dta", clear				
						
			import excel using "${pc}Data/Avaluos_catastrales_capitales/Avaluos_catastrales_capitales.xlsx", clear sheet("Completo_Capitales_Urb_Rur_Tot") cellrange(A4) case(lower) firstrow
			rename (codigo año) (cod_dane year)
			destring cod_dane year, replace			
			drop m-q			
			format %15.0f urbano_avaluos rural_avaluos total_avaluos			
						
			/*Calculando las tasas de crecimiento*/
				tsset cod_dane year
				bysort cod_dane: gen crec_avaluo = (total_avaluos-l.total_avaluos)/l.total_avaluos	if year > 2010
			
			/*Calculando el Promedio Móvil Bi-Anual de las Tasas de Crecimiento Poblacional*/
				bysort cod_dane: gen crec_avaluo_prom_bianual = ((crec_avaluo+l.crec_avaluo)/2)*100	if year > 2010
			
			/*Etiquetando los codigos de municipio*/
			label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
											27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
											68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
											94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
			label values cod_dane cod_dane_lbl
							
			save "${pc}Data/Convertidos_Avaluos/Z_Indicadores_Insumos/Panel_Property_Tax_Base_Growth_2002_2017.dta", replace
			save "${indicadores}Panel_Property_Tax_Growth_2002_2017.dta", replace	
			
			/*Gráficos en el tiempo*/
			/*---------------------*/
			
			local capitales "8001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 
			/*FALTA INCLUIR A BOGOTÁ(11001) Y MEDELLÍN(5001)*/
			
				foreach x of local capitales {
					preserve
						keep if cod_dane== `x'
						tsset cod_dane year
						
						#delimit;
						twoway  (tsline crec_avaluo_prom_bianual if year > 2011, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
								/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
						scheme(mono)
						title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
						xtitle(" " "Año", size(small))   
						ytitle("Porcentaje" " ", axis(1) size(medsmall))
						/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
						xlabel(2012(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
						ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
						/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
						plotregion(color(white)) 
						graphregion(color(white) lcolor(white))
						legend(label (1 "Crecimiento del avalúo - promedio bianual") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
						name(crecim_avaluos_`x', replace)
						;
						#delimit cr
						
						graph export "${graficos}Tax_Base_Growth\Property_Tax_Base_Growth_Bianual_Average_`:label(cod_dane) `x''.pdf", as(pdf) replace
					restore	
				}						
						
			/*Gráficos de Barras para 2016-2017*/
			/*---------------------------------*/			
			#delimit;
			graph hbar crec_avaluo_prom_bianual if year == 2017, 
					over(cod_dane, sort(crec_avaluo_prom_bianual) descending gap(80) label(labsize(medsmall)))		
					scheme(mono)
					scale(*.7)																		/*Controla el Tamaño de la escala de los nombres de las ciudades*/
					ytitle("")																		/*Esto evita que tengamos el nombre de la variable como título del eje*/
					ylabel(0(5)30, format(%8.0fc) /*nogrid*/ glcolor(gs14) glwidth(vvthin) labsize(medium) angle(0))
					b1title("Porcentaje", size(medlarge) color(black))								/*Título del eje X*/
					l1title("")																		/*Título del Eje Izquierdo*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(off)
					name(crecim_avaluos_2016_2017, replace)	
			;			
						
			graph export "${graficos}Tax_Base_Growth\A----Property_Tax_Base_Growth_Bianual_Average_2016-2017.pdf", as(pdf) replace	
		
		
		/*----------------------------------------------------*/
		/*   		INDUSTRY AND COMMERCE TAX BASE GROWTH	  */
		/*----------------------------------------------------*/
		/*Nota: Se utilizarán dos bases de datos ya creadas anteriormente: Las Operaciones Efectivas de Caja y el PIB Departamental*/
		
		
		*****************
		* RUTA GENERAL  *
		*****************
		clear
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global convertidos_poblac	= 	"${pc}Data/Convertidos_Poblacion/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"	
		
			/*Leyendo la base del PIB*/
			/*Nota: Aquí se agregará, para cada Departamento, el impuesto pagado por ICA en los municipios.
			Posteriormente, se calculará la participación de cada municiío en la suma total.*/
			
			use "${pc}Data/Convertidos_Operac_Efect_Caja/Panel_Operaciones_Efectivas_Caja_Colombia_2000_2016.dta", clear				
			
			/*Dejando únicamente el ICA*/
			keep if cod_cuenta == "A1020"
			
			/*Se calcula y se extrae la suma del ICA para el total del departamento para cada año*/
			preserve
				collapse (sum) montos, by(cod_depto year)
				rename montos total_depto
				save "${pc}Data/Convertidos_Operac_Efect_Caja/Z_Indicadores_Insumos/Panel_ICA_Agregados_Departamentos_2000_2016.dta", replace
			restore
			
			/*Agregando la base anterior con los totales por departamento y por año, para calcular las participaciones municipales*/
			merge m:1 cod_depto year using "${pc}Data/Convertidos_Operac_Efect_Caja/Z_Indicadores_Insumos/Panel_ICA_Agregados_Departamentos_2000_2016.dta"
			drop _merge
			
			/*Calculando la participación del ICA de cada Departamento en el total del ICA del departamento*/
			gen particip_ica_mpios = montos/total_depto
			sort cod_depto cod_dane year
			
			/*Guardando el archivo con las participaciones de cada municipio en el ICA total de su departamento*/
			keep cod_depto cod_dane municipio year montos total_depto particip_ica_mpios
			label var	montos				"Monto del impuesto de Industria y Comercio(ICA) - Millones de pesos corrientes"
			label var 	total_depto			"Suma total del ICA de todos los municipios de cada departamento y de cada año - Millones de pesos corrientes"
			label var 	particip_ica_mpios	"Participación de cada municipio en el ICA total de su departamento, para cada año - Porcentaje"
			
			save "${pc}Data/Convertidos_Operac_Efect_Caja/Z_Indicadores_Insumos/Panel_Participacion_ICA_Mpios_en_Departamentos_2000_2016.dta", replace
		
			/*Adicionando a la anterior la base del PIB Departamental*/
			use "${pc}Data/Convertidos_Operac_Efect_Caja/Z_Indicadores_Insumos/Panel_Participacion_ICA_Mpios_en_Departamentos_2000_2016.dta", clear
			merge m:1 cod_depto year using "${pc}Data/Convertidos_DANE_PIB/Panel_PIB_Corrientes_Deptos_2000_2016/PANEL_PIB_TOTAL_Prec_Corrientes_Deptos_2000_2016"
			drop _merge
			
			/*Calculando la proxy del PIB Departamental*/
			gen pib_municipal_ica = pib_tot_deptal*particip_ica_mpios
			sort cod_dane year
			
			label var pib_municipal_ica		"PIB Municipal - Proxy calculado solo con el ICA - Millones de pesos corrientes"
			
			save "${pc}Data/Convertidos_Operac_Efect_Caja/Z_Indicadores_Insumos/Panel_PIB_Mpios_ICA_Prec_Corrientes_2000_2016.dta", replace

			/*Calculando las tasas de crecimiento*/
				tsset cod_dane year
				bysort cod_dane: gen crec_pib_mpios_ica = (pib_municipal_ica-l.pib_municipal_ica)/l.pib_municipal_ica	
			
			/*Calculando el Promedio Móvil Bi-Anual de las Tasas de Crecimiento*/
				bysort cod_dane: gen crec_pib_mpios_prom_bianual = ((crec_pib_mpios_ica+l.crec_pib_mpios_ica)/2)*100	
		
			/*Dejando solo la información de las capitales departamentales*/		
				/*Opción 1*/
				keep if inlist(cod_dane,5001,8001,11001,13001,15001,17001,18001,19001,20001,23001,27001,41001,44001,47001,50001,52001, ///
							54001,63001,66001,68001,70001,73001,76001,81001,85001,86001,88001,91001,94001,95001,97001,99001)
			
				/*Opción 2*/
				egen temp = anymatch(cod_dane), values(5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 ///	/*Crea una dummy para los codigos seleccionados*/
												54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001)
				keep if temp
				drop temp
				
			/*Etiquetando los codigos de municipio*/
			label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
											27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
											68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
											94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
			label values cod_dane cod_dane_lbl
			
			save "${pc}Data/Convertidos_Operac_Efect_Caja/Z_Indicadores_Insumos/Panel_PIBICATax_Growth_2002_2017.dta", replace
			
			keep cod_depto cod_dane municipio year crec_pib_mpios_ica crec_pib_mpios_prom_bianual
			save "${indicadores}Panel_PIBICATax_Growth_2002_2017.dta", replace	
		
		
			/*Gráficos en el tiempo*/
			/*---------------------*/
			
			local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 91001 94001 95001 97001 99001"		 
			/*FALTA INCLUIR A SAN ANDRÉS(88001). LA RAZÓN ES QUE NO ESTÁ INCLUIDA COMO MUNICIPIO EN LAS CUENTAS FISCALES(OPERACIONES EFECTIVAS DE CAJA DE DONDE TOMAMOS EL ICA), SINO COMO DEPARTAMENTO*/
			
				foreach x of local capitales {
					preserve
						keep if cod_dane== `x'
						tsset cod_dane year
						
						#delimit;
						twoway  (tsline crec_pib_mpios_prom_bianual if year > 2011, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
								/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
						scheme(mono)
						title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
						xtitle(" " "Año", size(small))   
						ytitle("Porcentaje" " ", axis(1) size(medsmall))
						/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
						xlabel(2012(1)2016,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
						ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
						/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
						plotregion(color(white)) 
						graphregion(color(white) lcolor(white))
						legend(label (1 "Crecimiento del pib municipal(ICA) - promedio bianual") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
						name(crecim_pib_mpios_`x', replace)
						;
						#delimit cr
						
						graph export "${graficos}Tax_Base_Growth\PIB(ICA)_Tax_Base_Growth_Bianual_Average_`:label(cod_dane) `x''.pdf", as(pdf) replace
					restore	
				}						
						
			/*Gráficos de Barras para 2016-2017*/
			/*---------------------------------*/			
			#delimit;
			graph hbar crec_pib_mpios_prom_bianual if year == 2016, 
					over(cod_dane, sort(crec_pib_mpios_prom_bianual) descending gap(80) label(labsize(medsmall)))		
					scheme(mono)
					scale(*.7)																		/*Controla el Tamaño de la escala de los nombres de las ciudades*/
					ytitle("")																		/*Esto evita que tengamos el nombre de la variable como título del eje*/
					ylabel(0(5)30, format(%8.0fc) /*nogrid*/ glcolor(gs14) glwidth(vvthin) labsize(medium) angle(0))
					b1title("Porcentaje", size(medlarge) color(black))								/*Título del eje X*/
					l1title("")																		/*Título del Eje Izquierdo*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(off)
					name(crecim_pib_mpios_2016_2017, replace)	
			;			
						
			graph export "${graficos}Tax_Base_Growth\A----PIB(ICA)_Tax_Base_Growth_Bianual_Average_2016-2017.pdf", as(pdf) replace
		
											
					
					/*************************************/
					/*************************************/
					/*************************************/
					/*-----------------------------------*/
					/*   	UNEMPLOYMENT RATE			 */
					/*-----------------------------------*/
					/*************************************/
					/*************************************/
					/*************************************/	
		
		
		
		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global desempleo		= 	"${pc}Data/Tasa de Desempleo/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"	
		
		
		/*----------------------------------*/
		/*		UNEMPLOYMENT RATE			*/
		/*----------------------------------*/
		
		use "${desempleo}TD_13_ciudades_ANUAL_2007_2017.dta", clear 
		rename  ano year
		save "${indicadores}TD_13_ciudades_ANUAL_2007_2017.dta", replace 
		
		local capitales "5 8 11 13 17 23 50 52 54 66 68 73 76"
		
		foreach x of local capitales {
			preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway (tsline td_tr_mv_dane if year > 2007, lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
		 					/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(s1mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Porcentaje" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2008(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, /*format(%10,0fc)*/  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Tasa desempleo") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(Unemployment_rate_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Unemployment_rate\Unemployment_rate_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		
		}
	
		
					/*****************************************************/
					/*****************************************************/
					/*****************************************************/
					/*---------------------------------------------------*/
					/* OWN-SOURCE REVENUES RELATIVE TO TOTAL REVENUES 	 */
					/*---------------------------------------------------*/
					/*****************************************************/
					/*****************************************************/
					/*****************************************************/	
					
					
					/*Nota: Own-source revenues/total revenues */
					
		
		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"			 
		
			/*------------------------*/
			/*  OWN-SOURCE REVENUES   */
			/*------------------------*/
			/*------------------------*/
			
		*NOTA: (Ingresos corrientes -transferencias)
		
		
		************************
		*  INGRESOS CORRIENTES *
		************************
	
		
	    use "${convertidos_fut}FUT_Ingresos/Z_PANELES/PANEL_INGRESOS/TODOS_MPIOS_Panel_Ingresos_hasta_2017.dta", clear
				
		preserve
			keep if  codigo == "TI.A "		/*Dejar el espacio al final de cada codigo xq aparece en el archivo original*/
			format nombre %20s
			drop presup_inicial presup_definitivo recaudo_efectivo otras_dest_porce_dest otras_dest_vlr_dest recau_sin_situ_de_fond total_ingresos
			gen ingr_corrientes = total_ingresos_modif if codigo == "TI.A "
		
		/*Generandolos valores en millones*/
			gen ingr_corrientes_mill = ingr_corrientes/1000
			
		/*Guardando la base de datos*/
				
			keep mpio cod_dane year ingr_corrientes_mill
			format ingr_corrientes_mill %12.0f
			save "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Corrientes_2008_2017.dta", replace 
		restore
		
		
		************************
		*    TRANSFERENCIAS    *
		************************
	
		keep if  codigo == "TI.A.2.6 " 	
		format nombre %20s
		drop presup_inicial presup_definitivo recaudo_efectivo otras_dest_porce_dest otras_dest_vlr_dest recau_sin_situ_de_fond total_ingresos
		gen transfers = total_ingresos_modif if codigo == "TI.A.2.6 "
		
		/*Generandolos valores en millones*/
		gen transfers_mill =  transfers/1000
	
		/*Guardando la base de datos*/
			
		keep mpio cod_dane year transfers_mill
		save "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Transferencias_2008_2017.dta", replace	
		
	      
		 /*MERGE*/

		 use "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Corrientes_2008_2017.dta", clear
			merge 1:1 cod_dane year using "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Transferencias_2008_2017.dta"
			drop _merge
			gen own_source_revenues = (ingr_corrientes_mill-transfers_mill)
			format own_source_revenues %12.0f
			keep mpio cod_dane year own_source_revenues 	
		 /*Etiquetando los codigos de municipio*/
		 label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		 label values cod_dane cod_dane_lbl
	
		 save "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Own_Source_Revenues_2008_2017.dta", replace
		
			/*------------------------*/
			/*  INGRESOS TOTALES      */
			/*------------------------*/
			/*------------------------*/
		
		
		*NOTA: se usa, el Panel_ingresos_totales guardado anteriormente en Z_Indicadores_Insumos,de la carpeta de FUT_Ingresos.*
		
			*"${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Totales_2008_2017.dta"
			
		*-------------------------------------------------------------------------------------------------------------------------*	
		
				/*****************************************************/
				/*---------------------------------------------------*/
				/* OWN-SOURCE REVENUES RELATIVE TO TOTAL REVENUES 	 */
				/*---------------------------------------------------*/
				
				
	  /* Haremos un merge con el panel anteriores para generar el indicador */
	   
	   use "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Own_Source_Revenues_2008_2017.dta"
	   merge 1:1 cod_dane year using "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Totales_2008_2017.dta"
	   drop _merge
	   
		
	/*Generando indicador y guardando*/
	
	   gen own_reven_tot_reven = (own_source_revenues/total_ingresos_modif_mill)*100
	   *format own_reven_tot_reven %12.0f
	   keep mpio cod_dane year own_reven_tot_reven 
	   save "${indicadores}Panel_Own_Source_Revenues_Relative_to_Total_Revenues_2008_2017.dta", replace
	   
	   
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001 81001 85001 86001 88001 91001 94001 95001 97001 99001"		 

		foreach x of local capitales {
			preserve
				keep if cod_dane== `x'
				tsset cod_dane year
				
				#delimit;
				twoway  (tsline own_reven_tot_reven if year > 2008 , lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
						/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
				scheme(s1mono)
				title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
				xtitle(" " "Año", size(small))   
				ytitle("Porcentaje" " ", axis(1) size(medsmall))
				/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
				xlabel(2009(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
				ylabel(, /*format(%10,0fc)*/  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
				/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
				plotregion(color(white)) 
				graphregion(color(white) lcolor(white))
				legend(label (1 "Own_Revenues_Total_Revenues") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
				name(Own_Rev_Tot_Reven_`x', replace)
				;
				#delimit cr
				
				graph export "${graficos}Own_Source_Revenues_Relative_to_Total_Revenues\Own_Source_Revenues_Relative_to_Total_Revenues_`:label(cod_dane) `x''.pdf", as(pdf) replace
			restore	
		
		}	
	   
					
					/*****************************************************/
					/*****************************************************/
					/*****************************************************/
					/*---------------------------------------------------*/
					/* 		     DEBT TO TAX RATIO						 */
					/*---------------------------------------------------*/
					/*****************************************************/
					/*****************************************************/
					/*****************************************************/		
					
		*NOTA: Size of debt/tax revenues*
			
			
		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"	
		
			/*------------------*/
			/*  	DEBT		*/
			/*------------------*/
			
			*revisar 
	
		/*NOTA: ARAUCA,SE PRESENTA COMO FORMULARIO VACIO,POR LO TANTO SE ELIMINA DE LA BASE*/
		
		
		use "${convertidos_fut}/FUT_Deuda_Publica/Z_PANELES/PANEL_DEUDA_PUBLICA/TODOS_MPIOS_Panel_Deuda_publica_hasta_2017.dta", clear  
		drop if mpio == "Arauca"
		keep if plazo >= .  
		drop if  codigo == "VAL " 	
		gen debt = saldo_deud_cier_vig_act if codigo == "DP "
		format debt %12.0f
		/*Generandolos valores en millones*/
		gen debt_mill =  debt/1000
		
		 /*Etiquetando los codigos de municipio*/
		 label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		 label values cod_dane cod_dane_lbl	
		
		
		/*Guardando la base de datos*/
			
		keep mpio cod_dane year debt_mill 
		save "${convertidos_fut}FUT_Deuda_Publica/Z_Indicadores_Insumos/Panel_Debt_2011_2017.dta", replace	
	
		
			/*------------------*/
			/*    TAX RATIO		*/
			/*------------------*/
						
		*use "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Tributarios_2008_2017.dta"
	
		
		/*-----------------------------------*/
		/* 		  DEBT TO TAX RATIO			 */
		/*-----------------------------------*/
		
		use "${convertidos_fut}FUT_Deuda_Publica/Z_Indicadores_Insumos/Panel_Debt_2011_2017.dta", clear 
		merge 1:1 cod_dane year using "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Tributarios_2008_2017.dta"
		drop _merge
		drop if year < 2011
		gen debt_tax_ratio = (debt_mill/ingresos_tribut_modif_mill)*100
		keep mpio cod_dane year debt_tax_ratio
		sort mpio cod_dane year
		save  "${indicadores}Panel_Debt_to_Tax_Ratio_2011_2017.dta", replace 
		
		*se elimino a arauca del local 
		
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001  85001 86001 88001 91001 94001 95001 97001 99001"		 

			foreach x of local capitales {
				preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline debt_tax_ratio if  year > 2011 , lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(s1mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Porcentaje" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2012(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Debt_to_Tax_Ratio") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(Debt_to_Tax_Ratio_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Debt_to_Tax_Ratio\Debt_to_Tax_Ratio_`:label(cod_dane) `x''.pdf", as(pdf) replace
				restore	
			
			}	
	   
		
					/*****************************************************/
					/*****************************************************/
					/*****************************************************/
					/*---------------------------------------------------*/
					/*  DEBT CHARGES RELATIVE TO OWN-SOURCE REVENUES     */
					/*---------------------------------------------------*/
					/*****************************************************/
					/*****************************************************/
					/*****************************************************/	
			*NOTA: Debt charges (including principal plus interest)/municipal revenues less transfers*
			*NOTA: En el fut_deuda_publica hay aproximadamente 10 ciudades con formularios vacios o no reporto informacion para cierytos años, por eso se generan missing.*
						
					
		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"		
					
		/*-----------------*/			
		/*  DEBT CHARGES   */
		/*-----------------*/
		*NOTA:Se tomara amortizaciones mas intereses pagados en la vigencia actual.*
		
	
		use "${convertidos_fut}/FUT_Deuda_Publica/Z_PANELES/PANEL_DEUDA_PUBLICA/TODOS_MPIOS_Panel_Deuda_publica_hasta_2017.dta", clear  
		drop if mpio == "Arauca"
		keep if plazo >= .  
		drop if  codigo == "VAL " 
		keep mpio cod_dane year interes_pagad_vig amort_pagad_vig
	
		format interes_pagad_vig amort_pagad_vig %12.0f
		/*Generandolos valores en millones*/
		gen amortiz_mill =  amort_pagad_vig/1000
		gen interes_mill =	interes_pagad_vig/1000
			
		 /*Etiquetando los codigos de municipio*/
		label define cod_dane_lbl		5001 "Medellín" 8001 "Barranquilla" 11001 "Bogotá" 13001 "Cartagena" 15001 "Tunja" 17001 "Manizales" 18001 "Florencia" 19001 "Popayán" 20001 "Valledupar" 23001 "Montería" ///
										27001 "Quibdó" 41001 "Neiva" 44001 "Riohacha" 47001 "Santa Marta" 50001 "Villavicencio" 52001 "Pasto" 54001 "Cúcuta" 63001 "Armenia" 66001 "Pereira" ///
										68001 "Bucaramanga" 70001 "Sincelejo" 73001 "Ibagué" 76001 "Cali" 81001 "Arauca" 85001 "Yopal" 86001 "Mocoa" 88001 "San Andrés" 91001 "Leticia" /// 
										94001 "Inírida" 95001 "San José del Guaviare" 97001 "Mitú" 99001 "Puerto Carreño" 
		label values cod_dane cod_dane_lbl	
		
		
		/*Generando numerador*/
		gen debt_charges = (amortiz_mill + interes_mill)
		sort mpio cod_dane year 
		
		/*Guardando la base de datos*/
			
		keep mpio cod_dane year debt_charges
		save "${convertidos_fut}FUT_Deuda_Publica/Z_Indicadores_Insumos/Panel_Debt_Charges_2011_2017.dta", replace	

		
			/*------------------------*/
			/*  OWN-SOURCE REVENUES   */
			/*------------------------*/
			/*------------------------*/
		* NOTA : se genero anteriormente * 
		*use "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Own_Source_Revenues_2008_2017.dta"	
		
		
		/*---------------------------------------------------*/
		/*  DEBT CHARGES RELATIVE TO OWN-SOURCE REVENUES     */
		/*---------------------------------------------------*/
		
		use "${convertidos_fut}FUT_Deuda_Publica/Z_Indicadores_Insumos/Panel_Debt_Charges_2011_2017.dta"
		merge 1:1 cod_dane year using "${convertidos_fut}FUT_Ingresos/Z_Indicadores_Insumos/Panel_Own_Source_Revenues_2008_2017.dta"
		drop _merge 
		drop if year < 2011
		
		
		/*Generando Indicador*/
		gen debt_char_own_reven = (debt_charges/ own_source_revenues)*100
		sort mpio cod_dane year 
		
		/*Guardando la base de datos*/
			
		keep mpio cod_dane year debt_char_own_reven 
		save "${indicadores}Panel_Debt_Charges_Own_Source_Revenues_2011_2017.dta", replace
		
		
		local capitales "5001 8001 11001 13001 15001 17001 18001 19001 20001 23001 27001 41001 44001 47001 50001 52001 54001 63001 66001 68001 70001 73001 76001  85001 86001 88001 91001 94001 95001 97001 99001"		 

			foreach x of local capitales {
				preserve
					keep if cod_dane== `x'
					tsset cod_dane year
					
					#delimit;
					twoway  (tsline debt_char_own_reven if  year > 2011 , lcolor(blue) lwidth(medthick) lpattern(solid) yaxis(1)) /*Lo ubica en el Eje Principal - Izquierdo*/
							/*(tsline total_predios, lcolor(cranberry) lwidth(medthick) lpattern(longdash) yaxis(2))*/,	/*Lo ubica en el eje secundario - Derecho*/
					scheme(s1mono)
					title("`:label(cod_dane) `x''", size(medsmall) lcolor(black))		/*Esta opción permite utilizar los labels de la variable. Sin el `x' al final, no toma el label*/	
					xtitle(" " "Año", size(small))   
					ytitle("Porcentaje" " ", axis(1) size(medsmall))
					/*ytitle(" " "Número de predios", axis(2) size(medsmall))*/
					xlabel(2012(1)2017,glcolor(gs14) glwidth(vvthin) labsize(small) angle(0)) 
					ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(1))		/*Controla el formato del Eje Principal*/
					/*ylabel(, format(%10,0fc)  nogrid glcolor(gs14) glwidth(vvthin) labsize(medsmall) angle(0) axis(2))*/		/*Controla el formato del Eje Secundario*/
					plotregion(color(white)) 
					graphregion(color(white) lcolor(white))
					legend(label (1 "Debt_to_Tax_Ratio") /*label (2 "Número de predios (izq)")*/ cols(1) ring(0) position(11) lcolor(white) size(small) region(lcolor(white))) /*ring(0) indica que el cuadro de legenda va dentro del gr⧩co, y position(7) en la parte inferior izquierda*/
					name(Debt_Char_Own_Reven_`x', replace)
					;
					#delimit cr
					
					graph export "${graficos}Debt_Charges_Relative_To_Own_Source_Revenues\Debt_Charges_Own_Revenues_`:label(cod_dane) `x''.pdf", as(pdf) replace
				restore	
			
			}	
	   

					/*****************************************************/
					/*****************************************************/
					/*****************************************************/
					/*---------------------------------------------------*/
					/*  				OPERATING DEFICIT     			*/
					/*---------------------------------------------------*/
					/*****************************************************/
					/*****************************************************/
					/*****************************************************/	
			/*NOTA: Este indicador se calcula como: (gasto total-componente de inflación del pago de intereses) - ingreso total.
					O lo que es igual: deficit convencional - componente de inflación edl pago de intereses*/
			/*Se requiere entonces la siguiente información: 	Ingreso total
																Gasto total
																Interses pagados
																Inflación*/
					
					
		*****************
		* RUTA GENERAL  *
		*****************
		global pc 				=	"//Cart1179376/Fiscal_Health_BID_Libro/"

		****************************************
		*  RUTAS A LOS DIRECTORIOS ESPECÍFICOS *
		****************************************	
		global convertidos_fut		= 	"${pc}Data/Convertidos_FUT/"
		global graficos				=	"${pc}Graficos/"
		global tablas				=	"${pc}Tablas/"	
		global indicadores			= 	"${pc}Data/Indicadores/"		
					
		
		/*--------------------------------------------------*/			
		/*  				INFLACIÓN						*/
		/*--------------------------------------------------*/
		
		FALTA DETERMINAR LA INFLACIÓN QUE SE USARÁ, ASÍ COMO EL PRIODO DE TIEMPO. VER TRABAJOS DE BRASIL Y MÉXICO A VER SI SOLO LO HACEN POR CIUDADES PARA EL 2017.
		O HACER AMBOS ESCENARIOS: 	1. DEFICIT USANDO LA INFLACIONAL NACIONAL PARA VARIOS AÑOS
									2. DEFICIT SOLOM PARA 2017 USANDO LA INFLACION DE 2017 POR CIUDADES - PREGUNTAR A MAYITO SI ESA INFO EXISTE POR CIUDADES PARA UN PERIODO MÁS LARGO
		
		
		
		
		
		
		
		
		
		/*--------------------------------------------------*/			
		/*  	INTERESES PAGADOS - VIGENCIA CORRIENTE		*/
		/*--------------------------------------------------*/
		/*Nota: Se tomará del FUT-Deuda Pública el rubro correspondiente a "Intesese Pagados en la Vigencia"*/
		/*No hay información para ARAUCA(81001) ni para INIRIDA(94001)*/
		
		use "${convertidos_fut}FUT_Deuda_Publica/Z_PANELES/PANEL_DEUDA_PUBLICA/TODOS_MPIOS_Panel_Deuda_publica_hasta_2017.dta", clear
		keep cod_dane mpio year codigo nombre num_reg_deud_minhac interes_pagad_vig
		sort cod_dane year
		
		/*Para dejar solamente el valor que corresponde al pago de intereses total de la vigencia corriente correspondiente*/
		bysort cod_dane year: keep if codigo== "VAL "
		
		collapse interes_pagad_vig, by(cod_dane year)	
		
		/*Psando el monto a millones*/
		gen interes_pagad_vig_mill = interes_pagad_vig/1000
		drop interes_pagad_vig
		lab var interes_pagad_vig_mill		"intereses pagados en la vigencia corriente - Millones de pesos corrientes"
		
		save "${convertidos_fut}FUT_Deuda_Publica/Z_Indicadores_Insumos/Panel_Interes_Pagados_hasta_2017.dta", replace
		
		/*------------------------------*/			
		/*  INGRESO TOTAL Y GASTO TOTAL */
		/*------------------------------*/
		*NOTA: Se toma de la base de FUT Ingresos*
			
		use "${convertidos_fut}/FUT_Ingresos/Z_Indicadores_Insumos/Panel_Ingresos_Totales_2008_2017.dta", clear  
		merge 1:1 cod_dane year using "${convertidos_fut}/FUT_Gasto_Total/Z_Indicadores_Insumos/Panel_Total_Expenditure_2008_2017.dta"
		drop _merge
		sort cod_dane year
		merge 1:1 cod_dane year using "${convertidos_fut}FUT_Deuda_Publica/Z_Indicadores_Insumos/Panel_Interes_Pagados_hasta_2017.dta"
		drop _merge
		
		/*FIN*/				
		
		
		
		
		
		
		
		
		
		
		
	
		
		
		
		
		
