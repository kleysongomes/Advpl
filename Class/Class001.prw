#include 'protheus.ch'
#include 'totvs.ch'
#Include 'rwmake.ch'
#INCLUDE "topconn.ch"
#include "tbicode.ch"
#include "tbiconn.ch"
#include "msgraphi.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "FONT.CH"

/*/{Protheus.doc} ContratoJazigo
(long_description)
@author leonardo.freitas
@since 07/06/2017
@version 1.0
@example
(examples)

@see (links_or_references)
/*/
class ContratoJazigo 

	DATA cContrt
	DATA cCodCli
	DATA cNomCli
	DATA cStatus
	DATA nRecno

	method new() constructor 
	method geraManutencao()
	method trocaModalidade()
	method ativarcontrato()
	method getParcelamento()

endclass

/*/{Protheus.doc} new
Metodo construtor
@author leonardo.freitas
@since 07/06/2017 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new() class ContratoJazigo
return self

/*/{Protheus.doc} pergMan
  @type  User Function
  @author Kleyson Gomes
  @since 18/10/2023
  @version 12.33
  @param cContrt caracter, geraManu Boolean
  Rotina para validação e perguntas para preenchimento dos dados da manutenção
  @return boolean
/*/
user function pergMan(cContrt, lGeraManu, lpDep)
	local aBox 		:= {}
	local aRet 		:= {}
	local lTudOk 	:= .F. /*Retorno da rotina para seguir com a geração da manutenção ou não*/
	local cCodMan 
	local nVlrPm 
	local cDtPrim
	local cFormaPg
	local cOpcPg
	local cDiaPag

	if !empty(cContrt) 

		cQuery := "Select * from " + RetSqlName("SE1") + " where e1_contrt = '" + cContrt +"' "
		cQuery += " and e1_filial = '" + xFilial("SE1") +"' and e1_prefixo = 'MAN' and e1_situaca <> 'Z' and d_e_l_e_t_= ' ' "
		
		TcQuery cQuery New Alias "QRYMAN"

		if QRYMAN->(eof()) /*Valida se existe manutenção gerada*/

			if lpDep .or. lGeraManu /*Valida se não tem sepultado ou se veio da rotina manual do financeiro*/

				ZC0->(dbsetorder(1))
				if ZC0->(dbseek(xFilial('ZC0') + cContrt))

					BeginSql alias 'qry_codjaz'

						Select sb1.b1_prodpai as prodpai
						From %table:SB1% sb1
						Where sb1.d_e_l_e_t_ = ' '
						and sb1.b1_filial = %exp:zc0->zc0_filial%
						and sb1.b1_cod = %exp:zc0->zc0_codjaz%

					EndSql

					if empty(qry_codjaz->prodpai)
						MsgInfo('O produto de jazigo não possui produto de manutenção associado! Procure o setor de Marketing para corrigir o cadastro.')
						MsgInfo('Não é possível gerar manutenção!')
						return lTudOk
					endif

					cCodMan := qry_codjaz->prodpai
					qry_codjaz->(dbclosearea())

					BeginSql alias 'qry_prodpai'

						Select sb1.b1_prv1 as prv1
						From %table:SB1% sb1
						Where sb1.d_e_l_e_t_ = ' '
						and sb1.b1_filial = %exp:zc0->zc0_filial%
						and sb1.b1_cod = %exp:cCodMan%

					EndSql

					if empty(qry_prodpai->prv1)
						MsgInfo('Não foi possível ler os dados do produto de manutenção. Não é possível gerar manutenção')
						return lTudOk
					endif

					nVlrPm := qry_prodpai->prv1
					qry_prodpai->(dbclosearea())

					aAdd(aBox,{1,"Produto.....:"				,cCodMan,"","","",".F.",0,.T.}) 																											/*mvpar01*/
					aAdd(aBox,{1,"Valor",nVlrPm,"@E 9,999.99","","",".F.",20,.T.}) 																																				/*mvpar02*/
					aAdd(aBox,{1,"1o Vencimento"				,Ctod(Space(8)),"","","","",50,.T.}) 																											/*mvpar03*/
					aAdd(aBox,{1,"Forma cobrança:"			,Space(3),"","ExistCpo('SX5','ZZ' + MV_PAR04) .and. U_FCHKFPG(MV_PAR04)","ZZ","",0,.T.}) 	/*mvpar04*/
					aAdd(aBox,{1,"Opção de Pagamento "	,Space(3),"","ExistCpo('SX5','ZY' + MV_PAR05) .and. U_FCHKFPG(MV_PAR04)","ZY","",0,.T.}) 	/*mvpar05*/
					aAdd(aBox,{1,"Dia do Pagamento:"		,Space(2),"","","","",0,.T.}) 																														/*mvpar06*/
					
					if !ParamBox(aBox, "Geração de Manutenção", @aRet,,,.T.,,,,"",.F.,.F.)
						QRYMAN->(dbclosearea())
						return lTudOk
					endif

					cDtPrim 	:= mv_par03
					cFormaPg 	:= mv_par04
					cOpcPg 		:= mv_par05
					cDiaPag		:= mv_par06

					d30dias := Daysum(ddatabase,30)
					d45dias := Daysum(ddatabase,45)
					
					if cDtPrim >= d30dias .and. cDtPrim <=d45dias
						if !empty(cCodMan) .and. !empty(nVlrPm) .and. !empty(cDtPrim) .and. !empty(cFormaPg) .and. !empty(cOpcPg) .and. !empty(cDiaPag)

							Begin Transaction
								Reclock("ZC0",.F.)
									ZC0->ZC0_CODMAN := cCodMan
									ZC0->ZC0_VALMAN := nVlrPm 
									ZC0->ZC0_DTPRIM := cDtPrim 	   									/*Primeiro vencimento da manutencao*/
									ZC0->ZC0_FPGMAN := cFormaPg	   									/*Forma de pagamento (CAR,BOL, FOL )*/
									ZC0->ZC0_OPCPAG := cOpcPg      									/*Opcao de pagamento: 01, mensal,03-trimestral,...*/
									ZC0->ZC0_TIPEND := 'R'           								/*Tipo de endereco*/
									ZC0->ZC0_MESREF := Substr(Dtos(cDtPrim),5,2)   	/*Mes de referencia para reajuste de mensalidades anual*/
									ZC0->ZC0_GERMAN := 'S' 													/*gerar manutencao*/
									ZC0->ZC0_DIATXM := val(cDiaPag)
								ZC0->(Msunlock()) 
							End Transaction

							lTudOk := .T.
						else 
							MsgInfo('Para a geração é necessário o preechimento de todos os parâmetros.')
						endif	
					else 
						MsgInfo('A data precisar ser MAIOR que 30 dias da data de hoje e MENOR que 45 dias.')
					endif		
				else
					MsgInfo('Contrato não localizado, processo cancelado.')
				endif
			else 
				MsgInfo('Contrato já possui sepultado, geração de manutenção será pulada.')
				lTudOk := .T.
			EndIf
		else
			MsgInfo('Contrato já possui manutenção gerada.')
			lTudOk := .T.
		endif
	else
		MsgInfo('Parametro CONTRATO não recebido.')
	endif
	
	QRYMAN->(dbclosearea())

