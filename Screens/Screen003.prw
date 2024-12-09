#Include "Protheus.Ch"
#include "topconn.ch"
#include "msgraphi.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "FONT.CH"
#INCLUDE "JPEG.CH"
#DEFINE CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} MORA934

*	Nova Tela de Contrato de Plano (novo plano) 
*	Rotina modificada em: 11/07/2017 - Trocando a funão MBrowse por FWMBrowse 

@author Leandro Ayala
@since 13/07/2010
@version 1
@type function
/*/

User Function MORA934()
	Private aRotina		:= MenuDef()
	Private	cCadastro 	:= "Contrato Plano - MORA934"
	Private	cString		:= "ZAM"
	Private nUsado		:= 0
	Private aCopCols    := {}
	Private cItem 		:= "01" //variavel que controla a numeracao dos itens no acols do modelo3 || adicionar essa variavel padrao no campo item da tabela (ZAN_ITEM)
	
	//instancia a classe
	oBrowse:=FWMBrowse():New()
	
	//Define índice e vai para o primeiro registro
	dbSelectArea(cString)
	dbSetOrder(1)
	dbGoTop()

	//Filtra os planos relacionados - PLANO SEMPRE ou MORADA PREVER, 
	If FunName() == "MORA934O"
		cFilTop 	:= "ZAM_CODPRO $ ('009901,009902,009929')"
		cCadastro 	:= "CONTRATOS - MORADA PREVER" 
	Else
		cFilTop := "!ZAM_CODPRO $ ('009901,009902,009929')"
		cCadastro 	:= "CONTRATOS DE PLANO"
	EndIf
	oBrowse:SetFilterDefault(cFilTop)	

	//descrição do browse
	oBrowse:SetDescription(cCadastro)
	
	//tabela temporaria
	oBrowse:SetAlias(cString)
	
	//define as colunas para o browse
	aColunas:={}
	
	//seta as colunas para o browse
	oBrowse:SetFields(aColunas)
    
	//define as legendas
	oBrowse:AddLegend('ZAM->ZAM_STATUS == "0"',"BR_BRANCO" ,"Contrato em Avaliação")
	oBrowse:AddLegend('ZAM->ZAM_STATUS == "1" .and. ZAM->ZAM_CANVEN == "100015" .and. u_vPgtoZAM()',"BR_PINK",'Aguardando Pagamento' )
	oBrowse:AddLegend('ZAM->ZAM_STATUS == "1"',"BR_VERDE","Contrato Ativo")
	oBrowse:AddLegend('ZAM->ZAM_STATUS == "2"',"BR_AZUL","Contrato Suspenso")
	oBrowse:AddLegend('ZAM->ZAM_STATUS == "3"',"BR_VERMELHO","Contrato Encerrado")
	oBrowse:AddLegend('ZAM->ZAM_STATUS == "4"',"BR_PRETO","Contrato Cancelado")
	oBrowse:AddLegend('ZAM->ZAM_STATUS == "5"',"BR_AMARELO","Contrato Migrado")
	oBrowse:AddLegend('ZAM->ZAM_STATUS == "6"',"BR_LARANJA","Ação Judicial")

	// Colore linha com dados incompletos
	//lTmpCad := ValCadPla()
	oBrowse:SetBlkBackColor({|| iif(U_ValCadPl(),"",65535)})	
	
	//abre o browse
	oBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
Gera o menu da função 
@author Marcos Aurelio
@since 11/07/2017
@version 1
@type function
/*/
Static Function MenuDef()
	Local 	aRotina 	:= {}
	Local   aBtTroca   	:= {}
	Local   aBtAde     	:= {}
	Local   aBtAti     	:= {}
	Local   aBtUnic    	:= {}
	Local   aBtReat		:= {}
	Local 	aBtAlte		:= {}
	Local 	aBtCons		:= {}
	Local 	aBtStat		:= {}
	Local 	aBtParc		:= {}
	Local	aBtSol		:={}
	Local 	aBtMap		:={}
	Local aBtRecorr  := {}
	local 	aUserInf	:= PswRet(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³sub menus do menu intermediario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aAdd(aBtAti,{"A&tivar"	         	,'Processa( {|| u_Ativacao() } )',0,1})
	aAdd(aBtAti,{"&Cancelar"	      	,'Processa( {|| u_CancelAt() } )',0,2})
	aAdd(aBtAti,{"&Receber"	         	,'u_MORA165E()',0,1})

	//aAdd(aBtReat,{"&Solicitar"	      	,'Processa( {|| u_MORF793("R") } )'			    ,0,1})
	//aAdd(aBtReat,{"&Reativar"	      	,'u_MORF793A(ZAM->ZAM_CONTRT)'					,0,2})
	//aAdd(aBtReat,{"&Gerar Código"	   	,'u_MORF793B(ZAM->ZAM_CONTRT)'			        ,0,3})

	aAdd(aBtTroca,{"&Substituir"    	,'Processa( {|| U_MORF794(ZAM->ZAM_CONTRT,"T") } )',0,1 })
	aAdd(aBtTroca,{"&Cancelar" 			,'Processa( {|| U_MORF794(ZAM->ZAM_CONTRT,"C") } )',0,2})

	aAdd(aBtAde,{"&Gerar"	         	,'u_GeraAdes()',0,1})
	aAdd(aBtAde,{"&Cancelar"	      	,'u_CancAdes()',0,2})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³submenus do menu principal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³menu unico³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aBtUnic,{"&Incluir Aditivo"	,'U_ADITUNI(ZAM->ZAM_CONTRT)'	,0,11})
	aAdd(aBtUnic,{"&Cancelar Aditivo"	,'U_CancUni()'					,0,17})
	aAdd(aBtUnic,{"&Consultar Aditivos"	,'U_ConsAdi()'					,0,18})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³menu alteracoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aBtAlte,{"&Alt. Titularidade"		,aBtTroca							,0,11})
	aAdd(aBtAlte,{"Mov Dependentes"  		,'u_MORA937(ZAM->ZAM_CONTRT)' ,0,17})

	If FunName() == "MORA934O"
		aAdd(aBtAlte,{"Mud Venc/Pag Prever"	,'u_MORA1086()' ,0,20})
	Else
		aAdd(aBtAlte,{"Mud Form Pagamento" 	,'FWMsgRun(, {|| u_MORF786(ZAM->ZAM_CONTRT) }, "", "Processando a rotina")' ,0,18})
	EndIf

	aAdd(aBtAlte,{"Migração Plano"  		,'Processa( {|| u_MORF804(ZAM->ZAM_CONTRT) } )' ,0,19})
	aAdd(aBtAlte,{"Mudança Empresa"  		,'u_MORF808(ZAM->ZAM_CONTRT)' ,0,20})


	// aAdd(aBtAlte,{"Migração Recorrência",'u_MORA1142()' ,0,21}) // Removido para ser analisado posteriormente - Marcos 
	// aAdd(aBtAlte,{"Cancelar Recorrência",'u_MORF932A(ZAM->ZAM_ASSEXT)' ,0,21}) // Removido por ser 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³menu consultas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aBtCons,{"&Mensalidades"    		,"u_MORA934R()" 	,0,1})
	aAdd(aBtCons,{"Faixas Etarias"  		,'u_MORA935(ZAM->ZAM_CONTRT)' 	,0,2})
	aAdd(aBtCons,{"Evol Mensalidade"  		,'u_MORA936(ZAM->ZAM_CONTRT)' 	,0,3})
	aAdd(aBtCons,{"&Histórico"	      		,'Processa( {|| u_MORA025(ZAM->ZAM_CONTRT) } )' ,0,15})
	aAdd(aBtCons,{"&Beneficios"	   			,'u_MORA934C(ZAM->ZAM_CONTRT)'	,0,6})
	aAdd(aBtCons,{"Declaração"  			,'u_MORR977'					,0,6})
	aAdd(aBtCons,{"&Legenda"					,"u_MORA934A"					,0,7})
	aAdd(aBtCons,{"&Historico Mabisic"		,"U_MORA934I(ZAM->ZAM_CODCLI)"	,0,8})
	aAdd(aBtCons,{"&Demons. Financeiro"	,"U_MORR1047"					,0,9})
	aAdd(aBtCons,{"&Declaração Cancel."	,"U_MORR1049"					,0,10})
	aAdd(aBtCons,{"&Proposta de Plano"	,"U_MORR1102"					,0,12})
	aAdd(aBtCons,{"&Proposta Aditivo"	,"U_MORR1154"					,0,12})
    IF(aScan(PswRet(1)[1][10],{|x|x $ '000000'}) > 0,aAdd(aBtCons,{"&Regra Contratual"		,"U_RegContr(ZAM->ZAM_CONTRT)"					,0,10}),"")
    aAdd(aBtCons,{"&Desconto"				,"U_CONDESCO()"					,0,14})
    aAdd(aBtCons,{"&Objetos"				,"U_MORA934Q()"					,0,14})
    aAdd(aBtCons,{"&Cobrança Meirelles" ,"u_MORA934S()"     ,0,15})
	aAdd(aBtCons,{"Repr. RA PIX" 		,"u_MORA934X()" ,0,17})


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³menu mod status³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aBtStat,{"&Cancelar"	      	,'u_MORF793("C")'  	,0,1})
	aAdd(aBtStat,{"&Encerrar"	      	,'u_MORF793("E")'  	,0,3})
	aAdd(aBtStat,{"&Ativação"    		,aBtAti				,0,4})
	aAdd(aBtStat,{"&Reativação"    		,"u_MORF793A(ZAM->ZAM_CONTRT)",0,5})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³menu gerar parcela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aBtParc,{"A&desao"	  				,aBtAde 						,0,1})
	aAdd(aBtParc,{"De Contrato  "			,'Processa( {|| u_ParcelaE() } )',0,2})
	aAdd(aBtParc,{"Multa Rescisoria"		,'u_MultRes'  					,0,3})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³menu solicitacao         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aBtSol,{"Solicitar"	  			,'u_CartaoAd'					,0,1})

	aAdd(aBtMap,{"Onde Fica" 	,'U_MAPS(1,"MORA934")'						,0,1})
	aAdd(aBtMap,{"Como Chegar" ,'U_MAPS(2,"MORA934")'						,0,2})


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³menu Recorrência         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEmpAnt = "05"
	aAdd(aBtRecorr,{"&Atualizar Cartão"		,"u_MORA2005()" ,0,18})
	aAdd(aBtRecorr,{"&Migrar contrato para Recorrência"		,"u_MORF957()" ,0,19})
	aAdd(aBtRecorr,{"Cancelamento da Recorrência"		,"u_MORF957C"					,0,20})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³montagem do menu principal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aRotina,{"&Pesquisar"  			,"AxPesqui"    					,0,1})
	aAdd(aRotina,{"&Visualizar"	   			,"u_MORA934A"  					,0,2})
	aAdd(aRotina,{"&Incluir"				,"u_MORA934A"  					,0,3})
	aAdd(aRotina,{"&Alterar"				,'u_MORA934A'					,0,4})
	aAdd(aRotina,{"E&xcluir Contrato"		,"u_MORA934A"					,0,5})
	aAdd(aRotina,{"&Inserir Histórico"	    ,'u_fGeraHist(ZAM->ZAM_CONTRT,"ZAM",ZAM->ZAM_CODCLI,ZAM->ZAM_LOJA," ","CONT",ZAM->ZAM_CONTRT,"Histórico Manual: ",.T.)' ,0,12})
	aAdd(aRotina,{"&Alterações"				,aBtAlte			  			,0,4})
	aAdd(aRotina,{"&Consultas"				,aBtCons			  			,0,6})
	aAdd(aRotina,{"&Modificar Status"		,aBtStat			  			,0,7})
	aAdd(aRotina,{"&Gerar Parcela"			,aBtParc			  			,0,8})
	aAdd(aRotina,{"&Solic. 2 Via"			,aBtSol			  				,0,9})
	aAdd(aRotina,{"Aditivo"  				,aBtUnic					 	,0,4})
	aAdd(aRotina,{"Conhecimento"     		,"u_uMsDocument(1, zam->zam_contrt)"  					,0,03,0,NIL})
	aAdd(aRotina,{"Google Maps"      		,aBtMap        					,0,13})

	aAdd(aRotina,{"Importação de arquivo (CSV)","u_MORF952",0,17})

	aAdd(aRotina,{"Adesão/Cancelamento Fat Digital","u_MORF953",0,19})
	If cEmpAnt = "05"
		aAdd(aRotina, {"Recorrência", aBtRecorr, 0,20})
	Endif
	

	If aScan(UsrRetGrp(RetCodUsr()),{|x| x $ supergetmv(' ',.F.,'') }) > 0 .or. FwIsAdmin() // Apenas para adm - supergetmv(' MS_GRUPCAL ',.F.,'')
		aAdd(aRotina,{"Cadastro Simplificado de Plano - CAC"		,"u_MORA2004"					,0,1})
	EndIf

	If aScan(UsrRetGrp(RetCodUsr()),{|x| x $ supergetmv('MS_GRUPMKT',.F.,'') }) > 0 .or. FwIsAdmin() // Apenas para adm - supergetmv(' MS_GRUPMKT ',.F.,'')
		aAdd(aRotina,{"Atualiza Estrutura Beneficios - MKT"		,"u_morf960"					,0,1})
	EndIf

Return aRotina



/*/{Protheus.doc} ValCadPl
Valida preenchimento do cadastro. Retorna FALSO, caso o cadasreo não esteja completo 
@author Marcos Aurelio
@since 11/07/2017
@version 1
@type function
/*/
User Function ValCadPl()
	Local lRet := .T.
	
	Do Case
		Case (!CGC(alltrim(ZAM_CGC),'',.F.) .or. left(ZAM_CGC,6) $ '000000,111111,2222222,333333,444444,555555,666666,777777,888888,999999') .and. ZAM_STATUS $ ('0,1,5') 
			lRet := .F.
		Case Empty(Alltrim(ZAM_END)) .and. ZAM_STATUS $ ('0,1,5')
			lRet := .F.
		Case Empty(Alltrim(ZAM_BAIRRO)) .and. ZAM_STATUS $ ('0,1,5')
			lRet := .F.
		Case Empty(Alltrim(ZAM_MUNICI)) .and. ZAM_STATUS $ ('0,1,5')
			lRet := .F.
		Case (Empty(Alltrim(ZAM_TELRES)) .and. Empty(Alltrim(ZAM_TELCEL)) .and. Empty(Alltrim(ZAM_TELOUT))) .and. ZAM_STATUS $ ('0,1,5')
			lRet := .F.
		Case  ZAM_STATUS == '1' .and. ZAM_CANVEN == '100015' .and. ZAM_POSVEN == 'N'
			lRet := .F.
		OtherWise
	EndCase
Return lRet

User function MORA934R()
	Local aInfos     := {}
	Local aFunctions := {}

	aAdd(aInfos, {"Código:"             , ZAM->ZAM_CONTRT})
	aAdd(aInfos, {"Produto:"            , Posicione("SB1", 1, xFilial("SB1") + ZAM->ZAM_CODPRO, "B1_DESC" ) })
	aAdd(aInfos, {"_______________"     , "___________________"})
	aAdd(aInfos, {"Cliente:"            , ZAM->ZAM_CODCLI})
	aAdd(aInfos, {"Nome:"               , Alltrim(ZAM->ZAM_NOMCLI)})
	aAdd(aInfos, {"_______________"     , "___________________"})
	aAdd(aInfos, {"Opção de Pag.:"      , u_xBoxDesc("ZAM_FPAG",ZAM->ZAM_FPAG)})
	aAdd(aInfos, {"Valor:"              , u_autopict(ZAM->ZAM_VLTOT, .T.)})
	aAdd(aInfos, {"Dia Venc.:"          , Posicione("SE4",1,xFilial("SE4") + ZAM->ZAM_CPAGPV, "E4_DESCRI")})
	aAdd(aInfos, {"_______________"     , "___________________"})

	oContrato := GvContratoPlano():New( ZAM->ZAM_CONTRT, ZAM->ZAM_CODCLI )

	If FunName() <> "MORA934O"
		aAdd(aInfos, {"Mês de Referência:"  , StrZero( oContrato:GetMesReferencia() ,2) })
		aAdd(aInfos, {"Próxima Geração:"    , dToC( oContrato:GetProximaGeracao() ) })
	EndIf

	jAtalho := JsonObject():New()
	jAtalho[ 'bRotina' ]   :={|| u_MORA025(ZAM->ZAM_CONTRT) }
	jAtalho[ 'key' ]       := VK_F8
	jAtalho[ 'descricao' ] := "F8 - Histórico"

	aAdd( aFunctions, jAtalho)

	If  AllTrim(pswRet(1)[1][12]) $ SuperGetMV("MV_PERREAT",.F.,"TI")
		jAtalho2 := JsonObject():New()
		jAtalho2[ 'bRotina' ]   :={|| CobrancaPIX( cCrtParam,.t.)}
		jAtalho2[ 'key' ]       := K_CTRL_F7
		jAtalho2[ 'descricao' ] := "CTRL+F7 - Gerar PIX Reat."

		aAdd( aFunctions, jAtalho2)
	EndIf

	u_Mensalidades( ZAM->ZAM_CONTRT, ZAM->ZAM_CODCLI,aFunctions, aInfos )
Return 

/* MORA934A */
User Function MORA934A(cAlias, nReg, nOpc)
	Local i

	do case

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³(2)Visualizar ou (3)incluir ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case nOpc == 2 .or. nOpc == 3

			//Se for visualizacao verifica se houve reativacao para exibir o aviso
			If nOpc == 2
				If VerReat()
					MsgInfo("Este contrato sofreu reativação e suas carências podem ter sido modificadas."+chr(13)+chr(10)+"Caso necessário, analisar o histórico.")
				EndIf
				
				If u_LoteErro()
					MsgInfo("Contrato com carnê troca, favor verificar as mensalidades!")
				endif
				
				//Função que verifica casos específicos de contratos em ações judiciais e emite uma mensagem
				VerAcaJud()

				oCts := GvCtsReceber():New("PLANO")
				If oCts:ExistRAs( ZAM->ZAM_CONTRT )
					MsgInfo("Este contrato tem títulos de RA em aberto, favor entrar em contato com o financeiro", "Contrato com Saldo de RAs")
				EndIf

				//Instancia a classe Clientes e executa ometodo de verificar cpf
				oClientes := ClientesSA1():New()
				oClientes:consultaCpf(ZAM->ZAM_CODCLI,ZAM->ZAM_CGC)
				
			EndIf

			If u_fTela934(cAlias, nReg, nOpc)
				If nOpc == 3
				
					cHistIn := 'INCLUSÃO DE CONTRATO - RESUMO' + CRLF
					cHistIn += Replicate("-",50) + CRLF
					
					cHistIn += "Data: "+ DTOC(ddatabase) + CRLF
					cHistIn += "Hora: "+ time() + CRLF
					cHistIn += "Usuário: "+ cUserName + CRLF
					cHistIn += "Regra Contratual: "+ZAM->ZAM_REGCON + CRLF
					cHistIn += "Plano: " + ZAM->ZAM_CODPRO + CRLF
					cHistIn += "Valor: " + Transform(ZAM->ZAM_VALOR,"@E 999,999,999.99") + CRLF
					cHistIn += "Tx Titular: " + Transform(ZAM->ZAM_VLTAXA,"@E 999,999,999.99") + CRLF
					cHistIn += "Tx Dependentes: " + Transform(ZAM->ZAM_VLTXDE,"@E 999,999,999.99") + CRLF

					If !empty(ZAM->ZAM_CODPUN)	
						cHistIn += "Aditivo: "+ ZAM->ZAM_CODPUN + chr(10) + chr(13)
						cHistIn += "Valor: " + Transform(ZAM->ZAM_VLUNIC,"@E 999,999,999.99") + chr(10) + chr(13)
					EndIf
					
					cHistIn += "T O T A L: " + Transform(ZAM->ZAM_VLTOT,"@E 999,999,999.99") + chr(10) + chr(13)
					
					U_fGeraHist(ZAM->ZAM_CONTRT,'ZAM',ZAM->ZAM_CODCLI,ZAM->ZAM_LOJA,ZAM->ZAM_CODPRO,'0001',ZAM->ZAM_CONTRT,cHistIn,.F.)
					
					SX3->(dbSetOrder(1))
					SX3->(dbSeek("ZAM"))
					
					cHistIn := PADC("Dados Gerais do Contrato",50) + CRLF
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
					cHistIn += "Rotina que gerou o Historico:" + Funname() + CRLF
					
					U_fGeraHist(ZAM->ZAM_CONTRT,'ZAM',ZAM->ZAM_CODCLI,ZAM->ZAM_LOJA,ZAM->ZAM_CODPRO,'0001',ZAM->ZAM_CONTRT,cHistIn,.F.)
					
					//Verifico se o usuario logado pertence aos vendedores do call center
					if RetCodUsr() $ supergetmv('MS_USERCAL',.F.,'') .or. (aScan(UsrRetGrp(RetCodUsr()),{|x| x $ supergetmv('MS_GRUPCAL',.F.,'') }) > 0)
						ZFE->(dbsetorder(1))
						if !ZFE->(dbseek(xFilial('ZFE')+ZAM->ZAM_CONTRT))
							Reclock('ZFE',.T.)
								ZFE->ZFE_FILIAL := xFilial('ZFE')
								ZFE->ZFE_CODIGO := ZAM->ZAM_CONTRT 
								ZFE->ZFE_REGCON := ZAM->ZAM_REGCON
								ZFE->ZFE_STATUS := 'V'
							Msunlock()
						endif
					endif
					//SetComissao() função adicionada na ativação do contrato

					// verica se existe RA
					oCts := GvCtsReceber():New("PLANO")
					If oCts:ExistRAs( ZAM->ZAM_CONTRT,,ZAM->ZAM_CODCLI )
						FWAlertinfo("Este contrato possui um titulo de RA em aberto o mesmo será compensado na ativação do contrato")
					else
						FWAlertinfo("Este contrato não possui nenhum titulo de RA em aberto.")
					EndIf

				EndIf

			Endif		

		//ÚÄÄÄÄÄÄÄ¿
		//³Alterar³
		//ÀÄÄÄÄÄÄÄÙ
		Case nOpc == 4

			SU7->(dbsetorder(4))

			If !SU7->(dbseek(xFilial("SU7")+__cuserId))

				If ZAM->ZAM_STATUS $ '2,3,4,5'
					Alert('O status do contrato não permite alteração. Somente contrato ativo ou pré-contrato.')
					Return
				EndIf
				
				If u_LoteErro()
					MsgInfo("Contrato com carnê troca, favor verificar as mensalidades!")
				endif

			EndIf

			If VerReat()
				MsgInfo("Este contrato sofreu reativação e suas carências podem ter sido modificadas."+chr(13)+chr(10)+"Caso necessário, analisar o histórico.")
			EndIf
			//Função que verifica casos específicos de contratos em ações judiciais e emite uma mensagem
			VerAcaJud()
			
			//Instancia a classe Clientes e executa ometodo de verificar cpf
			oClientes := ClientesSA1():New()
			oClientes:consultaCpf(ZAM->ZAM_CODCLI,ZAM->ZAM_CGC)
			
			u_fTela934(cAlias, nReg, nOpc)
			SetComissao()

		//ÚÄÄÄÄÄÄÄ¿
		//³Legenda³
		//ÀÄÄÄÄÄÄÄÙ
		Case nOpc == 7

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Define as cores da Legenda                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aMatriz 	:= {}
			aCores 	:= {}
			aLegenda := {}
			aMatriz	:= {	{"ZAM->ZAM_STATUS == '0'", "BR_BRANCO"  ,'Contrato em Avaliação'},;
						  	{"ZAM->ZAM_STATUS == '1'", "BR_VERDE"   ,'Contrato Ativo'       },;
						  	{"ZAM->ZAM_STATUS == '2'", "BR_AZUL"    ,'Contrato Suspenso'    },;
						  	{"ZAM->ZAM_STATUS == '3'", "BR_VERMELHO",'Contrato Encerrado'   },;
						  	{"ZAM->ZAM_STATUS == '4'", "BR_PRETO"   ,'Contrato Cancelado'   },;
						  	{"ZAM->ZAM_STATUS == '5'", "BR_AMARELO",'Contrato Migrado'      },;
								{"ZAM->ZAM_STATUS == '6'", "BR_LARANJA",'Ação Judicial'         },;
								{"ZAM->ZAM_STATUS == '1' .and. ZAM->ZAM_CANVEN == '100015' .and. u_vPgtoZAM()", "BR_PINK",'Aguardando Pagamento'     }}

			For i:= 1 to Len(aMatriz)
				aAdd(aCores, 	{aMatriz[i,1], aMatriz[i,2]})
				aAdd(aLegenda,	{aMatriz[i,2], aMatriz[i,3]})
			Next

			BrwLegenda(cCadastro,"Legenda",aLegenda)

		//ÚÄÄÄÄÄÄÄ¿
		//³Excluir³
		//ÀÄÄÄÄÄÄÄÙ
		Case nOpc == 5

			If ZAM->ZAM_STATUS <> '0'
				Alert('Operação não permitida porque o contrato esta ativo.')
				Return
			EndIf

			If !empty(ZAM->ZAM_CONORI)
				Alert('Este pré-contrato foi originado de uma troca de titularidade. Efetue o cancelamento da troca.')
				Return
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³verifica se existe parcela de adesao gerada pa o contrato³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE1->(Dbordernickname('SE1007'))
			If SE1->(DbSeek(xFilial('SE1')+ZAM->ZAM_CONTRT))
				IF SE1->E1_SITUACA != 'Z'
					Alert('Existe(m) parcela(s) gerada(s) para este contrato. Operação não permitida.')
					Return
				ENDIF
			EndIf

			If !MsgNoYes("Deseja excluir este pré-contrato?")
			   Return
		   Else
				If !MsgNoYes("TEM CERTEZA ?")
					Return
				Endif
		   Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³apaga todo o historico do contrato³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SZ8->(dbsetorder(4))
			SZ8->(DbSeek(xFilial('SZ8')+ZAM->ZAM_CONTRT))
			While SZ8->(!EOF()) .and. Alltrim(SZ8->Z8_CONTRAT) == Alltrim(ZAM->ZAM_CONTRT) .and. SZ8->Z8_TIPO <> 'ZGR'
				RecLock("SZ8",.F.)
					SZ8->(dbDelete())
				SZ8->(msUnLock())
				SZ8->(dbskip())
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄ¿
			//³apaga RAs³
			//ÀÄÄÄÄÄÄÄÄÄÙ
			SZ7->(dbsetorder(6))
			SZ7->(DbSeek(xFilial('SZ7')+ZAM->ZAM_CONTRT))
			While SZ7->(!EOF()) .and. Alltrim(SZ7->Z7_CONTRAT) == Alltrim(ZAM->ZAM_CONTRT)
				RecLock("SZ7",.F.)
					SZ7->(dbDelete())
				SZ7->(msUnLock())
				SZ7->(dbskip())
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³apaga dependentes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ZAN->(dbsetorder(1))
			ZAN->(DbSeek(xFilial('ZAN')+ZAM->ZAM_CONTRT))
			While ZAN->(!EOF()) .and. Alltrim(ZAN->ZAN_CONTRT) == Alltrim(ZAM->ZAM_CONTRT)
				RecLock("ZAN",.F.)
					ZAN->(dbDelete())
				ZAN->(msUnLock())
				ZAN->(dbskip())
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³apaga o registro do contrato³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("ZAM",.F.)
				ZAM->(dbDelete())
			ZAM->(msUnLock())

			Z30->( dbSetorder(2) )
			If Z30->( dbSeek( xFilial("Z30") + avKey( ZAM->ZAM_CONTRT,"Z30_VENDA") + avKey( ZAM->ZAM_CODPRO, "Z30_PRODUT" ) ) )
				Z30->( Reclock("Z30", .F.) )
					Z30->Z30_MOTIVO := "Exclusão realizada: " + UsrRetName(__cUserId)
					Z30->( dbDelete() )
				Z30->( MsUnlock() )
			EndIf
		EndCase
