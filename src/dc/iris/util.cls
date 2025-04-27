Class dc.iris.util
{

ClassMethod DebugMerge(strMessage As %String = "", ByRef pArray) As %Status
{
	Merge ^TESTunit($I(^TESTunit)) = pArray
	Set tValue = ""
	If $Get(pArray) '= "" Set tValue = " = "_pArray
	Set ^TESTunit(^TESTunit) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage_tValue
	Quit $$$OK
}

ClassMethod DebugTEST(strMessage As %String = "") As %Status
{
	Set ^TESTunit($I(^TESTunit)) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage
	Quit $$$OK
}

ClassMethod StatusToText(pStatus As %Status) As %String
{
	Set tReturn = $System.Status.GetOneErrorText(pStatus)
	Quit tReturn
}

ClassMethod DebugStatus(pStatus As %Status) As %Status
{
	Set tStatus = ..StatusToText(pStatus)
	Quit ..DebugTEST(tStatus)
}

ClassMethod GetStatusText(pStatus As %Status) As %String
{
	If $$$ISOK(pStatus) Quit "OK"
	Set tErrorText = $SYSTEM.Status.GetErrorText(pStatus)
	Set tReturn = $REPLACE(tErrorText,"ERROR #5001:","")
	Quit tReturn
}

ClassMethod DataToLineCSV(ByRef pData) As %String
{
	Set c = ","
	Set q = """"
	Set r = "'"
	Set line = ""
	For ii = 1:1:$Get(pData,0) {
		Set x = $Replace($Get(pData(ii)),q,r)
		Set line = line_c_q_x_q
	}
	Quit $Extract(line,2,*)
}

ClassMethod ExecuteQueryOneValue(pQuery As %String, ByRef pResult As %String) As %Status
{
	Do ..DebugTEST("Riches.Util - ExecuteQueryOneValue")
	Do ..DebugTEST("pQuery = "_pQuery)
	Set pResult = ""
	Set rs = ##class(%ResultSet).%New()
	Set tSC = rs.Prepare(pQuery)
	Do ..DebugStatus(tSC)
	If $$$ISOK(tSC) {
		Set tSC = rs.Execute()
		Do ..DebugStatus(tSC)
		If $$$ISOK(tSC), rs.Next() Set pResult = rs.GetData(1)
	}
	Do rs.Close()
	Set rs = ""
	Do ..DebugTEST("pResult = "_pResult)
	Quit tSC
}

ClassMethod ExportToCSV(pFile As %String = "") As %Status
{
	If ("" = $Get(pFile)) Set pFile = "dc_iris-transact.csv"
	If ("" = $Get(pQuery)) Set pQuery = "SELECT ID, Account, Category, CheckNumber, Credit, Debit, Memo, Merchant, Status, SubCategory, TranDate, myId, zTranDate FROM dc_iris.transact"
	Set statement = ##class(%SQL.Statement).%New(1)  ; 1 - ODBC mode
	Set status = statement.%Prepare(pQuery)
	If $$$ISERR(status) {write "%Prepare failed:" do $SYSTEM.Status.DisplayError(status) quit}
	Set rset = statement.%Execute()
	If (rset.%SQLCODE '= 0) {write "%Execute failed:", !, "SQLCODE ", rset.%SQLCODE, ": ", rset.%Message quit}
	Set timeout = 1
	Open pFile:("NRW"):timeout
	Use pFile
	Kill pData
	Set pData($Increment(pData)) = "ID"
	Set pData($Increment(pData)) = "Account"
	Set pData($Increment(pData)) = "Category"
	Set pData($Increment(pData)) = "CheckNumber"
	Set pData($Increment(pData)) = "Credit"
	Set pData($Increment(pData)) = "Debit"
	Set pData($Increment(pData)) = "Memo"
	Set pData($Increment(pData)) = "Merchant"
	Set pData($Increment(pData)) = "Status"
	Set pData($Increment(pData)) = "SubCategory"
	Set pData($Increment(pData)) = "TranDate"
	Set pData($Increment(pData)) = "zTranDate"
	Set line = ..DataToLineCSV(.pData)
	Write line,!
	While rset.%Next()
	{
		//Write "Row count ",rset.%ROWCOUNT,!
		//Write rset.ID
		//Write ", Memo ",rset.Memo,!!
		Kill pData
		Set pData($Increment(pData)) = rset.ID
		Set pData($Increment(pData)) = rset.Account
		Set pData($Increment(pData)) = rset.Category
		Set pData($Increment(pData)) = rset.CheckNumber
		Set pData($Increment(pData)) = rset.Credit
		Set pData($Increment(pData)) = rset.Debit
		Set pData($Increment(pData)) = rset.Memo
		Set pData($Increment(pData)) = rset.Merchant
		Set pData($Increment(pData)) = rset.Status
		Set pData($Increment(pData)) = rset.SubCategory
		Set pData($Increment(pData)) = rset.TranDate
		Set pData($Increment(pData)) = rset.zTranDate
		Set line = ..DataToLineCSV(.pData)
		Write line,!
	}
	Close pFile
	Use 0
	If (rset.%SQLCODE < 0) {write "%Next failed:", !, "SQLCODE ", rset.%SQLCODE, ": ", rset.%Message quit}
	Write !,"End of data"
	Write !,"Total row count=",rset.%ROWCOUNT
	Quit $$$OK
}

ClassMethod GetDateValue(pValue As %String) As %Date
{
	If ($Get(pValue) ? 1.N1"/"1.N1"/"1.N) {
		Set tDate = $ZDATEH(pValue,8)
		Quit tDate
	}
	If ($Get(pValue) ? 1.N1"-"1.N1"-"1.N) {
		Set tDate = $ZDATEH(pValue,8)
	}
	Quit $Get(tDate,0)
}

ClassMethod ImportCSV(pCSV As %String = "", pMaxRows As %Integer = 9999) As %Status
{
	If (pCSV = "") {
		Set tExport = "/opt/irisbuild/data/finance-transactions-08-Jan-2022_08-25.csv"
		If ##class(%File).Exists(tExport) Set pCSV = tExport
	}
	If (pCSV = "") {
		Set tExport = ##class(%File).GetDirectory(##class(%File).NormalizeDirectory("lib", ##class(%File).GetDirectory($zu(86)))_"irisapp")_"export.CSV"
		If ##class(%File).Exists(tExport) Set pCSV = tExport
	}
	If (pCSV = "") Quit $$$ERROR($$$GeneralError,"file not found")
	Write "ImportCSV ",pCSV,!
	Set timeout = 1
	Open pCSV:("R"):timeout  // read
	If ($TEST = 0) {
		Set msg = "Unable to Open "_pCSV
		Write msg,!
		Quit $$$ERROR($$$GeneralError,msg)
	}
	Set comma = ","
	Set rows = -1
	Try {
		Use pCSV
		For {
			Read line
			If ($Increment(rows) = 0) {
				If ($Get(line) = "") {
					Set msg = "Headers not found in "_pCSV
					Use 0
					Write msg,!
					Quit  // For loop
				}
				Kill ^GLOBAL
				Set tId	 = 0
				Set headers = line
				For ii = 1:1:$Length(headers,comma) {
					Set title = $Piece(headers,comma,ii)
					Do ..UnQuote(title,.title)
					Set ^GLOBAL(tId,ii) = title
				}
				Continue
			}
			If (rows > pMaxRows) { Quit }
			Set tId = $Increment(^GLOBAL)
			For ii = 1:1:$Length(line,comma) {
				Set tData = $Piece(line,comma,ii)
				Do ..UnQuote(tData,.tData)
				Set ^GLOBAL(tId,ii) = tData
			}
			Continue
		}
	} Catch {
	}
	Close pCSV
	Write rows, " rows",!
	Quit $$$OK
}

ClassMethod UnQuote(pQuote As %String = "", Output pUnQuote As %String, pOutQuote As %String = "", pVerbose As %Integer = 0) As %Status
{
	Set boolContinue = 1
	While boolContinue {
		Set tFirst = $Extract(pQuote,1)
		Set tLast = $Extract(pQuote,*)
		If (tFirst = "'") {
			If (tFirst = tLast) {
				Set pQuote = $Extract(pQuote,2,*-1)
			} Else { Set boolContinue = 0 }
		} ElseIf (tFirst = """") {
			If (tFirst = tLast) {
				Set pQuote = $Extract(pQuote,2,*-1)
			} Else { Set boolContinue = 0 }
		} Else { Set boolContinue = 0 }
	}
	// Problem with ' or #
	Set pEscape = ##class(%CSP.Page).EscapeHTML(pQuote)
		Do:pVerbose ..DebugTEST("pEscape = "_pEscape)
	If (pQuote '= pEscape) {
		//Do ..DebugTEST("pEscape = "_pEscape)
	}
	Set pUnQuote = pOutQuote_pEscape_pOutQuote
	Do:pVerbose ..DebugTEST("pUnQuote = "_pUnQuote)
	Quit $$$OK
}

}
