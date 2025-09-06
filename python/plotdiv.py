#!/usr/local/bin/python3
# C:\InterSystems\Cache\bin>irispip install --upgrade --target C:\InterSystems\Cache\mgr\python numpy
# C:\InterSystems\Cache\bin>irispip install --upgrade --target C:\InterSystems\Cache\mgr\python pandas
# C:\InterSystems\Cache\bin>irispip install --upgrade --target C:\InterSystems\Cache\mgr\python plotly
# C:\InterSystems\Cache\bin>irispip install --upgrade --target C:\InterSystems\Cache\mgr\python plotly[express]

import iris
# import numpy
import pandas
import plotly.express as px
import plotly.graph_objects as go
from plotly.offline import plot

# import numpy as np
# import pandas as pd
# import plotly.graph_objs as go 
# import plotly.offline as pyo

# df = pd.DataFrame(data={
#   'Month': ['January', 'February', 'March'],
#   'Water': [50, 61, 43],
#   'Electricity': [100, 88, 112],
#   'Heat': [86, 92, 104],
#   'Total': [236, 241, 259]
# })

fig = go.Figure()

fig.add_trace(go.Bar(
    x=["Apples", "Oranges", "Watermelon", "Pears"],
    y=[3, 2, 1, 4]
))

fig.update_layout(
    autosize=False,
    width=500,
    height=500,
    yaxis=dict(
        title=dict(
            text="Y-axis Title",
            font=dict(
                size=30
            )
        ),
        ticktext=["Very long label", "long label", "3", "label"],
        tickvals=[1, 2, 3, 4],
        tickmode="array",
    )
)

fig.update_yaxes(automargin=True)

# pyo.plot(fig)

# Generate the HTML div
def gendiv(trnyear, trnmonth, filename="titanic.csv"):
    query = "SELECT Top 10 Category, Credit, Debit, TrnCount FROM dc_iris.trncount where TrnYear=2025 and TrnMonth=8 Order By Debit DESC"
    print(query)
    df = iris.sql.exec(query).dataframe().sort_values(by=['debit'],ascending=False)
    ##fig = px.bar(df.head(10),x="category",y="debit")
    #fig = go.Figure(
    #   data=[
    #       go.Bar(
    #           x=df['category'],
    #           y=df['debit']
    #       )
    #   ],
    #   layout=go.Layout(
    #       title='Total Monthly Cost'
    #   )
    #)
    # fig.update_traces(textfont_size=12,textangle=0,textposition="outside",cliponaxis=False)
    ##fig.update_traces(hovertemplate='%{y:.2f}', texttemplate='%{y:.2f}')
    # fig.update_layout(height=330)
    # fig.show()
    div = plot(fig, include_plotlyjs=False, output_type='div')
    # Print or save the div
    with open("plot.html", "w") as file:
        file.write(f"<html><body>{div}</body></html>")
    return div

# Create a simple plot
# fig = go.Figure(data=[go.Bar(x=['A', 'B', 'C'], y=[10, 20, 30])])
