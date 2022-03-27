Class dc.iris.count
{

ClassMethod Count() As %Status
{
	Kill ^COUNT
	Set tDebug = 1
	Do:tDebug ##class(util).DebugTEST("dc.iris.count - Count")
	//Do:tDebug ##class(util).DebugTEST("pWhere = "_pWhere)

	Set tQuote = """"
	Set tSC = $$$OK
	Set tTable = "dc_iris.transact"
	Set tWHERE = ""
	//If (pWhere '= "") Set tWHERE = " WHERE "_pWhere
	Set tQuery = "SELECT * FROM "_tTable_tWHERE
	Do:tDebug ##class(util).DebugTEST("tQuery = "_tQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) Do ##class(util).DebugStatus(tSC)
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
	//Write !,"<tr><th>Date</th><th>Account</th><th>Check</th><th>Merchant</th><th>Category</th><th>Debit</th><th>Credit</th></tr>"
	//Do ..OutputTableHead()
	Set (tSumCredit, tSumDebit) = 0
	While tResult.%Next() {
		Set (tYear, tMonth) = 0
		Set tValue = tResult.ID
		//Write !,"<td>",$ZDATE(tResult.TranDate),"</td>"
		Set tTranDate = tResult.TranDate
		If (tTranDate ? 1.2N1"/"1.2N1"/"1.4N) {
			Set tMonth = $Piece(tTranDate,"/",1)
			Set tYear = $Piece(tTranDate,"/",3)
		}
		//Write !,"<td>",$ZTIME(tResult.TranTime),"</td>"
		Set tAccount = tResult.Account
		//Write !,"<td>",tResult.CheckNumber,"</td>"
		//Set tQuery = "SELECT Nickname FROM Riches.Merchant WHERE ID = "_tResult.Merchant
		//Set tSC = ##class(Util).ExecuteQueryOneValue(tQuery,.tDisplay)
		Set tMerchant = tResult.Merchant
		//Set tQuery = "SELECT Nickname FROM Riches.Category WHERE ID = "_tResult.Category
		//Set tSC = ##class(Util).ExecuteQueryOneValue(tQuery,.tDisplay)
		Set tCategory = tResult.Category
		If (tCategory = "") Set tCategory = 0
		Set tDebit = tResult.Debit
		Set tCredit = tResult.Credit
		Set tData = $Get(^COUNT(tCategory,tYear,tMonth))
		Set tCount = $Piece(tData,"^",1)
		Set tSumCredit = $Piece(tData,"^",2)
		Set tSumDebit = $Piece(tData,"^",3)
		Set tCount = tCount + 1
		Set tSumCredit = tSumCredit + tResult.Credit
		Set tSumDebit = tSumDebit + tResult.Debit
		Set ^COUNT(tCategory,tYear,tMonth) = tCount_"^"_tSumCredit_"^"_tSumDebit
	}
	Set tTotal = tResult.%ROWCOUNT
	Write tTotal," Transactions counted.",!
	Quit $$$OK
}

}
