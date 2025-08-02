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
customerMetaData <- read.csv("customers_metadata.csv")
customerData <- read.csv("customers.csv")
View(customerMetaData)
View(customerData)

# Use GWalkR to interactively explore the midwest dataset
# gwalkr(customerMetaData)
# gwalkr(customerData)
