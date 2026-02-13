Class dc.iris.category Extends %Persistent
{

Property IncomeOrExpense As %String;

Property Name As %String;

Property Type As %String(VALUELIST = ",Income,Expense");

ClassMethod CreateOrUpdate(pType As %String, pName As %String) As %Status
{
	Set oCategory = ##class(dc.iris.category).%New()
	Set oCategory.IncomeOrExpense = $Get(pType)
	Set oCategory.Name = $Get(pName)
	Set tSC = oCategory.%Save()
	Quit tSC
}

ClassMethod OutputTableExpense(pPeriod As %String, pTotal As %String) As %String
{
	/*
              <table cellpadding="0" cellspacing="0" width="100%" class="formtable"> 
                #(..htmlGetExpense("Giving","Monthly-Giving"))#
                #(..htmlGetExpense("Housing","Monthly-Housing"))#
                #(..htmlGetExpense("Food","Monthly-Food"))#
                #(..htmlGetExpense("Clothing","Monthly-Clothing"))#
                #(..htmlGetExpense("Automobile","Monthly-Automobile"))#
                #(..htmlGetExpense("Savings","Monthly-Savings"))#
                #(..htmlGetExpense("Leisure","Monthly-Leisure"))#

              </table> 
	*/
	Set q = """"
	Set tCellPadding = " cellpadding="_q_"0"_q
	Set tCellSpacing = " cellspacing="_q_"0"_q
	Set tWidth = " width="_q_"100%"_q
	Set tClass = " class="_q_"formtable"_q
	Set tTable = "<table"_tCellPadding_tCellSpacing_tWidth_tClass_">"
	Write !,tTable
	For {
		Set tSC = ..OutputTableRow("Expense","Giving","Monthly-Giving")
		Set tSC = ..OutputTableRow("Expense","Housing","Monthly-Housing")
		Set tSC = ..OutputTableRow("Expense","Food","Monthly-Food")
		Set tSC = ..OutputTableRow("Expense","Clothing","Monthly-Clothing")
		Set tSC = ..OutputTableRow("Expense","Automobile","Monthly-Automobile")
		Set tSC = ..OutputTableRow("Expense","Savings","Monthly-Savings")
		Set tSC = ..OutputTableRow("Expense","Leisure","Monthly-Leisure")
		Quit
	}
	Set tClass = " class="_q_"formtabletotal"_q
	Write !,"<tr"_tClass_">"
	Write !,"<th>Total Expense</th><td>&nbsp;</td><td>&nbsp;</td>"
	Set tClass = " class="_q_"spandollar"_q
	Set tId = " id="_q_"tot_expense"_q
	Set tSpan = "<span"_tId_tClass_">"
	Write !,"<th>",tSpan,$Get(pTotal),"</span></th></tr>"
	Write !,"</table>"
	Quit ""
	Quit $$$OK
}

ClassMethod OutputTableIncome(pPeriod As %String, pTotal As %String) As %String
{
	/*
              <table cellpadding="0" cellspacing="0" width="100%" class="formtable"> 
                #(..htmlGetIncome("Income","Monthly-Income"))#
                #(..htmlGetIncome("Paycheck","Monthly-Paycheck"))#
                #(..htmlGetIncome("Freelance","Monthly-Freelance"))#
                <tr class="formtabletotal"><th>Total Income</th><td>&nbsp;</td><td>&nbsp;</td><th><span id="tot_income" class="spandollar">#($Get(tTotalIncome))#</span></th></tr> 
              </table> 
	*/
	Set q = """"
	Set tCellPadding = " cellpadding="_q_"0"_q
	Set tCellSpacing = " cellspacing="_q_"0"_q
	Set tWidth = " width="_q_"100%"_q
	Set tClass = " class="_q_"formtable"_q
	Set tTable = "<table"_tCellPadding_tCellSpacing_tWidth_tClass_">"
	Write !,tTable
	For {
		Set tSC = ..OutputTableRow("Income","Paycheck","Monthly-Paycheck")
		Set tSC = ..OutputTableRow("Income","Freelance","Monthly-Freelance")
		Quit
	}
	Set tClass = " class="_q_"formtabletotal"_q
	Write !,"<tr"_tClass_">"
	Write !,"<th>Total Income</th><td>&nbsp;</td><td>&nbsp;</td>"
	Set tClass = " class="_q_"spandollar"_q
	Set tId = " id="_q_"tot_income"_q
	Set tSpan = "<span"_tId_tClass_">"
	Write !,"<th>",tSpan,$Get(pTotal),"</span></th></tr>"
	Write !,"</table>"
	Quit ""
	Quit $$$OK
}

ClassMethod OutputTableRow(pType As %String, pName As %String, pId As %String) As %Status
{
	/*
<script language="cache" method="htmlGetExpense" arguments="Category:%String,ID:%String" returntype="%String">
// <tr><td>Clothing</td><td><input type="text" class="textinput inputpercent" id="percent_backup" value="25" /></td><td><input type="text" class="textinput inputdollar" id="clerical_pay" value="15" /></td></tr>
;
Set q = """"
Set tClassDollar = " class="_q_"textinput inputdollar"_q
Set tClassPercent = " class="_q_"textinput inputpercent"_q
Set tHTML = ""
Set tIdDollar = " id="_q_"idExpenseDollar"_$Get(ID)_q
Set tIdPercent = " id="_q_"idExpensePercent"_$Get(ID)_q
Set tNameDollar = " name="_q_"idExpenseDollar"_$Get(ID)_q
Set tNamePercent = " name="_q_"idExpensePercent"_$Get(ID)_q
Set tPeriod = "Year"
If ("Monthly" = $Piece(ID,"-",1)) { Set tPeriod = "Month" }
Set tValueDollar = $Get(^myBudget("idExpenseDollar"_$Get(ID),1))
Set tValuePercent = $Get(^myBudget("idExpensePercent"_$Get(ID),1))
Set tHTML = tHTML_"<tr><td>"
Set tHTML = tHTML_$Get(Category)
Set tHTML = tHTML_"</td><td><input type="_q_"text"_q_tClassPercent_tIdPercent_tNamePercent_" value="_q_tValuePercent_q_" />"
Set tHTML = tHTML_"</td><td>&nbsp;"
Set tHTML = tHTML_"</td><td><input type="_q_"text"_q_tClassDollar_tIdDollar_tNameDollar_" value="_q_tValueDollar_q_" />"
Set tHTML = tHTML_"</td></tr>"
Set ^TEMP("MyBudget",tPeriod,"Expense",Category,"Dollar") = "idExpenseDollar"_$Get(ID)
Set ^TEMP("MyBudget",tPeriod,"Expense",Category,"Percent") = "idExpensePercent"_$Get(ID)
Quit tHTML
;
</script>
<script language="cache" method="htmlGetIncome" arguments="Category:%String,ID:%String" returntype="%String">
// <tr><td>Clothing</td><td><input type="text" class="textinput inputpercent" id="percent_backup" value="25" /></td><td><input type="text" class="textinput inputdollar" id="clerical_pay" value="15" /></td></tr>
;
Set q = """"
Set tClassDollar = " class="_q_"textinput inputdollar"_q
Set tClassPercent = " class="_q_"textinput inputpercent"_q
Set tHTML = ""
Set tIdDollar = " id="_q_"idIncomeDollar"_$Get(ID)_q
Set tIdPercent = " id="_q_"idIncomePercent"_$Get(ID)_q
Set tNameDollar = " name="_q_"idIncomeDollar"_$Get(ID)_q
Set tNamePercent = " name="_q_"idIncomePercent"_$Get(ID)_q
Set tPeriod = "Year"
If ("Monthly" = $Piece(ID,"-",1)) { Set tPeriod = "Month" }
Set tValueDollar = $Get(^myBudget("idIncomeDollar"_$Get(ID),1))
Set tHTML = tHTML_"<tr><td>"
Set tHTML = tHTML_$Get(Category)
Set tHTML = tHTML_"</td><td>&nbsp;"
Set tHTML = tHTML_"</td><td>&nbsp;"
Set tHTML = tHTML_"</td><td><input type="_q_"text"_q_tClassDollar_tIdDollar_tNameDollar_" value="_q_tValueDollar_q_" />"
Set tHTML = tHTML_"</td></tr>"
Set ^TEMP("MyBudget",tPeriod,"Income",Category,"Dollar") = "idIncomeDollar"_$Get(ID)
Quit tHTML
;
</script>
	*/
  Try {
	Set pId = $Get(pId)
	Set pName = $Get(pName)
	Set pType = $Get(pType)
	//If ("Income" = pType) { Set tPrefix = "idIncome" } Else { Set tPrefix = "idExpense" }
	Set tPrefix = "id"_pType
	Set q = """"
	Set tClassDollar = " class="_q_"textinput inputdollar"_q
	Set tClassPercent = " class="_q_"textinput inputpercent"_q
	Set tHTML = ""
	Set tIdDollar = " id="_q_tPrefix_"Dollar"_$Get(pId)_q
	Set tIdPercent = " id="_q_tPrefix_"Percent"_$Get(pId)_q
	Set tNameDollar = " name="_q_tPrefix_"Dollar"_$Get(pId)_q
	Set tNamePercent = " name="_q_tPrefix_"Percent"_$Get(pId)_q
	Set tPeriod = "Year"
	If ("Monthly" = $Piece(pId,"-",1)) { Set tPeriod = "Month" }
	Set tValueDollar = $Get(^myBudget(tPrefix_"Dollar"_$Get(pId),1))
	Set tValuePercent = $Get(^myBudget(tPrefix_"Percent"_$Get(pId),1))
	Set tHTML = tHTML_"<tr><td>"
	Set tHTML = tHTML_$Get(pName)
	Set tHTML = tHTML_"</td><td><input type="_q_"text"_q_tClassPercent_tIdPercent_tNamePercent_" value="_q_tValuePercent_q_" />"
	Set tHTML = tHTML_"</td><td>&nbsp;"
	Set tHTML = tHTML_"</td><td><input type="_q_"text"_q_tClassDollar_tIdDollar_tNameDollar_" value="_q_tValueDollar_q_" />"
	Set tHTML = tHTML_"</td></tr>"
	Set ^TEMP("MyBudget",tPeriod,pType,pName,"Dollar") = "idExpenseDollar"_$Get(ID)
	Set ^TEMP("MyBudget",tPeriod,pType,pName,"Percent") = "idExpensePercent"_$Get(ID)
  } Catch ex { }
	Write !,tHTML
	Quit $$$OK
}

ClassMethod Setup() As %Status
{
	Set tSC = $$$OK
	If $$$ISOK(tSC) Set tSC = ##class(dc.iris.category).CreateOrUpdate("Income","Paycheck")
	If $$$ISOK(tSC) Set tSC = ##class(dc.iris.category).CreateOrUpdate("Expense","Giving")
	Quit tSC
}

Storage Default
{
<Data name="categoryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>IncomeOrExpense</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^dc.iris.categoryD</DataLocation>
<DefaultData>categoryDefaultData</DefaultData>
<ExtentSize>2</ExtentSize>
<IdLocation>^dc.iris.categoryD</IdLocation>
<IndexLocation>^dc.iris.categoryI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="IncomeOrExpense">
<AverageFieldSize>8.5</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>9</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^dc.iris.categoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
