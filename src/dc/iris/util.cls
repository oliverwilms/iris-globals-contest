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
	//If (pUnQuote = "") Set pUnQuote = "''"
	Do:pVerbose ..DebugTEST("pUnQuote = "_pUnQuote)
	Quit $$$OK
}

}
