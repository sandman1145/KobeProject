FILENAME REFFILE '/home/rgoodwin1/Stats2/project2KobeData.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.kobe1;
	GETNAMES=YES;
RUN;



/* here are some variables that i have removed w reasoning: 
- choosing action_type over combined_shot_type, because of descriptors such as "running jump shot"
- game_event_id, game_id and shot_id can be eliminated
- choose either lat lon or loc_x loc_y 
- could eliminate shot_zone_range as we have distance 
- eliminate team_id and team_name (all the same)
- eliminate game date, already have a lot of other factors pointing to time
- eliminate matchup and shot_id  */ 


/* remaining variables by qualitative vs quantitative: 
- qual: action_type, season, shot_type, shot_zone_area, shot_zone_basic, opponent
- quant: loc_x, loc_y, minutes_remaining, period, playoffs, seconds_remaining, shot_distance, attendance, arena_temp, avgnoisedb

/* Data step for new set 

I have combined period/minutes/seconds remaining to find game_seconds_left*/ 



data kobeNew(DROP = recId combined_shot_type game_event_id game_id lat lon shot_zone_range team_id team_name matchup game_date shot_id minutes_remaining seconds_remaining period);
set kobe_timeTotal;
run; 

proc contents data = kobeNew; run;

/* Look for variables that don't have a normal distribution */

/* create logistic model, need to do some sort of variable selection */

/* all variables */

proc logistic data  = kobeNew descending;
  class action_type season shot_type shot_zone_area shot_zone_basic opponent;
  model shot_made_flag = action_type season shot_type shot_zone_area shot_zone_basic opponent loc_x loc_y minutes_remaining period playoffs seconds_remaining shot_distance attendance arena_temp avgnoisedb;
run;

/* only quantitative variables  */
proc logistic data  = kobeNew descending;
  model shot_made_flag = loc_x loc_y minutes_remaining period playoffs seconds_remaining shot_distance attendance arena_temp avgnoisedb;
run;

/* ????  */
proc logistic data  = kobeNew descending;
  model shot_made_flag = shot_distance;
run;

proc freq data = kobeNew order = freq; 
tables shot_made_flag action_type shot_made_flag*action_type;
run;

/* "Does probability of shot going in decrease (and then know if it
decreases linearly) as distance from basket increases"
- want prob(shot_made_flag=1) as shot distance increases - look at the coefficient to determine linear */ 


/* When creating LDA model, should I standardize mean to 0 and variance to 1? */

