/*
{Protheus.doc} GRAP033B
Rotina de geração de borderô automática
@type Function
@author Kleyson Gomes
@since 27/04/2025
@see https://tdn.totvs.com/pages/releaseview.action?pageId=619131468
@see https://tdn.totvs.com/pages/releaseview.action?pageId=485450320
*/

User function GeraBordero()

    Local cTmp          := "TMPBOR"
    Local aTit          := {}
    Local aBor          := {}

    Local cBanco        := "341"
    Local cAgencia      := "0866"
    Local cConta        := "261936"

    Local lRegOn        := .T. //Para aparecer no novo Gestor Financeiro. 
    Local cSituaca      := "1"
    Local cNumBor       := ""
    Local dDataMov      := ""

    Local cEspecie      := '01'

    Local cSubconta     := 'API'

    //-- Variáveis utilizadas para o controle de erro da rotina automática
    Local aErroAuto     := {}
    Local cErroRet      := ""
    Local nCntErr       := 0
    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
    Private lAutoErrNoFile := .T.

    dDataMov := dDataBase

    If Select(cTmp) > 0
        (cTmp)->(dbCloseArea())
    EndIf

    BeginSQL Alias cTmp
        SELECT
            E1_FILIAL,
            E1_PREFIXO,
            E1_NUM,
            E1_PARCELA,
            E1_TIPO
        FROM
            %table:SE1%
        WHERE
            E1_TIPO NOT IN ( 'PR','PRE','IR-','CS-','PI-','CF-' )
            AND E1_FORMA = 'BOL' 
            AND E1_SALDO > 0 
            AND E1_NUMBOR = ''
            AND E1_EMISSAO >= '20250101'
            AND %NotDel%
    EndSQL

    // Adiciona os títulos no array
    While (cTmp)->(!EOF())
        aAdd(aTit, ;
            { ;
                {"E1_FILIAL"    , (cTmp)->E1_FILIAL}, ;
                {"E1_PREFIXO"   , (cTmp)->E1_PREFIXO}, ;
                {"E1_NUM"       , (cTmp)->E1_NUM}, ;
                {"E1_PARCELA"   , (cTmp)->E1_PARCELA}, ;
                {"E1_TIPO"      , (cTmp)->E1_TIPO} ;
            })
        (cTmp)->(dbSkip())
    EndDo

    (cTmp)->(dbCloseArea()) 

    If Empty(aTit) .OR. cSituaca == "0" // Caso não encontre títulos ou situação 0 deve sair da rotina.
        Return(.F.)
    EndIf

    // Informações bancárias para o borderô
    aAdd(aBor, {"AUTBANCO"      , PadR(cBanco   , TamSX3("A6_COD")[1]       )})
    aAdd(aBor, {"AUTAGENCIA"    , PadR(cAgencia , TamSX3("A6_AGENCIA")[1]   )})
    aAdd(aBor, {"AUTCONTA"      , PadR(cConta   , TamSX3("A6_NUMCON")[1]    )})
    aAdd(aBor, {"AUTSITUACA"    , PadR(cSituaca , TamSX3("E1_SITUACA")[1]   )})
    aAdd(aBor, {"AUTNUMBOR"     , PadR(cNumBor  , TamSX3("E1_NUMBOR")[1]    )}) // Caso não seja passado o número, será obtido o próximo pelo padrão do sistema
    aAdd(aBor, {"AUTSUBCONTA"   , PadR(cSubconta, TamSX3("EA_SUBCTA")[1]    )})
    aAdd(aBor, {"AUTESPECIE"    , PadR(cEspecie , TamSX3("EA_ESPECIE")[1]   )})
    aAdd(aBor, {"AUTBOLAPI"     , lRegOn                                     })

    If cSituaca $ "2|7" // Carteira descontada deve ser informada as taxas e data do movimento
        aAdd(aBor, {"AUTTXDESC" , 10        })
        aAdd(aBor, {"AUTTXIOF"  , 5         })
        aAdd(aBor, {"AUTDATAMOV", dDataMov  })
    EndIf

    MSExecAuto({|a, b| FINA060(a, b)}, 3, {aBor, aTit})

    If lMsErroAuto
        aErroAuto := GetAutoGRLog()
        For nCntErr := 1 To Len(aErroAuto)
            cErroRet += aErroAuto[nCntErr]
        Next
        Conout(cErroRet)
    EndIf

Return
