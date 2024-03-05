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
	Private Data cEmp__
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

	Private Data cSeq
	Private Data cIdCard
	Private Data nValueCard
	Private Data cTypeCard
	Private Data cObserver

	Public Method New() CONSTRUCTOR
	Public Method ImportFile()
	Private Method ImportCSV()
	Private Method ImportPlano()

	Private Method RegisterClient()
	Private Method RegisterPlans()
	Private Method SearchPlans()

	Private Method UpdateData()
	Private Method UpdateClient()
	Private Method UpdatePlans()
	Private Method UpdateJaz()

	Private Method ImportCard()
	Private Method RegisterCard()

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
		MsgInfo("Tipo de arquivo diferente de CSV, a rotina será encerrada!")
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

	Do Case
	Case ::cOption == "Importação de Plano Corporativo"
		::ImportPlano()
	Case ::cOption == "Atualização de Cliente"
		::UpdateData()
	Case ::cOption == "Importação Cartão Alimentação"
		::ImportCard()
	EndCase

	oFile:Close()

Return

/* {Protheus.doc} Método ImportPlano
Método de montagem dos dados para o cadastro de planos
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Nil
#Estrutura obrigatória do arquivo: PLANO ESCOLHIDO X BENEFICIARIO	X CPF	X DATA DE NASCIMENTO X SEXO X CELULAR	X E-MAIL X CEP X UF X MUNICIPIO X BAIRRO X TIPO LOGRADOURO	X LOGRADOURO X NUMERO
*/
Method ImportPlano() Class GmImportFile
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
		::jData["aContent",::nRow] := StrtokArr2(::jData["aContent",::nRow], ",", .T.) //Queraba a linha em array

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
					aAdd(::jData["aErr"], {"errField", ::nRow, "Erro", 'Cadastro de clientes'})
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
Método de criação do cliente após Importação do arquivo em csv (Opção 1)
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
Método de cadastro de plano após Importação do arquivo em csv (Opção 1)
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

	Z22->( Reclock("Z22", .T.) )

	SA3->( dbSetOrder(1) )
	SA3->( dbSeek(xFilial("SA3") + ::cSeller))

	If !Empty( ::cCodPro )
		SB1->( dbSetOrder(1) )
		If SB1->( dbSeek( xFilial("SB1") + ::cCodPro ) )
			Z22->Z22_VALOR := SB1->B1_PRV1
		Endif
	Endif

	/* Cria plano */
	Z22->Z22_FILIAL := xFilial("Z22")
	Z22->Z22_CONTRT := GetSxeNum("Z22","Z22_CONTRT",,xFilial("Z22") + "Z22_CONTRT"  )
	Z22->Z22_LOJA   := "01"
	Z22->Z22_FILORI := xFilial("Z22")

	Z22->Z22_CGC		:= ::cCpf
	Z22->Z22_NOMCLI	:= ::cName
	Z22->Z22_DTNAS	:= ::dBirth
	Z22->Z22_EMISSA := dDataBase
	Z22->Z22_CEP    := ::cZipCode
	Z22->Z22_EST 		:= ::cState
	Z22->Z22_CODMUN := ""
	Z22->Z22_MUNICI	:= ::cCity
	Z22->Z22_BAIRRO	:= ::cDistrict
	Z22->Z22_TLOG 	:= ::cTAddress
	Z22->Z22_END 		:= ::cAddress
	Z22->Z22_NUMERO := ::cNumber
	Z22->Z22_TELCEL	:= ::cPhone

	Z22->Z22_CODPRO	:= ::cCodPro
	Z22->Z22_STATUS := '0'
	Z22->Z22_CARFUN := DaySum( dDataBase , Z22->Z22_CARENC )
	Z22->Z22_DTATIV := dDataBase
	Z22->Z22_REGCON := ::cCodPro
	Z22->Z22_ORIGEM := "300004"
	Z22->Z22_CANVEN := "100099"
	Z22->Z22_DSORIG := "Outros"
	Z22->Z22_POSVEN := "N"

	::nQtCliFat += ::nLenPlans

	Do Case
	Case ::nQtCliFat < 2
		Z22->Z22_CARENC := 120
	Case  ::nQtCliFat >= 2 .and. ::nQtCliFat <= 100
		Z22->Z22_CARENC := 30
	Case ::nQtCliFat > 100
		Z22->Z22_CARENC := 0
	EndCase

	Z22->Z22_CODVEN := ::cSeller
	Z22->Z22_CODSUP := SA3->A3_SUPER
	Z22->Z22_CODGER := SA3->A3_GEREN
	Z22->Z22_DSVEND := SA3->A3_NOME

	Z22->Z22_CLIFAT	:= ::cClifat
	Z22->Z22_LJFAT  := "01"
	Z22->Z22_VLTOT  := Z22->Z22_VALOR
	Z22->Z22_CPAGPV := ::cForPgt
	Z22->Z22_FPAG		:= "4"
	Z22->Z22_FPGADE := "4"
	Z22->Z22_LOCPAG := "02"
	Z22->Z22_CPRCAR := "N"
	//Z22->Z22_DTPRIM	:= dDataBase

	ZFD->(dbsetorder(1))
	If ZFD->(dbseek(xfilial("ZFD") + ::cCodPro))
		Z22->Z22_DTVIGE := dDataBase + (ZFD->ZFD_VIGENC * 30)
	endif

	Aviso( "Cadastro", "Calculando valores do contrato: " + Z22->Z22_CONTRT, {"OK"}, 1, , , , , 5 )
	oContrato:CalculaPlano( aDepend	, 'RegisterPlans' )

	/*Valida dados e confirma o plano*/
	If Empty( Z22->Z22_CODCLI )
		oCrCli := ClientesSA1():New()
		::cCodCli := oCrCli:getOrCreate(Z22->Z22_NOMCLI, Z22->Z22_CGC,,,,,,, Z22->Z22_TELCEL,, Z22->Z22_DTNAS,,,cBasEmp)
		If Empty(::cCodCli)
			Return .F.
		EndIf

		Z22->Z22_CODCLI := ::cCodCli
	EndIf

	cHistIn := 'IMPORTAÇÂO DE CONTRATO - RESUMO' + CRLF
	cHistIn += Replicate("-",50) + CRLF
	cHistIn += "Data: "+ DTOC(ddatabase) + CRLF
	cHistIn += "Hora: "+ time() + CRLF
	cHistIn += "Usuário: "+ cUserName + CRLF
	cHistIn += "Regra Contratual: "+Z22->Z22_REGCON + CRLF
	cHistIn += "Plano: " + Z22->Z22_CODPRO + CRLF
	cHistIn += "Valor: " + Transform(Z22->Z22_VALOR,"@E 999,999,999.99") + CRLF
	cHistIn += "Tx Titular: " + Transform(Z22->Z22_VLTAXA,"@E 999,999,999.99") + CRLF
	cHistIn += "T O T A L: " + Transform(Z22->Z22_VLTOT,"@E 999,999,999.99") + CRLF
	cHistIn +=  CRLF + PADC("DADOS GERAIS DO CONTRATO",50) + CRLF
	cHistIn += Replicate("-",50) + CRLF

	While SX3->(! Eof()) .and. SX3->X3_ARQUIVO == "Z22"
		If SX3->X3_CONTEXT == "V"
			SX3->(dbSkip())
			Loop
		EndIf
		cHistIn += Alltrim(SX3->X3_Titulo) + " == "+ cValToChar(&("Z22->" + SX3->X3_CAMPO)) + CRLF
		SX3->(dbSkip())
	EndDo

	cHistIn += Replicate("-",50) + CRLF
	cHistIn += "Rotina que gerou o Historico: RegisterPlans(GmImportFile)" + CRLF
	If Date() # dDataBase
		cHistIn += "Contrato ativado com database retroativa, data real: " + dToC( Date() ) + CRLF
	EndIf
	cHistIn += Replicate("-",50) + CRLF

	oHistorico:= GmHistorico():New( Z22->Z22_CONTRT, Z22->Z22_CODCLI, 'PLANO' )
	oHistorico:GravaHistorico( cHistIn, .F., '0001')

	Z22->( MsUnlock() )

	Aviso( "Ativação", "Ativando contrato: " + Z22->Z22_CONTRT, {"OK"}, 1, , , , , 5 )
	If !u_Ativacao()
		Aviso( "Ativação", "ATIVAÇÃO NÃO REALIZADA E PROCESSO CANCELADO!", {"OK"}, 1, , , , , 5 )
		Return .F.
	EndIf
	ConfirmSX8()
	Aviso( "Ativação", "Contrato: " + Z22->Z22_CONTRT + " ATIVADO!", {"OK"}, 1, , , , , 5 )

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
	BeginSql alias 'QRYZ22'
		Select count(*) as QTD
		from %table:Z22% Z22
		where Z22.D_E_L_E_T_ = ' '
		and Z22.Z22_CLIFAT = %exp:cClifat2%
	EndSql

	If QRYZ22->(!eof())
		::nQtCliFat := QRYZ22->QTD
	EndIf

	QRYZ22->(dbclosearea())

