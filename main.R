if (FALSE) {
  remotes::install_github("difuture-lmu/ds.predict.base")
  remotes::install_github("difuture-lmu/ds.calibration")
  remotes::install_github("difuture-lmu/ds.roc.glm")

  source("update-data.R")
  source("upload-data.R")
  source("create-log-reg.R")
  source("install-ds-packages.R")
}

library(DSI)
library(DSOpal)
library(dsBaseClient)

builder = newDSLoginBuilder()

surl     = "https://opal-demo.obiba.org/"
username = "administrator"
password = "password"

datasets = c("KUM", "MRI", "UKA", "UKT")
for (i in seq_along(datasets)) {
  builder$append(
    server   = paste0("ds", i),
    url      = surl,
    user     = username,
    password = password,
    table    = paste0("DIFUTURE-TEST.", datasets[i])
  )
}

connections = datashield.login(logins = builder$build(), assign = TRUE)

datashield.symbols(connections)

load("data/mod.Rda")

ds.predict.base::pushObject(connections, obj = mod)
datashield.symbols(connections)

ds.predict.base::predictModel(connections, mod, "pred", predict_fun = "predict(mod, newdata = D, type = 'response')")
datashield.symbols(connections)

ssd = datashield.aggregate(connections, 'getNegativeScoresVar("D$binomial_1", "pred", 2)')
n   = ds.dim("D")
n   = n[[grep("combined", names(n))]][1]

sdd = 1 / (n - 1) * sum(unlist(ssd))

datashield.aggregate(connections, paste0('getNegativeScores("D$binomial_1", "pred", ', sdd, ')'))



ds.calibration::dsBrierScore(connections, "D$binomial_1", "pred")
cc = ds.calibration::dsCalibrationCurve(connections, "D$binomial_1", "pred")
ds.calibration::plotCalibrationCurve(cc, size = 1.5)

roc_glm    = ds.roc.glm::dsROCGLM(connections, "D$binomial_1", "pred")
plot(roc_glm) + ggplot2::theme_minimal()

## Check on pooled data:
if (FALSE) {
  library(mlr)
  load("data/dat_full.Rda")

  task = makeClassifTask(data = dat, target = "binomial_1")
  lrn  = makeLearner("classif.logreg", predict.type = "prob")
  mod  = train(lrn, task)
  pred = predict(mod, task = task)

  measureAUC(pred$data$prob.1, pred$data$truth, negative = 0, positive = 1)
  measureBrier(pred$data$prob.1, pred$data$truth, negative = 0, positive = 1)

  df = generateThreshVsPerfData(pred, measure = list(fpr, tpr))

  gg_roc_glm = plot(roc_glm)
  gg_roc_glm + ggplot2::geom_line(data = df$data, ggplot2::aes(x = fpr, y = tpr), color = "dark red", alpha = 0.6) + ggplot2::theme_minimal()
}

datashield.logout(connections)
