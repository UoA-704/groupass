if (!require("tidyverse")) install.packages("tidyverse")
if (!require("knitr")) install.packages("knitr")
if (!require("tinytex")) install.packages("tinytex")
if (!require("tidymodels")) install.packages("tidymodels")
if (!require("skimr")) install.packages("skimr")
if (!require("ranger"))   install.packages("ranger")
if (!require("car")) install.packages("car")
if (!require("vip")) install.packages("vip")
if (!require("bonsai")) install.packages("bonsai")     
if (!require("lightgbm")) install.packages("lightgbm") 
if (!require("xgboost"))  install.packages("xgboost")
if (!require("broom"))  install.packages("broom")
library(tidymodels)
library(tidyverse)
library(knitr)
library(tinytex)
library(skimr)
library(psych)
library(vip)
library(bonsai)
library(ranger)
library(broom)
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


############ loading data & data processing ############
data <- read.csv("customers.csv")

# ---- Basic NA summary ----
missing_summary <- data %>%
  summarise(across(everything(),
                   ~ sum(is.na(.)),
                   .names = "na_{col}"))



# remove string 'week'
data$weeks_since_signup <- as.numeric(gsub(" weeks", "", data$weeks_since_signup))
data$weeks_since_last_purchase <- as.numeric(gsub(" weeks", "", data$weeks_since_last_purchase))


# remove string 'currency tag'
data$avg_AddOnpurchase_value <- as.numeric(gsub("[$]", "", data$avg_AddOnpurchase_value))




# gender type (3 types)
n_distinct(data$gender)
unique(data$gender) 
# "Female"   ///    "Prefer Not to Answer / Other / Unknown"    ///   "Male" 

data <- data %>% 
  mutate(
    gender = case_when(
      gender == "Female" ~ "Female",
      gender == "Male"   ~ "Male",
      TRUE               ~ "Other"   # 把剩下的都归到 Other
    )
  )
unique(data$gender) 
# "Female"   ///   Other   ///   "Male" 

# subscription_payment_problem_last4Weeks (0 / 1)
data <- data %>%
  mutate(
    subscription_payment_problem_last4Weeks =
      as.integer(subscription_payment_problem_last4Weeks == "TRUE")
  )

# support ticket type (3 types)
n_distinct(data$support_ticket)
unique(data$support_ticket) 
# "NotLast3Months"  ////   "Last3Months"  ////    "YesThisMonth"


# sati survey type (6 types)
n_distinct(data$satisfaction_survey)
unique(data$satisfaction_survey) 
# 1 / 2 / 3 / 4 / 5 / NoResponse


# subscription type (5 types)
n_distinct(data$subscription)
unique(data$subscription) 
# "PlantBased" /// "Family"  //  "Everyday" ////  "Gourmet"  ////  "Low-carb"


# payment type (3 types)
n_distinct(data$payment)
unique(data$payment) 
# "DebitCard"  "CreditCard" "AppPay"  


#only take "weeks_since_last_purchase" equals or over 0
filter_data <- data %>% filter(weeks_since_last_purchase >= 0)


# View(data)
filter_data %>%
  count(retained_binary) %>%
  mutate(pct = n / sum(n) * 100)




#最终变量 
finalVariables <- c(
  "weeks_since_last_purchase",
  "discounted_rate_last_purchase",
  "avg_AddOnpurchase_value",
  "num_purchases",
  "location",
  "last_browser",
  "subscription_payment_problem_last4Weeks",
  "satisfaction_survey"
)

# 因变量：保证 0=否, 1=是，且 1 在第二水平
filter_data <- filter_data %>%
  mutate(
    retained_binary = factor(retained_binary, levels = c(0, 1))) %>% 
  dplyr::select(retained_binary, all_of(finalVariables))


set.seed(704)
# ---------- 分层切分 80/20 ----------
split <- initial_split(filter_data, prop = 0.8, strata = retained_binary)
train_data <- training(split)
test_data  <- testing(split)

