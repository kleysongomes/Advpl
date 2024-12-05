#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'FWCommand.ch'
#include 'rptdef.ch'
#define PEPEL_A4 10
#define IMP_SPOOL 2
#define AMBIENTE 2

/*/{Protheus.doc} User Function MORA1159
        Rotina para gerenciamento de cartões alimentação fornecido aos cliente
    @type  Function
    @author PauloSouza
    @since 13/12/2021
    @version 12.1.25    /*/
User Function MORA1159()
	Local aArea         := GetArea()
	Local oBrowse       := NIL
	Private cTitulo     := "Cartões alimentação/Kit Café de clientes"

	If !ChkFile("Z36")
		Msginfo("Estrutura da tabela Z36 não existe na base")
		return .F.
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z36")
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()
	oBrowse:SetAttach( .T. )
	oBrowse:SetOpenChart( .T. )
	oBrowse:AddLegend( "Z36->Z36_STATUS == 'A'", "VERDE"        , "Cartão livre")
	oBrowse:AddLegend( "Z36->Z36_STATUS == 'L'", "AMARELO"      , "Cartão liberado")
	oBrowse:AddLegend( "Z36->Z36_STATUS == 'C'", "VERMELHO"     , "Cartão cancelado")
	oBrowse:Activate()
	RestArea(aArea)
Return

Static Function MenuDef()
	Local aRot          := {}
	Local aGrupos       := UsrRetGrp (, __cUserId)

	ADD OPTION aRot TITLE 'Visualizar'          ACTION 'VIEWDEF.MORA1159' OPERATION MODEL_OPERATION_VIEW   ACCESS 0

	if FwisAdmin() .or. aScan( aGrupos, Supergetmv("MV_MOR159A", .F., "") ) .or. __cUserId $ SuperGetMV("MV_MOR159B", .F., "")
		ADD OPTION aRot TITLE 'Incluir Cartão'      ACTION 'VIEWDEF.MORA1159'   OPERATION MODEL_OPERATION_INSERT ACCESS 0
		ADD OPTION aRot TITLE 'Cancelar Cartão'     ACTION 'u_MRA1159C()'       OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	EndIf

	ADD OPTION aRot TITLE 'Liberar Alimentação' ACTION 'u_MRA1159B()'      OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRot TITLE 'Liberar Kit Café'    ACTION 'u_MRA1159D()'      OPERATION MODEL_OPERATION_VIEW   ACCESS 0

	//-------------------------------------------------------------------------------------------------------------

	ADD OPTION aRot TITLE 'Relatórios'          ACTION 'u_MRA1159R()'      OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRot TITLE 'Importar Cartão'     ACTION 'u_MORF952B()'      OPERATION MODEL_OPERATION_INSERT ACCESS 0
Return aRot

Static Function ModelDef()
	Local oModel := Nil
	Local oStructPai    := FWFormStruct(1, "Z36")

	oModel := MPFormModel():New("zMORA1159",,{|oModel| TudoOK(oModel) })
	oModel:AddFields("MASTER",,oStructPai)
	oModel:SetDescription(cTitulo)
	oModel:GetModel("MASTER"):SetDescription( cTitulo )
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel("MORA1159")
	Local oStructPai := FWFormStruct(2, "Z36")
	Local oView := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_Z36", oStructPai, "MASTER")
	oView:EnableTitleView('VIEW_Z36', cTitulo )
	oView:SetCloseOnOk({||.T.})
Return oView