Return

Static function SetComissao()
	Local nRecnoDel := 0

	If ZAM->ZAM_STATUS == "0" .and. ZAM->ZAM_CONORI = ' '
		/* Caso seja uma troca de produto */
		BeginSql alias 'dupl'
			Select r_e_c_n_o_ as recno_z30 
				from %Table:Z30% 
				where z30_filial = %xFilial:Z30%
					and z30_venda = %Exp:ZAM->ZAM_CONTRT%
					and z30_produt not in ('912995', %Exp:ZAM->ZAM_CODPRO% )
					and %notdel%
		EndSql
		nRecnoDel := recno_z30
		dupl->( dbCloseArea() )

		If nRecnoDel > 0 
			Z30->( dbGoTo( nRecnoDel ) )
			Z30->( RecLock("Z30", .F.))
				Z30->Z30_MOTIVO := "Troca de plano: " + UsrRetName(__cUserId)
				Z30->( dbDelete() )				
			Z30->( MsUnlock() )
		EndIf

		/*Inclui o contrato na rotina de comissão para na ativação calcular o valor*/
		jVenda := JsonObject():New()
		oComissao := GmComissao():New()

		jVenda['VENDA'] 			:= ZAM->ZAM_CONTRT
		jVenda['VENDEDOR']			:= ZAM->ZAM_CODVEN
		jVenda['PERIODO']			:= oComissao:GetPeriodoAtual( ZAM->ZAM_DTATIV )
		jVenda['PRODUTO']			:= ZAM->ZAM_CODPRO
		jVenda['VALOR']				:= ZAM->ZAM_VLORIG - ZAM->ZAM_VLUNIC
		jVenda['EMISSAO']   		:= ZAM->ZAM_EMISSA
        jVenda['VENDEDOR_NOME']		:= ZAM->ZAM_DSVEND
        jVenda['PRODUTO_DESCRI']	:= Posicione("SB1", 1, xFilial("SB1") + ZAM->ZAM_CODPRO, "B1_DESC" )
        jVenda['CLIENTE']			:= ZAM->ZAM_NOMCLI

		oComissao:NewRecord( jVenda )
		/*-------------------------------------------------------------------------*/
	Endif
Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934B º Autor ³ Leandro Ayala      º Data ³ 13/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Chama funcao padrao do protheus e mostra dados referente   º±±
//±±º            ³ ao cliente setado no contrato.                             º±±
//±±º            ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*User Function MORA934B()

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+ZAM->ZAM_CODCLI+ZAM->ZAM_LOJA))
		Fc010Con()
	EndIf

