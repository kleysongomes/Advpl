#INCLUDE "Protheus.ch"
#INCLUDE 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TopConn.ch"

/*{Protheus.doc} User Function ScreenXML
	 Tela MVC TABELA Z99 (Arquivos SX na pasta SRC > Files_sx)
	 @type  User Function
	 @author Kleyson Gomes
	 @since 14/01/2023
	 @version 12.33
	 @return */

User Function ScreenXML()

	Private aRotinaZ99   := MenuDef()
	private cTitulo      := "Importação de Arquivos XML"
	Private cTabela      := "Z99"
	Private cFilTop      := ""

	oBrowse:=FWMBrowse():New()

	dbSelectArea(cTabela)
	dbSetOrder(1)
	dbGoTop()

	oBrowse:SetFilterDefault(cFilTop)
	oBrowse:SetDescripition(cTitulo)
	oBrowse:SetAlias(cTabela)
	aColunas := {}
	oBrowse:Activate()

Return

//{Protheus.doc} MenuDef
//  @type  Static Function
//  @author Kleyson Gomes
//  @since 14/01/2023
//  @version 12.33
//  @param
// @return aRotinaZ99
//  @example

Static Function MenuDef()

	Local aRotinaZ99 := {}

	aAdd( aRotinaZ99, { 'Visualizar'	, 'VIEWDEF.ScreenXML', 0, 2, 0, NIL 	} )
	aAdd( aRotinaZ99, { 'Incluir' 		, 'VIEWDEF.ScreenXML', 0, 3, 0, NIL 	} )
	aAdd( aRotinaZ99, { 'Alterar' 		, 'VIEWDEF.ScreenXML', 0, 4, 0, NIL 	} )
	aAdd( aRotinaZ99, { 'Excluir' 		, 'VIEWDEF.ScreenXML', 0, 5, 0, NIL 	} )
	aAdd( aRotinaZ99,	{"CriaXML"			, "U_GeraXml()"			,	0,	18				}	)

Return aRotinaZ99

//{Protheus.doc} ModelDef
//  (long_description)
//  @type  Static Function
//  @author Kleyson Gomes
//  @since 15/01/2023
//  @version version
//  @param
//  @return oModel

Static Function ModelDef()

	Local oStructZ99 := FWFormStruct(1, 'Z99')
	Local oModel

	oModel := MPFormModel():New('Z99MODEL')
	oModel:AddFields('FIELDSZ99', ,oStructZ99)
	oModel:SetPrimaryKey({"Z99_FILIAL","Z99_SEQIMP"})
	oModel:SetDescription("Importação de Arquivos XML")

Return oModel

//{Protheus.doc} User Function legXml
//  @type  Static Function
//  @author Kleyson Gomes
//  @since 14/01/2023
//  @version 12.33
//  @return Nil

Static Function ViewDef()

	Local oModel := FWLoadModel('ScreenXML')
	Local oStruZ99  := FWFormStruct( 2, 'Z99' )

	oViewZ99 := FWFormView():New()
	oViewZ99:SetModel(oModel)
	oViewZ99:AddField('VIEW_Z99', oStruZ99, 'FIELDSZ99')
	oViewZ99:CreateHorizontalBox('TELA',100)
	oViewZ99:SetOwnerView('VIEW_Z99','TELA')

Return oViewZ99


User Function GeraXml()
	Local aArea := GetArea()
	Private cDirect := GetTempPath()
	Private cArquivo := "kleyson.xml"

	fCriaXML()

	fLeXML()

	RestArea(aArea)
Return


Static Function fCriaXML()
	Local nHdl := 0
	Local aArea := getArea()
	Local nAtu := 1

	nHdl := fCreate(cDirect + cArquivo)

	if nHdl == -1
		MsgStop("Não foi possível gerar o arquivo!")
		return
	endif

	BeginSql alias 'QRYZ99'

    Select Z99_SEQIMP, Z99_ARQUIV
    From %table:Z99% Z99

	EndSql

	if QRYZ99->(eof())
		MsgStop("Não há registros para exportar!")
		return
	endif

	fWrite(nHdl, "<?xml version='1.0' encoding='UTF-8'?>"	+Chr(13)+Chr(10))
	fWrite(nHdl, "<dados>"																+Chr(13)+Chr(10))
	fWrite(nHdl,"<data>"+dToC(dDataBase)+"</data>"				+Chr(13)+Chr(10))
	fWrite(nHdl,"<hora>"+Time()+"</hora>"									+Chr(13)+Chr(10))
	fWrite(nHdl,"<xml>"																		+Chr(13)+Chr(10))
	While !QRYZ99->(eof())
		fWrite(nHdl, '<registro id="'+cValToChar(nAtu)+'">'								+Chr(13)+Chr(10))
		fWrite(nHdl, "<sequencial>"+QRYZ99->Z99_SEQIMP+"</sequencial>"		+Chr(13)+Chr(10))
		fWrite(nHdl, "<arquivo>"+QRYZ99->Z99_ARQUIV+"</arquivo>"					+Chr(13)+Chr(10))
		fWrite(nHdl, "</registro>"+Chr(13)+Chr(10))

		nAtu++
		QRYZ99->(dbSkip())
	EndDo

	QRYZ99->(DbCloseArea())
	fWrite(nHdl, "</xml>"			+Chr(13)+Chr(10))
	fWrite(nHdl, "</dados>"		+Chr(13)+Chr(10))

	fClose(nHdl)

	ShellExecute("OPEN", cArquivo, "", cDirect, 0)

	RestArea(aArea)
Return

Static Function fLeXML()
	Local oLido    := Nil
	Local oProds   := Nil
	Local nAtual   := 0
	Local cReplace := "_"
	Local cErros   := ""
	Local cAvisos  := ""
	Local cMsg     := ""

    /* Verifica se o arquivo existe */
	If File(cDirect+cArquivo)
        /* Ler o arquvio via string */
		oLido := XmlParser(MemoRead(cDirect+cArquivo), cReplace, @cErros, @cAvisos)

        /* Verifica se houve erros e exibe*/
		If !Empty(cErros)
			Aviso('Atenção', "Erros: "+cErros, {'Ok'}, 03)
		EndIf

        /* Verifica se houve avisos e exibe*/
		If !Empty(cAvisos)
			Aviso('Atenção', "Avisos: "+cAvisos, {'Ok'}, 03)
		EndIf

        /* Montando mensagem de Data e Hora passados no Xml */
		cMsg := "Data: "	+oLido:_Dados:_Data:Text 		+Chr(13)+Chr(10)
		cMsg := "Hora: "	+oLido:_Dados:_Hora:Text 		+Chr(13)+Chr(10)

        /* Montando mensagem passada no Xml */
		oProds := oLido:_Dados:_xml:_registro
		For nAtual := 1 To Len(oProds)
			cMsg += "ID: "						+oProds[nAtual]:_id:Text+", "
			cMsg += "Sequencial: "		+oProds[nAtual]:_sequencial:Text+", "
			cMsg += "Arquivo: "				+oProds[nAtual]:_arquivo:Text
			cMsg += Chr(13)+Chr(10)
		Next

		//Mostrando a mensagem do xml lido
		Aviso('Atenção', cMsg, {'Ok'}, 03)
	EndIf
Return
