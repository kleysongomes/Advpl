#Include "Protheus.ch"
#include 'totvs.ch'
#include "FwmBrowse.ch"
#include "FWMVCDEF.CH"

/*{Protheus.doc} GeraDoc
	Coleta e prepara os dados para a DOC e impressão dos documentos 
  @type  User Function
  @author Kleyson Gomes
  @since 29/11/2022
	@version 12.33
  @return .T.
  */
User function GeraDoc()

	local aBox 						:= {}
	local aBox2 					:= {}
	local aRet  					:= {}
	Local nCont						:= 1
	Local lControler			:= .T.
	Local cCodEmp 				:= FWCodEmp()
	Local jDados					:= JsonObject():New()

	//Perguntas e coleta de dados
	aAdd(aBox,{3,"Tipo de Troca",0,{"VIDA","ADMINISTRATIVO", "DEFINITIVO"},50,,.T.})																				//MV_PAR01
	aAdd(aBox,{1,"Contrato" ,Space(6),"","","Table","",0,.T.}) 																				//MV_PAR02
	aAdd(aBox,{1,"Cod Cliente NOVO Titular" ,Space(6),"","","SA1","",0,.T.})												//MV_PAR03
	aAdd(aBox,{1,"Grupo Doc",Space(4),"", "", "SBM","",0,.T.}) 																			//MV_PAR04
	aAdd(aBox,{1,"Data Reg" ,Space(8),"@R 99/99/9999","","","MV_PAR01 = 2",0,.F.}) 						//MV_PAR05

		If !ParamBox(aBox,"Dados para troca",@aRet,{||validaAbox()})
			Return
		EndIf
	
	//Montando dados brutos no JSON
	jDados['cod_Contrt'] 					:= MV_PAR02
	jDados['cod_Titular'] 				:= Alltrim(Table->Table_CODCLI)
	jDados['nom_Titular']					:= Alltrim(Table->Table_NOMCLI)
	jDados['cpf_Titular']					:= transform(Table->Table_CGC, "@R 999.999.999-99")	
	jDados['end_Titular']					:= Capital(Alltrim(Table->Table_TLOG) + " " + alltrim(Table->Table_END) + ", " + (Table->Table_NUMERO) + ", " + alltrim(Table->Table_BAIRRO) + ", " + alltrim(Table->Table_MUNICI)) + "/" + alltrim(Table->Table_EST)
	jDados['cep_Titular']					:= transform(Table->Table_CEP, "@R 99.999-999")
	jDados['est_Titular']					:= alltrim(Table->Table_EST)
	jDados['dt_reg'] 							:= transform(MV_PAR05,"@R 99/99/9999")

	jDados['cod_NTitular'] 					:= MV_PAR03
	jDados['nom_NTitular'] 					:= Alltrim(SA1->A1_NOME)
	jDados['cpf_NTitular']					:= transform(SA1->A1_CGC, "@R 999.999.999-99")
	jDados['end_NTitular']					:= Capital(Alltrim(SA1->A1_TIPOLOG) + " " + Alltrim(SA1->A1_END) + ", " + (SA1->A1_NUMERO) + ", " + Alltrim(SA1->A1_BAIRRO) + ", " + Alltrim(SA1->A1_MUN)) + "/" + Alltrim(SA1->A1_EST)
	jDados['cep_NTitular']					:= transform(SA1->A1_CEP, "@R 99.999-999")

	jDados['grp_doc']						:= MV_PAR04
	jDados['tp_troca']						:= MV_PAR01

		if jDados['tp_troca'] = 1
			jDados['num_RGTitular'] := Alltrim(SA1->A1_PFISICA)
			jDados['Emi_RGTitular'] := Alltrim(SA1->A1_ORGEMIS)
			jDados['tex_DOc']				:= "Doc gerada para realização do processo de troca de titularidade entre o antigo titular " + jDados['nom_Titular'] + " e o novo titular " + jDados['nom_NTitular'] + "."
		Else
			jDados['tex_DOC']				:= "Doc gerada para realização do processo de troca de titularidade entre o antigo titular " + jDados['nom_Titular'] + " e o novo titular " + jDados['nom_NTitular'] + "."
		EndIf

	//Loop herdeiros
	While lControler
		aAdd(aBox2,{1,"Nome Assinante " + CValToChar(nCont) ,Space(30),"","","","",0,.T.})
		aAdd(aBox2,{1,"CPF Assinante " + CValToChar(nCont) ,Space(11),"@R 999.999.999-99","","","",0,.T.})
		aAdd(aBox2,{1,"Parentesco " + CValToChar(nCont) ,Space(6),"","","SZJ","",0,.F.})
			
			If !ParamBox(aBox2,"Dados para troca",@aRet)
				Return  
				EXIT
			EndIf

			jDados['nom_Testemunha_' + CValToChar(nCont)]	:= MV_PAR01
			jDados['cpf_Testemunha_' + CValToChar(nCont)]	:= MV_PAR02
			jDados['par_Testemunha_' + CValToChar(nCont)]	:= MV_PAR03
			jDados['qtd_Testemunhas']	:= nCont
			
			nCont 		+= 1
			aBox2			:= {}
			aRet			:= {}
			
		lControler := MsgYesNo("Adicionar mais um Assinante?", "Coleta de Assinaturas")
			
	Enddo

	//Validação do dados preenchidos 
	If !MsgYesNo("<b>Contrato:</b> " + jDados["cod_Contrt"]  + " <br><b>Novo titular: </b>" + jDados['nom_NTitular'] + " <br><b>CPF: </b>" + jDados['cpf_NTitular'] + " <br><b>Endereço:</b>  " + jDados['end_NTitular'] + " <br><b>CEP </b>" + jDados['cep_NTitular'], "Os dados conferem?")
		Return
	EndIf
	
	//Validacao de qual empresa para o preenchimento dos dados no Aditivo
	If cCodEmp == "03" 
		jDados['nom_Emp']							:= EncodeUTF8("EMPRESA1", "cp1252")
		jDados['cpnj_Emp']						:= "00.000.000/0000-00"
		jDados['end_Emp']							:= EncodeUTF8("Rua , CEP, Cidade", "cp1252")
	ElseIf cCodEmp == "05" 
		jDados['nom_Emp']							:= EncodeUTF8("EMPRESA2", "cp1252")
		jDados['cpnj_Emp']						:= "00.000.000/0000-00"
		jDados['end_Emp']							:= EncodeUTF8("Rua , CEP, Cidade", "cp1252")
	ElseIf cCodEmp == "07"  
		jDados['nom_Emp']							:= EncodeUTF8("EMPRESA3", "cp1252")
		jDados['cpnj_Emp']						:= "00.000.000/0000-00"
		jDados['end_Emp']							:= EncodeUTF8("Rua , CEP, Cidade", "cp1252")
	Else
		MsgAlert('Não foi possivel identificar a EMPRESA. Favor abrir um chamado ao TI relatando o problema!')
		Return .F.
	EndIf
		
		AutoGeraDoc(jDados) 
