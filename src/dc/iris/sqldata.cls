Class dc.iris.sqldata
{

ClassMethod byQuery(pQuery As %String = "SELECT Top 5 Category, Credit, Debit, TrnCount FROM dc_iris.trncount where TrnYear=2025 and TrnMonth=8 Order By Debit DESC") As %DynamicAbstractObject
{
	Set dao = {}
	Try {
		Set tStatement = ##class(%SQL.Statement).%New(1)  ; 1 - ODBC mode
		Set tSC = tStatement.%Prepare(pQuery)
		If $$$ISERR(tSC) {write "%Prepare failed:" do $SYSTEM.Status.DisplayError(tSC) quit}
		Set rset = tStatement.%Execute()
		If (rset.%SQLCODE '= 0) {write "%Execute failed:", !, "SQLCODE ", rset.%SQLCODE, ": ", rset.%Message quit}
		While rset.%Next() {
			Write "Row count ",rset.%ROWCOUNT,!
			Write rset.Debit
			Write ", Category ",rset.Category,!!
		}
		If (rset.%SQLCODE < 0) {write "%Next failed:", !, "SQLCODE ", rset.%SQLCODE, ": ", rset.%Message quit}
		Write !,"End of data"
		Write !,"Total row count=",rset.%ROWCOUNT
	} Catch ex {
		zw ex
	}
	Quit dao
}

}
