##### libraries##########
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("GWalkR")) install.packages("GWalkR")
library(tidyverse)
library(GWalkR)

########### load data#################
customerMetaData <- read.csv("customers_metadata.csv")
customerData <- read.csv("customers.csv")
View(customerMetaData)
View(customerData)

# Use GWalkR to interactively explore the midwest dataset
# gwalkr(customerMetaData)
# gwalkr(customerData)

#xxxxxxx
library(ggplot2)mmmm
