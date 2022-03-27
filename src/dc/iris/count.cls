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
		If $Data(^TRANSLATE("Category",tCategory)) Set tCategory = $Get(^TRANSLATE("Category",tCategory))
		If (tCategory = "") Set tCategory = 0
		Set tDebit = tResult.Debit
		Set tCredit = tResult.Credit
		If (tAccount '= ""),$Data(^TRANSLATE("Credit-Debit",tAccount)) {
			Set tCreditDebit = $Get(^TRANSLATE("Credit-Debit",tAccount))
			If (tCreditDebit = "Credit is Debit") {
				Set tData = tCredit
				Set tCredit = tDebit
				Set tDebit = tData
			}
		}
		//Set tData = $Get(^COUNT(tCategory,tYear,tMonth))
		Set tData = $Get(^COUNT(tYear,tMonth,tCategory))
		Set tCount = $Piece(tData,"^",1)
		Set tSumCredit = $Piece(tData,"^",2)
		Set tSumDebit = $Piece(tData,"^",3)
		Set tCount = tCount + 1
		Set tSumCredit = tSumCredit + tCredit
		Set tSumDebit = tSumDebit + tDebit
		//Set ^COUNT(tCategory,tYear,tMonth) = tCount_"^"_tSumCredit_"^"_tSumDebit
		Set ^COUNT(tYear,tMonth,tCategory) = tCount_"^"_tSumCredit_"^"_tSumDebit
	}
	Set tTotal = tResult.%ROWCOUNT
	Write tTotal," Transactions counted.",!
	Quit $$$OK
}

