#Include 'Protheus.ch'

/*/{Protheus.doc} WORKFLOWS - Função de controle.
	(long_description)
	@type  User Function
	@author Kleyson Gomes
	@since 08/02/2023
	@version 12.33
	@param jDados, cOption
	@return boolean
/*/

User Function MORR1231(jDados, cOption)
	Local lRet

	Do Case
	Case cOption == "Importação de Plano Corporativo"		
        lRet := MORR1231B(jDados, cOption)
	Case cOption == "Atualização de Cliente"
				lRet := MORR1231A(jDados, cOption)
	Case cOption == "Importação Cartão Alimentação"
				lRet := MORR1231C(jDados, cOption)
	EndCase

Return lRet



/*/{Protheus.doc} WORKFLOW - Importações de clientes.
    @type  Static Function
    @author Kleyson Gomes
    @since 27/03/2023
    @version 12.33
    @param jDados, cOption
    @return Boolean
/*/
Static Function MORR1231A(jDados, cOption)
	Local cHtml     := "\workflow\workflow_imports_clientes.html"
	Local cAssunto  := "WORKFLOW - " + cEmpAnt + "/" + cFilAnt + "  RESUMO DA IMPORTAÇÃO (" + cOption + ")"
	Local cTo       := UsrRetMail(__cUserId)
	Local i         := 0
	Local i2        := 0
	Local aItens    := {}
	Local aAux      := {}
	Local cHtmlMail	:= ''
	Local cTitulo	:= "Resumo de importação (" + cOption + ")"
	Local aCabec	:= {}
    

	aAdd(aCabec	, {"TITULO"	     , cTitulo })

    /* For para percorrer os registros com erro, gerando um resumo com os dados invalidos ou faltantes */
	for i:= 1 to len(jDados['aErr'])
		if len(aItens) >= 1 /* Valida todos os campos com erro de um mesmo registro, baseado no próximo endereço do array. */
			if aItens[i2][1][2] == iif(Empty(jDados['aContent'][jDados['aErr'][i][2]][3]), " - ", transform(jDados['aContent'][jDados['aErr'][i][2]][3], "@R 999.999.999-99"))
				aItens[i2][2][2] := aItens[i2][2][2] + " , " + jDados['aErr'][i][3] + " " + jDados['aErr'][i][4]
				loop
			endif
		endif
		aAdd(aAux, {"CPFCLI", iif(Empty(jDados['aContent'][jDados['aErr'][i][2]][3]), " - ", transform(jDados['aContent'][jDados['aErr'][i][2]][3], "@R 999.999.999-99"))})
		aAdd(aAux, {"ERR", jDados['aErr'][i][3] + " " + jDados['aErr'][i][4]})
		aAdd(aItens, aAux)
		aAux	:=	{}
		i2++
	next i

    /* Tratatamento restante do html e envio. */     
	cHtmlMail := u_TrataHtm(aCabec, aItens, cHtml)
	cHtmlMail := Strtran(cHtmlMail, "NUMTOTAL", cvaltochar(len(jDados['aContent']) - 1))
	cHtmlMail := Strtran(cHtmlMail, "NUMSUCCESS", cvaltochar(len(jDados['aSuccess'])))
	cHtmlMail := Strtran(cHtmlMail, "NUMFAIL", cvaltochar((len(jDados['aContent']) - 1) - len(jDados['aSuccess'])))

	if U_EnviaEmail(cAssunto, cTo, cHtmlMail)
		lRet := .T.
	endif

Return lRet


