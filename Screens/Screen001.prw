#include "protheus.ch"
#include 'tbiconn.ch'
#include "rwmake.ch" 

/*/{Protheus.doc} MORA2004
  @type  User Function
  @author Kleyson Gomes
  @since 26/12/2022
  @version 12.33
  Chama a tela de cadastro de vendas de plano
  @return null
/*/
User Function MORA2004()
   Private lSucess := .F.
   
  //  RpCSetType(3)
  //  RpcSetEnv("03","01")

  // Set century on
  
  Begin Transaction 
    
    /* Chama o processo de cadastro do contrato */
    ZAM->( Reclock("ZAM", .T.) )
      FwMsgRun(,{|oSayP| StartProcess(oSayP)},"Preparando Tela"," Aguarde....")
    ZAM->( MsUnlock() )
  
    If lSucess
      FwMsgRun(,{|oSayP| lSucess := u_Ativacao() },"Realizando processo de ativação"," Aguarde....")
    EndIf

    
    If !lSucess
      DisarmTransaction()
      Return 
    EndIf
  End Transaction

  /* Por ultimo chama a ativação */

Return 

/*/{Protheus.doc} MORA2005
  @type  Static Function
  @author Kleyson Gomes
  @since 26/12/2022
  @version 12.33
  @param oSayP
  Tela para o cadastro de vendas de plano com validações iniciais + grid de dependentes
  @return 
/*/
Static Function StartProcess(oSayP)
  Local aDependentes    := { ModelDep() } /* Array padrão */
  Local aSexo           := u_xBoxDesc('ZAN_SEXO')
  Local aFpag           := u_xBoxDesc('ZAM_FPAG')
  Local aParent         := Parent() 
  Local lDecli          := .F.
  Local lAnuai          := .F.
   
  Local oFont1	        := TFont():New("Arial",09,11,,.F.,,,,,.F.)
  Local oFont14 		    := TFont():New('Bold',,-14,.T.)
  Local oFont12B 		    := TFont():New('Bold',,-12,.T.,.T.)
  Local oFont18B 		    := TFont():New('Bold',,-18,.T.,.T.)
  
  Private cSexo         := ""
  Private cParent       := ""
  Private aCpos         := {}
  Private oContrato     := GvContratoPlano():New()
  Private nVlrStatico   := 0
  Private cNomPla       := ""
  Private cNomVen       := ""
  Private oDlg          := Nil
  Private bSair         := {|| If( MsgYesNo("Seu progresso será perdido, continuar?","Cancelar inclusão de contrato"),(DisarmTransaction(), oDlg:DeActivate()), .T.) }

  //Monta o dialog principal da tela que suportará os demais componentes
    oDlg := FwDialogModal():New()       
    oDlg:SetEscClose( .F. )
    oDlg:SetTitle('Cadastro Simplificado de Plano - CAC')
    oDlg:SetSubTitle('Morada Essencial')
    oDlg:setSize(330, 385)//altura,largura
    oDlg:CreateDialog()

  //Monta os Inputs 
  //Panel central para preenchimento das informações
  oPnlReg         := tPanel():New(01,01,"",oDlg:getPanelMain(),oFont1,.T.,,CLR_BLUE,CLR_BLUE,400,300,.F.,.T.)
      oGrpPrm		  := TGroup():New(02,05,70,375,'Dados da Proposta',oPnlReg,,,.T.) //Linhas de contenção dos campos

  //-- linha 1
      oSayMV      := TSay():New(15,10,{|| "Cód. Vendedor(a)" },oPnlReg,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetVE      := TGet():New(25,10,{|u| If( PCount() == 0, ZAM->ZAM_CODVEN, ZAM->ZAM_CODVEN := u)},;
                                oPnlReg,060,010,"@!",{|| If( Empty(ZAM->ZAM_CODVEN),.T., ExistCpo('SA3', ZAM->ZAM_CODVEN)) },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ZAM->ZAM_CODVEN",,,,.T.)
      oGetVE:cF3  := "SA3"

      oSayMV      := TSay():New(15,80,{|| "Nº Proposta" },oPnlReg,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetPR      := TGet():New(25,80,{|u| If( PCount() == 0, ZAM->ZAM_CONTRT, ZAM->ZAM_CONTRT := u)},oPnlReg,060,010,"!@",;
                                {|| If(Empty(ZAM->ZAM_CONTRT),.T.,validaPro(ZAM->ZAM_CODVEN,ZAM->ZAM_CONTRT))} ,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ZAM->ZAM_CONTRT",,,,.T.  )

      oSayMV      := TSay():New(15,160,{|| "Cód. Plano" },oPnlReg,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetPL      := TGet():New(25,160,{|u| If( PCount() == 0, ZAM->ZAM_CODPRO, ZAM->ZAM_CODPRO := u)},;
                                oPnlReg,060,010,"@!",{|| If( Empty(ZAM->ZAM_CODPRO),.T., If( !ExistCpo('SB1', ZAM->ZAM_CODPRO), .F.,(recalcula(), oGetDP:SetFocus())))  },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ZAM->ZAM_CODPRO",,,,.T.  )
      oGetPL:cF3  := "SB1PLA"

      oSayMV      := TSay():New(15,310,{|| "Valor Plano" },oPnlReg,,oFont14,,,,.T.,CLR_BLACK,CLR_HGRAY,200,20)
      oGetMV      := TGet():New(25,310,{|u| If( PCount() == 0, nVlrStatico, nVlrStatico := u)},oPnlReg,060,010,"@E 999.99",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nVlrStatico",,,,.T.  )
      oGetMV:Disable()

  //--- Linha 2
      oSayMV      := TSay():New(40,10,{|| "Carência" },oPnlReg,,oFont14,,,,.T.,CLR_BLACK,CLR_HGRAY,200,20)
      oGetCA      := TGet():New(50,10,{|u| If( PCount() == 0, ZAM->ZAM_CARFUN, ZAM->ZAM_CARFUN := u)},;
                                oPnlReg,060,010,"@!",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F. ,,"ZAM->ZAM_CARFUN",,,,.T.  )
      oGetCA:Disable()

      oSayMV      := TSay():New(40,80,{|| "Cond. Pag." },oPnlReg,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetDP      := TGet():New(50,80,{|u| If( PCount() == 0, ZAM->ZAM_CPAGPV, ZAM->ZAM_CPAGPV := u)},;
                                oPnlReg,060,010,"@!",{|| If(Empty(ZAM->ZAM_CPAGPV),.T., ExistCpo('SE4', ZAM->ZAM_CPAGPV)) },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ZAM->ZAM_CPAGPV",,,,.T.  )
      oGetDP:cF3 := "SE4ZAM"

      oSayMV      := TSay():New(40,160,{|| "Forma Pagamento" },oPnlReg,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetFP      := TComboBox():New(50,160,{|u| If( PCount() == 0, ZAM->ZAM_FPAG, ZAM->ZAM_FPAG := u)},aFpag,060,010,oPnlReg,,,,,,.T.,,,,,,,,,'ZAM->ZAM_FPAG')

      oSayDT      := TSay():New(40,310,{|| "Data Ativação" },oPnlReg,,oFont14,,,,.T.,CLR_BLACK,CLR_HGRAY,200,20)
      oGetDT      := TGet():New(50,310,{|u| If( PCount() == 0, dDataBase, dDataBase := u)},;
                                oPnlReg,060,010,"@E 99/99/9999",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F. ,,"dDataBase",,,,.T.  )
      oGetDT:Disable()

      oGetDecli   := TCheckBox():New(25,230,'Declinar Disposição Final',{|u|If( PCount() == 0,ZAM->ZAM_DECLBE, ZAM->ZAM_DECLBE := u)},;
                                oPnlReg,100,210,,{||lDecli:=!lDecli,Recalcula()},,,,,,.T.,,,)  

      oGetAnu     := TCheckBox():New(52,230,'Anuidade',{||lAnuai},;
                                oPnlReg,100,210,,{||lAnuai:=!lAnuai,Recalcula(lAnuai)},,,,,,.T.,,,) 

  //-- linha 3
  oPnlTit         := tPanel():New(75,01,"",oDlg:getPanelMain(),oFont1,.T.,,CLR_BLUE,CLR_BLUE,400,300,.F.,.T.)
    oGrpPrm		    := 	TGroup():New(02,05,40,375,'Dados do(a) Titular',oPnlTit,,,.T.) 
    oGrpPrm		    := 	TGroup():New(45,05,100,375,'Inclusão de Dependentes',oPnlTit,,,.T.)
      
      oSayMV      := TSay():New(10,10,{|| "CPF" },oPnlTit,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetCPF     := TGet():New(20,10,{|u| If( PCount() == 0, ZAM->ZAM_CGC, ZAM->ZAM_CGC := u)},;
                                oPnlTit,060,010,"@R 999.999.999-99",{|| If(Empty(ZAM->ZAM_CGC),.T., If( CGC( ZAM->ZAM_CGC ), CarregaCli(), .F.)) },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ZAM->ZAM_CGC",,,,.T.  )

      oSayMV      := TSay():New(10,90,{|| "Nome" },oPnlTit,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetNTI     := TGet():New(20,90,{|u| If( PCount() == 0, ZAM->ZAM_NOMCLI, ZAM->ZAM_NOMCLI := u)},;
                                oPnlTit,125,010,"@!",{|| .T. },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ZAM->ZAM_NOMCLI",,,,.T.  )

      oSayMV     := TSay():New(10,230,{|| "Celular" },oPnlTit,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetCEL     := TGet():New(20,230,{|u| If( PCount() == 0, ZAM->ZAM_TELCEL, ZAM->ZAM_TELCEL := u)},;
                                oPnlTit,060,010,"@R (99) 99999-9999",{|| .T. },0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ZAM->ZAM_TELCEL",,,,.T.  )

      oSayDT      := TSay():New(10,310,{|| "Data Nascimento" },oPnlTit,,oFont14,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oGetDTN     := TGet():New(20,310,{|u| If( PCount() == 0, ZAM->ZAM_DTNAS, ZAM->ZAM_DTNAS := u)},oPnlTit,060,010,"@E 99/99/9999",;
                                {|| iif(ZAM->ZAM_DTNAS >= dDataBase,;
                                    MsgAlert("Data de Nascimento precisa ser menor que a data atual!", "Inclusão invalida"),), Recalcula() };
                                ,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"ZAM->ZAM_DTNAS",,,,.T.  )

  //Panel central para preenchimento dos dependentes + grid editavel de dependentes
  oPnlDep         := tPanel():New(130,06,"",oDlg:getPanelMain(),oFont1,.T.,,CLR_BLUE,CLR_BLUE,370,100,.F.,.T.)
      oBrowse     := FWBrowse():New(oPnlDep)

  oBrowse:SetDataArray(.T.)
  oBrowse:DisableConfig()
  oBrowse:DisableReport()
  oBrowse:SetEditCell(.T., {|| TudoOK() })
  oBrowse:SetAfterAddLine( {|x|AddLine(x)})
  oBrowse:setArray( aDependentes )
  oBrowse:SetChange({|| oBrowse:GoColumn(1) })

  oColumn := FWBrwColumn():New()
    oColumn:SetData({||oBrowse:oData:aArray[oBrowse:nAT,'ZAN_NOME']})
    oColumn:SetReadVar("oBrowse:oData:aArray[oBrowse:nAT,'ZAN_NOME']")
    oColumn:SetTitle("Nome")
    oColumn:SetPicture("@!")
    oColumn:SetType( "C" )
    oColumn:SetEdit(.T.)
    oColumn:SetAlign(0)
    oColumn:SetSize( 25 )
  oBrowse:SetColumns({oColumn})

  oColumn := FWBrwColumn():New()
    oColumn:SetData({||oBrowse:oData:aArray[oBrowse:nAT,'ZAN_DTNASC']})
    oColumn:SetReadVar("oBrowse:oData:aArray[oBrowse:nAT,'ZAN_DTNASC']")
    oColumn:SetType( "D" )
    oColumn:SetTitle("Data Nasc.")
    oColumn:SetPicture("@R 99/99/9999")
    oColumn:SetEdit(.T.)
    oColumn:SetAlign(0)
    oColumn:SetSize( 5 )
  oBrowse:SetColumns({oColumn})

  oColumn := FWBrwColumn():New()
    oColumn:SetData({||oBrowse:oData:aArray[oBrowse:nAT,'ZAN_SEXO']})
    oColumn:SetReadVar("oBrowse:oData:aArray[oBrowse:nAT,'ZAN_SEXO']")
    oColumn:SetTitle("Sexo")
    oColumn:SetType( "C" )
    oColumn:SetPicture("@!")
    oColumn:SetEdit(.T.)
    oColumn:SetAlign(0)
    oColumn:SetSize( 8 )
    oColumn:SetOptions(aSexo)
  oBrowse:SetColumns({oColumn})

  oColumn := FWBrwColumn():New()
    oColumn:SetData({||oBrowse:oData:aArray[oBrowse:nAT,'ZAN_PARENT']})
    oColumn:SetReadVar("oBrowse:oData:aArray[oBrowse:nAT,'ZAN_PARENT']")
    oColumn:SetTitle("Parentesco")
    oColumn:SetPicture("@!")
    oColumn:SetType( "C" )
    oColumn:SetEdit(.T.)
    oColumn:SetAlign(0)
    oColumn:SetSize( 5 )
    oColumn:SetOptions(aParent)
  oBrowse:SetColumns({oColumn})

  oColumn := FWBrwColumn():New()
    oColumn:SetData({||oBrowse:oData:aArray[oBrowse:nAT,'ZAN_FINAL']})
    oColumn:SetReadVar("oBrowse:oData:aArray[oBrowse:nAT,'ZAN_FINAL']")
    oColumn:SetTitle("Taxa")
    oColumn:SetPicture("@E 99.99")
    oColumn:SetType( "N" )
    oColumn:SetEdit(.F.)
    oColumn:SetAlign(0)
    oColumn:SetSize( 5 )
  oBrowse:SetColumns({oColumn})
  oBrowse:Activate()


  oPnlInfo      := tPanel():New(230,10,"",oDlg:getPanelMain(),oFont1,.T.,,CLR_BLUE,CLR_BLUE,400,100,.F.,.T.)
    
    oGrpPrm		  := 	TGroup():New(02,5,35,150,'Resumo',oPnlInfo,,,.T.)
      
      oSayMV      := TSay():New(10,10,{|| "Total de Dependentes:" },oPnlInfo,,oFont12B,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oSayQTdep   := TSay():New(10,100,{|| len( oBrowse:oData:aArray ) - 1},oPnlInfo,,oFont12B,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

      oSayNomPla  := TSay():New(18,10,{|| "Plano: " + cNomPla},oPnlInfo,,oFont12B,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oSayNomVen  := TSay():New(25,10,{|| "Vendedor(a): " + cNomVen},oPnlInfo,,oFont12B,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

  //Painel Resumo
  oPnlResu      := tPanel():New(230,175,"",oDlg:getPanelMain(),oFont1,.T.,,CLR_BLUE,CLR_BLUE,400,100,.F.,.T.)

    oGrpPrm		  := 	TGroup():New(02,5,35,200,'A Pagar',oPnlResu,,,.T.)

      oSayMV          := TSay():New(10,010,{|| "Valor Mínimo" },oPnlResu,,oFont18B,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oSayVlMinimo    := TSay():New(20,010,{|| "R$ " + Transform( nVlrStatico, "@E 999.99" ) },oPnlResu,,oFont18B,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
      oSayMV          := TSay():New(10,110,{|| "Valor Final" },oPnlResu,,oFont18B,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)
      oSayTotal       := TSay():New(20,110,{|| "R$ " + Transform( ZAM->ZAM_VLTOT, "@E 999.99" ) },oPnlResu,,oFont18B,,,,.T.,CLR_GREEN,CLR_WHITE,200,20)

  /* Aglutinando campos para facilitar a atualização */
  aAdd( aCpos, oGetVE )
  aAdd( aCpos, oGetPR )
  aAdd( aCpos, oGetPL )
  aAdd( aCpos, oGetVE )
  aAdd( aCpos, oGetMV )
  aAdd( aCpos, oGetCA )
  aAdd( aCpos, oGetDP )
  aAdd( aCpos, oGetFP )
  aAdd( aCpos, oGetDT )
  aAdd( aCpos, oGetNTI )
  aAdd( aCpos, oGetCEL )
  aAdd( aCpos, oGetCPF )
  aAdd( aCpos, oGetDTN )
  aAdd( aCpos, oGetAnu )
  aAdd( aCpos, oGetDecli )
  aAdd( aCpos, oSayQTdep )
  aAdd( aCpos, oSayNomPla)
  aAdd( aCpos, oSayNomVen)
  aAdd( aCpos, oSayTotal )
  aAdd( aCpos, oBrowse )
  /*------------------------------------*/

  aButtons := {}
  aAdd( aButtons, {,"Salvar e ativar", {|| ConfirmaPlano(), oDlg:DeActivate() }, '', 1, .T., .F. } )
  aAdd( aButtons, {,"Precisa de ajuda?", {|| ShellExecute("open","https://docs.google.com/document/doc01","","",1) }, '', 2, .T., .F. } )
  aAdd( aButtons, {,"Cancelar", bSair, '', 3, .T., .F. } )

  oDlg:addButtons( aButtons )

  oDlg:Activate()
  If !lSucess
    DisarmTransaction()
  EndIf
Return 

/*/{Protheus.doc} parent
  (long_description)
  @type  Static Function
  @author Paulo Souza
  @since 29/12/2022
  @version 12.33
  Array de parentesco
  @return 
/*/
Static function parent()
  Local aRet := {}

  /* Modificar para puxar via query */
  BeginSql alias 'parent'
    select zj_codigo as codigo 
      from szj030 
      where d_e_l_e_t_ = ' '
  EndSql
  While parent->( !Eof() )
    aAdd( aRet, upper( parent->codigo ) )
    parent->( dbSkip() )
  EndDo
  parent->( dbCloseArea() )

return aRet

static function TudoOK()
  Local nUlt := len( oBrowse:oData:aArray )
  Local aUltLin := oBrowse:oData:aArray[nUlt]

  if Empty( ZAM->ZAM_CODPRO ) .OR. Empty( ZAM->ZAM_DTNAS ) .OR. Empty( ZAM->ZAM_CONTRT )
    MsgInfo("É necessário preencher as informações do plano antes de prosseguir com os dependentes")
    oBrowse:oData:aArray[nUlt] :=  ModelDep()   
    oBrowse:Refresh()
    Return .F.
  EndIf

  /*
    1=>Nome
    2=>Nascimento
    3=>sexo
    4=>Parentesco
    5=>Taxa
  */

  If !Empty(aUltLin['ZAN_NOME']) ;
      .and. !Empty(aUltLin['ZAN_PARENT']) ;
      .and. !Empty(aUltLin['ZAN_SEXO']) ;
      .and. !Empty(aUltLin['ZAN_DTNASC'])

      /* Calcula taxa */
      oContrato:CalculaPlano( @oBrowse:oData:aArray, 'MORA2004' )

      /* adiciona nova linha */
      oBrowse:AddLine()
  Endif  

  aEval( aCpos, {|x| x:Refresh() } )      
return .T.

Static function AddLine(x)
  Local nUlt := len( oBrowse:oData:aArray )

  oBrowse:oData:aArray[nUlt] := ModelDep()
Return 

/*/{Protheus.doc} validaPro
  (long_description)
  @type  Static Function
  @author Kleyson GOmes
  @since 29/12/2022
  @version 12.33
  @param cGetVenc,GetPro
  @return 
/*/
Static Function validaPro(cGetVen,cGetPro)
  Local aSave := ZAM->( getArea() )
  If !Empty(cGetVen) .and. !Empty(cGetPro)

    ZAM->( dbSetOrder(1) )
    If zam->( dbSeek( xfilial("ZAM") + cGetPro ) )
      MsgAlert("Já existe um contrato cadastrado com esse código", "Inclusão invalida")
      restArea( aSave )
      Return .F.
    Endif

    ZGR->( dbSetOrder(1) )
    If !ZGR->( dbSeek( xFilial("ZGR") + cGetPro ) )
      MsgAlert("Proposta não encontrada!", "Inclusão invalida")
      restArea( aSave )
      Return .F.
    Endif

    If Alltrim( ZGR->ZGR_CODVEN ) != Alltrim( cGetVen )
      MsgAlert("Proposta esta associada a outro vendedor, associada ao vendedor "+ ZGR->ZGR_CODVEN +" !", "Inclusão invalida")
      restArea( aSave )
      Return .F.
    Endif

    If !(Alltrim(ZGR->ZGR_STATUS) $ '1/2/3/4')
      MsgAlert("O status da proposta não é válido para ativação", 'Inclusão Invalida')
      restArea( aSave )
      Return .F.
    Endif
  Endif

  oGetPR:Disable()

  restArea( aSave )
Return .T.

Static function Recalcula(lbulean)

  default lbulean := .F.
 
  if !Empty( ZAM->ZAM_CODPRO )
    SB1->( dbSetOrder(1) )
    If SB1->( dbSeek( xFilial("SB1") + ZAM->ZAM_CODPRO ) )
      ZAM->ZAM_VALOR := SB1->B1_PRV1
      nVlrStatico := SB1->B1_PRV1
      cNomPla     := LEFT(SB1->B1_DESC,25)

      oSayNomPla:Refresh()
      oSayNomVen:Refresh()
      oSayVlMinimo:Refresh()
    Endif
  Endif
  /* Adiciona informação de anuidade ao contrato caso a opção esteja marcada */
  If lbulean
    ZAM->ZAM_ADIMEN := 11
  EndIf

  SA3->( dbSetOrder(1) )
  SA3->( dbSeek( xFilial("SA3") + ZAM->ZAM_CODVEN ) )
  cNomVen := LEFT(SA3->A3_NOME,20)

  if Empty( ZAM->ZAM_CODPRO ) .OR. Empty( ZAM->ZAM_DTNAS ) .OR. Empty( ZAM->ZAM_CONTRT ) .or. Empty( ZAM->ZAM_NOMCLI ) .or. Empty( ZAM->ZAM_CGC ) .or. Empty( ZAM->ZAM_TELCEL )
    Return .T.
  EndIf


  ZAM->ZAM_FILIAL := xFilial("ZAM")
  ZAM->ZAM_FILORI := xFilial("ZAM")
  ZAM->ZAM_LOJA   := "01"
  ZAM->ZAM_CODSUP := SA3->A3_SUPER
  ZAM->ZAM_CODGER := SA3->A3_GEREN
  ZAM->ZAM_DSVEND := SA3->A3_NOME
  ZAM->ZAM_STATUS := '0'
  ZAM->ZAM_EMISSA := dDataBase
  ZAM->ZAM_DTATIV := dDataBase
  ZAM->ZAM_REGCON := ZAM->ZAM_CODPRO
  ZAM->ZAM_CANVEN := "100015" /* Em caso de alteração ajustar na MORF934 no controle de legendas da rotina*/
  ZAM->ZAM_DSORIG := "PaP via CAC"
  ZAM->ZAM_FPGADE := "1"
  ZAM->ZAM_POSVEN := "N"
  

  ZFD->(dbsetorder(1))
  If ZFD->(dbseek(xfilial("ZFD")+ZAM->ZAM_CODPRO))
    ZAM->ZAM_DTVIGE := dDataBase + (ZFD->ZFD_VIGENC * 30)
  endif
  
  oContrato:CalculaPlano( @oBrowse:oData:aArray, 'MORA2004' )
  
  aEval( aCpos, {|x| x:Refresh() } )
Return .T.

/*/{Protheus.doc} CriaClient
  (long_description)
  @type  Static Function
  @author Kleyson Gomes
  @since 30/12/2022
  @version 12.33
  @param 
  @return 
  Cria um novo cliente caso não exista
/*/
Static Function ConfirmaPlano()
  Local i
  Default cBasEmp := "03" //Serve para pegar a empresa para o filtro de endereço na classe de cliente

  if  Empty( ZAM->ZAM_CODPRO ) .or.; 
      Empty( ZAM->ZAM_CONTRT ) .or. ;
      Empty( ZAM->ZAM_CGC ) .or. ;
      Empty( ZAM->ZAM_NOMCLI ) .or.; 
      Empty( ZAM->ZAM_DTNAS ) .or. ;
      Empty( ZAM->ZAM_TELCEL ) .or. ;
      Empty( ZAM->ZAM_CPAGPV )

      MsgAlert("Só é possível salvar e ativar quando os dados estiverem completos", "Validação")
      Return .F.
  EndIf

  If Empty( ZAM->ZAM_CODCLI )
    oCrCli := ClientesSA1():New()
    cCodCli := oCrCli:getOrCreate(zam->zam_nomcli, zam->zam_cgc,,,,,,,zam->zam_telcel,,zam->ZAM_DTNAS,,,cBasEmp)
    If Empty(cCodCli)
      MsgAlert("Cliente não cadastrado", "Cadastro de Clientes")
      Return .F.
    EndIf

    ZAM->ZAM_CODCLI := cCodCli
  EndIf

  For i := 1 to len( oBrowse:oData:aArray )
    jDependente := oBrowse:oData:aArray[i]

    if !Empty(jDependente['ZAN_NOME']) .and. !Empty(jDependente['ZAN_DTNASC'])
      ZAN->( RecLock("ZAN", .T.) )
        ZAN->ZAN_FILIAL := xFilial("ZAN")
        ZAN->ZAN_CONTRT := ZAM->ZAM_CONTRT
        ZAN->ZAN_ITEM   := StrZero(i,2)
        ZAN->ZAN_NOME   := jDependente['ZAN_NOME']
        ZAN->ZAN_PARENT := jDependente['ZAN_PARENT']
        ZAN->ZAN_SEXO   := jDependente['ZAN_SEXO']
        ZAN->ZAN_DTNASC := jDependente['ZAN_DTNASC']
        ZAN->ZAN_DTCARE := jDependente['ZAN_DTCARE']
        ZAN->ZAN_CODTX  := jDependente['taxas','codigo_taxa']
        ZAN->ZAN_DESCTX := jDependente['taxas','descricao_taxa']
        ZAN->ZAN_VLTAXA := jDependente['ZAN_VLTAXA']
        ZAN->ZAN_TXDEPE := jDependente['ZAN_TXDEPE']
        ZAN->ZAN_CARENC := jDependente['taxas','carencia']
        ZAN->ZAN_DTINC  := dDataBase
        ZAN->ZAN_STATUS := "A"
      ZAN->( MsUnlock() )
    Endif
  Next i

  cHistIn := 'INCLUSÃO DE CONTRATO VIA CAC - RESUMO' + CRLF
  cHistIn += Replicate("-",50) + CRLF  
  cHistIn += "Data: "+ DTOC(ddatabase) + CRLF
  cHistIn += "Hora: "+ time() + CRLF
  cHistIn += "Usuário: "+ cUserName + CRLF
  cHistIn += "Regra Contratual: "+ZAM->ZAM_REGCON + CRLF
  cHistIn += "Plano: " + ZAM->ZAM_CODPRO + CRLF
  cHistIn += "Valor: " + Transform(ZAM->ZAM_VALOR,"@E 999,999,999.99") + CRLF
  cHistIn += "Tx Titular: " + Transform(ZAM->ZAM_VLTAXA,"@E 999,999,999.99") + CRLF
  cHistIn += "Tx Dependentes: " + Transform(ZAM->ZAM_VLTXDE,"@E 999,999,999.99") + CRLF
  cHistIn += "T O T A L: " + Transform(ZAM->ZAM_VLTOT,"@E 999,999,999.99") + CRLF
  cHistIn +=  CRLF + PADC("DADOS GERAIS DO CONTRATO",50) + CRLF
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
  cHistIn += "Rotina que gerou o Historico: MORA2004" + CRLF
  If Date() # dDataBase
    cHistIn += "Contrato ativado com database retroativa, data real: " + dToC( Date() ) + CRLF
  EndIf
  cHistIn += Replicate("-",50) + CRLF

  oHistorico:= GmHistorico():New( zam->zam_contrt, zam->zam_codcli, 'PLANO' )
  oHistorico:GravaHistorico( cHistIn, .F., '0001')

  lSucess := .T.
Return 

Static function ModelDep()
  Local oJson := JsonObject():New()

  oJson['ZAN_NOME']   := Space( TAMSX3('ZAN_NOME')[1] ) 
  oJson['ZAN_PARENT'] := ' '
  oJson['ZAN_DTNASC'] := StoD('')
  oJson['ZAN_SEXO']   := ' '
  oJson['ZAN_VLTAXA'] := 0
  oJson['ZAN_TXDEPE'] := 0
  oJson['ZAN_FINAL']  := 0
Return oJson

Static function CarregaCli()
  SA1->( dbSetOrder(3) )
  If SA1->( dbSeek( xFilial("SA1") + ZAM->ZAM_CGC ) )
    ZAM->ZAM_NOMCLI := SA1->A1_NOME
    ZAM->ZAM_TELCEL := SA1->A1_TEL
    ZAM->ZAM_DTNAS  := SA1->A1_DTNASC
    
    recalcula()

    oBrowse:SetFocus()
  EndIf
Return 
