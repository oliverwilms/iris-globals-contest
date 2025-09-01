Class dc.python.test
{

ClassMethod HelloWorld() As %Status
{
  Set sc = $$$OK
  Set b = ##class(%SYS.Python).Import("builtins")
  Do b.print("Hello world")
  Return sc
}

ClassMethod Today() As %Status
{
  Set sc = $$$OK
  Set dt = ##class(%SYS.Python).Import("datetime")
  write dt.date.today().isoformat()
  Return sc
}

ClassMethod Hello() As %Status
{
  Set sc = $$$OK
  Set sm = ##class(%SYS.Python).Import("sample")
  write sm.hello()
  Return sc
}

/// Titanic
ClassMethod TitanicMeanAge() As %Status
{
    Set sc = $$$OK
    set tt=##class(%SYS.Python).Import("sample")
    set path=$System.Util.ManagerDirectory()_"data/titanic.csv"
    write "mean age="_tt.meanage(path)
    Return sc
}

ClassMethod PlotlyDiv(pTrnYear = 0, pTrnMonth = 0) As %String
{
	Set sc = $$$OK
	Set py = ##class(%SYS.Python).Import("plotdiv")
	Set div = py.gendiv(pTrnYear,pTrnMonth)
	Return div
	Return sc
}

}
