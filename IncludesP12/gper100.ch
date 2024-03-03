#ifdef SPANISH
	#define STR0001 "Informe por codigo"
	#define STR0002 "Se imprimira de acuerdo con los param. solicitados por el"
	#define STR0003 "usuario."
	#define STR0004 "Matricula"
	#define STR0005 "Centro de costo"
	#define STR0006 "Nomb"
	#define STR0007 "A Rayas"
	#define STR0008 "Administrac."
	#define STR0009 "Salir"
	#define STR0010 "Confirma"
	#define STR0011 "VALORES POR CODIGO "
	#define STR0012 "VALORES POR CODIGO "
	#define STR0013 "DE LIQ."
	#define STR0014 "DE 2ª CUOTA AGUINALDO "
	#define STR0015 "DE VALORES EXTRAS"
	#define STR0016 "¿Debe compr. los caract de la impres. a 18 CPI?"
	#define STR0017 "¿Debe compr. caract. de la impres. a 18 CPI?"
	#define STR0018 "                                                     |- INGRESO / DESCUENTO -|"
	#define STR0019 "SC C COSTO              MAT.   NOMBRE                               COD DESCRIPCION         HORAS         V A L O R"
	#define STR0020 "SUC MATR  NOMB"
	#define STR0021 "        V A L O R"
	#define STR0022 "    HORAS"
	#define STR0023 "        T O T A L"
	#define STR0024 "T O T A L"
	#define STR0025 "Empresa: "
	#define STR0026 "D E L   E M P L E A D O            "
	#define STR0027 "D E L   C E N T R O  D E  C O S T O"
	#define STR0028 "D E   L A   S U C U R S A L        "
	#define STR0029 "D E   L A   E M P R E S A          "
	#define STR0030 "SUELDO BASE    "
	#define STR0031 "T O T A L"
	#define STR0032 "SUEL BASE"
	#define STR0033 "    ( Orden: "
	#define STR0034 "TOTAL NETO  "
	#define STR0035 ""
	#define STR0036 "No es posible listar mas de 7 codigos en la horizontal, cuando estos se solicitan en valores y se solicita la impresion del total neto o salario base"
	#define STR0037 "Semana"
	#define STR0038 "BASE "
	#define STR0039 "BS."
	#define STR0040 "HORAS "
	#define STR0041 "HS."
	#define STR0042 "HORA EXTRA"
	#define STR0043 "HE. "
	#define STR0044 "FI"
	#define STR0045 "C.COSTO"
	#define STR0046 "MATR."
	#define STR0047 "NOMBRE"
	#define STR0048 "COD DESCRIPCION"
	#define STR0049 "HORAS"
	#define STR0050 "V A L O R"
	#define STR0051 "|- REMUNERACIONES/DESCUENTO -|"
	#define STR0052 "C.Costo del Mvto"
