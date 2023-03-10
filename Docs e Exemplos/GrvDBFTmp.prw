#INCLUDE 'RWMake.ch'
#INCLUDE 'Totvs.ch'
#INCLUDE 'ParmType.ch'

//##################################################################################################
//##+========+=================================+=======+====================+======+=============+##
//##|Programa| GrvDBFTmp                       | Autor | Cirilo Rocha       | Data | 10/03/2023  |##
//##+========+=================================+=======+====================+======+=============+##
//##|Desc.   | Pequeno fonte exemplo de usar a classe zDBFFile para efetuar a grava��o de arqui- |##
//##|        |  vos em DBF                                                                       |##
//##|        | Baseado nos fontes de J�lio Wittwer                                               |##
//##|        | https://siga0984.wordpress.com/2019/01/04/lendo-dbf-em-advpl-sem-driver-ou-rdd/   |##
//##|        | https://github.com/siga0984/zLIB                                                  |##
//##|        |                                                                                   |##
//##|        | Este exemplo � de uma grava��o simples, feita campo a campo mesmo, sem otimiza��o |##
//##|        |  do processo apenas a t�tulo did�tico, existe outro exemplo da grava��o otimizada |##
//##+========+==========+========================================================================+##
//##|  DATA  | ANALISTA | MANUTEN��O EFETUADA                                                    |##
//##+========+==========+========================================================================+##
//##|        |          |                                                                        |##
//##|        |          |                                                                        |##
//##|        |          |                                                                        |##
//##+========+==========+========================================================================+##
//##################################################################################################
User Function GrvDBFTmp()	AS Logical

	//Declaracao de variaveis----------------------------------------------------------------------
	Local aStruSrc			AS Array
	Local oDBF				AS Object
	Local lOK	:= .T.		AS Logical
	Local nX				AS Numeric

	//Inicializa Variaveis-------------------------------------------------------------------------
	aStruSrc	:= {}
	aAdd(aStruSrc,{'CAMPO_C','C',30,0})	//Caracter
	aAdd(aStruSrc,{'CAMPO_D','D',08,0})	//Data
	aAdd(aStruSrc,{'CAMPO_N','N',10,2})	//Num�rico
	aAdd(aStruSrc,{'CAMPO_M','M',10,0})	//MEMO

	//Instancia objeto que ser� utilizado
	oDBF := zDBFFile():New('\system\GrvDBFTmp.dbf')
	
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
		For nX := 1 to 100
			
			oDBF:Insert()	//Inclui um registro vazio na tabela, equivale a RecLock(.T.)
			
			oDBF:FieldPut('CAMPO_C',StrZero(nX,30))
			oDBF:FieldPut('CAMPO_D',dDataBase+nX)
			oDBF:FieldPut('CAMPO_N',nX/10)
			oDBF:FieldPut('CAMPO_M','texto aleat�rio para o campo memo '+strzero(nX,3))
			
			//For�a a grava��o dos dados, pode ser feito apenas no final tamb�m, pois, o Insert() 
			// for�a a grava��o antes de incluir um novo registro
			oDBF:Update()

		Next
	EndIf
	
	//Limpa objeto da mem�ria
	If ValType(oDBF) == 'O'
		oDBF:Close()
		oDBF:Destroy()
			
		FreeObj(oDBF)
	EndIf

Return lOK
