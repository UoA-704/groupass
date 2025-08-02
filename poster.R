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
customerData <- read.csv("customers.csv")
View(customerData)

# remove string 'weeks'
data$weeks_since_signup <- as.numeric(gsub(" weeks", "", data$weeks_since_signup))
data$weeks_since_last_purchase <- as.numeric(gsub(" weeks", "", data$weeks_since_last_purchase))


# remove string 'currency tag'
data$avg_AddOnpurchase_value <- as.numeric(gsub("[$]", "", data$avg_AddOnpurchase_value))


# Use GWalkR to interactively explore the midwest dataset
# gwalkr(customerMetaData)
# gwalkr(customerData)