Return*/

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934C º Autor ³ Leandro Ayala      º Data ³ 28/09/09    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Tela que mostra os beneficios do plano(produto) do contratoº±±
//±±º            ³selecionado.                                                º±±
//±±º            ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³ cContrt- Contrato                                          º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934C(cCont)

	Local lRet 	:= .F.
	Local aBene := {}
	Local cBenef:= ""
	Local lMig := .F.
	Private _oDlg1
	Private oLstBen
	Private aLstBen := {}
	Private CodBene := ZAM->ZAM_CODPRO
	
	If zam->zam_Carfun > ddatabase .and. !empty(zam->zam_proant)
		CodBene := ZAM->ZAM_PROANT
		lMig	:= .T.
	endif

	oBenef := GvBeneficioPlano():new(ZAM->ZAM_CONTRT)
	aBenef := oBenef:getBeneficio() 

	if len(aBenef) == 0
		//Grava os beneficios na tabela de beneficios do plano
    lRet := oBenef:setBeneficio(ZAM->ZAM_CODPRO,'P')

		if !lRet
			MsgAlert('Não foi possível cadastrar os beneficios do plano, processo cancelado!')
			DisarmTransaciton()
			return .F.
		endif
		

		//Caso tenha unico, grava os beneficios do unico
		if !empty(ZAM->ZAM_CODPUN)
			lRet := oBenef:setBeneficio(ZAM->ZAM_CODPUN,'U')

			if !lRet
				MsgAlert('Não foi possível cadastrar os beneficios do plano, processo cancelado!')
				DisarmTransaciton()
				return .F.
			endif
		endif

		aBenef := oBenef:getBeneficio() 

	endif

	

	DEFINE MSDIALOG _oDlg1 TITLE "BENEFÍCIOS - "+alltrim(Posicione("SB1",1,xFilial("SB1")+CodBene,"B1_DESC")) + Iif(!empty(ZAM->ZAM_CODPUN)," e "+ Posicione("SB1",1,xFilial("SB1")+ZAM->ZAM_CODPUN,"B1_DESC"),"" ) FROM C(50),C(50) TO C(445),C(400) PIXEL
		
		@ C(160),C(000) Jpeg FILE "\imagens\logo_GM_Ass_Baixa.png" Size C(280),C(040)	PIXEL OF _oDlg1
		@ C(000),C(000) ListBox oLstBen Fields HEADER "Codigo","Descricao","Quantidade" Size C(177),C(160) Of _oDlg1 Pixel ColSizes 50,130,20
		@ C(170),C(147) BUTTON "&Fechar"    Size C(030),C(025) OF _oDlg1 PIXEL ACTION (_oDlg1:End())
		
		If lMig
			@ C(170),C(30) Say "Observação: Este contrato sofreu migração e encontra-se" Size C(150),C(10) COLOR CLR_BLUE PIXEL OF _oDlg1
			@ C(175),C(30) Say "em carência, os beneficios mostrados refere-se aos" Size C(150),C(10) COLOR CLR_BLUE PIXEL OF _oDlg1
			@ C(180),C(30) Say "beneficios do plano anterior!" Size C(150),C(10) COLOR CLR_BLUE PIXEL OF _oDlg1
		Endif


		oLstBen:SetArray(aBenef)

		oLstBen:bLine := {|| {;
					aBenef[oLstBen:nAT,01],;
					aBenef[oLstBen:nAT,02],;
					aBenef[oLstBen:nAT,03]}}

	//fLstBene(cCont)

	ACTIVATE MSDIALOG _oDlg1 CENTERED

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934D º Autor ³ Leandro Ayala      º Data ³ 28/09/09    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Funcao responsavel por verificar se o cliente informado    º±±
//±±º            ³possui campanha associada para carregar os dados em relacao º±±
//±±º            ³a campanha para o contrato.                                 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³ cTipo = PB - publica PR - privada                          º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934D(cTipo)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³se for cliente verifica campanhas Publicas     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If cTipo == "PB"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³query que verifica se existe campanha valida para ser utilizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      cquery := "SELECT * FROM "+RetSqlName("ZFC")+" ZFC "
      cquery += "WHERE ZFC.D_E_L_E_T_ <> '*' AND ZFC.ZFC_ABRANG = 'PUBL' "
      cquery += "ORDER BY ZFC.ZFC_DTINI DESC "

	   TcQuery cQuery New Alias "QRY016D"

		While QRY016D->(!eof())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³preenche os campos com os dados da campanha³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 		If (M->ZAM_EMISSA >= STOD(QRY016D->ZFC_DTINI) .and. M->ZAM_EMISSA <= STOD(QRY016D->ZFC_DTFIM)) .or. (empty(QRY016D->ZFC_DTINI) .and. empty(QRY016D->ZFC_DTFIM))

		 		M->ZAM_REDCAR 	:= QRY016D->ZFC_REDCAR
		   	M->ZAM_DESCVL	:= QRY016D->ZFC_DESCPE

		   	If QRY016D->ZFC_FPAGES == "S"
		   		M->ZAM_FPAG	:= QRY016D->ZFC_FPAG
		   	EndIf

		   	If QRY016D->ZFC_CPAGES == "S"
		   		M->ZAM_CPAGPV	:= QRY016D->ZFC_CPAG
		   	Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³zera os campos pra nao ficar dados de uma atualizacao anterior³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	Else
	   		M->ZAM_REDCAR 	:= 0
		   	M->ZAM_DESCVL	:= 0
	   	EndIf

	   	QRY016D->(dbskip())
	   EndDo

	   QRY016D->(dbclosearea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³se for empresa verifica a campanha associada a empresa informada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cTipo == "PR"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³seleciona o cliente [empresa]  e verifica a campanha associada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      SA1->(dbsetorder(1))
      If SA1->(dbseek(xfilial("SA1")+M->ZAM_CLIFAT))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³verifica se a campanha esta ativa (periodo)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         ZFC->(dbsetorder(1))
         If ZFC->(dbseek(xfilial("ZFC")+SA1->A1_CODCAM))

      		If !empty(ZFC->ZFC_DTINI) .and. !empty(ZFC->ZFC_DTFIM)

      			If M->ZAM_EMISSA >= ZFC->ZFC_DTINI .and. M->ZAM_EMISSA <= ZFC->ZFC_DTFIM

	      			M->ZAM_REDCAR 	:= ZFC->ZFC_REDCAR
			   		M->ZAM_DESCVL	:= ZFC->ZFC_DESCPE

			   		If ZFC->ZFC_FPAGES == "S"
			   			M->ZAM_FPAG	:= ZFC->ZFC_FPAG
			   		EndIf

			   		If ZFC->ZFC_CPAGES == "S"
			   			M->ZAM_CPAGPV	:= ZFC->ZFC_CPAG
			   		Endif

			   		M->ZAM_CARFUN := M->ZAM_EMISSA + (M->ZAM_CARENC * (1 - M->ZAM_REDCAR/100))

      		   EndIf

      		ElseIf  empty(ZFC->ZFC_DTINI) .and. empty(ZFC->ZFC_DTFIM)

      			M->ZAM_REDCAR 	:= ZFC->ZFC_REDCAR
			   	M->ZAM_DESCVL	:= ZFC->ZFC_DESCPE

			   	If ZFC->ZFC_FPAGES == "S"
			   		M->ZAM_FPAG	:= ZFC->ZFC_FPAG
			   	EndIf

			   	If ZFC->ZFC_CPAGES == "S"
			   		M->ZAM_CPAGPV	:= ZFC->ZFC_CPAG
			   	Endif

      			M->ZAM_CARFUN := M->ZAM_EMISSA + (M->ZAM_CARENC * (1 - M->ZAM_REDCAR/100))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³se informou a empresa mas a campanha associada nao esta na validade³
				//³apaga os dados para o caso desses dados terem sidos carregados     ³
				//³na digitacao do CPF, onde se carrega campanha publica.             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      		Else

      			M->ZAM_REDCAR := 0
		   		M->ZAM_DESCVL	:= 0
		   		M->ZAM_FPAG	:= '1'
		   		M->ZAM_CPAGPV	:= '   '
      			M->ZAM_CARFUN := M->ZAM_EMISSA + (M->ZAM_CARENC * (1 - M->ZAM_REDCAR/100))
      		EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³se informou a empresa mas essa nao tem campanha associada     ³
			//³apaga os dados para o caso desses dados terem sidos carregados³
			//³na digitacao do CPF, onde se carrega campanha publica.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	Else
      		M->ZAM_REDCAR := 0
		   	M->ZAM_DESCVL	:= 0
		   	M->ZAM_FPAG	:= '1'
		   	M->ZAM_CPAGPV	:= '   '
         	M->ZAM_CARFUN := M->ZAM_EMISSA + (M->ZAM_CARENC * (1 - M->ZAM_REDCAR/100))
         Endif

      EndIf

	Else

		M->ZAM_REDCAR := 0
		M->ZAM_DESCVL	:= 0
		M->ZAM_FPAG	:= '1'
		M->ZAM_CPAGPV	:= '   '

		M->ZAM_CARFUN := M->ZAM_EMISSA + (M->ZAM_CARENC * (1 - M->ZAM_REDCAR/100))

	Endif


Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934F º Autor ³ Leandro Ayala      º Data ³ 07/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Funcao responsavel por verificar se o codigo informado do  º±±
//±±º            ³contrato esta entre as propostas validas, no caso de sim    º±±
//±±º            ³carrega p o contrato os dados da regra contratual.          º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934F()

	Local cMsgSol
	Local	cLogErro
	cMsgSol	:= ''
	cLogErro	:= ''
	cPerg 		:= 'CODAUT0001'
	
//	M->ZAM_CONTRT := strzero(val(M->ZAM_CONTRT),8)

	ZFE->(dbsetorder(1))

	//Verifica se a proposta foi autorizada pelo callcenter
	If cEmpAnt == '05'

		ZZQ->(dbsetorder(1))
		If ZZQ->(dbseek(xFilial("ZZQ")+M->ZAM_CONTRT))

			MsgInfo("Esta Proposta foi autorizada pelo call Center. Informe o código da autorização gerado!")
			PutSx1(cPerg,"01","Nº Autorização"	,"Nº Autorização"	,"Nº Autorização"	,"mv_ch1","C",18,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",,,)

			If !Pergunte(cPerg,.T.)
				Return
			Endif

			//Seleciona os dados do titular e importa para os campos
			cQuery := "SELECT * FROM "+RetSqlName("ZZQ")
			cQuery += " WHERE ZZQ_ITEM = 'TI' AND ZZQ_CONTRT = '"+M->ZAM_CONTRT+"' AND D_E_L_E_T_ = ' ' AND ZZQ_CODAUT = '"+alltrim(mv_par01)+"'"

			TcQuery cQuery New Alias "QRYTIT"

			If !QRYTIT->(eof())

				M->ZAM_CODPRO := QRYTIT->ZZQ_CODPRO
				M->ZAM_CODVEN := QRYTIT->ZZQ_CODVEN
				M->ZAM_CGC		:= QRYTIT->ZZQ_CGC
				M->ZAM_CEP		:= QRYTIT->ZZQ_CEP
				M->ZAM_TELRES	:= QRYTIT->ZZQ_TELRES
				M->ZAM_DTNAS	:= STOD(QRYTIT->ZZQ_DTNAS)
				M->ZAM_CODTX	:= QRYTIT->ZZQ_CODTXT
				M->ZAM_DESCTX	:= QRYTIT->ZZQ_DESTXT
				M->ZAM_VLTAXA	:= QRYTIT->ZZQ_VLTXTI
				M->ZAM_VALOR	:= QRYTIT->ZZQ_VLPLAN
				M->ZAM_VLTXDE 	:= QRYTIT->ZZQ_VLTXDE
				M->ZAM_VLTOT	:= QRYTIT->ZZQ_VLTOT
				M->ZAM_CARFUN	:= QRYTIT->ZZQ_DTCARE

				//Carga dos dados dos dependentes
				aCols := {}

				cQuery := "SELECT * FROM "+RetSqlName("ZZQ")
				cQuery += " WHERE ZZQ_ITEM <> 'TI' AND ZZQ_CONTRT = '"+M->ZAM_CONTRT+"' AND D_E_L_E_T_ = ' ' AND ZZQ_CODAUT = '"+alltrim(mv_par01)+"'"

				TcQuery cQuery New Alias "QRYDEP"

				While !QRYDEP->(eof())

					aAdd(aCols,{QRYDEP->ZZQ_ITEM,space(40),QRYDEP->ZZQ_SEXO,STOD(QRYDEP->ZZQ_DTNASC),QRYDEP->ZZQ_PARENT,QRYDEP->ZZQ_PARENT,ddatabase,'',CTOD("  /  /  "),;
						QRYDEP->ZZQ_CODTX,QRYDEP->ZZQ_DESCTX,QRYDEP->ZZQ_VLTAXA,QRYDEP->ZZQ_TXDEPE,'A',QRYDEP->ZZQ_CARENC,QRYDEP->ZZQ_REDCAR,;
						STOD(QRYDEP->ZZQ_DTCARE),'',CTOD('  /  /  '),__cuserid,time(),'',CTOD('  /  /  '),'',CTOD('  /  /  '),.F.})

					QRYDEP->(dbskip())
				EndDo

				GetDRefresh()
				QRYDEP->(dbclosearea())

			Else
				MsgInfo("Não localizada proposta com a autorização informada. Favor verificar o código informado.")
				QRYTIT->(dbclosearea())
				Return .F.
			EndIf

			QRYTIT->(dbclosearea())
		EndIf
	EndIf
Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934G º Autor ³ Leandro Ayala      º Data ³ 07/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Calcula a carencia do contrato quando informada a red de   º±±
//±±º            ³carencia na tela do contrato.                               º±±
//±±º            ³ Executada na validacao do campo ZAM_REDCAR                 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934G()
	Local i
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica reducao digitada. Se for compra de carencia (recife)   ³
	//³os 100% de carencia podem ser informados mesmo nao sendo empresa|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If M->ZAM_CPRCAR == "N"
		//Regra comercia para planos migrados de outros planos
		//Se a Forma de pagamento for migração, a carência pode ser de 0, 60 ou 180 dias
		if M->ZAM_FPAG == '5' .and. empty(M->ZAM_CLIFAT)  //Migracao
			aRet		:= {}
			aParamBox	:= {}
				
			aAdd(aParamBox,{3,"Selecione a Carência: ",1,{"Redução de 100% ","Carência de 60 dias","Carência de 90 dias","Carência Normal"},60,"",.T.})
			ParamBox(aParamBox,"MIGRAÇÂO",@aRet)

			Do Case
				Case (aRet[1] == 1)
					M->ZAM_CARFUN := M->ZAM_EMISSA 
					M->ZAM_CARENC := 180
					M->ZAM_REDCAR := 100
				Case (aRet[1] == 2)
					M->ZAM_CARFUN := M->ZAM_EMISSA + 60
					M->ZAM_CARENC := 60
					M->ZAM_REDCAR := 0
				Case (aRet[1] == 3)
					M->ZAM_CARFUN := M->ZAM_EMISSA + 90
					M->ZAM_CARENC := 90
					M->ZAM_REDCAR := 0
				Case (aRet[1] == 4)
					M->ZAM_CARFUN := M->ZAM_EMISSA + 180
					M->ZAM_CARENC := 180
					M->ZAM_REDCAR := 0
			EndCase
			
			For i := 1 to len(aCols)
				aCols[i][15] := M->ZAM_CARENC
				aCols[i][16] := M->ZAM_REDCAR
				aCols[i][17] := M->ZAM_CARFUN
			next
			GetDRefresh()
		else
			If !empty(M->ZAM_CLIFAT) .and. (M->ZAM_REDCAR <> 0 .and. M->ZAM_REDCAR <> 50 .and. M->ZAM_REDCAR <> 60  .and. M->ZAM_REDCAR <> 100 .and. M->ZAM_REDCAR <> 90)
				MsgInfo("A redução de carencia informada não pode ser diferente de : 0%, 50%")
				Return .F.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³calcula a carencia³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M->ZAM_CARFUN := M->ZAM_EMISSA + (M->ZAM_CARENC * (1 - M->ZAM_REDCAR/100))
		EndIf
   EndIf

Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³fTela934  º Autor ³ Leandro Ayala      º Data ³ 13/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Monta a tela (cabecalho, Rodape e itens) e identifica a    º±±
//±±º            ³ acao(nOpc).                                                º±±
//±±º            ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³ cAlias - Alias da tabela                                   º±±
//±±º            ³ nRecNo - Numero do registro que esta setado                º±±
//±±º            ³ nOpc   - Numero da opcao (2 - Visualizar; 3- Incluir)      º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function fTela934( cAlias, nRecNo, nOpc )

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Variaveis³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	Local	nX         		:= 0
	Local	nTamCabec		:= 290
	local	aBotoes			:= {}
	Local	cTitulo			:="Contrato"
	Local	cAliasEnchoice	:="ZAM"
	Local	cAliasGetD		:="ZAN"
	Local	cLinOk			:="U_LinhOK"
	Local	cTudOk			:="U_M934OK"//"AlwaysTrue()"
	Local	cFieldOk		:="AlwaysTrue()"
	Local	aCpoEnchoice	:= {}
	Private	aHeader			:= {}
	Private	aCols			:= {}


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Variaveis de Memoria da Enchoice³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("ZAM",iif(nOpc==3,.T.,.F.))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o aHeader³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CriaHeader()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	montaCols(nOpc)

	If nOpc == 2 .or. nOpc == 3
		lInclui	:= .T.
		lAltera	:= .F.
	EndIf
	If nOpc == 4
		lInclui	:= .F.
		lAltera	:= .T.
	EndIf


	aAdd(aBotoes,{"SIMULACA"		,{|| U_MORA021(ZAM->ZAM_CONTRT)}	, "Tela de Mensalidades", "Mensalidade"})
	aAdd(aBotoes,{"NOTE"			,{|| U_MORA025(ZAM->ZAM_CONTRT)}	, "Histórico do Contrato", "Histórico"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para processamento dos Gets³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet:= Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpc ,nOpc ,cFieldOk,.T.,,,,aBotoes,,nTamCabec)
	//lRet:=u_Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpc ,nOpc ,cFieldOk,,,,,nTamCabec,"+ZAN_ITEM",lAltera,lInclui,aBotoes)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executar processamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		if nOpc == 3 .or. nOpc == 4 //Incluir ou alterar
			if GrvContrt(nOpc)	
				/*Só atualiza caso seja inclusão ou alteração com contrato pré ativo*/
				if nOpc == 3 .or. ( nOpc == 4 .and. ZAM->ZAM_STATUS == "0" ) //Incluir: Confirma auto-numercao

					RecLock("ZAM", .F.)
						ZAM->ZAM_VLORIG	:= ZAM->ZAM_VLTOT
						ZAM->ZAM_VLTXOR	:= ZAM->ZAM_VLTAXA
						ZAM->ZAM_VTXDOR	:= ZAM->ZAM_VLTXDE
						ZAM->ZAM_FILIAL	:= xFilial('ZAM')
						If !empty(ZAM->ZAM_CODPUN)
							ZAM->ZAM_CONUNI := ZAM->ZAM_CONTRT
						EndIf	
					ZAM->(msUnLock())

					If Len(M->ZAM_MEMO) > 0
						MSMM(ZAM->ZAM_CODMEM,80,,M->ZAM_MEMO,1,,,"ZAM","ZAM_CODMEM")
					Endif

					ZAN->(DBSETORDER(1))
					ZAN->(DBSEEK(xFILIAL('ZAN')+ZAM->ZAM_CONTRT))
					WHILE ZAN->(!EOF()) .AND. ZAN->ZAN_CONTRT == ZAM->ZAM_CONTRT
						RecLock("ZAN", .F.)
							ZAN->ZAN_VLORIG	:= ZAN->ZAN_VLTAXA
							ZAN->ZAN_CODCLI	:= ZAM->ZAM_CODCLI
						ZAN->(msUnLock())
						ZAN->(DBSKIP())
					ENDDO
					confirmSX8()
				EndIf

			endIf
		EndIf
	else
		if nOpc == 3 //Incluir
			rollBackSX8()
		endIf
	Endif



Return lRet


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³CriaHeaderº Autor ³ Leandro Ayala      º Data ³ 13/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Cria as variaveis vetor aHeader, para montagem do cabeca-  º±±
//±±º            ³ lho da tela (dentro do enchoice)                           º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³ cAlias - Alias da tabela                                   º±±
//±±º            ³ nRecNo - Numero do registro que esta setado                º±±
//±±º            ³ nOpc   - Numero da opcao                                   º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function CriaHeader()

	nUsado		:= 0
	aHeader	:= {}

	SX3->(dbSetOrder(1))
	SX3->(dbSeek("ZAN"))
	While ( SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "ZAN" )
	   If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL ) .and. !(allTrim(SX3->X3_CAMPO) $ "ZAN_FILIAL,ZAN_CONTRT,ZAN_DESCPA")
	      aAdd(aHeader,{ Trim(X3Titulo()), ;
	                     SX3->X3_CAMPO   , ;
	                     SX3->X3_PICTURE , ;
	                     SX3->X3_TAMANHO , ;
	                     SX3->X3_DECIMAL , ;
	                     SX3->X3_VALID   , ;
	                     SX3->X3_USADO   , ;
	                     SX3->X3_TIPO    , ;
	                     SX3->X3_ARQUIVO , ;
  	                     SX3->X3_OBRIGAT , ;
	                     SX3->X3_CONTEXT } )
	      nUsado++
	   Endif
	   SX3->(dbSkip())
	End

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³MontaCols º Autor ³ Leandro Ayala      º Data ³ 13/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Monta coluna de itens da tela, de acorodo com a opcao esco-º±±
//±±º            ³ lhida. (Incluir ou visualizar)                             º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³ nOpc   - Numero da opcao                                   º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function montaCols(nOpc)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Variaveis³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	Local nCols := 0
	Local nX, nB

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³visualizar ou alterar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 2 .or. nOpc == 4

		dbSelectArea("ZAN")
		ZAN->(dbSetOrder(1))
		ZAN->(dbSeek( cSeek := xFilial("ZAN")+ZAM->ZAM_CONTRT))

		While ZAN->(!Eof()) .and. cSeek == ZAN->ZAN_FILIAL + ZAN->ZAN_CONTRT

			aAdd(aCols,Array(nUsado+1))
			nCols ++

			For nX := 1 To nUsado
				If ( aHeader[nX][10] != "V") //Verifica se for Virtual "V"
					aCols[nCols][nX] := FieldGet(FieldPos(aHeader[nX][2]))
				Else
					aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
				Endif
		   Next nX

		   aCols[nCols][nUsado+1] := .F.
		   ZAN->(dbSkip())

		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³copia o acols atual³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      aCopCols := acols

	//ÚÄÄÄÄÄÄÄ¿
	//³incluir³
	//ÀÄÄÄÄÄÄÄÙ
	Elseif nOpc == 3

		aAdd(aCols,Array(nUsado+1))

		for nX := 1 to nUsado
			aCols[1][nX] := CriaVar(aHeader[nX][2])
		next nX

		aCols[1][nUsado+1] := .F.
		aCols[1][aScan(aHeader,{|x| Trim(x[2])=="ZAN_ITEM"})] := "01"
		aCols[1][aScan(aHeader,{|x| Trim(x[2])=="ZAN_DTINC"})] := ddatabase - 1
		aCols[1][aScan(aHeader,{|x| Trim(x[2])=="ZAN_STATUS"})] := "A"

	EndIf

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ GrvContrtº Autor ³ Leandro Ayala      º Data ³ 13/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Grava os dados do Contrato.                                º±±
//±±º            ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³ lRet = logico                                              º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³ nOpcx - Tipo de gravacao (3-Inclusao;4-Alteracao)          º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
static function GrvContrt(nOpcx)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Variaveis³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	Local bCampo   	:= {|nCPO| Field(nCPO) }
	Local nQuantTot	:= 0
	Local lResult		:= .F.
	Local cAlteracao	:= ""
	Local nPosUsAlte	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "ZAN_USUALT"})
	Local nPosDtAlte	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "ZAN_DTALT"})
	Local nPosHrAlte	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "ZAN_HRALT"})
	Local nB, nA, nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³inicia gravacao dos dados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Varre o Array aCols p/ Gravar o Arquivo PAO.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nA := 1 To Len(aCols)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for inclusao e estiver deletado, ignorao ³
			//³Ou Se nao estiver inforado o nome do depen- ³
			//³dente.                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (nOpcx == 3 .AND. aCols[nA][nUsado + 1] ) .or. Empty(aCols[nA][2])
				Loop
			EndIf

			dbSelectArea("ZAN")
			dbSetOrder(1) // filial + contrato + seq

			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+M->ZAM_CODCLI))

			nPosSeq 		:= aScan(aHeader,{|x| AllTrim(x[2]) == Upper('ZAN_ITEM')})
			ZAN->(dbSeek(xFilial("ZAN")+M->ZAM_CONTRT+aCols[nA][nPosSeq]))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava historico dos dependentes - inclusao,alteracao   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAlteracao 	:= ''
			cTitHist		:= ''

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³inclusao de dependente³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !ZAN->(Found()) .And. nOpcx == 4
  	 			cTitHist := "INCLUSÃO DE DEPENDENTE (PRÉ-CONTRATO)"+ chr(10) + chr(13)
  	 			cTitHist	+= "-----------------------------------------------" + chr(10) + chr(13)
  	 			cTitHist	+= "Item: "+AllTrim(gdFieldGet("ZAN_ITEM", nA))+"  Nome: "+AllTrim(gdFieldGet("ZAN_NOME", nA))+ chr(10) + chr(13)

  	 			u_fGeraHist(M->ZAM_CONTRT+gdFieldGet("ZAN_ITEM", nA),"ZAN",M->ZAM_CODCLI,M->ZAM_LOJA,M->ZAM_CODPRO,"0001",M->ZAM_CONTRT,cTitHist,.F.)

			//ÚÄÄÄÄÄÄÄÄÄ¿
			//³alteracao³
			//ÀÄÄÄÄÄÄÄÄÄÙ
    		ElseIf ZAN->(Found()) .And. nOpcx == 4

				If ZAM->ZAM_STATUS == '0'
    				cTitHist := "ALTERAÇÃO DE DEPENDENTE (PRÉ-CONTRATO)"+ chr(10) + chr(13)
  	 			Else
  	 				cTitHist := "ALTERAÇÃO DE DEPENDENTE"+ chr(10) + chr(13)
  	 			EndIf

  	 			cTitHist	+= "-----------------------------------------------" + chr(10) + chr(13)
	    		cTitHist	+= "Item: "+ AllTrim(gdFieldGet("ZAN_ITEM", nA)) + chr(10) + chr(13)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³verifica qual campo foi alterado³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    		If gdFieldGet("ZAN_NOME"  , nA) <> ZAN->ZAN_NOME
    					cAlteracao += 'Nome: De ' + Alltrim(ZAN->ZAN_NOME) + ' para ' + Alltrim(gdFieldGet("ZAN_NOME"  , nA)) + Chr(10) + Chr(13)
    			EndIf
    			If gdFieldGet("ZAN_DTNASC", nA) <> ZAN->ZAN_DTNASC
    					cAlteracao += 'Data de Nascimento: De ' + dtoc(ZAN->ZAN_DTNASC) + ' para ' + dtoc(gdFieldGet("ZAN_DTNASC"  , nA)) + Chr(10) + Chr(13)
    			EndIf
    			If gdFieldGet("ZAN_PARENT", nA) <> ZAN->ZAN_PARENT
	    				cAlteracao += 'Parentesco: De ' + Alltrim(ZAN->ZAN_PARENT) + ' para ' + Alltrim(gdFieldGet("ZAN_PARENT"  , nA)) + Chr(10) + Chr(13)
	    		EndIf
    			If gdFieldGet("ZAN_DESCTX", nA) <> ZAN->ZAN_DESCTX
    					cAlteracao += 'Taxa: De ' + Alltrim(ZAN->ZAN_DESCTX) + ' para ' + Alltrim(gdFieldGet("ZAN_DESCTX"  , nA)) + Chr(10) + Chr(13)
    			EndIf
    			If gdFieldGet("ZAN_STATUS", nA) <> ZAN->ZAN_STATUS
    					cAlteracao += 'Status: Novo Status: ' + Iif(gdFieldGet("ZAN_STATUS", n) == 'A', 'Ativo', Iif(gdFieldGet("ZAN_STATUS", n) == 'I', 'Inativo','Obito')) + Chr(10) + Chr(13)
    			EndIf
    			If gdFieldGet("ZAN_SEXO"  , nA) <> ZAN->ZAN_SEXO
    					cAlteracao += 'Sexo: De ' + Iif(Alltrim(ZAN->ZAN_SEXO)=='1','Feminino','Masculino') + ' para ' + Iif(Alltrim(gdFieldGet("ZAN_SEXO"  , nA))=='1','Feminino','Masculino')  + Chr(10) + Chr(13)
    			EndIf
    			If gdFieldGet("ZAN_PAREAT", nA) <> ZAN->ZAN_PAREAT
    					cAlteracao += 'Parentesco Atual: De ' + Alltrim(ZAN->ZAN_PAREAT) + ' para ' + Alltrim(gdFieldGet("ZAN_PAREAT"  , nA)) + Chr(10) + Chr(13)
    			EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³verifica se houve alteracao de algum campo³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         If !Empty(cAlteracao)

	    			u_fGeraHist(M->ZAM_CONTRT+gdFieldGet("ZAN_ITEM", nA),"ZAN",M->ZAM_CODCLI,M->ZAM_LOJA,M->ZAM_CODPRO,"0002",M->ZAM_CONTRT, cTitHist + cAlteracao,.F.)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³registra nos campo usuario, hora se houve alteracao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					acols[nA][nPosUsAlte] 	:= __cuserid
					acols[nA][nPosDtAlte]  := ddatabase
					acols[nA][nPosHrAlte]  := time()

				EndIf

	      Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for alteracao ou inclusao ou exclusao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpcx == 4 .OR. nOpcx == 3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se for inclusao, reclock com .T.                        ³
				//³se for alteracao e achar o registro, reclock com .F.    ³
				//³se for alteracao e nao achar o registro, reclock com .T.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lTipoOpc := iif(nOpcx==3 .OR. (nOpcx == 4 .AND. !ZAN->(Found())),.T.,.F.)

				RecLock("ZAN",lTipoOpc)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se estiver deletado, exclui tambem da tabela³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					if ZAN->(Found()) .AND. (aCols[nA, len(aHeader)+1].OR. nOpcx == 5)
						  ZAN->(dbDelete())
					  ZAN->(msUnLock())
					  LOOP
					endif

	            ZAN->ZAN_FILIAL	:= xFilial("ZAN")
					ZAN->ZAN_CONTRT	:= M->ZAM_CONTRT

	            If nOpcx==3
	               ZAN->ZAN_VLORIG:= M->ZAM_VLTAXA
               EndIf

					For nB := 1 To Len(aHeader)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Obtem a Posicao do Campo no Arquivo.                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPosCampo := FieldPos(aHeader[nB][2])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava o Campo no Arquivo.                                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						FieldPut(nPosCampo, aCols[nA][nB])
					Next nB

				ZAN->(MsUnLock())

			Endif

		Next nA

		cAlteracao := '' //Variavel que guarda alteracoes no contrato
		cNomeCampo := ''
		SX3->(dbSetOrder(2))
		RecLock("ZAM",iif(nOpcx==3,.T.,iif(nOpcx == 4,.F.,.T.)))
			if ZAM->(Found() .AND. nOpcx == 5)
					ZAM->(dbDelete())
				ZAM->(msUnLock())
			else
				For nX := 1 TO FCount()
					If nOpcx == 4    //inclusao de um novo contrato
	    				// Se o valor em memoria for diferente do valor na tabela, o campo sofreu alteracao
	    				If M->&(EVAL(bCampo,nX)) <> ZAM->&(EVAL(bCampo,nX))
	    						cNomeCampo := EVAL(bCampo,nX)
	    						SX3->(dbseek(cNomeCampo))
									If SX3->X3_TIPO=='C'
    									cAlteracao += Alltrim(SX3->X3_TITULO) + ': De ' + Alltrim(ZAM->&(EVAL(bCampo,nX))) + ' para ' + Alltrim(M->&(EVAL(bCampo,nX))) + Chr(10) + Chr(13)
    								EndIf
									If SX3->X3_TIPO=='D'
    									cAlteracao += Alltrim(SX3->X3_TITULO) + ': De ' + dtoc(ZAM->&(EVAL(bCampo,nX))) + ' para ' + dtoc(M->&(EVAL(bCampo,nX))) + Chr(10) + Chr(13)
    								EndIf
									If SX3->X3_TIPO=='N'
    									cAlteracao += Alltrim(SX3->X3_TITULO) + ': De ' + transform(ZAM->&(EVAL(bCampo,nX)),"@E 999,999.999") + ' para ' + transform(M->&(EVAL(bCampo,nX)),"@E 999,999.999") + Chr(10) + Chr(13)
    								EndIf
    					EndIf
    				EndIf
					FieldPut(nX,M->&(EVAL(bCampo,nX)))
				Next nX
			endIf

     	If !Empty(cAlteracao)
     		If ZAM->ZAM_STATUS == '0'
     			cTit 	:= "ALTERAÇÃO DE CONTRATO (PRÉ-CONTRATO)"+ chr(10) + chr(13)
  	 		Else
  	 			cTit 	:= "ALTERAÇÃO DE CONTRATO"+ chr(10) + chr(13)
  	 		EndIf
  	 		cTit	+= "-----------------------------------------------" + chr(10) + chr(13)
			u_fGeraHist(ZAM->ZAM_CONTRT,'ZAM',ZAM->ZAM_CODCLI,ZAM->ZAM_LOJA,ZAM->ZAM_CODPRO,'0002',ZAM->ZAM_CONTRT, cTit + cAlteracao,.F.)
		EndIf

		ZAM->(msUnLock())
		If Len(M->ZAM_MEMO) > 0
			MSMM(ZAM->ZAM_CODMEM,80,,M->ZAM_MEMO,1,,,"ZAM","ZAM_CODMEM")
		Endif

	end transaction

Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ LinhOK   º Autor ³ Leandro Ayala      º Data ³ 13/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Verifica se a linha esta deletada e se estiver alterando   º±±
//±±º            ³nao pode deletar apenas se estiver incluindo.               º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³ Array logico                                               º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function LinhOK
	
	Local nQtd65 		:= 0
	Local nContExtra 	:= 0
	Local nQtd70  		:= 0
	Local nQtdDep 		:= 0
	Local nQtdIdade 	:= 0
	Local nDepPla 		:= 0
	Local nDepExtra 	:= 0
	Local nContDir  	:= 0
	Local i
	
	SB1->(dbsetorder(1))
	SB1->(dbseek(xFilial('SB1')+M->ZAM_CODPRO))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz validacao de campos obrigatorios dos dependentes do contrato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If M->ZAM_STATUS != "0" // Só verifica o linha OK e o contrato estiver pré-ativo  
		Return .T. 
	EndIF

	If !aCols[n][len(aHeader)+1]

		If Empty(gdFieldGet("ZAN_NOME", n))

			Help(1," ","OBRIGAT",," Nome do Dependente ",2,0)
			Return AlwaysFalse()


		Else
			If (Empty(gdFieldGet("ZAN_DTNASC", n)) .Or. Empty(gdFieldGet("ZAN_PARENT", n))) .and. (cempant <> "13" .and. ZAM->ZAM_FILORI == '02')
			   Help(1," ","OBRIGAT",," Data de Nascimento ou Parentesco",2,0)
				Return AlwaysFalse()
			EndIf
			
			If	((Alltrim(gdFieldGet("ZAN_PARENT", n)) $ 'FILHO') .and. Calc_Idade(gdFieldGet("ZAN_DTNASC", n),M->ZAM_DTNAS) < 12 ) .or.;
				((Alltrim(gdFieldGet("ZAN_PARENT", n)) $ 'MAE,PAI') .and. Calc_Idade(M->ZAM_DTNAS,gdFieldGet("ZAN_DTNASC", n)) < 12 ) 
				MsgInfo("<b><font color='red'>A diferença de idade entre o títular e dependente possui uma diferença menor que 12 anos</font><b>","Atenção!!")
			EndIf
			
		EndIf

		If !Empty(gdFieldGet("ZAN_CODOBT", n)) .And. Empty(gdFieldGet("ZAN_DTOBT", n))
			Help(1," ","OBRIGAT",," Código do óbito",2,0)
			Return AlwaysFalse()
		Endif

		If Alltrim( M->ZAM_CODPRO ) $ '940050,940051,940052,940053,940054'
			MsgInfo(" O produto selecionado é empresarial e não permite a inclusão de dependentes ", 'Atenção')
			Return .F.
		Endif

		Do Case
			
			case (SB1->B1_GRUPO $ '1099') //Produtos do Prever
				//Se o dependente for FILHO
				/*If alltrim(gdFieldGet("ZAN_PARENT", n)) $ 'FILHO'
				
					Nao permite incluir dependente filho com idado maior que 30 caso nao possua produto cemiterio
					If u_anosidade(gdFieldGet("ZAN_DTNASC", n),ddatabase) > 40 .and. M->ZAM_CEMIT == '2'
						Alert('Não é possivel incluir dependente FILHO maior que 40 anos!')
						Return AlwaysFalse()
					endif
				EndIf*/
				
				SZH->(dbsetorder(2))
				
				if SZH->(dbseek(xFilial('SZH') + '               ' + M->ZAM_CODPRO))
					if !(alltrim(gdFieldGet("ZAN_PARENT", n)) $ SZH->ZH_DEPDIRE)
						for i := 1 to Len(aCols)
							if !aCols[i][len(aHeader)+1] .and. i <> n
								if !(alltrim(gdFieldGet("ZAN_PARENT", i)) $ SZH->ZH_DEPDIRE)
									nDepExtra++
								endif
							endif
						next i
						
						if nDepExtra > 2
							Alert('Só é permitido apenas 3 dependente indireto!')
							Return AlwaysFalse()
						endif
					endif
				endif
				
				//Percorre para verificar a quantidade de dependentes maiores de 75 anos
				for i := 1 to Len(aCols)
					if !aCols[i][len(aHeader)+1]
						
						if u_anosidade(gdFieldGet("ZAN_DTNASC", i),M->ZAM_EMISSA) > 75 .and. alltrim(gdFieldGet("ZAN_PARENT", i)) <> 'CONJ'
							nQtd65++
						endif
						
						nQtdDep++
					endif
				next i
				
				if nQtdDep > 13
					Msginfo('Só é permitido incluir até 10 dependentes para este contrato')
					Return AlwaysFalse()
				endif
				
				//Caso tiver mais de dois dependentes nao permite nova inclusao
				if nQtd65 > 3
					Alert('Só é possível incluir 3 dependentes maiores de 75 anos')
					Return AlwaysFalse()
				endif
			OtherWise
			
				//Busca as regras contratuais do contrato
				ZFD->(dbsetorder(1))
				if ZFD->(dbseek(xFilial('ZFD') + alltrim(M->ZAM_REGCON)))
			
					for i:= 1 to n//len(aCols) //Percorre o acols de dependentes
				
						if !aCols[i][len(aHeader)+1] //Verifica se o dependente esta excluído
						
							//Verifica a quantidade de dependentes extras
							if (alltrim(gdFieldGet("ZAN_PARENT",i)) $ alltrim(Posicione("SZH",2,xfilial("SZH") + '               ' + SB1->B1_COD,"ZH_DEPDIRE")))
								//Verifica a quantidade de dependentes acima de 75 anos
								if u_anosidade(gdFieldGet("ZAN_DTNASC", i),M->ZAM_EMISSA) > ZFD->ZFD_IDLITI
									nQtdIdade++
								EndIf

								nContDir++
								
							else

								if u_anosidade(gdFieldGet("ZAN_DTNASC", i),M->ZAM_EMISSA) > ZFD->ZFD_IDLITI
									nQtdIdade++
								EndIf

								//Continua contabilizando extra para verificar o qtd extra total
								nContExtra++
							endif
							
							nDepPla++
							
						endif
						
					next i

					//Verifica se escedeu a quantidade de limite de idade
					if nQtdIdade > ZFD->ZFD_QTDPID
					
						MsgInfo('Para este plano só é permitido incluir até ' + cValtoChar(ZFD->ZFD_QTDPID) + ' dependentes acima de ' + cvaltochar(ZFD->ZFD_IDLITI) + ' anos!')
						Return AlwaysFalse()
					
					endif

					//Verifica se excedeu a quantidade limite de dependente 
					if nContDir > (ZFD->ZFD_QTDDDI + (ZFD->ZFD_QTDDEX - ZFD->ZFD_QTEXLI))
					
						MsgInfo('Para este plano só é permitido incluir até ' + cValtoChar(ZFD->ZFD_QTDDDI + (ZFD->ZFD_QTDDEX - ZFD->ZFD_QTEXLI)))
						Return AlwaysFalse()
					
					endif
										
					//Verifica se excedeu a quantidade limite de dependente livres
					if nContExtra > ZFD->ZFD_QTDDEX
					
						MsgInfo('Para este plano só é permitido incluir até ' + cValtoChar(ZFD->ZFD_QTDDEX) + ' dependentes livres!')
						Return AlwaysFalse()
					
					endif
			
				endif
				
		EndCase
			
	EndIf

	For i := 1 to len(aCols)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se esta deletado e se esta preenchido.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCols[i][len(aHeader)+1] .and. !Empty(gdFieldGet("ZAN_NOME", i))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se estivar alterando não pode excluir o dependente.          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ALTERA .And. !U_MORF023(M->ZAM_CONTRT)
				aCols[i][len(aHeader)+1] := .F.
				Alert('Não é possível excluir dependente.')
				GetDRefresh()
				Return AlwaysFalse()
			EndIf
		EndIf

	Next

	//Recalculo dos valores do plano 
	/*If M->ZAM_STATUS == '0'
	
		M->ZAM_VLTXDE := 0
	
		For i:=1 TO Len(aCols)
	
			If gdFieldGet("ZAN_STATUS",i) <> 'A' .or. aCols[i][len(aHeader)+1]
				loop
			EndIf
	
			M->ZAM_VLTXDE	+= gdFieldGet("ZAN_VLTAXA", i) + gdFieldGet("ZAN_TXDEPE", i)
	
		Next
	
		M->ZAM_VLTOT := M->ZAM_VALOR+M->ZAM_VLUNIC+M->ZAM_VLTXDE+M->ZAM_VLTAXA+M->ZAM_TXEMP - ((M->ZAM_VALOR+M->ZAM_VLUNIC+M->ZAM_VLTXDE+M->ZAM_VLTAXA+M->ZAM_TXEMP)*(M->ZAM_DESCVL/100))
	
	EndIf*/
		
	cItem := SOMA1(strzero(len(aCols),2)) //Soma a numeracao da coluna item do acols
	
	GetDRefresh()


