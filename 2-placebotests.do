clear all

*import delimited 
*linked_birth_water_county1970-1988.csv"
*This file has all births linked to water measures. 

drop if d>-90 
drop if dgest>60
drop if dbir>9000

drop datayear rectype restatus stateres cntyres cityres citrspop smsares metrores divres stsubres statenat cntynat divocc stsubocc
drop crace3 mage36 mage15 mage12 mage8 mage7 mage6 totord9 livord9 livord8 livord7 livord6 livord3 fage11 birwt12 birwt3 gestat10 gestat3 meduc14 meduc6 feduc14 mpre10 isllb17 isllb10 isllb8 term9

drop educstrflg lmprflg monprerflg llbrflg lfdrflg educsmsarflg congenrflg educstoflg lmpoflg monpreoflg llboflg lfdoflg

drop date fipsst countyname county pop_2000 latitude longitude x

drop if birattnd!=1
drop if dmeduc>65

global controls csex frace mrace dmage dfage dmeduc dfeduc outcome

foreach x in $controls{
	tab `x'
}

gen m_teen=0
replace m_teen=1 if dmage<18

gen m_old=0
replace m_old=1 if dmage>30

gen f_unk_age=0
replace f_unk_age=1 if dfage==99

gen m_no_hs=0 if dmeduc>=12 
replace m_no_hs=1 if dmeduc<12

gen m_hs_only=0 
replace m_hs_only=1 if dmeduc==12

gen f_no_hs=0 
replace f_no_hs=1 if dfeduc<12

gen f_hs_only=0
replace f_hs_only=1 if dfeduc==12

gen first=0
replace first=1 if outcome==1

gen prior_alive=0
replace prior_alive=1 if outcome==1

gen f_nhw=0
replace f_nhw=1 if frace==1
gen m_nhw=0
replace m_nhw=1 if mrace==1

destring(monprec), force replace

gen pn_first=0
replace pn_first=1 if monprec>=1 & monprec<=3

global controls csex f_nhw m_nhw m_teen m_old f_unk_age m_no_hs m_hs_only f_no_hs f_hs_only first prior_alive pn_first mar_code 
foreach x in $controls{
	tab year `x', missing
}

gen n_limit=0
replace n_limit=1 if nitrate_median>10

gen male=0
replace male=1 if csex==1

gen zero=0
replace zero=1 if nitrate_median==0

gen any_nitrate=0
replace any_nitrate=1 if nitrate_median>0

gen hundredth_nitrate=0
replace hundredth_nitrate=1 if nitrate_median>.1

gen five=0
replace five=1 if nitrate_median>5

gen ptb=0
replace ptb=1 if dgestat<37

*Begin summary sample stats*


estimates clear

gen w=1

log using "sens-d.log", text replace


****Tests****

eststo: reghdfe dbirwt c.nitrate_median i.($controls) c.dmage  i.dgest [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe dbirwt 1.n_limit i.($controls) c.dmage  i.dgest [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe dbirwt 1.five i.($controls) c.dmage  i.dgest [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe dbirwt 1.hundredth_nitrate i.($controls) c.dmage  i.dgest[pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe dbirwt 1.any i.($controls) c.dmage  i.dgest [pw=w], vce(cluster fips) absorb(fips#year year#month)


estimates clear
eststo: reghdfe dgestat c.nitrate_median i.($controls) c.dmage   [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe dgestat 1.n_limit i.($controls) c.dmage   [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe dgestat 1.five i.($controls) c.dmage   [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe dgestat 1.hundredth_nitrate i.($controls) c.dmage  [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe dgestat 1.any i.($controls) c.dmage   [pw=w], vce(cluster fips) absorb(fips#year year#month)

****lbw
gen lbw=0
replace lbw=1 if dbirwt<2500


****Tests****

eststo: reghdfe lbw c.nitrate_median i.($controls) c.dmage  i.dgest [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe lbw 1.n_limit i.($controls) c.dmage  i.dgest [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe lbw 1.five i.($controls) c.dmage  i.dgest [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe lbw 1.hundredth_nitrate i.($controls) c.dmage  i.dgest[pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe lbw 1.any i.($controls) c.dmage  i.dgest [pw=w], vce(cluster fips) absorb(fips#year year#month)



eststo: reghdfe ptb c.nitrate_median i.($controls) c.dmage   [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe ptb 1.n_limit i.($controls) c.dmage   [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe ptb 1.five i.($controls) c.dmage [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe ptb 1.hundredth_nitrate i.($controls) c.dmage [pw=w], vce(cluster fips) absorb(fips#year year#month)

eststo: reghdfe ptb 1.any i.($controls) c.dmage  [pw=w], vce(cluster fips) absorb(fips#year year#month)

esttab , b(4) ci(4) keep(nitrate_median* 1.n_limit* 1.five* 1.hundredth_nitrate* 1.any*)


esttab  using sens-d.csv , b(3) se(3) replace
esttab  using sens-e.csv , b(3) se(3) replace

estimates clear