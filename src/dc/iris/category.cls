Class dc.iris.category Extends %Persistent
{

Property IncomeOrExpense As %String;

Property Name As %String;

ClassMethod CreateOrUpdate(pType As %String, pName As %String) As %Status
{
	Set oCategory = ##class(dc.iris.category).%New()
	Set oCategory.IncomeOrExpense = $Get(pType)
	Set oCategory.Name = $Get(pName)
	Set tSC = oCategory.%Save()
	Quit tSC
}

ClassMethod Setup() As %Status
{
	Set tSC = $$$OK
	If $$$ISOK(tSC) Set tSC = ##class(dc.iris.category).CreateOrUpdate("Income","Paycheck")
	If $$$ISOK(tSC) Set tSC = ##class(dc.iris.category).CreateOrUpdate("Expense","Giving")
	Quit tSC
}

}