Return AlwaysTrue()


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ TudoOK   º Autor ³ Leandro Ayala      º Data ³ 13/07/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Função que verifica se mudou o valor e pede a senha de     º±±
//±±º            ³superior para poder fazer a alteração.                      º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³ Logico                                                     º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³ 																				º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function M934OK()

	Local nQtd65 			:= 0
	Local nContExtra 	:= 0
	Local nQtd70  		:= 0
	Local nQtdDep 		:= 0
	Local nQtdIdade 	:= 0
	Local nDepPla			:= 0
	Local nContDir 		:= 0
	Local i

	SB1->(dbsetorder(1))
	
	If ZAM->ZAM_STATUS != "0" // Só verifica o Tudo OK e o contrato estiver pré-ativo  
		Return .T. 
	EndIF
	
	If !U_MORA934L()//Serve para validar o preenchimento do campo de forma de pagamento da 1 parcela
		Return (.F.)
	EndIf
	
	If !Empty(M->ZAM_CLIFAT)
		If M->ZAM_CLIFAT == '040000' .and. Empty(M->ZAM_MATR)
			ApMsgInfo('A matrícula da empresa para o contrato não pode ficar em branco')
			Return(.F.)
		Endif
	Endif
	If Empty(M->ZAM_CLIFAT) .and. !Empty(M->ZAM_MATR)
		ApMsgInfo('Não pode existir matrícula para um contrato que não possua empresa associada a ele!')
		Return(.F.)
	Endif
	If !Empty(M->ZAM_CLIFAT) .and. !(M->ZAM_FPAG $ '4,9,0') .AND. M->ZAM_CODPRO <> '912189'
		ApMsgInfo('A forma de pagamento do contrato associada a empresa está incorreta!')
		Return(.F.)
	Endif
	If Empty(M->ZAM_CLIFAT) .and. M->ZAM_FPAG == '4'
		ApMsgInfo('A forma de pagamento do contrato só pode ser utilizada quando se trata de empresa associada a ele!')
		Return(.F.)
	Endif
	
	If M->Zam_FPag == '0'
		If Empty(M->Zam_Clifat)
			MsgInfo("<font color='red'>Na forma de pagamento de campanha é necessário o preenchimento da empresa.</font>")
			Return(.F.)	
		Endif
		
		Zfc->(dbSetOrder(4))
		Zfc->(dbSeek(xFilial("ZFC") + M->Zam_CliFat ))
		
		If Zfc->(!(Found()))
			MsgInfo("<font color='red'>Empresa não foi encontrada no cadastro de campanhas</font>")
			Return(.F.)
		EndIf
	Endif
	
	// if type('aCols') != "U"
	// 	oContrt := GvContratoPlano():New()
	// 	aPETRet := oContrt:ValidaPET( aCols, M->ZAM_CONTRT)
		
	// 	If !aPETRet[1]
	// 		MsgStop(aPETRet[2], "Validação")
	// 		return .F.
	// 	Endif
	// EndIf

	SB1->(dbseek(xFilial('SB1')+M->ZAM_CODPRO))
	
	Do Case

		case (SB1->B1_GRUPO $ '1099')
	
			If Empty( M->ZAM_DTPRIM )
				MsgInfo("É necessário preencher o campo de vencimento <strong>Dt Prim Venc</strong>", "Validação Prever")
				return .F.
			EndIf

			//Nao permite incluir titular com mais de 70 anos e que nao tem produto principal do cemiterio
			/*If u_anosidade(M->ZAM_DTNAS,ddatabase) > 70 .and. M->ZAM_CEMIT == '2'
				ApMsgInfo('O titular não pode ter idade superior a 70 anos!')
				Return .F.
			endif*/
			
			//Se nao for Carne CD, CC ou boleto nao ira permitir a inclusao
			/* FOI INSERIDA A OPÇÃO DE CARNÊ */
			If !(M->ZAM_FPAG $ '8,4,1')
				ApMsgInfo('Forma de Pagamento invalido para este Plano!')
				Return .F.
			endif 
			
			//Percorre para verificar a quantidade de dependentes maiores de 65 anos
			/*for i := 1 to Len(aCols)
				if !aCols[i][len(aHeader)+1]
					Do Case
						
						Case (alltrim(gdFieldGet("ZAN_PARENT", i)) $ 'FILHO')
						
							//Nao permite incluir dependente filho com idado maior que 30 caso nao possua produto cemiterio
							If u_anosidade(gdFieldGet("ZAN_DTNASC", i),ddatabase) > 40 .and. M->ZAM_CEMIT == '2'
								ApMsgInfo('Dependente filho não pode ter idade superior a 40 anos!')
								Return .F.
							endif
							
						Case !(alltrim(gdFieldGet("ZAN_PARENT", i)) $ SZH->ZH_DEPDIRE)
							nContExtra++
						OtherWise
							if u_anosidade(gdFieldGet("ZAN_DTNASC", i),ddatabase) > 70 .and. alltrim(gdFieldGet("ZAN_PARENT", i)) <> 'CONJ'
								nQtd65++
							endif
					EndCase
					
					nQtdDep++
				endif
				
			next i*/
			
			if nQtdDep > 13
				Msginfo('Só é permitido incluir até 10 dependentes para este contrato')
				Return AlwaysFalse()
			endif
			
			//Se tiver mais que dois dependentes extra, cobrar 20R$.
			if nContExtra > 3
			alert("Só é permitido até três dependentes extra")
				Return AlwaysFalse()
			elseIf nContExtra > 1 
				if !Msgyesno('Existe 2 ou mais dependentes Extras, será gerado uma taxa por dependente extra no valor de R$ 20,00.')
					Return AlwaysFalse()
				endif
			endif
			
			//Caso tiver mais de dois dependentes nao permite nova inclusao
			if nQtd65 > 3
				Alert('Só é possível incluir 3 dependentes maiores de 75 anos')
				Return .F.
			endif

		OtherWise

			If IsNumeric(Left(Alltrim(M->Zam_contrt),1))
				//Busca as regras contratuais do contrato
				ZFD->(dbsetorder(1))
				if ZFD->(dbseek(xFilial('ZFD') + alltrim(M->ZAM_REGCON)))

					// Valida a idade do titular
					If u_anosidade(M->ZAM_DTNAS,M->ZAM_EMISSA) < 18
						MsgInfo('Títular menor de 18 anos, processo cancelado!')
						Return .F.
					elseIf u_anosidade(M->ZAM_DTNAS,M->ZAM_EMISSA) > ZFD->ZFD_IDLITI .and. M->ZAM_STATUS == "0"
						MsgInfo('Títular com idade superior a ' + cValtoChar(ZFD->ZFD_IDLITI) + ' anos, processo cancelado!')
						Return .F.
					endif

					for i:= 1 to len(aCols) //Percorre o acols de dependentes
				
						if !aCols[i][len(aHeader)+1] //Verifica se o dependente esta excluído
						
							//Verifica a quantidade de dependentes extras
							if (alltrim(gdFieldGet("ZAN_PARENT",i)) $ alltrim(Posicione("SZH",2,xfilial("SZH") + '               ' + SB1->B1_COD,"ZH_DEPDIRE")))
								//Verifica a quantidade de dependentes acima de 75 anos
								if u_anosidade(gdFieldGet("ZAN_DTNASC", i),M->ZAM_EMISSA) > ZFD->ZFD_IDLITI
									nQtdIdade++
								EndIf

								nContDir++
								
							else
								if u_anosidade(gdFieldGet("ZAN_DTNASC", i),M->ZAM_EMISSA) > ZFD->ZFD_IDLITI
									nQtdIdade++
								EndIf

								nContExtra++
							endif
													
							nDepPla++
							
						endif
						
					next i
					
					//Verifica se escedeu a quantidade de limite de idade
					if nQtdIdade > ZFD->ZFD_QTDPID
					
						MsgInfo('Para este plano só é permitido incluir até ' + cValtoChar(ZFD->ZFD_QTDPID) + ' dependentes acima de ' + cvaltochar(ZFD->ZFD_IDLITI) + ' anos!')
						Return AlwaysFalse()
					
					endif

					//Verifica se excedeu a quantidade limite de dependente direto
					if nContDir > (ZFD->ZFD_QTDDDI + (ZFD->ZFD_QTDDEX - ZFD->ZFD_QTEXLI))
					
						MsgInfo('Para este plano só é permitido incluir até ' + cValtoChar(ZFD->ZFD_QTDDDI + (ZFD->ZFD_QTDDEX - ZFD->ZFD_QTEXLI))) 
						Return AlwaysFalse()
					
					endif
										
					//Verifica se excedeu a quantidade limite de dependente livres
					if nContExtra > ZFD->ZFD_QTDDEX
					
						MsgInfo('Para este plano só é permitido incluir até ' + cValtoChar(ZFD->ZFD_QTDDEX) + ' dependentes livres!')
						Return AlwaysFalse()
					
					endif

				endif
			endif
	endCase
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica na base de caico se a cidade for diferente de currais novos³
	//³e tiver informado a reducao de taxa. nao permite a inclusao         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If cEmpant == '08'

   	If alltrim(M->ZAM_MUNICI) <> 'CURRAIS NOVOS' .and. M->ZAM_REDTAX > 0

   		MsgInfo('Só é possível conceder redução de taxa para a cidade de CURRAIS NOVOS.')
   		Return .F.

   	EndIf

   EndIf
   
   	//Recalcula o contrato com os campos atualizados
	If M->ZAM_STATUS == '0' 
		U_MORF795() //U_MORA934P()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³verifica se é alteracao do contrato. Verifica se houve alteracao            ³
	//³na data de nascimento do titular que pode haver mudanca no valor do contrato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lALTERA

   	Processa( {|| U_MORF801() } )

   EndIf

   //Verifica se e plano sempre mais e bloqueia para natal
   If alltrim(M->ZAM_MUNICI) == 'NATAL' .and. M->ZAM_CODPRO == '911450'
		MsgInfo("Venda do plano não permitido para Natal!")
		Return .F.
   EndIf

Return AlwaysTrue()


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ ChkTot   º Autor ³ Guilherme          º Data ³ 30/10/06    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Checa se existe parcelas abertas a partir da data de       º±±
//±±º            ³ inclusao do dependente. Se houver alguma parcela verifica  º±±
//±±º            ³ se a taxa altera o valor total do contrato (.T.)           º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³ Logico                                                     º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³ 																				º±±
//±±º            ³ 																				º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function ChkTot()

	lResult := .F.
	aValDep := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query que retornara' se o contrato possue alguma parcela gerada com taxa do dependente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT E1_CONTRT, E1_VALOR, ZAM_VLTOT FROM " + RetSqlName('SE1') + " SE1 "
	cQuery += " INNER JOIN " + RetSqlName('ZAM') + " ZAM ON ZAM_CONTRT = SE1.E1_CONTRT "
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' AND ZAM.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_VENCTO >= '"+ DTOS(dDataBase) + "' AND SE1.E1_SALDO >= 0 "
	cQuery += " AND ZAM.ZAM_FILIAL = '" + xFilial("ZAM") + "' "
	cQuery += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQuery += " AND SE1.E1_CONTRT = '" + M->ZAM_CONTRT + "' "

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "ChkTot"

	If AllTrim(M->ZAM_VLTOT) <> AllTrim(ChkTot->ZAM_VLTOT) .And. !Empty(ChkTot->E1_CONTRT)
		lResult := .T.
	EndIf

	dbCloseArea('ChkTot')

Return lResult

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Programa   ³fLstBene ³ Autor   ³ Leandro Ayala          ³ Data ³27/02/2009³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descricao  ³ Funcao que preenche o listbox que exibe os beneficios do     ³±±
//±±³           ³ credito.                                                     ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function fLstBene(cContrato)

	aLstBen := {}
	oLstBen:SetArray(aLstBen)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³seta o credito selecionado para utilizacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SG1->(dbsetorder(1))
	ZAM->(dbsetorder(1))
 	If ZAM->(dbseek(xfilial("ZAM")+cContrato))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³seleciona os beneficios desse credito³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      cQuery := "select G1_COMP,G1_QUANT from "+RetSqlName("SG1")+" SG1 "
      cQuery += "where sg1.d_e_l_e_t_ <> '*' and sg1.g1_cod = '" + CodBene + "' and sg1.g1_filial = '"+xFilial("SG1")+"' "
      
      //Lista os beneficios do unico
      If !empty(ZAM->ZAM_CODPUN)
	      cQuery += " Union All "
	      cQuery += "select G1_COMP,G1_QUANT from "+RetSqlName("SG1")+" SG1 "
	      cQuery += "where sg1.d_e_l_e_t_ <> '*' and sg1.g1_cod = '"+ZAM->ZAM_CODPUN+"' and sg1.g1_filial = '"+xFilial("SG1")+"' "
	     
      EndIf

      TcQuery cQuery New Alias "QRYLST"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³nivel um da estrutura³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      While QRYLST->(!eof())

      	aadd(alstBen,{alltrim(QRYLST->G1_COMP),Posicione("SB1",1,xFilial("SB1")+QRYLST->G1_COMP,"B1_DESC"),Transform(QRYLST->G1_QUANT,"@E 999.99")})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³verifica se os produtos da estrutura um tambem possuem estrutura³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    cQuery := "select * from "+RetSqlName("SG1")+" SG1 "
      	cQuery += "where sg1.d_e_l_e_t_ <> '*' and sg1.g1_cod = '"+QRYLST->G1_COMP+"' and sg1.g1_filial = '"+xFilial("SG1")+"' "
      	cQuery += "order by sg1.g1_comp"

      	TcQuery cQuery New Alias "QRYSET"

      	While QRYSET->(!eof())

   			aadd(alstBen,{"   "+alltrim(QRYSET->G1_COMP),Posicione("SB1",1,xFilial("SB1")+QRYSET->G1_COMP,"B1_DESC"),Transform(QRYSET->G1_QUANT,"@E 999.99")})

      		QRYSET->(dbskip())
      	EndDo

	      	QRYSET->(dbclosearea())

 			QRYLST->(dbskip())
 		EndDo

		If len(aLstBen) == 0
			aAdd(aLstBen,{'','',''})
		EndIf

		oLstBen:bLine := {|| {;
				aLstBen[oLstBen:nAT,01],;
				aLstBen[oLstBen:nAT,02],;
				aLstBen[oLstBen:nAT,03]}}
   Else
   	ApMsgInfo("Contrato não localizado!")
   Endif

	QRYLST->(dbclosearea())

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934H º Autor ³ Leandro Ayala      º Data ³ 26/11/2010  º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Modifica a informacao no acols dos dependentes da data de  º±±
//±±º            ³inclusao se a data de emissao do contrato for modificada.   º±±
//±±º            ³ Executada na validacao do campo ZAM_EMISSA                 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934H()

   Local nPosDtInc := Ascan(aHeader,{|x|Alltrim(x[2]) == "ZAN_DTINC"})
   Local i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³percorre o acols dos dependentes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i:= 1 to len(aCols)

		acols[i][nPosDtInc] := M->ZAM_EMISSA

	Next

	GetDRefresh()

Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934I º Autor ³ Sergio Barbalho    º Data ³ 16/05/11    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Chama funcao padrao do protheus e mostra pagamentos antigosº±±
//±±º            ³ de migracao do mabsic.                                     º±±
//±±º            ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934I(cCliente_)

	Local cStrCli

	cStrCli := '90,91,92,93,94,95,96,97,98,99'
   aInfoCp := GetRmtInfo()

   If 'Windows' $ aInfoCp[2]

		If LEFT(cCliente_,2) $ cStrCli
			ShellExecute("open","http://192.168.0.251:81/Busca_Contrato/ConsultaContrato_action.php?input_contrato="+alltrim(STR(Val(cCliente_) - 900000)) +"&input_submit=Pesquisar","","", 1 )
		Else
			MsgInfo("Este contrato não foi migrado do MABSIC!")
		Endif


   Else

		WaitRun("http://192.168.0.251:81/Busca_Contrato/ConsultaContrato_action.php?input_contrato="+alltrim(STR(Val(cCliente_) - 900000)) +"&input_submit=Pesquisar",3)

   EndIf

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934J º Autor ³ Leandro Ayala      º Data ³ 16/05/11    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Funcao executada no gatilho do campo ZAM_EMISSA. Valida a  º±±
//±±º            ³ data de emissao digitada de acordo com o dia da semana,    º±±
//±±º            ³ permitindo ou nao a data informada de acordo com regras.   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±º 04/02/2016 ³ Marcos Aurelio ³ Função modificada para validar a data de  º±± 
//±±º            ³ emissão de forma genérica, não está mais amarrada          º±±
//±±º            ³ a ZAM_EMISSA.  											  º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934J(dDataEmis)

   Local lRet := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³se o dia da semana for segunda so permite inclusao de emissao³
	//³com data-4  (sexta, + 1 dia de margem).                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If DOW(dDataBase) == 2

   	If dDataEmis < (dDataBase - 10) .or. dDataEmis > ddatabase
   		MsgInfo("A data digitada não é valida. Contratos cadastrados na segunda-feira devem tem emissão da sexta-feira.")
         lRet := .F.
      EndIf

   EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³se for entre terca e sexta a emissao deve ser database-4 (margem para feriados)         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If DOW(dDataBase) <> 2

		If dDataEmis < (dDataBase - 10) .or. dDataEmis > ddatabase
			MsgInfo("A data digitada não é valida. Contratos cadastrados no periodo de terça a sexta devem ter emissão do dia anterior.")
         lRet := .F.
		EndIf

	EndIf

Return lRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934K º Autor ³ Leandro Ayala      º Data ³ 24/11/11    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Funcao executada na propriedade modo de edicao do campo    º±±
//±±º            ³ ZAM_REDTAX verificando se o campo pode ser liberado ou nao.º±±
//±±º            ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934K()

	Local lRet := .F.

	If Alltrim(M->ZAM_MUNICI) == 'CURRAIS NOVOS' .and. M->ZAM_STATUS == '0' .and. cEmpAnt == '08'
		lRet := .T.
	EndIf

