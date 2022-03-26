Class U
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
		Set tExport = "/usr/irissys/lib/irisapp/export.CSV"
		If ##class(%File).Exists(tExport) Set pCSV = tExport
	}
	If (pCSV = "") {
		Set tExport = "/opt/irisapp/data/export.csv"
		If ##class(%File).Exists(tExport) Set pCSV = tExport
	}
	If (pCSV = "") {
		Set tExport = "/opt/irisapp/export.CSV"
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
	Set cAccount = 0
	Set cCategory = 0
	Set cCheck = 0
	Set cCredit = 0
	Set cDate = 0
	Set cDebit = 0
	Set cMemo = 0
	Set cMerchant = 0
	Set cStatus = 0
	Set cSubategory = 0
	Try {
		Use pCSV
		Set tColumns = "Account,TranDate,Merchant,Category,AmountDebit,AmountCredit"
		Set tQuery = "Insert into Riches.Transact ("_tColumns_") values "
		For {
			Read line
			If ($Increment(rows) = 0) {
				If ($Get(line) = "") {
					Set msg = "Headers not found in "_pCSV
					Use 0
					Write msg,!
					Quit  // For loop
				}
				Set headers = line
				For ii = 1:1:$Length(headers,comma) {
					Set title = $Piece(headers,comma,ii)
					Set tSC = ..UnQuote(title,.title)
					If (title = "Account") Set cAccount = ii
					If (title = "Check") Set cCheck = ii
					If (title = "Credit") Set cCredit = ii
					If (title = "Date") Set cDate = ii
					If (title = "Debit") Set cDebit = ii
					If (title = "Memo") Set cMemo = ii
					If (title = "Merchant") Set cMerchant = ii
					If (title = "Status") Set cStatus = ii
					If (title = "Subategory") Set cSubategory = ii
					If '(title [ "SubCategory"),(title [ "Category") Set cCategory = ii
				}
				Continue
			}
			If (rows > pMaxRows) { Quit }
			Set tValues = "("
			If cAccount Set tValues = tValues_$Piece(line,comma,cAccount)
			Set tValues = tValues_comma
			If cDate Set tValues = tValues_$Piece(line,comma,cDate)
			Set tValues = tValues_comma
			If cMerchant Set tValues = tValues_$Piece(line,comma,cMerchant)
			Set tValues = tValues_comma
			If cCategory Set tValues = tValues_$Piece(line,comma,cCategory)
			Set tValues = tValues_comma
			If cDebit Set tValues = tValues_$Piece(line,comma,cDebit)
			Set tValues = tValues_comma
			If cCredit Set tValues = tValues_$Piece(line,comma,cCredit)
			Set tValues = tValues_")"
			Set tSQL = tQuery_tValues
			//Set tSC = ##class(Riches.REST).PostSQL(tSQL,rows)
		}
	} Catch {
	}
	Close pCSV
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
	If (pUnQuote = "") Set pUnQuote = "''"
	Do:pVerbose ..DebugTEST("pUnQuote = "_pUnQuote)
	Quit $$$OK
}

}
