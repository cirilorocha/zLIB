#INCLUDE 'RWMake.ch'
#INCLUDE 'Totvs.ch'
#INCLUDE 'ParmType.ch'

//##################################################################################################
//##+========+=================================+=======+====================+======+=============+##
//##|Programa| GravarDBFTab                    | Autor | Cirilo Rocha       | Data | 10/03/2023  |##
//##+========+=================================+=======+====================+======+=============+##
//##|Desc.   | Pequeno fonte exemplo de usar a classe zDBFFile para efetuar a grava��o de arqui- |##
//##|        |  vos em DBF                                                                       |##
//##|        | Baseado nos fontes de J�lio Wittwer                                               |##
//##|        | https://siga0984.wordpress.com/2019/01/04/lendo-dbf-em-advpl-sem-driver-ou-rdd/   |##
//##|        | https://github.com/siga0984/zLIB                                                  |##
//##|        |                                                                                   |##
//##|        | Este exemplo est� Otimizado ao m�ximo para opera��o de c�pia de uma tabela do ban-|##
//##|        |  co para um arquivo DBF, existe outro exemplo com a grava��o campo a campo tamb�m |##
//##+========+==========+========================================================================+##
//##|  DATA  | ANALISTA | MANUTEN��O EFETUADA                                                    |##
//##+========+==========+========================================================================+##
//##|        |          |                                                                        |##
//##|        |          |                                                                        |##
//##|        |          |                                                                        |##
//##+========+==========+========================================================================+##
//##################################################################################################
//Posi��es do array aStruct, apenas para melhorar a leitura do fonte!
Static nST_CAMPO	:= 1	AS Integer
//Static nST_TIPO		:= 2	AS Integer
//Static nST_TAMANHO	:= 3	AS Integer
//Static nST_DECIMAL	:= 4	AS Integer
//-------------------------------------------------------------------------------------------------
User Function GravarDBFTab()	AS Logical

	//Declaracao de variaveis----------------------------------------------------------------------
	Local aDados			AS Array
	Local aPosSrc			AS Array
	Local aStruSrc			AS Array
	Local aStruTgt			AS Array
	Local cTabSrc			AS Character
	Local oDBF				AS Object
	Local lOK	:= .T.		AS Logical
	Local nX				AS Numeric
	Local nPos				AS Numeric

	//Inicializa Variaveis-------------------------------------------------------------------------
	cTabSrc		:= 'SF4'
	(cTabSrc)->(dbSetOrder(1))	//Abre a tabela origem!
	aStruSrc	:= (cTabSrc)->(dbStruct())	//Obtenho a estrutura para criar o destino e para otimiza��o da grava��o!
	
	//Instancia objeto que ser� utilizado
	oDBF := zDBFFile():New('\system\bkp_'+cTabSrc+'.dbf')
	
	//Se o arquivo destino j� existir apaga!-------------------------------------------------------
	If oDBF:Exists()
		lOK	:= MsErase(oDBF:FileName(),/*cIndice*/,'DBFCDXADS')
	EndIf

	If lOK
		If 	.Not. oDBF:Create(aStruSrc) .Or. ;	//Cria o arquivo destino
			.Not. oDBF:Open(.T.,.T.)			//Abre o arquivo para altera��o em modo exclusivo

			UserException( oDBF:GetErrorStr() )
			lOK	:= .F.
		Endif
	EndIf

	If lOK
		//Preciso obter a estrutura criada exatamente como no destino, por causa de campos memo as
		// vezes ela n�o respeita a ordem dos campos passados na cria��o
		aStruTgt	:= oDBF:dbStruct()

		//Monta array aPosSrc para otimiza��o da grava��o!
		aPosSrc		:= Array(Len(aStruTgt))
		For nX := 1 to Len(aStruTgt)
			nPos	:= aScan(aStruSrc,{|x| RTrim(x[nST_CAMPO]) == RTrim(aStruTgt[nX][nST_CAMPO]) })
			If nPos <= 0 
				UserException( 	'Problema na estrutura da tabela '+cTabSrc+'.'+CRLF+;
								'Campo Destino: '+aStruTgt[nX][nST_CAMPO]+' n�o encontrado na origem!' )
				lOk	:= .F.
				Exit
			EndIf
			aPosSrc[nX]	:= nPos
		Next
	EndIf
	
	If lOK

		aDados	:= Array(Len(aStruTgt))
		(cTabSrc)->(dbGoTop())
		While (cTabSrc)->(!EOF())
			//Monta registro para grava��o!
			For nX := 1 to Len(aStruTgt)
				//Lendo desta forma � muito r�pido, por isso uso esse array aPosSrc j� com as posi��es
				// mapeadas dos campos destino em rela��o a origem.
				aDados[nX]	:= (cTabSrc)->(FieldGet(aPosSrc[nX]))
			Next
			
			//Este m�todo foi criado com a finalidade de j� appendar o registro com todos os dados
			// aumentando muito a performance na grava��o em rela��o a grava��o de campo a campo
			oDBF:Insert(aDados,(cTabSrc)->(Deleted()))

			(cTabSrc)->(dbSkip())
		EndDo
	EndIf
	
	//Limpa objeto da mem�ria
	If ValType(oDBF) == 'O'
		oDBF:Close()
		oDBF:Destroy()
			
		FreeObj(oDBF)
	EndIf

	//Fecha tabelas abertas
	If Select(cTabSrc) > 0
		(cTabSrc)->(dbCloseArea())
	EndIf

Return lOK