return

/* {Protheus.doc} Método UpdateData
Método para atualização de dados cadastras de clientes após Importação do arquivo em csv (Opção 2)
Atualiza dados no contrato e no cadastro do cliente
#Autor Kleyson Gomes
#Data 14/03/2023
#Versão 12.33
#return Nil
#Estrutura obrigatória do arquivo: FILIAL X CONTRATO X CPF X NOME X	ENDEREÇO X NUMERO X CODIGO X MUNICIPIO X	BAIRRO X CIDADE X	UF X CEP X COMPLEMENTO X FONE ACIONAMENTO	X FONE 2 X FONE 3 X E-MAIL
*/
Method UpdateData() Class GmImportFile
	Local cColBkp := 0    /* Variavel extra para controle de campos obrigátorios */
	::aHeader := {}
	::lCreate := .T.

	/* Percorre o arquivo quebra as colunas em linhas e valida cada campo */
	Aviso( "Atualização", "Processo de atualização foi iniciado.", {"OK"}, 1, , , , , 5 )
	For  ::nRow := 1 to len(::jData["aContent"])
		::jData["aContent",::nRow] := StrtokArr2(::jData["aContent",::nRow], ",", .T.)

		If ::nRow == 1
			aHeader := ::jData["aContent", ::nRow]
			LOOP
		EndIf

		For ::nCol := 1 to len(::jData["aContent",::nRow])
			cColBkp := ::nCol
			If Empty(::jData["aContent", ::nRow, ::nCol])
				If !cValToChar(cColBkp) $ '1,12,15,16,17,18'
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Campo em branco' })
					::lCreate := .F.
				EndIf
			EndIf

			Do Case
			Case ::nCol == 3 /* Valida CPF */
				If !Len(::jData["aContent", ::nRow, ::nCol]) == 11
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválido' })
					::lCreate := .F.
				EndIf
			Case ::nCol == 13 /* Valida número celular */
				If !len(::jData["aContent", ::nRow, ::nCol]) >= 10
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválido' })
					::lCreate := .F.
				EndIf
			Case ::nCol == 11 /* Valida CEP */
				If !len(::jData["aContent", ::nRow, ::nCol]) == 8
					aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválida' })
					::lCreate := .F.
				EndIf
			Case ::nCol == 16 /* Valida e-mail */
				If !Empty( ::jData["aContent", ::nRow, ::nCol] )
					If !IsEmail(::jData["aContent", ::nRow, ::nCol])
						aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Inválido' })
						::lCreate := .F.
					EndIf
				EndIf
			EndCase
		Next ::nCol

		/* Processa a execução da atualização do cliente e Contratos */
		If ::lCreate
			If ::UpdateClient(::jData["aContent",::nRow])
				//Plano		
				If ::UpdatePlans(::jData)
					aAdd(::jData["aSuccess"], {"Successo" , ::jData["aContent",::nRow]})
				Else
					aAdd(::jData["aErr"], {"errField", ::nRow, "Ressalva", 'Cliente atualizado, porém o Contrato(Plano) não foi localizado'})
				EndIf
				//Jazigo
				If ::UpdateJaz(::jData["aContent",::nRow])
					aAdd(::jData["aSuccess"], {"Successo" , ::jData["aContent",::nRow]})
				Else
					aAdd(::jData["aErr"], {"errField", ::nRow, "Ressalva", 'Cliente atualizado, porém o Contrato(Jazigo) não foi localizado'})
				EndIf
				//Cremacao
				//UF
				//Pet
			Else
				aAdd(::jData["aErr"], {"errField", ::nRow, "Erro", 'Atualização de Cliente (ou cliente não localizado)'})
			EndIf
		EndIf
		::lCreate := .T.
		LOOP
	Next ::nRow

	Aviso( "Finalizando", "Gerando resumo da importação.", {"OK"}, 1, , , , , 10 )
	If u_MORR1231(::jData, ::cOption)
		MsgInfo("WorkFlow com o resumo da importação enviado com sucesso!")
	EndIf
