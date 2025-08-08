devtools::clean_dll()
devtools::load_all()

library(profvis)
library(mixedprofileproject) # source("R/wrapper.R")

profvis({
  for (i in 1:20) {
    call_mixed(i)
  }
})