set.seed(704)
subsplit <- initial_split(train_data,
                          prop = 10000 / nrow(train_data),
                          strata = retained_binary)
train_sample <- training(subsplit)
nrow(train_sample)   # 约等于 10000


# train smaple recipe
rec_tune <- recipe(retained_binary ~ ., data = train_sample) %>%
  step_string2factor(all_nominal_predictors()) %>%
  step_unknown(all_nominal_predictors()) %>%
  step_other(all_nominal_predictors(), threshold = 0.01) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_impute_median(all_numeric_predictors()) %>%
  step_zv(all_predictors())

set.seed(704)
# fold 5 times
folds <- vfold_cv(train_sample, v = 5, strata = retained_binary)




options(yardstick.event_first = FALSE)  # 把“1”当正类

# 定义模型（还没填参数）
lgbm_spec <- boost_tree(
  learn_rate     = tune(),
  trees          = tune(),
  tree_depth     = tune(),
  min_n          = tune(),
  loss_reduction = tune()
) %>% 
  set_engine("lightgbm") %>% 
  set_mode("classification")


# 把模型和数据预处理流程打包
lgbm_wf <- workflow() %>% add_recipe(rec_tune) %>% add_model(lgbm_spec)


# 随机生成一批参数组合（Grid Search）
set.seed(704)
lgbm_grid <- grid_random(
  learn_rate(range = c(-3, -0.5)),   # 10^-3 ~ 10^-0.5 ≈ 0.001 ~ 0.316
  trees(range = c(400L, 1000L)),
  tree_depth(range = c(3L, 6L)),
  min_n(range = c(2L, 20L)),
  loss_reduction(range = c(-4, 1)),
  size = 10
)


# 用交叉验证调参 - 5 折交叉验证
lgbm_res <- tune_grid(
  lgbm_wf, 
  resamples = folds,                   # ← 这是 train_sample 的 5 折
  grid = lgbm_grid,
  metrics = metric_set(roc_auc),       # 先就看 AUC，提速
  control = control_grid(save_pred = TRUE)  # 要画 CV ROC 就得保存折内预测
)


# 找出最优参数
lgbm_best <- select_best(lgbm_res, metric = "roc_auc")


# 用最优参数跑全量训练集，并在测试集评估
lgbm_final_wf <- finalize_workflow(lgbm_wf, lgbm_best)
# 用 1w 训练集拟合模型
lgbm_fit_1w <- fit(lgbm_final_wf, data = train_sample)  # 1w 训练
# 在 4w 测试集上预测（augment 会给 .pred_1/.pred_class）
preds_test <- augment(lgbm_fit_1w, new_data = test_data)

# 你要的 5 个指标 + AUC
metrics_6 <- dplyr::bind_rows(
  roc_auc(preds_test, truth = retained_binary, .pred_1),
  accuracy(preds_test, truth = retained_binary, .pred_class),
  sens(preds_test, truth = retained_binary, .pred_class),
  spec(preds_test, truth = retained_binary, .pred_class),
  precision(preds_test, truth = retained_binary, .pred_class),
  f_meas(preds_test, truth = retained_binary, .pred_class)
)
metrics_6

# 混淆矩阵（默认阈值 0.5）
conf_mat(preds_test, truth = retained_binary, estimate = .pred_class)


# 3) 显式指定正类再画 ROC
preds_test %>%
  roc_curve(retained_binary, .pred_1, event_level = "second") %>%
  autoplot() + ggtitle("LightGBM ROC (event=1)")


# 2) 收集折内预测
lgbm_pred <- collect_predictions(lgbm_res)

# 3) 画 ROC（挑两维做分面，例如 learn_rate × trees）
lgbm_pred |>
  group_by(id, learn_rate, trees) |>
  roc_curve(truth = retained_binary, .pred_1) |>
  autoplot() +
  facet_grid(rows = vars(learn_rate), cols = vars(trees)) +
  theme(legend.position = "none") +
  labs(title = "ROC: LightGBM", subtitle = "By folds")