return lTudOk

/*/{Protheus.doc} new
Gera manutenï¿½ï¿½o
@author leonardofreitas
@since 01/10/2018
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method geraManutencao(cContrt) class ContratoJazigo
	local cCodMan  := ""
	local nVlrMan  := 0
	local cFormaPg := ""
	local cOpcPg   := ""
	local lGeraFin := .T.
	local dDtPrim
	local lRet    := .T.
	local g_p
	
	//Quantidade de parcelas para carne
	nQtdP := SuperGetMv('MS_QTDMAN',.F.,'')

	//Reserva numero do codigo do lote
	cCodLote := GetSX8Num('ZCB', 'ZCB_CODLOT')

	sb1->(dbsetorder(1))//b1_filial+b1_cod

	ZC0->(dbsetorder(1))
	if ZC0->(dbseek(xFilial('ZC0') + cContrt))

		//Para contratos posssuem informacao de manutenção
		if !empty(ZC0->ZC0_CODMAN)
			dDtPrim  := ZC0->ZC0_DTPRIM //Preenche data da manutencao
			cCodMan  := ZC0->ZC0_CODMAN //Preenche o codigo da manutencao
			nVlrMan  := ZC0->ZC0_VALMAN //Preenche valor da manutencao
			cFormaPg := ZC0->ZC0_FPGMAN //Preenche a forma de pagamento
			cOpcPg 	 := ZC0->ZC0_OPCPAG //Preenche a Opcao de pagamento

		//Para contratos que nao tem informações, gerar as manutencoes trimestrais
		Else
			dDtPrim  := MonthSum(ddatabase,1) //Preenche data da manutencao
			cCodMan  := Posicione("SB1", 1, xFilial("SB1") + ZC0->ZC0_CODJAZ,"B1_PRODPAI") //Preenche o codigo da manutencao
			nVlrMan  := Posicione("SB1", 1, xFilial("SB1") + cCodMan,"B1_PRV1")//Preenche valor da manutencao
			cFormaPg := 'BOL' //Preenche a forma de pagamento
			cOpcPg 	 := '03' //Preenche a Opcao de pagamento	
		Endif

		/*if empty(alltrim(cCodMan))
			lGeraFin	:= .F.
			lIncSE1		:= .F.
		endif*/

		cDescricao := 'Processo de Liberação de Quadra Construída: '+ time()  + Chr(10) + Chr(13)

		if lGeraFin
			nQtdP_	:= IIf(cFormaPg=='CAR',nQtdP,1)
			lFaixa	:= .F.
			cOpcPag	:=	If(cFormaPg=='CAR','01',cOpcPg)
			If cFormaPg=='CAR'
				nVlrP		:= nVlrMan
				nVlrPm	:= nVlrMan
			Else
				nVlrP		:= nVlrMan*Val(cOpcPag)
				nVlrPm	:= nVlrMan
			Endif

			cNumPar	:= GetSX8Num('SE1','E1_NUM')
			ConfirmSX8()	
					
			ZEM->(dbsetorder(1))
			ZEM->(Dbseek(xFilial("ZEM") + cFormaPg + cOpcPag))
			If ZEM->(Found())
				nDiaDesc := 5         		//Dias de desconto permitido para recebimento no assistente de baixa e CNAB
				nDescFin := ZEM->ZEM_DESC  //nDescFin recebe o valor do percentual de desconto do parametro
			Else
				nDiaDesc := 0         		//Dias de desconto permitido para recebimento no assistente de baixa e CNAB
				nDescFin := 0
			Endif
					
			cParc 	:= '  '
			
			cNatureza	:= POSICIONE('SB1',1,xFilial('SB1') + cCodMan, 'B1_NATUREZ')
			
			//cDia	:= U_FDiaData(iif(empty(zc0->zc0_dtsegv), ZC0->ZC0_DIATXM, Val(substr(dtos(ZC0->ZC0_DTSEGV), 7, 2))),Substr(Dtos(dDtPrim),5,2),Substr(Dtos(dDtPrim),1,4))
			cDia 	:= Val(Substr(Dtos(dDtPrim),7,2))
			nMes	:= Val(Substr(Dtos(dDtPrim),5,2))
			nAno	:= Val(Substr(Dtos(dDtPrim),1,4))
					
			aMeses	:= {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}
					
			cHist	:= ''
			nMesP	:= 0
			nAnoP	:= 0
			nAnoP	:= nAno
			nMesP	:= nMes

			if cFormaPg <> 'CAR' .and. cOpcPag <> '01'
				cHist += aMeses[nMesP]+"/"+substr(Strzero(nAnoP,4),3,2)+ " a "
				nMesP := ((nMes + val(cOpcPag)) -1 )

				if nMesP > 12
					nMesP := nMesP - 12
					nAnoP++
				elseIf nMesP == 0
					nMesP := nMes
				endif

				cHist += aMeses[nMesP]+"/"+substr(Strzero(nAnoP,4),3,2)
			else
				cHist += aMeses[nMes]+"/"+Strzero(nAno,4)
			endif

			lGerParc := .T.
				
				if lGerParc
					cDescricao += 'Parcelas de manutencao geradas: '  + Chr(10) + Chr(13)
					cDescricao += replicate('-',80)
					For g_p:= 1 to nQtdP_
						if nQtdP_ > 1
							cParc := StrZero(g_p,2)
							nMes++

							if nMes > 12
								nMes := 1
								nAno++
							endif

							cDia  := U_FDiaData(cDia, strzero(nMes,2), strzero(nAno,2))
							dVenc	:= sTod(strzero(nAno,4)+Strzero(nMes,2)+strzero(cDia,2))
						else
							dVenc	:= sTod(strzero(nAno,4)+Strzero(nMes,2)+strzero(cDia,2))
						endif

						IncProc('Gerando Vencimento: '+Dtoc(sTod(Substr(Dtos(dDtPrim),1,6)+strzero(cDia,2)))+' contrato: '+ZC0->ZC0_CONTRT)
						
						cChvSE1 := ZC0->ZC0_CONTRT+space(09)+Dtos(dVenc)
						
						//Variavel logica que vai retornar se foi encontrado vencimentos de manutencao no SE1
						BeginSql alias 'Parcelas'
						Select count(*) quantidade
							From %Table:SE1% se1
						Where se1.e1_filial = %xFilial:SE1%
					  		and se1.e1_contrt = %Exp:ZC0->ZC0_CONTRT%
					  		and se1.e1_prefixo = 'MAN'
							and se1.e1_vencto = %Exp:Dtos(dVenc)%
					  		and not ( se1.e1_situaca = 'Z' and se1.e1_ocorren = '02' )
					  		and se1.%notdel%
						EndSql

						lEncSE1 := ( Parcelas->quantidade > 0 )
						parcelas->(dbCloseArea())

						//Variavel logica que retorna se o registro foi incluido no SE1 com sucesso
						cDtPrim	:=	dVenc
						   
						If cFormaPg =='CAR' .and. lEncSE1
							g_p += nQtdP_
						Endif
						
						If !lEncSE1
							//Funcao que vai checar se a variavel cNumPar existe para
							//alguma mensalidade de manutencao na parcela indicada em
							//cParc
							cNumpar := U_fchkDpSE1(ZC0->ZC0_FILIAL,'MAN',cNumpar,cParc,'DP ')
							
							//Funcao que vai gerar as parcelas no financeiro de manutencao	
							lIncSE1 := U_fGSE1F603(ZC0->ZC0_FILIAL,cNumPar,cParc,cNatureza,ZC0->ZC0_CODCLI,ZC0->ZC0_LOJA,ZC0->ZC0_CONTRT,dDataBase,ZC0->ZC0_CODVEN,dVenc,cCodLote,nVlrP,'MAN',cHist,'N',cCodMan,nDiaDesc,nDescFin,cOpcPag)
							
							//Gera historico de geracao de parcelas
							cDescricao += "  MAN" + alltrim(cNumPar) + alltrim(cParc) + Chr(10) + Chr(13)
							
						Else
							lIncSE1 := .F.
						endif

						Dbselectarea("ZC0")
					Next g_p
				
				endif

		else
			cDescricao += "Parcelas de manutençao não gerado para este contrato! "  + Chr(10) + Chr(13)
			lRet    := .F.
		endif

		u_fGerHistC(ZC0->ZC0_CONTRT,'ZC0',ZC0->ZC0_CODCLI,ZC0->ZC0_LOJA,"",'0003',ZC0->ZC0_CONTRT,cDescricao,.F.,.F.)

		if lIncSE1 .and. lGeraFin
			Reclock("ZC0",.F.)
				ZC0->ZC0_CODMAN := cCodMan
				ZC0->ZC0_VALMAN := nVlrPm 
				ZC0->ZC0_DTPRIM := cDtPrim 	   //Primeiro vencimento da manutencao
				ZC0->ZC0_FPGMAN := cFormaPg	   //Forma de pagamento (CAR,BOL, FOL )
				ZC0->ZC0_OPCPAG := cOpcPg      //Opcao de pagamento: 01, mensal,03-trimestral,...
				ZC0->ZC0_TIPEND := 'R'           //Tipo de endereco
				ZC0->ZC0_MESREF := Substr(Dtos(cDtPrim),5,2)   //Mes de referencia para reajuste de mensalidades anual
				ZC0->ZC0_DIATXM := cDia//Val(substr(Dtos(ZC0->ZC0_EMISSA), 7, 2))        //Dia do vencimento do contrato
				ZC0->ZC0_GERMAN := 'S' 									//gerar manutencao
			ZC0->(Msunlock())  
			
			//Codigo diferencial + Ano YYYY + Mes MM + Dia DD = ????20180323
			cIdLote := "ATRI"  + dToS(dDataBase)
			
			ZCB->(RecLock('ZCB',.T.))
				ZCB->ZCB_FILIAL		:= xFilial('ZCB')
				ZCB->ZCB_CODLOT 	:= cCodLote
				ZCB->ZCB_DTLOTE  	:= dDataBase
				ZCB->ZCB_CONTRI 	:= ZC0->ZC0_CONTRT
				ZCB->ZCB_CONTRF 	:= ZC0->ZC0_CONTRT
				ZCB->ZCB_PERCEN 	:= 0
				ZCB->ZCB_CONDPG 	:= cOpcPg
				ZCB->ZCB_STATUS		:= '1'
				ZCB->ZCB_TIPO		:= '3'  //Atribuição de endereço por liberação de quadra
				ZCB->ZCB_IDLOTE		:= cIdLote
				ZCB->ZCB_MESREF		:= StrZero(Month(dDataBase),2) + StrZero(Year(dDataBase),4)
				ZCB->ZCB_VENCTO 	:= dVenc
				ZCB->ZCB_VLRANT 	:= ZC0->ZC0_VALMAN //Valor anterior Manutenção
				ZCB->ZCB_FPGMAN		:= ZC0->ZC0_FPGMAN
				ZCB->ZCB_FPGJAZ		:= ZC0->ZC0_FPGJAZ
				ZCB->ZCB_HORA   	:= Time()				
			ZCB->(MsUnLock())
			
			// RecLock('ZCF',.T.)
			// 	ZCF->ZCF_FILIAL		:=	xfilial("ZCF") 
			// 	ZCF->ZCF_CODLOT		:=	cCodLote
			// 	ZCF->ZCF_MESREF		:=	Substr(Dtos(cDtPrim),5,2)
			// 	ZCF->ZCF_CONTRT		:=	ZC0->ZC0_CONTRT
			// 	ZCF->ZCF_VENCTO		:=	dVenc
			// 	ZCF->ZCF_USUARI		:=	cUserName
			// 	ZCF->ZCF_HORA		:=	time()
			// 	ZCF->ZCF_DATA		:=	ddatabase
			// ZCF->(MsUnlock())
		
		else
			Reclock("ZC0",.F.)
				ZC0->ZC0_TIPEND := 'R'           //Tipo de endereco
				ZC0->ZC0_GERMAN := 'N' 									//gerar manutencao
			ZC0->(Msunlock())  
			
		endif  

	else
		MsgInfo('Contrato nao localizado, processo cancelado')
		return .F.	
	endif

