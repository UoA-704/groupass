##### libraries##########
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("knitr")) install.packages("knitr")
if (!require("tinytex")) install.packages("tinytex")
if (!require("tidymodels")) install.packages("tidymodels")
if (!require("skimr")) install.packages("skimr")
if (!require("car")) install.packages("car")
library(tidymodels)
library(tidyverse)
library(knitr)
library(tinytex)
library(skimr)
library(psych)
library(car)

########### load data#################
customerData <- read.csv("customers_cleaned.csv")
View(customerData)


# 
categorical_vars <- c(
  "gender",
  "support_ticket",
  "opened_last_email",
  "subscription_payment_problem_last4Weeks",
  "last_login_device",
  "last_browser",
  "location",
  "subscription",
  "payment_type"
)

#
numeric_vars <- c(
  "app_visits",
  "website_visits",
  "social_media_comments",
  "social_media_posts",
  "social_media_likes",
  "social_media_shares",
  "subscription_meals_per_week",
  "subscription_people",
  "weeks_since_signup",
  "weeks_since_last_purchase",
  "num_purchases",
  "discounted_rate_last_purchase",
  "avg_AddOnpurchase_value"
)


# ---- 数值型概览 ----
num_summary <- psych::describe(filter_data %>% select(any_of(numeric_vars)))

# 输出成表（knitr）
kable(num_summary, caption = "数值变量描述统计")






