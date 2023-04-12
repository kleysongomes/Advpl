#include "Protheus.ch"
#include "TOTVS.ch"
#include "TopConn.ch"

/* {Protheus.doc} Class ImportData
Classe para importa��o de arquivos e utiliza��o
#Autor Kleyson Gomes
#Data 09/03/2023
#Vers�o 12.33
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


/* {Protheus.doc} M�todo New
M�todo construtor da classe
#Autor Kleyson Gomes
#Data 09/03/2023
#Vers�o 12.33
#return Self
*/
Method New(cFile__,cOption) Class ImportFile
	::cFile__ := cFile__
	::cOption := cOption
	::jData  	:= JsonObject():New()
Return Self

/* {Protheus.doc} M�todo ImportFile
M�todo de importa��o do arquivo
#Autor Kleyson Gomes
#Data 09/03/2023
#Vers�o 12.33
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
		MsInfo("Tipo de arquivo diferente de CSV, a rotina ser� encerrada!")
	EndCase


Return

/* {Protheus.doc} M�todo ImportCSV
M�todo de estrutura��o do arquivo em csv
#Autor Kleyson Gomes
#Data 09/03/2023
#Vers�o 12.33
#return Nil
*/
Method ImportCSV() Class ImportFile
	::jData["aErr"]    			:=  {}
	::jData["aSuccess"] 		:=  {}


  /* Abre o arquivo e ler o conte�do e adiciona ao Json*/
	oFile := FwFileReader():New(::cFile__)
	If!(oFile:Open())
		MsInfo("N�o foi poss�vel abrir o arquivo!")
		Return
	EndIf

	::jData["aContent"] := oFile:GetAllLines()

	::ImportData()

Return

/* {Protheus.doc} M�todo ImportData
M�todo de montagem dos dados para o cadastramento
#Autor Kleyson Gomes
#Data 09/03/2023
#Vers�o 12.33
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

		/* Trata a utliza��o de cada linha */
		If ::lControl
			Begin Transaction
				/*=======*/
			End Transaction
		EndIf

		::lControl := .T.
		LOOP
	Next
Return