Return

/* {Protheus.doc} Método UpdateClient
Método para atualização de dados cadastras de clientes após Importação do arquivo em csv (Opção 2)
#Autor Kleyson Gomes
#Data 14/03/2023
#Versão 12.33
#return Bool
*/
Method UpdateClient(aUpdateC) Class GmImportFile
	::cCpf 				:= aUpdateC[3]
	::cName 			:= aUpdateC[4]
	::cAddress 		:= aUpdateC[5]
	::cNumber 		:= aUpdateC[6]
	::cCodCity    := aUpdateC[7]
	::cDistrict 	:= aUpdateC[8]
	::cCity 			:= aUpdateC[9]
	::cState 			:= aUpdateC[10]
	::cZipCode 		:= aUpdateC[11]
	::cComplem 		:= aUpdateC[12]
	::cPhone 			:= aUpdateC[13]
	::cPhone2 		:= aUpdateC[14]
	::cPhone3 		:= aUpdateC[15]
	::cEmail 			:= aUpdateC[16]
	::dBirth			:= cToD(aUpdateC[17])

	SA1->(dbsetorder(3))
	If !SA1->( dbseek( xFilial( "SA1" ) + alltrim( ::cCpf ) ) )
		Return .F.
	EndIf

	::cCodCli := SA1->A1_COD

	Aviso( "Atualização", "Atualizando dados do cliente: " + SA1->A1_NOME, {"OK"}, 1, , , , , 5 )

	RecLock("SA1", .F.)
	SA1->A1_NOME 			:= ::cName

	If !(SA1->A1_CEP	== ::cZipCode .and. SA1->A1_END == ::cAddress .and. SA1->A1_NUMERO == ::cNumber)
		SA1->A1_COD_MUN 	:= ::cCodCity
		SA1->A1_CEP				:= ::cZipCode
		SA1->A1_NUMERO		:= ::cNumber
		SA1->A1_END				:= DecodeUTF8(::cAddress, 	"cp1252")
		SA1->A1_EST				:= DecodeUTF8(::cState, 		"cp1252")
		SA1->A1_MUN				:= DecodeUTF8(::cCity, 			"cp1252")
		SA1->A1_BAIRRO 		:= DecodeUTF8(::cDistrict, 	"cp1252")
		SA1->A1_COMPLEM		:= DecodeUTF8(::cComplem, 	"cp1252")
	EndIf

	SA1->A1_DTNASC 		:= ::dBirth
	SA1->A1_TEL 			:= ::cPhone
	SA1->A1_TELEX 		:= ::cPhone2
	SA1->A1_EMAIL 		:= ::cEmail


	SA1->(MsUnlock())

