logitToAUC = function(x) 1 / (1 + exp(-x))
toLogit = function(x) log(x / (1 - x))

deLongVar = function(scores, truth) {
  # survivor functions for diseased and non diseased:
  s_d = function(x) 1 - ecdf(scores[truth == 1])(x)
  s_nond = function(x) 1 - ecdf(scores[truth == 0])(x)

  # Variance of empirical auc after DeLong:
  var_auc = var(s_d(scores[truth == 0])) / sum(truth == 0) + var(s_nond(scores[truth == 1])) / sum(truth == 1)

  return(var_auc)
}

pepeCI = function(logit_auc, alpha, var_auc) {
  logit_auc + c(-1, 1) * qnorm(1 - alpha / 2) * sqrt(var_auc) / (logitToAUC(logit_auc) * (1 - logitToAUC(logit_auc)))
}

