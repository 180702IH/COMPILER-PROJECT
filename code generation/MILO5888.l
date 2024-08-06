%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
int line_no = 1;

%}

%x COMMENT

%%                                     

[pP][rR][oO][gG][rR][aA][mM]      {return TPROGRAM;}
[iI][nN][tT][eE][gG][eE][rR]      {return TINTEGER;}
[rR][eE][aA][lL]                  {return TREAL;}
[bB][oO][oO][lL][eE][aA][nN]      {return TBOOLEAN;}
[cC][hH][aA][rR]                  {return TCHAR;}
[vV][aA][rR]                      {return TVAR;}
[tT][oO]                          {return TTO;}
[oO][fF]                          {return TOF;}
[dD][oO][wW][nN][tT][oO]          {return TDOWNTO;}
[iI][fF]                          {return TIF;}
[eE][lL][sS][eE]                  {return TELSE;}
[wW][hH][iI][lL][eE]              {return TWHILE;}
[fF][oO][rR]                      {return TFOR;}
[dD][oO]                          {return TDO;}
[aA][rR][rR][aA][yY]              {return TARRAY;}
[aA][nN][dD]                      {return TAND;}
[oO][rR]                          {return TOR;}
[nN][oO][tT]                      {return TNOT;}
[bB][eE][gG][iI][nN]              {return TBEGIN;}
[eE][nN][dD]                      {return TEND;}
[rR][eE][aA][Dd]                  {return TREAD;}
[wW][rR][iI][tT][eE]              {return TWRITE;}
[tT][hH][eE][nN]                  {return TTHEN;}
"+"                               {return TPLUS;}
"-"                               {return TMINUS;}
"*"                               {return TMUL;}
"/"                               {return TDIV;}
"%"                               {return TMOD;}
":="                              {return TASSIGN;}
"="                               {return TEQUAL;}
"<>"                              {return TNOTEQUAL;}
"<"                               {return TLT;}
">"                               {return TGT;}
">="                              {return TGE;}
"<="                              {return TLE;}
":"                               {return TCOLON;}
","                               {return TCOMMA;}
";"                               {return TSEMI;}
"("                               {return TLP;}
")"                               {return TRP;}
"["                               {return TLB;}
"]"                               {return TRB;}
"."                               {return TDOT;}
".."                              {return TDOTDOT;}
[a-zA-Z]([a-zA-Z0-9_])*           {yylval.t.v.sval = (char*)malloc(strlen(yytext)+1);strcpy(yylval.t.v.sval,yytext);return TID;}
\"([^"]|"")([^"]|"")+\"           {yylval.t.v.sval = yytext;return TSTRING;}
'([^']|'')'                       {yylval.t.v.sval = yytext;return TCHARV;}
[0-9]+                            {yylval.t.v.ival = atoi(yytext);return TINT;}
[0-9]+"\."[0-9]+                  {yylval.t.v.dval = atof(yytext);return TREALV;}
"//"                              {BEGIN(COMMENT);}
<COMMENT>"\n"                     {line_no++;BEGIN(INITIAL);}
<COMMENT>.                        {}
[ \t\f\r\v]                       {}
"\n"                              {line_no++;}
.                                 {fprintf (stderr, "'%c' (0%o): illegal charcter at line %d\n",yytext[0], yytext[0], line_no);}
 
%%