User function MRA1159C()
	Local cHistorico := "Cancel. de cartão alimentação - MORA1159 " + CRLF
	Local cMotivo    := ""
	Local cObserv    := Z36->Z36_OBSERV

	If !Empty( Z36->Z36_CONTRT )
		If !MsgYesNo("Já existe um contrato associado a este cartão, deseja realmente cancelar?")
			Return .F.
		Else
			cHistorico += "Cartão com contrato associado: " + Z36->Z36_CONTRT + CRLF
		EndIf
	EndIf

	cMotivo := Motivo()
	If Empty( cMotivo )
		MsgInfo("Para realizar o cancelamento é necessário informar o motivo")
		return .F.
	EndIf

	cHistorico += "Matricula liberada: " + Transform(Z36->Z36_IDCARD, PesqPict( "Z36", "Z36_IDCARD" )) + CRLF
	cHistorico += "Motivo: " + cMotivo + CRLF

	If !Empty( Z36->Z36_CONTRT)
		ZAM->( dbSetOrder(1) )
		If ZAM->( dbSeek( xFilial("ZAM") + Z36->Z36_CONTRT ) )
			oHistorico := GmHistorico():New(ZAM->ZAM_CONTRT, ZAM->ZAM_CODCLI)
			oHistorico:GravaHistorico( cHistorico,,"0024")
		EndIf
	EndIf

	cHistorico += "Usuário: " + UsrRetName( __cUserId ) + CRLF
	cHistorico += "Data:" + dToC( Date() ) + CRLF
	cHistorico += Replicate('-',50) + CRLF

	cObserv += cHistorico

	Z36->( Reclock("Z36", .F.) )
	Z36->Z36_status := "C"
	Z36->Z36_dtcanc := dDataBase
	Z36->Z36_observ := cObserv
	Z36->( MsUnlock() )
Return

Static function TudoOK( oModel )
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		If oModel:GetValue("MASTER","Z36_VALOR") == 0
			MsgInfo("O valor do cartão não pode ser 0")
			return .F.
		EndIf
		If Len(Alltrim(oModel:GetValue("MASTER","Z36_IDCARD"))) != 9
			MsgInfo("A numeração do cartão precisa conter 9 digitos")
			return .F.
		EndIf
		BeginSql alias 'qtd'
            Select count(1) quantidade
                from %Table:Z36% z36
                where z36.z36_filial = %xFilial:Z36%
                and z36.z36_status <> 'C'
                and z36.z36_idcard = %Exp:oModel:GetValue("MASTER","Z36_IDCARD")%
                and z36.%notdel%
		EndSql
		if qtd->quantidade > 0
			qtd->( dbCloseArea() )
			MsgInfo("Já existe cartão criado com esta numeração")
			return .F.
		EndIf
		qtd->( dbCloseArea() )
	EndIf
Return .T.

Static function Motivo()
	Local aBox := {}
	Local aRet := {}

	aAdd(aBox,{11,"Informe o motivo","",".T.",".T.",.T.})
	If !ParamBox(aBox,"Motivo",@aRet,{||if(Len(MV_PAR01) < 10,(MsgAlert("Favor incluir mais informações","Alerta!!")),.T.)})
		MsgAlert("Abortado pelo Operador")
		Return ""
	Endif
Return MV_PAR01

