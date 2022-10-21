/****************************************************************************************
Brief        : Get variables list of specified dataset
Submacro     : NONE
Usage        : 
  *Example1: Print variables of "sashelp.class";
  %put %ds_varlist(sashelp.class);

  *Example2: Print numeric variables of "sashelp.class";
  %put %ds_varlist(sashelp.class,type=N);

  *Example3: Print numeric variables that match regular expression "/ht$/" of "sashelp.class";
  %put %ds_varlist(sashelp.class,type=N,pattern=/ht$/);
Note         : If none variable meet the filter criteria, the macro will return as blank value.;
Reference    : SAS Help Documentation
Parameters   :
-------------------------------------------------------------------------------------------
Name          Required   Default            Description
-----------   --------   ----------------   -----------------------------------------------
dsin          Y          &syslast           Name of a dataset 
type          N          NONE               Type of variables to be queried
pattern       N          NONE               Perl regular expression to fliter variable name
-------------------------------------------------------------------------------------------
History      :
-------------------------------------------------------------------------------------------
Date         Author            Description
----------   ---------------   ------------------------------------------------------------
2022-10-20   whymath           Original Version
-------------------------------------------------------------------------------------------
******************************************************************************************/

%macro ds_varlist(dsin,type=,pattern=)/minoperator;
%local errcode did varcount varname vartype _result_;

/*1. Parameter Check*/
%if %sysfunc(exist(&dsin.))=0 %then %let errcode=001;
%else %if %quote(&type.)^=%str() %then %do;
  %if %eval(%qupcase(&type.) in C N)=0 %then %let errcode=002;
%end;

%exception:
%if &errcode.^=%str() %then %do;
  %if &errcode.=001 %then %put ERROR: Dataset "%quote(&dsin.)" is not exist.;
  %else %if &errcode.=002 %then %put ERROR: Parameter TYPE= is expected to be one of: C, N.;
  %else %if &errcode.=101 %then %put &errtext.;
  %put ERROR: &sysmacroname. terminated due to above reason.;
  %return;
%end;

/*2. Implementation*/
%let did=%sysfunc(open(&dsin.));
%if &did.^=0 %then %do;
  %let varcount=%sysfunc(attrn(&did.,nvars));
  %do i=1 %to &varcount.;
    %let varname=%sysfunc(varname(&did.,&i.));
    %if %quote(&type.)^=%str() %then %do;
      %let vartype=%sysfunc(vartype(&did.,&i.));
      %if &vartype.^=&type. %then %let varname=;
    %end;
    %if %quote(&pattern.)^=%str() and %quote(&varname.)^=%str() %then %do;
      %if %sysfunc(prxmatch(&pattern.,&varname.))=0 %then %let varname=;
    %end;
    %let _result_=&_result_. &varname.;
  %end;
  %let did=%sysfunc(close(&did.));
%end;
%else %do;
  %let errtext=%sysfunc(sysmsg());
  %let errcode=101;
  %goto exception;
%end;

/*3. Return and Exit*/
&_result_.
%mend;
