#include 'totvs.ch'
#include 'protheus.ch'
#include 'TopConn.ch'

/* {Protheus.doc} SearchInvite
   Função que valida números de telefone celular
   @type  Static Function
   @author Kleyson Gomes
   @since 16/08/2023
   @version 12.33
   @return Array */
User Function validacell(aCells)

  Local aValidos := {}
  Local nDDD
  Local lDDDVal, lNumVal
  Local e, f, k

  //Inicia serie de validações
  For e := 1 To Len(aCells)
    nDDD    := 11
    lDDDVal := .F.
    f       := 0
    k       := 0

    If Len(aCells[e] ) == 11 //Qtd digitos
      
      For f := 1 To 99 
        If Left(aCells[e],2) == cValToChar(nDDD)//DDD é valido
            lDDDVal := .T.
            Exit
        EndIf
        nDDD++
      Next f

      If lDDDVal
        If Substr(aCells[e],3,1) == '9' //Digito obrigatorio
          
          For k := 1 to 9
            lNumVal := .F.
            cNumTeste := replicate(cValToChar(k),9)

            If Substr(aCells[e],3,9) <> cNumTeste //Número repetidos
              If Substr(aCells[e], k+2, 1) $'0,1,2,3,4,5,6,7,8,9' //São números
                lNumVal := .T.
              EndIf
            EndIf
          Next k
          
          //Se passou por todas as validações, adiciona o celular no array de validos
          If lNumVal
            aAdd(aValidos, aCells[e])
          EndIf
        EndIf
      EndIf
    EndIf

  Next e


Return aValidos