return .T.


/*/{Protheus.doc} User Function TrocaModalidade
		Rotina que irá gerar o valor de diferença do contrato de cemitério
	@type  Function
	@author PauloSouza
	@since 12/08/2021
	@version 12.1.25
	@param cContrato, character, Contrato que dará inicio a geração da diferença/*/
Method trocaModalidade( cContrato ) Class ContratoJazigo
	Default cContrato := zc0->zc0_contrt

	/*Caso seja chamado por outra rotina e o contrato não esteja setado*/
	If ZC0->ZC0_CONTRT == NIL .or. Alltrim(ZC0->ZC0_CONTRT) != Alltrim(cContrato)
		ZC0->( dbSetorder(1) )
		If !ZC0->( dbSeek( xFilial("ZC0") + cContrato ) )
			MsgInfo("Não foi possível localizar o contrato", "Verificação de contrato de entrada")
			Return 
		EndIf
	EndIf
	/*-----------------------------------------------------------------*/

	/* Só permite continuidade em contratos ativos */
	If Zc0->Zc0_status != '1'
		MsgInfo("Contrato não esta ativo", "Verificação de status")
		Return .F.
	EndIf

	/* Contrato faz a troca quando esta dentro do periodo de Carência */
	if Daysum( zc0->zc0_emissa, 30 ) < dDataBase 	
		MsgInfo("Contrato já passou do periodo futuro","Verificação de emissão")
		Return .F.
	EndIF

	/* Verifica se já houve sepultado no contrato, portanto não sendo mais futuro */
	zc2->( DbSetOrder( 1 ) )
	If zc2->( dbSeek( xFilial("ZC2") + zc0->zc0_Contrt ) )
		MsgInfo("Já existe sepultado no contrato selecionado","Verificação de sepultados")
		Return .F.
	EndIf

	nDiferenca := abs(ZC0->ZC0_VALJAV - ZC0->ZC0_VALJAZ)
	nFinalDiff := nDiferenca
	nFinalDiff := noRound( nFinalDiff, 2 )
	
	/*Tela de confirmação dos valores a ser gerado*/
	lGerar := .F.
	oMain	:= TDialog():New(0,0,200,300,'Memória de cálculo',,,,,CLR_GRAY,CLR_WHITE,,,.T.) 
		oPanel	:= TPanel():New(01,01,"",oMain,,.T.,,CLR_GRAY,CLR_WHITE,100,100)
		oPanel:Align  := CONTROL_ALIGN_ALLCLIENT

			oTFinal := TButton():New( 130, 229, "Gerar diferença",oPanel,{|| lGerar := .T., oMain:End() }, 150,20,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTFinal:SetCss("QPushButton{ background-color: #3399FF; color: white}")
			oTFinal:Align := CONTROL_ALIGN_BOTTOM

			oGroup := TGroup():New(02,02,130,130,'Valores',oPanel,,,.T.)
			oGroup:Align  := CONTROL_ALIGN_ALLCLIENT
			TSay():New(12,05,{||'<Strong>Valor do contrato futuro:</Strong> R$ ' + Transform( ZC0->ZC0_VALJAZ, "@E 999,999.99") },oPanel,,,,,,.T.,,,120,10,,,,,,.T.)
			TSay():New(24,05,{||'<Strong>Valor de tabela:</Strong> R$ ' + Transform( ZC0->ZC0_VALJAV, "@E 999,999.99") },oPanel,,,,,,.T.,,,120,10,,,,,,.T.)
			TSay():New(48,05,{||'<Strong>_____________________________________________</Strong>'},oPanel,,,,,,.T.,,,120,10,,,,,,.T.)
			TSay():New(60,05,{||'<font size="4" color="green"><Strong>Diferença a ser gerada:</Strong> R$</font>'},oPanel,,,,,,.T.,,,90,10,,,,,,.T.)
			
			oContrato := TGet():Create( oPanel,{|u| If(PCount()>0,nFinalDiff:=u,nFinalDiff)},60,100,040,010,"@E 99999999.99",{||},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"","nFinalDiff")
	oMain:Activate(,,,.T.)
	/*--------------------------------------------*/

	If lGerar
		FWMsgRun(, {|oSay| GerarTitulo( nFinalDiff ) }, "Aguarde", "Gerando título de diferença")
	Endif

Return 

Static function GerarTitulo( nFinalDiff )
	oFinanceiro := GvCtsReceber():New("CEMITERIO")
	
	jTitulo := JsonObject():New()
	jTitulo['PREFIXO'] 		:= "VEN"
	jTitulo['TIPO']			:= "DP"
	jTitulo['PARCELAS']		:= 1
	jTitulo['CLIENTE']		:= zc0->zc0_codcli
	jTitulo['VENCIMENTO']	:= Daysum( dDataBase, 15 )
	jTitulo['VALOR']		:= nFinalDiff
	jTitulo['CONTRATO']		:= zc0->zc0_contrt	
	jTitulo['NUMCART']		:= ""
	jtitulo['LOTE']			:= "DIFF" + dToS( dDataBase )

	oFinanceiro:CriarTitulo( @jTitulo )

	If jTitulo['STATUS']
		cDescricao := "--Troca de futuro para imediato--" +  CRLF
		cDescricao += "Parcela de diferença gerada pela troca de modalidade, de Uso Futuro para Uso Imediato" + CRLF
		cDescricao += "Valor do contrato futuro: R$ " + Transform( ZC0->ZC0_VALJAZ, "@E 999,999.99") + CRLF
		cDescricao += "Valor de tabela: R$ " + Transform( ZC0->ZC0_VALJAV, "@E 999,999.99") + CRLF
		cDescricao += "Valor de entrada: R$ " + Transform( ZC0->ZC0_VLRENT, "@E 999,999.99") + CRLF
		cDescricao += "Valor de diferença: R$ " + Transform( (ZC0->ZC0_VALJAV - ZC0->ZC0_VALJAZ), "@E 999,999.99") + CRLF
		cDescricao += Replicate('-',50) + CRLF
		If abs( (ZC0->ZC0_VALJAV - ZC0->ZC0_VALJAZ) - nFinalDiff ) > 0 
			cDescricao += "Desconto concedido: R$ " + Transform( abs( (ZC0->ZC0_VALJAV - ZC0->ZC0_VALJAZ) - nFinalDiff ), "@E 999,999.99") + CRLF

			aBox := {}
			aRet := {}
			aAdd(aBox,{11,"Informe o motivo do desconto","",".T.",".T.",.T.})
			If !ParamBox(aBox," Motivo da alteração ",@aRet)
				Return .F.
			EndIf

			cDescricao += "Motivo: " + MV_PAR01 + CRLF
		EndIf
		cDescricao += Replicate('-',50) + CRLF
		cDescricao += "Valor final gerado: R$ " + Transform(nFinalDiff, "@E 999,999.99") + CRLF

		u_fGerHistC(ZC0->ZC0_CONTRT,'ZC0',ZC0->ZC0_CODCLI,ZC0->ZC0_LOJA,"",'0003',ZC0->ZC0_CONTRT,cDescricao,.F.,.F.)

		ZC0->( Reclock("ZC0", .F.) )
			ZC0->ZC0_VALJAZ := ZC0->ZC0_VALJAZ + nFinalDiff
			ZC0->ZC0_VLRENT := ZC0->ZC0_VLRENT + nFinalDiff 
		ZC0->(MsUnlock())		
	Else
		MsgInfo(jTitulo['ERRO'], jTitulo['MSG'])
		Return .F.
	EndIf
Return .T.

Method ativarcontrato(cContrt, nVlrJaz, nVlrEnt, nQtdParc, dSegVenc, nDiaVenc, cFormCob, cEmpAsso) Class ContratoJazigo

	Local aCondicao 	:= {}
	Local cPrefSE1  	:= ''
	local c_p, i_p		:= 0
	local cNatureza 	:= ''
	local aCond     	:= {}
	local cMsg_		 		:= ''
	local cHistMens 	:= ''
	local nDiaDesc  	:= 0
	local nDescFin	 	:= 0
	local lAvista			:= .F.

	default nVlrJaz := ""

	ZC0->(dbsetorder(1))
	if !ZC0->(dbseek(xFilial('ZC0') + cContrt))
		MsgInfo('Contrato não localizado.')
		return .F.
	endif

	if empty(nVlrJaz)
		nVlrJaz := posicione('SB1', 1, xFilial('SB1') + ZC0->ZC0_CODJAZ, 'B1_PRV1')
	endif

	If ZC0->ZC0_STATUS == '1'
		MsgInfo('Contrato já se encontra ativo.')
		Return .F.
	EndIf

	If ZC0->ZC0_STATUS == '2'
		MsgInfo('Contrato não pode ser ativado! Pois está cancelado!')
		Return .F.
	EndIf

	/* 
		Validação contrato do CLIENTE MORADA (Planos com benefício de produtos do Cemitério)
		VALIDAÇÃO APENAS PARA PE
	*/
	If cEmpAnt == '05'
		If ALLTRIM(GetMv('MS_CLIMORA')) == ALLTRIM(ZC0->ZC0_CODCLI)
			If !MsgNoYes("Contrato Cliente Morada. Deseja ativar sem Movimentação Financeira?")
				MsgInfo('Ativação cancelada.')
				Return .F.
			Else
				cMsgH := "Ativação do contrato: " + ZC0->ZC0_CONTRT + " (CLIENTE MORADA) "	+ chr(10) + chr(13) + chr(10) + chr(13)
				cMsgH += "*** Não foi gerada movimentação financeira ***"

				Begin Transaction
					RecLock('ZC0',.F.)
						ZC0->ZC0_STATUS := '1'
						ZC0->ZC0_DTATIV 	:= dDatabase
					ZC0->(MsUnLock())
					
					u_fGerHistC(ZC0->ZC0_CONTRT,'ZC0',ZC0->ZC0_CODCLI,ZC0->ZC0_LOJA,ZC0->ZC0_CODJAZ,'0001',ZC0->ZC0_CONTRT,cMsgH,.F.,.F.)

				End Transaction

				MsgInfo('Contrato ativado sem Movimentação Financeira.')
				Return .T.
			Endif
		Endif
	Endif

	/*
	 * Caso for contrato UNICO irá chamar a função CONTUNI e não irá gerar financeiro
	*/
	If (((cEmpAnt == '03' .and. cFilAnt == '04') .or. (cEmpAnt == '07' .and. cFilAnt == '04')) .and. ZC0->ZC0_PROTOC <> ' ') .or. alltrim(ZC0->ZC0_CODCLI) == '110967'
		If CONTUNI(cTipo_)
			Return .T.
		Else
			Return .F.
		EndIf
	EndIf
	
	/*
	* Validação de data do segundo vencimento
	*/
	If (dSegVenc - ZC0->ZC0_EMISSA) < 27
		MsgInfo("<b><font color='Red'>O intervalo entre ativação e o vencimento é menor que 27 dias!</font></b>","Aviso - Range de Data Invalido")
		return .F.
	EndIf
	
	if ((dSegVenc - ZC0->ZC0_EMISSA) > 55)
		MsgInfo("<b><font color='Red'>O intervalo entre ativação e o vencimento é maior que 55 dias!</font></b>","Aviso - Range de Data Invalido")
		return .F.
	EndIf

	Dbselectarea("SE4")
	Dbsetorder(2)
	Dbseek(xFilial("SE4") + Strzero(nDiaVenc,2)+"X"+Strzero(nQtdParc,3))
	If !Found()
		
		Do While .T.
			cCondPg := Alltrim(GetSX8Num('SE4','E4_CODIGO'))
			
			SE4->(Dbsetorder(1))
			SE4->(Dbgotop())
			SE4->(Dbseek(xFilial("SE4")+cCondPg))
			If !Found()
				Reclock("SE4",.T.)
					E4_FILIAL := xFilial("SE4")
					E4_CODIGO := cCondPg
					E4_TIPO   := '3'
					E4_COND   := alltrim(str(nQtdParc,3))+",0,"+alltrim(str(nDiaVenc,2))
					E4_DESCRI := Strzero(nDiaVenc,2)+"X"+Strzero(nQtdParc,3)
					E4_FORMA  := 'DP'
					E4_ACRES  := 'N'
				Msunlock()
				Exit
			Endif
			ConfirmSX8()
		Enddo
	Else
		cCondPg := SE4->E4_CODIGO
	Endif

	//Pega a natureza a partir do cadastro de produtos
	cNatureza	:= alltrim(posicione('SB1', 1, xFilial('SB1') + ZC0->ZC0_CODJAZ, 'B1_NATUREZ'))

	if empty(cNatureza)
		MsgAlert("Natureza do produto " + alltrim(ZC0->ZC0_CODJAZ) + " não localizado, favor entrar em contato com o setor de Suprimentos!")
		return .F.
	endif

	//Calcula valor da parcela
	If nValorJaz == nVlrEnt
		nVlrTit := nVlrEnt
		nTotPar := nVlrEnt
		nResDiv := 0
		lAvista := .T.
	Else
		nVlrTit := (nValorJaz - nVlrEnt)
		nTotPar := round((nValorJaz - nVlrEnt) / nQtdParc,2)
		nResDiv := (nValorJaz - nVlrEnt) - (nTotPar * nQtdParc)
	EndIf
	nQtdeP  := nQtdParc
	dDataPar:= firstday(dSegVenc)
	
	if alltrim(cFormCob) == 'BO'
		cTabAut 	:=  ''
		aRet := {}
		aParamBox := {}
		aCombo := {"Diretoria","Ger.Regional","Ger.Operacional"}
	
		/*
		* pergunta para validacao de forma de pagamento boleto
		* Tipo da Autorizacao: Diretoria ou Gerencia          
		*/
		aAdd(aParamBox,{3,"Selecione o Tipo de Autorização:",1,aCombo,50,"",.T.})
	
		ParamBox(aParamBox,"Autorização de Boleto",@aRet)
	
		If len(aRet) == 0
			MsgAlert('Operação cancelada!')
			lRet := .f.
		Endif
	
		nTipoAut := aRet[1]
	
		Do Case
			Case (aRet[1] == 1)
				cTabAut := "U0"
			Case (aRet[1] == 2)
				cTabAut := "U1"
			Case (aRet[1] == 3)
				cTabAut := "U3"
		EndCase
		
		//Limpa array para novas perguntas
		aRet := {}
		aParamBox := {}
	
		aAdd(aParamBox,{1,"Autorizado Por:",space(02),"@E 99","",cTabAut,"",2,.T.})
		aAdd(aParamBox,{11,"Observação (Máximo 250 Caracteres):","",".T.",".T.",.T.})
	
		ParamBox(aParamBox,"Autorização de Boleto",@aRet)
		
		//Se as perguntas forem canceladas retorn Falso
		If len(aRet) == 0
			MsgAlert("Operação cancelada!")
			Return .F.
		Endif
		
		//verifica se o email de autorizacao e valido
		SX5->(Dbsetorder(1))
		If !SX5->(Dbseek(xFilial("SX5") + cTabAut + aRet[1]))
			MsgInfo('Email de autorização inválido')
			Return .F.
		Else
			aDiasBol		:= &(GetMv('MS_DIASBOL')) 
			dDataPgto	:= ''
			nTipoAut := iif(nTipoAut > 2, (nTipoAut - 1), nTipoAut) // Faz menos um no tipo da autorizacao caso seja Gerencial 
			cEmlAut := Alltrim(SX5->X5_DESCRI)
			
			Reclock('ZC0',.F.)
				ZC0->ZC0_AUTBOL := Alltrim(SX5->X5_DESCRI)
			ZC0->(MsUnLock())
	
			//Altera data de vencimento do boleto de acordo com o tipo da autorizacao
			nDiasBol := val(aDiasBol[nTipoAut][2])
			If dDataPar != dDataBase + nDiasBol
				dDataPar := dDataBase + nDiasBol
			Endif

			MsgInfo("A data de vencimento foi alterada para: " + dtoc(dDataPar),"Data de Vencimento")
			
		Endif
		
	endif

	if nQtdParc == 1
		if Dtos(ZC0->ZC0_EMISSA) > Dtos(dSegVenc)
			MsgInfo('Por Ser um Pagamento a vista, o vencimento não pode ser menor que a emissão do contrato. Ativação cancelada!')
			Return .T.
		endif
	endif

	//Acrescentar na aCondicao o 1o Vencimento da primeira parcela
	If nVlrEnt > 0
		AADD(aCond,{ZC0->ZC0_EMISSA,{nVlrEnt}})
	Endif

	/*
	* Funcao retorna um array com a data das parcelas geradas de acordo 
	* com a condicao de pagamento especificada.                         
	*/
	If !empty(cCondPg)
		SE4->(dbSetorder(1))
		SE4->(dbseek(xFilial('SE4')+cCondPg))
		IF SE4->E4_TIPO == '3' .and. Alltrim(SE4->E4_CODIGO) == Alltrim(cCondPg)
			aCondicao := Condicao(nVlrTit,cCondPg,0,dDataPar,)
		Else
			aCondicao := Condicao(nVlrTit,cCondPg,0,dDataPar,)
		EndIf
	Else
		MsgInfo('Preencher condição de pagamento.')
		Return .F.
	EndIf
	
	if alltrim(cFormCob) == 'BO'
		aCondicao[1][1] := dDataPar
	endif

	if lAvista
		cMsg_:=	"<b><font color='blue'>Atenção " + AllTrim(PswRet(1)[1][4]) + "<br>Será gerada uma unica parcela no valor de R$ "+ Transform(nVlrTit,"@E 999,999.99") + "<br>Para pagamento até a data: " + dtoc(aCondicao[1][1]) + "<br><br>Confirma o procedimento?</font></b>"
	else
		cMsg_:=	'Atenção ' + AllTrim(cUserName) + ', será gerada a primeira parcela no valor de '+ cValToChar(Round(nVlrTit/nQtdeP,2) ) + " R$" + Chr(13)+ Chr(10)+ dtoc(aCondicao[1][1]) + ', Confirma?'
	endif

	if !MsgNoYes(cMsg_) 
		ApMsgInfo('Atribuição de lote cancelada!')
		Return .F.
	endif

	/*
	* Reserva numero do codigo do lote
	*/
	cCodLote := GetSX8Num('ZCB','ZCB_CODLOT')
	ConfirmSX8()

	cParc    := ''
	cParcDet := ''
	cCodPro  := ''

	/*
	* Matriz com todas as condicoes de pagamento do pagamento parcelado
  * aCondicao onde sera guardada em aCond->matriz contendo a 1a parcela
	* que se refere a entrada
	*/
	For c_p:=1 to Len(aCondicao)
		AADD(aCond,{aCondicao[c_p][1],{aCondicao[c_p][2]}})
	Next

	aCondicao := aCond
	cHistMsgM := ''

	ProcRegua(Len(aCondicao))
	Begin Transaction
	
		cNumPar := GetSX8Num('SE1','E1_NUM')
		ConfirmSX8()

		If left(ZC0->ZC0_CONTRT, 1) <> '9'
			If !U_MORA165I(ZC0->ZC0_CONTRT,ZC0->ZC0_CODVEN)
				DisarmTransaction()
				Return .F.
			EndIf
		EndIf

		For i_p := 1 To Len(aCondicao)
			If nValEnt > 0
				If i_p == 1
					cParc := '  '
				Else
					cParc := strzero(i_p-1,2)
				Endif
			Else
				cParc := strzero(i_p,2)
			Endif
	
			IncProc('Gerando parcela '+cParc+' Vencimento: '+Dtoc(aCondicao[i_p][1])+' do contrato: '+Alltrim(ZC0->ZC0_CONTRT))
	
			dVenc := aCondicao[i_p][1]
	
			nVlrP := aCondicao[i_p][2][1]

			cPrefSE1 := 'VEN'
			cCodPro  := ZC0->ZC0_CODJAZ

			Do While .T.
				Dbselectarea("SE1")
				Dbsetorder(1)
				Dbgotop()
				Dbseek(xFilial("SE1") + cPrefSE1 + cNumPar + cParc + 'DP ')
				If Found()
					cNumPar	:= GetSX8Num('SE1','E1_NUM')
					ConfirmSX8()
				Else
					Exit
				Endif
		
			Enddo

			If alltrim(cCondPg) == 'FOL'
				SA1->(Dbsetorder(1))
				IF SA1->(Dbseek(xFilial("SA1") + alltrim(cEmpAsso)))
					cCodCli_ := SA1->A1_COD
					cCodLoj_ := SA1->A1_LOJA
					cNomCli_ := SA1->A1_NREDUZ
				Endif
			Endif

			//Funcao que vai gerar as parcelas no financeiro seja de contrato ou manutencao
			lRet := U_fGSE1F603(xFilial("SE1"),cNumPar,cParc,cNatureza,ZC0->ZC0_CODCLI,ZC0->ZC0_LOJA,;
			                 ZC0->ZC0_CONTRT,ZC0->ZC0_EMISSA,ZC0->ZC0_CODVEN,;
											 dVenc,cCodLote,nVlrP,cPrefSE1,cHistMens,If(ZC0->ZC0_ORIVEN=='P','S','N'),;
											 ccOdPro,nDiaDesc,nDescFin,/*nOpPag*/ 1)
	
			If !lRet
				msginfo('A parcela de numero '+cParc+ ' nao foi gerada. Verificar os parametros!')
				Disarmtransaction()
				Return .F.
			Endif

			//Envia WF para pagamento em BO
			if alltrim(cFormCob) == 'BO'
				U_WORKFLBO(ZC0->ZC0_CONTRT, cEmlAut, nVlrEnt)
			endif
			
			cHistMsgM +=  cPrefSE1 + ' ' + cNumPar + ' ' + cParc + ' ' + 'DP' + ' ' +;
				'- ' + dtoc(dVenc) + ' R$ ' + Alltrim(Transform(nVlrP,'@E 999,999.99')) + chr(10) + chr(13)

		Next i_p

		RecLock('ZCB',.T.)
		ZCB->ZCB_FILIAL	:= xFilial('ZCB')
			ZCB->ZCB_CODLOT 	:= cCodLote
			ZCB->ZCB_DTLOTE  	:= dDataBase
			ZCB->ZCB_CONTRI 	:= ZC0->ZC0_CONTRT
			ZCB->ZCB_CONTRF 	:= ZC0->ZC0_CONTRT
			ZCB->ZCB_PERCEN 	:= 0
			ZCB->ZCB_CONDPG 	:= cCondPg
			ZCB->ZCB_STATUS		:= "1"

			If Alltrim(str(cTipo_)) == "1"//Ativação
				ZCB->ZCB_TIPO		:= "1"//Ativação é opção 1 e atribuição é opção 3
				ZCB->ZCB_MESREF		:= StrZero(Month(dDataBase),2) + StrZero(Year(dDataBase),4)
				ZCB->ZCB_VENCTO 	:= If( len(aCondicao) > 1, aCondicao[2,1], dVenc )   //Vencimento da segunda parcela
			Else
				ZCB->ZCB_TIPO		:= "3"//Ativação é opção 1 e atribuição é opção 3
				ZCB->ZCB_MESREF		:= Strzero(nMes,2) + cValToChar(nAno) 
				ZCB->ZCB_VENCTO 	:= aCondicao[1,1] //Vencimento da primeira parcela
			EndIf
			ZCB->ZCB_IDLOTE		:= "ATIV" + dToS(dDataBase)
			ZCB->ZCB_VLRANT 	:= ZC0->ZC0_VALMAN //Valor anterior Manutenção
			ZCB->ZCB_FPGMAN		:= ZC0->ZC0_FPGMAN
			ZCB->ZCB_FPGJAZ		:= ZC0->ZC0_FPGJAZ
			ZCB->ZCB_HORA   	:= Time()				
		ZCB->(MsUnLock())

		/*
			Gera Objeto para expedição
		*/
		cMsgH := "Ativação de contrato: "+ZC0->ZC0_CONTRT+" Lote de mensalidade gerado: "+cCodLote	+ chr(10) + chr(13)
		cMsgH += cHistMsgM

		nPercPerm	:=	10.00
		nPercCal	:=	0

		SA3->(dbsetorder(1))
		SA3->(Dbseek(xFilial("SA3")+ZC0->ZC0_CODVEN))
		cNomVen := SA3->A3_NOME

		cMensagem	:= "Comunicamos que o valor do jazigo vendido para o contrato <br> "
		cMensagem	+= "de numero : "+ZC0->ZC0_CONTRT+" Titular: "+ZC0->ZC0_NOMCLI+"  <br> "
		cMensagem	+= "vendedor: "+cNomVen+"  <br> "
		cMensagem	+= "sofreu alteracao de preco no ato da venda. Preco de tabela: "+alltrim(str(SB1->B1_PRV1,10,2))
		cMensagem += " para "+alltrim(str(nValorJaz,10,2))+"  <br> "

		cAssunto	:= "Preco de venda de jazigo a menor"
		cTo			:= ""
		cAnexos		:= ""
		cBcc			:= ""

		lRet := .T.

		nPercCal :=	((1 - nValorJaz/SB1->B1_PRV1))*100

		If	SB1->B1_PRV1 == 0
			ApMsgInfo('O valor de a vista do produto não está informado. Favor solicitar atualização do preço do produto no cadastro.')
			Alert('MORF603-Processo abortado!')
			Disarmtransaction()
			Return .F.
		Endif

		//Envia workflow para descontos maiores que o permitido
		If  nPercCal > nPercPerm
			U_WORKF603A(.F.)
		Endif

		//Altera as informações do contrato e ativa
		RecLock('ZC0',.F.)
			ZC0->ZC0_STATUS := '1'
			ZC0->ZC0_DTATIV 	:= dDatabase
			ZC0->ZC0_VALJAZ 	:= nValorJaz
			ZC0->ZC0_VALJAV 	:= SB1->B1_PRV1
			ZC0->ZC0_VLRENT 	:= nValEnt
			ZC0->ZC0_DTSEGV 	:= dSegVenc
			ZC0->ZC0_QTDEP  	:= nQtdParc
			ZC0->ZC0_FPGJAZ 	:= cFormCob
			If alltrim(cFormCob) == 'FOL'
				ZC0->ZC0_CLIFAT	:= cCodCli_
				ZC0->ZC0_LJFAT	:=	cCodLoj_
				ZC0->ZC0_NCLIFA	:= cNomCli_
			Endif
		ZC0->(MsUnLock())

		cMsgH += CRLF + Replicate("-",50) + CRLF
		cMsgH += "Id. do lote para Objetos : " + cIdLote + CRLF
			
		u_fGerHistC(cCodLote,'ZCB',ZC0->ZC0_CODCLI,ZC0->ZC0_LOJA,"",'0003',ZC0->ZC0_CONTRT,cMsgH,.F.,.F.)

	End Transaction

return .T.

Method getParcelamento(nVlrJaz, nVlrEnt, nQtdParc, cTpJazi, cFormCob) Class ContratoJazigo

	local nVlrParc := 0

	if SX5->(dbSeek(xFilial("SX5") + Padr("X1",len(SX5->X5_TABELA)," ") + xFilial("ZC0") + Padr(nQtdParc,2) + left(cTpJazi,1)))
		if ("CC" $ upper(alltrim(cFormCob)) .or. cEmpAnt == '05')
			nVlrParc := (nVlrJaz - nVlrEnt) / nQtdParc
		else
			nVlrParc := (nVlrJaz - nVlrEnt) * val(SX5->X5_DESCRI)
		endif
	else
		msgInfo("Opção de parcelamento não disponível.")	
	endif

return nVlrParc
