**Prompt [Show sample profiling script for mixed code | Try in Copilot Chat](https://m365.cloud.microsoft/chat/entity1-d870f6cd-4aa5-4d42-9626-ab690c041429/eyJpZCI6IlZYTmxjbFl4ZkdoMGRIQnpPaTh2YzNWaWMzUnlZWFJsTFdsdWRDNXZabVpwWTJVdVkyOXRMM3hQU1VRNk5XSmtNamt4WXpBdE1UQTNPUzAwWVRBMExXRXhZVE10WldOaE9UWTRaR1E1T1RnMWZERTROV1EwWW1VNExUSTFZVEF0TkRFME1DMDVORFE0TFdVd1ptRmlOMlJtTWpFeVpud3lNREkxTFRBNExUQTNWREE0T2pBME9qQXhMakE1TWpZNU16VmEiLCJzY2VuYXJpbyI6InNoYXJlTGlua1ZpYVJpY2hDb3B5IiwicHJvcGVydGllcyI6eyJwcm9tcHRTb3VyY2UiOiJ1c2VyIiwiY2xpY2tUaW1lc3RhbXAiOiIyMDI1LTA4LTA3VDA4OjA0OjAxLjEyOFoifSwiY2hhdFR5cGUiOiJ3ZWIiLCJ2ZXJzaW9uIjoxLjF9)**
Show sample profiling script for mixed code
**Response**
Here’s a **sample profiling setup** for a mixed-language R project using **R**, **Rcpp (C++)**, and **Fortran**. This example demonstrates how to:

- Integrate C++ and Fortran code via Rcpp.
- Compile with profiling flags.
- Use `gprof` or `valgrind` to profile native code.
- Use `Rprof` or `profvis` for R-level profiling.

---

### 📁 Project Structure

```
mixed_profile_project/
├── src/
│   ├── mycode.cpp
│   ├── myfortran.f90
│   └── Makevars
├── R/
│   └── wrapper.R
└── test.R
```

---

### 🧩 `src/mycode.cpp` (Rcpp wrapper for Fortran)

```cpp
#include <Rcpp.h>

extern "C" {
  void myfortran_(int* x);
}

using namespace Rcpp;

// [[Rcpp::export]]
void call_fortran(int x) {
  myfortran_(&x);
}
```

---

### 🧮 `src/myfortran.f90` (Fortran subroutine)

```fortran
subroutine myfortran(x)
  integer :: x
  print *, "Fortran received:", x
end subroutine myfortran
```

---

### ⚙️ `src/Makevars` (compilation flags for profiling)

```make
PKG_CXXFLAGS = -pg -g
PKG_FCFLAGS = -pg -g
PKG_LIBS = -pg
```

---

### 📦 `R/wrapper.R` (R function calling C++)

```r
call_mixed <- function(x) {
  call_fortran(x)
}
```

---

### 🧪 `test.R` (Profiling script)

```r
library(profvis)
source("R/wrapper.R")

profvis({
  for (i in 1:1000) {
    call_mixed(i)
  }
})
```

---

### 🛠️ Profiling Native Code

After running `test.R`, you can profile the compiled shared object:

```bash
R CMD SHLIB src/mycode.cpp src/myfortran.f90
./test.R  # Run the R script

# Use gprof
gprof ./test.so gmon.out > analysis.txt

# Or use valgrind
valgrind --tool=callgrind Rscript test.R
kcachegrind callgrind.out.*
```

---

Would you like me to generate a working example or help you adapt this to your specific project setup?
