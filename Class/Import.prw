#include "Protheus.ch"
#include "TOTVS.ch"
#include "TopConn.ch"

/* {Protheus.doc} Class GmImporta
Classe para importação de arquivos e utilização
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Nil
*/
Class GmImportFile from GmImporta

	Private Data cFile__
	Private Data cOption
	Private Data jData
	Private Data nRow
	Private Data nCol
	Private Data lCreate
	Private Data aHeader
	Private Data cCodPro
	Private Data cSeller
	Private Data cClifat
	Private Data nQtCliFat
	Private Data nLenPlans
	Private Data cForPgt

	Private Data cCodCli
	Private Data cName
	Private Data cCpf
	Private Data dBirth
	Private Data cState
	Private Data cCodCity
	Private Data cCity
	Private Data cDistrict
	Private Data cZipCode
	Private Data cTAddress
	Private Data cAddress
	Private Data cNumber
	Private Data cComplem
	Private Data cPhone
	Private Data cPhone2
	Private Data cPhone3
	Private Data cEmail

	Public Method New() CONSTRUCTOR
	Public Method ImportFile()
	Private Method ImportCSV()
	Private Method ImportData()

	Private Method RegisterClient()
	Private Method RegisterPlans()
	Private Method SearchPlans()

	Private Method UpdateData()
	Private Method UpdateClient()
	Private Method UpdatePlans()

EndClass


/* {Protheus.doc} Método New
Método construtor da classe
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Self
*/
Method New(cFile__,cOption) Class GmImportFile
	::cFile__ := cFile__
	::cOption := cOption
	::jData  	:= JsonObject():New()
Return Self