ClassMethod OutputTableData(
	pWhere As %String = "",
	pTrClick As %String = "window.location='Transact.csp?iAccount=#';",
	pMaxRows = -1) As %String
{
	Set tDebug = 1
	Do:tDebug ##class(util).DebugTEST("dc.iris.count - OutputTableData")
	Do:tDebug ##class(util).DebugTEST("pWhere = "_pWhere)
	Set tFilter = ""
	Set (tYear, tMonth) = ""
	// iFilter = NEXT^2022^12
	If (pWhere [ "iFilter") {
		Set tFilter = $Piece(pWhere," AND ",1,1)
		Set tFilter = $Piece(tFilter,"iFilter = ",2)
		Set tYear = $Piece(tFilter,"^",2)
		Set tMonth = $Piece(tFilter,"^",3)
		Do:tDebug ##class(util).DebugTEST("tFilter = "_tFilter)
		Set pWhere = $Piece(pWhere," AND ",2,*)
	}
	If (tMonth = "") Set tYear = ""
	If (tYear = "") {
		Set tDate = $ZDATE($HOROLOG)
		Set tYear = $Piece(tDate,"/",3)
		Set tMonth = +$Piece(tDate,"/",1)  // Drop leading zero
	}
	If ($Extract(tFilter,1,4) = "NEXT") {
		Set tMonth = $Order(^COUNT(tYear,tMonth),1)
		If (tMonth = "") {
			Set tYear = $Order(^COUNT(tYear),1)
			If (tYear '= "") {
				Set tMonth = $Order(^COUNT(tYear,tMonth),1)
			}
		}
	}
	If ($Extract(tFilter,1,4) = "PREV") {
		Set tMonth = $Order(^COUNT(tYear,tMonth),-1)
		If (tMonth = "") {
			Set tYear = $Order(^COUNT(tYear),-1)
			If (tYear '= "") {
				Set tMonth = $Order(^COUNT(tYear,tMonth),-1)
			}
		}
	}
	If (tYear = "") {
		Do ..OutputTableNada()
	 	Set tReturn = "^"_tYear_"^"_tMonth
 		Quit tReturn
	}
	If (tMonth = "") {
		Do ..OutputTableNada()
	 	Set tReturn = "^"_tYear_"^"_tMonth
 		Quit tReturn
	}
 	Do ..OutputTableHead()
 	Set (tSumCount, tSumCredit, tSumDebit) = 0
 	Write !,"<tbody>"
	Set tCategory = ""
	For {
		Set tCategory = $Order(^COUNT(tYear,tMonth,tCategory),1,tData)
		If (tCategory = "") { QUIT }
		Set tCount = $Piece(tData,"^",1)
		Set tCredit = $Piece(tData,"^",2)
		Set tDebit = $Piece(tData,"^",3)
		Write "<tr><td>",tCategory,"</td><td>",tCount,"</td><td>",tDebit,"</td><td>",tCredit,"</td></tr>",!
		Set tSumCount = tSumCount + tCount
		Set tSumCredit = tSumCredit + tCredit
		Set tSumDebit = tSumDebit + tDebit
	}
	Write !,"</tbody>"
 	Do ..OutputTableFoot(1,tSumCount,tSumCredit,tSumDebit)
 	Set tReturn = "^"_tYear_"^"_tMonth
 	Quit tReturn
	Quit $$$OK
	/*
	// iStartDate >= '1/1/2021' AND iEndDate <= '1/31/2022'
	If (pWhere [ "iStartDate") {
		Set tBefore = $Piece(pWhere,"iStartDate",1)
		Set tAfter = $Piece(pWhere,"iStartDate",2)
		Set tValue = $Piece(tAfter,"'",2)
		Set tData = ..GetTranDate(tValue)
		Set tMore = $Piece(tAfter," AND ",2,*)
		Set pWhere = tBefore_"zTranDate"_$Piece(tAfter,"'",1)_tData
		If (tMore '= "") Set pWhere = pWhere_" AND "_tMore
	}
	If (pWhere [ "iEndDate") {
		Set tBefore = $Piece(pWhere,"iEndDate",1)
		Set tAfter = $Piece(pWhere,"iEndDate",2)
		Set tValue = $Piece(tAfter,"'",2)
		Set tData = ..GetTranDate(tValue)
		Set tMore = $Piece(tAfter," AND ",2,*)
		Set pWhere = tBefore_"zTranDate"_$Piece(tAfter,"'",1)_tData
		If (tMore '= "") Set pWhere = pWhere_" AND "_tMore
	}
	*/
	Set tQuote = """"
	Set tSC = $$$OK
	Set tTable = "dc_iris.transact"
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE "_pWhere
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
 	Do ..OutputTableHead()
 	Set (tSumCredit, tSumDebit) = 0
 	Write !,"<tbody>"
 	While tResult.%Next() {
	 	If (tFilter '= "") {
		 	Set tData = tResult.Category
		 	Set tContinue = (tData '[ tFilter)
		 	If tContinue { CONTINUE }
	 	}
	 	//Set tValue = ##class(Util).EncodeLogicalDisplay(tResult.ID,tResult.Nickname)
		Set tValue = tResult.ID
		Write !,"<tr onclick=",tQuote,$Replace(pTrClick,"#",tValue),tQuote,">"
		//Write !,"<td>",$ZDATE(tResult.TranDate),"</td>"
		Set tDisplay = tResult.TranDate
		Write !,"<td>",tDisplay,"</td>"
		//Write !,"<td>",$ZTIME(tResult.TranTime),"</td>"
		Write !,"<td>",tResult.Account,"</td>"
		Write !,"<td>",tResult.CheckNumber,"</td>"
		//Set tQuery = "SELECT Nickname FROM Riches.Merchant WHERE ID = "_tResult.Merchant
		//Set tSC = ##class(Util).ExecuteQueryOneValue(tQuery,.tDisplay)
		Set tDisplay = tResult.Merchant
		Write !,"<td>",tDisplay,"</td>"
		//Set tQuery = "SELECT Nickname FROM Riches.Category WHERE ID = "_tResult.Category
		//Set tSC = ##class(Util).ExecuteQueryOneValue(tQuery,.tDisplay)
		Set tDisplay = tResult.Category
		Write !,"<td>",tDisplay,"</td>"
		Write !,"<td>",tResult.Debit,"</td>"
		Write !,"<td>",tResult.Credit,"</td>"
		Write !,"</tr>"
		Set tSumCredit = tSumCredit + tResult.Credit
		Set tSumDebit = tSumDebit + tResult.Debit
	}
	Write !,"</tbody>"
 	Do ..OutputTableFoot(1,tSumCredit,tSumDebit)
	Quit tSC
}

ClassMethod OutputTableFoot(
	pColSpan As %String = "",
	pCount As %String = "",
	pCredit As %String = "",
	pDebit As %String = "") As %Status
{
	Set q = """"
	Set qColSpan = q_pColSpan_q
	Write !,"<tfoot>"
	Write !,"<tr><td colspan=",qColSpan,">Sum</td>"
	Write !,"<td>",pCount,"</td>"
	Write !,"<td>",pDebit,"</td>"
	Write !,"<td>",pCredit,"</td>"
	Write !,"</tr>"
	Write !,"</tfoot>"
	Quit $$$OK
}

ClassMethod OutputTableHead() As %Status
{
	Write !,"<thead>"
	Write !,"<tr><th>Category</th><th>Count</th><th>Debit</th><th>Credit</th></tr>"
	Write !,"</thead>"
	Quit $$$OK
}

ClassMethod OutputTableNada() As %Status
{
	Write !,"<tr><td>Nothing to show here</td></tr>"
	Quit $$$OK
}

}
