Class dc.iris.count
{

ClassMethod Count() As %Status
{
	Set ^TRANSLATE("Category","Donation") = "Donations"
	Kill ^COUNT
	Set tDebug = 1
	Do:tDebug ##class(util).DebugTEST("dc.iris.count - Count")
	Set tSC = $$$OK
	Set tTable = "dc_iris.transact"
	Set tWHERE = ""
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
	Set (tSumCredit, tSumDebit) = 0
	While tResult.%Next() {
		Set (tYear, tMonth) = 0
		Set tTranDate = tResult.TranDate
		If (tTranDate ? 1.2N1"/"1.2N1"/"1.4N) {
			Set tMonth = $Piece(tTranDate,"/",1)
			Set tYear = $Piece(tTranDate,"/",3)
		}
		If (tTranDate ? 1.4N1"-"1.2N1"-"1.2N) {
			Set tMonth = $Piece(tTranDate,"-",2)
			Set tYear = $Piece(tTranDate,"-",1)
		}
		If (tYear > 0),(tYear < 50) Set tYear = tYear + 2000
		Set tMonth = +tMonth  // Eliminate leading zero
		Set tAccount = tResult.Account
		Set tCategory = tResult.Category
		If (tCategory = "") Set tCategory = 0
		If $Data(^TRANSLATE("Category",tCategory)) Set tCategory = $Get(^TRANSLATE("Category",tCategory))
		If (tCategory = "") Set tCategory = 0
		If ($Extract(tCategory,1,2) = "xx") Set tCategory = "xx"
		Set tDebit = $Translate(tResult.Debit,",","")  // Remove commas
		Set tCredit = $Translate(tResult.Credit,",","")  // Remove commas
		If (tAccount '= ""),$Data(^TRANSLATE("Credit-Debit",tAccount)) {
			Set tCreditDebit = $Get(^TRANSLATE("Credit-Debit",tAccount))
			If (tCreditDebit = "Credit is Debit") {
				Set tData = tCredit
				Set tCredit = tDebit
				Set tDebit = tData
			}
		}
		Set tData = $Get(^COUNT(tYear,tMonth,tCategory))
		Set tCount = $Piece(tData,"^",1)
		Set tSumCredit = $Piece(tData,"^",2)
		Set tSumDebit = $Piece(tData,"^",3)
		Set tCount = tCount + 1
		Set tSumCredit = tSumCredit + tCredit
		Set tSumDebit = tSumDebit + tDebit
		Set ^COUNT(tYear,tMonth,tCategory) = tCount_"^"_tSumCredit_"^"_tSumDebit
	}
	Do ..Count2()
	Set tTotal = tResult.%ROWCOUNT
	Write tTotal," Transactions counted.",!
	Quit $$$OK
}

ClassMethod Count2() As %Status
{
	Set tYear = ""
	For {
		Set tYear = $Order(^COUNT(tYear))
		If (tYear = "") { QUIT }
		Set tMonth = ""
		For {
			Set tMonth = $Order(^COUNT(tYear,tMonth))
			If (tMonth = "") { QUIT }
			Set tSub = ""
			Set (tSumCount, tSumCredit, tSumDebit) = 0
			For {
				Set tSub = $Order(^COUNT(tYear,tMonth,tSub),1,tData)
				If (tSub = "") { QUIT }
				Set tSumCount = tSumCount + $Piece(tData,"^",1)
				Set tSumCredit = tSumCredit + $Piece(tData,"^",2)
				Set tSumDebit = tSumDebit + $Piece(tData,"^",3)
			}
			Set ^COUNT(tYear,tMonth) = tSumCount_"^"_tSumCredit_"^"_tSumDebit
		}
	}
	Quit $$$OK
}

ClassMethod OutputFourTD(pCategory As %String, pCount As %String, pDebit As %String, pCredit As %String) As %Status
{
	Set tCreditFN = $FN(pCredit,",",2)
	Set tDebitFN = $FN(pDebit,",",2)
	Write "<td>",pCategory,"</td><td>",pCount,"</td><td>",tDebitFN,"</td><td>",tCreditFN,"</td></tr>"
	Quit $$$OK
}

ClassMethod OutputTableCount2(pWhere As %String = "", pTrClick As %String = "", pMaxRows = -1) As %String
{
	Set tDebug = 1
	Do:tDebug ##class(util).DebugTEST("dc.iris.count - OutputTableCount2")
	Do:tDebug ##class(util).DebugTEST("pWhere = "_pWhere)
	If (pTrClick = "") Set pMaxRows = -1  // ?
	Set tFilter = ""
	Set tOrder = -1  // Show newest first
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
	Set tReturn = "^"_tYear_"^"_tMonth
	If (tYear = "") {
		Do ..OutputTableNada()
 		Quit tReturn
	}
	If (tMonth = "") {
		Do ..OutputTableNada()
 		Quit tReturn
	}
	If ($Data(^COUNT) = 0) {
		Do ..OutputTableNada()
		Quit tReturn
	}
	Set tMonth = tMonth + 1
	Set tMonth = $Order(^COUNT(tYear,tMonth),tOrder,tData)
	If (tMonth = "") {
		Set tYear = $Order(^COUNT(tYear),tOrder)
		Set tMonth = $Order(^COUNT(tYear,tMonth),tOrder,tData)
	}
	Set pHead = "Month^Count^Debit^Credit"
	Do ..OutputTableHead(pHead)
	Set (tSumCount, tSumCredit, tSumDebit) = 0
	Write !,"<tbody>"
	Set tData = $Get(^COUNT(tYear,tMonth))
	For {
		For {
			Set tCategory = "^"_tYear_"^"_tMonth
			Set tClick = $Replace(pTrClick,"#",tCategory)
			Set tCount = $Piece(tData,"^",1)
			Set tCredit = $Piece(tData,"^",2)
			Set tDebit = $Piece(tData,"^",3)
			Write !,"<tr onclick=""",tClick,""";>"
			Set tSC = ..OutputFourTD(tCategory,tCount,tDebit,tCredit)
			Set tSumCount = tSumCount + tCount
			Set tSumCredit = tSumCredit + tCredit
			Set tSumDebit = tSumDebit + tDebit
			Set tMonth = $Order(^COUNT(tYear,tMonth),tOrder,tData)
			If (tMonth = "") { QUIT }
		}
		Set tYear = $Order(^COUNT(tYear),tOrder,tData)
		If (tYear = "") { QUIT }
		Set tMonth = $Order(^COUNT(tYear,tMonth),tOrder,tData)
	}
	Write !,"</tbody>"
	Do ..OutputTableFoot(1,tSumCount,tSumCredit,tSumDebit)
	Quit tReturn
}

ClassMethod OutputTableData(pWhere As %String = "", pTrClick As %String = "", pMaxRows = -1) As %String
{
	Set tDebug = 1
	Do:tDebug ##class(util).DebugTEST("dc.iris.count - OutputTableData")
	Do:tDebug ##class(util).DebugTEST("pWhere = "_pWhere)
	If (pTrClick = "") Set pMaxRows = -1  // ?
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
		Set tCreditFN = $FN(tCredit,",",2)
		Set tDebit = $Piece(tData,"^",3)
		Set tDebitFN = $FN(tDebit,",",2)
		Set tReturn = "^"_tYear_"^"_tMonth_"^"_tCategory
		Set tClick = $Replace(pTrClick,"#",tReturn)
		Write !,"<tr onclick=""",tClick,""";>"
		Set tSC = ..OutputFourTD(tCategory,tCount,tDebit,tCredit)
		Set tSumCount = tSumCount + tCount
		Set tSumCredit = tSumCredit + tCredit
		Set tSumDebit = tSumDebit + tDebit
	}
	Write !,"</tbody>"
 	Do ..OutputTableFoot(1,tSumCount,tSumCredit,tSumDebit)
 	Set tReturn = "^"_tYear_"^"_tMonth
 	Quit tReturn
}

ClassMethod OutputTableFoot(pColSpan As %String = "", pCount As %String = "", pCredit As %String = "", pDebit As %String = "") As %Status
{
	Set tCreditFN = $FN(pCredit,",",2)
	Set tDebitFN = $FN(pDebit,",",2)
	Set q = """"
	Set qColSpan = q_pColSpan_q
	Write !,"<tfoot>"
	Write !,"<tr><td colspan=",qColSpan,">Sum</td>"
	Write !,"<td>",pCount,"</td>"
	Write !,"<td>",tDebitFN,"</td>"
	Write !,"<td>",tCreditFN,"</td>"
	Write !,"</tr>"
	Write !,"</tfoot>"
	Quit $$$OK
}

ClassMethod OutputTableHead(pHead As %String = "") As %Status
{
	If (pHead = "") Set pHead = "Category^Count^Debit^Credit"
	Write !,"<thead>"
	Write !,"<tr>"
	For ii = 1:1:$Length(pHead,"^") {
		Write !,"<th>",$Piece(pHead,"^",ii),"</th>"
	}
	Write !,"</tr>"
	Write !,"</thead>"
	Quit $$$OK
}

ClassMethod OutputTableNada() As %Status
{
	Write !,"<tr><td>Nothing to show here</td></tr>"
	Quit $$$OK
}

ClassMethod Return2Dates(pReturn As %String, Output pStartDate As %String, Output pEndDate As %String)
{
	Set pReturn = $Get(pReturn)
	Set tYear = $Piece(pReturn,"^",2)
	If (tYear = "") Set tYear = 1841
	Set tMonth = $Piece(pReturn,"^",3)
	If (tMonth = "") Set tMonth = 1
	Set tDay = 1
	Set pStartDate = tMonth_"/"_tDay_"/"_tYear
	Set tMonth = tMonth + 1
	If (tMonth > 12) {
		Set tMonth = 1
		Set tYear = tYear + 1
	}
	Set tDate = tMonth_"/"_tDay_"/"_tYear
	Set tDateH = $ZDATEH(tDate)
	Set pEndDate = $ZDATE(tDateH - 1)
	Return
}

}