User function MRA1159B()
	Local aBox := {}
	Local aRet := {}
	Local nQtdPlano := 0

	If Z36->Z36_STATUS != "A"
		MsgInfo("Status não permite liberação")
		return
	Endif

	if Z36->Z36_TIPO != "A" //Alimentação
		MsgInfo("Esse cartão não é do tipo ALIMENTAÇÃO!")
		Return
	endif

	aAdd(aBox,{1,"Contrato",Space(8),"","","ZAM","",80,.T.})
	If !ParamBox(aBox,"Filtros",@aRet)
		Return
	EndIf

	BeginSql alias 'validacao'
        Select count(1) quantidade
            from %Table:Z36% z36
            where z36.z36_filial = %xFilial:Z36%
              and z36.z36_status <> 'C'
              and z36.z36_tipo = 'A'
              and z36.z36_contrt = %Exp:MV_PAR01%
              and z36.%notdel%
	EndSql

	if validacao->quantidade > 0
		validacao->( dbCloseArea() )
		MsgInfo("Já existe cartão liberado para este contrato")
		return
	EndIf
	validacao->( dbCloseArea() )

	ZAM->( dbSetOrder(1) )
	If !ZAM->( dbSeek( xFilial("ZAM") + MV_PAR01 ) )
		MsgInfo("Contrato não localizado")
		return
	EndIf

	BeginSql alias 'obt_titular'
        select count(1) quantidade
            from %Table:SZO% szo
            where szo.zo_filial = %xFilial:SZO%
            and szo.zo_contrt = %Exp:ZAM->ZAM_CONTRT%
            and szo.zo_entobt = '1'
            and szo.d_e_l_e_t_ = ' '
	EndSql
	If obt_titular->quantidade == 0
		obt_titular->( dbCloseArea() )
		MsgInfo("Não foi localizado nenhum titular em óbito.", "Rotina de registro de óbito")
		Return
	EndIf
	obt_titular->( dbCloseArea() )

	oBenef := GvBeneficioPlano():new(ZAM->ZAM_CONTRT)
	aBenef := oBenef:getBeneficio()
	cMotBen := ""
	nProd := aScan( aBenef, {|x| x[1] $ ("940026,100001") } )
	If nProd == 0
		If MsgyesNo("O beneficio auxilio alimentação(Produto 940026/100001) não foi localizado no contrato. Deseja Liberar o Benefício mesmo assim?")
			cMotBen := Motivo()
			If Empty( cMotBen )
				MsgInfo("Para realizar q Liberação é necessário informar o motivo")
				return .F.
			EndIf
		else
			Return
		endif
	else

		nQtdPlano   := Val(aBenef[nProd, 3])
		Do Case
			Case nQtdPlano == 1
				nVlBenef := 60
			Case nQtdPlano == 2
				nVlBenef := 120
			Case nQtdPlano >= 3
				nVlBenef := 180								
		Endcase	

		If nVlBenef != Z36->Z36_VALOR
			cText := "<strong>Não será possível a liberação deste cartão</strong>"
			cText += "<br>Cartão selecionado tem o valor => " + Transform( Z36->Z36_VALOR, PesqPict( "Z36", "Z36_VALOR" ))
			cText += "<br>Beneficio do plano => Quantidade " + cValToChar( nQtdPlano )
			cText += "<br>Beneficio do plano => Valor " + Transform( nVlBenef, PesqPict( "Z36", "Z36_VALOR" ))
			ctext += "<br>"
			cText += "<br>REF.: 1 => 60, 2 => 120, 3 => 180"

			MsgInfo( cText, "Valor divergente")
			return
		EndIf

	EndIf

	cObservacao := "Liberação de cartão alimentação" + CRLF
	cObservacao += "Matricula liberada: " + Transform(Z36->Z36_IDCARD, PesqPict( "Z36", "Z36_IDCARD" )) + CRLF
	cObservacao += "Valor: " + Transform( Z36->Z36_VALOR, PesqPict( "Z36", "Z36_VALOR" )) + CRLF
	cObservacao += "Sequencia: " + Z36->Z36_SEQUEN + CRLF + CRLF

	if !empty(cMotBen)
		cObservacao += "OBSERVAÇÂO: Liberação realizada manualmente (Beneficio não localizado no contrato) " + CRLF
		cObservacao += "Motivo informado: " + CRLF
		cObservacao += cMotBen
	endif

	oHistorico := GmHistorico():New(ZAM->ZAM_CONTRT, ZAM->ZAM_CODCLI)
	oHistorico:GravaHistorico( cObservacao,,"0024")

	cObservacao += "Usuário: " + UsrRetName( __cUserId ) + CRLF
	cObservacao += "Data:" + dToC( Date() ) + CRLF
	cObservacao += Replicate('-',50) + CRLF

	Z36->( Reclock("Z36", .F.) )
	Z36->Z36_CONTRT := ZAM->ZAM_CONTRT
	Z36->Z36_DTLIBE := dDataBase
	Z36->Z36_OBSERV := Z36->Z36_OBSERV + CRLF + cObservacao
	Z36->Z36_STATUS := "L"
	Z36->( MsUnlock() )

	Workflow()
Return

