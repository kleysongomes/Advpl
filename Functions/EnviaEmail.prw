#INCLUDE "rwmake.ch"
#include 'tbiconn.ch' 
#include 'ap5mail.ch' 
#INCLUDE "PROTHEUS.CH"


User Function EnviaEmail(cAssunto, cTo, cMensagem, cAnexos, cBcc, cServer, cAccount, cPassword, cEnviador, lBaseTeste, cCc)

	Local lResult		:= .F.		
	Local lEnviado		:= .F.		// Resultado da tentativa de comunicacao com servidor de E-Mail
	
	Default cServer		:= GetMV("MV_RELSERV")
	Default cAccount	:= GetMV("MV_RELACNT")
	Default cPassword 	:= GetMV("MV_RELPSW")
	Default cEnviador 	:= GetMV("MV_RELACNT")
	Default cAnexos		:= ""
	Default cBcc		:= ""
	Default cCc			:= ""
	Default lBaseTeste	:= Alltrim(GetServerIp()) == "xxx.xxx.xx.xxx"
	
	/*	Caso o server sendo executado seja base de testes, n�o envia o e-mail para o publico, 
		somente para quem esta logado	*/
	If lBaseTeste
		/*Caso a conex�o seja com interface*/
		If !IsBlind()
			cTo := UsrRetMail( __cUserId )
			cAssunto := "(Base de Testes)" + cAssunto
		EndIf
	EndIf
	//����������������������������������������Ŀ
	//� Tenta conexao com o servidor de E-Mail �
	//������������������������������������������
	ConOut('---------------------- ENVIO DE E-MAIL ----------------------------------' + CRLF)
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult // Resultado da tentativa de conex�o
	
	If lResult
		conout("Conectado com servidor de E-Mail - " + cServer + CRLF)
	else
		conout("N�o foi poss�vel conectar ao servidor de E-Mail - " + cServer + CRLF)
	EndIf	
	
	If Mailauth(cAccount,cPassword)
		conout("Autenticado servidor de E-Mail - " + cServer + CRLF)	
	else
		conout("N�o Autenticado servidor de E-Mail - " + cServer + CRLF)
	EndIf

	If !lResult
		MsgInfo("N�o foi poss�vel se conectar no servidor de e-mail", Funname())
	Else
		SEND MAIL;
		FROM cEnviador;
		TO cTo;
		CC cCc;
		BCC cBcc;
		SUBJECT cAssunto;
		BODY cMensagem;
		ATTACHMENT cAnexos;
		RESULT 	lEnviado             	// Resultado da tentativa de envio
		DISCONNECT SMTP SERVER

		If lEnviado
			ConOut('---------------------- ENVIO FINALIZADO ---------------------------------' + CRLF)
		else
			ConOut('---------------------- E-MAIL NAO ENVIADO ---------------------------------' + CRLF)		
		EndIf	
	EndIf
	
Return lResult
