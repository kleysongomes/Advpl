#INCLUDE "Protheus.ch"   
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

/* {Protheus.doc} User Function MORR1230
   Print identification tag with query
   @type  User Function
   @author Kleyson Gomes
   @since 13/06/2023
   @version version
   @return Nil */

User Function printTag()

  Local aBox        :=  {}
  Local aRet        :=  {}

  Local cfield1     := ""
  Local cfield2     := ""
  Local cDtfield1   := ""
  Local cfieldSql   := ""
  Local cDtfield2   := ""
  Local cDtfield3   := ""
  Local cfield3     := ""
  Local cfield4     := ""
  Local cfield5     := "&&"

  Private oPrinter   
  Private oFont1N    :=  TFont():New( "Arial",        ,       15, ,       .T.)  
  Private oFont1     :=  TFont():New( "Arial",        ,       12,         .T.)  
  Private nLin       :=  29

// Definition of parameter fields 

    aAdd(aBox,  {1,    "field 1",         Space(6),         "",                 "",       "zz2",    "",    30,    .F.})                 //MV_PAR01
    aAdd(aBox,  {1,    "field 2",         Space(30),        "",                 "",       "zz1",    "",    80,    .T.})                //MV_PAR02
    aAdd(aBox,  {1,    "Date field 1",    Space(10),        "@E 99/99/9999",    "",       "",       "",    30,    .F.})               //MV_PAR03
    aAdd(aBox,  {1,    "field SQL",       Space(12),        "@R XX.XXX.XXXXX",  "",       "",       "",    50,    .F.})              //MV_PAR04
    aAdd(aBox,  {1,    "Date field 2",    Space(10),        "@E 99/99/9999",    "",       "",       "",    30,    .F.})             //MV_PAR05
    aAdd(aBox,  {1,    "Date field 3",    Space(10),        "@E 99/99/9999",    "",       "",       "",    30,    .F.})            //MV_PAR06
    aAdd(aBox,  {1,    "field 3",         Space(30),        "",                 "",       "",       "",    30,    .F.})           //MV_PAR07
    aAdd(aBox,  {1,    "field 4",         Space(7),         "@E 9999999",       "",       "",       "",    30,    .F.})          //MV_PAR08
    aAdd(aBox,  {1,    "field 5",         Space(30),        "",                 "",       "",       "",    80,    .F.})         //MV_PAR09

// Builds the parameters screen for user interaction 

    If !ParamBox(aBox,"parameters",@aRet)
      Return
    Endif

    If !(Empty(MV_PAR01))
      cFilter := "% '%" + MV_PAR02 + "%' %"
// Executa a query e preenche as variaveis com os dados coletados caso haja contrato no MV_PAR01 

        BeginSql alias 'QRYzz2'
          SELECT
              zz1.zz1_field2   field2,
              zz2.zz2_lote     fieldsql,
              form_data(zz1.zz1_dtfield2) datafield2,
              form_data(zz1.zz1_dtfield1) datafield1
          FROM %table:zz2% zz2
                      inner join %table:zz1% zz1
                        on zz1.zz1_field1 = zz2_field1
                        and zz1.zz1_field2 like %Exp:cFilter%
                        and zz1.d_e_l_e_t_ = ' '
                    Where 
                    zz1.zz1_field1 = %Exp:MV_PAR01%
          AND zz2.d_e_l_e_t_ = ' '
        EndSql

          cfield1     =   MV_PAR01
          cfield2     =   QRYzz2 -> field2
          cDtfield1   =   QRYzz2 -> datafield1
          cfieldSql   =   QRYzz2 -> fieldsql
          cDtfield2   =   QRYzz2 -> datafield2
          cDtfield3   :=  MV_PAR06  
          cfield3     :=  MV_PAR07
          cfield4     :=  MV_PAR08
          cfield5     :=  MV_PAR09

// Closes the connection opened by the query

    QRYzz2->(dbclosearea())

    else

// Direct completion of the parameters if there is no contract

          cfield1     :=  MV_PAR02
          cDtfield1   :=  MV_PAR03
          cfieldSql   :=  MV_PAR04
          cDtfield2   :=  MV_PAR05
          cDtfield3   :=  MV_PAR06
          cfield3     :=  MV_PAR07
          cfield4     :=  MV_PAR08
          cfield5     :=  MV_PAR09

    Endif

// print settings

    If oPrinter == Nil
        lPreview                          := .T.
        oPrinter                          := FWMSPrinter():New('tag_' + fwtimestamp() ,6,.F.,,.T.)
        oPrinter:SetPortrait()
        oPrinter:SetPaperSize(9)
        oPrinter:SetMargin(60,60,60,60)
        oPrinter:cPathPDF                 :="C:\TEMP\"       
    EndIf       

    oPrinter:StartPage()

///Assembles the graphic print in PDF

    oPrinter:SayBitmap( 40,   0190,     "\imagens\sua-logo.png",                                                    55,        30)
    oPrinter:Say(       50,   0020,     'IDENTIFICATION OF',                                                        oFont1N,  100)
    oPrinter:Say(       65,   0020,     'PRINT TAG',                                                                oFont1N,  100)

    oPrinter:Say(       90,   0020,     'FIELDSQL: '        + TRANSFORM(Alltrim(cfieldSql), "@R XX.XXX.XXXXX"),     oFont1,   100) 
    oPrinter:Say(       90,   0140,     'FIELD 1: '         + AllTrim(cfield1),                                     oFont1,   100) 
    oPrinter:Say(       105,  0020,     'FIELD 2: '         + AllTrim(cfield2),                                     oFont1,   100) 
    oPrinter:Say(       120,  0020,     'DATA FIELD 1: '    + AllTrim(cDtfield1),                                   oFont1,   100)
    oPrinter:Say(       120,  0140,     'DATA FIELD 2: '    + AllTrim(cDtfield2),                                   oFont1,   100)
    oPrinter:Say(       135,  0020,     'DATA FIELD 3: '    + AllTrim(cDtfield2),                                   oFont1,   100)
    oPrinter:Say(       135,  0140,     'FIELD 3: '         + AllTrim(cfield3),                                     oFont1,   100)
    oPrinter:Say(       150,  0020,     'FIELD 4: '         + AllTrim(cfield4),                                     oFont1,   100)
    oPrinter:Say(       165,  0020,     'FIELD 5: '         + AllTrim(cfield5),                                     oFont1,   100)

    oPrinter:EndPage()

// Saves the file and opens it in the installed default PDF viewer or web browser

    oPrinter:Preview()

    FreeObj(oPrinter)

return
