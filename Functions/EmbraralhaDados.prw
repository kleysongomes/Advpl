#include 'totvs.ch'
#include 'protheus.ch'
#include 'TOPCONN.CH'

/*/{Protheus.doc} shuffle
Function that performs the shuffling of customer data for identity validation.
@type user function
@version  12.33
@author Kleyson Gomes
@since 18/05/2023
@param cCpf, character, Customer CPF
@param nOrder, number, Login Attempt Number
@return jData, scrambled data
/*/
User Function shuffle(cCpf, nOrder)

	Local cStreet       := ""
	Local cDistrict     := ""
	Local cCity         := ""
	Local cState        := ""
	Local cAName        := ""
	Local nIndex        := 0
	Local nSum          := 0
	Local nCont         := 1
	Local dBirth        := Date()
	Local __aTrueA      := {}
	Local __aTrueD      := {}
	Local __aFalse      := {}
	Local __aFalseD     := {}
	Local QuestA        := {}
	Local QuestD        := {}
	Local jData         := JsonObject():new()
	local lProceed      := .T.
  local nLoop         := 1

  Default nOrder      := Random(1, 5) 
  // Default cCpf        := "70111665485"

  // RPCSetType(3)
	// RpcSetEnv("03", "01")

  sa1->(DbSetOrder(3))

  If !sa1->(DbSeek(/*xFilial("ZC3")*/"  " + cCpf)) //<---------------------
    jData['status']   := 'error'
    jData['message']  := 'CPF não encontrado'

    sa1->(DbClosearea())
    Return jData
  endIf

  cStreet   :=  encodeUTF8(Alltrim(sa1->a1_end))
  cDistrict :=  encodeUTF8(Alltrim(sa1->a1_bairro))
  cCity     :=  encodeUTF8(Alltrim(sa1->a1_mun))
  cState    :=  encodeUTF8(Alltrim(sa1->a1_est))
  dBirth    :=  sToD(dToS(sa1->a1_dtnasc))
  nSum      :=  Random(1, 30)

  aAdd(__aTrueA, {'Address1', cStreet     + " - " + cDistrict  + " - " + cCity                          })
  aAdd(__aTrueA, {'Address2', cStreet     + " - " + cCity      + " - " + cDistrict                      })
  aAdd(__aTrueA, {'Address3', cDistrict   + " - " + cStreet    + " - " + cCity                          })
  aAdd(__aTrueA, {'Address4', cDistrict   + " - " + cCity      + " - " + cStreet                        })
  aAdd(__aTrueA, {'Address5', cCity       + " - " + cStreet    + " - " + cDistrict                      })

  aAdd(__aTrueD, {'Birth1',   dtoc(dBirth)                                                              })
  aAdd(__aTrueD, {'Birth2',   Day2Str(dBirth)                                                           })
  aAdd(__aTrueD, {'Birth3',   Month2Str(dBirth)                                                         })
  aAdd(__aTrueD, {'Birth4',   Year2Str(dBirth)                                                          })
  aAdd(__aTrueD, {'Birth5',   Day(dBirth) + nSum                                                        })

  aAdd(QuestA,   {'Address1', encodeUTF8('o seu endereço?')                                             })
  aAdd(QuestA,   {'Address2', 'sua logradouro, cidade e bairro?'                                        })
  aAdd(QuestA,   {'Address3', 'seu bairro, logradouro e cidade?'                                        })
  aAdd(QuestA,   {'Address4', 'seu bairro, cidade e logradouro?'                                        })
  aAdd(QuestA,   {'Address5', 'sua cidade, logradouro e bairro?'                                        })

  aAdd(QuestD,   {'Birth1',   'a sua data de nascimento?'                                               })
  aAdd(QuestD,   {'Birth2',   'o DIA do seu nascimento?'                                                })
  aAdd(QuestD,   {'Birth3',   encodeUTF8('o MÊS do seu nascimento?')                                    })
  aAdd(QuestD,   {'Birth4',   'o ANO do seu nascimento?'                                                })
  aAdd(QuestD,   {'Birth5',   'o DIA do seu nascimento + ' + cValToChar(nSum)                           })

  nIndex                :=   nOrder
  jData['AddressTrue']  := __aTrueA[nIndex]
  jData['DateTrue']     := __aTrueD[nIndex]
  jData['QuestionA']    :=   QuestA[nIndex]
  jData['QuestionD']    :=   QuestD[nIndex]
  //jData['Question']     :=   "Qual das opções contém"
  jData['Question'] := encodeUTF8( "Qual das opções contém",  )
  
  Do Case
    Case nOrder == 1
      cOrder := "%qStreet%"
    Case nOrder == 2
      cOrder := "%qDistrict%"
    Case nOrder == 3
      cOrder := "%qCity%"
    Case nOrder == 4
      cOrder := "%qDistrict, qCity%"
    Case nOrder == 5
      cOrder := "%qCity, qDistrict%"
  EndCase


  BeginSql alias 'fAddress'

    Select 
      sa1.a1_end as qStreet, 
      sa1.a1_bairro as qDistrict,  
      sa1.a1_mun as qCity,
      sa1.a1_dtnasc as qBirth
    From %table:sa1% sa1
    Where sa1.d_e_l_e_t_ = ' '
      and sa1.a1_mun = UPPER(%exp:cCity%)
      and sa1.a1_est = %exp:cState%
      and sa1.a1_end <> %exp:cStreet%
      and sa1.a1_end <> ' '
      and sa1.a1_bairro <> ' '
      and a1_dtnasc <> %exp:dBirth%
      and a1_dtnasc <> ' '
      and length(trim(sa1.a1_end)) > 5
      and ROWNUM <= 10
      ORDER BY dbms_random.value

  EndSql

  while fAddress->(!eof()) .and. nCont <= 3

		cteste := jData:GetNames()

		nLoop = 1
		lProceed = .T.
		while nLoop <= Len(cteste) .and. lProceed = .T.
      if ValType(jData[cteste[nLoop]]) != "A"
				nLoop++
        loop
      endif

			if   jData[cteste[nLoop]][2] == dtoc(sToD(fAddress->qBirth));
					.OR. jData[cteste[nLoop]][2] == Day2Str(sToD(fAddress->qBirth));
					.OR. jData[cteste[nLoop]][2] == Month2Str(sToD(fAddress->qBirth));
					.OR. jData[cteste[nLoop]][2] == Year2Str(sToD(fAddress->qBirth)) 
          lProceed = .F.
      else
          lProceed = .T.
			endif
			nLoop++
			enddo

		If cDistrict != Alltrim(fAddress->qDistrict) .AND. lProceed

			cAName    := "AddressFalse" + cValToChar(nCont)
			cDName    := "DateFalse" + cValToChar(nCont)
			cStreet   := Alltrim(fAddress->qStreet)
			cDistrict := Alltrim(fAddress->qDistrict)
			cCity     := Alltrim(fAddress->qCity)
			dBirth    := sToD(fAddress->qBirth)

      aAdd(__aFalse, {cAName, cStreet   + " - " + cDistrict + " - " + cCity                           })
      aAdd(__aFalse, {cAName, cStreet   + " - " + cCity     + " - " + cDistrict                       })
      aAdd(__aFalse, {cAName, cDistrict + " - " + cStreet   + " - " + cCity                           })
      aAdd(__aFalse, {cAName, cDistrict + " - " + cCity     + " - " + cStreet                         })
      aAdd(__aFalse, {cAName, cCity     + " - " + cStreet   + " - " + cDistrict                       })
                      
      aAdd(__aFalseD, {cDName, dtoc(dBirth)                                                           })
      aAdd(__aFalseD, {cDName, Day2Str(dBirth)                                                        })
      aAdd(__aFalseD, {cDName, Month2Str(dBirth)                                                      })
      aAdd(__aFalseD, {cDName, Year2Str(dBirth)                                                       })
      aAdd(__aFalseD, {cDName, Day(dBirth) + nSum                                                     })
      
      If jData[cAName] != __aFalse[nIndex]
        
        jData[cAName] := __aFalse[nIndex]
        jData[cDName] := __aFalseD[nIndex]
        
        nCont := nCont + 1
        
        __aFalse  := {}
        __aFalseD := {}

      EndIf

    EndIf

    fAddress->(DbSkip())
  EndDo

  fAddress->(DbClosearea())
  sa1->(DbClosearea())
Return jData