User function MRA1159D()
	Local aBox              := {}
	Local aRet              := {}
	Local cFilAut           := ""
	Local cTable_Z36        := ""
	Local cTable_ZAM        := ""
	Local cContrt_ZAM       := ""
	Local cClient_ZAM       := ""
	Local cAtend 						:= ""

	If Z36->Z36_STATUS != "A"
		MsgInfo("Status não permite liberação")
		return
	Endif

	if Z36->Z36_TIPO != "K" //Alimentação
		MsgInfo("Esse cartão não é do tipo KIT CAFÉ!")
		Return
	endif

	aAdd(aBox,{1,"Atend. Funerario",Space(6),"","","SZ1","",80,.T.})
	If !ParamBox(aBox,"Filtros",@aRet)
		Return
	EndIf

	cAtend := MV_PAR01

	//Verifica se o atendimento funerario existe e se possui contrato plano associado
	SZ1->(dbsetorder(1))
	If !SZ1->(dbseek(xFilial("SZ1")+mv_par01))
		MsgInfo("Atendimento Funerário não localizado")
		return
		//Verifica se o atendimento funerario tem a autorização e o contrato informados
	elseif empty(SZ1->Z1_CONTRT) .or. empty(SZ1->Z1_AUTORIZ)
		If MsgyesNo("Atendimento é parceiro?")
			cMotBen := Motivo()
			If Empty( cMotBen )
				MsgInfo("Para realizar q Liberação é necessário informar o motivo")
				return
			EndIf
			KitParceiro(cMotBen, cAtend)
			return
		EndIf
		MsgInfo("O atendimento informado não possui autorização de atendimento e o contrato informados. Verifique se trata-se de um atendimento Morada Essencial!")
		return
	EndIf

	cTable_Z36  := "% Z36" + substr(SZ1->Z1_AUTORIZ,1,2) + "0 %"
	cTable_ZAM  := "% ZAM" + substr(SZ1->Z1_AUTORIZ,1,2) + "0 %"
	cEmpAut     := substr(SZ1->Z1_AUTORIZ,1,2)
	cFilAut     := substr(SZ1->Z1_AUTORIZ,3,2)

	//Valida se ja houve um cartão de kit cafe já liberado para  esse contrato + atendimento
	//Caso haja um novo obito podera haver outro kit cafe
	BeginSql alias 'validacao'
        Select count(1) quantidade
            from %Exp:cTable_Z36% z36
            where z36.z36_filial = %Exp:cFilAut%
              and z36.z36_status <> 'C'
              and z36.z36_contrt = %Exp:SZ1->Z1_CONTRT%
              and z36.z36_autori = %Exp:SZ1->Z1_AUTORIZ%
              and z36.%notdel%

        UNION ALL

        Select count(1) quantidade
            from %table:Z36% z36
            where z36.z36_filial = %xFilial:Z36%
              and z36.z36_status <> 'C'
              and z36.z36_contrt = %Exp:SZ1->Z1_CONTRT%
              and z36.z36_autori = %Exp:SZ1->Z1_AUTORIZ%
              and z36.%notdel%
	EndSql

	if validacao->quantidade > 0
		validacao->( dbCloseArea() )
		MsgInfo("Já existe cartão liberado para esta Autorizção/Atendimento")
		return
	EndIf
	validacao->( dbCloseArea() )

	BeginSql alias 'contratoSql'
        Select  zam.zam_contrt as contrato,
                zam.zam_codcli as cliente
            from %Exp:cTable_ZAM% zam
            where zam.zam_filial = %Exp:cFilAut%
                and zam.zam_contrt = %Exp:SZ1->Z1_CONTRT%
                and zam.%notdel%
	EndSql

	if Len(contratoSql->contrato) == 0
		contratoSql->( dbCloseArea() )
		MsgInfo("Contrato não localizado")
		return
	EndIf
	cContrt_ZAM := Alltrim(contratoSql->contrato)
	cClient_ZAM := Alltrim(contratoSql->cliente)
	contratoSql->( dbCloseArea() )

	oBenef := GvBeneficioPlano():new(cContrt_ZAM)
	aBenef := oBenef:getBeneficio()
	cMotBen := ""
	nProd := aScan( aBenef, {|x| x[1] $ ("940015,000112,000066") } )
	If nProd == 0
		If MsgyesNo("O beneficio Kit Cafe(Produto 940015,000112) não foi localizado no contrato. Deseja Liberar o Benefício mesmo assim?")
			cMotBen := Motivo()
			If Empty( cMotBen )
				MsgInfo("Para realizar q Liberação é necessário informar o motivo")
				return .F.
			EndIf
		else
			Return
		endif
	else
		nQtdPlano   := Val(aBenef[nProd, 3])
		cText := "<strong>Não será possível a liberação deste cartão</strong>"
		cText += "<br>Cartão selecionado tem o valor => " + Transform( Z36->Z36_VALOR, PesqPict( "Z36", "Z36_VALOR" ))
		cText += "<br>Beneficio do plano => Quantidade " + cValToChar( nQtdPlano )

	EndIf

	cObservacao := "Liberação de cartão Kit Café" + CRLF
	cObservacao += "Matricula liberada: " + Transform(Z36->Z36_IDCARD, PesqPict( "Z36", "Z36_IDCARD" )) + CRLF
	cObservacao += "Valor: " + Transform( Z36->Z36_VALOR, PesqPict( "Z36", "Z36_VALOR" )) + CRLF
	cObservacao += "Sequencia: " + Z36->Z36_SEQUEN + CRLF + CRLF

	if !empty(cMotBen)
		cObservacao += "OBSERVAÇÂO: Liberação realizada manualmente (Beneficio não localizado no contrato) " + CRLF
		cObservacao += "Motivo informado: " + CRLF
		cObservacao += cMotBen + CRLF
	endif

	cObservacao += "Liberação realizada na base: " + FwFilialName(cEmpant, cFilant) + CRLF

	//usar start job para gravar o historico
	StartJob( "U_MRA1159E", getenvserver(), .F., cContrt_ZAM, cClient_ZAM, cObservacao,cEmpAut, cFilAut)

	cObservacao += "Usuário: " + UsrRetName( __cUserId ) + CRLF
	cObservacao += "Data:" + dToC( Date() ) + CRLF
	cObservacao += Replicate('-',50) + CRLF

	Z36->( Reclock("Z36", .F.) )
	Z36->Z36_CONTRT := cContrt_ZAM
	Z36->Z36_DTLIBE := dDataBase
	Z36->Z36_OBSERV := Z36->Z36_OBSERV + CRLF + cObservacao
	Z36->Z36_STATUS := "L"
	Z36->Z36_AUTORI := SZ1->Z1_AUTORIZ
	Z36->( MsUnlock() )

	//Workflow()