Return .T.

/* {Protheus.doc} Método UpdatePlans
Método para atualização de dados cadastrais do Plano após Importação do arquivo em csv (Opção 2)
#Autor Kleyson Gomes
#Data 14/03/2023
#Versão 12.33
#return Bool
*/
Method UpdatePlans(aUpdateP) Class GmImportFile

	Local cCPFsql := ::cCpf

	BeginSql alias 'QRYZ22'

		Select Z22_contrt as contrato
		From %table:Z22% Z22
		Where Z22_status = '1'
		and Z22_cgc = %Exp:cCPFsql%
		and Z22.d_e_l_e_t_ = ' '
		and Z22_filial = %xFilial:Z22%

	EndSql

	if QRYZ22->(eof())
		QRYZ22->(dbclosearea())
		Return .F.
	endif

	While QRYZ22->(!eof())

		Z22->(dbsetorder(1))
		Z22->( dbseek( xFilial( "Z22" ) + QRYZ22->contrato ) )

		Aviso( "Atualização", "Atualizando dados do contrato(Plano): " + QRYZ22->contrato, {"OK"}, 1, , , , , 5 )

		RecLock("Z22", .F.)

		If !(Z22->Z22_CEP	== ::cZipCode .and. Z22->Z22_END == ::cAddress .and. Z22->Z22_NUMERO == ::cNumber)
			Z22->Z22_CEP			:= ::cZipCode
			Z22->Z22_CODMUN 	:= ::cCodCity
			Z22->Z22_NUMERO 	:= ::cNumber
			Z22->Z22_EST			:= DecodeUTF8(::cState, 		"cp1252")
			Z22->Z22_MUNICI		:= DecodeUTF8(::cCity, 			"cp1252")
			Z22->Z22_BAIRRO 	:= DecodeUTF8(::cDistrict, 	"cp1252")
			Z22->Z22_END			:= DecodeUTF8(::cAddress, 	"cp1252")
			Z22->Z22_COMP			:= DecodeUTF8(::cComplem, 	"cp1252")
		EndIf

		Z22->Z22_DTNAS		:= ::dBirth
		Z22->Z22_TELRES		:= ::cPhone
		Z22->Z22_TELCEL 	:= ::cPhone2
		Z22->Z22_TELOUT		:= ::cPhone3

		Z22->(MsUnlock())
		QRYZ22->(dbskip())

	EndDo


	QRYZ22->(dbclosearea())

