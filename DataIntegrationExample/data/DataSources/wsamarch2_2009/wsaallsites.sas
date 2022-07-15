/*WSA files were sent to OW (Alice Mayio) for their website.  This was done in November 2008.  In January 2009
it was discovered that the WSA sites that were included in these data sets only included sites from the EAST.
the real WSA study included sites from the WEST as well.  New data sets are created here for

(1) distribution to OW, and
(2) replace the WSA sites on SWIM to reflect the entire study.

The list of sites to use can be found in wsa_condclass_wgt4b where EVALSTATUS = "TS"
New list of correct sites in wsa_siteInfo_ts_final where USED = "Y"
There are 1392 sites in this study.*/



libname wsafixes "D:\EMAPDATA\WSA\ToAMayio1_2009FIXALLSITES";

data sitelist;
   set wsafixes.wsa_siteinfo_ts_final;
    if USED = "Y";
	run;

/*For each data set, need the data from WSA and EMAP West for the sitevisit/year for the
index site.  For the WSA sites, these will all be in the WSA data.  For the EMAP West
data, need to pick them out of the EMAP West files.

Required files are (as determined by the November 2008 data call:

	BankGeometry
	Benthiccounts
	Benthicmetrics
	Canopycover
	channelconstraint
	fieldchemistry
	fishcover
	largewoody
	legacytree
	legacytreeMet
	mesosubstrate
	periphyton....NO LONGER REQUIRED
	phabbest
	phabmet
	rapidhabass
	rapidhabmets
	riparian
	siteinfo
	streamvelocity
	thalweg
	verification
	waterchemistry
	watershedstressor

  From the sitelist..... Make a table of the index visits.

*/

	data indxvisits;
	 set sitelist;
	 keep site_id year visit_no indxvis_extent 
            sampchem indxvis_chem indexvis_chem indexyr_chem
            sampbent indxvis_bent indexvis_bent indexyr_bent 
            sampphab indxvis_phab indexvis_phab indexyr_phab;
run; 

/*test for equality of visits*/

data indxvisits2;
 set indxvisits;
 if year = indexyr_chem AND visit_no = indexvis_chem then chemmatch="YES"; else chemmatch="NO";
 if year = indexyr_bent AND visit_no = indexvis_bent then bentmatch="YES"; else bentmatch="NO";
 if year = indexyr_phab AND visit_no = indexvis_phab then phabmatch="YES"; else phabmatch="NO";

 run;

 proc freq data=indxvisits2;
  tables chemmatch bentmatch phabmatch;
  run;

  data mismatch;
   set indxvisits2;
   if chemmatch = "NO" OR  bentmatch = "NO" OR  phabmatch = "NO";
   run;

 proc print data=mismatch;
  var site_id visit_no year indexyr_phab indexvis_phab phabmatch;
  where phabmatch="NO";
  run;

 /* chem mismatches:

  site_id	visit_id	year	indexyr_chem	indexvis_chem
  WUTP99-0563	1		2001		2000			1

  bent mismatches

  WCAP99-1039	1		2002			.			.
  WIDP99-0524	1		2000			.			.
  WIDP99-0700	1		2002			.			.
  WMTP99-0804	1		2004			.			.
  WNDP99-0570	1		2000			.			.
  WSDP99-0660	1		2002			.			.
  WSDP99-0679	1		2002			.			.
  WUTP99-0563	1		2001			2000		1
  WUTP99-0594	1		2004			.			.
  WWAP99-0617	1		2001			.			.

phab mismatches	
  WNDP99-0570	1		2000			.			.
  WUTP99-0563	1		2001			2000		1
  WWYP00-0513	2		2000			2000		1

-------------------

 get the combined phab files with the new site list

    BankGeometry
	Canopycover
	channelconstraint
	fishcover
	largewoody
	legacytree
	legacytreeMet
	mesosubstrate
	phabbest
	phabmet
	rapidhabass
	rapidhabmets
	riparian
	thalweg
*/

libname wsa "w:\data\im\wsa\data";

libname emap "w:\data\im\wemap\data";

/*BankGeometry (sub_bank)*/

OPTIONS MPRINT MLOGIC SYMBOLGEN;

%macro phabfix (t1, f1, t2, f2, f3); 
data sitelistphab;
 set sitelist;
 keep site_id visit_no year;
 /*from phabmatches above make the following changes*/
 if site_id="WNDP99-0570" then delete;
 if site_id="WUTP99-0563" then year=2000; /*NOTE THE DATA ARE FOR -0563 YEAR 2001*/
 run;

 proc sql;
  create table &t1  as 
    select a.*, b.* from sitelistphab as a
     INNER JOIN
    emap.&f1 as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 
 /*add the EAST sites*/
 proc sql;
  create table &t2  as 
    select a.*, b.* from sitelistphab as a
     INNER JOIN
    wsa.&f1 as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 data &f2;
  set  &t1 &t2;
  run;
data wsafixes.&f3;
 set &f2;
 run;
%mend phabfix;

