*******************************************************************************
********************               mapspamc                ********************
*******************************************************************************

$ontext
max_score version of the Spatial Production Allocation Model for Country
level assessments (mapspamc) at various resolutions.

The input (gdx_input) and output (gdx_output) data files are parameters and
need to be set before the code can be run.

version 0.1
$offtext


*******************************************************************************
* Sets, parameters, variables, scalars
*******************************************************************************

$onempty

sets
    i            grid cells
    j            crop system combinations
    j_s(j)       subsistence system
    s            crop list
    k            adm list

    n(s,j)       crops with corresponding systems
    l(k,i)       adm with corresponding grid cells
    m(k,s)       adm with corresponding crops
    d(i,j)       grid cells and system for spatial detail
    system_grid(i,j)  All system grid cell combinatons
    sign sign for negative slacks /plus,minus/
;

scalars
    scalef         scaling parameter for GAMS: number of grid cells
    rps_factor     base value for alloc_s  /1/
;

parameters
    report(*,*)     report on model performance
    scores(i,j)      score per grid cell and crop-system
    adm_area(k,s)   crop area per adm
    cl(i)           crop cover per grid cell
    crop_area(j)    total area per crop-system
    ir_area(i)      irrigated area per grid cell
    ir_crop(j)      total irrigated crop area
    rur_pop_share(i,j)  rural population share per grid cell
    slackweights(k,s) weights for adm slacks
;

variables
    alloc(i,j)          allocation of crop j to plot i
    adm_slack(k,s,sign) slack variable for adm area
    sum_score           weighted sum of score
    cl_slack(i)         slack for land cover
    ir_slack(i)         slack for ir_area
    s_slack(i,j,sign)   slack for subsistence allocation
    sum_ir_slack        sum of ir slack
    sum_cl_slack        sum of cl slack
    sum_adm_slack       weighted sum of adm slacks
    sum_all_slack       weighted sum of all slacks
    sum_s_slack         sum of subsistence slack
;

equations
    obj_max_score        objective function: maximize score
    sum_one(j)           sum of land allocation shares is 1
    adm_stat_slack(k,s)  adm statistics constraint with slack
    ir_cover_slack(i)    irrigated crops constraint with slack
    cl_cover_slack(i)    land cover constraint with slack
    s_alloc_slack(i,j)   allocate subsistence share proportional to rural population
    rps_con(i,j)         ensure that s_alloc_slack is equal or larger than 1
;


*******************************************************************************
* load data from GDX file
*******************************************************************************

$gdxin %gdx_input%
$loaddc i j s k j_s
$loaddc n l m
$loaddc adm_area cl crop_area scalef ir_crop ir_area rur_pop_share scores

system_grid(i,j) = yes;

* abort in case of negative values due to errors in pre processing
abort$sum(j$(ir_crop(j) < 0), 1) "ir_crop should be positive", ir_crop;
abort$sum(j$(crop_area(j) < 0), 1) "crop_area should be positive", crop_area;
abort$sum(i$(cl(i) < 0), 1) "cl should be positive", cl;
abort$sum(system_grid(i,j)$(scores(i,j) < 0), 1) "score should be positive", scores;


*******************************************************************************
* Prepare
*******************************************************************************

* Initialize report
report('max_score', 'mstat') = 13;
report('max_score', 'sstat') = 13;


*******************************************************************************
* Set boundary values
*******************************************************************************

* Ensure that variables are positive
positive variable alloc, cl_slack, ir_slack, adm_slack, s_slack;

* Alloc can not be higher than scalef (=100% or 1 after scaling)
* meaning all crop_area in one grid cell i or scalef*cl(i)/crop_area(j),
* or grid-cell area/total crop area when crop area is divided over more grid cells
alloc.up(i,j) = min(scalef, scalef*cl(i)/crop_area(j))$crop_area(j);

*******************************************************************************
* Objective functions
*******************************************************************************

* Objective function to allocate using score including slack
* We add weights for the slack to ensure small adms receive smaller slack
* We prefer to have s_slack over adm, cl and ir slack and therefore add weights
* Of these slacks with weights we would like to minize ir and cl slack so add
* a higher weight than for adm.
slackweights(k,s)$adm_area(k,s) = 1/adm_area(k,s);
    obj_max_score.. sum_score =e= sum(system_grid(i,j), (1/scalef)*alloc(i,j)*scores(i,j)) -
    (sum(system_grid(i,j), (s_slack(i,j, 'plus') + s_slack(i,j, 'minus'))) +
        1e5*sum(m$adm_area(m), slackweights(m)*(adm_slack(m,'plus') + adm_slack(m,'minus'))) +
        1e6*sum(i,cl_slack(i)) +
        1e6*sum(i,ir_slack(i)));


*******************************************************************************
* Constraints
*******************************************************************************
* Constraint 1
* Allocated shares are in between 0 and 1
* Set by postive values and alloc.up statements above.
*

* Constraint 2
* sum of allocated shares for each crop over all grid cells is 1
*
sum_one(j)$crop_area(j)..
    (1/scalef)*sum(i, alloc(i,j)) =e= 1;

* Constraint 3
* Sum of allocated area over all crops should not exceed actual cropland in a grid cell.
*
cl_cover_slack(i)..
    (1/scalef)*sum(system_grid(i,j), alloc(i,j)*crop_area(j)) =l= cl(i) + cl_slack(i);


* Contstraint 4
* Irrigated grid cells are allocated
*
ir_cover_slack(i)..
    (1/scalef)*sum(j, alloc(i,j)*ir_crop(j)) =l= ir_area(i) + ir_slack(i);


