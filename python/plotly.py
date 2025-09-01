import iris
import plotly.express as px

query = "SELECT ..."
df = iris.sql.exec(query).dataframe().sort_values(by=['column'], ascending=False)

fig = px.bar(df.head(10),x="location",y="column",barmode="group",text_auto='.3s')

fig.update_traces(textfont_size=12,textangle=0,textposition="outside",cliponaxis=False)

fig.update_layout(height=330)
fig.show()