Return

/*/{Protheus.doc} User Function MRA1159E
    Gera o historico via startJob
    @type  Function
    @author Kleyson Gomes
    @since 09/02/2023
    @version 12.33
    @param cContrt_ZAM, cClient_ZAM, cObservacao, cEmpAut, cFilAut
    @return Nil
    /*/
User Function MRA1159E(cContrt_ZAM, cClient_ZAM, cObservacao, cEmpAut, cFilAut)
	RpcSetType( 3 )
	RpcSetEnv( cEmpAut, cFilAut )
	oHistorico := GmHistorico():New(cContrt_ZAM, cClient_ZAM)
	oHistorico:GravaHistorico( cObservacao,,"0024")
Return

User function MRA1159R()
	Local oprint := NIL

    /* Caso o relatório seja executado sem carregar os parametros, já pré define */
	MV_PAR01 := "T"
	MV_PAR02 := dDatabase
	MV_PAR03 := dDataBase
    /*------------------*/

	oPrint := ReportDef()
	oPrint:PrintDialog()
Return

Static function ReportDef()
	oPrint := TReport():New(Funname())
	oPrint:SetDevice(IMP_SPOOL)
	oPrint:SetEnvironment(AMBIENTE)
	oPrint:SetTitle("Extrato de conferência de cartões")
	oPrint:SetAction({|oPrint| ReportPrint(oPrint)})
	oPrint:SetDescription("Extrato de conferência de cartões")
	oPrint:DisableOrientation()
	oPrint:SetLandscape()
	oprint:SetParam({|| Pergunte() })
	oPrint:ShowHeader()

	oColunas := TRSection():New(oPrint,"[DETALHES]","QRYZ36")
	oColunas:SetHeaderSection(.T.)
	oColunas:SetAutoSize(.T.)

	TRCell():New(oColunas,"sequencia","QRYZ36" ,"Seq.")
	TRCell():New(oColunas,"emissao","QRYZ36" ,"Data",,,,{|| dToC(sToD(QRYZ36->emissao)) })
	TRCell():New(oColunas,"tipo","QRYZ36" ,"Tip Cartao")
	TRCell():New(oColunas,"status","QRYZ36","Situação",,,,{|| u_xBoxDesc("Z36_STATUS", QRYZ36->Status) })
	TRCell():New(oColunas,"id","QRYZ36","ID Cartão")
	TRCell():New(oColunas,"valor","QRYZ36" ,"Valor", "@E 9,999,999.99")
	TRCell():New(oColunas,"contrato","QRYZ36" ,"Contrato")
	TRCell():New(oColunas,"cliente","QRYZ36" ,"Cliente")
	TRCell():New(oColunas,"useri","QRYZ36" ,"Usr.Inclusão")

	TRCollection():New("VLRPEN","SUM",,"Total p/ status"  ,"@E 9,999,999.99" ,oColunas:Cell("status"),.F.,.T.,oColunas,,oColunas:Cell("valor"))
	TRCollection():New("CNTPEN","COUNT",,"Qtd. p/ status"  ,"@E 9999" ,oColunas:Cell("status"),.F.,.T.,oColunas,,oColunas:Cell("status"))