Return lRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºFuncao      ³ MORA934L º Autor ³ Leandro Ayala      º Data ³ 24/11/11    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao   ³ Validacao no campo ZAM_FPGADE. Dependendo da opcaoda forma º±±
//±±º            ³ de pagamento, existe validacao para a opcao da fpg adesao. º±±
//±±º            ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºRetorno     ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºParametros  ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±º            ³                                                            º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function MORA934L()

	If !(Alltrim(M->ZAM_CODPRO) $ '009922,009923,009924') .and. ALTERA .and. M->ZAM_STATUS <> '0'
		Return .T.
	EndIf
	
  	Do Case

		//ÚÄÄÄÄÄ¿
		//³carne³
		//ÀÄÄÄÄÄÙ
		Case M->ZAM_FPAG == '1'

	  		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³A adesao deve ser gerada, por isso a opcao nenhum nao pode ser selecionada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !( ZAM->ZAM_CODVEN $ SuperGetMv("MV_REPRVEN",.F.,"901064") )
				If M->ZAM_FPGADE == '4'
					MsgInfo('Dinheiro: A forma de pagamento para a 1ª Parcela deve ser selecionada.')
					Return .F.
				EndIf
			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³debito automatico³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		Case M->ZAM_FPAG == '2'

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao gera adesao. A opcao fpg adesao deve ser '4' - nenhum³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	  	If M->ZAM_FPGADE <> '4'
	 	  		MsgInfo('Débito automático: A primeira parcela é pago pela empresa. A opção da adesão deve ser: 4 - Nenhum')
	      		Return .F.
	      	EndIf

 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³cartao anuidade  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		Case M->ZAM_FPAG == '3'

  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao gera adesao. A opcao fpg adesao deve ser '4' - nenhum³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->ZAM_FPGADE <> '4'
	      	MsgInfo('Cartão anuidade: A 1ªParcela é baixada automaticamente. A opção da adesão deve ser: 4 - Nenhum')
	      	Return .F.
	   	EndIf

	  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³desconto folha   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		Case M->ZAM_FPAG == '4'

  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao gera adesao. A opcao fpg adesao deve ser '4' - nenhum³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->ZAM_FPGADE <> '4'
		      	MsgInfo('Desconto folha: Não gera adesão. A opção da adesão deve ser: 4 - Nenhum')
		      	Return .F.
		   	EndIf

			If M->ZAM_CPRCAR == 'S' .or. M->ZAM_REDCAR > 0
				If !ApMsgYesNo("Os contratos de Desconto/Empresas calculam automaticamente a Carência " + CRLF +;
				  			  "deseja realmente aplicar redução ou compra de carência?")
				  	Return .F.		  
				EndIf  			  
			EndIf

	   		/* A carência foi definida em 60 dias fixo para as empresas
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³se for gov do estado, a carencia deve ser de 50%  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		   If M->ZAM_CLIFAT $ GETMV("MS_EMPGOVE")

	 		   If M->ZAM_REDCAR <> 50
	 		   	MsgInfo('Desconto folha: O contrato deve ter carência de 50%.')
		      	Return .F.
	 		   EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³se for empresa, a carencia deve ser 50% ou 100%, de acordo com as regras.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		   Else

 		   	If M->ZAM_REDCAR <> 50 .and. M->ZAM_REDCAR <> 100
	 		   	MsgInfo('Desconto folha: O contrato deve ter carência de 50% ou 100%, de acordo com as regras.')
		      	Return .F.
	 		   EndIf

 		   EndIf
 		   */
 		//ÚÄÄÄÄÄÄÄÄÄÄ¿
		//³migracao  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÙ
 		Case M->ZAM_FPAG == '5'

  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao gera adesao. A opcao fpg adesao deve ser '4' - nenhum³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			/*If M->ZAM_FPGADE <> '4'
		      	MsgInfo('Migração: Não gera adesão. A opção da adesão deve ser: 4 - Nenhum')
		      	Return .F.
	      	EndIf*/

		
	   		/*//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³nao pode haver carencia (reducao de 100%)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		   If M->ZAM_REDCAR <> 100
 		   	MsgInfo('Migração: O contrato não pode haver carência.')
	      	Return .F.
 		   EndIf
 		   */
 		//ÚÄÄÄÄÄÄÄÄÄÄ¿
		//³renovacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÙ
 		Case M->ZAM_FPAG == '6'

  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao gera adesao. A opcao fpg adesao deve ser '4' - nenhum³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->ZAM_FPGADE <> '4'
				MsgInfo('Migração: Não gera adesão. A opção da adesão deve ser: 4 - Nenhum')
				Return .F.
			EndIf
			
		 Case M->ZAM_FPAG == '9'

  			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nao gera adesao. A opcao fpg adesao deve ser '4' - nenhum³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->ZAM_FPGADE == '4' .and. Empty(M->ZAM_CLIFAT)  
				MsgInfo('Convenio/Carne: Deve ser preenchida a empresa de Convenio')
				Return .F.
			EndIf	
			
			If M->ZAM_CPRCAR == 'S' .or. M->ZAM_REDCAR > 0
				If !ApMsgYesNo("Os contratos de Desconto/Empresas calculam automaticamente a Carência " + CRLF +;
				  			  "deseja realmente aplicar redução ou compra de carência?")
				  	Return .F.		  
				EndIf  			  
			EndIf
		 
		 Case M->ZAM_FPAG == '0'			
			
			If M->Zam_FpgAde == '4' .and. Empty(M->Zam_Clifat)
				MsgInfo("<font color='red'>Campanha: Deve ser preenchida a empresa da campanha</font>")
				Return .F.				
			EndIf
			
			/*//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³nao pode haver carencia (reducao de 100%)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 		   If M->ZAM_REDCAR <> 50
 		   	MsgInfo('Migração: A carencia do contrato deve ser de 50%')
	      	Return .F.
 		   EndIf
 		   */
   EndCase 

Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Programa   ³MORA934M ³ Autores ³ Leandro Ayala          ³ Data ³04/06/2013³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descricao  ³ Funcao que valida, so permitindo o preenchimento do campos   ³±±
//±±³           ³dos dependentes se a aba daods plano estiver preenchidos.     ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
User Function MORA934M(lCalcTaxa)
	DEFAULT lCalcTaxa := .F.
	Local lRet := .T.

	If Empty(M->ZAM_CODPRO)

		MsgInfo("Os dados do plano devem ser preenchidos antes de informar os dependentes do contrato")
		lRet := .F.

	EndIf

	IF lCalcTaxa
		aReterno := u_MORF792("D",M->ZAM_CODPRO,M->ZAN_PARENT, aCols[len(aCols)][4], M->ZAM_CONTRT)                     

		aCols[len(aCols)][5]  := M->ZAN_PARENT
		aCols[len(aCols)][10] := aReterno[1]
		aCols[len(aCols)][11] := aReterno[2]
		aCols[len(aCols)][12] := aReterno[3]
		aCols[len(aCols)][15] := aReterno[4]

		GetDRefresh() 
		//Atualiza as taxas dos dependentes 
		U_MORF795()
	ENDIF
	
Return lRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
//±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function C(nTam)

	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf

Return Int(nTam)


/*/{Protheus.doc} MasCart
(long_description)
Rotina de substituição das opções das telas do plano
@author paulosouza
@since 05/01/2015
@version 1.0
@param cNum, character, (Descrição do parâmetro)
@param nOpc, numérico, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
User Function MasCart(cNum,nOpc)

//Opção 1 = Numero do cartão
//Opção 2 = Cod segurança
//Opção 3 = Vencimento
local cRet := ""

do Case
	case nOpc == 1
		cRet := LEFT(cNum,4)+ "************"+ RIGHT(ALLTRIM(cNum),4)
	case nOpc == 2
		cRet := "****"
	case nOpc == 3
		cRet := "***"
EndCase

Return cRet

User Function RegContr(cContrt)
	local aRet			:=	{}
	local aParamBox	:=	{}
	local aDados		:=	{}

	If Empty(cContrt)
		aAdd(aParamBox,{1,"Contrato",Space(8),"","","","",0,.F.}) // Tipo caractere
		If !ParamBox(aParamBox,".....",@aRet)
			Return
		EndIf
		cContrt := alltrim(mv_Par01)
		aRet 		:= {}
		aParamBox 	:= {}
	EndIf

	If Empty(ZAM->ZAM_REGCON)
		MsgInfo("Contrato sem regra difinida")
		Return
	EndIf

	ZFD->(dbsetorder(1))
	If !ZFD->(dbseek(xFilial("ZFD")+ alltrim(ZAM->ZAM_REGCON)))
		MsgInfo("Regra contratual não encontrada - RegContr (MORA934)")
		return
	EndIf

	AADD(aDados,IIF(ZFD->ZFD_STATUS == "A","ATIVO","DESATIVADO")) //Status da regra contratual || aDados[1]
	AADD(aDados,IIF(ZFD->ZFD_OBTMEN == "S","SIM","NAO")) //Se muda mensalidade quando houver óbito || aDados[2]
	AADD(aDados,IIF(ZFD->ZFD_REFXET == "S","SIM","NAO")) //Se Reajusta Faixa etária || aDados[3]
	AADD(aDados,IIF(ZFD->ZFD_OBTVIG == "S","SIM","NAO")) //Se Reajusta vigencia quando houver óbito || aDados[4]
	AADD(aDados,IIF(ZFD->ZFD_TROCPL == "S","SIM","NAO")) //Se Pode trocar de plano || aDados[5]


	aAdd(aParamBox,{9,"Regra Contratual :: "+ cValToChar(ZAM->ZAM_REGCON),150,7,.T.})
	aAdd(aParamBox,{9,"Descrição da Regra :: "+ cValToChar(ZFD->ZFD_DESCRI),150,7,.T.})
	aAdd(aParamBox,{9,"Situação da Regra :: "+ cValToChar(aDados[1]),150,7,.T.})
	aAdd(aParamBox,{9,"Óbito é retirado da mensalidade ? "+ cValToChar(aDados[2]),150,7,.T.})
	aAdd(aParamBox,{9,"Ao Mudar Faixa Etària muda Valor ? "+ cValToChar(aDados[3]),150,7,.T.})
	aAdd(aParamBox,{9,"Tempo de Vigencia :: "+ cValToChar(ZFD->ZFD_VIGENC),150,7,.T.})
	aAdd(aParamBox,{9,"Se Houver Óbito Reajusta Vigencia ? "+ cValToChar(aDados[4]),150,7,.T.})
	aAdd(aParamBox,{9,"Indice de Correção :: "+ cValToChar(ZFD->ZFD_INDCOR),150,7,.T.})
	aAdd(aParamBox,{9,"QTD. Maxima de Dependente Direto :: "+ cValToChar(ZFD->ZFD_QTDDDI),150,7,.T.})
	aAdd(aParamBox,{9,"QTD. Maxima de Dependente Extra :: "+ cValToChar(ZFD->ZFD_QTDDEX),150,7,.T.})
	aAdd(aParamBox,{9,"Idade Limite :: "+ cValToChar(ZFD->ZFD_IDLITI),150,7,.T.})
	aAdd(aParamBox,{9,"Cliente Pode Mudar Plano ? "+ cValToChar(aDados[5]),150,7,.T.})

	If !ParamBox(aParamBox,".....",@aRet)
		Return
	EndIf

Return

/*/{Protheus.doc} VerReat
Verifica se o contrato foi reativado
@author leandroayala
@since 13/02/2015
@version 1.0
@return T ou F
/*/
Static Function VerReat()

	Local lReat := .F.

	cQuery := "Select count(*) QTD from "+ RetSqlName("SZ8") +" Where z8_grupo = 'REAT' and d_e_l_e_t_ = ' ' and z8_contrat = '"+ZAM->ZAM_CONTRT+"' "

	TcQuery cQuery New Alias "QRYRET"

	If QRYRET->QTD > 0
		lReat := .T.
	EndIf

	QRYRET->(dbCloseArea())

Return lReat

/*/{Protheus.doc} InContrt
(long_description) Função criada para que gere o numero automatico quando a venda for feita pelo call center
@author leonardofreitas
@since 10/07/2015
@version 1.0
@param nCampo, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function InContrt(nCampo)
	Local aUserInf := pswRet(1) //Array contendo os dados dos usuarios logados no sistema
	Local cConteudo := ""
	Local RegContrt := '0000000001'
	
	//Verifico se o usuario logado pertence aos vendedores do call center
	if aUserInf[1][1] $ supergetmv('MS_USERCAL',.F.,'') .or. aUserInf[1][1] $ supergetmv('MS_USERATE',.F.,'') .or. (aScan(UsrRetGrp(RetCodUsr()),{|x| x $ supergetmv('MS_GRUPCAL',.F.,'') }) > 0)

		SA3->(dbsetorder(7))
		SA3->(dbseek(xFilial('SA3')+aUserInf[1][1]))
		
		Do Case
			//Se o campo for ZAM_CONTRT
			Case (nCampo == 1)
				cConteudo := GetSX8Num('ZAM','ZAM_CONTRT')
				ConfirmSX8()
			//Se o campo for ZAM_VEND
			Case (nCampo == 2)
				cConteudo := SA3->A3_COD
			//Se o campo for ZAM_DSVEND
			Case (nCampo == 3)
				cConteudo := SA3->A3_NOME
			//Se o campo for ZAM_SUPER
			Case (nCampo == 4)		
				cConteudo := SA3->A3_SUPER
			//Se o campo for ZAM_GEREN
			Case (nCampo == 5)
				cConteudo := SA3->A3_GEREN
			Case (nCampo == 6)
				//Usuarios do canal Call Center
				if aUserInf[1][1] $ supergetmv('MS_USERCAL',.F.,'') .or. (aScan(UsrRetGrp(RetCodUsr()),{|x| x $ supergetmv('MS_GRUPCAL',.F.,'') }) > 0)
					cConteudo := '100008'
				//usuarios do canal Atendimento/Balcao	
				ElseIf aUserInf[1][1] $ supergetmv('MS_USERATE',.F.,'')
					cConteudo := '100009'
				EndIf
			Case (nCampo == 7)
				cConteudo := RegContrt
			Case (nCampo == 8)
				ZFD->(dbsetorder(1))
	  			If ZFD->(dbseek(xfilial("ZFD")+RegContrt))
					cConteudo := dDataBase + (ZFD->ZFD_VIGENC * 30)
				endif
		EndCase
	endif
	
return cConteudo

/*/{Protheus.doc} AltVend
(long_description) Função para bloquear campos referente a venda do call center
@author leonardofreitas
@since 10/07/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function AltVend()
	
	Local lRet := .F.
	if M->ZAM_STATUS == "0"
		lRet := .T.
	EndIf
/*	Do Case
		Case (RetCodUsr() $ supergetmv('MS_USERCAL',.F.,'')) .and. RetCodUsr() <> '000998'
			lRet := .F.
		Case !(M->ZAM_STATUS == "0"  .or. day(ddatabase)<=30)
			lRet := .F.
	EndCase*/
return lRet

