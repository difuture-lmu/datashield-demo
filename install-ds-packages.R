surl     = "https://opal-demo.obiba.org/"
username = "administrator"
password = "password"

opal = opalr::opal.login(username = username, password = password, url = surl)

pkgs = c("ds.predict.base", "ds.calibration", "ds.roc.glm")
for (pkg in pkgs) {
  check1 = opalr::dsadmin.install_github_package(opal = opal, pkg = pkg, username = "difuture-lmu")
  if (! check1)
    stop("[", Sys.time(), "] Was not able to install ", pkg, "!")

  check2 = opalr::dsadmin.publish_package(opal = opal, pkg = pkg)
  if (! check2)
    stop("[", Sys.time(), "] Was not able to publish methods of ", pkg, "!")
}

opalr::opal.logout(opal)