Return oPrint

Static function ReportPrint( oPrint )
	Local oSecao := oPrint:Section(1)
	Local cFiltros := ""
	
	//se tipo for numero
	If ValType(MV_PAR01) == "N"
		Do Case
			Case MV_PAR01 == 1
				MV_PAR01 := "T"
			Case MV_PAR01 == 2
				MV_PAR01 := "T"
			Case MV_PAR01 == 3
				MV_PAR01 := "A"
			Case MV_PAR01 == 4
				MV_PAR01 := "L"
			Case MV_PAR01 == 5
				MV_PAR01 := "C"
		EndCase
	EndIf

    /*
        Primeiro filtro de fornecedor
    */
	If Left(MV_PAR01, 1) == "T"
		cFiltros += " AND ((Z36.Z36_DTCANC between '"+dToS( MV_PAR02 )+"' and '"+dToS( MV_PAR03 )+"') or (Z36.Z36_DTINCL between '"+dToS( MV_PAR02 )+"' and '"+dToS( MV_PAR03 )+"') or (Z36.Z36_DTLIBE between '"+dToS( MV_PAR02 )+"' and '"+dToS( MV_PAR03 )+"') ) "
	Else
		cFiltros += " AND Z36.Z36_STATUS = '" + Left(MV_PAR01, 1) + "' "
		if Left(MV_PAR01, 1) == "A"
			cFiltros += " AND Z36.Z36_DTINCL between '"+dToS( MV_PAR02 )+"' and '"+dToS( MV_PAR03 )+"'"
		ElseIf Left(MV_PAR01, 1) == "C"
			cFiltros += " AND Z36.Z36_DTCANC between '"+dToS( MV_PAR02 )+"' and '"+dToS( MV_PAR03 )+"'"
		Else
			cFiltros += " AND Z36.Z36_DTLIBE between '"+dToS( MV_PAR02 )+"' and '"+dToS( MV_PAR03 )+"'"
		EndIf
	EndIf

	If Empty( cFiltros )
		cFiltros := "% %"
	Else
		cFiltros := "% " + cFiltros + " %"
	Endif

    /*-------------------------------------------------------*/
	oSecao:BeginQuery()
	BeginSql Alias "QRYZ36"
        Select  z36.z36_sequen as sequencia,
                case when z36.z36_status = 'A' then z36.z36_dtincl
                     when z36.z36_status = 'C' then z36.z36_dtcanc
                     when z36.z36_status = 'L' then z36.z36_dtlibe
                end emissao,
                z36.z36_status as status,
                z36.z36_valor as valor,
                z36.z36_idcard as id,
                z36.z36_usrinc as useri,
                z36.z36_contrt as contrato,
                nvl(zam.zam_nomcli, ' ') as cliente,
                case when z36.z36_tipo = 'A' then 'Alimentacao'
                    when z36.z36_tipo = 'K' then 'Kit Cafe'
                end tipo
            From %Table:Z36% Z36
            left join %Table:ZAM% zam
                on  zam.zam_filial = z36.z36_filial
                and zam.zam_contrt = z36.z36_contrt
                and zam.%notdel%
        Where z36.z36_filial = %xFilial:Z36%
          %Exp:cFiltros%
          and z36.%notdel%
	EndSql
	oSecao:EndQuery()

	oSecao:Init()
	While QRYZ36->( !Eof() )

		oSecao:PrintLine()

		QRYZ36->( dbSkip() )
	EndDo
	QRYZ36->( dbCloseArea() )
	oSecao:Finish()
