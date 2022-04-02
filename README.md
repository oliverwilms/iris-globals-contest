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

Data originates from Excel

![screenshot](https://github.com/oliverwilms/bilder/blob/main/Capture_Excel.JPG)

I decided to store the data in ^GLOBAL each cell getting its own node. You can try it out for yourself with this command:
```
USER>do ##class(dc.iris.util).ImportCSV()
```

The global looks like this:
![screenshot](https://github.com/oliverwilms/bilder/blob/main/Capture_GLOBAL.JPG)