* Constraint 5
* Total allocation per crop should be equal to land use in adm
* allow slack between adm_area and total allocation into (k,s)
* CHECK: SPAM uses additional constraint on artificial adms, for which no slack is allowed
*
adm_stat_slack(m(k,s))..
 (1/scalef)*sum((l(k,i),n(s,j)), alloc(i,j)*crop_area(j)) =e=
    adm_area(k,s) + (adm_slack(k,s,'plus') - adm_slack(k,s,'minus'));


* Constraint 6
* Subsistence allocation should be similar to rural population share in sample
*
* For S crops we want the crop area to be allocated in line with rural population.
* If we do not use weights, the model will push the allocated area to zero
* for crops with small total area = very low rural area starting values.

parameters
    small_area_weights(i,j)  Large weight for crops with small S area
    max_area                 Maximum of area otherwise slack becomes very large;

max_area = smax((j),crop_area(j));
small_area_weights(i,j)$rur_pop_share(i,j) = 1/crop_area(j)*max_area;

s_alloc_slack(i,j)$j_s(j)..
    alloc(i,j) =e= scalef*(rps_factor + small_area_weights(i,j)*
    (s_slack(i,j,'plus')- s_slack(i,j,'minus')))* rur_pop_share(i,j);


*******************************************************************************
* Model: mazimize suitability score
*******************************************************************************

* Initial values
adm_slack.l(k,s,sign) = 0.0 ;
ir_slack.l(i) = 0;
cl_slack.l(i) = 0;
alloc.l(i,j) = 0;
s_slack.l(i,j,sign) = 0;

* solver options
option
    limrow = 5
    limcol = 5
    solprint = off
    sysout = off
    lp  = cplex
    reslim = 900000
    BRatio = 1
;

* Model
model max_score  /obj_max_score, sum_one, cl_cover_slack, adm_stat_slack, ir_cover_slack, s_alloc_slack/;

* Fixes constant variables (where lower and upper bound is equal) and simplifies model
max_score.holdfixed = 1;

* Solve model
solve max_score using lp maximize sum_score;

* check sum_score
parameters sum_score_l sum of weighted score;
sum_score_l = sum_score.l
display sum_score_l;

* Abort if max_score model does not result in solution
if (max_score.modelstat > 2,
    abort$1 "max_score was not solved!"
);


*******************************************************************************
* Post-process
*******************************************************************************

parameters
    ir_slack_l(i)                ir_slack
    adm_slack_l(k,s,sign)        adm_slack
    cl_slack_l(i)                cl_slack
    s_slack_l(i,j,sign)          s_slack
    sum_ir_slack_l               sum of ir_slack
    sum_adm_slack_l              sum of adm_slack
    sum_cl_slack_l               sum of cl_slack
    sum_s_slack_l                sum of s_slack
    sum_all_slack_l              sum of all_slack
;


* Extract slacks
ir_slack_l(i) = ir_slack.l(i);
adm_slack_l(k,s,sign) = adm_slack.l(k,s,sign);
cl_slack_l(i) = cl_slack.l(i);
s_slack_l(i,j, sign) = s_slack.l(i,j, sign);

* Calculate sum of slacks
sum_ir_slack_l = sum(i, ir_slack.l(i));
sum_cl_slack_l = sum(i, cl_slack.l(i));
sum_s_slack_l = sum(system_grid(i,j),
                 small_area_weights(i,j)*(s_slack.l(i,j, 'plus') + s_slack.l(i,j, 'minus')));

* we sum up plus and min. Normally plus and min slack are the same.
* However in case of statistical inconsistencies in the adm data there might be differences.
sum_adm_slack_l = sum(m,
              (adm_slack.l(m,'plus')+ adm_slack.l(m,'minus')));
sum_all_slack_l = sum_s_slack_l + sum_ir_slack_l + sum_cl_slack_l + sum_adm_slack_l;

display sum_all_slack_l;
display sum_s_slack_l;
display sum_ir_slack_l;
display sum_cl_slack_l;
display sum_adm_slack_l;


parameters
    palloc(i,j)           Allocations
    rur_pop_alloc(i,j)    Allocation based on rural population
;

* Allocation
palloc(i,j) = alloc.l(i,j)*crop_area(j)/scalef;
rur_pop_alloc(i,j) = rur_pop_share(i,j)*crop_area(j);


* Reporting
report('max_score', 'mstat') = max_score.modelstat;
report('max_score', 'sstat') = max_score.solvestat;
report('max_score', 'resusd') = max_score.resusd;
report('min_all_slack', 'sum_all_slack') = sum_all_slack_l;
report('min_all_slack', 'sum_adm_slack') = sum_adm_slack_l;
report('min_all_slack', 'sum_cl_slack') = sum_cl_slack_l;
report('min_all_slack', 'sum_ir_slack') = sum_ir_slack_l;
report('min_all_slack', 'sum_s_slack') = sum_s_slack_l;


*******************************************************************************
* Save
*******************************************************************************

execute_unload "%gdx_output%",
adm_area, cl crop_area, scalef, ir_crop, ir_area, scores, rur_pop_share,
alloc, palloc, report, sum_cl_slack_l, sum_adm_slack_l, sum_ir_slack_l, sum_s_slack_l, sum_score_l,
ir_slack_l, adm_slack_l, s_slack_l, cl_slack_l, sum_all_slack_l, rur_pop_alloc;

$onListing
