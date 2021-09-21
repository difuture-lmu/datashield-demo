#dfiles = list.files("data", full.names = TRUE, pattern = "csv")
dfiles = paste0("data/", c("KUM", "MRI", "UKA", "UKT"), ".csv")
ll_dat = list()

for (df in dfiles) {
  ll_dat = c(ll_dat, list(read.csv(df)))
}
dat = do.call(rbind, ll_dat)

dat$gender = as.factor(dat$gender)
dat$numbness = as.factor(dat$numbness)

dat = dat[, c("gender", "height", "weight", "numbness", "cell_count", "relapses", "binomial_1")]

mod = glm(binomial_1 ~ ., data = dat, family = binomial())
save(mod, file = "data/mod.Rda")
save(dat, file = "data/dat_full.Rda")
