#INCLUDE "PROTHEUS.CH"

/*{Protheus.doc} ExecFonte
   /* {Protheus.doc} SearchInvite
   Executa funções de usuário a partir de um promptbox que solicita o nome da função.
   @type  Static Function
   @author Kleyson Gomes
   @since 04/0/2023
   @version 12.33
   @return Array 
*/

USER FUNCTION ExecFonte()

    LOCAL cNomefuncao    := ""  //variavel que deve receber o nome do fonte digitado
    LOCAL aPergs        := {}  //Array que armazena as perguntas do ParamBox()

//adiciona elementos no array de perguntas
    aAdd( aPergs , {1, "Nome da função ", space(20), "", "", "", "", 40, .T.} )

//If que valida o OK do parambox() e passa o conteudo do parametro para a variavel
    IF ParamBox(aPergs, "EXECUTAR FUNÇÃO DE USUÁRIO" )
        cNomefuncao := ALLTRIM( MV_PAR01 )
    ELSE
        RETURN
    ENDIF

//Caso o usuario digite o U_ ou () no nome do fonte, retira esses caracteres
    cNomefuncao := StrTran( cNomefuncao , "U_" , "" )
    cNomefuncao := StrTran( cNomefuncao , "()" , "" )

//Valida se a funcao existe no rpo
    IF !FindFunction( cNomefuncao )
        MsgAlert( "Funcao não encontrada ou não compilada!" , "ops!" )
        RETURN u_ExecFonte()
    ENDIF

//complementa a variavel e executa macro substituicao chamando a rotina
    cNomefuncao := "U_"+cNomefuncao+"()"
    &cNomefuncao

RETURN
