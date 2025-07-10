##### libraries##########
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("GWalkR")) install.packages("GWalkR")
if (!require("remotes")) install.packages("remotes")
if (!require("rmarkdown")) install.packages("rmarkdown")
remotes::install_github("brentthorne/posterdown")
library(ggplot2)
library(dplyr)
library(GWalkR)
library(posterdown)
library(posterdown)


########### load data#################
customerMetaData <- read.csv("customers_metadata.csv")
customerData <- read.csv("customers.csv")
View(customerMetaData)
View(customerData)

# Use GWalkR to interactively explore the midwest dataset
# gwalkr(customerMetaData)
# gwalkr(customerData)
