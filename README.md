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

I looked for a menu to navigate between the different CSP pages. I used the existing menu.csp with no changes required.

Try it on your local installation http://localhost:57700/csp/user/menu.csp or - [demo](https://irisglobalscontest.demo.community.intersystems.com/csp/user/menu.csp)

![screenshot](https://github.com/oliverwilms/bilder/blob/main/iris-globals-contest_menu.png)

Go to Transact.csp page where the data can be imported. Alternative option from Terminal is shown below...

![screenshot](https://github.com/oliverwilms/bilder/blob/main/iris-globals-contest_transact.png)

If your IRIS has no ^GLOBAL, click Import button. It automatically calls class method to import data file into ^GLOBAL.

![screenshot](https://github.com/oliverwilms/bilder/blob/main/iris-globals-contest_transact_after_Import.png)

After Import the button is replaced with Count button. If your IRIS has no ^COUNT, click Count button. It automatically calls class method to count Transaction data into ^COUNT. After Count the button is replaced with Menu button.

![screenshot](https://github.com/oliverwilms/bilder/blob/main/iris-globals-contest_transact_after_Count.png)

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

I used Brendan Bannon's Article The Art of Mapping Globals to Classes (https://community.intersystems.com/post/art-mapping-globals-classes-1-3) to map ^GLOBAL to persistent class dc.iris.transact. Now it can be seen here:

![screenshot](https://github.com/oliverwilms/bilder/blob/main/iris-globals-contest_SQL.png)

Next I created a CSP page where I could filter the transaction data at will.

I wanted to see transaction counts and totals for each category one month at a time. I accumulated data into ^COUNT like this:

I created another CSP page to view the monthly data snapshots like this:

I wanted to see monthly totals for a series of months at a glance as can be seen here:

## Online Demo
You can find online demo here - [demo](https://irisglobalscontest.demo.community.intersystems.com/csp/user/menu.csp)