/* {Protheus.doc} Método ImportFile
Método de importação do arquivo
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Nil
*/
Method ImportFile() Class GmImportFile
	Local cTypeFile          	:=  ""
	Local aArrFile          	:=  {}

  /* Recebe o caminho do arquivo e o tipo  */
	aArrFile                	:= StrtokArr(::cFile__,"\")
	aArrFile                	:= StrtokArr(aArrFile[Len(aArrFile)],".")
	cTypeFile                	:= Upper(Alltrim(aArrFile[Len(aArrFile)]))

	Do Case
	Case cTypeFile == "CSV"
		::ImportCSV()
	Case cTypeFile <> "CSV"
		MsInfo("Tipo de arquivo diferente de CSV, a rotina será encerrada!")
	EndCase


Return

/* {Protheus.doc} Método ImportCSV
Método de estruturação do arquivo em csv
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Nil
*/
Method ImportCSV() Class GmImportFile
	::jData["aErr"]    			:=  {}
	::jData["aSuccess"] 		:=  {}


  /* Abre o arquivo e ler o conteúdo e adiciona ao Json*/
	oFile := FwFileReader():New(::cFile__)
	If!(oFile:Open())
		MsInfo("Não foi possível abrir o arquivo!")
		Return
	EndIf

	::jData["aContent"] := oFile:GetAllLines()

	::ImportData()

Return

/* {Protheus.doc} Método ImportData
Método de montagem dos dados para o cadastramento
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Nil
#Estrutura obrigatória do arquivo: PLANO ESCOLHIDO X BENEFICIARIO	X CPF	X DATA DE NASCIMENTO X SEXO X CELULAR	X E-MAIL X CEP X UF X MUNICIPIO X BAIRRO X TIPO LOGRADOURO	X LOGRADOURO X NUMERO
*/
Method ImportData() Class GmImportFile
	Local aBox 	:=  {}
	Local aRet 	:=  {}

	::aHeader 	:= {}
	::lCreate		:= .T.

	aAdd(aBox,{1,"Código de cliente da Emp. ",Space(6),"","","SA1","",50,.T.})
	aAdd(aBox,{1,"Código Vendedor(a). ",Space(6),"","","SA3","",50,.T.})
	aAdd(aBox,{1,"Cond. Pagamento. ",Space(6),"","","SE4","",50,.T.})
	ParamBox(aBox,"Importação de Planos",@aRet)
	If len(aRet) <> 0
		::cClifat 	:= MV_PAR01
		::cSeller 	:= MV_PAR02
		::cForPgt		:= MV_PAR03
		SA1->( dbSetOrder(1) )
		If SA1->( dbSeek(::cClifat))
			MsgInfo("Informe um código de empresa válido!")
			return
		EndIf
	EndIf

	::SearchPlans()
	::nLenPlans := (len(::jData["aContent"])) - 1

	/* Percorre o arquivo quebra as colunas em linhas e valida cada campo */
	Aviso( "Atualização", "Processo de importação foi iniciado.", {"OK"}, 1, , , , , 5 )
	For  ::nRow := 1 to len(::jData["aContent"])
		::jData["aContent",::nRow] := StrtokArr2(::jData["aContent",::nRow], ",", .T.)

		If ::nRow == 1
			aHeader := ::jData["aContent", ::nRow]
			LOOP
		EndIf

		For ::nCol := 2 to len(::jData["aContent",::nRow])
			If Empty(::jData["aContent", ::nRow, ::nCol])
				aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Campo em branco' })
				::lCreate := .F.
				LOOP
			EndIf

			Do Case
			Case ::nCol == 3 /* Valida CPF */
				If !Len(::jData["aContent", ::nRow, ::nCol]) == 11
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválido' })
					::lCreate := .F.
				EndIf
			Case ::nCol == 4 /* Valida Data Nacimento */
				If !len(::jData["aContent", ::nRow, ::nCol]) == 10
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválido' })
					::lCreate := .F.
				EndIf
			Case ::nCol == 6 /* Valida número celular */
				If !len(::jData["aContent", ::nRow, ::nCol]) >= 11
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválido' })
					::lCreate := .F.
				EndIf
			Case ::nCol == 7 /* Valida e-mail */
				If !IsEmail(::jData["aContent", ::nRow, ::nCol])
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválido' })
					::lCreate := .F.
				EndIf
			Case ::nCol == 8 /* Valida CEP */
				If !len(::jData["aContent", ::nRow, ::nCol]) == 8
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválida' })
					::lCreate := .F.
				EndIf
			EndCase
		Next ::nCol

		/* Processa a execução da criação de cliente e inclusão do contrato */
		If ::lCreate
			Begin Transaction
				If ::RegisterClient(::jData["aContent",::nRow])
					If ::RegisterPlans(::jData)
						aAdd(::jData["aSuccess"], {"Successo" , ::jData["aContent",::nRow]})
					Else
						DisarmTransaction()
						aAdd(::jData["aErr"], {"errField", ::nRow, "Erro", 'Cadastro de Plano'})
					EndIf
				Else
					Add(::jData["aErr"], {"errField", ::nRow, "Erro", 'Cadastro de clientes'})
				EndIf
			End Transaction
		EndIf

		::lCreate := .T.
		LOOP
	Next ::nRow

	Aviso( "Finalizando", "Gerando resumo da importação.", {"OK"}, 1, , , , , 10 )
	If U_MORR1231(::jData, ::cOption)
		MsgInfo("WorkFlow com o resumo da importação enviado com sucesso!")
	EndIf
Return

/* {Protheus.doc} Método RegisterClient
Método de criação do cliente após imporatação do arquivo em csv (Opção 1)
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Nil
*/
Method RegisterClient(aClient) Class GmImportFile
		/* Valida se o cliente já existe e cria caso não */
	oCrCli := ClientesSA1():New()
	If Empty(oCrCli:getOrCreate(;
			aClient[2],; 	  		//cNome
		aClient[3],;		    //CPF
		aClient[8],;		    //CEP
		aClient[13],;	      //Logradouro
		aClient[9],;		    //Estado
		aClient[10],;	      //Cidade
		aClient[14],;	      //NumResi
		aClient[11],;	      //Bairro
		aClient[6],;		    //Telefone
		aClient[7],;		    //Email
		CTOD(aClient[4]),;	//Nascime
		aClient[5],))	      //Genero
		Return .F.
	EndIf
Return .T.

/* {Protheus.doc} Método RegisterPlans
Método de cadastro de plano após imporatação do arquivo em csv (Opção 1)
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Nil
*/
Method RegisterPlans(aPlans) Class GmImportFile
	Local cBasEmp 			:= "03" /* Para o filtro do cliente (SA1030) */
	Local aDepend 			:= {}
	::lCreate := .T.

	Private oContrato  	:= GvContratoPlano():New()

	Aviso( "Cadastro", "Gerando dados do contrato", {"OK"}, 1, , , , , 5 )

	::cCodPro 		:= Substr(aPlans["aContent",::nRow,1],1,6)
	::cName 			:= aPlans["aContent",::nRow,2]
	::cCpf 				:= aPlans["aContent",::nRow,3]
	::dBirth 			:= CTOD(aPlans["aContent",::nRow,4])
	::cPhone  		:= aPlans["aContent",::nRow,6]
	::cZipCode 		:= aPlans["aContent",::nRow,8]
	::cState 			:= aPlans["aContent",::nRow,9]
	::cCity 			:= aPlans["aContent",::nRow,10]
	::cDistrict 	:= aPlans["aContent",::nRow,11]
	::cTAddress		:= aPlans["aContent",::nRow,12]
	::cAddress 		:= aPlans["aContent",::nRow,13]
	::cNumber 		:= aPlans["aContent",::nRow,14]

	ZAM->( Reclock("ZAM", .T.) )

	SA3->( dbSetOrder(1) )
	SA3->( dbSeek(xFilial("SA3") + ::cSeller))

	If !Empty( ::cCodPro )
		SB1->( dbSetOrder(1) )
		If SB1->( dbSeek( xFilial("SB1") + ::cCodPro ) )
			ZAM->ZAM_VALOR := SB1->B1_PRV1
		Endif
	Endif

	/* Cria plano */
	ZAM->ZAM_FILIAL := xFilial("ZAM")
	ZAM->ZAM_CONTRT := GetSxeNum("ZAM","ZAM_CONTRT",,xFilial("ZAM") + "ZAM_CONTRT"  )
	ZAM->ZAM_LOJA   := "01"
	ZAM->ZAM_FILORI := xFilial("ZAM")

	ZAM->ZAM_CGC		:= ::cCpf
	ZAM->ZAM_NOMCLI	:= ::cName
	ZAM->ZAM_DTNAS	:= ::dBirth
	ZAM->ZAM_EMISSA := dDataBase
	ZAM->ZAM_CEP    := ::cZipCode
	ZAM->ZAM_EST 		:= ::cState
	ZAM->ZAM_CODMUN := ""
	ZAM->ZAM_MUNICI	:= ::cCity
	ZAM->ZAM_BAIRRO	:= ::cDistrict
	ZAM->ZAM_TLOG 	:= ::cTAddress
	ZAM->ZAM_END 		:= ::cAddress
	ZAM->ZAM_NUMERO := ::cNumber
	ZAM->ZAM_TELCEL	:= ::cPhone

	ZAM->ZAM_CODPRO	:= ::cCodPro
	ZAM->ZAM_STATUS := '0'
	ZAM->ZAM_CARFUN := DaySum( dDataBase , ZAM->ZAM_CARENC )
	ZAM->ZAM_DTATIV := dDataBase
	ZAM->ZAM_REGCON := ::cCodPro
	ZAm->ZAM_ORIGEM := "300004"
	ZAM->ZAM_CANVEN := "100099"
	ZAM->ZAM_DSORIG := "Outros"
	ZAM->ZAM_POSVEN := "N"

	::nQtCliFat += ::nLenPlans

	Do Case
	Case ::nQtCliFat < 2
		ZAM->ZAM_CARENC := 120
	Case  ::nQtCliFat >= 2 .and. ::nQtCliFat <= 100
		ZAM->ZAM_CARENC := 30
	Case ::nQtCliFat > 100
		ZAM->ZAM_CARENC := 0
	EndCase

	ZAM->ZAM_CODVEN := ::cSeller
	ZAM->ZAM_CODSUP := SA3->A3_SUPER
	ZAM->ZAM_CODGER := SA3->A3_GEREN
	ZAM->ZAM_DSVEND := SA3->A3_NOME

	ZAM->ZAM_CLIFAT	:= ::cClifat
	ZAM->ZAM_LJFAT  := "01"
	ZAM->ZAM_VLTOT  := ZAM->ZAM_VALOR
	ZAM->ZAM_CPAGPV := ::cForPgt
	ZAM->ZAM_FPAG		:= "4"
	ZAM->ZAM_FPGADE := "4"
	ZAM->ZAM_LOCPAG := "02"
	ZAM->ZAM_CPRCAR := "N"
	//ZAM->ZAM_DTPRIM	:= dDataBase

	ZFD->(dbsetorder(1))
	If ZFD->(dbseek(xfilial("ZFD") + ::cCodPro))
		ZAM->ZAM_DTVIGE := dDataBase + (ZFD->ZFD_VIGENC * 30)
	endif

	Aviso( "Cadastro", "Calculando valores do contrato: " + ZAM->ZAM_CONTRT, {"OK"}, 1, , , , , 5 )
	oContrato:CalculaPlano( aDepend	, 'RegisterPlans' )

	/*Valida dados e confirma o plano*/
	If Empty( ZAM->ZAM_CODCLI )
		oCrCli := ClientesSA1():New()
		::cCodCli := oCrCli:getOrCreate(ZAM->ZAM_NOMCLI, ZAM->ZAM_CGC,,,,,,, ZAM->ZAM_TELCEL,, ZAM->ZAM_DTNAS,,,cBasEmp)
		If Empty(::cCodCli)
			Return .F.
		EndIf

		ZAM->ZAM_CODCLI := ::cCodCli
	EndIf

	cHistIn := 'IMPORTAÇÂO DE CONTRATO - RESUMO' + CRLF
	cHistIn += Replicate("-",50) + CRLF
	cHistIn += "Data: "+ DTOC(ddatabase) + CRLF
	cHistIn += "Hora: "+ time() + CRLF
	cHistIn += "Usuário: "+ cUserName + CRLF
	cHistIn += "Regra Contratual: "+ZAM->ZAM_REGCON + CRLF
	cHistIn += "Plano: " + ZAM->ZAM_CODPRO + CRLF
	cHistIn += "Valor: " + Transform(ZAM->ZAM_VALOR,"@E 999,999,999.99") + CRLF
	cHistIn += "Tx Titular: " + Transform(ZAM->ZAM_VLTAXA,"@E 999,999,999.99") + CRLF
	cHistIn += "T O T A L: " + Transform(ZAM->ZAM_VLTOT,"@E 999,999,999.99") + CRLF
	cHistIn +=  CRLF + PADC("DADOS GERAIS DO CONTRATO",50) + CRLF
	cHistIn += Replicate("-",50) + CRLF

	While SX3->(! Eof()) .and. SX3->X3_ARQUIVO == "ZAM"
		If SX3->X3_CONTEXT == "V"
			SX3->(dbSkip())
			Loop
		EndIf
		cHistIn += Alltrim(SX3->X3_Titulo) + " == "+ cValToChar(&("ZAM->" + SX3->X3_CAMPO)) + CRLF
		SX3->(dbSkip())
	EndDo

	cHistIn += Replicate("-",50) + CRLF
	cHistIn += "Rotina que gerou o Historico: RegisterPlans(GmImportFile)" + CRLF
	If Date() # dDataBase
		cHistIn += "Contrato ativado com database retroativa, data real: " + dToC( Date() ) + CRLF
	EndIf
	cHistIn += Replicate("-",50) + CRLF

	oHistorico:= GmHistorico():New( ZAM->ZAM_CONTRT, ZAM->ZAM_CODCLI, 'PLANO' )
	oHistorico:GravaHistorico( cHistIn, .F., '0001')

	ZAM->( MsUnlock() )

	Aviso( "Ativação", "Ativando contrato: " + ZAM->ZAM_CONTRT, {"OK"}, 1, , , , , 5 )
	If !u_Ativacao()
		Aviso( "Ativação", "ATIVAÇÃO NÃO REALIZADA E PROCESSO CANCELADO!", {"OK"}, 1, , , , , 5 )
		Return .F.
	EndIf
	ConfirmSX8()
	Aviso( "Ativação", "Contrato: " + ZAM->ZAM_CONTRT + " ATIVADO!", {"OK"}, 1, , , , , 5 )

Return .T.

/* {Protheus.doc} Método SearchPlans
Método de busca de contratos do clifat para condição de carência
#Autor Kleyson Gomes
#Data 22/03/2023
#Versão 12.33
#return Nil
*/
Method SearchPlans() Class GmImportFile
	Local cClifat2 := ::cClifat

	/* Busca contratos do cliente */
	BeginSql alias 'QRYZAM'
		Select count(*) as QTD
		from %table:ZAM% ZAM
		where ZAM.D_E_L_E_T_ = ' '
		and ZAM.ZAM_CLIFAT = %exp:cClifat2%
	EndSql

	If QRYZAM->(!eof())
		::nQtCliFat := QRYZAM->QTD
	EndIf

	QRYZAM->(dbclosearea())

return
