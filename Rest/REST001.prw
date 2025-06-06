#include "protheus.ch"
#Include "RestFul.CH"
#include "topconn.ch"
#include "tbiconn.ch"

WSRESTFUL WebHookVindi DESCRIPTION "Serviço REST para WebHook VINDI" FORMAT APPLICATION_JSON

	//WSMETHOD POST DESCRIPTION "Serviço POST para WebHook VINDI" WSSYNTAX "/webhookvindi"
	WSMETHOD POST DESCRIPTION "Serviço POST para WebHook VINDI" WSSYNTAX "/webhookvindi"

END WSRESTFUL

WSMETHOD POST WSSERVICE WebHookVindi
	local cJson := ""

	set century on
	::SetContentType("application/json")

	oJson := JsonObject():new()

	//Recupera o body da requisicao em JSON
	cJson := ::GetContent()

	oJson:FromJson(cJson)

	If cJson != Nil

		Do Case
		Case oJson["event"]["type"] == "charge_rejected"
			oRecurrence := RejeitaWH(oJson)
			return .T.
		Case oJson["event"]["type"] == "bill_seen"
			oRecurrence := VisualizaWH(oJson)
			return .T.
		Case oJson["event"]["type"] == "bill_paid"
			oRecurrence := PagamentoWH(oJson)
			return .T.
		Case oJson["event"]["type"] == "test"
			Self:setStatus(200)
			return .T.
		EndCase

	else
		SetRestFault(204, Encondeutf8('{ message: "Não foi possível ler as informações" }'))
		return .F.
	endif

Return .T.
/*{Protheus.doc} RejeitaWH
Registra historico de Cobrança Rejeitada
@version  12.33
@author kleysongomes
@since 26/06/2023
*/
Static Function RejeitaWH(oJson)
	local cCodCli       := ""
	local cAcao         := ""
	local cMsgHist      := ""
	local cData_        := ""
	local oHistorico    := nil
	local oResponse     := nil

	conout('--------- RECEBENDO WEBHOOK VINDI ---------')

	cCodCli := ojson["event"]["data"]["charge"]["customer"]["code"]
	cAcao := decodeutf8(ojson["event"]["data"]["charge"]["last_transaction"]["gateway_message"],"cp1252")

	conout('--------- CONSULTANDO DADOS DA FATURA ---------')

	nIdBill := oJson["event"]["data"]["charge"]["bill"]["id"]
	oRecorrencia := RecorrenceVindi():new()
	jResponse := oRecorrencia:getInvoice(,,,nIdBill)

	If jResponse["errors"] != NIL
		conout('--------- FATURA NÃO LOCALIZADA ---------')
		Return oResponse
	EndIf

	cCode     := jResponse["bill"]["subscription"]["code"]
	cValor    := jResponse["bill"]["bill_items"][1]["pricing_schema"]["short_format"]
	cValor2   := jResponse["bill"]["bill_items"][1]["pricing_schema"]["price"]
	cParcela  := jResponse["bill"]["installments"]
	cData_    := jResponse["bill"]["charges"][1]["due_at"]

	aData_    := StrtokArr(cData_, "-")
	aDados    := StrtokArr(cCode, "@") //CONTRATO @ CLIENTE @ NEGOCIO @ EMPRESA @ FILIAL @ LOTE

	cAno      := aData_[1]
	cMes      := aData_[2]

	cContrato := aDados[1]
	cNegocio  := aDados[3]
	__cEmp    := aDados[4]
	__cFil    := aDados[5]

	conout('--------- GRAVANDO HISTORICO ---------')

	cMsgHist := "WEBHOOK VINDI - Transacao Rejeitada" + CRLF
	cMsgHist += REPLICATE( "-", 40 ) + CRLF
	cMsgHist += "Rotina de origem: WebHookVindi" + CRLF
	cMsgHist += "Uma tentativa de cobrança foi rejeitada" + CRLF
	cMsgHist += "Operação: "+ cAcao + CRLF
	cMsgHist += "Parcela: "+ cValToChar(cParcela) + CRLF
	cMsgHist += "Valor: "+ cValor + CRLF
	cMsgHist += "Data: " + Dtoc(DATE()) + CRLF
	cMsgHist += "Hora: " + Time() + CRLF

	conout(cMsgHist)

	oHistorico  := GmHistorico():New(cContrato, cCodCli, cNegocio)
	oResponse   := oHistorico:GravaHistorico(cMsgHist, .F., "0030")

	conout(oResponse)

	conout('--------- < HISTORICO REGISTRADO > ---------')

	conout('--------- < REGISTRANDO REJEICAO (SE1) > ---------')

	oMensalidade 	:= RecorrenceVindi():new()
	jMensalidade := oMensalidade:getBillsToReceive(/*idSubscription*/"",;
    /*contract*/cContrato,;
    /*idCustomer*/"",;
    /*client*/cCodCli,;
    /*year*/cAno,;
    /*month*/cMes,;
    /*value*/cValor2)

	If jMensalidade["error"] != Nil
		conout('--------- < ERRO AO REGISTRAR REJEICAO (SE1) > ---------')
		conout(jMensalidade["error"][2])

		Return oResponse
	EndIf

	conout(jMensalidade)

	SE1->( dbGoTo(jMensalidade["toReceive"]["recno"]))

	nAddRej := 1
	nAddRej += se1->e1_rejreco

	conout('--------- < ALTERANDO REGISTRO (SE1) > ---------')
	SE1->( Reclock("SE1",.F.) )
	se1->e1_rejreco := nAddRej
	SE1->( MsUnlock() )

	conout('--------- < REJEICAO REGISTRADA (SE1) > ---------')