/*/{Protheus.doc} CONDESCO
(long_description) Tela de descontos do contrato
@type function
@author leonardofreitas
@since 10/12/2015
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/user function CONDESCO()
	Local lRet := .T.
	Local cQuery := ""
	
	Private _oDlg1
	Private oLstBen 
	Private aLstBen 	:= {}
	Private nContObt	:=	0
	
	SB1->(dbsetorder(1))
	//Verifica se pertence ao plano prever
	SB1->(dbseek(xfilial('SB1')+ZAM->ZAM_CODPRO))
	
	if !(SB1->B1_GRUPO $ '1099')
		MsgInfo('Rotina disponivel apenas para o Plano Prever!')
		return
	endif
	
	ZZZ->(dbsetorder(2))
	
	//Busca os descontos para o contrato
	if ZZZ->(dbseek(xFilial('ZZZ')+ZAM->ZAM_CONTRT)) .and. ZAM->ZAM_STATUS == '1'
	
		DEFINE MSDIALOG _oDlg1 TITLE "Descontos do Contrato" FROM C(50),C(50) TO C(230),C(340) PIXEL		
	  
		@ C(000),C(000) ListBox oLstBen Fields ;
		HEADER "Código","Produto","Descrição","Desconto" Size C(147),C(050) Of _oDlg1 Pixel ColSizes 25,25,80,20   
		  
	 	while ( ZZZ->(!Eof()) .and. ZZZ->ZZZ_CONTRT == ZAM->ZAM_CONTRT)
	
			aadd(alstBen,{ZZZ->ZZZ_CODIGO,alltrim(ZZZ->ZZZ_CODPRO),alltrim(POSICIONE("ZZX", 1, xFilial('ZZX')+ZZZ->ZZZ_CODDES,"ZZX_DESCRI")),cValtoChar(ZZZ->ZZZ_DESCON)+"%"})
		
		 	ZZZ->(dbSkip())
	 	
	 	EndDo
	 	
	   	If len(aLstBen) == 0
			aAdd(aLstBen,{'','','','',''})
		EndIf
		
		oLstBen:SetArray(aLstBen)
		oLstBen:bLine := {|| {aLstBen[oLstBen:nAT,01], aLstBen[oLstBen:nAT,02], aLstBen[oLstBen:nAT,03], aLstBen[oLstBen:nAT,04]}}    
		
		@ C(051),C(000) Jpeg FILE "\imagens\bg_mora616.jpg" Size C(303),C(040)	PIXEL OF _oDlg1		
		@ C(061),C(95) BUTTON  "&Ok"  Size C(050),C(025) OF _oDlg1 PIXEL ACTION (_oDlg1:End())
			
		ACTIVATE MSDIALOG _oDlg1 CENTERED
	else
		MsgInfo('Não existe desconto para este contrato!')
	endif

return



/*/{Protheus.doc} MORA934N
Consulta de parcelas deletadas para o financeiro
@author paulosouza
@since 22/12/2015
@version 1
@type function
/*/
User Function MORA934N()
	Local cQuery	:=	""
	local cMsg		:=	""
	local aRet		:=	{}
	local aBox		:=	{}
	local cMsgWhil	:=	"Consultar novamente?"
	local l1Vez		:=	.T.
	
	Do While IIF(!l1Vez,ApMsgYesNo(cMsgWhil),.T.) 
	
		aAdd(aBox,{1,"Nosso Numero",Space(18),"","","","",0,.T.}) // Tipo caractere
		ParamBox(aBox,"Consulta ampla Nosso Numero...",@aRet)	
		
		If len(aRet) == 0
			Return
		EndIf
		
		cQuery	:=	" SELECT E1_FILIAL AS FILIAL, "
		cQuery	+=	" E1_CONTRT AS CONTRATO, "
		cQuery	+=	"    E1_CLIENTE AS CLIENTE, "
		cQuery	+=	" E1_PREFIXO AS PREFIXO, "
		cQuery	+=	"    E1_NUM  AS NUMERO, "
		cQuery	+=	"    E1_PARCELA AS PARCELA, "
		cQuery	+=	"    E1_TIPO AS TIPO, "
		cQuery	+=	"    E1_VALOR AS VALOR, "
		cQuery	+=	"    E1_VENCTO AS VENCIMENTO, "
		cQuery	+=	"    CASE WHEN D_E_L_E_T_ = '*' THEN 'DELETADO' ELSE 'NORMAL' END SITUACAO "
		cQuery	+=	"    FROM "+RetSqlName("SE1")+" WHERE E1_NUMBCO = '"+ MV_PAR01 +"' "
		
		TcQuery cQuery New Alias "QRY934N"
		Count To nReg
		
		If nReg == 0
			MsgInfo("Não Encontrado na Base de dados da empresa")
			Loop
		EndIf
		
		QRY934N->(dbGoTop())
		
		cMsg += "Filial" + SPACE(3) + "Contrt" + SPACE(3) + "Client" + SPACE(3) + "Prefix" + SPACE(3)+ "Num" + SPACE(3) + "Parc" + SPACE(3) + "Situacao" + Chr(10) + Chr(13)
		
		While QRY934N->(!Eof())
			cMsg += QRY934N->FILIAL + SPACE(3) + PADR(CONTRATO,9) + SPACE(3) + CLIENTE + SPACE(3) + PREFIXO + SPACE(3)+NUMERO + SPACE(3) + PARCELA + SPACE(3) + SITUACAO + Chr(10) + Chr(13)
					
			QRY934N->(DbSkip())
		EndDo
		
		QRY934N->(dbCloseArea())
		
		MsgInfo(cMsg)
		
		aRet  := {}
		aBox  := {}
		l1Vez := .F.
		cMsg  := ""	
	EndDo

Return

/*/{Protheus.doc} MORA934N
Chama a rotina DE contrato de plano so que com filtro para exibir somente MORADA PREVER
@author leandroayala
@since 24/12/2015
@version 1
@type function
/*/
User Function MORA934O()

	if !(cEmpAnt $ '01,05,07' ) 
		MsgInfo("Morada Prever esta habilitado apenas para a empresa Safra e Serpos")
		return
	EndIf
	
	U_MORA934("P")

Return


/*/{Protheus.doc} ADITUNI
Chama da tela do aditivo único  
@author marcossilva
@since 03/02/2016
@version 1
@type function
/*/
User Function ADITUNI(cContrt,cVend,lAtiva)
	/* Declaração de variáveis dos componentes */
	
	Local aItems			:= {'','1=Dinheiro','2=Cartao','3=Cheque','4=Nenhum'}
	local aTitColDep		:= {"Item","Tipo","Nome","Sexo","Data Nasc","Parentesco","Fim Carenc","Dias Carenc","Fim Carenc Aditivo","Dias Carenc Aditivo"}
	local aSizColDep		:= {15,40,80,40,30,30,30,20,30,20}
	local aTitColPac		:= {"Prefixo","Parcela","Vencimento","Valor"}
	local aSizColPac		:= {30,30,30,30}

	default cVend 		:= Space(06) //Se a variavel nao for passada o vendedor devera ser informado na tela
	default lAtiva 		:= .F.
	Private lrotAti		:= lAtiva
	Private cCodPun    	:= Space(6)
	Private cConUni    	:= Space(15)
	Private dEmisUn    	:= DDATABASE-IIF(DOW(DDATABASE)=2,3,1) // Variável inicializada de acordo com o IniciliazadoR padrão do ZAM_EMISSA //CtoD(" ")
	Private nVlUnic    	:= 0
	Private nVlPlan    	:= 0
	Private nVlTotUn		:= 0
	Private nVlTotPl		:= 0
	Private nQtdParc		:= 0 
	Private cDescUn			:= Space(30)
	Private cFpgUni			:= Space(01)
	Private cCodVeu			:= Space(06)
	Private cCodCou			:= Space(06)
	Private cOdSupu			:= Space(06)	

	Private lQtdDepDir	:= 0
	Private lQtdDepExt  := 0
	Private aLstDep	 		:= {}
	Private oLstDep
	Private aLstParc 		:= {}
	Private oLstParc
	Private oCampanha

	/* Declaração de Variaveis Private dos Objetos */
	SetPrvt("oFont1","oDlg1","oPnlPrinc","oPnlParc","oPnlResu","oSay1","oLblEmis","oLblResu","oLblCodPun","oLblCon","oLblFpgUni","oConUni","oEmisUn","oVlUnic","oVlPlan","oFpgUni")
	SetPrvt("oSayDescCon","oSayDescUn","oLblGrdDep","oBrw1","oTBtnConf","oTBtnCanc","oCodVeu","oCodCou","oOdSupu","oLblCodVeUn","oSayNomVen","oSayCoord","oSaySuper","oLblCoord","oLblSuper")

	
	/* seta o contrato */
	ZAM->(dbsetorder(1))
	ZAM->(dbseek(xfilial("ZAM")+cContrt))

	/* if verifca se o contrato esta ativo */
	If ZAM->ZAM_STATUS <> '1'
		MsgInfo("O Contrato não está ativo.")
		Return
	EndIf

	//Carrega o codigo do vendedor
	if !empty(cVend)
		cCodVeu := cVend
	endif

	/* Fontes da tela */
	oFont1     	:= TFont():New( "Arial",0,-14,,.T.,0,,700,.F.,.F.,,,,,, )
	oFont2     	:= TFont():New( "Arial",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )
	
	/* Definicao do Dialog*/
	oDlg1      	:= MSDialog():New( 197,250,800,1266,"ADITIVO",,,.F.,,,,,,.T.,,,.T. )

	/* Definicao dos Painéis */
	oPnlPrinc  	:= TPanel():New( 000,000,"",oDlg1,,.F.,.F.,,,500,300,.T.,.F. )
	oPnlParc   	:= TPanel():New( 180,012,"",oPnlPrinc,,.T.,.F.,CLR_BLACK,CLR_HGRAY,240,90,.T.,.T. )
	oPnlResu   	:= TPanel():New( 180,260,"",oPnlPrinc,,.T.,.F.,CLR_BLACK,CLR_HGRAY,240,90,.T.,.T. )

	/* Definicao dos componentes do Dialog / Painel Principal */

	/* Campos de entrada */
	oLblCon    	:= TSay():New( 008,012,{||"Contrato:"},oPnlPrinc,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,,)
 	oSayDescCon	:= TSay():New( 008,055,{||OemToAnsi(alltrim(ZAM->ZAM_CONTRT)+" - "+alltrim(ZAM->ZAM_NOMCLI)+" - EMISSÃO: "+DTOC(ZAM->ZAM_EMISSA))},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_BLACK,,)

	oLblEmis    := TSay():New( 020,012,{||"Emissão"},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,064,012)
	oEmisUn    	:= TGet():New( 020,050,{|u| If(PCount()>0,dEmisUn:=u,dEmisUn)},oPnlPrinc,060,008,'',{|| U_MORA934J(dEmisUn)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||  },.F.,.F.,"","dEmisUn",,)
	
	oLblCodPun 	:= TSay():New( 020,118,{||"Cód Aditivo"},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,012)
	oCodPun    	:= TGet():New( 020,182,{|u| If(PCount()>0,cCodPun:=u,cCodPun)},oPnlPrinc,060,008,'',{|| ExistCpo("SB1",,1) .and. NaoVazio() .and. VerAdi(cCodPun)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||  },.F.,.F.,"SB1UNI","cCodPun",,)
	oSayDescUn	:= TSay():New( 020,247,{|| Posicione("SB1", 1, xFilial("SB1") + cCodPun, "B1_DESC") },oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_BLACK,,)

	oLblFpgUni 	:= TSay():New( 020,350,{||"Pag.Adesão"},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,012)
	oFpgUni 	:= TComboBox():New(020,390,{|u|if(PCount()>0,cFpgUni:=u,cFpgUni)},aItems,50,10,oPnlPrinc,,{||GerParUn()},,,,.T.,,,,,,,,,'oFpgUni')

	oLblCodVeUn	:= TSay():New( 035,012,{||"Vendedor"},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,012)
	oCodVeu    	:= TGet():New( 035,050,{|u| If(PCount()>0,cCodVeu:=u,cCodVeu)},oPnlPrinc,060,008,'',{|| ExistCpo("SA3",,1) .and. NaoVazio()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"A3VEND","cCodVeu",,)
	oSayNomVen	:= TSay():New( 035,118,{|| Posicione("SA3", 1, xFilial("SA3") + cCodVeu, "A3_NREDUZ") },oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_BLACK,,)

	oLblCoord	:= TSay():New( 035,182,{||"Coordernador:"},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,012)
	oSayCoord	:= TSay():New( 035,233,{|| Posicione("SA3", 1, xFilial("SA3") + cCodVeu, "A3_SUPER") },oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_BLACK,,)

	oLblSuper	:= TSay():New( 035,260,{||"Supervisor:"},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,058,012)
	oSaySuper	:= TSay():New( 035,300,{|| Posicione("SA3", 1, xFilial("SA3") + cCodVeu, "A3_GEREN") },oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_BLACK,,)

	oSay1      	:= TSay():New( 035,350,{||"Proposta"},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,064,012)
	oConUni    	:= TGet():New( 035,390,{|u| If(PCount()>0,cConUni:=u,cConUni)},oPnlPrinc,040,008,'',{||},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cConUni",,)

	oTBtnConf := TButton():New(010,460, "Confirmar",oPnlPrinc,{|| AtivaUni() }, 40,20,,oFont1,.F.,.T.,.F.,,.F.,,,.F. )
	oTBtnConf:lProcessing := .F.
	oTBtnConf:SetCss("QPushButton{ background-color: #3399FF; color: white}")

	oTBtnCanc := TButton():New(035,460, "Cancelar",oPnlPrinc,{|| oDlg1:End()}, 40,20,,oFont1,.F.,.T.,.F.,,.F.,,,.F. )

	/* Definicao dos componentes do Dialog / Painel Resumo */
	oLblResu 	:= TSay():New( 008,100,{||"RESUMO"},oPnlResu,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_BLUE,,)
	oLblResu1	:= TSay():New( 025,012,{||"Parcela Plano :"},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,,)
	oVlPlan		:= TSay():New( 025,070,{|| Transform(ZAM->ZAM_VLTOT, "@E 999,999.99")},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,,)

	oLblResu3	:= TSay():New( 025,120,{||"Total Parcelas Plano :"},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,,)
	oLblResu4	:= TSay():New( 025,190,{|| Transform(nVlTotPl, "@E 999,999.99")},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,,)

	oLblResu5	:= TSay():New( 035,012,{||"Parcela Aditivo :"},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,,)
	oVlUnic		:= TSay():New( 035,070,{|| Transform(Posicione("SB1", 1, xFilial("SB1") + cCodPun, "B1_PRV1"), "@E 999,999.99")},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,,)

	oLblResu6	:= TSay():New( 035,120,{||"Total Parcelas Aditivo :"},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,,)
	oLblResu7	:= TSay():New( 035,190,{|| Transform(nVlTotUn, "@E 999,999.99")},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,,)

	oLblResu8	:= TSay():New( 055,012,{||"Total Parcelas:"},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,,)
	oLblResu9	:= TSay():New( 055,070,{|| Transform(ZAM->ZAM_VLTOT + val(strtran(oVlUnic:cCaption,',','.')), "@E 999,999.99")},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,,)

	oLblResu10	:= TSay():New( 055,120,{||"Total Geral Parcelas:"},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,,)
	oLblResu11	:= TSay():New( 055,190,{|| Transform(nVlTotPl + nVlTotUn, "@E 999,999.99")},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,,)

	oLblResu10	:= TSay():New( 065,120,{||"Qtd Parcelas Geradas:"},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,,)
	oLblResu11	:= TSay():New( 065,190,{|| Transform(nQtdParc, "@E 99999999")},oPnlResu,,oFont2,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,,)

	/* Exibe grid dos dependentes/Lista os dependentes do contrato */
	oLblGrdDep 	:= TSay():New( 055,200,{||"D E P E N D E N T E S"},oPnlPrinc,,oFont2,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,,)
	oLstDep	:= TWBrowse():New( C(055),C(010),C(380),C(070),,aTitColDep, aSizColDep, oPnlPrinc,,,,,,,,,,,,,,.T. )
  
	LstDepUn()

	/* Definicao dos componentes do Dialog / Painel Parcelas */
	oLblParc 	:= TSay():New( 002,090,{||"NOVAS PARCELAS"},oPnlParc,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_BLUE,,)
	oLstParc	:= TWBrowse():New( C(015),C(005),C(180),C(050),,aTitColPac,aSizColPac,oPnlParc,,,,,,,,,,,,,,.T. )
	GerParUn()

	oDlg1:Activate(,,,.T.)
	
Return


/*/{Protheus.doc} LstDepUn
Lista os dependentes com a carência do Único  
@author marcossilva
@since 04/02/2016
@version 1
@type function
/*/
Static Function LstDepUn()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis locais   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	local aTitleCols	:= {"Item","Tipo","Nome","Sexo","Data Nasc","Parentesco","Fim Carenc","Dias Carenc","Fim Carenc Único","Dias Carenc Único"}
//	local aSizeCols	:= {15,40,80,40,30,30,30,20,30,20}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carga inicial dos dependentes   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If val(strtran(oVlUnic:cCaption,',','.')) > 0
		GetDepUn()
	Else
		aAdd(aLstDep,{	space(2),;
						space(20),;
						space(40),;
						space(9),;
						"  /  /  ",;
						space(6),;
						space(6),;
						"  /  /  ",;
						space(6),;
						"  /  /  ",;
						space(6) })
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a grid    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	oLstDep	:= TWBrowse():New( C(040),C(010),C(380),C(070),,aTitleCols, aSizeCols, oPnlPrinc,,,,,,,,,,,,,,.T. )

	oLstDep:SetArray(aLstDep)

	oLstDep:bLine := {|| {;
								aLstDep[oLstDep:nAT,01],;
								aLstDep[oLstDep:nAT,02],;
								aLstDep[oLstDep:nAT,03],;
								aLstDep[oLstDep:nAT,04],;
								aLstDep[oLstDep:nAT,05],;
								aLstDep[oLstDep:nAT,06],;
								aLstDep[oLstDep:nAT,07],;
								alltrim(Transform(aLstDep[oLstDep:nAT,08],"@E 999")),;
								aLstDep[oLstDep:nAT,09],;
								alltrim(Transform(aLstDep[oLstDep:nAT,10],"@E 999")) }}

	oLstDep:nAt	:= 1
	
	oLstDep:Refresh()

Return

/*/{Protheus.doc} GetDepUn
Carrega os dependente para mostrar na tela do aditivo Único  
@author marcossilva
@since 04/02/2016
@version 1
@type function
/*/
/*/{Protheus.doc} GetDepUn
//TODO Descrição auto-gerada.
@author leonardofreitas
@since 28/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
/*/{Protheus.doc} GetDepUn
//TODO Descrição auto-gerada.
@author leonardofreitas
@since 28/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
/*/{Protheus.doc} GetDepUn
//TODO Descrição auto-gerada.
@author leonardofreitas
@since 28/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GetDepUn()

   aLstDep := {}

	/* Calculo da carência do Único - Titular */
	aCarTit := U_MORF792("T",ZAM->ZAM_CODPRO,"TITULA",ZAM->ZAM_DTNAS, ZAM->ZAM_CONTRT,'ADITUNI')		

	/* Alimenta o array de dependentes */
	aAdd(aLstDep,{	"00",;
					"Titular",;
					ZAM->ZAM_NOMCLI,;
					"",;
					DTOC(ZAM->ZAM_DTNAS),;
					"",;
					DTOC(ZAM->ZAM_CARFUN),;
					ZAM->ZAM_CARENC,;
					DAYSUM(dEmisUn,aCarTit[4]),;
					aCarTit[4]})


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³seleciona os dependentes do contrato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   ZAN->(dbsetorder(1))
   If ZAN->(dbseek(cseek:= xfilial("ZAN")+ZAM->ZAM_CONTRT))

   	While ZAN->(!eof()) .and. cseek == xfilial("ZAN")+ZAN->ZAN_CONTRT

		/* grava no array pra carregar a grid */
		If ZAN->ZAN_STATUS == 'A'
			
			aAreaZAN :=	ZAN->(GetArea())
			/* Calculo da carência do Único - Dependentes */
			aCarDep := U_MORF792("D",ZAM->ZAM_CODPRO,ZAN->ZAN_PARENT,ZAN->ZAN_DTNASC, ZAM->ZAM_CONTRT,'ADITUNI')		
			RestArea(aAreaZAN)

			/* Alimenta o array de dependentes */
			aAdd(aLstDep,{	ZAN->ZAN_ITEM,;
							"Dependente",;
							ZAN->ZAN_NOME,;
							iif(ZAN->ZAN_SEXO=="2","Masculino","Feminino"),;
							DTOC(ZAN->ZAN_DTNASC),;
							ZAN->ZAN_PARENT,;
							DTOC(ZAN->ZAN_DTCARE),;
							iif(cCodPun == "940022",0,ZAN->ZAN_CARENC),;
							iif(cCodPun == "940022",ddatabase,DAYSUM(dEmisUn,aCarDep[4])),; //Se for o aditivo tanatopraxia, não há carencia, pois é aditivo para atendimento de obito
							aCarDep[4]})


		Endif

   		ZAN->(dbskip())
   	EndDo

   EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao exista carrega dados em branco.   ³
	//³ Evita array out of bound                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If len(aLstDep) == 0

		aAdd(aLstDep,{	space(2),;
						space(20),;
						space(40),;
						space(9),;
						dtoc(ddatabase),;
						space(6),;
						space(6),;
						dtoc(ddatabase),;
						space(6),;
						dtoc(ddatabase),;
						space(6) })

	EndIf

Return
/*/{Protheus.doc} GerParUn
Gera as parcelas do aditivo Único  
@author marcossilva
@since 10/02/2016
@version 1
@type function
/*/
Static Function GerParUn()
	nItem		:= 0
	nVlTotUn	:= 0
	nVlTotPl	:= 0
	nQtdParc	:= 0 

	aLstParc 	:= {}

	SE1->(Dbordernickname('SE1007'))// FILIAL + NUMERO do CONTRATO
	SE1->(Dbgotop())
	If SE1->(Dbseek(xFilial("SE1")+ZAM->ZAM_CONTRT)) .and. val(strtran(oVlUnic:cCaption,',','.')) > 0
		Do While Alltrim(xFilial("SE1")+ZAM->ZAM_CONTRT) == Alltrim(SE1->E1_FILIAL+SE1->E1_CONTRT) .and. SE1->(!Eof())
			If SE1->E1_VENCREA > dEmisUn .and. SE1->E1_PREFIXO = 'CON' .and. SE1->E1_SITUACA <> 'Z' //.and. Empty(SE1->E1_BAIXA) 
			
				nItem++

				nVlUnico := val(strtran(oVlUnic:cCaption,',','.'))  * ( 1 - ZAM->ZAM_DESCVL / 100)
				nNovoVlr := SE1->E1_VALOR + nVlUnico

				//A primeira parcela será a adesao do aditivo
				if nItem == 1 .and. cFpgUni <> '4'
					aAdd(aLstParc,{	'ADI',;
								'01',;
								dtoc(SE1->E1_VENCREA),;
								Transform(nVlUnico,"@E 999,999,999.99"),;
								SE1->(RecNo()) })
				else
				
					aAdd(aLstParc,{	SE1->E1_PREFIXO,;
								SE1->E1_PARCELA,;
								dtoc(SE1->E1_VENCREA),;
								Transform(nNovoVlr,"@E 999,999,999.99"),;
								SE1->(RecNo()) })
				endif

				nVlTotPl += SE1->E1_VALOR
				nVlTotUn += nVlUnico
				
			Endif
			SE1->(DBSKIP())
		Enddo
		
		nQtdParc := nItem 

		/* Atualiza browse com lista dos dependentes */
		LstDepUn()
	
	Else
		aAdd(aLstParc,{	'',;
						space(2),;
						ctod("  /  /  "),;
						space(10) })

	Endif

	If !EMPTY(cCodPun) .and. !EMPTY(dEmisUn)
		oCampanha := GvCampanha():New(ZAM->ZAM_CAMPAN, ZAM->ZAM_CONTRT, cCodPun, dEmisUn, "U")
		FWMsgRun(, {|| oCampanha:GetCampanha() }, "Verficando campanhas ativas", "Processando")
	EndIf

	If len(aLstParc) > 1
		If oCampanha:lExisteCampanha
			If oCampanha:cAbrangencia == "ADES"
				oCampanha:nValorParcela := val(strtran(aLstParc[1,4],',','.'))
				oCampanha:GetValorCalculado() 
				aLstParc[1,4] := Transform(oCampanha:nValorCalculado,"@E 999,999,999.99")
			EndIf
		EndIf		
	EndIf

	oLstParc:SetArray(aLstParc)

	oLstParc:bLine := {|| {;
								aLstParc[oLstParc:nAT,01],;
								aLstParc[oLstParc:nAT,02],;
								aLstParc[oLstParc:nAT,03],;
								aLstParc[oLstParc:nAT,04] }}

	oLstParc:Refresh()
Return

/*/{Protheus.doc} AtivaUni
Chama função que grava dados de carência e parcelas do Aditivo Único  
@author marcossilva
@since 17/02/2016
@version 1
@type function
/*/
Static Function AtivaUni()
	Local bProcess
	Private oProcess

	if empty(cFpgUni)
		msginfo('Selecione a opção Pag.Adesão')
		return .F.
	endif

	bProcess := { || U_GravaUni() }
	oProcess := MsNewProcess():New( bProcess, "Grava dados - Aditivo" , "Aguarde..." , .T. )
	oProcess:Activate()
Return


/*/{Protheus.doc} CancUni
Chama função que cancela o Aditivo Único  
@author marcossilva
@since 18/02/2016
@version 1
@type function
/*/
User Function CancUni()
	Local aRet := {}
	Local aParamBox := {}
	Local lReajuste	:= .F.

	Local bProcess
	Private oProcess

	/* Variáves utilizadas na pesquisa da RA de cancelamento */
	Public	cTPOperac 	:= 'C'
	Public 	cContrt  	:= ZAM->ZAM_CONTRT

	YAE->(dbsetorder(1)) // yae_filial+yae_contrt
	YAF->(dbsetorder(1)) // yaf_filial+yaf_contrt+yaf_proyae

	/* Verifica se o contrato possui o Único */
	If !YAE->(dbseek(xfilial("YAE")+ZAM->ZAM_CONTRT))
		MsgStop("Este contrato não possui Aditivo!","Aditivo")
		Return
	Endif

	aAdd(aParamBox,{1,"Numero da RA: "  ,Space(06),"","","SZ7CA","",6,.F.}) // Tipo caractere
	aAdd(aParamBox,{1,"Aditivo: "		,Space(06),"","","YAE","",6,.F.}) // Tipo caractere
	
	While .T.
		ParamBox(aParamBox,"Cancelamento Aditivo",@aRet)
		
		If len(aRet) < 1
			Return
		Endif
		
		If Empty(Alltrim(aRet[1])) .or. Empty(Alltrim(aRet[2]))
			MsgInfo("Preencha todos os parâmetros")
			Loop
		Endif

		YAE->(dbsetorder(2)) //yae_filial+yae_contrt+yae_codpro
		If !YAE->(dbseek(xFilial("YAE")+ZAM->ZAM_CONTRT+aRet[2]))
			MsgInfo("Aditivo não localizado para esse contrato")
			return
		EndIf
		
		/* Verifica se RA informada é valida */
		SZ7->(Dbsetorder(1))
		If !SZ7->(Dbseek( xFilial("SZ7") + aRet[1] ))
		   	apMsgInfo('RA de Atendimento Inválido! Verificar Numero do RA.')
		   	Return
		Else

			Begin Transaction

				If SZ7->Z7_CONTRAT <> cContrt
					apMsgInfo('Este Contrato nao Pertence ao RA selecionado! Favor verificar o Numero do RA.')
			    	Return
			   	Else
					/* Verifica status do RA informado */
					If SZ7->Z7_STATUS <> "A"
						apMsgInfo(' O RA não está aberto. Não será possível efetuar o cancelamento.')
						Return
					Endif
				
					cQuery := "SELECT MAX(E1_VENCREA) DATAMAX FROM " + RetSqlName("SE1")  + " WHERE E1_PREFIXO = 'CON' AND E1_CONTRT = '" + ZAM->ZAM_CONTRT + "' AND D_E_L_E_T_ = ' ' AND E1_SITUACA <> 'Z' "
					cQuery += "UNION ALL " 
					cQuery += "SELECT MAX(E1_VENCREA) DATAMAX FROM " + RetSqlName("SE1")  + " WHERE E1_PREFIXO = 'ADI' AND E1_CONTRT = '" + ZAM->ZAM_CONTRT + "' AND D_E_L_E_T_ = ' ' AND E1_SITUACA <> 'Z' " 
				
					TcQuery cQuery New Alias "QryCanUni"
					
					If QryCanUni->(!eof())
						dDtUltCon := stod(QryCanUni->DATAMAX)
						QryCanUni->(dbskip())
						dDtUltAdi := stod(QryCanUni->DATAMAX)	
					End
				
					QryCanUni->(dbclosearea())
				
					If dDtUltCon > dDtUltAdi
						lReajuste := .T.
					Endif


					If MsgYesNo("Deseja Excluir o Aditivo?","ADITIVO")
	
						/* Fecha o RA informado */
				   		MsgInfo("O RA: " + aRet[1] + " será fechada/encerrada automaticamente.","Encerramento de RA")
				   		reclock("SZ7", .F.)
				   			SZ7->Z7_STATUS := "F"
				   		SZ7->(msUnlock())
	
						bProcess := { || U_ApagaUni(lReajuste, dDtUltAdi) }
						oProcess := MsNewProcess():New( bProcess, "Cancelamento do Aditivo" , "Aguarde..." , .T. )
						oProcess:Activate()
						
					Endif
				Endif
	
	   		End Transaction	

			Exit
		Endif
	Enddo
Return


/*/{Protheus.doc} ApagaUni
Apagao dados de carência e parcelas do aditivo Único  
@author marcossilva
@since 18/02/2016
@version 1
@type function
/*/
User Function ApagaUni(lReajuste, dDtUltAdi)
	Local 	aAreaSE1
	Default lReajuste := .F.

	oProcess:SetRegua1(5)
	oProcess:SetRegua2(5)

	if msgYesNo("Deseja Excluir o aditivo "+ YAE->YAE_CODPRO + " ?")

		oProcess:IncRegua1("Cancelando o Aditivo no contrato")
		oProcess:IncRegua1("Cancelando o Aditivo no contrato")
		oProcess:IncRegua2('Excluindo Aditivo')

		//Cancela a ativação do controle de proposta
		U_MORA165J(ZAM->ZAM_CONUNI)

		/* Deleta aditivo da tabela de aditivos */
		RecLock("YAE",.F.)
			YAE->(DbDelete())
		YAE->(msUnLock())

		nVlrAdit := YAE->YAE_VALOR

		/* Corrige valor do contrato */
		RecLock("ZAM",.F.)
			ZAM->ZAM_VLTOT	:= ZAM->ZAM_VLTOT - nVlrAdit
			ZAM->ZAM_VLUNIC := ZAM->ZAM_VLUNIC - nVlrAdit
		MsUnLock()

		/* Altera valor da Assinatur	a na VINDI */
		If !Empty(ZAM->ZAM_ASSEXT) .and. ZAM->ZAM_PLTREC == '1'
			lRetCanc := U_MORF934(ZAM->ZAM_ASSEXT, ZAM->ZAM_VLTOT)
			
			if Valtype(lRetCanc) != "U" .and. Valtype(lRetCanc) == "L"
				If !lRetCanc
					MsgInfo("Não foi possível alterar o valor da assinatura na VINDI.","Assinatura VINDI")			
				Endif
			Endif
			
		Endif

		oProcess:IncRegua1("Cancelando o Aditivo no contrato")
		oProcess:IncRegua2('Excluindo tabela de carências')

		/* Grava dados dos dependentes */
		YAF->(dbsetorder(1)) //yaf_filial+yaf_contrt+yaf_proyae
		If YAF->(dbseek(xfilial("YAF")+ZAM->ZAM_CONTRT+YAE->YAE_CODPRO))
			while YAF->(!eof()) .and. YAF->YAF_FILIAL == YAE->YAE_FILIAL .and. YAF->YAF_CONTRT == YAE->YAE_CONTRT .and. YAF->YAF_PROYAE == YAE->YAE_CODPRO
				RecLock("YAF",.F.)
					YAF->(DbDelete())
				YAF->(msUnLock())

				YAF->(dbskip())
			enddo
		EndIf
		
		/* Geracao de historico cancelamento Aditivo Único */
		cTxtHist := "CANCELAMENTO ADITIVO"+ chr(10) + chr(13)
		cTxtHist += "---------------------------------------------------" + chr(10) + chr(13) + chr(10) + chr(13)
		cTxtHist += "Registro de Atendimento: " + SZ7->Z7_NUMERO + chr(10) + chr(13) + chr(10) + chr(13)

		u_fGeraHist(ZAM->ZAM_CONTRT,'ZAM',ZAM->ZAM_CODCLI,ZAM->ZAM_LOJA,ZAM->ZAM_CODPRO,'0015',ZAM->ZAM_CONTRT,cTxtHist,.F.)

		
		oProcess:IncRegua1("Cancelando o Aditivo no contrato")
		oProcess:IncRegua2('Corrigindo as parcelas geradas')

		/* Deleta as parcelas do aditivo */
		SE1->(Dbordernickname('SE1007'))// FILIAL + NUMERO do CONTRATO
		SE1->(Dbgotop())
		If SE1->(Dbseek(xFilial("SE1")+ZAM->ZAM_CONTRT))
						
			nVlrAnt :=  nVlrAdit

			/* Geracao de historico de parcela excluida */
			cTxtHist := "EXCLUSAO DE PARCELAS - PLANO / ADITIVO"+ chr(10) + chr(13)
			cTxtHist += "---------------------------------------------------" + chr(10) + chr(13) + chr(10) + chr(13)
			cTxtHist += "PREF NÚMERO    PARC TIPO   VENCIMENTO    VALOR - SITUAÇÃO" + chr(10) + chr(13)

			While Alltrim(xFilial("SE1")+ZAM->ZAM_CONTRT) == Alltrim(SE1->E1_FILIAL+SE1->E1_CONTRT) .and. SE1->(!Eof())
				
				if SE1->E1_SITUACA == 'Z'
					SE1->(Dbskip())
					loop
				endIf
				
				If SE1->E1_PREFIXO == 'ADI'

					cTxtHist += SE1->E1_PREFIXO + '  ' + SE1->E1_NUM + '  ' + SE1->E1_PARCELA + '   ' + SE1->E1_TIPO + '   ' + DTOC(SE1->E1_VENCTO) + ' ' + Transform(SE1->E1_VALOR, "@E 9,999.99") + " - Excluída " + chr(10) + chr(13)
  
					oCtsReceber := GvCtsReceber():New("PLANO")
					oCtsReceber:RemoveTitulo(1, SE1->( e1_prefixo + e1_num + e1_parcela + e1_tipo ) )					

				Else
				
					If (SE1->E1_VENCREA > dDtUltAdi) .AND.  EMPTY(SE1->E1_BAIXA)
						
						cTxtHist += SE1->E1_PREFIXO + '  ' + SE1->E1_NUM + '  ' + SE1->E1_PARCELA + '   ' + SE1->E1_TIPO + '   ' + DTOC(SE1->E1_VENCTO) + ' ' + Transform(SE1->E1_VALOR, "@E 9,999.99") + " - Valor Corrigido para: " + Transform(SE1->E1_VALOR - nVlrAnt, "@E 9,999.99") + chr(10) + chr(13)

						aAreaSE1 := SE1->(GetArea()) //Guardando o ponteiro anterior para garantir o titulo setado quando sair da função
						
						//Instancia a classe
						oRetira := RetiraBordero():New(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,.F.,.T.)
						//Executa o metodo para retirar titulo de bordero
						oRetira:RetiraBordero()

						//Altera o valor do titulo, sem o reajuste
						RecLock("SE1",.F.)
							SE1->E1_IDCNAB 	:= ''
							SE1->E1_NUMBCO 	:= ''
							SE1->E1_VALOR	:= ZAM->ZAM_VLTOT
							SE1->E1_SALDO	:= ZAM->ZAM_VLTOT
							SE1->E1_VLCRUZ	:= ZAM->ZAM_VLTOT
						SE1->(Msunlock())

						RESTAREA(aAreaSE1)

					Endif
					
				
				Endif

				SE1->(Dbskip())

			Enddo

			u_fGeraHist(ZAM->ZAM_CONTRT,'ZAM',ZAM->ZAM_CODCLI,ZAM->ZAM_LOJA,ZAM->ZAM_CODPRO,'0015',ZAM->ZAM_CONTRT,cTxtHist,.F.)

		EndIf
		
		Z30->( dbSetorder(2) )
		If Z30->( dbSeek( xFilial("Z30") + avKey( ZAM->ZAM_CONTRT,"Z30_VENDA") + avKey( YAE->YAE_CODPRO, "Z30_PRODUT" ) ) )
			Z30->( Reclock("Z30", .F.) )
				Z30->Z30_MOTIVO := "Exclusão de aditivo: " + UsrRetName(__cUserId)
				Z30->( dbDelete() )
			Z30->( MsUnlock() )
		EndIf

		MsgInfo("Aditivo cancelado.","ADITIVO")

	Endif
Return

/*/{Protheus.doc} GravaUni
Grava dados de carência e parcelas do aditivo Único  
@author marcossilva
@since 15/02/2016
@version 1
@type function
/*/
User Function GravaUni()
	Local U
	oProcess:SetRegua1(Len(aLstParc))
	oProcess:SetRegua2(Len(aLstParc))
	lSemPar := .F.

	oProcess:IncRegua1("Aditivando contrato")

	If Empty(cCodPun) .or. Empty(cFpgUni) .or. Empty(cCodVeu)
		MsgStop("É necessário que todos os campos obrigatórios estejam preenchidos!","Aditivo")
		Return
	Endif

	If !(Posicione("SB1", 1, xFilial("SB1") + cCodPun, "B1_GRUPO") $ "0054,0070")
		MsgStop("Código do produto inválido!","Aditivo")
		Return
	Endif

	If Len(aLstParc) == 0 // .or. Len(aLstDep) == 0
		MsgStop("Atenção, o aditivo será incluído sem geração de parcelas, pois não foi localizado parcelas do plano em aberto!","Aditivo")
		lSemPar := .T.
	Endif 
	
	Begin Transaction

		lValidaProposta := .F.
		
		If lValidaProposta
			If Empty(cConUni)
				MsgInfo("É necessário o preenchimento do código da proposta")
				DisarmTransaction()
				Return .F.
			EndIf
		
			If !U_MORA165I(cConUni,cCodVeu)
				DisarmTransaction()
				Return .F.
			EndIf
		EndIf

		oProcess:IncRegua1("Gravando dados da carência do Aditivo")
		
	 	/* Grava dados do titular */
		RecLock("YAE",.T.)
			YAE->YAE_FILIAL := xFilial("YAE")
			YAE->YAE_CONTRT	:= If(lValidaProposta,cConUni,ZAM->ZAM_CONTRT)
			YAE->YAE_EMISSA	:= dEmisUn
			YAE->YAE_CODPRO	:= cCodPun
			YAE->YAE_VALOR	:= val(strtran(oVlUnic:cCaption,',','.'))
			YAE->YAE_FPGPAR	:= cFpgUni
			YAE->YAE_CODVEN	:= cCodVeu
			YAE->YAE_CODCOO	:= Posicione("SA3", 1, xFilial("SA3") + cCodVeu, "A3_SUPER")
			YAE->YAE_CODSUP	:= Posicione("SA3", 1, xFilial("SA3") + cCodVeu, "A3_GEREN")   
			YAE->YAE_VLORIG := val(strtran(oVlUnic:cCaption,',','.'))
		MsUnLock()

		/*Inclui o contrato na rotina de comissão para na ativação calcular o valor*/
		jVenda := JsonObject():New()
		oComissao := GmComissao():New()

		jVenda['VENDA'] 			:= ZAM->ZAM_CONTRT
		jVenda['VENDEDOR']			:= cCodVeu
		jVenda['PERIODO']			:= oComissao:GetPeriodoAtual( dEmisUn )
		jVenda['PRODUTO']			:= cCodPun
		jVenda['VALOR']				:= val(strtran(oVlUnic:cCaption,',','.'))
		jVenda['EMISSAO']   		:= dEmisUn
		jVenda['VENDEDOR_NOME']		:= Posicione("SA3", 1, xFilial("SA3") + cCodVeu, "A3_NOME")
		jVenda['PRODUTO_DESCRI']	:= Posicione("SB1", 1, xFilial("SB1") + cCodPun, "B1_DESC" )
		jVenda['CLIENTE']			:= ZAM->ZAM_NOMCLI

		oComissao:NewRecord( jVenda )
		/*-------------------------------------------------------------------------*/

		//Grava a carencia do TITULAR na tabela de carencias
		RecLock("YAF", .T.)
			YAF->YAF_FILIAL := XFILIAL("YAF")
			YAF->YAF_CONTRT := ZAM->ZAM_CONTRT
			YAF->YAF_PROYAE := cCodPun
			YAF->YAF_ITEM	:= "TT"
			YAF->YAF_DTCARE	:= aLstDep[1][09]
			YAF->YAF_CARENC	:= aLstDep[1][10] 
		MsUnlock()	

		//Ajusta o Valor do COntrato
		Reclock("ZAM",.F.)
			ZAM->ZAM_VLTOT	:= ZAM->ZAM_VLTOT + val(strtran(oVlUnic:cCaption,',','.'))
			ZAM->ZAM_VLUNIC :=  val(strtran(oVlUnic:cCaption,',','.'))
			If oCampanha:lExisteCampanha
				ZAM->ZAM_CAMPAN := oCampanha:cCodigo
			EndIf
			ZAM->ZAM_VLORIG += val(strtran(oVlUnic:cCaption,',','.'))
			
		MsUnlock()

		/* Altera valor da Assinatur	a na VINDI */
		If !Empty(ZAM->ZAM_ASSEXT) .and. ZAM->ZAM_PLTREC == '1'
			lRetCanc := U_MORF934(ZAM->ZAM_ASSEXT, ZAM->ZAM_VLTOT)
			
			if Valtype(lRetCanc) != "U" .and. Valtype(lRetCanc) == "L"
				If !lRetCanc
					MsgInfo("Não foi possível alterar o valor da assintura na VINDI.","Assinatura VINDI")			
				Endif
			Endif
			
		Endif

		If Len(aLstDep) > 0
			/* Grava dados dos dependentes */
			ZAN->(dbsetorder(1))
			If ZAN->(dbseek(cseek:= xfilial("ZAN")+ZAM->ZAM_CONTRT))
				/* Começa do segundo item, pois o primeiro é p titular */
				nItem := 2
		
				While ZAN->(!eof()) .and. cseek == xfilial("ZAN")+ZAN->ZAN_CONTRT
					If ZAN->ZAN_STATUS == 'A' .and. ZAN->ZAN_ITEM == aLstDep[nItem][01]
						RecLock("YAF",.T.)
							YAF->YAF_FILIAL := XFILIAL("YAF")
							YAF->YAF_CONTRT := ZAM->ZAM_CONTRT
							YAF->YAF_PROYAE := cCodPun
							YAF->YAF_ITEM	:= ZAN->ZAN_ITEM
							YAF->YAF_DTCARE	:= aLstDep[nItem][09]
							YAF->YAF_CARENC	:= aLstDep[nItem][10]
						MsUnLock()
						nItem++
					Endif
					ZAN->(dbskip())
				EndDo
			EndIf
		Endif
			
		If SB1->(DbSeek(xFilial('SB1')+ZAM->ZAM_CODPRO))
			cNatur := SB1->B1_NATUREZ
		Else
			MsgInfo("O produto "+alltrim(ZAM->ZAM_CODPRO)+" não foi encontrado no cadastro de produtos.")
			DisarmTransaction()
			Return
		EndIf

		//Reserva numero do lote para aditivo
		oProcess:IncRegua1("Reservando código do lote de mensalidades")
		cCodLtRe := "UNIC" + GravaData(ddatabase,.F.,1)

		//Alterar as parcelas do contrato com o valor do aditivo
		For U := 1 to Len(aLstParc)

			//Na primeira parcela, gera a adesao para o aditivo
			if U == 1 .and. cFpgUni <> '4'
				oProcess:IncRegua1("Gerando Parcela de Adesão")
				AdeAdi(aLstParc[U][3],val(strtran(oVlUnic:cCaption,',','.')))

			//Nas demais parcelas acrescenta o valor do aditivo 	
			else
				
				SE1->(dbGoTo(aLstParc[U][5]))
				
				oProcess:IncRegua1("Alterando Valor das parcelas do contrato")
				oProcess:IncRegua2('Parcela: ' + aLstParc[U][2])
				
				if SE1->E1_SALDO > 0

					lMsErroAuto := .F.

					aArray := {}
					nVlrReal := SE1->E1_VLRREAL
				
					aAdd(aArray, { "E1_PREFIXO"		, SE1->E1_PREFIXO	  	, nil})
					aAdd(aArray, { "E1_NUM"		  	, SE1->E1_NUM		    , nil})
					aAdd(aArray, { "E1_PARCELA"		, SE1->E1_PARCELA	  	, nil})
					aAdd(aArray, { "E1_VALOR"		, ZAM->ZAM_VLTOT		, nil})
					aAdd(aArray, { "E1_SALDO"		, ZAM->ZAM_VLTOT		, nil})
					//Se nao for ativacao, é pq é a rotina de aditivo. Nesse caso altera o lote das parcelas.
					if !lrotAti
						aAdd(aArray, { "E1_CODLOTE"		, cCodLtRe				, nil})
					endif 
					MsExecAuto({|x,y|fina040(x,y)},aArray,4)

					If lMsErroAuto
						disarmTransaction()
						return "Não foi possível efetuar a alteração"
					Endif

					SE1->( Reclock("SE1", .F.) )
						SE1->E1_VLRREAL := nVlrReal
					SE1->( MsUnlock() )
					
					oRetira := RetiraBordero():New(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,.F.,.T.)
					oRetira:RetiraBordero()

					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
						Return
					EndIf
				
				ENDIF

			endif
		Next U

		//Grava lote caso seja executado da rotina de aditivo e não da ativação
		if !lrotAti
			cCodEvo := GetSX8Num('ZFI','ZFI_CODIGO')
			ConfirmSX8()

			RecLock('ZFI',.T.)
				ZFI->ZFI_FILIAL 	:= xfilial("ZFI")
				ZFI->ZFI_CODIGO 	:= cCodEvo
				ZFI->ZFI_CONTRT 	:= ZAM->ZAM_CONTRT
				ZFI->ZFI_PROCES 	:= 'ADITIVO'
				ZFI->ZFI_DTMOD		:= ddatabase
				ZFI->ZFI_LOTE		:= cCodLtRe
				ZFI->ZFI_MESINI		:= StrZERO(Month(dDataBase))+"/"+StrZero(Year(dDataBase))
				ZFI->ZFI_INDCOR		:= 0
				ZFI->ZFI_VLPROD		:= ZAM->ZAM_VALOR
				ZFI->ZFI_VLTXTI		:= ZAM->ZAM_VLTAXA
				ZFI->ZFI_VLTXDE   	:= ZAM->ZAM_VLTXDE
				ZFI->ZFI_DESCON		:= ZAM->ZAM_DESCVL
				ZFI->ZFI_VLMENS   	:= ZAM->ZAM_VLTOT
				ZFI->ZFI_VLUNIC		:= val(strtran(oVlUnic:cCaption,',','.'))
				ZFI->ZFI_DESOPE		:= "ADITIVO CONTRATO"
			ZFI->(MsUnLock())

			RecLock('SZL',.T.)
				SZL->ZL_FILIAL	 := xFilial('SZL')
				SZL->ZL_CODLOTE := cCodLtRe
				SZL->ZL_DTLOTE  := dDataBase
				SZL->ZL_CONTRTI := ZAM->ZAM_CONTRT
				SZL->ZL_CONTRTF := ZAM->ZAM_CONTRT
				SZL->ZL_PERCENT := 0
				SZL->ZL_CONDPG  := ZAM->ZAM_CPAGPV
				SZL->ZL_STATUS  := '1'
				SZL->ZL_TIPO    := '1'
			SZL->(MsUnLock())
		ENDIF

		oProcess:IncRegua2('Gravando histórico')

		/* Grava histórico */
		cHistIn :=  'INCLUSÃO DE ADITIVO'+chr(10)+chr(13)
		cHistIn += "-----------------------------------------------" + chr(10) + chr(13)
		cHistIn += "Aditivo: " + Posicione("SB1",1,xfilial("SB1")+YAE->YAE_CODPRO,"B1_DESC") + chr(10) + chr(13)
		cHistIn += "Proposta.................: " + Alltrim(YAE->YAE_CONTRT) + chr(10) + chr(13)
		cHistIn += "Data.....................: " + DTOC(ddatabase) + chr(10) + chr(13)
		cHistIn += "Emissão..................: " + DTOC(dEmisUn) + chr(10) + chr(13)
		cHistIn += "-----------------------------------------------" + chr(10) + chr(13)
		cHistIn += "Valor atual do plano.....: " + Transform(ZAM->ZAM_VLTOT - val(strtran(oVlUnic:cCaption,',','.')),"@E 999,999,999.99") + chr(10) + chr(13)
		cHistIn += "-----------------------------------------------" + chr(10) + chr(13)
		cHistIn += "Valor do aditivo.........: " + Transform(val(strtran(oVlUnic:cCaption,',','.')),"@E 999,999,999.99") + chr(10) + chr(13)
		cHistIn += "Parcelas alteradas.......: " + Transform(nQtdParc, "@E 99999999") + chr(10) + chr(13)
		cHistIn += "-----------------------------------------------" + chr(10) + chr(13)
		cHistIn += "Novo valor do plano......: " + Transform(ZAM->ZAM_VLTOT,"@E 999,999,999.99") + chr(10) + chr(13)

		cMsg_ := ""
		Do case 
			case (ZAM->ZAM_FPAG $ '1' .and. ZAM->ZAM_ADIMEN == 11 ) .and. Len(aLstParc) == 12
				oCampanha:lBaixaParcela := .T.
				cMsg_ += "Anuidade em dinheiro"  + CRLF
			case ZAM->ZAM_FPAG $ "3" .and. Len(aLstParc) == 12
				oCampanha:lBaixaParcela := .T.
				cMsg_ += "Anuidade em CC" + CRLF
			case ZAM->ZAM_FPAG $ "4" .and. Len(aLstParc) == 12
				oCampanha:lBaixaParcela := .T.
				cMsg_ += "Forma de pagamento Desconto em Folha" + CRLF
			case ZAM->ZAM_FPAG $ "6" .and. Len(aLstParc) == 12
				oCampanha:lBaixaParcela := .T.
				cMsg_ += "Forma de pagamento Renovação" + CRLF
			case ZAM->ZAM_FPAG $ "9" .and. Len(aLstParc) == 12
				oCampanha:lBaixaParcela := .T.
				cMsg_ += "Forma de pagamento Migração" + CRLF
			case oCampanha:lBaixaParcela
				cMsg_ += "Participação da campanha:" + oCampanha:cCodigo + CRLF
		EndCase			

		If oCampanha:lExisteCampanha
			cHistIn += oCampanha:GetHistorico()
		EndIf

		If oCampanha:lBaixaParcela
			oCampanha:cHistorico := " "
			cHistIn += oCampanha:cHistorico
		EndIf

		//Instancia objeto de beneficios plano
		oBenef := GvBeneficioPlano():new(ZAM->ZAM_CONTRT)

		//Cadastra beneficios do aditivo
		if !empty(YAE->YAE_CODPRO)
			lRet := oBenef:setBeneficio(YAE->YAE_CODPRO,'U')

			if !lRet
				MsgAlert('Não foi possível cadastrar os beneficios do plano, processo cancelado!')
				DisarmTransaciton()
				return .F.
			endif
		endif

		U_fGeraHist(ZAM->ZAM_CONTRT,'ZAM',ZAM->ZAM_CODCLI,ZAM->ZAM_LOJA,ZAM->ZAM_CODPRO,'0001',ZAM->ZAM_CONTRT,cHistIn,.F.)

	End Transaction	
	
	MsgInfo("Aditivo Incluído. É necessário Reimprimir os boletos das parcelas que sofreram alteração","ADITIVO")
	
	oDlg1:End()	
	
Return

User Function LoteErro()
	Local lRet := .F.
	
	cQuery	:= "SELECT COUNT(*) AS QRY_QUANT FROM " + retSqlName("SE1") + " SE1 "
	cQuery	+= "WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
	
	cQuery	+= "AND E1_PREFIXO = 'CON' " 
	
	cQuery	+= "AND E1_CONTRT = '" + ZAM->ZAM_CONTRT + "' "
	cQuery	+= "AND E1_CODLOTE = '0999122015' "
	cQuery	+= "AND E1_VENCREA < '" + dtos(dDataBase) + "' AND E1_BAIXA = ' ' "
	cQuery	+= " AND D_E_L_E_T_ <> '*'"

	tcQuery cQuery new alias "QRYE"

	if QRYE->(!eof())
		if QRYE->QRY_QUANT > 0
			lRet := .T.
		endif
	endIf

	QRYE->(dbCloseArea())
return lRet

/*/{Protheus.doc} ValiCond
Valida condição de pagamento para os novos planos
@author leonardofreitas
@since 29/09/2016
@version undefined

@type function
/*/
User Function ValiCond()

	Local lRet := .F.

	if alltrim(M->ZAM_CODPRO) $ '009922,009923,009924'
		
		if empty(alltrim(M->ZAM_CLIFAT))
			if left(M->zam_cpagpv,1) == 'P'
				lRet := .T.
			else
				M->zam_cpagpv := '   '
				MsgInfo('Condição de pagamento invalido para este plano!')
			endif
		else
			if left(M->zam_cpagpv,1) <> 'P'
				lRet := .T.
			else
				M->zam_cpagpv := '   '
				MsgInfo('Condição de pagamento invalido para este plano!')
			endif
		endif
	else
	
		lRet := .T.
		
	endif

return lRet

/*/{Protheus.doc} MORA934P
//TODO Descrição auto-gerada.
	Rotina para recalcular todo o contrato no TudoOK


@author paulosouza
@since 28/11/2016
@version undefined

@type function
/*/
User Function MORA934P()
	local aTxsTitular := {}
	local aTxsDependen:= {}
	Local P

	aTxsTitular  := u_MORF792("T",M->ZAM_CODPRO,"TITULA" ,M->ZAM_DTNAS, M->ZAM_CONTRT)
	
	M->ZAM_VALOR  := SB1->B1_PRV1 
	M->ZAM_DESCRI := SB1->B1_DESC
	M->ZAM_CODTX  := aTxsTitular[1]
	M->ZAM_DESCTX := aTxsTitular[2]
	M->ZAM_VLTAXA := aTxsTitular[3]
	M->ZAM_CARENC := aTxsTitular[4]
	
	//Chama a rotina pela segunda vez para calcular os dados com os campos atualizados
	u_MORF792("T",M->ZAM_CODPRO,"TITULA" ,M->ZAM_DTNAS, M->ZAM_CONTRT)

	For P := 1 To Len(aCols)
		aTxsDependen  := u_MORF792("D",M->ZAM_CODPRO, aCols[P][5], aCols[P][4], M->ZAM_CONTRT)          
		aCols[P][10]  := aTxsDependen[1]
		aCols[P][11]  := aTxsDependen[2]
		aCols[P][12]  := aTxsDependen[3]
		aCols[P][15]  := aTxsDependen[4]
	Next P
	
Return Alltrim(M->ZAM_CLIFAT)

user function CEPPLANO
	Local aRetorno := {}
	Local i := 0
	
	aRetorno := U_WSCep(M->ZAM_CEP) 

	if len(aRetorno) > 0
	
		for i:= 1 to Len(aRetorno)
			
			Do Case
				Case (aRetorno[i][1] == 'logradouro')
					M->ZAM_END		:= iif(empty(aRetorno[i][2]), M->ZAM_END, substr(aRetorno[i][2],1,40))
				Case (aRetorno[i][1] == 'bairro')
					M->ZAM_BAIRRO  	:= iif (empty(aRetorno[i][2]), M->ZAM_BAIRRO, aRetorno[i][2])
				Case (aRetorno[i][1] == 'cidade')
					M->ZAM_MUNICI 	  	:= iif(empty(aRetorno[i][2]), M->ZAM_MUNICI,aRetorno[i][2])
				Case (aRetorno[i][1] == 'uf')
					M->ZAM_EST	  	:= iif(empty(aRetorno[i][2]), M->ZAM_EST,aRetorno[i][2])
				Case (aRetorno[i][1] == 'ibge')
					M->ZAM_CODMUN 	:= iif(empty(aRetorno[i][2]), M->ZAM_CODMUN,right(aRetorno[i][2],5))
				Case (aRetorno[i][1] == 'complemento')
					M->ZAM_COMP	:= iif(empty(aRetorno[i][2]), M->ZAM_COMP, aRetorno[i][2])
			EndCase
			
		next i
	
	endif
	
return .T.

/*/{Protheus.doc} GetRegCo
Busca regra contratual do produto plano 
@author leonardofreitas
@since 28/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodPro, characters, descricao
@type function
/*/
user function GetRegCo(cCodPro)
	local cRegCont := '0000000001'

	ZFD->(dbsetorder(1))
	
	if ZFD->(dbseek(xFilial('ZFD') + cCodPro))
		cRegCont := ZFD->ZFD_CODIGO
	endif
	
	//Calcula Data da vigência do prever
	If FunName() == "MORA934O"     
		M->ZAM_DTVIGE := MonthSum(M->ZAM_EMISSA,24)
    Else
    	M->ZAM_DTVIGE := MonthSum(M->ZAM_EMISSA,ZFD->ZFD_VIGENC)
    EndIf	
      
return cRegCont

User function MORA934Q()
  Private aBrowse   := {}
  Private oTela     := oGride := NIL
  
  BeginSql Alias 'Objetos'
	Select 	sz7.z7_numero as protocolo,
			sz7.z7_status as status,
			trim(sz7.z7_produto)||'-'||trim(sb1.b1_desc) as objeto,
			trim(sa1.a1_cod)||'-'||trim(sa1.a1_nome) as cliente,
			trim(sze.ze_cod)||'-'||trim(sze.ze_nome) as cobrador,
			trim(sz7.z7_recepor)||'-'||trim(szj.zj_desc) as Receptor,
			sz7.z7_dtsaida as saida,
			sz7.z7_dtstatu as entrega,
			sz7.z7_dtretor as dt_baixa,
			trim(sz7.z7_motdev) as motivo_dev
	From %Table:SZ7% SZ7
		INNER JOIN %Table:SA1% SA1
			on	sa1.a1_cod = sz7.z7_cliente
			and	sa1.%notdel%
		INNER JOIN %Table:SZE% SZE
			on	sze.ze_filial = %xFilial:SZE%
			and	sze.ze_cod = sz7.z7_cobra
			and	sze.%notdel%
		LEFT JOIN %Table:SZJ% SZJ
			on  szj.zj_filial = %xFilial:SZJ%
			and	szj.zj_codigo = sz7.z7_parente
			and	szj.%notdel%
		INNER JOIN %Table:SB1% SB1
			on  sb1.b1_filial = %xFilial:SB1%
			and sb1.b1_cod = sz7.z7_produto
			and	sb1.%notdel%
	Where 	sz7.z7_filial = %xFilial:SZ7%
		and	sz7.z7_contrat = %Exp:ZAM->ZAM_CONTRT% 
		and	sz7.%notdel%
	Order by entrega desc
  EndSql	

  aBrowse := {}
  While Objetos->( !Eof() )
	 aadd(aBrowse,{Objetos->status,Objetos->cliente,Objetos->protocolo,Objetos->objeto,Objetos->cobrador,Objetos->Receptor,dToC(sToD(Objetos->saida)),dToC(sToD(Objetos->entrega)),dToC(sToD(Objetos->dt_Baixa)),Objetos->motivo_dev})	
	 Objetos->( dbSkip() )	
  EndDo
  Objetos->( dbCloseArea() )

	//Pega os novos objetos
	getZops()		

  oTela   := TDialog():New(0,0,300,1100,"Objetos do contrato " + ZAM->ZAM_CONTRT,,,,,CLR_GREEN,CLR_WHITE,,,.T.)
  
  oPanel2 := TPanel():New(35,01,"",oTela,,.F.,,CLR_BLACK,CLR_WHITE,100,30)
  oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

  oGride  := FWBrowse():New(oPanel2)
	oGride:SetDataArray(.T.)
	oGride:DisableConfig()
	oGride:DisableReport()
	oGride:SetArray(aBrowse)
	oGride:SetDoubleClick({|| Visuobj()})
	oGride:AddLegend({||aBrowse[oGride:nAT,1] == 'T' } ,"AMARELO"   	,"Em transido")
	oGride:AddLegend({||aBrowse[oGride:nAT,1] == 'A' } ,"BR_PRETO" 		,"Em aberto")
	oGride:AddLegend({||aBrowse[oGride:nAT,1] == 'E' } ,"BR_BRANCO"    	,"Entregue")
	oGride:AddLegend({||aBrowse[oGride:nAT,1] == 'D' } ,"VERMELHO"  	,"Devolvido")
	oGride:AddLegend({||aBrowse[oGride:nAT,1] == 'R' } ,"AZUL"  		,"Recusado")
	oGride:AddColumn({"Situação"		,{||aBrowse[oGride:nAT,1]},"C","!@"	,1,6,0,.F.,,.F.,,,,,,{"T=Em transito","A=Em Aberto","E=Entregue","D=Devolvido","R=Recusado"}})
	oGride:AddColumn({"Cliente"	  		,{||aBrowse[oGride:nAT,2]},"C","!@"	,1,15})
	oGride:AddColumn({"Protocolo"   	,{||aBrowse[oGride:nAT,3]},"C","!@"	,1,6})
	oGride:AddColumn({"Objeto"	    	,{||aBrowse[oGride:nAT,4]},"C","!@"	,1,15})
	oGride:AddColumn({"Cobrador"	    ,{||aBrowse[oGride:nAT,5]},"C","!@"	,1,15})
	oGride:AddColumn({"Receptor"		,{||aBrowse[oGride:nAT,6]},"C","!@"	,1,15})
	oGride:AddColumn({"Saída"	  		,{||aBrowse[oGride:nAT,7]},"D","!@"	,1,6})
	oGride:AddColumn({"Entrega"	    	,{||aBrowse[oGride:nAT,8]},"D","!@"	,1,6})
	oGride:AddColumn({"Dt. Baixa"		,{||aBrowse[oGride:nAT,9]},"D","!@"	,1,6})
	oGride:AddColumn({"Mot. Devolucao"	,{||aBrowse[oGride:nAT,10]},"C","!@"	,1,15})
  
	oGride:Activate()
	oTela:Activate(,,,.T.)
Return

/*Função que verifica casos exclusivos de contratos ocm ações judiciais
Emite um aviso
*/
Static Function VerAcaJud()

	If alltrim(cempant+cfilant+zam->zam_contrt) $ '010100916674'

		MsgInfo("Processo Judicial de n.º 0801096-36.2014.8.20.6002 <br>"+; 
		"Na Sentença, o Juízo decidiu pela condenação da Empresa à correção e atualização do valor a título de seguro de vida. <br>"+;
		"Assim, restou como única obrigação à Empresa, decorrente do processo judicial, a atualização do valor da indenização securitária<br>"+; 
		"devida à parte Autora em caso de sinistro (R$ 1.000,00), corrigido monetariamente pelo INPC desde a data de contratação e, além disso,<br>"+; 
		"se responsabilizar ao seu pagamento caso ocorra algum sinistro que se enquadre na hipótese de pagamento.")
	
	EndIf


Return

/*
Gera a parcela de adesão para o aditivo
*/
static Function AdeAdi(cvencto,nvlrAd)

	lMsErroAuto := .F. 

	If SB1->(DbSeek(xFilial('SB1')+ZAM->ZAM_CODPRO))
		cNatur := SB1->B1_NATUREZ
	else
		cNatur := ''
	ENDIF

	cCodLote := "UNIC" + GravaData(ddatabase,.F.,1)
	cNumPar := GetSX8Num('SE1','E1_NUM')
	ConfirmSX8()

	aVetor  := {{"E1_FILIAL"  ,xFilial('SE1')			,Nil},;
				{"E1_PREFIXO"	,'ADI'   				,Nil},;
				{"E1_NUM"		,cNumPar     			,Nil},;
				{"E1_PARCELA"	,'01'	  				,Nil},;
				{"E1_TIPO"		,"DP "       	  		,Nil},;
				{"E1_NATUREZ"	,cNatur			   		,Nil},;
				{"E1_CLIENTE"	,ZAM->ZAM_CODCLI   		,Nil},;
				{"E1_LOJA"		,ZAM->ZAM_LOJA	  		,Nil},;
				{"E1_CONTRT"	,ZAM->ZAM_CONTRT   		,Nil},;
				{"E1_EMISSAO"	,dEmisUn				,Nil},;
				{"E1_VEND1"		,cCodVeu		  		,Nil},;
				{"E1_OCORREN"  ,"01"    		  		,Nil},;
				{"E1_VENCTO"	,ctod(cvencto)  		,Nil},;
				{"E1_VENCREA"	,ctod(cvencto)			,Nil},;
				{"E1_CODLOTE"	,cCodLote 	       		,Nil},;
				{"E1_CLIRES"	,ZAM->ZAM_CODCLI   		,Nil},;
				{"E1_RESNOME"	,ZAM->ZAM_NOMCLI   		,Nil},;
				{"E1_LOJARES"	,ZAM->ZAM_LOJA     		,Nil},;
				{"E1_VALOR"		,nvlrAd					,Nil}}
					
			MSExecAuto({|x,y| Fina040(x,y)},aVetor,3)
			
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				Return
			EndIf

return


static Function VerAdi(cCodPun)

	local lret := .T.

	YAE->(dbsetorder(2))
	if YAE->(dbseek(xfilial('YAE')+ZAM->ZAM_CONTRT+cCodPun))
		MsgInfo("O contrato já possui este aditivo!")
		return .f.
	endif	

return lRet


/*
Tela que exibe os aditivos do contrato e as carencias
*/
User Function ConsAdi()

	Local _oDlg1
	Private oLstAdi
	Private aLstAdi	:= {} 
	Private oLstCar
	Private aLstCar	:= {} 

	DEFINE MSDIALOG _oDlg1 TITLE "Aditivos do Contrato" FROM C(50),C(10) TO C(440),C(800) PIXEL		
	
		@ C(000),C(000) ListBox oLstAdi Fields ;
		HEADER "Emissão","Aditivo","Valor","Valor Original","Vendedor","Coordenador","Supervisor";
		Size C(400),C(080) Of _oDlg1 Pixel ColSizes 30,50,30,30,50,50,50                                                  
		
		@ C(080),C(000) ListBox oLstCar Fields ;
		HEADER "Item","Nome","Dias Carencia","Data Carencia";
		Size C(700),C(100) Of _oDlg1 Pixel ColSizes 20,80,40,50                     
		
		//No carregamento da tela carrega a grid dos aditivos do contrato
		ListAdi(ZAM->ZAM_CONTRT)                                       
		
		oLstAdi:bChange := {|| fLstCar(ZAM->ZAM_CONTRT,aLstAdi[oLstAdi:nAT,08]) }
		
		@ C(180),C(350) Button "Fechar" Size C(040),C(015) PIXEL OF _oDlg1 action _oDlg1:End() 
		
	ACTIVATE MSDIALOG _oDlg1 CENTERED

Return

/*
Lista os aditivos do contrato
*/
Static function ListAdi(cContrt)
	
	cquery := "Select * from " + retsqlname("YAE")
	cquery += " where YAE_CONTRT = '"+ cContrt +"' and d_e_l_e_t_ = ' ' and YAE_FILIAL = '"+ xFilial("YAE") +"'"
	tcquery cquery new alias "QRY"

	if QRY->(!eof())

		while QRY->(!eof())

			aAdd(alstAdi,{ dtoc(stod(qry->yae_emissa)), posicione("SB1",1,xfilial("SB1")+qry->yae_codpro,"b1_desc"), transform(qry->yae_valor,"@E 999,9999.99"),;
			transform(qry->yae_vlorig,"@E 999,9999.99"), posicione("SA3",1,xfilial("SA3")+qry->yae_codven,"A3_NOME"), posicione("SA3",1,xfilial("SA3")+qry->yae_codcoo,"A3_NOME"),;
			posicione("SA3",1,xfilial("SA3")+qry->yae_codsup,"A3_NOME"), qry->yae_codpro })
			
			qry->(dbskip())
		endDo
	else
		aAdd(alstAdi,{'','','','','','','',''})
	endif	

	oLstAdi:SetArray(alstAdi)

	oLstAdi:bLine := {|| {;
				alstAdi[oLstAdi:nAT,01],;
				alstAdi[oLstAdi:nAT,02],; 
				alstAdi[oLstAdi:nAT,03],;
				alstAdi[oLstAdi:nAT,04],;
				alstAdi[oLstAdi:nAT,05],;
				alstAdi[oLstAdi:nAT,06],;
				alstAdi[oLstAdi:nAT,07],;
				alstAdi[oLstAdi:nAT,08];
				}}

	QRY->(dbclosearea())
return


/*
Listagem das carencias baseado no aditivo clica na grid acima
*/
static function fLstCar(cContrt,cprod)
	aLstCar	:= {} 
	

	cquery := "Select * from " + retsqlname("YAF")
	cquery += " where YAF_CONTRT = '"+ cContrt +"' and YAF_PROYAE = '"+ cprod +"' and d_e_l_e_t_ = ' ' and YAF_FILIAL = '"+ xfilial("YAF") +"'"
	tcquery cquery new alias "QRY"

	if QRY->(!eof())

		while QRY->(!eof())

			aAdd(alstCar,{ qry->YAF_ITEM,iif(qry->YAF_ITEM == "TT",posicione("ZAM",1,xfilial("ZAM")+cContrt,"ZAM_NOMCLI"),posicione("ZAN",1,xfilial("ZAN")+cContrt+qry->yaf_item,"ZAN_NOME")) ,qry->yaf_carenc,dtoc(stod(qry->yaf_dtcare))})
			
			qry->(dbskip())
		endDo
	else
		aAdd(alstCar,{'','','','','','',''})
	endif	

	oLstCar:SetArray(alstCar)
	oLstCar:bLine := {|| {;
				alstCar[oLstCar:nAT,01],;
				alstCar[oLstCar:nAT,02],; 
				alstCar[oLstCar:nAT,03],;
				alstCar[oLstCar:nAT,04],;
				}}

	QRY->(dbclosearea())

return

/*/{Protheus.doc} MORA934S
	Chama tela de cobrança meirelles
	@type  Static Function
	@author user
	@since 16/08/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
user Function MORA934S()
	oCobranca := GvCobrancaMeirelles():New("1", ZAM->ZAM_CONTRT)
  oCobranca:TelaCobranca()
Return 

/*
Função que verifica se a soma das taxas do contrato ultrapassaram o valor do plano.
Caso sim, o valor do plano será o somatório das taxas e não mais o valor do plano 
*/
static Function VerEssen()

	local nVlrTxt := 0
	local i
	local lRecal := .F. //Variavel que indica se recalcula o contrato ou nao

	//Calcula as taxas dos dependetes
	for i:= 1 to len(aCols) //Percorre o acols de dependentes	
		if !aCols[i][len(aHeader)+1] //Verifica se o dependente esta excluído
			
			dDataNasc := gdFieldGet("ZAN_DTNASC", i) 
			nVlrTxt += GetTaxa(dDataNasc,M->ZAM_CODPRO)	

		endif
	next

	//Calcula a taxa do titular
	nVlrTxt += GetTaxa(dDataNasc,M->ZAM_CODPRO)

	//Caso a soma das taxas seja maior que o valor do plano. o valor do plano deve ser a soma das taxas
	if nVlrTxt > M->ZAM_VALOR
		lRecal := .T.
	endIf

return lRecal

/*/{Protheus.doc} User Function MORA934T
	(long_description)
	@type  Function
	@author user
	@since 24/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function MORA934T()
	local jRecorrencia := Nil
	
	//busca se existe uma recorrência para este contrato
	jRecorrencia := u_MORF940(alltrim(M->ZAM_CONTRT))

	if jRecorrencia <> Nil
		M->ZAM_FPAG   := '3'
		M->ZAM_FPGADE := '2'
		M->ZAM_PLTREC := '3'
		M->ZAM_RECORR := 'S'
	endif

Return .T.


static function getZops()

	BEGINSQL ALIAS "OBJ"

	SELECT
            TRIM(zam.zam_munici) municipio,
            TRIM(zam.zam_bairro) bairro,
            TRIM(zam.zam_numero) numero,
            zam_contrt       contrato,
            TRIM(zam.zam_nomcli) nome,
            zob.zob_codpro   codigo,
            TRIM(zop_descri) descricao,
            form_data(nvl((
                SELECT
                    MAX(zom_dtmovi)
                FROM
                    %table:zom% zom
                WHERE
                    zom_tpmovi = 'TRANSITO'
                    AND zom.d_e_l_e_t_ = ' '
                    AND zob_codigo = zom_codobj
            ),' ')) data_saida,
            form_data(nvl((
                SELECT
                    MAX(zom_dtmovi)
                FROM
                    %table:zom% zom
                WHERE zom_tpmovi = 'ENTREGUE'
                    AND zom.d_e_l_e_t_ = ' '
                    AND zob_codigo = zom_codobj
            ),' ')) data_retorno,
            form_data(nvl((
                SELECT
                    MAX(zom_dtmovi)
                FROM
                    %table:zom% zom
                WHERE zom_tpmovi = 'RECEBIDO'
                    AND zom.d_e_l_e_t_ = ' '
                    AND zob_codigo = zom_codobj
            ),' ')) data_recebimento,
            CASE zob_situac
                WHEN 'G'   THEN
                    'RECEBIDO'
            WHEN 'A'   THEN
                    'AGUARDANDO PRODUCAO'
                WHEN 'B'   THEN
                    'BLOQUEADO'
                WHEN 'T'   THEN
                    'TRANSITO'
                WHEN 'E'   THEN
                    'ENTREGUE'
                WHEN 'D'   THEN
                    'DEVOLVIDO'
                WHEN 'R'   THEN
                    'RECUSADO'
                WHEN 'C'   THEN
                    'CANCELADO'
								WHEN 'P'   THEN
										'ENVIADO PARA PRODUCAO'
                ELSE
                    'NAO IDENTIFICADO'
            END status,
            ZOB_VENCTO PRIMEIRO_VENCIMENTO,
            zoq_codigo COD_TRANSPORTADOR,
            zoq_NOME NOME_TRANSPORTADOR,
            ZOB_NEGOCI NEGOCIO,
            ZOB_UNIDAD UNIDADE,
            ZOB_LOTGRA LOTE,
			ZOB_CODIGO CODOBJ
            
        FROM
            %table:ZOB%   zob
            INNER JOIN %table:ZAM%   zam ON zam_contrt = zob.zob_contrt
                                    AND zam.d_e_l_e_t_ = ' '
            INNER JOIN %table:ZOP%   zop ON zob.zob_codpro = zop.zop_codigo
                                    AND zop.d_e_l_e_t_ = ' '
            LEFT JOIN %table:ZOQ% zoq ON zoq.zoq_codigo = zob.zob_transp and zoq.d_e_l_e_t_ = ' '      

        WHERE
            zob.d_e_l_e_t_ = ' '	
			and zam_filial = %xFilial:ZAM% 				
			and zob_msemp = %Exp:cEmpAnt%
            and zob_contrt = %exp:ZAM->ZAM_CONTRT%	

    ENDSQL
	
	while OBJ->(!eof())
		aadd(aBrowse,{obj->status,obj->nome,obj->codobj,obj->descricao,obj->NOME_TRANSPORTADOR,'',dToC(CTOD(obj->data_saida)),dToC(CTOD(obj->data_retorno)),dToC(CTOD(obj->data_recebimento)),''})	
		OBJ->(dbskip())	
	enddo

	OBJ->(dbclosearea())
return

Static Function VisuObj()

	ZOB->(dbsetorder(1))
	if ZOB->(dbseek(xFilial("ZOB")+aBrowse[oGride:nAT,3]))
		U_ZOBVISU()
	endif

return

User function MORA934X()
	Local oCts := NIL

	oCts := GvCtsReceber():New( 'PLANO' )
	oCts:ReprocessaCompensacao( ZAM->ZAM_CONTRT, ZAM->ZAM_CODCLI, 'PLANO' )
Return


/*/{Protheus.doc} User Function valPgto
	Valida pagamento do contrato
	@type  User Function
	@author Kleyson Gomes
	@since 28/02/2023
	@version version
	@return boolean
	/*/
User Function vPgtoZAM()
	
	BeginSql alias 'QRYSE1'

	Select count(*) as qtd
	from %table:SE1% se1
	where se1.e1_filial = %xFilial:SE1%
		and se1.e1_contrt = %exp:ZAM->ZAM_CONTRT%
    and se1.e1_prefixo = 'CON'
		and se1.e1_vencori <> ' ' 
		and se1.e1_baixa <> ' '
		and se1.e1_saldo = 0
		and se1.d_e_l_e_t_ = ' '
	EndSql

	If QRYSE1->QTD > 0
		QRYSE1->(dbCloseArea())
		Return .F.
	EndIf

	QRYSE1->(dbCloseArea())

Return .T.