Return .T.

/* {Protheus.doc} Método UpdateJaz
Método para atualização de dados cadastrais do Contrato de Jazigo após Importação do arquivo em csv (Opção 2)
#Autor Kleyson Gomes
#Data 09/08/2023
#Versão 12.33
#return Bool
*/
Method UpdateJaz(aUpdateJ) Class GmImportFile

	Local cCPFsql := ::cCpf

	BeginSql alias 'QRYZ11'

		Select Z11_contrt as contrato
		From %table:Z11% Z11
		Where Z11_status = '1'
		and Z11_cgc = %Exp:cCPFsql%
		and Z11.d_e_l_e_t_ = ' '
		and Z11_filial = %xFilial:Z11%

	EndSql

	if QRYZ11->(eof())
		QRYZ11->(dbclosearea())
		Return .F.
	endif

	While QRYZ11->(!eof())

		Z11->(dbsetorder(1))
		Z11->( dbseek( xFilial( "Z11" ) + QRYZ11->contrato ) )

		Aviso( "Atualização", "Atualizando dados do contrato(Jazigo): " + QRYZ11->contrato, {"OK"}, 1, , , , , 5 )

		RecLock("Z11", .F.)

		If !(Z11->Z11_CEP	== ::cZipCode .and. Z11->Z11_END == ::cAddress .and. Z11->Z11_NUMERO == ::cNumber)
			Z11->Z11_CEP			:= ::cZipCode
			Z11->Z11_NUMERO 	:= ::cNumber
			Z11->Z11_EST			:= DecodeUTF8(::cState, 		"cp1252")
			Z11->Z11_MUNICI		:= DecodeUTF8(::cCity, 			"cp1252")
			Z11->Z11_BAIRRO 	:= DecodeUTF8(::cDistrict, 	"cp1252")
			Z11->Z11_END			:= DecodeUTF8(::cAddress, 	"cp1252")
			Z11->Z11_COMP			:= DecodeUTF8(::cComplem, 	"cp1252")
		EndIf

		Z11->Z11_DTNAS 		:= ::dBirth
		Z11->Z11_TELRES		:= ::cPhone
		Z11->Z11_TELCEL 	:= ::cPhone2
		Z11->Z11_TELOUT		:= ::cPhone3

		Z11->(MsUnlock())
		QRYZ11->(dbskip())

	EndDo


	QRYZ11->(dbclosearea())

