/* -------------------------------------------------------------------------------------------

Copyright 2015-2019 J�lio Wittwer ( siga0984@gmail.com | http://siga0984.wordpress.com/ )

� permitido, gratuitamente, a qualquer pessoa que obtenha uma c�pia deste software 
e dos arquivos de documenta��o associados (o "Software"), para negociar o Software 
sem restri��es, incluindo, sem limita��o, os direitos de uso, c�pia, modifica��o, fus�o,
publica��o, distribui��o, sublicenciamento e/ou venda de c�pias do Software, 
SEM RESTRI��ES OU LIMITA��ES. 

O SOFTWARE � FORNECIDO "TAL COMO EST�", SEM GARANTIA DE QUALQUER TIPO, EXPRESSA OU IMPL�CITA,
INCLUINDO MAS N�O SE LIMITANDO A GARANTIAS DE COMERCIALIZA��O, ADEQUA��O A UMA FINALIDADE
ESPEC�FICA E N�O INFRAC��O. EM NENHUM CASO OS AUTORES OU TITULARES DE DIREITOS AUTORAIS
SER�O RESPONS�VEIS POR QUALQUER REIVINDICA��O, DANOS OU OUTRA RESPONSABILIDADE, SEJA 
EM A��O DE CONTRATO OU QUALQUER OUTRA FORMA, PROVENIENTE, FORA OU RELACIONADO AO SOFTWARE. 

                    *** USE A VONTADE, POR SUA CONTA E RISCO ***

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without 
restriction, including without limitation the rights to use, copy, modify, merge, publish, 
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom 
the Software is furnished to do so, WITHOUT RESTRICTIONS OR LIMITATIONS. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT 
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE. 

                    ***USE AS YOU WISH , AT YOUR OWN RISK ***

------------------------------------------------------------------------------------------- */



/* ======================================================

Funcoes de Conversao String / Hexadecimal 

====================================================== */

#include "zLibDec2Hex.ch"

// ----------------------------------------
// Recebe uma string bin�ria
// Retorna uma uma string ASCII em formato de DUMP de mem�oria
// em Hexadecimal --  Cada linha com 16 bytes

USER Function STR2HexD(cBuffer,nOffset,nLength)
Local cHexLine := ''
Local cCharLine := ''
Local nI , cChar , nChar , cRet := ''
Local nTamBuff := len(cBuffer)

// Valores DEFAULT
IF nOffset = NIL ; nOffset := 1 ; Endif
IF nLength = NIL ; nLength := nTamBuff ; Endif

cBuffer := Substr(cBuffer,nOffset,nLength)

For nI := 1 to nTamBuff
	cChar := substr(cBuffer,nI,1)
	nChar := Asc(cChar)
	If nChar < 32 
		cCharLine += "." 
	Else
		cCharLine += cChar
	Endif
	cHexLine += DEC2HEX(nChar) + ' '
	If (nI%16) == 0
		cRet += cHexLine+' | '+cCharLine + Chr(13)+Chr(10)
		cCharLine := ''
		cHexLine  := ''
	Endif
Next

If !empty(cHexLine)
	cRet += padr(cHexLine,48)+' | '+ padr(cCharLine,16) + Chr(13)+Chr(10)
Endif

Return cRet


// ----------------------------------------
// Recebe uma string bin�ria
// Retorna uma uma string ASCII hexadecimal representando
// os bytes da scring informada como parametro

USER Function STR2Hex(cBuffer,nOffset,nLength)
Local nI , cRet := ''
Local nTamBuff := len(cBuffer)

// Valores DEFAULT
IF nOffset = NIL ; nOffset := 1 ; Endif
IF nLength = NIL ; nLength := nTamBuff ; Endif

cBuffer := Substr(cBuffer,nOffset,nLength)

For nI := 1 to nTamBuff
	cRet += DEC2HEX(Asc(substr(cBuffer,nI,1)))
Next

cBuffer := ''

Return cRet
