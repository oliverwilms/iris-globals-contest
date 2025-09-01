import iris
import plotly.express as px

query = "SELECT Top 10 Category, Credit, Debit, TrnCount FROM dc_iris.trncount where TrnYear=2025 and TrnMonth=8 Order By Debit DESC"
df = iris.sql.exec(query).dataframe().sort_values(by=['Debit'], ascending=False)

fig = px.bar(df.head(10),x="Category",y="Debit",barmode="group",text_auto='.3s')
fig.update_traces(textfont_size=12,textangle=0,textposition="outside",cliponaxis=False)
fig.update_layout(height=330)
fig.show()
