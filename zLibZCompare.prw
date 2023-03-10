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

Funcao de Compara��o zCompare()

Compara��o de tipo e conte�do exatamente igual
Compara tamb�m arrays.

Retorno :

0 = Conte�dos id�nticos
-1 = Tipos diferentes
-2 = Conte�do diferente
-3 = Numero de elementos (Array) diferente

====================================================== */

USER Function zCompare(	xValue1	,;	//01 xValue1
						xValue2	);	//02 xValue2
							AS Numeric

	//Declaracao de variaveis----------------------------------------------------------------------
	Local cType1 := valtype(xValue1)		AS Character
	Local nI, nT, nRet := 0					AS Numeric

	//---------------------------------------------------------------------------------------------
	If cType1 == valtype(xValue2)
		If cType1 = 'A'
			// Compara��o de Arrays 
			nT := len(xValue1)
			If nT <> len(xValue2)
				// Tamanho do array diferente
				nRet := -3
			Else
				// Compara os elementos
				For nI := 1 to nT
					nRet := U_zCompare(xValue1[nI],xValue2[nI])
					If nRet < 0
						// Achou uma diferen�a, retorna 
						EXIT
					Endif
				Next
			Endif
		Else
			If !( xValue1 == xValue2 )
				// Conteudo diferente
				nRet := -2
			Endif
		Endif
	Else
		// Tipos diferentes
		nRet := -1
	Endif

Return nRet