%phabfix (bankgeoWest, sub_bank, bankgeoEast, bg, bankgeometry)
%phabfix (canpycovWest, canpycov, canpycovEast, cc, canopycover)
%phabfix (constrtWest, constrt, constrtEast, cstr, channelconstraint)
%phabfix (fishcovWest, fishcov, fishcovEast, fshcov, fishcover)
%phabfix (lgwoodyWest, lgwoody, lgwoodyEast, lgwoody, largewoody)
%phabfix (lgtreeWest, lgtree, lgtreeEast, lgtree, legacytree)
%phabfix (mhtreesWest, mhtrees, mhtreesEast, mhtrees, legacytreeMet)
%phabfix (mesosubWest, mesosub, mesosubEast, mesosub, mesosubstrate)
%phabfix (phabmetWest, phabmet, phabmetEast, phabmet, phabmet)
%phabfix (phabbestWest, phabbest, phabbestEast, phabbest, phabbest)
%phabfix (raphabasWest, raphabas, raphabasEast, raphabas, raphabas)
%phabfix (mhraphWest, mhraph, mhraphEast, mhraph, mhraph)
%phabfix (riparianWest, riparian, riparianEast, riparian, riparian)
%phabfix (thalwegWest, thalweg, thalwegEast, thalweg, thalweg)



 /*see if we have 1391 sites
  there are only 1390 sites because Utah -0563 is listed as 2001 in the phab files
  and in wsa_condclass_wgt4b the phab data are missing for that site
Check each of these files, because in at least one (constr) -0563 shows up as 2001*/


%macro phabchec (f1, f2);
  proc sql; 
  create table x as
   select distinct site_id, visit_no, year from &f1;
   quit;
  data x1;
   set x;
   inx = "Y";
   run;
   data &f2;
    merge x1 sitelistphab;
	 by site_id visit_no year;
	 run;
 title "result of &f2";
  proc print data=&f2;
   where inx = " ";
   run;
%mend phabchec;


%phabchec (bg, bg2)					    
%phabchec (cc, cc2)							
%phabchec (cstr, cstr2)					
%phabchec (fshcov, fshcov2)			
%phabchec (lgwoody, lgwoody2)		
%phabchec (lgtree, lgtree2)			
%phabchec (mhtrees, mhtrees2)		
%phabchec (mesosub, mesosub2)		
%phabchec (phabmet, phabmet2)		
%phabchec (phabbest, phabbest2)	
%phabchec (raphabas, raphabas2)	
%phabchec (mhraph, mhraph2)			
%phabchec (riparian, riparian2)	
%phabchec (thalweg, thalweg2)		


/*Water chemistry..... create proper sitelistchem.*/;

data sitelistchem;
 set sitelist;
 keep site_id visit_no year;
 /*from chemmatches above make the following changes*/
 if site_id="WUTP99-0563" then year=2000; 
 run;

 proc sql;
  create table chemwest  as 
    select a.*, b.* from sitelistchem as a
     INNER JOIN
    emap.chem as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 
 /*add the EAST sites*/
 proc sql;
  create table chemeast  as 
    select a.*, b.* from sitelistchem as a
     INNER JOIN
    wsa.chem as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 data chemall;
  set  chemwest chemeast;
  run;
data wsafixes.waterchemistry;
 set chemall;
 run;


/*check the chem sites...viola there are 1392*/

  proc sql; 
  create table x as
   select distinct site_id, visit_no, year from chemall;
   quit;
  data x1;
   set x;
   inx = "Y";
   run;
   data chemall2;
    merge x1 sitelistchem;
	 by site_id visit_no year;
	 run;
 title "result of chemall2";
  proc print data=chemall2;
   where inx = " ";
   run;


/*bugs ....bentcnt and bentmet

   Bugs are not done, got files from Alan*/


/*
data sitelistbent;
 set sitelist;
 keep site_id visit_no year;
 /*from bentmmatches above make the following changes
 and there are a number of sites that appear not to have data, or data pending*/
/*
 if site_id="WUTP99-0563" then year=2000; 
 run;

 proc sql;
  create table bentcntwest  as 
    select a.*, b.* from sitelistbent as a
     INNER JOIN
    emap.bentcnt as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 
 /*add the EAST sites*/
 /*proc sql;
  create table bentcnteast  as 
    select a.*, b.* from sitelistbent as a
     INNER JOIN
    wsa.bentcnt as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 data bentcntall;
  set  bentcntwest bentcnteast;
  run;
data wsafixes.bentcnt;
 set bentcntall;
 run;


/*check the bent sites...viola there are 1392*/

/*  proc sql; 
  create table x as
   select distinct site_id, visit_no, year from bentcntall;
   quit;
  data x1;
   set x;
   inx = "Y";
   run;
   data bentcntall2;
    merge x1 sitelistbent;
	 by site_id visit_no year;
	 run;
 title "result of bentcntall2";
  proc print data=bentcntall2;
   where inx = " ";
   run;

/*next bentmet*/

/*
data sitelistbent;
 set sitelist;
 keep site_id visit_no year;
 /*from bentmmatches above make the following changes
 and there are a number of sites that appear not to have data, or data pending*/
