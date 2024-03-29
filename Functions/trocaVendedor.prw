#include 'Totvs.ch'
#INCLUDE 'TOPCONN.CH'

/*{Protheus.doc} User Function trocaVendedor
  Valida solicita��o de troca de vendedor
  @type  User Function
  @author Kleson Gomes
  @since 09/01/2023
  @version 12.33
  @param 
  @return .T.
  */
User Function trocaVendedor(jDados)
  /* Monta os dados para o Workflow */
  jDados['Empresa']                     := cEmpAnt 
  jDados['Filial']                      := cFilAnt
  jDados['Solicitante']                 := __cUserId 
  jDados['Nome_Solicitante']            := UsrRetName(__cUserId)

  jDados['Nome_Vendedor_Atual']         := POSICIONE("SA3",1,XFILIAL("SA3") + jDados['Vendedor_Atual']        ,"A3_NOME" )
  jDados['Nome_Lider_Atual']            := POSICIONE("SA3",1,XFILIAL("SA3") + jDados['Lider_Atual']           ,"A3_NOME" )
  jDados['Nome_Supervisor_Atual']       := POSICIONE("SA3",1,XFILIAL("SA3") + jDados['Supervisor_Atual']      ,"A3_NOME" )

  jDados['Lider_Novo'] 	                := POSICIONE("SA3",1,XFILIAL("SA3") + jDados['Vendedor_Novo']         ,"A3_SUPER")
  jDados['Supervisor_Novo'] 	          := POSICIONE("SA3",1,XFILIAL("SA3") + jDados['Vendedor_Novo']         ,"A3_GEREN")

  jDados['Nome_Vendedor_Novo']          := POSICIONE("SA3",1,XFILIAL("SA3") + jDados['Vendedor_Novo']         ,"A3_NOME" )
  jDados['Nome_Lider_Novo']             := POSICIONE("SA3",1,XFILIAL("SA3") + jDados['Lider_Novo']            ,"A3_NOME" )
  jDados['Nome_Supervisor_Novo']        := POSICIONE("SA3",1,XFILIAL("SA3") + jDados['Supervisor_Novo']       ,"A3_NOME" )

  /* Chamada da rotina que trata o Workflow e envia os dados para o e-mail */
  FWMsgRun(, {|oSay| lEmail := EmlAprova(jDados) }, "Processamento", "Enviando e-mail para aprova��o da modifica��o")

Return .T.



/*{Protheus.doc} User Function ValidaPeriodo
  Valida o per�odo de comissionamento
  @type  user Function
  @author Kleyson Gomes
  @since 11/01/2023
  @version 12.33
  @param jDados
  @return 
  */
User Function ValidaPeriodo(jDados)
  Local aRet                := {}
  Local aBox                := {}
  Local cQuery
  Local oComissao           := GmComissao():New()

  If Empty(jDados['Dt_Ativacao'])
    MsgAlert("Data da emiss�o n�o encontrada!", "Valida��o da Data")
    Return
  EndIf

  cQuery                    := "SELECT ZA_CODIGO, ZA_DESC FROM " ;
                                + RetSqlName("SZA") +  " WHERE d_e_l_e_t_ = ' ' and '" ;
                                + jDados['Dt_Ativacao'] + "' BETWEEN ZA_DTINI AND ZA_DTFIM"

	/* Coleta os dados do per�odo para a verifica��o */
  TcQuery cQuery New Alias "QRY"
	jDados['Cod_Periodo']     := QRY->ZA_CODIGO
  jDados['Periodo']         := QRY->ZA_DESC
  QRY->(DbCloseArea())

  jDados['Status_Periodo']    := oComissao:GetDescPeriodo( jDados['Cod_Periodo'] )

  /* Valida per�odo sicronizado com as rotinas de comiss�o */
  If jDados['Status_Periodo'] == "Fechado"
    MsgAlert("N�o � poss�vel alterar o vendedor devido o per�odo comercial j� est� fechado", "Valida��o de Per�odo")
    Return
  EndIf

  aAdd(aBox,{1,"C�digo NOVO Vendedor:",Space(6),"","","SA3","",6,.T.}) 	//MV_PAR01
  aAdd(aBox,{11,"Motivo da Troca","",".T.",".T.",.T.})                  //MV_PAR02

  If ParamBox(aBox,"Atualiza��o: Dados Vendedor",@aRet)
    jDados['Vendedor_Novo'] 	:= MV_PAR01
    jDados['Motivo_Troca'] 		:= MV_PAR02
    /* Rotina que executa a montagem dos dados e chama o envio do e-mail */
    U_MORF951(jDados)		
  EndIf

Return   

/*{Protheus.doc} User Function Func951b
	Envia dados para a valida��o e altera��o de vendedor
	@type  User Function
	@author Kleyson Gomes
	@since 10/01/2023
	@version 12.33
	@return 
	*/
User Function Func951b()

	Local jDados     					:= JsonObject():New()

	/* Coleta de informa��es atuais da venda */
	jDados['Dt_Ativacao']			:= DTOS(table->table_DTATIV)
	jDados['Tipo']	 					:= "JAZIGO"
	jDados['Cliente'] 				:= table->table_CODCLI
  jDados['Nome_Cliente'] 		:= table->table_NOMCLI
	jDados['Codigo'] 					:= table->table_CONTRT
	jDados['Vendedor_Atual'] 	:= table->table_CODVEN
	jDados['Lider_Atual'] 		:= table->table_CODSUP
	jDados['Supervisor_Atual']:= table->table_CODGER
	
	U_ValidaPeriodo(jDados)
