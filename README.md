## iris-globals-contest
This app imports data file into ^GLOBAL and counts transactions per month into ^COUNT global.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.


## Installation ZPM

```
USER>zpm "install iris-globals-contest"
```

## Installation docker

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/oliverwilms/iris-globals-contest.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to work with it

Menu CSP page:

http://localhost:57700/csp/user/menu.csp

Go to Transact.csp page

If your IRIS has no ^GLOBAL, click Import button.

It automatically calls class method to import data file into ^GLOBAL.

If your IRIS has no ^COUNT, click Count button.

It automatically calls class method to count Transaction data into ^COUNT.

You can run adhoc query by entering Start Date, End Date and Filter. Filter is currently only applied to Category. Click Preview button to run query.

Click Menu button to return to menu page.

Go to Count.csp page

It displays monthly totals for number of transactions and total debits and credits. Click on a table row to see counts for the selected month broken down by Categories. Click on Previous button to see counts for the previous month or click Next button to go to next month.

Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>
```

The first test demonstrates the call to a standard python library working with dates datetime
```
USER>d ##class(dc.python.test).Today()
2021-02-09
```

Another example shows the work of a custom lib sample.py which is installed with repo or ZPM. It has function hello which returns string "world":
```
USER>d ##class(dc.python.test).Hello()
World
```

Another example shows how to work with files and use pandas and numpy libs. 
It calculates the mean age of Titanic passengers:

```
USER>d ##class(dc.python.test).TitanicMeanAge()
mean age=29.69911764705882

```

