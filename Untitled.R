
{r}
set.seed(704) 

# 切分
data_split <- initial_split(
  filter_data, 
  prop   = 0.8,                     # 80% 训练集
  strata = retained_binary           # 按留存状态分层
)

# 78.2% - 21.8%
train_data <- training(data_split)
# 78.2% - 21.8%
test_data  <- testing(data_split)

# 检查比例
prop.table(table(train_data$retained_binary))
prop.table(table(test_data$retained_binary))









# 



