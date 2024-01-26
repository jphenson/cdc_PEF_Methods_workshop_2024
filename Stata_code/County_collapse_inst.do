// This do file uses the CCP, Dartmouth, and Casino data. The data is then collapsed at the county level.
//args yr
local yr=2010
capture log using "Final_CCP_county_levelyr_`yr'.log",replace
clear all 

local var1 "riskscore real_sum_90dplus_sd real_sum_90dplus_autof real_sum_90dplus_autob real_sum_90dplus_allauto real_sum_90dplus_fmtg real_sum_90dplus_he_nstl real_sum_90dplus_he_rev real_sum_total real_sum_total_autof real_sum_total_autob real_sum_total_allauto real_sum_total_fmtg real_sum_total_he_nstl real_sum_total_he_rev count_90dplus_sd count_share_90dplus_sd count_90dplus_autof count_share_90dplus_autof count_90dplus_autob count_share_90dplus_autob count_90dplus_allauto count_total_allauto count_share_90dplus_allauto count_90dplus_fmtg count_total_fmtg count_share_90dplus_fmtg count_90dplus_he_rev count_total_he_rev count_share_90dplus_he_rev count_90dplus_allmtg count_total_allmtg count_share_90dplus_allmtg age bankrupt24mo bankruptflag cma_attr3904 cma_attr3905 sevdel birthyear panelid urate state_id year qtr county_id "


