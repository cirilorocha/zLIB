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



#include 'Protheus.ch'
#include 'zLibMath.ch'

/* ======================================================

Classe       ZPERMUTE
Autor        J�lio Wittwer
Data         09/2020
Descri��o    Classe de permuta��o simples de elementos de Array 

A permuta��o significa colocar os elementos fornecidos 
de forma nao repetida em todas as sequencias possiveis 

====================================================== */

  CLASS ZPERMUTE FROM LONGNAMECLASS

  DATA aElements     // Elementos do array a serem permutados
  DATA nSize         // Tamanho do Array de elementos

  METHOD NEW()       // Construtor, recebe numero de colunas e array a combinar 
  METHOD RUN()       // Executa um bloco de c�digo para cada combina��o processada 
  METHOD GETTOTAL()  // Calcula o numero total de combina��es 

  ENDCLASS

// ------------------------------------------------------
// Construtor 
// aElements � o array com os elementos a permutar. 

METHOD NEW( aElements ) CLASS ZPERMUTE

::aElements := aElements
::nSize     := len(aElements)

Return self

// ------------------------------------------------------
// Roda um codeblock para cada permuta��o calculada 

METHOD RUN(bBLock) CLASS ZPERMUTE
Local aPermute := aCLone(::aElements)
Local aControl := array(::nSize)
Local nPos := 1
Local nI

  For nI := 1 to ::nSize
    aControl[nI] := 1
  Next
  
  eval(bBLock,aPermute)

  while nPos <= ::nSize
    
    if aControl[nPos] < nPos

      if (nPos % 2) != 0
        xSwap := aPermute[1]
        aPermute[1] := aPermute[nPos] 
        aPermute[nPos] := xSwap
      else
        xSwap := aPermute[aControl[nPos]]
        aPermute[aControl[nPos]] := aPermute[nPos] 
        aPermute[nPos] := xSwap
      endif

      eval(bBLock,aPermute)
      
      aControl[nPos]++
      nPos := 1
    else
      aControl[nPos] := 1
      nPos++
    endif
  enddo

Return 


// ------------------------------------------------------
// Calcula o numero total de permuta��es possiveis
// baseado nos parametros ( numero de elementos ) 

METHOD GETTOTAL() CLASS ZPERMUTE
Local nTot := zFatorial( ::nSize )
Return nTot


