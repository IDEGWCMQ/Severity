
use Dataset
keep if pcrdate>=td(18jan2021)
keep if pcrdate<=td(15feb2021)
merge 1:1 hcno TestDate using CT
drop if _merge==2
drop if _merge==1
drop _merge
merge 1:m hcno using SevereInf
drop if _merge==2
gen CaseControl=1 if (Sev==3)
replace CaseControl=0 if (Sev==0 | Sev==1 | Sev==.) 
keep if CaseControl~=.
gen AgeCat=1 if age<10
replace AgeCat=2 if (age>=10 & age<20)
replace AgeCat=3 if (age>=20 & age<30)
replace AgeCat=4 if (age>=30 & age<40)
replace AgeCat=5 if (age>=40 & age<50)
replace AgeCat=6 if (age>=50 & age<60)
replace AgeCat=7 if (age>=60 & age<70)
replace AgeCat=8 if age>=70
label define AgeCat 1"0-9" 2"10-19" 3"20-29" 4"30-39" 5"40-49" 6"50-59" 7"60-69" 8"70+"
label values AgeCat AgeCat
gen Calendar=1 if inrange(TestDate, td(18jan2021), td(24jan2021))
replace Calendar=2 if inrange(TestDate, td(25jan2021), td(31jan2021))
replace Calendar=3 if inrange(TestDate, td(01feb2021), td(07feb2021))
replace Calendar=4 if inrange(TestDate, td(08feb2021), td(15feb2021))
label define Calendar 1"18-24 Jan" 2"25-31 Jan" 3"01-07 Feb" 4"08-15 Feb"
label values Calendar Calendar
ccmatch Sex AgeCat Calendar, cc(CaseControl) id(hcno)
keep if match~=.
gen UkVariant=1 if  ((nprotein_ct<=30 & orf1ab_ct<=30) & sprotein_ct==.)
replace UkVariant=0 if UkVariant==.
label define UkVariant 0"Not Uk variant" 1"UkVAriant"
label values UkVariant UkVariant
cc CaseControl UkVariant
summ age if CaseControl==1, detail
summ age if CaseControl==0, detail
ttest age, by(CaseControl)
gen AgeCatR=1 if age<30
replace AgeCatR=2 if (age>=30 & age<40)
replace AgeCatR=3 if (age>=40 & age<50)
replace AgeCatR=4 if (age>=50 & age<60)
replace AgeCatR=5 if (age>=60 & age<70)
replace AgeCatR=6 if age>=70
label define AgeCatR 1"0-29" 2"30-39" 3"40-49" 4"50-59" 5"60-69" 6"70+"
label values AgeCatR AgeCatR
tab AgeCatR CaseControl, col chi2
tab Sex CaseControl, col chi2
tab Natr CaseControl, col chi2
gen Age2=0 if (AgeCatR<=3 & AgeCatR~=.)
replace Age2=1 if (AgeCatR>=4 & AgeCatR~=.)
label define Age2 0"<50 years" 1">=50 years"
label values Age2 Age2
xi: logistic CaseControl i.UkVariant i.Age2
xi: logistic CaseControl i.UkVariant i.Age2 i.Sex