!echo "county means instance `yr' started"|mail jphenson1218@gmail.com
cd "CCP_Data_Setup/Data"
use SEER_pop_ccp.dta,clear
drop if age<18
drop if age>64
keep if year==`yr'
bys year county_id: egen allpop=total(pop)
bys year county_id: keep if _n==1
drop age pop
rename allpop pop_18_64
save pop_`yr'_temp.dta,replace
capture noisily{
forvalues j=1(1)4{
display("dataset has started loading")
use `var1' using "final_`yr'_jph.dta" if qtr==`j',clear
merge m:1 year county_id using pop_`yr'_temp.dta
keep if _merge==3
drop _merge
// The real variables were added in the limited_states_CCP_data_setup.do
display("dataset has finished loading")
gen forec24mo=.
gen forecflag=.
replace forec24mo=0 if cma_attr3904=="0"
replace forec24mo=1 if cma_attr3904=="1"
replace forecflag=0 if cma_attr3905=="0"
replace forecflag=1 if cma_attr3905=="1"

// Correcting the age variable 
replace age=. if birthyear==0
capture gen age18_64= 0 
capture gen age21_64 = 0
capture gen age65on = 0 
replace age18_64= 0 
replace age21_64 = 0
replace age65on = 0 
replace age18_64 = 1 if age>=18&age<=64
replace age21_64 = 1 if age>=21&age<=64
replace age65on = 1 if age>=65
drop if age<18
drop if age>64

bys panelid qtr:gen dup_check=_n
assert dup_check==1
bys county_id qtr:egen cnty_bank_count=total(bankruptflag)
bys county_id qtr:egen cnty_sevdel_count=total(sevdel)
bys county_id qtr:egen cnty_forecflag_count=total(forecflag)
bys county_id qtr:egen cnty_bank_obs=count(bankruptflag)
bys county_id qtr:egen cnty_sevdel_obs=count(sevdel)
bys county_id qtr:egen cnty_forecflag_obs=count(forecflag)
// Keeping only the variables remaining after the collapse command
gen cnty_bank_count_per100k=cnty_bank_count/(pop_18_64/100000)
gen cnty_sevdel_count_per100k=cnty_sevdel_count/(pop_18_64/100000)
gen cnty_forecflag_count_per100k=cnty_forecflag_count/(pop_18_64/100000)
destring state_id,replace

// Starting the collapse
display("collapse command has started")
gcollapse (mean) /*
*/mean_riskscore=riskscore mean_real_sum_90dplus_sd=real_sum_90dplus_sd mean_real_sum_90dplus_autof=real_sum_90dplus_autof mean_real_sum_90dplus_autob=real_sum_90dplus_autob /*
*/mean_real_sum_90dplus_allauto=real_sum_90dplus_allauto mean_real_sum_90dplus_fmtg=real_sum_90dplus_fmtg mean_real_sum_90dplus_he_nstl=real_sum_90dplus_he_nstl /*
*/mean_real_sum_90dplus_he_rev=real_sum_90dplus_he_rev mean_real_sum_total=real_sum_total mean_real_sum_total_autof=real_sum_total_autof /*
*/mean_real_sum_total_autob=real_sum_total_autob mean_real_sum_total_allauto=real_sum_total_allauto mean_real_sum_total_fmtg=real_sum_total_fmtg /*
*/mean_real_sum_total_he_nstl=real_sum_total_he_nstl mean_real_sum_total_he_rev=real_sum_total_he_rev /*
*/mean_count_90dplus_sd=count_90dplus_sd mean_count_share_90dplus_sd=count_share_90dplus_sd mean_count_90dplus_autof=count_90dplus_autof /*  
*/mean_count_share_90dplus_autof=count_share_90dplus_autof mean_count_90dplus_autob=count_90dplus_autob mean_count_share_90dplus_autob=count_share_90dplus_autob /*
*/mean_count_90dplus_allauto=count_90dplus_allauto mean_count_total_allauto=count_total_allauto mean_count_share_90dplus_allauto=count_share_90dplus_allauto  /*
*/mean_count_90dplus_fmtg=count_90dplus_fmtg mean_count_total_fmtg=count_total_fmtg mean_count_share_90dplus_fmtg=count_share_90dplus_fmtg  /*
*/mean_count_90dplus_he_rev=count_90dplus_he_rev mean_count_total_he_rev=count_total_he_rev mean_count_share_90dplus_he_rev=count_share_90dplus_he_rev   /*
*/mean_count_90dplus_allmtg=count_90dplus_allmtg mean_count_total_allmtg=count_total_allmtg mean_count_share_90dplus_allmtg=count_share_90dplus_allmtg /*
*/mean_age=age mean_bankrupt24mo=bankrupt24mo mean_bankruptflag=bankruptflag mean_sevdel=sevdel /*
*/mean_urate=urate mean_forecflag=forecflag mean_forec24mo=forec24mo /*
*/(median)   /*
*/med_riskscore=riskscore med_real_sum_90dplus_sd=real_sum_90dplus_sd med_real_sum_90dplus_autof=real_sum_90dplus_autof med_real_sum_90dplus_autob=real_sum_90dplus_autob /*
*/med_real_sum_90dplus_allauto=real_sum_90dplus_allauto med_real_sum_90dplus_fmtg=real_sum_90dplus_fmtg med_real_sum_90dplus_he_nstl=real_sum_90dplus_he_nstl /*
*/med_real_sum_90dplus_he_rev=real_sum_90dplus_he_rev med_real_sum_total=real_sum_total med_real_sum_total_autof=real_sum_total_autof /*
*/med_real_sum_total_autob=real_sum_total_autob med_real_sum_total_allauto=real_sum_total_allauto med_real_sum_total_fmtg=real_sum_total_fmtg /*
*/med_real_sum_total_he_nstl=real_sum_total_he_nstl med_real_sum_total_he_rev=real_sum_total_he_rev /*
*/med_count_90dplus_sd=count_90dplus_sd med_count_share_90dplus_sd=count_share_90dplus_sd med_count_90dplus_autof=count_90dplus_autof /*  
*/med_count_share_90dplus_autof=count_share_90dplus_autof med_count_90dplus_autob=count_90dplus_autob med_count_share_90dplus_autob=count_share_90dplus_autob /*
*/med_count_90dplus_allauto=count_90dplus_allauto med_count_total_allauto=count_total_allauto med_count_share_90dplus_allauto=count_share_90dplus_allauto  /*
*/med_count_90dplus_fmtg=count_90dplus_fmtg med_count_total_fmtg=count_total_fmtg med_count_share_90dplus_fmtg=count_share_90dplus_fmtg  /*
*/med_count_90dplus_he_rev=count_90dplus_he_rev med_count_total_he_rev=count_total_he_rev med_count_share_90dplus_he_rev=count_share_90dplus_he_rev   /*
*/med_count_90dplus_allmtg=count_90dplus_allmtg med_count_total_allmtg=count_total_allmtg med_count_share_90dplus_allmtg=count_share_90dplus_allmtg /*
*/med_age=age med_bankrupt24mo=bankrupt24mo med_bankruptflag=bankruptflag med_sevdel=sevdel  /*
*/med_urate=urate med_forecflag=forecflag med_forec24mo=forec24mo /*

*/(first)   /*
*/ cnty_bank_count cnty_sevdel_count cnty_forecflag_count_per100k cnty_bank_count_per100k cnty_sevdel_count_per100k state_id pop_18_64/*
*/   , by(year qtr county_id)
display("collapse command has completed")
label variable mean_age "mean(county level) age"
label variable mean_bankrupt24mo "mean(county level) count bankruptcy past 24mo"
label variable mean_bankruptflag "mean(county level) count current bankruptcy flag"
label variable mean_count_90dplus_allauto "mean(county level) count all auto trades 90 DPD or more"
label variable mean_count_90dplus_allmtg "mean(county level) count all home equity lines and first mortgage 90 DPD or more"
label variable mean_count_90dplus_autob "mean(county level) count all auto bank trades 90 DPD or more"
label variable mean_count_90dplus_autof "mean(county level) count all auto finance trades 90 DPD or more"
label variable mean_count_90dplus_fmtg "mean(county level) count all first morgage trades 90 DPD or more"
label variable mean_count_90dplus_he_rev "mean(county level) count home equity revolving 90 DPD or more"
label variable mean_count_90dplus_sd "mean(county level) count all trades 90 DPD or more"
label variable mean_count_share_90dplus_allauto "mean(county level) share all auto trades 90 DPD or more"
label variable mean_count_share_90dplus_allmtg "mean(county level) share all home equity lines and first mortgage 90 DPD or more"
label variable mean_count_share_90dplus_autob "mean(county level) share all auto bank trades 90 DPD or more"
label variable mean_count_share_90dplus_autof "mean(county level) share all auto finance trades 90 DPD or more"
label variable mean_count_share_90dplus_fmtg "mean(county level) share all first morgage trades 90 DPD or more"
label variable mean_count_share_90dplus_he_rev "mean(county level) share home equity revolving 90 DPD or more"
label variable mean_count_share_90dplus_sd "mean(county level) share all trades 90 DPD or more"
label variable mean_count_total_allauto "mean(county level) count all auto trades 90 DPD or more"
label variable mean_count_total_allmtg "mean(county level) count all auto trades 90 DPD or more"
label variable mean_count_total_fmtg "mean(county level) count all auto trades 90 DPD or more"
label variable mean_count_total_he_rev "mean(county level) count all auto trades 90 DPD or more"
label variable mean_forec24mo "mean(county level) count foreclosure w/in 24 months flag"
label variable mean_forecflag "mean(county level) count foreclosure flag"
label variable mean_real_sum_90dplus_allauto "mean(county level)real $ all auto trades 90 DPD or more"
label variable mean_real_sum_90dplus_autob "mean(county level)real $ all auto bank trades 90 DPD or more"
label variable mean_real_sum_90dplus_autof "mean(county level)real $ all auto finance trades 90 DPD or more"
label variable mean_real_sum_90dplus_fmtg "mean(county level)real $ all first morgage trades 90 DPD or more"
label variable mean_real_sum_90dplus_he_nstl "mean(county level)real $ home equity installment 90 DPD or more"
label variable mean_real_sum_90dplus_he_rev "mean(county level)real $ home equity revolving 90 DPD or more"
label variable mean_real_sum_90dplus_sd "mean(county level)real $ all trades 90 DPD or more"
label variable mean_real_sum_total "mean(county level)real $ all trades"
label variable mean_real_sum_total_allauto "mean(county level)real $ all auto trades"
label variable mean_real_sum_total_autob "mean(county level)real $ all auto bank trades"
label variable mean_real_sum_total_autof "mean(county level)real $ all auto finance trades"
label variable mean_real_sum_total_fmtg "mean(county level)real $ all first morgage trades"
label variable mean_real_sum_total_he_nstl "mean(county level)real $ home equity installment"
label variable mean_real_sum_total_he_rev "mean(county level)real $ home equity revolving"
label variable mean_riskscore "mean(county level) riskscore"
label variable mean_urate "mean(county level) unemployment rate"
label variable med_age "median(county level) age"
label variable med_bankrupt24mo "median(county level) count bankruptcy past 24mo"
label variable med_bankruptflag "median(county level) count current bankruptcy flag"
label variable med_count_90dplus_allauto "median(county level) count all auto trades 90 DPD or more"
label variable med_count_90dplus_allmtg "median(county level) count all home equity lines and first mortgage 90 DPD or more"
label variable med_count_90dplus_autob "median(county level) count all auto bank trades 90 DPD or more"
label variable med_count_90dplus_autof "median(county level) count all auto finance trades 90 DPD or more"
label variable med_count_90dplus_fmtg "median(county level) count all first morgage trades 90 DPD or more"
label variable med_count_90dplus_he_rev "median(county level) count home equity revolving 90 DPD or more"
label variable med_count_90dplus_sd "median(county level) count all trades 90 DPD or more"
label variable med_count_share_90dplus_allauto "median(county level) share all auto trades 90 DPD or more"
label variable med_count_share_90dplus_allmtg "median(county level) share all home equity lines and first mortgage 90 DPD or more"
label variable med_count_share_90dplus_autob "median(county level) share all auto bank trades 90 DPD or more"
label variable med_count_share_90dplus_autof "median(county level) share all auto finance trades 90 DPD or more"
label variable med_count_share_90dplus_fmtg "median(county level) share all first morgage trades 90 DPD or more"
label variable med_count_share_90dplus_he_rev "median(county level) share home equity revolving 90 DPD or more"
label variable med_count_share_90dplus_sd "median(county level) share all trades 90 DPD or more"
label variable med_count_total_allauto "median(county level) count all auto trades 90 DPD or more"
label variable med_count_total_allmtg "median(county level) count all auto trades 90 DPD or more"
label variable med_count_total_fmtg "median(county level) count all auto trades 90 DPD or more"
label variable med_count_total_he_rev "median(county level) count all auto trades 90 DPD or more"
label variable med_forec24mo "median(county level) count foreclosure w/in 24 months flag"
label variable med_forecflag "median(county level) count foreclosure flag"
label variable med_real_sum_90dplus_allauto "median(county level)real $ all auto trades 90 DPD or more"
label variable med_real_sum_90dplus_autob "median(county level)real $ all auto bank trades 90 DPD or more"
label variable med_real_sum_90dplus_autof "median(county level)real $ all auto finance trades 90 DPD or more"
label variable med_real_sum_90dplus_fmtg "median(county level)real $ all first morgage trades 90 DPD or more"
label variable med_real_sum_90dplus_he_nstl "median(county level)real $ home equity installment 90 DPD or more"
label variable med_real_sum_90dplus_he_rev "median(county level)real $ home equity revolving 90 DPD or more"
label variable med_real_sum_90dplus_sd "median(county level)real $ all trades 90 DPD or more"
label variable med_real_sum_total "median(county level)real $ all trades"
label variable med_real_sum_total_allauto "median(county level)real $ all auto trades"
label variable med_real_sum_total_autob "median(county level)real $ all auto bank trades"
label variable med_real_sum_total_autof "median(county level)real $ all auto finance trades"
label variable med_real_sum_total_fmtg "median(county level)real $ all first morgage trades"
label variable med_real_sum_total_he_nstl "median(county level)real $ home equity installment"
label variable med_real_sum_total_he_rev "median(county level)real $ home equity revolving"
label variable med_riskscore "median(county level) riskscore"
label variable med_urate "median(county level) unemployment rate"
label variable cnty_bank_count "county level bankruptcy count"
label variable cnty_sevdel_count "county level count of all trades 90 DPD or more"
label variable cnty_forecflag_count_per100k "county level foreclosures per 100K pop ages 18 to 64"
label variable cnty_bank_count_per100k "county level bankruptcy per 100K pop ages 18 to 64"
label variable cnty_sevdel_count_per100k "county level trades 90 DPD or more per 100K pop ages 18 to 64"
label variable state_id "State id variable"
label variable pop_18_64 "county level population ages 18 to 64"
display("save command has started")
save final_`yr'q`j'_CCP_county_level.dta,replace
}
clear all
use final_`yr'q1_CCP_county_level.dta
forvalues j=2(1)4{
append using final_`yr'q`j'_CCP_county_level.dta
}
save final_`yr'_CCP_county_level.dta,replace
forvalues j=1(1)4{
erase final_`yr'q`j'_CCP_county_level.dta
}
erase pop_`yr'_temp.dta
log close


}
if _rc==0{
!echo "county means instance `yr' finished"|mail jphenson1218@gmail.com
}
if _rc!=0{
!echo "county means instance `yr' ran into a problem"|mail jphenson1218@gmail.com
}
