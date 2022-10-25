/****************************************************************************************
Brief        : Judge if variables exist in specified dataset or not
Submacro     : NONE
Usage        : 
  *Example1: Check existence of one variable;
  %put %var_exist(sashelp.class,var=name);

  *Example2: Check existence of multiple variables;
  %put %var_exist(sashelp.class,var=name weight sex);

  *Example2: Check existence of multiple variables, return 0 if there is any variable doesn't exist;
  %put %var_exist(sashelp.class,var=name neverland sex);
Note         : The macro will return 1 if all variables exist in the dataset, or 0 if one variable doesn't.;
Reference    : SAS Help Documentation
Parameters   :
-------------------------------------------------------------------------------------------
Name          Required   Default            Description
-----------   --------   ----------------   -----------------------------------------------
dsin          Y          &syslast           Name of a dataset 
var           Y          NONE               Variables needed to detect existence, use space as delimiter if there are multiple variables
-------------------------------------------------------------------------------------------
History      :
-------------------------------------------------------------------------------------------
Date         Author            Description
----------   ---------------   ------------------------------------------------------------
2022-10-24   whymath           Original Version
-------------------------------------------------------------------------------------------
******************************************************************************************/

%macro var_exist(dsin,var=);
%local errcode did varcount _result_;

/*1. Parameter Check*/
%if %sysfunc(exist(&dsin.))=0 %then %let errcode=001;
%else %if %quote(&var.)=%str() %then %let errcode=002;

%exception:
%if &errcode.^=%str() %then %do;
  %if &errcode.=001 %then %put ERROR: Dataset "%quote(&dsin.)" is not exist.;
  %else %if &errcode.=002 %then %put ERROR: Parameter var= is not specified.;
  %else %if &errcode.=101 %then %put &errtext.;
  %put ERROR: &sysmacroname. terminated due to above reason.;
  %return;
%end;

/*2. Implementation*/
%let did=%sysfunc(open(&dsin.));
%if &did.^=0 %then %do;
  %let varcount=%sysfunc(countw(&var.));
  %let i=1;
  %do %while(&_result_.^=0 and &i<=&varcount.);
    %let varnum=%sysfunc(varnum(&did.,%scan(&var.,&i.,%str( ))));
    %let _result_=&varnum.;
    %let i=%eval(&i.+1);
  %end;
  %let did=%sysfunc(close(&did.));
%end;
%else %do;
  %let errtext=%sysfunc(sysmsg());
  %let errcode=101;
  %goto exception;
%end;

/*3. Return and Exit*/
%sysfunc(sign(&_result_.))
%mend;
