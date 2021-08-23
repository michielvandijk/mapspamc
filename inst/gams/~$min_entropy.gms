*******************************************************************************
********************               SPAMc                   ********************
*******************************************************************************

$ontext
min_entropy version of the Spatial Production Allocation Model for Country
level assessments (SPAMc)at various resolutions.

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
    sign         sign for negative slacks /plus,minus/
;

scalars
    scalef         scaling parameter for GAMS: number of grid cells
    epsilon original Tolerance to allow zero area shares /0.000001/
;

parameters
    report(*,*)     report on model performance
    priors(i,j)     prior information about area shares pre-scaled with scalef
    log_priors(i,j) log of priors per grid cell and crop-system
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
    entropy             entropy
    cl_slack(i)         slack for land cover
    ir_slack(i)         slack for ir_area
    sum_ir_slack        sum of ir slack
    sum_cl_slack        sum of cl slack
    sum_adm_slack       weighted sum of adm slacks
    sum_all_slack       weighted sum of all slacks
;

equations
    obj_min_entropy      Objective function: minimize entropy
    sum_one(j)           sum of land allocation shares is 1
    adm_stat_slack(k,s)  adm statistics constraint with slack
    adm_stat_slack2(k,s)
    ir_cover_slack(i)    irrigated crops constraint with slack
    cl_cover_slack(i)    land cover constraint with slack
;


*******************************************************************************
* load data from GDX file
*******************************************************************************

$gdxin %gdx_input%
$loaddc i j s k j_s
$loaddc n l m
$loaddc adm_area cl crop_area scalef ir_crop ir_area priors

system_grid(i,j) = yes;

* abort in case of negative values due to errors in pre processing
abort$sum(j$(ir_crop(j) < 0), 1) "ir_crop should be positive", ir_crop;
abort$sum(j$(crop_area(j) < 0), 1) "crop_area should be positive", crop_area;
abort$sum(i$(cl(i) < 0), 1) "cl should be positive", cl;
abort$sum(system_grid(i,j)$(priors(i,j) < 0), 1) "priors should be positive", priors;


*******************************************************************************
* Prepare
*******************************************************************************

* Initialize report
report('min_entropy', 'mstat') = 13;
report('min_entropy', 'sstat') = 13;


*******************************************************************************
* Set boundary values
*******************************************************************************

* Ensure that variables are positive
positive variable alloc, cl_slack, ir_slack, adm_slack;

* Alloc can not be higher than scalef (=100% or 1 after scaling)
* meaning all crop_area in one grid cell i or scalef*cl(i)/crop_area(j),
* or grid-cell area/total crop area when crop area is divided over more grid cells
alloc.up(i,j) = min(scalef, scalef*cl(i)/crop_area(j))$crop_area(j);

*******************************************************************************
* Objective functions
*******************************************************************************

* Objective function to allocate using entropy including slack
* We add weights for the slack to ensure small adms receive smaller slack
* We prefer to have s_slack over adm, cl and ir slack and therefore add weights
* Of these slacks with weights we would like to minize ir and cl slack so add
* a higher weight than for adm.
* Note that the priors are already scaled by scalef to ensure they are not too small
* Hence there is no need to apply 1/scalef in the objective function
slackweights(k,s)$adm_area(k,s) = 1/adm_area(k,s);
log_priors(i,j)=log(priors(i,j)+epsilon);
obj_min_entropy.. entropy =e= sum(system_grid(i,j),
         alloc(i,j)*(log(alloc(i,j)+epsilon)-log_priors(i,j))) +
         1e5*sum(m$adm_area(m), slackweights(m)*(adm_slack(m,'plus') + adm_slack(m,'minus'))) +
         1e6*sum(i,cl_slack(i)) +
         1e6*sum(i,ir_slack(i));


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

*******************************************************************************
* Model: minimize entropy
*******************************************************************************

* Initial values
alloc.l(i,j) = priors(i,j);
entropy.l = 0 ;
adm_slack.l(k,s,sign) = 0.0 ;
ir_slack.l(i) = 0;
cl_slack.l(i) = 0;


* Model
model min_ent  /obj_min_entropy, sum_one, cl_cover_slack, adm_stat_slack, ir_cover_slack/;


* solver options
option
    limrow = 5
    limcol = 5
    solprint = off
    sysout = off
    nlp = MOSEK
    reslim = 900000
;

* solver options file
*Option NLP = MOSEK;
*$onecho > mosek.opt
*$offecho
*min_ent.OptFile = 1;


* Fixes constant variables (where lower and upper bound is equal) and simplifies model
min_ent.holdfixed = 1;

* Solve model
solve min_ent using nlp minimize entropy;

* check entropy
parameters entropy_l entropy;
entropy_l = entropy.l
display entropy_l;

* Abort if min_entropy does not result in solution
if (min_ent.modelstat > 2,
    abort$1 "min_entropy was not solved!"
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

* Calculate sum of slacks
sum_ir_slack_l = sum(i, ir_slack.l(i));
sum_cl_slack_l = sum(i, cl_slack.l(i));

* we sum up plus and min. Normally plus and min slack are the same.
* However in case of statistical inconsistencies in the adm data there might be differences.
sum_adm_slack_l = sum(m,
              (adm_slack.l(m,'plus')+ adm_slack.l(m,'minus')));
sum_all_slack_l = sum_ir_slack_l + sum_cl_slack_l + sum_adm_slack_l;

display sum_all_slack_l;
display sum_ir_slack_l;
display sum_cl_slack_l;
display sum_adm_slack_l;


parameters
    palloc(i,j)           Allocations
    rur_pop_alloc(i,j)    Allocation based on rural population
;

* Allocation
palloc(i,j) = alloc.l(i,j)*crop_area(j)/scalef;

* Reporting
report('min_entropy', 'mstat') = min_ent.modelstat;
report('min_entropy', 'sstat') = min_ent.solvestat;
report('min_entropy', 'resusd') = min_ent.resusd;


*******************************************************************************
* Save
*******************************************************************************

execute_unload "%gdx_output%",
adm_area, cl crop_area, scalef, ir_crop, ir_area, entropy,
alloc, palloc, report, sum_cl_slack_l, sum_adm_slack_l, sum_ir_slack_l, entropy_l,
ir_slack_l, adm_slack_l, cl_slack_l;

$onListing