#else
	#ifdef ENGLISH
		#define STR0001 "Report by Code"
		#define STR0002 "Will be printed according to the parameters selected by  "
		#define STR0003 "the User."
		#define STR0004 "Registrat"
		#define STR0005 "Cost Center    "
		#define STR0006 "Name"
		#define STR0007 "Z.Form "
		#define STR0008 "Management   "
		#define STR0009 "Quit    "
		#define STR0010 "Confirm "
		#define STR0011 "AMOUNTS PER CODE   "
		#define STR0012 "AMOUNTS PER CODE   "
		#define STR0013 "OF SHEET "
		#define STR0014 "OF 2ND PARCEL  13TH SAL."
		#define STR0015 "OF SURPLUS AMOUNTS"
		#define STR0016 "Is it necessary to compact the Printer to 18 CPI?"
		#define STR0017 "Is it necessary to compact printer to 18 CPI ?"
		#define STR0018 "                                                       |- REVENUE /DISCOUNT -|"
		#define STR0019 "FI C.CENTER             REGIS  NAME                                 DESCRIPT.CODE           HORAS         V A L O R"
		#define STR0020 "FI C.CENTER  REGIS  NAME                   "
		#define STR0021 "        A M O U N T"
		#define STR0022 "    HOURS"
		#define STR0023 "        T O T A L"
		#define STR0024 "T O T A L"
		#define STR0025 "Company: "
		#define STR0026 "O F     E M P L O Y E E            "
		#define STR0027 "O F     C O S T   C E N T E R      "
		#define STR0028 "O F     B R A N C H                "
		#define STR0029 "O F     C O M P A N Y              "
		#define STR0030 "BASE SALARY    "
		#define STR0031 "T O T A L"
		#define STR0032 "BASE SAL."
		#define STR0033 "    ( Order: "
		#define STR0034 "NET TOTAL"
		#define STR0035 ""
		#define STR0036 "It is not possible to list more than 7 Codes in Line (Horizontally), when those are expressed by values, and the printing of Net Total or Base Salary is ordered."
		#define STR0037 "Week"
		#define STR0038 "BASE "
		#define STR0039 "BS."
		#define STR0040 "HOURS "
		#define STR0041 "HS."
		#define STR0042 "OVERTIME   "
		#define STR0043 "HE. "
		#define STR0044 "FI"
		#define STR0045 "COST C."
		#define STR0046 "REGISTRATION"
		#define STR0047 "NAME"
		#define STR0048 "DESCRIPTION CD"
		#define STR0049 "HOUR"
		#define STR0050 "V A L U E"
		#define STR0051 "|- REVENUE/DISCOUNT -|"
		#define STR0052 "Mov. Cost C."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Relatório por código", "Relatorio por Codigo" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Será impresso de acordo com os parâmetros solicitados pelo", "Será impresso de acordo com os parametros solicitados pelo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "utilizador.", "usuário." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Registo", "Matricula" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Centro De Custo", "Centro de Custo" )
		#define STR0006 "Nome"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Administração", "Administraçäo" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Abandonar", "Abandona" )
		#define STR0010 "Confirma"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Valores por código ", "VALORES POR CODIGO " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Valores por código ", "VALORES POR CODIGO " )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Da folha ", "DA FOLHA " )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Da 2a. Parcela Sub.Natal", "DA 2a. PARCELA 13o. SAL." )
		#define STR0015 "DE VALORES EXTRAS"
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "É preciso compactar a impressora para 18 CPI ?", "E' preciso Compactar a Impressora para 18 CPI ?" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "É preciso compactar a impressora para 18 cpi ?", "É preciso Compactar a Impressora para 18 CPI ?" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "                                                       |- REMUNER./DESCONTO -|", "                                                       |- PROVENTO/DESCONTO -|" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "FI C.CUSTO              REG.  NOME                                  CÓD.DESCRIÇÃO           HORAS         V A L O R", "FI C.CUSTO              MATR.  NOME                                 COD DESCRICAO           HORAS         V A L O R" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Fi Registo  Nome", "FI MATR.  NOME" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Valor", "        V A L O R" )
		#define STR0022 "    HORAS"
		#define STR0023 "        T O T A L"
		#define STR0024 "T O T A L"
		#define STR0025 "Empresa: "
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "D O     E M P R E G A D O          ", "D O     F U N C I O N A R I O      " )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "D O   C E N T R O   D E   C U S T O", "D O     C E N T R O  D E  C U S T O" )
		#define STR0028 "D A     F I L I A L                "
		#define STR0029 "D A     E M P R E S A              "
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "REMUNERAÇÃO BASE   ", "SALARIO BASE   " )
		#define STR0031 "T O T A L"
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "REM. BASE", "SAL. BASE" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "    ( ordem: ", "    ( Ordem: " )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "TOTAL LÍQUIDO   ", "TOTAL LIQUIDO   " )
		#define STR0035 ""
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Não é possível listar mais do que 7 códigos na horizontal, quando os mesmos forem solicitados em valores é requerida a impressão do total líquido ou remuneração base", "Nao e possivel listar mais do que 7 Codigos na Horizontal,quando os mesmos forem solicitados em valores e solicitada a impressao do Total Liquido ou Salario Base" )
		#define STR0037 "Semana"
		#define STR0038 "BASE "
		#define STR0039 "BS. "
		#define STR0040 "HORAS "
		#define STR0041 "HS. "
		#define STR0042 "HORA EXTRA "
		#define STR0043 "HE. "
		#define STR0044 "FI"
		#define STR0045 "C.CUSTO"
		#define STR0046 "MATR."
		#define STR0047 "NOME"
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "CÓD.DESCRIÇÃO", "COD DESCRICAO" )
		#define STR0049 "HORAS"
		#define STR0050 "V A L O R"
		#define STR0051 "|- PROVENTO/DESCONTO -|"
		#define STR0052 "C.Custo do Movto"
	#endif
#endif
