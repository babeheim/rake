
rake architecture for simple reproducible research in R
============

`rake` is a simple, lightweight pipeline for developing reproducible research in R.

The key features:

- each analysis is broken down into discrete chapters which execute in sequence
- each chapter has a defined `input`, which it cannot modify, and produces `output`. this means chapters can repeatedly, or run out of order, so long as their input is correct
- a single overview R script, akin to a GNU Makefile, which takes the `output` from one chapter and passes it to the next, as appropriate, then runs that chapter's scripts
- all project dependencies and global variables are stored in a `project_support.r` file which is loaded first, to indicate immediately if problems arise

These are not hard requirements, but good habits. The major advantage is that it is *lightweight*. It has no prerequisites and it has only one new function, `dir_init`; the rest is all standard R. Rather, it is a *philosophy* of project organization.

A rake project works best for a research project that has linear sequence of steps. If the data require little munging or have really one step, better to use Ben Marwick's [rrtools](link-to-rrtools) workflow.

For example, a simple 4-step project on Github might look like this

```

my-analysis/
├── run_project.r
├── project_support.r
├── data/
├── 1_clean_data/
│   └── clean_data.r       # this is the main document to edit
├── 2_explore_data/
│   └── explore_data.r       # this is the main document to edit
├── 3_fit_models/
│   ├── models/
│   └── fit_models.r       # this is the main document to edit
└── 4_explore_models/
    └── explore_models.r       # this is the main document to edit

```

We would run the project by simply calling `source("./run_project.r")` or in the Terminal, type `R CMD BATCH run_project.r`. It would then execute in sequence.

```

analysis/
├── run_project.r
├── project_support.r
├── data/
├── 1_clean_data/
│   ├── clean_data.r       # this is the main document to edit
│   ├── input/  # this contains the reference list information
│   ├── temp/
│   └── output/
├── 2_explore_data/
│   ├── explore_data.r       # this is the main document to edit
│   ├── input/  # this contains the reference list information
│   ├── temp/
│   └── output/
├── 3_fit_models/
│   ├── fit_models.r       # this is the main document to edit
│   ├── input/  # this contains the reference list information
│   ├── temp/
│   └── output/
├── 4_explore_models/
│   ├── explore_models.r       # this is the main document to edit
│   ├── input/ # this contains the reference list information
│   ├── temp/
│   └── output/
├── 5_prep_manuscript/
│   ├── explore_models.r       # this is the main document to edit
│   ├── input/  # this contains the reference list information
│   ├── temp/
│   └── output/
└── output/
    ├── manuscript.pdf
    └── manuscript.docx

```

One of the major advantages is that there's very little confusion about the flow of code; the only things a chapter's code can 'see' is inside `input/`. 

It's easy to write multiple chapters at once, even with multiple people working on them.

Changing the order is just a matter of renaming the folder; nothing inside changes.

# rake style guide

- all scripts use *relative* file paths, assuming the analysis is the working directory at the beginning

- each script uses clear imperative names, e.g. `run_project.r` or `draw_figures.r`; think of giving a computer an order like in Star Trek


# inside `run_project.r`

The script looks like this:

```

rm(list = ls())

source("./project_support.r")

dir_init("./1_clean_data/input")
file.copy("raw_data.csv", "./1_clean_data/input")
setwd("./1_clean_data")
source("./clean_data.r")
setwd("..")

# each chapter goes here

```

The project does the following: clears the working directory, loads all the libraries and custom functions. then it initalizies the input folder that `clean_data` sees.

The function `dir_init` is a wrapper for dir.create that *wipes the contents* by default. This prevents older versions of files from hanging out in a folder they are not supposed to be in.


# inside `project_support.r`

```

library(rake)

save_temp <- TRUE

set.seed(1001)

```


# inside a chapter script

```

source("../run_project.r")

dir_init("./temp")

# all computations go here

dir_init("./output")

relevant_results <- c("./temp/1.png")
file.copy(relevant_results, "./output")

```

A hard rule in rake: **chapter scripts cannot change the chapter's inputs**
why? because it will produce unstable or irreproducible output

The most important point is that `dir_init("./output")` output happens *last*. Why? Because downstream code might want to look at the output files even as they are being recalculated. This is the equivalent of only 'saving' a new version.

# Additional Features

## using version control

rake is built assuming the project is under version control
major advantage is that you only need to version the R scripts and (maybe) the input data
all generated assets need not be

## using testthat to ensure quantitative reproducibility

say you are fitting a regression analysis with 309 cases
you might be making changes "upstream" in the code which change that accidentally
you want to know if somethign went wrong, the simplset hting to do is add a hard check that will fail if not

```
expect_true(nrow(data) == 309)
```

Now when the project executes, it must get that.

Likewise you can do this for results. Say you fit a linear regression model and the coef is X. There's some variability here, but


```
key_effect <- coef(m1)[2]
expect_true(abs(key_effect - 0.634) < 0.01)
```

This should be within that range, even as the seed changes.

## Incorporating R markdown

One way to organize your code is to embed it into rmarkdown. rake goes the other way, embedding rmarkdown calls inside an R script. This allows short manuscripts.

## Incorporating System Calls

you can use system calls to do things like compile a pdf using pdflatex


## using tictoc to time chapters and write a log/

some steps might take a long (very long!) time. using a log times things out is useful.

log <- TRUE

## using docstrings

a docstring is a statement about whats happening insdie the script
esp useufl for debugging, since it gives you a sense of where things came to a sudden halt

tictoc does this already but very helpful

## removing temporary contents

save_temp <- FALSE


# example projects

Most of my recent projects use rake architecture, which is where I've developed it over the years. It's not perfect, but so far i've been able to create and re-create my results on past projects since 2011.


pimbwe-wealth-mortality
moralizing-gods-reanalysis
mosuo-ppr
go-firstmove # this one uses Rmd to write up the pdf based on the computational results