Return .T.

/* {Protheus.doc} Método ImportCard
Método para atualização de dados cadastrais de cartão alimentação após Importação do arquivo em csv
#Autor Kleyson Gomes
#Data 29/08/2023
#Versão 12.33
#return Bool
*/
Method ImportCard() Class GmImportFile

	::aHeader 	:= {}
	::lCreate		:= .T.

	/* Percorre o arquivo quebra as colunas em linhas e valida cada campo */
	Aviso( "Importação", "Processo de importação foi iniciado.", {"OK"}, 1, , , , , 5 )
	For  ::nRow := 1 to len(::jData["aContent"])
		::jData["aContent",::nRow] := StrtokArr2(::jData["aContent",::nRow], ",", .T.) //Quebra a linha em array

		If ::nRow == 1
			aHeader := ::jData["aContent", ::nRow]
			LOOP
		EndIf

		For ::nCol := 1 to len(::jData["aContent",::nRow])-1
			If Empty(::jData["aContent", ::nRow, ::nCol])
				aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Campo em branco' })
				::lCreate := .F.
				LOOP
			EndIf
		Next ::nCol

		/* Processa a execução do cadastro do cartão */
		If ::lCreate
			Begin Transaction
				If ::RegisterCard(::jData["aContent",::nRow])
					aAdd(::jData["aSuccess"], {"Successo" , ::jData["aContent",::nRow]})
				Else
					aAdd(::jData["aErr"], {"errField", ::jData["aContent"][::nRow][2], "Erro", 'Cartão já cadastrado'})
				EndIf
			End Transaction
		EndIf

		::lCreate := .T.
		LOOP
	Next ::nRow

	Aviso( "Importação", "Gerando resumo da importação.", {"OK"}, 1, , , , , 10 )
	If U_MORR1231(::jData, ::cOption)
		MsgInfo("Resumo da importação enviado com sucesso!")
	EndIf
Return

/* {Protheus.doc} Método RegisterCard
Método de cadastro de cartões após Importação do arquivo em csv
#Autor Kleyson Gomes
#Data 29/08/2023
#Versão 12.33
#return Nil
*/
Method RegisterCard(aCards) Class GmImportFile

	::cSeq       := U_GETSEQ("Z36","Z36_SEQUEN")                                                                                                    
	::cIdCard    := aCards[1]
	::nValueCard := Val(aCards[2])
	::cTypeCard  := aCards[3]
	::cObserver  := aCards[4]

	cIdcard_ := ::cIdCard
	cfi := xFilial("Z36")
	lRet := .T.

	BeginSql alias 'QRYZ36'

		Select z36.z36_idcard as idcard
		From %table:z36% z36
		Where z36.d_e_l_e_t_ = ' '
		and z36_filial = %Exp:cfi%
		and z36_idcard = %Exp:cIdcard_%
		and z36_status = 'A'

	EndSql

	If QRYZ36->(!eof())
		Aviso( "Importação", "Id já cadastrado: "+::cIdCard, {"OK"}, 1, , , , , 5 )
		lRet := .F.
	Else
		Aviso( "Importação", "Cadastrando cartão: "+::cIdCard, {"OK"}, 1, , , , , 5 )

		Z36->( Reclock("Z36", .T.) )

		Z36->Z36_FILIAL := xFilial("Z36")
		Z36->Z36_SEQUEN := ::cSeq
		Z36->Z36_IDCARD := alltrim(::cIdCard)
		Z36->Z36_VALOR  := ::nValueCard
		Z36->Z36_STATUS := "A"
		Z36->Z36_TIPO   := ::cTypeCard

		Z36->Z36_DTINCL := dDataBase
		Z36->Z36_USRINC := alltrim(cUserName)
		Z36->Z36_OBSERV := alltrim(::cObserver)

		Z36->( MsUnlock() )
		ConfirmSX8()
	EndIf

	QRYZ36->(dbclosearea())
Return lRet
