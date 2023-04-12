#include "Protheus.ch"
#include "TOTVS.ch"
#include "TopConn.ch"

/* {Protheus.doc} Class ImportData
Classe para importação de arquivos e utilização
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Nil
*/
Class ImportFile from ImportData

	Private Data cFile__
	Private Data cOption
	Private Data jData
	Private Data nRow
	Private Data nCol
	Private Data lControl
	Private Data aHeader

	Public Method New() CONSTRUCTOR
	Public Method ImportFile()
	Private Method ImportCSV()
	Private Method ImportData()

EndClass


/* {Protheus.doc} Método New
Método construtor da classe
#Autor Kleyson Gomes
#Data 09/03/2023
#Versão 12.33
#return Self
*/
Method New(cFile__,cOption) Class ImportFile
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
Method ImportFile() Class ImportFile
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
Method ImportCSV() Class ImportFile
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
*/
Method ImportData() Class ImportFile
	::aHeader 	:= {}
	::lControl		:= .T.

	/* Trata cada linha do CSV */
	For  ::nRow := 1 to len(::jData["aContent"])
		::jData["aContent",::nRow] := StrtokArr2(::jData["aContent",::nRow], ",", .T.)

		If ::nRow == 1
			aHeader := ::jData["aContent", ::nRow]
			LOOP
		EndIf

		/* Trata cada campo*/
		For ::nCol := 2 to len(::jData["aContent",::nRow])
			If Empty(::jData["aContent", ::nRow, ::nCol])
				aAdd(::jData["aErr"], {"errField", ::nRow, aHeader[::nCol], 'Campo em branco' })
				::lControl := .F.
				LOOP
			EndIf
		Next ::nCol

		/* Trata a utlização de cada linha */
		If ::lControl
			Begin Transaction
				/*=======*/
			End Transaction
		EndIf

		::lControl := .T.
		LOOP
	Next
Return
