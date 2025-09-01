# This is a basic Python program
import iris
import plotly.express as px
import plotly.graph_objects as go
from plotly.offline import plot

query = "SELECT Top 10 Category, Credit, Debit, TrnCount FROM dc_iris.trncount where TrnYear=2025 and TrnMonth=8 Order By Debit DESC"
df = iris.sql.exec(query).dataframe().sort_values(by=['Debit'], ascending=False)

fig = px.bar(df.head(10),x="Category",y="Debit",barmode="group",text_auto='.3s')
fig.update_traces(textfont_size=12,textangle=0,textposition="outside",cliponaxis=False)
fig.update_layout(height=330)
# fig.show()
div = plotly.offline.plot(fig, include_plotlyjs=False, output_type='div')
# Print or save the div
with open("plot.html", "w") as file:
    file.write(f"<html><body>{div}</body></html>")


# Create a simple plot
# fig = go.Figure(data=[go.Bar(x=['A', 'B', 'C'], y=[10, 20, 30])])

# Generate the HTML div
# div = plot(fig, output_type='div')
