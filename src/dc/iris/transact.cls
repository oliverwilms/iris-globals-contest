Class dc.iris.transact Extends %Persistent [ StorageStrategy = NewStorage1 ]
{

Index NewIndex1 On myId [ IdKey, PrimaryKey, Unique ];

Property Account As %String;

Property Category As %String;

Property CheckNumber As %String;

Property Credit As %String;

Property Debit As %String;

Property Memo As %String;

Property Merchant As %String;

Property myId As %String;

Property Status As %String;

Property SubCategory As %String;

Property TranDate As %String;

Property zTranDate As %Integer [ Calculated, SqlComputeCode = {set {*}=##class(dc.iris.transact).GetTranDate({TranDate})}, SqlComputed ];

ClassMethod GetTranDate(pStringDate As %String) As %Integer
{
	Try {
		Set zTranDate = $ZDATEH(pStringDate)
	} Catch {
		Set zTranDate = 0
	}
	Quit $Get(zTranDate,0)
}

ClassMethod OutputTableData(
	pWhere As %String = "",
	pTrClick As %String = "window.location='Transact.csp?iAccount=#';",
	pMaxRows = -1) As %Status
{
	Set tDebug = 1
	Do:tDebug ##class(util).DebugTEST("Riches.Transact - OutputTableData")
	Do:tDebug ##class(util).DebugTEST("pWhere = "_pWhere)
	Set tFilter = ""
	If (pWhere [ "iFilter") {
		Set tFilter = $Piece(pWhere," AND ",1,1)
		Set tFilter = $Piece(tFilter,"iFilter = ",2)
		Do:tDebug ##class(util).DebugTEST("tFilter = "_tFilter)
		Set pWhere = $Piece(pWhere," AND ",2,*)
	}
	If (pWhere [ "iStartDate") {
		Set tBefore = $Piece(pWhere,"iStartDate",1)
		Set tAfter = $Piece(pWhere,"iStartDate",2)
		Set tValue = $Piece(tAfter,"'",2)
		Set tData = ..GetTranDate(tValue)
		Set tMore = $Piece(tAfter," AND ",2,*)
		Set pWhere = tBefore_"zTranDate"_$Piece(tAfter,",",1)_tData
		If (tMore '= "") Set pWhere = pWhere_" AND "_tMore
	}
	If (pWhere [ "iEndDate") {
		Set tBefore = $Piece(pWhere,"iEndDate",1)
		Set tAfter = $Piece(pWhere,"iEndDate",2)
		Set tValue = $Piece(tAfter,"'",2)
		Set tData = ..GetTranDate(tValue)
		Set tMore = $Piece(tAfter," AND ",2,*)
		Set pWhere = tBefore_"zTranDate"_$Piece(tAfter,",",1)_tData
		If (tMore '= "") Set pWhere = pWhere_" AND "_tMore
	}
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
 	Do ..OutputTableFoot(5,tSumCredit,tSumDebit)
	Quit tSC
}

ClassMethod OutputTableFoot(
	pColSpan As %String = "",
	pCredit As %String = "",
	pDebit As %String = "") As %Status
{
	Set q = """"
	Set qColSpan = q_pColSpan_q
	Write !,"<tfoot>"
	Write !,"<tr><td colspan=",qColSpan,">Sum</td>"
	Write !,"<td>",pDebit,"</td>"
	Write !,"<td>",pCredit,"</td>"
	Write !,"</tr>"
	Write !,"</tfoot>"
	Quit $$$OK
}

ClassMethod OutputTableHead() As %Status
{
	Write !,"<thead>"
	Write !,"<tr><th>Date</th><th>Account</th><th>Check</th><th>Merchant</th><th>Category</th><th>Debit</th><th>Credit</th></tr>"
	Write !,"</thead>"
	Quit $$$OK
}

Storage NewStorage1
{
<ExtentSize>2048</ExtentSize>
<Property name="%%ID">
<AverageFieldSize>5.45</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Account">
<AverageFieldSize>9.96</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," CAPONE"," CAPONE"," CAPONE"," CHASE"," CHASE"," COSTCOCASH"," COSTCOVISA"," COSTCOVISA"," DISCOVERNAZZ"," DOUBLECASH"," DSCVRROSE"," OLDNAVY"," REDCARD"," SOUTHWEST"," WFACTIVECASH"),$lb(1,8,8,2,7,2,7,12,1,2,2,1,1,1,1),$lb(536870912,0,1128353871,0,0,0,0,1095782222,1212240709,0,0,1212240709,1330861123,1128354632,1447646017,0,0,1129272148,1145656131,1230193487,1330987596,1330987596,1396921938,1146307414,1330398286,1330398286,1380271171,1380271171,1397708116,1397708116,1464222019,542590529))</Histogram>
<OutlierSelectivity>.171387:"CapOne"</OutlierSelectivity>
<Selectivity>2.7620%</Selectivity>
</Property>
<Property name="Category">
<AverageFieldSize>8.47</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," "," "," DIVIDENDS"," GAS"," GROCERIES"," GROCERIES"," GROCERIES"," JONATHAN"," MAHAL"," MAHAL"," PAYMENT"," REIMBURSED"," SARAH"," TRANSFER"," YARD"),$lb(2,2,1,1,2,11,11,1,1,7,1,1,1,1,1),$lb(536870912,0,0,0,0,0,1145656905,1145656905,1195463424,1095958528,1380926277,0,0,0,0,1196576579,1246711361,1246711361,1296123969,0,0,1296123969,1346459981,1346459981,1380272461,1380272461,1396789825,1396789825,1414676814,1414676814,1497453124,542720338))</Histogram>
<OutlierSelectivity>.18457:"Groceries"</OutlierSelectivity>
<Selectivity>1.1649%</Selectivity>
</Property>
<Property name="CheckNumber">
<AverageFieldSize>2.02</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," CHECK"),$lb(2,2,2,2,2,2,2,2,2,2,2,2,2,2,1),$lb(536870912,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1128809795,541280325))</Histogram>
<OutlierSelectivity>.994629:</OutlierSelectivity>
<Selectivity>0.0671%</Selectivity>
</Property>
<Property name="Credit">
<AverageFieldSize>3.65</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," "," "," "," "," "," "," "," "," "," 100"," 169"," 250.96"," 4.21"," 6.29"," SPEND"),$lb(2,2,2,2,2,2,2,2,2,1,2,1,1,1,1),$lb(536870912,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,825241600,808452096,909705216,825637120,842346542,842346542,875442737,875442737,908997177,908997177,1397769550,542330949))</Histogram>
<OutlierSelectivity>.635742:</OutlierSelectivity>
<Selectivity>0.0624%</Selectivity>
</Property>
<Property name="Debit">
<AverageFieldSize>4.6</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," "," "," "," "," "," 0"," 12.08"," 16.23"," 21.52"," 264.77"," 320"," 40"," 51.66"," 7.47"," DEBIT"),$lb(2,2,2,2,2,1,1,2,1,2,1,1,1,1,1),$lb(536870912,0,0,0,0,0,0,0,0,0,0,0,805306368,805306368,825372208,841887800,908997171,825634354,842083893,825111858,909389367,842413102,858927104,858927104,875560960,875560960,892415542,892415542,925774903,925774903,1145389641,541345090))</Histogram>
<OutlierSelectivity>.400879:</OutlierSelectivity>
<Selectivity>0.0716%</Selectivity>
</Property>
<Property name="Memo">
<AverageFieldSize>4.9</AverageFieldSize>
<Histogram>
<![CDATA[$lb(.06666666666666666667,0,0,$lb(" "," "," "," "," "," "," "," "," "," "," "," "," AMEX OFFER KROGER GROC &AMP; WINE 20%"," HAPPIEST HOUR"," PHONE"," ZIP LINES"),$lb(2,2,2,2,2,2,2,2,2,2,2,1,1,1,1),$lb(536870912,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1095583064,1095583064,1212239952,1212239952,1346916174,1346916174,1514754080,542787920))]]></Histogram>
<OutlierSelectivity>.744141:</OutlierSelectivity>
<Selectivity>0.0692%</Selectivity>
</Property>
<Property name="Merchant">
<AverageFieldSize>9.81</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," ALDI"," AMEX"," CHASE"," COMCAST"," COSTCO"," DILLARDS"," HAWAIIAN BROS"," JONATHAN"," MARKET STREET"," PAYMENT"," ROSE WILMS"," SOUTHWEST"," T-MOBILE"," TEXAS.GOV"," ZELLE"),$lb(1,2,1,2,3,1,1,1,1,1,1,1,1,2,1),$lb(536870912,0,1095517257,1279543552,1296390144,1095583064,1128808787,1212240709,1330463553,1296253267,1398031183,1129272148,1145654348,1145654348,1212241729,1212241729,1246711361,1246711361,1296126539,1296126539,1346459981,1346459981,1380930373,1380930373,1397708116,1397708116,1412255055,760041282,1163411795,1413830721,1514490956,542786892))</Histogram>
<OutlierSelectivity>.073242:"Costco"</OutlierSelectivity>
<Selectivity>0.2553%</Selectivity>
</Property>
<Property name="Status">
<AverageFieldSize>8.05</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," "," "," "," "," "," CLEARED"," CLEARED"," RECONCILED"," RECONCILED"," RECONCILED"," RECONCILED"," RECONCILED"," RECONCILED"," RECONCILED"," VOID"),$lb(2,2,2,2,2,1,9,1,12,12,12,12,12,12,1),$lb(536870912,0,0,0,0,0,0,0,0,0,0,0,1129071937,0,0,1129071937,1380270927,0,0,0,0,0,0,0,0,0,0,0,0,1380270927,1448036676,542527305))</Histogram>
<OutlierSelectivity>.395508:"Reconciled"</OutlierSelectivity>
<Selectivity>4.0299%</Selectivity>
</Property>
<Property name="SubCategory">
<AverageFieldSize>2.1</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," "," "," "," "," "," "," "," "," "," "," "," "," "," "," WATER"),$lb(2,2,2,2,2,2,2,2,2,2,2,2,2,2,1),$lb(536870912,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1463899205,542589268))</Histogram>
<OutlierSelectivity>.984863:</OutlierSelectivity>
<Selectivity>0.1081%</Selectivity>
</Property>
<Property name="TranDate">
<AverageFieldSize>10.63</AverageFieldSize>
<Histogram>$lb(.06666666666666666667,0,0,$lb(" "," 1/26/2021"," 10/23/2021"," 11/19/2021"," 12/13/2021"," 12/5/2021"," 2/6/2021"," 3/4/2021"," 4/24/2021"," 5/19/2021"," 6/12/2021"," 6/6/2021"," 7/29/2021"," 8/21/2021"," 9/15/2021"," Q4"),$lb(1,2,2,2,4,1,1,1,1,1,3,1,1,1,1),$lb(536870912,0,825176630,791819823,808399411,808399411,825176377,825176377,841953587,825438002,892285488,825372469,841954863,841954863,858731567,858731567,875508276,875508276,892285241,892285241,909062450,825372466,909062704,909063727,925839929,925839929,942617137,942617137,959394101,959394101,1362362368,542192640))</Histogram>
<Selectivity>0.2688%</Selectivity>
</Property>
<Property name="myId">
<AverageFieldSize>5.45</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<SQLMap name="Map1">
<BlockCount>-160</BlockCount>
<Data name="Account">
<Delimiter>"^"</Delimiter>
<Node>11</Node>
<Piece>1</Piece>
</Data>
<Data name="Category">
<Delimiter>"^"</Delimiter>
<Node>4</Node>
<Piece>1</Piece>
</Data>
<Data name="CheckNumber">
<Delimiter>"^"</Delimiter>
<Node>2</Node>
<Piece>1</Piece>
</Data>
<Data name="Credit">
<Delimiter>"^"</Delimiter>
<Node>7</Node>
<Piece>1</Piece>
</Data>
<Data name="Debit">
<Delimiter>"^"</Delimiter>
<Node>8</Node>
<Piece>1</Piece>
</Data>
<Data name="Memo">
<Delimiter>"^"</Delimiter>
<Node>6</Node>
<Piece>1</Piece>
</Data>
<Data name="Merchant">
<Delimiter>"^"</Delimiter>
<Node>3</Node>
<Piece>1</Piece>
</Data>
<Data name="Status">
<Delimiter>"^"</Delimiter>
<Node>13</Node>
<Piece>1</Piece>
</Data>
<Data name="SubCategory">
<Delimiter>"^"</Delimiter>
<Node>5</Node>
<Piece>1</Piece>
</Data>
<Data name="TranDate">
<Delimiter>"^"</Delimiter>
<Node>1</Node>
<Piece>1</Piece>
</Data>
<Global>^GLOBAL</Global>
<Subscript name="1">
<Expression>{myId}</Expression>
<StartValue>1</StartValue>
</Subscript>
<Type>data</Type>
</SQLMap>
<StreamLocation>^dc.iris.transactS</StreamLocation>
<Type>%Storage.SQL</Type>
}

}