Return 

/*{Protheus.doc} AutoGeraDoc
	Gera a RA automaticamente
  @type  Function
  @author Kleyson Gomes
  @since 29/11/2022
	@version 12.33
  @return .T.
*/
Static function AutoGeraDoc(jDados)

	cCodDoc 			:= GetSxEnum("SZ7","Z7_NUMERO")
	ConfirmSX8()

	Local nCont2 			
	Local nTipo				:= 1
	Local cUnid 			:= "01"
	Local cContrt			:= jDados['cod_Contrt']
	Local cCodCli			:= jDados['cod_Titular']
	Local cNomSol			:= jDados['nom_NTitular']	
	Local cGrupo 			:= jDados['grp_Doc']
	Local cTexto		 	:= "" + jDados['tex_Doc']

		cTexto 		+= CRLF + "-----------------------------------------------" 									+ CRLF + CRLF
		cTexto 		+= "Contrato: " 					+ jDados['cod_Contrt'] 															+ CRLF 
		cTexto 		+= "Titular: " 						+ jDados['nom_Titular'] 														+ CRLF
		cTexto 		+= "CPF: " 								+ jDados['cpf_Titular'] 														+ CRLF
		cTexto    += "Novo Titular: " 			+ jDados['nom_NTitular'] 														+ CRLF
		cTexto 		+= "CPF: " 								+ jDados['cpf_NTitular'] 														+ CRLF
		cTexto 		+= "Endereco: " 					+ jDados['end_NTitular'] 														+ CRLF
		cTexto 		+= "Tipo de Troca: EM " 	+ CValToChar(jDados['tp_troca'])										+ CRLF
		cTexto 		+= CRLF + "-----------------------------------------------" 									+ CRLF
		cTexto 		+= "Herdeiros/Testemunha: " + CRLF

			for nCont2 := 1 to jDados['qtd_Testemunhas']
				cTexto 		+= "Nome: " + jDados['nom_Testemunha_' + CValToChar(nCont2)] 							+ CRLF
				cTexto 		+= "CPF: " + jDados['cpf_Testemunha_' + CValToChar(nCont2)] 							+ CRLF
				cTexto 		+= "Parentesco: " + jDados['par_Testemunha_' + CValToChar(nCont2)] 				+ CRLF + CRLF
			next nCont2

	//Geração da RA
	oRA := GvRegistroAtendimento():new()
		If !(oRA:gravaRA(cCodDoc,;						
		 				 dDatabase,;				 				
		 				 left(time(),5),;						
		 				 "02", ;										
		 				 cUnid, ;										
		 				 cContrt, ;									
		 				 cCodCli, ; 									
		 				 "01",;												
						 "", ;								
						 "001", ;						
						 cNomSol, ;
						 "001", ;		
						 cGrupo, ;										
						 cTexto, ;
						 ,;
						 nTipo,;
						 sTod(' ')))
						 
			MsgAlert('Não foi possível gravar a RA. Favor gerar a RA manual e abrir um chamado ao CSTI relatando o problema!')
			return .F.
		Else
			U_EnviaEmail(cCodDoc,'A','')
		EndIf

		jDados['cod_RA'] := cCodDoc

		//Chama a geração do documento por tipo escolhido

		Do case 
			case (jDados['tp_troca'] == 1)
				U_DOC1(jDados) //Doc 1
			case (jDados['tp_troca'] == 2)
				U_DOC2(jDados) //Doc 2
			case (jDados['tp_troca'] == 3)
				U_DOC3(jDados) //Doc 3
		Endcase

Return .T.

/*{Protheus.doc} validaAbox
	(long_description)
	@type  Static Function
	@author Kleyson GOmes
	@since 16/12/2022
	@version 12.33
	@return 
*/
Static Function validaAbox()

		Table->(DbSetOrder(1))
		If !Table->(DbSeek(xFilial("Table") + MV_PAR02))
			MsgInfo("Contrato não encontrado")
			return .F.	
		Endif
	
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek(xFilial("SA1")+ MV_PAR03))
			MsgInfo("Cliente não encontrado")
			return .F.	
		Endif

		SBM->(DbSetOrder(1))
		If !SBM->(DbSeek(xFilial("SBM")+ MV_PAR04))
			MsgInfo("Grupo de DOC não encontrado")
			return .F.	
		Endif

Return .T.
