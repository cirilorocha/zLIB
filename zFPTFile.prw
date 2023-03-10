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
#INCLUDE 'CXInclude.ch'
#include 'fileio.ch'
#include "zLibNBin.ch"

/* ==========================================================

Classe 		ZFPTFILE
Autor		Julio Wittwer
Data		01/2019
Descri��o 	Classe de manuten��o de arquivo DBF MEMO
			Formato FTP ( FoxPro2 ) 

- Implementa��o de Leitura e Grava��o 
- Cria��o do FPT File usando Block Size de 16K 

O processo de grava��o � r�pido, porem nao h� mecanismo eficiente 
Implementado para reaproveitamento de espa�os vazios. Posteriormente 
pode ser implementado uma estrutura, reservando alguns blocos, 
para criar um mapa dos espa�os livres para reaproveitamento 
			
========================================================== */

CLASS ZFPTFILE //FROM LONGNAMECLASS

	PUBLIC DATA oDBF	 		AS Object		// Objeto ZDBFFILE owner do MEMO 
	PUBLIC DATA cFileName 		AS Character	// Nome do arquivo FPT
	PUBLIC DATA nHMemo    		AS Numeric		// Handler do arquivo 
	PUBLIC DATA nNextBlock		AS Numeric		// Proximo bloco para inser��o de dados 
	PUBLIC DATA nBlockSize		AS Numeric		// Tamanho do bloco em bytes 
	PUBLIC DATA lExclusive		AS Logical		// Arquivo aberto em modo exclusivo ?
	PUBLIC DATA lCanWrite 		AS Logical		// Arquivo aberto para gravacao 

	PUBLIC METHOD NEW()		 	CONSTRUCTOR		// Construtor
	PUBLIC METHOD CREATE()		AS Logical		// Cria o arquivo 
	PUBLIC METHOD OPEN()		AS Logical		// Abre o FPT 
	PUBLIC METHOD CLOSE()						// Fecha o FPT
	PUBLIC METHOD READMEMO()	AS Character	// Le um memo armazenado em um bloco
	PUBLIC METHOD WRITEMEMO()	AS Numeric		// Insere ou atualiza um memo em um bloco 

ENDCLASS
              
// ----------------------------------------------------------
// Construtor
// Recebe o objeto ZDBFFILE e o nome do arquivo FPT 

METHOD NEW(_oDBF,_cFileName) CLASS ZFPTFILE

	//Parametros da rotina-------------------------------------------------------------------------
	ParamType 0		VAR _oDBF			AS Object
	ParamType 1		VAR _cFileName		AS Character

	//---------------------------------------------------------------------------------------------
	::oDBF       := _oDBF
	::cFileName  := _cFileName
	::nHMemo     := -1
	::nBlockSize := 16384
	::nNextBlock := 1 
	::lExclusive := .F.
	::lCanWrite  := .F.

Return self


// ------------------------------------------------------------------------------------------------
// Cria��o do arquivo 
// Cria um arquivo FPT vazio 

METHOD CREATE() CLASS ZFPTFILE
	
	//Declaracao de variaveis----------------------------------------------------------------------
	Local cHeader			AS Character
	Local cNextBlock		AS Character
	Local cBlockSize		AS Character
	Local cFiller1			AS Character
	Local cFiller2			AS Character
	Local nHFile			AS Numeric

	// Cria o arquivo MEMO 
	nHFile := FCreate(::cFileName)

	If nHFile == -1
		Return .F.
	Endif

	// Cria o Header ( 512 bytes ) 
	// Block Size = 16 K

	/*
	0 | Number of next        |  ^
	1 | available block       |  |
	2 | for appending data    | Header
	3 | (binary)           *1 |  |
	|-----------------------|  |
	4 | ( Reserved )          |  |    
	5 |                       |  |
	|-----------------------|  |
	6 | Size of blocks N   *1 |  |
	7 |                    *2 |  |
	*/

	// ----- Build 512 Bytes FPT Empty File Header -----
	cNextBlock := NtoBin4(1)                     // Proximo bloco livre para escrita 
	cFiller1   := chr(0) + chr(0)               
	cBlockSize := NToBin2( ::nBlockSize )                // Tamanho do Bloco 
	cFiller2   := replicate( chr(0) , 504 )       

	// Monta o Header do arquivo
	cHeader := cNextBlock + cFiller1 + cBlockSize +cFiller2

	// Grava o header em disco 
	fWrite(nHFile,cHEader,512)
	FClose(nHFile)

Return .T. 

// ----------------------------------------------------------
// Abertura do arquivo FPT 
// Recebe os mesmos modos de abertura do ZDBFFILE

