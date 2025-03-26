#include "protheus.ch"
#include 'totvs.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

/*
    {Protheus.doc} ClassificaNota
    Schedule de classificação de Pré-Notas via execAuto MATA103 (para optantes simples)
    @type Function
    @author Kleyson Gomes
    @since 21/10/2024
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=235592777
*/
User Function ClassificaNota()

    Local cOrigemSF1    := "PAGUEA%"
    Local cTES          := "026"
    Local cEspecie      := "NFS-E"
    Local aRetAPI       := {.F.,.F.}
    Local nOpc          := 4
    Local oFornec       := JsonObject():New()
    Local aCab          := {}
    Local aItem         := {}
    Local aItens        := {}

    Local lSD1_OK       := .F.
    Local cSD1_TIPO     := ""

    Local cAliasSF1 
    Local cAliasSD1

    Private lMsErroAuto := .F.

    conout("-------------------------------------------------------------- ")
    conout("   ///     ///   /////  //////   /////     ///  //////  /////  ")
    conout("  // // // //  //   //   //    //   //   ////  //  //   __//   ")
    conout(" //   //  //  //===//   //    //===//     //  //  //     //    ")
    conout("//       //  //   //   //    //   //     //  //////  /////     ")
    conout("-------------------------------------------------------------- ")

    conout("---------- Iniciando processo de classificação de notas... ----------")
    conout("---------- Consultando notas a serem classificadas... ----------     ")
    
    cAliasSF1 := GetNextAlias()

    BeginSql Alias cAliasSF1
        Select
            DISTINCT SF1.*
        From
            %Table:SF1% SF1
            INNER JOIN %Table:SD1% SD1 On SF1.F1_DOC = SD1.D1_DOC
            And SD1.D1_NUMSEQ = ' '
            And SD1.D1_CUSTO = ' '
            And SD1.%NotDel%
        Where
            UPPER(SF1.F1_XORINT) Like %Exp:cOrigemSF1%
            And (SF1.F1_ESPECIE = 'NFS' Or SF1.F1_ESPECIE = 'NFS-E')
            And SF1.%NotDel%
        EndSQL 

    If (cAliasSF1)->(Eof())
        conout("---------- Não existem notas a serem classificadas. ----------")
        Return
    EndIf

    conout("---------- Agrupando notas por fornecedor... ----------")
    While (cAliasSF1)->(!Eof())
        
        Begin Transaction
            //TODO TESTAR NO OFF INCLUINDO MAIS DE UMA NOTA 
            If !oFornec:hasProperty((cAliasSF1)->F1_FORNECE)            

                //Cria o array temporário para o fornecedor
                oFornec[(cAliasSF1)->F1_FORNECE] := {}

                dbSelectArea("SA2")
                dbSetOrder(1)

                If DbSeek(xFilial("SA2") + (cAliasSF1)->F1_FORNECE)
                
                    //Realiza consulta na SERPRO 
                    aRetAPI := u_APISERPRO(SA2->A2_CGC)

                    If aRetAPI[2]
                        conout("---------- Fornecedor optante pelo Simples Nacional. ----------")
                        aAdd(oFornec[(cAliasSF1)->F1_FORNECE], "OPTANTE")   
                    Else
                        conout("---------- Fornecedor NÃO optante pelo Simples Nacional. ----------")
                        aAdd(oFornec[(cAliasSF1)->F1_FORNECE], "NAO_OPTANTE")   
                    EndIf
                EndIF
            
            EndIf

            If oFornec[(cAliasSF1)->F1_FORNECE][1] == "OPTANTE"

                aItens := {} //Array de itens zerado para cada Nota
                cAliasSD1 := GetNextAlias()

                BeginSql Alias cAliasSD1
                    Select
                        SD1.*
                    From
                        %Table:SD1% SD1
                    Where
                        SD1.D1_DOC = %Exp:(cAliasSF1)->F1_DOC%
                        And SD1.D1_NUMSEQ = ' '
                        And SD1.D1_CUSTO = ' '
                        And SD1.%NotDel%
                EndSQL 

                If (cAliasSD1)->(Eof())
                    conout("---------- Itens não encontrados F1_DOC: "+ (cAliasSF1)->F1_DOC +" ----------")
                    (cAliasSF1)->(DbSkip())
                EndIf

                while (cAliasSD1)->(!Eof())
                    dbSelectArea("SD1")
                    dbSetOrder(1) //Documento + Serie + Forn/Cliente + Loja + Produto + Item NF           
                    If DbSeek(xFilial("SD1") + (cAliasSD1)->D1_DOC + (cAliasSD1)->D1_SERIE + (cAliasSD1)->D1_FORNECE + (cAliasSD1)->D1_LOJA + (cAliasSD1)->D1_COD + (cAliasSD1)->D1_ITEM)

                        lSD1_OK := .T.
                        cSD1_TIPO := (cAliasSD1)->D1_TIPO

                        conout("---------- Atualizando SD1... ----------") 
                        RecLock("SD1", .F.)
                            SD1->D1_BASEIRR := 0
                            SD1->D1_ALIQIRR := 0
                            SD1->D1_VALIRR  := 0
                            SD1->D1_TES     := cTES
                        MsUnlock()
                        
                        conout("---------- SD1 -> atualizada com sucesso. ----------")

                        dbSelectArea("SF1")
                        dbSetOrder(1)
                        If dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)
                            conout("---------- Atualizando SF1... ----------") 
                            RecLock("SF1", .F.)
                                SF1->F1_ESPECIE := cEspecie
                            MsUnlock()
                            
                            conout("---------- SF1 -> atualizada com sucesso. ----------")
                        EndIf
                        
                        conout("---------- Preparando dados (SD1) para o ExecAuto. ----------") 
                        //Array de Item
                        aItem := {}
                        aadd(aItem,{"D1_ITEM"       , (cAliasSD1)->D1_ITEM     ,NIL})
                        aadd(aItem,{"D1_COD"        , (cAliasSD1)->D1_COD      ,NIL})
                        aadd(aItem,{"D1_UM"         , (cAliasSD1)->D1_UM       ,NIL})
                        aadd(aItem,{"D1_LOCAL"      , (cAliasSD1)->D1_LOCAL    ,NIL})
                        aadd(aItem,{"D1_QUANT"      , (cAliasSD1)->D1_QUANT    ,NIL})
                        aadd(aItem,{"D1_VUNIT"      , (cAliasSD1)->D1_VUNIT    ,NIL})
                        aadd(aItem,{"D1_TOTAL"      , (cAliasSD1)->D1_TOTAL    ,NIL})
                        aadd(aItem,{"D1_TES"        , cTES                     ,NIL})
                        aadd(aItem,{"D1_RATEIO"     , (cAliasSD1)->D1_RATEIO   ,NIL})

                        //Garantia de não calcular impostos
                        aadd(aItem,{"D1_BASEIRR"    , 0                        ,NIL})
                        aadd(aItem,{"D1_ALIQIRR"    , 0                        ,NIL})
                        aadd(aItem,{"D1_VALIRR"     , 0                        ,NIL})

                        If(nOpc == 4)//Se for classificação deve informar a variável LINPOS
                            aAdd(aItem, {"LINPOS" , "D1_ITEM",  (cAliasSD1)->D1_ITEM})
                        EndIf

                        aAdd(aItens,aItem)
                    EndIf

                    (cAliasSD1)->(DbSkip())
                EndDo //While SD1
                
                If lSD1_OK
                    conout("---------- Preparando dados (SF1) para o ExecAuto. ----------") 
                    //Array de Cabeçalho
                    aCab := {}
                    aadd(aCab,{"F1_TIPO"        , cSD1_TIPO                ,NIL})
                    aadd(aCab,{"F1_FORMUL"      , (cAliasSF1)->F1_FORMUL   ,NIL})
                    aadd(aCab,{"F1_DOC"         , (cAliasSF1)->F1_DOC      ,NIL})
                    aadd(aCab,{"F1_SERIE"       , (cAliasSF1)->F1_SERIE    ,NIL})
                    aadd(aCab,{"F1_EMISSAO"     , (cAliasSF1)->F1_EMISSAO  ,NIL})
                    aadd(aCab,{"F1_DTDIGIT"     , (cAliasSF1)->F1_DTDIGIT  ,NIL})
                    aadd(aCab,{"F1_FORNECE"     , (cAliasSF1)->F1_FORNECE  ,NIL})
                    aadd(aCab,{"F1_LOJA"        , (cAliasSF1)->F1_LOJA     ,NIL})
                    aadd(aCab,{"F1_ESPECIE"     , cEspecie                     ,NIL})
                    aadd(aCab,{"F1_COND"        , (cAliasSF1)->F1_COND     ,NIL})
                    aadd(aCab,{"F1_DESPESA"     , (cAliasSF1)->F1_DESPESA  ,NIL})
                    aadd(aCab,{"F1_DESCONT"     , (cAliasSF1)->F1_DESCONT  ,NIL})
                    aadd(aCab,{"F1_SEGURO"      , (cAliasSF1)->F1_SEGURO   ,NIL})
                    aadd(aCab,{"F1_FRETE"       , (cAliasSF1)->F1_FRETE    ,NIL})
                    aadd(aCab,{"F1_MOEDA"       , (cAliasSF1)->F1_MOEDA    ,NIL})
                    aadd(aCab,{"F1_TXMOEDA"     , (cAliasSF1)->F1_TXMOEDA  ,NIL})
                    aadd(aCab,{"F1_STATUS"      , (cAliasSF1)->F1_STATUS   ,NIL})

                    conout("---------- Executando ExecAuto... ----------")
                    MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)}, aCab, aItens, nOpc)
        
                    If lMsErroAuto
                        //MostraErro() 
                        DisarmTransaction()
                        ConOut("---------- Erro na classificação! ----------")
                    Else
                        ConOut("---------- Classificação realizada com sucesso! ----------")
                    EndIf
                Else //Se lSD1_OK = .F.
                    conout("---------- Erro ao localizar/atualizar SD1. ----------")
                    DisarmTransaction()
                    (cAliasSF1)->(DbSkip())
                EndIf
            EndIf

        End Transaction

        (cAliasSF1)->(DbSkip())
    EndDo //While SF1

    conout("---------- Processo de classificação finalizado. ----------")
Return

/*
    {Protheus.doc} executa_classificacao
    Rotina para execução de teste isolado no processo de classificação de notas.
    @type Function
    @author Kleyson Gomes
    @since 21/10/2024
*/
user function executa_classificacao()

    RpcSetType( 3 )
	RpcSetEnv( '01', '01')  

    u_ClassificaNota()
    
return
