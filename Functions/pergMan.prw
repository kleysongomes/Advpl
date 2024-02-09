/*{Protheus.doc} pergMan
  @type  User Function
  @author Kleyson Gomes
  @since 18/10/2023
  @version 12.33
  @param cContrt caracter, geraManu Boolean
  Rotina para validação e perguntas para preenchimento dos dados da manutenção
  @return boolean
*/
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