Return oResponse

/*{Protheus.doc} VisualizaWH
Registra historico de Fatura Visualizada
@version  12.33
@author kleysongomes
@since 26/06/2023
*/
Static Function VisualizaWH(oJson)
	local cCodCli       := ""
	local cAcao       := ""
	local cMsgHist      := ""
	local oHistorico    := nil
	local oResponse     := nil

	conout('--------- RECEBENDO WEBHOOK VINDI ---------')

	cCodCli := ojson["event"]["data"]["bill"]["customer"]["code"]
	cAcao := "Fatura Visualizada"

	conout('--------- CONSULTANDO DADOS DA FATURA ---------')

	nIdBill := oJson["event"]["data"]["bill"]["id"]
	oRecorrencia := RecorrenceVindi():new()
	jResponse := oRecorrencia:getInvoice(,,,nIdBill)

	If jResponse["errors"] != NIL
		conout('--------- FATURA NÃO LOCALIZADA ---------')
		Return oResponse
	EndIf

	cCode     := jResponse["bill"]["subscription"]["code"]
	cValor    := jResponse["bill"]["bill_items"][1]["pricing_schema"]["short_format"]
	cParcela  := jResponse["bill"]["installments"]
	aDados    := StrtokArr(cCode, "@") //CONTRATO @ CLIENTE @ NEGOCIO @ EMPRESA @ FILIAL @ LOTE

	cContrato := aDados[1]
	cNegocio  := aDados[3]
	__cEmp    := aDados[4]
	__cFil    := aDados[5]

	conout('--------- GRAVANDO HISTORICO ---------')

	cMsgHist := "WEBHOOK VINDI - Fatura Visualizada" + CRLF
	cMsgHist += REPLICATE( "-", 40 ) + CRLF
	cMsgHist += "Rotina de origem: WebHookVindi" + CRLF
	cMsgHist += "A fatura foi visualizada" + CRLF
	cMsgHist += "Operação: "+ cAcao + CRLF
	cMsgHist += "Parcela: "+ cValToChar(cParcela) + CRLF
	cMsgHist += "Valor: "+ cValor + CRLF
	cMsgHist += "Data: " + Dtoc(DATE()) + CRLF
	cMsgHist += "Hora: " + Time() + CRLF

	conout(cMsgHist)

	oHistorico  := GmHistorico():New(cContrato, cCodCli, cNegocio)
	oResponse   := oHistorico:GravaHistorico(cMsgHist, .F., "0030")

	conout(oResponse)

	conout('--------- < REGISTRO REALIZADO > ---------')

Return oResponse