/*/{Protheus.doc} Resumo - Importações de planos.
    @type  Static Function
    @author Kleyson Gomes
    @since 27/03/2023
    @version 12.33
    @param jDados, cOption
    @return Boolean
/*/
Static Function MORR1231B(jDados, cOption)
	Local cHtml     := "\workflow\workflow_imports_planos.html"
	Local cAssunto  := "WORKFLOW - " + cEmpAnt + "/" + cFilAnt + "  RESUMO DA IMPORTAÇÃO (" + cOption + ")"
	Local cTo       := UsrRetMail(__cUserId) + ";" + GetMv('MS_MAILIMP')
	Local i         := 0
	Local i2        := 0
	Local i3        := 0
	Local i4        := 0
	Local valTotal := 0
	Local aItens    := {}
	Local aAux      := {}
	Local aAux2     := {}
	Local cHtmlMail	:= ''
	Local cTitulo	:= "Resumo de importação (" + cOption + ")"
	Local aCabec	:= {}
	Local htmAux    := ""

	aAdd(aCabec	, {"TITULO"	     , cTitulo })

	/* For para gerar um resumo de plano/vidas associadas/valor unitário/valor total. */
	for i:= 1 to len(jDados['aSuccess'])
		ZAM->(dbsetorder(5))
		ZAM->(dbseek(xFilial("ZAM") + alltrim(jDados['aSuccess'][i][2][3])))
		if i >= 2
			if aAux2[i4][1][2] == right(jDados['aSuccess'][i][2][1], 28) //Validação de planos (Amarrado pelo nome do plano).
				i3++
				valTotal += ZAM->ZAM_VALOR
				aAux2[i4][2][2] := cValToChar(i3)
				aAux2[i4][3][2] := alltrim(transform(ZAM->ZAM_VALOR, "@E 999,999.99"))
				aAux2[i4][4][2] := alltrim(transform(valTotal, "@E 999,999.99"))
				loop
			endif
			i3       := 0
			valTotal := 0
		endif
		if !Empty(ZAM->ZAM_CLIFAT)
			valTotal += ZAM->ZAM_VALOR
			i3++
			aAdd(aAux, {"planoNome",  right(jDados['aSuccess'][i][2][1], 28)	})
			aAdd(aAux, {"vidasAsso",  cValToChar(i3) })
			aAdd(aAux, {"valorUnit",  alltrim(transform(ZAM->ZAM_VALOR, "@E 999,999.99"	)) })
			aAdd(aAux, {"valorTotal", alltrim(transform(valTotal, "@E 999,999.99"	))  })
			aAdd(aAux2, aAux)
			aAux := {}
			i4++
		EndIf
	next


    /* For para percorrer os registros com erro, gerando um resumo com os dados invalidos ou faltantes. */
	for i:= 1 to len(jDados['aErr'])
		if len(aItens) >= 1 /* Valida todos os campos com erro de um mesmo registro */
			if aItens[i2][1][2] == iif(Empty(jDados['aContent'][jDados['aErr'][i][2]][3]), " - ", transform(jDados['aContent'][jDados['aErr'][i][2]][3], "@R 999.999.999-99"))
				aItens[i2][2][2] := aItens[i2][2][2] + " , " + jDados['aErr'][i][3] + " " + jDados['aErr'][i][4]
				loop
			endif
		endif
		aAdd(aAux, {"CPFCLI", iif(Empty(jDados['aContent'][jDados['aErr'][i][2]][3]), " - ", transform(jDados['aContent'][jDados['aErr'][i][2]][3], "@R 999.999.999-99"))})
		aAdd(aAux, {"ERR", jDados['aErr'][i][3] + " " + jDados['aErr'][i][4]})
		aAdd(aItens, aAux)
		aAux	:=	{}
		i2++
	next i

	/* For para tratar o html, adiciona os itens da sessão de resumo por plano. */
    for i:= 1 to len(aAux2)
        htmAux += "<tr>"
        htmAux += "<td style='border: 1px solid #cccccc; text-align: left;'
		htmAux += "colspan = '2'>"
        htmAux += aAux2[i][1][2]
        htmAux += "</td>"
        htmAux += "<td style='border: 1px solid #cccccc; text-align: center;'
		htmAux += "colspan = '2'>"
        htmAux += aAux2[i][2][2]
        htmAux += "</td>"
        htmAux += "<td style='border: 1px solid #cccccc; text-align: center;'
		htmAux += "colspan = '1'>"
        htmAux += "R$" + cValToChar(aAux2[i][3][2])
        htmAux += "</td>"
        htmAux += "<td style='border: 1px solid #cccccc; text-align: center;'
		htmAux += "colspan = '1'>"
        htmAux += "R$" + cValToChar(aAux2[i][4][2])
        htmAux += "</td>"
        htmAux += "</tr>"
    next i 

    /* Tratatamento restante do html e envio. */   
	cHtmlMail := u_TrataHtm(aCabec, aItens, cHtml)
    cHtmlMail := Strtran(cHtmlMail, "-- Identificador -- ", htmAux)
	cHtmlMail := Strtran(cHtmlMail, "NUMTOTAL", cvaltochar(len(jDados['aContent']) - 1))
	cHtmlMail := Strtran(cHtmlMail, "NUMSUCCESS", cvaltochar(len(jDados['aSuccess'])))
	cHtmlMail := Strtran(cHtmlMail, "NUMFAIL", cvaltochar((len(jDados['aContent']) - 1) - len(jDados['aSuccess'])))

	if U_EnviaEmail(cAssunto, cTo, cHtmlMail)
		lRet := .T.
	endif

Return lRet

/*/{Protheus.doc} Resumo - Importações de cartão alimentação.
    @type  Static Function
    @author Kleyson Gomes
    @since 29/08/2023
    @version 12.33
    @param jDados, cOption
    @return Boolean
/*/
Static Function MORR1231C(jDados, cOption)
	Local cHtml     := "\workflow\workflow_imports_card_aliment.html"
	Local cAssunto  := cEmpAnt + "/" + cFilAnt + "  RESUMO DA IMPORTAÇÃO (" + cOption + ")"
	Local cTo       := UsrRetMail(__cUserId)
	Local i         := 0
	Local i2        := 0
	Local aItens    := {}
	Local aAux      := {}
	Local cHtmlMail	:= ''
	Local cTitulo	:= "Resumo de importação (" + cOption + ")"
	Local aCabec	:= {}
    

	aAdd(aCabec	, {"TITULO"	     , cTitulo })

    /* For para percorrer os registros com erro, gerando um resumo com os dados invalidos ou faltantes */
	for i:= 1 to len(jDados['aErr'])
		aAdd(aAux, {"IDCARD", jDados['aErr'][i][2]})
		aAdd(aAux, {"ERR", jDados['aErr'][i][3] + " " + jDados['aErr'][i][4]})
		aAdd(aItens, aAux)
		aAux	:=	{}
		i2++
	next i

  /* Tratatamento restante do html e envio. */     
	cHtmlMail := u_TrataHtm(aCabec, aItens, cHtml)
	cHtmlMail := Strtran(cHtmlMail, "NUMTOTAL", cvaltochar(len(jDados['aContent']) - 1))
	cHtmlMail := Strtran(cHtmlMail, "NUMSUCCESS", cvaltochar(len(jDados['aSuccess'])))
	cHtmlMail := Strtran(cHtmlMail, "NUMFAIL", cvaltochar((len(jDados['aContent']) - 1) - len(jDados['aSuccess'])))

	if U_EnviaEmail(cAssunto, cTo, cHtmlMail)
		lRet := .T.
	endif

Return lRet
