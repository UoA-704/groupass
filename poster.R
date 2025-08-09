##### libraries##########
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("knitr")) install.packages("knitr")
if (!require("tinytex")) install.packages("tinytex")
if (!require("tidymodels")) install.packages("tidymodels")
if (!require("GWalkR")) install.packages("GWalkR")
library(tidymodels)
library(tidyverse)
library(knitr)
library(tinytex)
library(GWalkR)

########### load data#################
customerData <- read.csv("customers_cleaned.csv")
View(customerData)


# Use GWalkR to interactively explore the midwest dataset
gwalkr(customerData)