/*
 if site_id="WUTP99-0563" then year=2000; 
 if site_id="WWYP00-0513" then visit_no=1;
 run;

 proc sql;
  create table bentmetwest  as 
    select a.*, b.* from sitelistbent as a
     INNER JOIN
    emap.bentmet as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 
 /*add the EAST sites*/
/* proc sql;
  create table bentmeteast  as 
    select a.*, b.* from sitelistbent as a
     INNER JOIN
    wsa.bentmet as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 data bentmetall;
  set  bentmetwest bentmeteast;
  run;
data wsafixes.bentmet;
 set bentmetall;
 run;


/*check the bent sites...there are 9 sites with "PENDING" bentsamp*/
/*
  proc sql; 
  create table x as
   select distinct site_id, visit_no, year from bentmetall;
   quit;
  data x1;
   set x;
   inx = "Y";
   run;
   data bentmetall2;
    merge x1 sitelistbent;
	 by site_id visit_no year;
	 run;
 title "result of bentmetall2";
  proc print data=bentmetall2;
   where inx = " ";
   run;


/*all the rest of the files (orphan-type) will be based on the sitelist (1392)*/

%macro restfix (t1, f1, t2, f2, f3); 
data sitelistrest;
 set sitelist;
 keep site_id visit_no year;
* /*from phabmatches above make the following changes*/
* if site_id="WNDP99-0570" then delete;
* if site_id="WUTP99-0563" then year=2000; /*NOTE THE DATA ARE FOR -0563 YEAR 2001*/
* if site_id="WWYP00-0513" then visit_no=1;
 run;

 proc sql;
  create table &t1  as 
    select a.*, b.* from sitelistrest as a
     INNER JOIN
    emap.&f1 as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 
 /*add the EAST sites*/
 proc sql;
  create table &t2  as 
    select a.*, b.* from sitelistrest as a
     INNER JOIN
    wsa.&f1 as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no AND a.year=b.year;
 quit;
 data &f2;
  set  &t1 &t2;
  run;
data wsafixes.&f3;
 set &f2;
 run;
%mend restfix;

/*%restfix (periphytonWest, periphyt, periphytonEast, periphyt, periphyton)*/
%restfix (flowWest, flow, flowEast, flow, streamvelocity)
%restfix (verificaWest, verifica, verificaEast, verifica, verification)

;



data insituwest;
 set insituwest;
FORMAT TIME HHMM.;
length char1 $5;
num1=TIME;
 char1=put(num1, hhmm.);
 *wrong1=put(num1, 10.5);
 *put char1= ;
 run;

data insituwest (rename=(char1=TIME));
 set insituwest;
 drop TIME  num1;
 run;


/*restfix2 for insitu files which don't have year var.*/
%macro restfix2 (t1, f1, t2, f2, f3); 
data sitelistrest;
 set sitelist;
 keep site_id visit_no ;
 run;

 proc sql;
  create table &t1  as 
    select a.*, b.* from sitelistrest as a
     INNER JOIN
    emap.&f1 as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no ;
 quit;
 
 

 /*add the EAST sites*/
 proc sql;
  create table &t2  as 
    select a.*, b.* from sitelistrest as a
     INNER JOIN
    wsa.&f1 as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no;
 quit;
 data &f2;
  set  &t1 &t2;
  run;
data wsafixes.&f3;
 set &f2;
 run;
%mend restfix2;
%restfix2 (insituWest, insitu, insituEast, insitu, fieldchemistry)
;
 data insitu;
  set  insituWest insituEast;
  run;
data wsafixes.fieldchemistry;
 set insitu;
 run;
proc sql;
  create table wsafixes.fieldchemistry2  as 
    select a.*, b.* from sitelistrest as a
     INNER JOIN
    wsafixes.fieldchemistry as b
   on a.site_id=b.site_id AND a.visit_no=b.visit_no;
 quit;

/*special for the stressor file... JUST USE THE STRESSOR_COMMON by Marc Weber*/;

/*proc sql;
  create table stressorWest  as 
    select a.*, b.* from sitelistrest as a
     INNER JOIN
    emap.stressor as b
   on a.site_id=b.site_id ;
 quit;
 */
 /*add the EAST sites*/
 proc sql;
  create table stressorEast  as 
    select a.*, b.* from sitelistrest as a
     INNER JOIN
    wsa.stressor_common as b
   on a.site_id=b.site_id ;
 quit;
 data stressor;
  set  /*stressorWest*/ stressorEast;
  run;
data wsafixes.watershedstressor;
 set stressor;
 run;



/*rest chec*/
 
%macro restchec (f1, f2);
  proc sql; 
  create table x as
   select distinct site_id, visit_no, year from &f1;
   quit;
  data x1;
   set x;
   inx = "Y";
   run;
   data &f2;
    merge x1 sitelist;
	 by site_id visit_no year;
	 run;
 title "result of &f2";
  proc print data=&f2;
   where inx = " ";
   run;
%mend restchec;


%restchec (insitu, insitu2)			
%restchec (periphyt, periphyt2)			
%restchec (flow, flow2)			
%restchec (verifica, verifica2)			
%restchec (stressor, stressor2)			












