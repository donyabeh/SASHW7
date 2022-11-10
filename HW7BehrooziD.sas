1a;
filename readfile '/home/u62368731/sasuser.v94/Homework/Halloween Candy.csv';
data hallCandies;
	infile readfile dlm = ',' dsd firstobs = 2;
	input id $ age costume M_and_Ms Three_Musketeers Milky_Way Snickers Twizzlers Laffy_Taffy Mars Reeses
	Swedish_Fish Gobstoppers Milk_Duds Tootsie_Rolls Kit_Kat Starburst Butterfinger;
run;

*1b;
proc means data = hallCandies;
	var age costume;
run;

*1c;
proc means noprint data = hallCandies;
	var costume;
	output out = costumeSummary mean(costume) = costume_mean;
run;

data recoded_candies (drop=_type_ _freq_);
	if _N_ = 1 then set costumeSummary;
	set hallCandies;
	tot_candy = sum(of M_and_Ms -- Butterfinger);
	avg_candy = mean(of M_and_Ms -- Butterfinger);
	if age >= 0 and age <= 5 then ageGrp = 1;
	else if 5 < age <= 10 then ageGrp = 2;
	else if 10 < age <= 15 then ageGrp = 3;
	else if 15 < age <=20 then ageGrp = 4;
	else if age > 20 then ageGrp = 5;
	if costume > costume_mean then costume_abv_avg = 1;
	else costume_abv_avg = 0;
run;

*1d;
proc freq data = recoded_candies;
	tables ageGrp costume_abv_avg;
run;

*1e;
proc format;
	value age 1 = '0-5'
	          2 = '6-10'
	          3 = '11-15'
	          4 = '16-20'
	          5 = '21+';
	 value costume 1 = 'Above Average'
	               0 = 'Below Average';
run;

ods noptitle;
proc means data = recoded_candies nonobs maxdec=2;
	var tot_candy;
	class ageGrp;
	title 'Descriptive Statistics for Total Candy by Age Group';
	label tot_candy = '(Total Candy)';
	label ageGrp = 'Age Group';
	format ageGrp age.;
run;

ods noptitle;
proc means data = recoded_candies nonobs maxdec=2;
	var tot_candy;
	class costume_abv_avg;
	title 'Descriptive Statistics for Total Candy by Costume';
	label tot_candy = '(Total Candy)';
	label costume_abv_avg = 'Costume';
	format costume_abv_avg costume.;
run;

*1f;
proc sort data = recoded_candies;
	by id;
run;

proc transpose data = recoded_candies out = new_candies (rename=(_name_=brand col1=count));
	by id;
	var M_and_Ms -- Butterfinger;
run;

proc print data = new_candies;
run;

*1g; *come back to this, maximum candies doesn't match the actual max from previous data set;
proc means data = new_candies;
	by id;
	var count;
run;

/*********************************************/
/* STAT 330, Fall 2022						 */
/* Homework #7B								 */
/* Donya Behroozi and Grace Trenholme		 */
/*********************************************/

*1a;
filename MEPSfile '/home/u62368731/my_shared_file_links/ulund/STAT 330/Data/Homework/H224.DAT';
data meps2020;
	infile MEPSfile;
	input dupersID $ 11-20 age20x 182-183 sex 192 oftsmk53 635-636 totexp20 2703-2709;
run;

data mepsUse;
  set meps2020;
  
  if age20x >= 18 and oftsmk53 >= 1;
  
  currSmoke = 0;
  if oftsmk53 in (1,2) then currSmoke = 1;
  
  if      18 <= age20x <= 34 then ageGrp = 1;
  else if 35 <= age20x <= 64 then ageGrp = 2;
  else if       age20x >= 65 then ageGrp = 3;
  
  if          totexp20  =    0 then expGrp = 1;
  else if 0 < totexp20 <= 1000 then expGrp = 2;
  else if     totexp20 >  1000 then expGrp = 3;
  
  if         0    <= totexp20 <= 224     then expQuartile = 1;
  else if  224    <  totexp20 <= 1546    then expQuartile = 2;
  else if 1546    <  totexp20 <= 5740.50 then expQuartile = 3;
  else if 5740.50 <  totexp20            then expQuartile = 4;
run;

*1b;
proc format;
	value quartile 1 = '1st Quartile'
	               2 = '2nd Quartile'
	               3 = '3rd Quartile'
	               4 = '4th Quartile';
	value age 1 = '18-34'
	          2 = '35-64'
	          3 = '65+';
	value gender 1 = 'Male'
	             2 = 'Female';
	value smoker 0 = 'Non-smoker'
	             1 = 'Smoker';
run;
	             
proc sgplot data = mepsUse pctlevel=group;
	vbar sex / stat=percent group=expQuartile;
	title justify=left 'Level of Medical Expenditures by Sex';
	xaxis label='Sex';
	yaxis label='% within Sex';
	format sex gender. expQuartile quartile.;
	keylegend / title='Expenditures';
run;

proc sgplot data = mepsUse pctlevel=group;
	vbar ageGrp / stat=percent group=expQuartile;
	title justify=left 'Level of Medical Expenditures by Age Group';
	xaxis label='Age Group';
	yaxis label='% within Age Group';
	format ageGrp age. expQuartile quartile.;
	keylegend / title='Expenditures';
run;

proc sgplot data = mepsUse pctlevel=group;
	vbar currSmoke / stat=percent group=expQuartile;
	title justify=left 'Level of Medical Expenditures by Smoking Status';
	xaxis label='Smoking Status';
	yaxis label='% within Smoking Status';
	format currSmoke smoker. expQuartile quartile.;
	keylegend / title='Expenditures';
run;

*1c;
proc freq data = mepsUse;
	tables sex*expQuartile;
run;

proc freq data = mepsUse;
	tables ageGrp*expQuartile;
run;

proc freq data = mepsUse;
	tables currSmoke*expQuartile;
run;
*The different colored areas in the graph above frequencies are row percents, as given in my proc freq outputs;

*2a;
filename nflFILE '/home/u62368731/sasuser.v94/Homework/NFL Points Per Team Per Game.csv';
data nfl;
	infile nflFILE dlm=',' dsd firstobs = 3;
	input Rk Year Tms RshTD RecTD PR_TD KR_TD FblTD IntTD OthTD AllTD twoPM twoPA D2P XPM XPA FGM FGA Sfty Pts;
run;

*2b;
proc means data = nfl;
	var Rk Tms Pts;
run;

*2c;
proc sgplot data = nfl;
	scatter x = Year y = Pts / markerattrs=(symbol=circlefilled color=grey);
	title1 justify=left 'Average points per team, per game';
	title2 justify=left 'NFL 1922-2022';
	xaxis values=(1920 to 2025 by 5) label='Year' valueattrs=(size=0.25 cm);
	yaxis values=(0 to 25 by 1) display =(nolabel) valueattrs=(size=0.25 cm);
run;

*2d;
data nfl_plot;
	set nfl;
	if Year = 2020 then is2020='2020';
	else is2020 = '';
run;

proc sgplot data = nfl_plot noborder;
	where 1970<= Year <= 2020;
	scatter x = Year y = Pts / markerattrs=(symbol=circlefilled color=grey) 
	datalabel = is2020 datalabelattrs=(color=red);
	title1 justify=left 'Average points per team, per game';
	xaxis display=(noline) values=(1970 to 2020 by 5) label='Year' valueattrs=(size=0.25 cm);
	yaxis grid display=(noline) values=(17 to 25 by 1) display =(nolabel) valueattrs=(size=0.25 cm);
run;
