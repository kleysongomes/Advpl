#INCLUDE "Protheus.ch"   
#Include "TopConn.ch"
#Include "TbIConn.ch"
#include "FWPrintSetup.ch"
#Include "RPTDef.ch"

/*{Protheus.doc} User Function MORR1221
  @type  User Function
  @author Kleyson Gomes
  @since 08/11/2022
  @return Nil
*/

User Function MORR1221()

  Local aBox          := {}
  Local aRet          := {}
  Local nCPF          := 0
  Local nValorItens   := 0
  Local cCtrZAM       := ""
  Local cCtrZC0       := ""
  Local cCtrZEO       := ""
  Local cCtrZCM       := ""
  
  Private oPrinter,oDesign
  private cTitulo     := "Resumo Produtos por Cliente"   
  Private oFont1N     := TFont():New( "Arial",,15,,.T.)  
  Private oFont1      := TFont():New( "Arial",,12,.T.)  
  Private nLin        := 0160
  
  aAdd(aBox,{1,"CPF Cliente",Space(20),"","","","",50,.T.})//MV_PAR01

  If !ParamBox(aBox,"Parametros",@aRet)
    Return
  Endif

  nCPF := AllTrim(MV_PAR01)

    BeginSql alias "QRYSL2"
      SELECT
          sa1.a1_cod codCliente,
          form_data(sl1.l1_emissao) ddata,
          sl1.l1_num venda,
          sa1.a1_nome nomeCliente,
          sl2.l2_produto produto,
          sl2.l2_descri descricao,
          sum(sl2.l2_vrunit) valorItens
      FROM
          %table:sa1%   sa1
          INNER JOIN %table:sl1%   sl1 
              on sl1.l1_cliente = sa1.a1_cod
              AND sl1.d_e_l_e_t_ = ' '
          INNER JOIN %table:sl2%   sl2 
              on sl2.l2_num = sl1.l1_num
              AND sl2.d_e_l_e_t_ = ' '
      WHERE
          sa1.a1_cgc = %Exp:nCPF%
          AND sa1.d_e_l_e_t_ = ' '
      GROUP BY
          sa1.a1_cod,
          form_data(sl1.l1_emissao),
          sl1.l1_num,
          sa1.a1_nome,
          sl2.l2_produto,
          sl2.l2_descri
      ORDER BY
          sl1.l1_num DESC
    EndSql

    count to nReg 
    QRYSL2->(dbGotop())

    BeginSql alias "QRYCRT"
      SELECT
        zam_contrt contratoZAM,
        form_data(zam.zam_emissa) emissaoZAM,
        zc0_codjaz contratoZC0,
        form_data(zc0.zc0_emissa) emissaoZC0,
        zeo.zeo_codigo contratoZEO,
        form_data(zeo.zeo_emissa) emissaoZEO,
        zcm.zcm_codigo contratoZCM,
        form_data(zcm.zcm_emissa) emissaoZCM
      FROM
        %table:sa1030%  sa1
        LEFT JOIN %table:zc0%  zc0 on zc0.zc0_codcli = sa1.a1_cod AND zc0.%notdel%
        LEFT JOIN %table:zam%  zam on zam.zam_codcli = sa1.a1_cod AND zam.%notdel%
        LEFT JOIN %table:zeo%  zeo on zeo.zeo_codcli = sa1.a1_cod AND zeo.%notdel%
        LEFT JOIN %table:zcm%  zcm on zcm.zcm_codcli = sa1.a1_cod AND zcm.%notdel%
      WHERE
        sa1.a1_cgc = %Exp:nCPF%
        AND sa1.%notdel%
    EndSql

    count to nReg2 
    QRYCRT->(dbGotop())

        If oPrinter == Nil
          lPreview                          := .T.
          oPrinter                          := FWMSPrinter():New(cTitulo + fwtimestamp(),6,.F.,,.T.,.F.,,"",.F.,.T.,.F.,.T.,1)
          oPrinter:SetPortrait()
          oPrinter:SetPaperSize(9)
          oPrinter:SetMargin(60,60,60,60)
          oPrinter:cPathPDF                 :="C:\TEMP\"   

          oDesign := GvMsPrinter():New(0/*Img Geral*/,oPrinter)  

        EndIf       
            oPrinter:StartPage()

            oPrinter:Say(130,0020,"Cliente  " + AllTrim(QRYSL2->codCliente) + " - "+AllTrim(QRYSL2->nomeCliente),oFont1N,  100)
            oPrinter:Say(145,0020,"Data",                                                 oFont1N,  100)
            oPrinter:Say(145,0090,"Venda",                                                oFont1N,  100)
            oPrinter:Say(145,0160,"Produto",                                              oFont1N,  100)
            oPrinter:Say(145,0220,"Descrição",                                            oFont1N,  100)
            oPrinter:Say(145,0450,"Valor Produto",                                        oFont1N,  100)

            oDesign:Header(cTitulo)

          while QRYSL2->(!EOF())
            oPrinter:Say(nLin,0020,AllTrim(QRYSL2->ddata),                              oFont1,  100)
            oPrinter:Say(nLin,0090,AllTrim(QRYSL2->venda),                              oFont1,  100)
            oPrinter:Say(nLin,0160,AllTrim(QRYSL2->produto),                            oFont1,  100)
            oPrinter:Say(nLin,0220,AllTrim(QRYSL2->descricao),                          oFont1,  100)
            oPrinter:Say(nLin,0450,"R$" + TRANSFORM(QRYSL2->valorItens,"@E 999,999.99"),oFont1,  100)

            nValorItens := nValorItens + QRYSL2->valorItens
            nLin := nLin + 10

            QRYSL2->(dbSkip())
          enddo
            
            oPrinter:Say(nLin + 5,0400,"Valor Total dos Itens:   R$" + TRANSFORM(nValorItens,"@E 999,999.99"),oFont1,  100)
            
            nLin := nLin + 50
            oPrinter:Say(nLin - 20,0020,"Contratos Existentes do Cliente"           ,oFont1N,  100)
            oPrinter:Say(nLin     ,0020,"Crt Plano/Emissão"       ,oFont1N,  100)
            oPrinter:Say(nLin     ,0140,"Crt Jazigo/Emissão"      ,oFont1N,  100)
            oPrinter:Say(nLin     ,0260,"Crt Cremação/Emissão"    ,oFont1N,  100)
            oPrinter:Say(nLin     ,0410,"Crt Funeral UF/Emissão"  ,oFont1N,  100)

          while QRYCRT->(!EOF())
            if cCtrZAM != AllTrim(QRYCRT->contratoZAM)
              oPrinter:Say(nLin + 20,0020,AllTrim(QRYCRT->contratoZAM) + " - " + QRYCRT->emissaoZAM,oFont1,  100)
              cCtrZAM := AllTrim(QRYCRT->contratoZAM)
            EndIf
            if cCtrZC0 != AllTrim(QRYCRT->contratoZC0)
              oPrinter:Say(nLin + 20,0145,AllTrim(QRYCRT->contratoZC0) + " - " + QRYCRT->emissaoZC0,oFont1,  100)
              cCtrZC0 := QRYCRT->contratoZC0
            EndIf
            if cCtrZEO != AllTrim(QRYCRT->contratoZEO) 
              oPrinter:Say(nLin + 20,0265,AllTrim(QRYCRT->contratoZEO) + " - " + QRYCRT->emissaoZEO,oFont1,  100)
              cCtrZEO := AllTrim(QRYCRT->contratoZEO)
            EndIf
            if cCtrZCM != AllTrim(QRYCRT->contratoZCM) 
              oPrinter:Say(nLin + 20,0415,AllTrim(QRYCRT->contratoZCM) + " - " + QRYCRT->emissaoZCM,oFont1,  100)
              cCtrZCM := AllTrim(QRYCRT->contratoZCM)
            EndIf

            nLin := nLin + 10
            QRYCRT->(dbSkip())
          enddo
  
          oPrinter:Say(nLin + 50,0020,"Observação: Os valores listados são referentes à data de realização da venda*" ,oFont1,  100)
      
      QRYSl2->(dbclosearea())
      QRYCRT->(dbclosearea())
      
      oDesign:Footer(,,.F.)
      oPrinter:EndPage()
      oPrinter:Preview()

      FreeObj(oPrinter)  
Return