METHOD OPEN(lExclusive	,;	//01 lExclusive
			lCanWrite	);	//02 lCanWrite
				CLASS ZFPTFILE

	//Declaracao de variaveis----------------------------------------------------------------------
	Local cBuffer := ''		AS Character
	Local nFMode := 0 		AS Numeric

	//Parametros da rotina-------------------------------------------------------------------------
	ParamType 0		VAR lExclusive		AS Logical				Optional Default .F.
	ParamType 1		VAR lCanWrite		AS Logical				Optional Default .F.

	::lExclusive := lExclusive
	::lCanWrite  := lCanWrite

	If lExclusive
		nFMode += FO_EXCLUSIVE
	Else
		nFMode += FO_SHARED
	Endif

	If lCanWrite
		nFMode += FO_READWRITE
	Else
		nFMode += FO_READ
	Endif

	// Abre o arquivo MEMO 
	::nHMemo := FOpen(::cFileName,nFMode)

	IF ::nHMemo == -1
		Return .F. 
	Endif

	// Le  o Header do arquivo ( 512 bytes ) 
	fSeek(::nHMemo,0)
	fRead(::nHMemo,@cBuffer,512)

	// Pega o numero do proximo bloco para append 
	::nNextBlock  := Bin4toN( substr(cBuffer,1,4) )

	// Le o Block Size do arquivo 
	::nBlockSize := Bin2ToN( substr(cBuffer,7,2) )

	conout("")
	conout("FPT Next Append Block ......: "+cValToChar(::nNextBlock))
	conout("FPT Block Size ...... ......: "+cValToChar(::nBlockSize))
	conout("")

Return .T. 

// ----------------------------------------------------------
// Fecha o arquivo FPT

METHOD CLOSE() CLASS ZFPTFILE

	IF ::nHMemo != -1
		fClose(::nHMemo)
	Endif

	::nHMemo     := -1
	::nBlockSize := 16384
	::nNextBlock := 1 
	::lExclusive := .F.
	::lCanWrite  := .F.

Return


// ----------------------------------------------------------
// L� um campo memo armazenado em um Bloco
// Recebe o n�mero do bloco como par�metro

METHOD READMEMO(nBlock) CLASS ZFPTFILE

	//Declaracao de variaveis----------------------------------------------------------------------
	Local cMemo   := ''							AS Character
	Local cBlock  := space(8)					AS Character
	Local nFilePos := nBlock * ::nBlockSize		AS Numeric
	Local nRecType								AS Numeric

	//Parametros da rotina-------------------------------------------------------------------------
	ParamType 0		VAR nBlock		AS Numeric

	// Leitura de MEMO em Arquivo FPT
	// Offset 1-4 Record type 
	// Offset 5-8 Tamanho do registro

	fSeek(::nHMemo , nFilePos)
	fRead(::nHMemo,@cBlock,8)

	// Pega o tipo do Registro ( Offset 0 size 4 ) 
	nRecType := Bin4toN( substr(cBlock,1,4) )

	/*	
	Record Type 
	00h	Picture
	01h	Memo
	02h	Object
	*/

	If nRecType <> 1 
		UserException("Unsupported MEMO Record Type "+cValToChar(nRecType))
	Endif

	// Obrt�m o tamanho do registro ( Offset 4 Size 4 ) 
	nMemoSize := Bin4toN( substr(cBlock,5,4) )

	// L� o registro direto para a mem�ria
	fRead(::nHMemo,@cMemo,nMemoSize)

Return cMemo


// ------------------------------------------------------------
// Atualiza ou insere um valor em um campo memo 
// Se nBlock = 0 , Conteudo novo 
// Se nBlock > 0 , Conteudo j� existente 
//
// Release 20190109 - Tratar "limpeza" de campo. 
//                  - Ignorar inser��o de string vazia

