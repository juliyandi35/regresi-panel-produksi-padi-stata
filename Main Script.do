*******************************************************
* ANALISIS REGRESI PANEL - PRODUKSI PADI
* Disiapkan untuk data: kapanewon-tahun (panel)
*******************************************************

clear all
set more off

*******************************************************
* 1. IMPORT DATA
*******************************************************
* Sesuaikan path file CSV/Excel kamu
import excel "C:\Research Consultant Projects\Project Regresi Panel Produksi Padi STATA\Kirim Olah Data.xlsx", firstrow clear

*******************************************************
* 2. SET DATA PANEL
*******************************************************
encode kapanewon, gen(id)
xtset id tahun
xtdescribe

*******************************************************
* 3. MODEL DASAR: Pooled OLS, Fixed Effect, Random Effect
*******************************************************
* Pooled OLS
reg ln_prod ln_lahan ln_tk ln_benih ln_pupuk

* Fixed Effect
xtreg ln_prod ln_lahan ln_tk ln_benih ln_pupuk, fe

* Random Effect
xtreg ln_prod ln_lahan ln_tk ln_benih ln_pupuk, re


*******************************************************
* 4. UJI PEMILIHAN MODEL
*******************************************************
* 4.1 Uji Chow (FE vs Pooled OLS)
reg ln_prod ln_lahan ln_tk ln_benih ln_pupuk i.id
testparm i.id       // jika signifikan → gunakan FE

* 4.2 Uji Hausman (FE vs RE)
* 1) Estimasi FE dan simpan residualnya dalam bentuk OLS
xtreg ln_prod ln_lahan ln_tk ln_benih ln_pupuk, fe
est store fe

* 2) Estimasi RE
xtreg ln_prod ln_lahan ln_tk ln_benih ln_pupuk, re
est store re

hausman fe re       // menentukan FE atau RE
* Karena hausman biasa tidak berjalan dengan baik akibat gagal memenuhi asumsi asimtotik, maka kita gunakan uji Hausman dengan Mundlak adjustment

* 3) Gunakan Mundlak Adjustment (Hausman alternatif)
* Buat group means untuk setiap variabel X
bysort id: egen mean_lahan = mean(ln_lahan)
bysort id: egen mean_tk    = mean(ln_tk)
bysort id: egen mean_benih = mean(ln_benih)
bysort id: egen mean_pupuk = mean(ln_pupuk)

* Estimasi Random Effect dengan Mundlak adjustment
xtreg prod_padi ln_lahan ln_tk ln_benih ln_pupuk ///
      mean_lahan mean_tk mean_benih mean_pupuk, re

* Uji apakah group means signifikan (ini adalah Hausman test versi valid)
test mean_lahan mean_tk mean_benih mean_pupuk

* Menurut teorema Mundlak (1978):
*FE = RE + means(X)
*Jika "means" signifikan → FE lebih cocok
*Jika "means" tidak signifikan → RE lebih cocok

* Karena means signifikan maka kita gunakan FE

* 4.3 Uji Lagrange Multiplier (RE vs Pooled)
xtreg ln_prod ln_lahan ln_tk ln_benih ln_pupuk, re
xttest0             // jika signifikan → RE lebih baik dari Pooled

* Keputusan akhir kita gunakan FE

*******************************************************
* 5. UJI ASUMSI KLASIK
*******************************************************

* 5.1 UJI NORMALITAS (menggunakan residual pooled OLS)
reg ln_prod ln_lahan ln_tk ln_benih ln_pupuk
predict resid, resid
sktest resid        // Shapiro-Wilk

* 5.2 UJI MULTIKOLINEARITAS
reg ln_prod ln_lahan ln_tk ln_benih ln_pupuk
vif                 // VIF < 10 adalah baik

* 5.3 UJI HETEROKEDASTISITAS
xtreg ln_prod ln_lahan ln_tk ln_benih ln_pupuk, fe
xttest3             // Modified Wald test (khusus FE)

* 5.4 UJI AUTOKORELASI
xtserial ln_prod ln_lahan ln_tk ln_benih ln_pupuk

*******************************************************
* 6. PENGUJIAN STATISTIK (SESUAI MODEL TERPILIH)
*******************************************************
xtreg ln_prod ln_lahan ln_tk ln_benih ln_pupuk, fe

* 6.1 Uji Signifikan Parsial (uji t)
* Tampil pada output FE/RE

* 6.2 Uji Signifikan Simultan (uji F)
* Tampil pada baris: F( ) = 

* 6.3 Koefisien Determinasi (R-squared)
* Tampil pada:
* - Within R2
* - Between R2
* - Overall R2

*******************************************************
* END OF SCRIPT
*******************************************************
