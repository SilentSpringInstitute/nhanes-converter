NHANES PDF Extractor
====================

Background
----------
[The National Health and Nutrition Examination Survey (NHANES)](http://www.cdc.gov/nchs/nhanes/index.htm) is a national survey conducted by the Centers for Disease Control every two years. Among other things, the survey covers participant's exposure to environmental chemicals.

Chemical test results are published publicly online, as both the original data as well as summary statistics. The statistics are available in PDF form as the [National Report on Human Exposure to Environmental Chemicals.](https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=NHANES+summary+tablesa) The tables include statistics like the geometric mean and selected quantiles. The tables are periodically updated along with the data. The PDF is huge: right now it is just over 61 megabytes. Moreover, the data is difficult to access programmatically due to the PDF format.

These statistics are useful as a way to validate analyses performed on the data. For example, the R package [RNHANES](http://github.com/SilentSpringInstitute/RNHANES) uses a different method to compute summary statistics than CDC does (they use SAS), so the output is checked against the summary tables to make sure they match.

PDF Extractor
-------------
This Ruby script converts PDF summary tables into CSV files. The PDFs are converted into text files using `pdftotext`, and then a finite state machine is used to tokenize and reformat the data into a CSV.

Usage
-----

Convert a summary table PDF to a CSV:
```
$ ruby ./pdftotext.rb ./nhanes_feb2015.pdf ./nhanes_feb2015.csv
```

Dependencies
-----------
`Ruby`

`pdftotext` (look for it in the `poppler-utils` package in your package repository)

`ruby-progressbar` gem. Install with ```$ gem install ruby-progressbar```