METHOD WRITEMEMO( nBlock , cMemo ) CLASS ZFPTFILE

	//Declaracao de variaveis----------------------------------------------------------------------
	Local cBuffer := ''			AS Character
	Local nTamFile				AS Numeric
	Local nFiller				AS Numeric
	Local nFilePos				AS Numeric
	Local nMemoSize				AS Numeric
	Local nChuckSize			AS Numeric
	Local nUsedBlocks			AS Numeric
	Local nMaxMemoUpd			AS Numeric
	Local nFileSize				AS Numeric

	//Parametros da rotina-------------------------------------------------------------------------
	ParamType 0		VAR nBlock		AS Numeric
	ParamType 1		VAR cMemo		AS Character

	If ( !::lCanWrite )
		UserException("ZFPTFILE::WRITEMEMO() FAILED - FILE OPENED FOR READ ONLY")
	Endif

	If  Len(cMemo) == 0 .AND. nBlock == 0 
		// Atualiza��o de campo memo vazia. 
		// Se o block � zero, estou inserindo, ignora a opera��o. 
		return 0 
	Endif

	If nBlock > 0
		
		// Eatou atualizando conte�do
		// verifica se cabe no blocco atual
		// Se nao couber , usa um novo .
		// Primeiro l� o tamanho do campo atual
		// e quantos blocos ele usa
		
		cBuffer  := space(8)
		nFilePos := nBlock * ::nBlockSize
		fSeek(::nHMemo , nFilePos)
		fRead(::nHMemo,@cBuffer,8)
		nMemoSize := Bin4toN( substr(cBuffer,5,4) )
		nChuckSize :=  nMemoSize + 8
		
		// Calcula quantos blocos foram utilizados
		nUsedBlocks := int( nChuckSize / ::nBlockSize )
		IF nChuckSize > ( nUsedBlocks * ::nBlockSize)
			nUsedBlocks++
		Endif
		
		// Calcula o maior campo memo que poderia reaproveitar
		// o(s) bloco(s) usado(s), descontando os 8 bytes de controle
		nMaxMemoUpd := (nUsedBlocks * ::nBlockSize) - 8
		
		If len(cMemo) > nMaxMemoUpd
			
			// Passou, nao d� pra reaproveitar.
			// Zera o nBlock, para alocar um novo bloco
			// Como se o conteudo estivesse sendo inserido agora
			
			nBlock := 0
			
		Else
			
			// Cabe no mesmo bloco ... remonta o novo buffer
			// e atualiza o campo. 
			
			// Mesmo que eu esteja atualizando o campo para uma string vazia 
			// eu mantenho o bloco alocado, para posterior reaproveitamento 
			
			nMemoSize  := len(cMemo)
			nChuckSize :=  nMemoSize + 8
			
			cBuffer := NtoBin4( 01 ) // Tipo de registro = Memo
			cBuffer += NtoBin4( nMemoSize )
			cBuffer += cMemo
			
			// Posiciona no inicio do bloco j� usado
			fSeek(::nHMemo , nFilePos)
			fWrite(::nHMemo,cBuffer,nChuckSize)

		Endif
		
	Endif

	If nBlock == 0 
		
		// Pega o tamanho do arquivo 
		nFileSize := fSeek(::nHMemo,0,2)

		// Estou inserindo um conteudo em um campo memo ainda nao utilizado. 
		// Ou estou usando um novo bloco , pois o campo memo 
		// nao cabe no bloco anteriormente utilizado 
		// Utiliza o proximo bloco para inser��o do Header
		
		nTamFile := ::nNextBlock * ::nBlockSize

		If nFileSize < nTamFile
			// Se o ultimo bloco do arquivo ainda nao foi preenchido com um "Filler" 
			// at� o inicio do proximo bloco , preenche agora
			nFiller := nTamFile - nFileSize
			fSeek(::nHMemo,0,2)
			fWrite(::nHMemo , replicate( chr(0) , nFiller ) , nFiller ) 
		Endif
		
		// Monta o buffer para gravar 
		
		nMemoSize := len(cMemo)
		
		cBuffer := NtoBin4( 01 ) // Tipo de registro = Memo 
		cBuffer += NtoBin4( nMemoSize )
		cBuffer += cMemo
		
		// Tamanho do campo memo no bloco 
		// soma 8 bytes ( tipo , tamanho ) 
		nChuckSize :=  nMemoSize + 8
		
		// Posiciona no proximo bloco livre e grava
		nFilePos := ::nNextBlock * ::nBlockSize 
		fSeek(::nHMemo,nFilePos)
		fWrite(::nHMemo,cBuffer,nChuckSize)
		
		// Guarda o bloco usado para retorno 
		nBlock := ::nNextBlock
		
		// Calcula quantos blocos foram utilizados 
		nUsedBlocks := int( nChuckSize / ::nBlockSize )
		IF nChuckSize > ( nUsedBlocks * ::nBlockSize)
			nUsedBlocks++
		Endif

		// Agora define o proximo bloco livre 
		// Soma no ultimo valor a quantidade de blocos usados 
		::nNextBlock += nUsedBlocks
		
		// Agora atualiza no Header
		fSeek(::nHMemo,0)
		fWrite( ::nHMemo , nToBin4(::nNextBlock) , 4 )

	Endif

// Retorna o numero do bloco usado para a opera��o 
Return nBlock

