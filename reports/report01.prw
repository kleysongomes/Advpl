#include "Protheus.ch"

/*{Protheus.doc} report01
Relatório de uso por cliente e tempo de uso
@type User Function
@version 12.33  
@author Kleyson Gomes
@since 14/07/2023
*/
User Function report01()
  Local oReport := ReportDef()

  oReport:PrintDialog()
Return

Static Function PrintReport(oReport)
  oSection1 := oReport:Section(1)

  Local aBox      := {}
  Local lRetParam := .F.

  aAdd(aBox,{1,"Cod Cliente" ,Space(6),"","","SA1","",0,.T.})
	aAdd(aBox,{1,"Data de Uso Até"	            ,Ctod(Space(8)),"","","","",50,.T.})

  lRetParam := ParamBox(aBox,"Relatário de Uso por Cliente",.T.)

  If !lRetParam
    MsgAlert( "Filtro não preenchido, operação cancelada!", "Relatário de Uso por Cliente" )
		Return
  EndIf
  
  cCodCli  := MV_PAR01
  cEndDate := dTos(MV_PAR02)

  BeginSql alias 'usoCli'
    select 
      table1.table1_contrt as contrato
      ,table1.table1_codcli as cliente
      ,table2.table2_nomcli as nomeuso
      ,table2.table2_endere as endereco
      ,table2.table2_dtsepu as dtSep
    from %Table:table1% table1
      inner join %Table:table2% table2 on table2.table2_contrt = table1.table1_contrt
        and table2.table2_dtsepu <= %Exp:cEndDate%
        and table2.%notdel%
    where table1.table1_codcli = %Exp:cCodCli%
      and table1.%notdel%
      order by 
      table2.table2_dtsepu desc
  EndSql

  oSection1:init()
  while usoCli->(!eof())
    oSection1:printLine()
    usoCli->(dbSkip())
  EndDo
  oSection1:Finish()
  usoCli->(dbCloseArea())
  
  oReport:EndPage()
Return

Static Function ReportDef()
  
  Local oReport
  Local oSection1
  oReport := TReport():New('Relatário de uso por Cliente' + ' - ' ,"uso POR CLIENTE",,{|oReport| PrintReport(oReport)}, "uso POR CLIENTE" )

  oReport:SetLandscape(.T.)
  oReport:SetTotalInLine(.F.)

  oSection1 := TRSection():New(oReport,"nomeuso por Cliente") 
    TRCell():New(oSection1,"contrato", "nomeuso","Contrato",,30,,,,,,,,,,,.F.)
    TRCell():New(oSection1,"cliente", "nomeuso","Cliente",,30,,,,,,,,,,,.F.)
    TRCell():New(oSection1,"nomeuso", "nomeuso","nomeuso",,30,,,,,,,,,,,.F.)
    TRCell():New(oSection1,"endereco", "nomeuso","Endereço",,30,,,,,,,,,,,.F.)
    TRCell():New(oSection1,"dtSep", "nomeuso","Data Sepultamento",,30,,,,,,,,,,,.F.)
    
Return oReport