Return

Static function Pergunte()
	Local aBox := {}
	Local aRet := {}
	Local aStatus := {}

	aAdd( aStatus, " " )
	aAdd( aStatus, "T=Todos" )
	aEval( u_xBoxDesc("Z36_STATUS"), {|x| aAdd( aStatus, x ) } )

	aAdd(aBox,{2,"Status", 1,aStatus,80,"",.T.})
	aAdd(aBox,{1,"Data inicial",Ctod(Space(8)),"","","","",80,.T.})
	aAdd(aBox,{1,"Data Final",Ctod(Space(8)),"","","","",80,.T.})

	If !ParamBox(aBox,"Filtros",@aRet)
		Return
	EndIf
Return

Static function Workflow()
	Local cHtml         := MemoRead("\workflow\notificacao_cesta_basica.htm")
	Local cAssunto      := "WF "+ cEmpAnt+"-"+cFilAnt +"- LIBERAÇÃO DE CARTÃO CESTA BÁSICA - " + ZAM->ZAM_CONTRT + " - " + ZAM->ZAM_NOMCLI
	Local cTo           := SuperGETMV("",.F.,"wfliberacaocestabasica@moradadapaz.com.br")

	cHtml     := Strtran( cHtml, "%EMPRESA%"        , FwFilialName( cEmpAnt, cFilAnt, 2 ) )
	cHtml     := Strtran( cHtml, "%CLIENTE%"        , ZAM->ZAM_NOMCLI )
	cHtml     := Strtran( cHtml, "%CONTRATO%"       , ZAM->ZAM_CONTRT )
	cHtml     := Strtran( cHtml, "%IDCARD%"         , Transform(Z36->Z36_IDCARD, PesqPict( "Z36", "Z36_IDCARD" )) )
	cHtml     := Strtran( cHtml, "%VLPAGO%"         , Transform(Z36->Z36_VALOR, "@E 999,999.99") )
	cHtml     := Strtran( cHtml, "%OPERADOR%"       , usrretname( __cUserId ) )

	If !u_EnviaEmail(cAssunto, cTo, cHtml)
		return .F.
	EndIf
Return

/*/{Protheus.doc} Static Function KitParceiro
	Função para controle de liberação de kit café para parceiros
	@type  Static Function
	@author Kleyson Gomes
	@since 06/04/2023
	@version 12.33
	@param cMotBen, cAtend
	@return Nil
	/*/