/*{Protheus.doc} PagamentoWH
Baixar fatura recorrencia
@version  12.33
@author Leonardo Monteiro
@since 07/07/2023
*/
Static Function PagamentoWH(oJson)
	local i := 0

	cCode     := oJson["event"]["data"]["bill"]["subscription"]["code"]
	cValor    := oJson["event"]["data"]["bill"]["amount"]
	cData     := oJson["event"]["data"]["bill"]["charges"][1]["created_at"]
	nPresta    := oJson["event"]["data"]["bill"]["installments"]
	aDados    := StrtokArr(cCode, "@") //CONTRATO @ CLIENTE @ NEGOCIO @ EMPRESA @ FILIAL @ LOTE
	aData_    := StrtokArr(cData, "-")

	cAno      := aData_[1]
	cMes      := aData_[2]


	cContrato := aDados[1]
	cCliente  := aDados[2]
	cNegocio  := aDados[3]
	__cEmp    := aDados[4]
	__cFil    := aDados[5]
	cParcela  := aDados[6]



	oMensalidade 	:= RecorrenceVindi():new()
	jMensalidade := oMensalidade:getBillsToReceive(/*idSubscription*/"",;
    /*contract*/cContrato,;
    /*idCustomer*/"",;
    /*client*/cCliente,;
    /*year*/cAno,;
    /*month*/cMes,;
    /*value*/cValor)

	if empty(jMensalidade["toReceive"]["recno"])
		errorMail(oJson, "Não achou a mensalidade")
		return .F.
	endif

	//Compania de pagamento
	jMensalidade['toReceive']['nPayment_companies'] := 12

	//Numero de autorização do pagamento
	jMensalidade['toReceive']['AUTORIZACAO'] := oJson["event"]["data"]["bill"]["charges"][1]["last_transaction"]["gateway_response_fields"]["proof_of_sale"]

	jMensalidade['toReceive']['DTBAIXA'] := Date()
	jMensalidade['toReceive']['MOTIVO_BAIXA'] := "CC"
	jMensalidade['toReceive']['PARCELAS'] := nPresta

	conout(jMensalidade["toReceive"]["contract"])

	oCtsReceber := GvCtsReceber():New( cNegocio )
	oCtsReceber:BaixaParcela( @jMensalidade["toReceive"] )

	if !jMensalidade["toReceive"]["STATUS"]
		errorMail(oJson, "Não foi possivel baixar o titulo")
		return .F.
	endif

	conout("Baixa executada com sucesso!")

	if cvaltochar(nPresta) = cParcela
		ZAM->(DbSetOrder(1))
		ZAM->(DbSeek(xFilial("ZAM") + cContrato))
		Reclock("ZAM", .F.)
		ZAM->ZAM_CLIEXT := " "
		ZAM->ZAM_ASSEXT := " "
		ZAM->(Msunlock())

		aParams := {__cEmp, __cFil, cContrato, cCliente, cNegocio}
		StartJob("U_criaRecr",GetEnvServer(),.T.,aParams)
	endif

return .T.



user function criaRecr(aParams)
	Local cContrato := aParams[3]
	Local cCliente := aParams[4]
	local cNegocio := aParams[5]
	jClient := JsonObject():New()

	oCtsReceber := GvCtsReceber():New( cNegocio )
	jMensali = oCtsReceber:GetMensalidades( cContrato, "", "AE")


	jClient["startAt"] := jMensali[1]["V_REAL"]
	jClient["contrt"] := cContrato
	jClient["client"] := cCliente
	jClient["business"] := cNegocio
	jClient["lote"] := ""
	jClient["price"] := jMensali[1]["VALOR"]
	jClient["planId"] := supergetmv('MS_VIPLANID',.T.,"77393")
	jClient["productId"] := supergetmv('MS_VIPRODID',.T.,"212295")
	jClient["nPayDay"] := right(jMensali[1]["V_REAL"],2)
	jClient["duration"] := len(jMensali)


	cteste := u_MORF956(jClient)

	conout(cteste)

return

static function errorMail(oJson, cMsg)
	local oStatus
	local cPath
	DEFAULT cMsg = ""


	cPath := "\log_vindi\logvindi" + DTOS(dDatabase) +".json"
	nHandle :=  FCreate(cPath)
	FWrite(nHandle, cValToChar(oJson))
	FClose(nHandle)

	oUtilities := GvUtility():New()
	oUtilities:SendMailAws("csti@email.com.br",;
		ENCODEUTF8("Error na baixa da parcela -> VINDI"),;
		"Segue em anexo o Json recebido pela vindi na baixa da parcela e a mensagem de error: " + cMsg,;
		"Morada da Paz <ola@email.com.br>",;
		cPath,;
		.T.,;
		@oStatus,;
		"protheus-recorrencia")

return
