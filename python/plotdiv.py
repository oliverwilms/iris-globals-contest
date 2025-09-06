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

# pyo.plot(fig)

# Generate the HTML div
def gendiv(trnyear, trnmonth, filename="titanic.csv"):
    query = "SELECT Top 10 Category, Credit, Debit, TrnCount FROM dc_iris.trncount where TrnYear=2025 and TrnMonth=8 Order By Debit DESC"
    print(query)
    df = iris.sql.exec(query).dataframe().sort_values(by=['debit'],ascending=False)
    ##fig = px.bar(df.head(10),x="category",y="debit")
    fig = go.Figure(
       data=[
           go.Bar(
               x=df['category'],
               y=df['debit']
           )
       ],
       layout=go.Layout(
           title='Total Monthly Cost'
       )
    )
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
