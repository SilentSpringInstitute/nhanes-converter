NHANES PDF Extractor
====================

Background
----------
[The National Health and Nutrition Examination Survey (NHANES)](http://www.cdc.gov/nchs/nhanes/index.htm) is a national survey conducted by the Centers for Disease Control every two years. Among other things, the survey covers participant's exposure to environmental chemicals.

Chemical test results are published publicly online, as both the original data as well as summary statistics. The statistics are available in PDF form as the ["National Report on Human Exposure to Environmental Chemicals"](http://www.cdc.gov/biomonitoring/pdf/FourthReport_UpdatedTables_Feb2015.pdf) The tables include statistics like the geometric mean and selected quantiles. The tables are periodically updated along with the data. The PDF is huge: right now it is just over 61 megabytes. Moreover, the data is difficult to access programmatically due to the PDF format.

These statistics are useful as a way to validate analyses performed on the data. For example, the R package [RNHANES](http://www.cdc.gov/exposurereport) uses a different method to compute summary statistics than CDC does (they use SAS), so the output is checked against the summary tables to make sure they match.

PDF Extractor
-------------
This Ruby script converts PDF summary tables into CSV files. The PDFs are converted into text files using `pdftotext`, and then a finite state machine is used to tokenize and reformat the data into a CSV.

Usage
-----

Convert a summary table PDF to a CSV:
```
$ ruby ./pdftotext.rb ./nhanes_feb2015.pdf ./nhanes_feb2015.csv
```

Also works with flags for input/output:
```
$ ruby ./pdftotext.rb -input ./nhanes_feb2015.pdf -output ./nhanes_feb2015.csv
```

Download the most recent version of the summary tables from the CDC:
```
$ ruby ./pdftotext.rb --most-recent ./nhanes_feb2015.csv
```


Dependencies
-----------
`Ruby`
`pdftotext` (look for it in the `poppler-utils` package in your package repository)
