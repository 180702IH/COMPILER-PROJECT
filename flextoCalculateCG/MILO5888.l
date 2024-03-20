%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

typedef struct Course 
{
  char courseID[30];
  int units;
  int grade;
}course;

int comment_count=0;
char target[30];
int flag=0;
int valid_records=0;
int pos=0;
int flag2=0;
course courses[30];
int j=0;
float cg;
int sum=0;
int flagf=0;
int posf=0;
int w=0;
int skip=0;
char temp[30];
int unit;
int grade;

%}

%x COMMENT
%x DOLLAR
%x STUDENT
%x COURSE

%%

<INITIAL>"//"                                   {comment_count++; BEGIN COMMENT;}
<COMMENT>"\n"                                   {BEGIN(INITIAL);}
<COMMENT>.                                      ;
<INITIAL>[^$^"//"]*[$]                          {if(flag==1){valid_records++;flag=0;}BEGIN(DOLLAR);}
<DOLLAR>"//"                                    {comment_count++;BEGIN(COMMENT);}
<DOLLAR>"\n"                                    {BEGIN(INITIAL);}
<DOLLAR>[ \t\r\v\f]*[A-Z]+[0-9]+[ \t\r\v\f]*    {if(flag==1){valid_records++;flag=0;}if(strncmp(yytext,target,(strlen(target)-1))==0) flag2=1;BEGIN(STUDENT);}
<DOLLAR>.                                       {flag=0;BEGIN(INITIAL);}
<STUDENT>[<]                                    {flag=1;BEGIN(COURSE);}
<COURSE>[A-Z]+[0-9]+                            {skip++;if(flag2==1){strcpy(temp,yytext);}}
<COURSE>[2-4]                                   {skip++;if(flag2==1 && skip==2){unit=atoi(yytext);}}
<COURSE>(A-?|B-?|C)                             {skip++;if(flag2==1 && skip==3){if(strcmp(yytext,"A")==0){grade=10;}else if(strcmp(yytext,"A-")==0){grade=8;}else if(strcmp(yytext,"B")==0){grade=6;}else if(strcmp(yytext,"B-")==0){grade=4;}else if(strcmp(yytext,"C")==0){grade=2;}}}
<COURSE>[>]                                     {if(flag2==1 && skip==3){for(int i=0;i<=j;i++){if(strcmp(temp,courses[i].courseID)==0){posf=i;flagf=1;break;}}if(flagf==0){w=j;strcpy(courses[w].courseID,temp);}else w=posf;courses[w].units=unit;courses[w].grade=grade;if(flagf==0) j++;else flagf=0;}if(skip==3)flag=1;skip=0;BEGIN(STUDENT);} 
<COURSE>.                                       ;
<STUDENT>"//"                                   {flag2=0;comment_count++;BEGIN(COMMENT);}
<STUDENT>"\n"                                   {flag2=0;BEGIN(INITIAL);}
<STUDENT>[$]                                    {flag2=0;BEGIN(DOLLAR);}
<STUDENT>.                                      ;
<INITIAL>.                                      ;

%%

int main()
{
	FILE *file;
	file = fopen("input.txt", "r");
    if (file == NULL) 
    {
        printf("Error opening file: input2.txt\n");
        return 1;
    }
    if (fgets(target, sizeof(target), file) == NULL) 
    {
      	printf("Error reading file!\n");
    	fclose(file);
       	return 1;
	}
    fclose(file);
    yyin=fopen("data2.txt","r");
	yylex();
	if(flag==1)
	{
		flag = 0;
		valid_records++;
	}
	for(int i=0;i<j;i++)
	{
		sum+=courses[i].units;
	}
	for(int i=0;i<j;i++)
	{
		cg+=(courses[i].units * courses[i].grade);
	}
	cg/=sum;
	if(j==0) cg=0;
    yyout=fopen("output.txt","w");
    fprintf(yyout,"@%d@%d@%d@%d#",valid_records,comment_count,j,(int)round(cg*100));
    return 0;
}