Static Function KitParceiro(cMotBen, cAtend)

	Local aRet 			:= {}
	Local aBox 			:= {}
	Local aCombo 		:= {"03","05","07"}
	Local aCombo2 	:= {"01","02","03","04","05","06","07"}

	Local cParcei 		:= ""
	Local cContrP 		:= ""
	Local cTable_Z36 	:= ""
	Local cFilAte 		:= ""
	Local cObservacao := ""

	aAdd(aBox,{1,"Cod. Parceiro",Space(15),"","","","",0,.T.})
	aAdd(aBox,{1,"Contrato Parceiro",Space(15),"","","","",0,.T.})
	aAdd(aBox,{2,"Empresa",1,aCombo,50,"",.T.})
	aAdd(aBox,{2,"Filial Atendimento",1,aCombo2,50,"",.T.})

	If !ParamBox(aBox," Kit para parceiro ",@aRet)
		Return .F.
	EndIf

	cParcei 		:= MV_PAR01
	cContrP 		:= MV_PAR02
	cTable_Z36 	:= "% Z36" + MV_PAR03 + "0 %"
	cFilAte 		:= MV_PAR04

	BeginSql alias 'valida_parceiro'
    Select count(1) quantidade
      From %Exp:cTable_Z36% Z36
      where z36.z36_filial = %Exp:cFilAte%
      and z36.z36_status <> 'C'
      and z36.z36_atend = %Exp:cAtend%
      and z36.%notdel%
	EndSql

	If valida_parceiro->quantidade > 0
		MsgBox("Atendimento já possui kit cadastrado!")
		Return .F.
	EndIf

	valida_parceiro->( dbCloseArea() )

	cObservacao := "======= Liberação KitCafé para parceiro =======" + CRLF
	cObservacao += "Atendimento: " + cAtend + CRLF
	cObservacao += "Parceiro: " + cParcei + CRLF
	cObservacao += "Contrato Parceiro: " + cContrP + CRLF
	cObservacao += "Matricula liberada: " + Transform(Z36->Z36_IDCARD, PesqPict( "Z36", "Z36_IDCARD" )) + CRLF
	cObservacao += "Valor: " + Transform( Z36->Z36_VALOR, PesqPict( "Z36", "Z36_VALOR" )) + CRLF
	cObservacao += "Sequencia: " + Z36->Z36_SEQUEN + CRLF + CRLF

	if !empty(cMotBen)
		cObservacao += "======= Motivo informado pelo beneficiário =======" + CRLF
		cObservacao += "IMPORTANTE: Liberação realizada para PARCEIRO " + CRLF
		cObservacao += "Motivo informado: " + cMotBen + CRLF + CRLF
	endif

	cObservacao += "======= Detalhes da liberação =======" + CRLF
	cObservacao += "Liberação realizada na base: " + FwFilialName(cEmpant, cFilant) + CRLF
	cObservacao += "Usuário: " + UsrRetName( __cUserId ) + CRLF
	cObservacao += "Data:" + dToC( Date() ) + CRLF + CRLF
	cObservacao += Replicate('-',50) + CRLF

	Z36->( Reclock("Z36", .F.) )
	Z36->Z36_CONTRT := "PARCEIRO"
	Z36->Z36_DTLIBE := dDataBase
	Z36->Z36_OBSERV := Z36->Z36_OBSERV + CRLF + cObservacao
	Z36->Z36_STATUS := "L"
	Z36->Z36_AUTORI := " "
	Z36->Z36_ATEND 	:= cAtend
	Z36->( MsUnlock() )

	If RetPar(cObservacao,cAtend)
		MsgInfo("O setor FINANCEIRO foi informado sobre a liberação!")
	EndIf

	MsgInfo("Kit liberado com sucesso!")
Return

/*/{Protheus.doc} Static Function RetPar
	Envia e-mail para informação de liberação kit café para parceiros
	@type  Static Function
	@author Kleyson Gomes
	@since 06/04/2023
	@version 12.33
	@param cObservacao,cAtend
	@return boolean
	/*/
Static Function RetPar(cObservacao,cAtend)

	Local cTexto        := cObservacao
	Local cAssunto      := "INFORMATIVO: "+ cEmpAnt+"/"+cFilAnt +"- LIBERAÇÃO DE KIT PARA PARCEIRO - ATENDIMENTO " + cAtend
	Local cTo           := SuperGETMV('MS_KITCAF',.F.,'')

	If !u_EnviaEmail(cAssunto, cTo, cTexto)
		return .F.
	EndIf
Return .T.