Return

/*{Protheus.doc} User Function Func951c
	Envia dados para a valida��o e altera��o de vendedor
	@type  Function
	@author Kleyson Gomes
	@since 11/01/2023
	@version 12.33
	*/
User function Func951c()

	Local jDados     					:= JsonObject():New()
  Local cQryCli             :=""

  /* coleta de informa��es atuais da venda */
	jDados['Tipo']	 					:= "VENDA"
	jDados['Dt_Ativacao']			:= DTOS(SL1->L1_EMISNF)
	jDados['Cliente'] 				:= SL1->L1_CLIENTE
	jDados['Codigo'] 					:= SL1->L1_NUM
	jDados['Vendedor_Atual'] 	:= SL1->L1_VEND
	jDados['Lider_Atual'] 		:= SL1->L1_VEND2
	jDados['Supervisor_Atual']:= SL1->L1_VEND3

  cQryCli                   := "SELECT A1_NOME " ;
                                + "FROM SA1030" +  " WHERE d_e_l_e_t_ = ' ' and " ;
                                + "A1_COD =" + "'" + jdados['Cliente'] + "'"
  TcQuery cQryCli New Alias "QRY1"
	jDados['Nome_Cliente']     := QRY1->A1_NOME
  QRY1->(DbCloseArea())

	U_ValidaPeriodo(jDados)
Return

/*{Protheus.doc} EmlAprova
  Envia e-mail para aprova��o
  @type  Static Function
  @author Kleyson Gomes
  @since 09/01/2023
  @version 12.33
  @param 
  @return 
*/
Static Function EmlAprova(jDados)
  Local cHtml           := MemoRead("\workflow\alteracao_vendedor.htm")
  Local cTo             := SuperGetMV("MV_APVCOMI", .F., "kleysongomes7@gmail.com.br")
  Local cAssunto        := "WF" + cEmpAnt + "-" + cFilAnt + " - Solicita��o de altera��o de vendedor"
  Local cDados          := ""
  Local nCont           := 0
  Local lConfirma       := .T.
  Local aEmails         := {}
  
  /* Montagem dos HTML para o Workflow */
  cHtml := Strtran(cHtml, "%EMPRESA%",        jDados['Empresa']                                                     )
  cHtml := Strtran(cHtml, "%SOLICITANTE%",    jDados['Solicitante']       +"-"+    jDados['Nome_Solicitante']       )
  cHtml := Strtran(cHtml, "%CLIENTE%",        jDados['Cliente']           +"-"+    jDados['Nome_Cliente']           )
  cHtml := Strtran(cHtml, "%TIPO%",           jDados['Tipo']                                                        )
  cHtml := Strtran(cHtml, "%CODIGO%",         jDados['Codigo']                                                      )
  cHtml := Strtran(cHtml, "%DTATIVACAO%",     DTOC(STOD(jDados['Dt_Ativacao']))                                     )
  cHtml := Strtran(cHtml, "%PERIODO%",        jDados['Periodo']                                                     ) 
  cHtml := Strtran(cHtml, "%VENDEDORATUAL%",  jDados['Vendedor_Atual']    +"-"+   jDados['Nome_Vendedor_Atual']     )
  cHtml := Strtran(cHtml, "%LIDERATUAL%",     jDados['Lider_Atual']       +"-"+   jDados['Nome_Lider_Atual']        )
  cHtml := Strtran(cHtml, "%SUPATUAL%",       jDados['Supervisor_Atual']  +"-"+   jDados['Nome_Supervisor_Atual']   )
  cHtml := Strtran(cHtml, "%VENDEDORNOVO%",   jDados['Vendedor_Novo']     +"-"+   jDados['Nome_Vendedor_Novo']      )
  cHtml := Strtran(cHtml, "%LIDERNOVO%",      jDados['Lider_Novo']        +"-"+   jDados['Nome_Lider_Novo']         )
  cHtml := Strtran(cHtml, "%SUPNOVO%",        jDados['Supervisor_Novo']   +"-"+   jDados['Nome_Supervisor_Novo']    )
  cHtml := Strtran(cHtml, "%MOTIVO%",         jDados['Motivo_Troca']                                                )

    cHtml                 := Strtran(   cHtml, "%STATUS%", jDados['Status_Periodo'] )
    aEmails               := StrtokArr( cTo,    ";"                                 )

  For nCont := 1 to len(aEmails)
    /* Adiciona no Json com os dados do e-mail do aprovador*/
    jDados['Email_Aprov'] := aEmails[nCont]
    jDados['Btn_Aprov']   := "Aprovado"

    /* Condifica em base64 os dados do Json montado */
    cDados                := encode64(  jDados:tojson()          )
    cHtml                 := Strtran(   cHtml, "%CHAVE%", cDados )

    /* Para montagem do btn cancelar */
    jDados['Btn_Aprov']   := "Recusado"
    cDados                := encode64(  jDados:tojson()          )
    cHtml                 := Strtran(   cHtml, "%CHAVE1%", cDados )
    
    
    /* Chama a rotina para o envio do e-mail */
    If !u_EnviaEmail(cAssunto, aEmails[nCont], cHtml)
        lConfirma         := .F.
    EndIf

  Next nCont

  If lConfirma == .T.
    MsgInfo("E-mail de aprova��o enviado!", "Envio de E-mail")
  EndIf

Return lConfirma
