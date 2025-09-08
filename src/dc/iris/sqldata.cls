Class dc.iris.sqldata
{

ClassMethod byQuery(pQuery As %String = "SELECT Top 5 Category, Credit, Debit, TrnCount FROM dc_iris.trncount where TrnYear=2025 and TrnMonth=8 Order By Debit DESC") As %DynamicAbstractObject
{
	Set dao = {}
	Try {
		Set tColumns = 4
		Set tColumns(1) = "Category"
		Set tColumns(2) = "Credit"
		Set tColumns(3) = "Debit"
		Set tColumns(4) = "TrnCount"
		For ii = 1:1:tColumns {
			If (ii = 1) Set array1 = []
			If (ii = 2) Set array2 = []
			If (ii = 3) Set array3 = []
			If (ii = 4) Set array4 = []
		}
		Set tStatement = ##class(%SQL.Statement).%New(1)  ; 1 - ODBC mode
		Set tSC = tStatement.%Prepare(pQuery)
		If $$$ISERR(tSC) {write "%Prepare failed:" do $SYSTEM.Status.DisplayError(tSC) quit}
		Set rset = tStatement.%Execute()
		If (rset.%SQLCODE '= 0) {write "%Execute failed:", !, "SQLCODE ", rset.%SQLCODE, ": ", rset.%Message quit}
		While rset.%Next() {
			Write "Row count ",rset.%ROWCOUNT,!
			For ii = 1:1:tColumns {
				If (ii = 1) Do array1.%Push(rset.%GetData(ii))
				If (ii = 2) Do array2.%Push(rset.%GetData(ii))
				If (ii = 3) Do array3.%Push(rset.%GetData(ii))
				If (ii = 4) Do array4.%Push(rset.%GetData(ii))
			}
		}
		If (rset.%SQLCODE < 0) {write "%Next failed:", !, "SQLCODE ", rset.%SQLCODE, ": ", rset.%Message quit}
		Write !,"End of data"
		Write !,"Total row count=",rset.%ROWCOUNT
		For ii = 1:1:tColumns {
			If (ii = 1) Set $PROPERTY(dao,tColumns(ii)) = array1
			If (ii = 2) Set $PROPERTY(dao,tColumns(ii)) = array2
			If (ii = 3) Set $PROPERTY(dao,tColumns(ii)) = array3
			If (ii = 4) Set $PROPERTY(dao,tColumns(ii)) = array4
		}

	} Catch ex {
		zw ex
	}
	Quit dao
}

}
