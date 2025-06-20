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


#INCLUDE 'RWMake.ch'
#INCLUDE 'Totvs.ch'
#INCLUDE 'ParmType.ch'

/* ======================================================

Funcoes de Conversao Decimal / Hexa e vice-versa

====================================================== */


// ----------------------------------------
// Converte um valort decimal de 0 a 255 para Hexadecimal

STATIC __aHEX := {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'}

USER Function ZDEC2HEX(nByte	AS Numeric	)	AS Character

	//Declaracao de variaveis----------------------------------------------------------------------
	Local nL,nH			AS Numeric

	//Parametros da rotina-------------------------------------------------------------------------
	ParamType 0		VAR nByte		AS Numeric

	//Inicializa Variaveis-------------------------------------------------------------------------
	nL := ( nByte % 16 )	
	nH := ( nByte-nL) / 16

Return __aHEX[nH+1]+__aHEX[nL+1]

// ----------------------------------------
// Converte um valor hexadecimal de 00 a FF para decimal
USER  Function ZHEX2DEC(cHex	AS Numeric	)	AS Numeric

	//Declaracao de variaveis----------------------------------------------------------------------
	Local nH,nL			AS Numeric

	//Parametros da rotina-------------------------------------------------------------------------
	ParamType 0		VAR cHex		AS Character

	//Inicializa Variaveis-------------------------------------------------------------------------
	nH := asc(Upper(substr(cHex,1,1)))
	nL := asc(Upper(substr(cHex,2,1)))

	If nH <= 57 ;    nH -= 48 ; Else ;    nH -= 55 ; Endif
	If nL <= 57 ;    nL -= 48 ; Else ;    nL -= 55 ; Endif

Return (nH*16)+nL
