#INCLUDE "Protheus.ch"
#INCLUDE 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TopConn.ch"


User Function generatesXml()
	Local aArea := GetArea()
	Private cDirect := GetTempPath()
	Private cArquivo := "kleyson.xml"

	createXml()

	readXml()

	RestArea(aArea)
Return


Static Function createXml()
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

	fWrite(nHdl, "<?xml version='1.0' encoding='UTF-8'?>"+Chr(13)+Chr(10))
	fWrite(nHdl, "<dados>"+Chr(13)+Chr(10))
	fWrite(nHdl,"<data>"+dToC(dDataBase)+"</data>"+Chr(13)+Chr(10))
	fWrite(nHdl,"<hora>"+Time()+"</hora>"+Chr(13)+Chr(10))
	fWrite(nHdl,"<xml>"+Chr(13)+Chr(10))
	While !QRYZ99->(eof())
		fWrite(nHdl, '<registro id="'+cValToChar(nAtu)+'">'+Chr(13)+Chr(10))
		fWrite(nHdl, "<sequencial>"+QRYZ99->Z99_SEQIMP+"</sequencial>"+Chr(13)+Chr(10))
		fWrite(nHdl, "<arquivo>"+QRYZ99->Z99_ARQUIV+"</arquivo>"+Chr(13)+Chr(10))
		fWrite(nHdl, "</registro>"+Chr(13)+Chr(10))

		nAtu++
		QRYZ99->(dbSkip())
	EndDo

	QRYZ99->(DbCloseArea())
	fWrite(nHdl, "</xml>"+Chr(13)+Chr(10))
	fWrite(nHdl, "</dados>"+Chr(13)+Chr(10))

	fClose(nHdl)

	ShellExecute("OPEN", cArquivo, "", cDirect, 0)

	RestArea(aArea)
Return

Static Function readXml()
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
		cMsg := "Data: "+oLido:_Dados:_Data:Text + Chr(13)+Chr(10)
		cMsg := "Hora: "+oLido:_Dados:_Hora:Text + Chr(13)+Chr(10)

    /* Montando mensagem passada no Xml */
		oProds := oLido:_Dados:_xml:_registro
		For nAtual := 1 To Len(oProds)
			cMsg += "ID: "+oProds[nAtual]:_id:Text+", "
			cMsg += "Sequencial: "+oProds[nAtual]:_sequencial:Text+", "
			cMsg += "Arquivo: "+oProds[nAtual]:_arquivo:Text
			cMsg += Chr(13)+Chr(10)
		Next

		//Mostrando a mensagem do xml lido
		Aviso('Atenção', cMsg, {'Ok'}, 03)
	EndIf
Return
