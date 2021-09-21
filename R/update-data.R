datasets = c("KUM", "MRI", "UKA", "UKT")
formula = binomial_1 ~ 0 + gender + height + weight + numbness + cell_count + relapses
for (d in datasets) {
  dfile = paste0("data/", d, ".csv")
  dat   = read.csv(dfile)
  dmat  = model.matrix(formula, data = dat)

  if (is.numeric(dat$gender))   dat$gender   = as.factor(dat$gender)
  if (is.numeric(dat$numbness)) dat$numbness = as.factor(dat$numbness)

  set.seed(31415)
  pars = runif(ncol(dmat), -1, 1)

  score = dmat %*% pars
  score = (score - min(score)) / (max(score) - min(score)) * 4 - 2
  prob  = 1 / (1 + exp(-(score - mean(score)))) + rnorm(length(score), 0, 0.15)
  #dat$binomial_1 = rbinom(length(score), size = 1, prob = prob)
  dat$binomial_1 = ifelse(prob > 0.5, 1, 0)

  write.csv(dat, file = dfile)
}
