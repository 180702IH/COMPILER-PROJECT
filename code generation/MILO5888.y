%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;


int count=0;
int qind=0;
int tos=-1;
int temp_char=0;

struct quadruple{
char operator[50];
char operand1[100];
char operand2[100];
char result[100];
} quad[250];


struct stack{
char c[1000]; 
} stk[250];


void addQuadruple(char op1[], char op[], char op2[], char result[])
{
strcpy (quad[qind].operator, op);
strcpy (quad[qind].operand1, op1);
strcpy (quad[qind].operand2, op2);
strcpy (quad[qind].result, result);
qind++;
}


void display_Quad()
{
printf ("%s ", quad[qind-1].result);
printf("=");
printf ("%s " , quad[qind-1].operand1);
printf ("%s ", quad[qind-1].operator);
printf ("%s \n", quad[qind-1].operand2);
}


void push1(char *c){
strcpy(stk[++tos].c, c);
}


char* pop1()
{
char* c=stk[tos].c;
tos=tos-1;
return c;
}

%}

/*%name parse*/


%union{
struct{
char type[10];
union{
int ival;
double dval;
char *sval;
}v; }t;
}

%token TPROGRAM TVAR TBEGIN TEND TREAD TWRITE TIF TTHEN TELSE TWHILE TDO TCASE TTO TDOWNTO TFOR TEQUAL TNOTEQUAL TGE TGT TLE TLT TASSIGN TPLUS TMINUS TMUL TDIV TOR TAND TNOT TMOD TLB TRB TLP TRP TSEMI TDOT TDOTDOT TCOMMA TCOLON TINTEGER TBOOLEAN TARRAY TOF TREAL TCHAR TINT TREALV TID TCHARV TSTRING


%%

start               :   TPROGRAM TID TSEMI declare TDOT {printf("\nvalid input\n");};
declare             :   simple_var complex_stmt ;
simple_var          :   TVAR simplevar_dec |  ;
simplevar_dec       :   simplevar_dec simplevar_decl  | simplevar_decl;
simplevar_decl      :   listn TCOLON types TSEMI  ;
types               :   simple_types { strcpy($<t.v.sval>$,$<t.v.sval>1); strcpy($<t.type>$,$<t.type>1); }
                    |   array_types  { strcpy($<t.v.sval>$,$<t.v.sval>1); strcpy($<t.type>$,$<t.type>1); } ;

array_types         :   TARRAY TLB TINT TDOTDOT TINT TRB TOF simple_types { strcpy($<t.type>$,$<t.type>8); };
simple_types        :   TINTEGER { strcpy($<t.type>$,"integer"); } 
                    |   TBOOLEAN { strcpy($<t.type>$,"boolean");  } 
                    |   TREAL { strcpy($<t.type>$,"real"); } 
                    |   TCHAR { strcpy($<t.type>$,"char"); };
listn               :   listn TCOMMA ID { 
    strcpy($<t.v.sval>$,strcat($<t.v.sval>1, ",")); 
    strcat($<t.v.sval>$,$<t.v.sval>3);
    } 
                    | ID { strcpy($<t.v.sval>$,$<t.v.sval>1); };
ID                  :   TID { strcpy($<t.v.sval>$,$<t.v.sval>1); };





IDT                 :   TID { $<t.v.sval>$ = $<t.v.sval>1;char c[5]; sprintf(c,"%s",$<t.v.sval>1); push1(c);};

IDTI                 :   TID {$<t.v.sval>$ = $<t.v.sval>1;char c[5]; sprintf(c,"%s",$<t.v.sval>1); push1(c);};


complex_stmt_tail   :   TBEGIN stmt_list_tail TEND  ;
complex_stmt        :   TBEGIN stmt_list TEND  ;
stmt_list           :   stmt_list stmt TSEMI |  ;
stmt_list_tail      :   stmt_list_tail stmt_tail TSEMI |  ;
stmt                :   TINT TCOLON no_label_stmt { /* Handle other statements */ } | no_label_stmt ;
no_label_stmt       :   assign_stmt | complex_stmt | if_stmt | while_stmt | for_stmt | proc_stmt   ;
stmt_tail           :   TINT TCOLON no_label_stmt_tail { /* Handle other statements */ } | no_label_stmt_tail ;
no_label_stmt_tail  :   assign_stmt | complex_stmt_tail | while_stmt_tail | for_stmt_tail | proc_stmt   ;

assign_stmt         :   IDTI TASSIGN expression   | IDTI TLB expression TRB TASSIGN expression ;

if_stmt             :   TIF expression TTHEN stmt_tail  else_clause ;
else_clause         :   TELSE stmt_tail | /* empty */ ;
while_stmt_tail     :   TWHILE expression TDO stmt_tail ;
for_stmt_tail       :   TFOR IDTI TASSIGN expression TTO expression TDO stmt_tail | TFOR IDTI TASSIGN expression TDOWNTO expression TDO stmt_tail ; 
while_stmt          :   TWHILE expression TDO stmt ;
for_stmt            :   TFOR IDTI TASSIGN expression TTO expression TDO stmt  | TFOR IDTI TASSIGN expression TDOWNTO expression TDO stmt_tail ;
proc_stmt           :   IDT { /* Handle procedure call */ } | TREAD TLP listnn TRP { /* Handle read statement */ } | TWRITE TLP args_list TRP { /* Handle write statement */ } ;


listnn              :   listnn TCOMMA IDTI
                    |   IDTI 
                    |   listnn TCOMMA IDTI TLB expression TRB  
                    |   IDTI TLB expression TRB ;
                        
                        
args_list           :   args_list TCOMMA expression 
                        | expression ;
			              
			              
expression          :   expression TGE expr {strcpy($<t.type>$,"integer");
    char str[5], str1[5]="t"; sprintf(str,"%d", temp_char++);
    strcat(str1, str); addQuadruple(pop1(), ">=", pop1(), str1);
    display_Quad(); push1(str1);
    }|   expression TGT expr {strcpy($<t.type>$,"integer");
    char str[5], str1[5]="t"; sprintf(str,"%d", temp_char++);
    strcat(str1, str); addQuadruple(pop1(), ">", pop1(), str1);
    display_Quad(); push1(str1);} |   expression TLE expr {strcpy($<t.type>$,"integer");
    char str[5], str1[5]="t"; sprintf(str,"%d", temp_char++);
    strcat(str1, str); addQuadruple(pop1(), "<=", pop1(), str1);
    display_Quad(); push1(str1);
    }|   expression TLT expr {strcpy($<t.type>$,"integer");
    char str[5], str1[5]="t"; sprintf(str,"%d", temp_char++);
    strcat(str1, str); addQuadruple(pop1(), "<=", pop1(), str1);
    display_Quad(); push1(str1);
    }|   expression TEQUAL expr {strcpy($<t.type>$,"integer");
    char str[5], str1[5]="t"; sprintf(str,"%d", temp_char++);
    strcat(str1, str); addQuadruple(pop1(), "=", pop1(), str1);
    display_Quad(); push1(str1);
    }|   expression TNOTEQUAL expr {strcpy($<t.type>$,"integer");
    }
                       |   expr {char *temp = pop1(); push1(temp);};
	
	
			         
			    
expr                :   expr TPLUS term {
if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");
else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0)) strcpy($<t.type>$,"real");
else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"real");
else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) strcpy($<t.type>$,"real");
char str[5], str1[5]="t"; sprintf(str,"%d", temp_char++);
strcat(str1, str);
addQuadruple(pop1(), "+", pop1(), str1);
display_Quad();push1(str1);


$<t.v.ival>$ = $<t.v.ival>1 + $<t.v.ival>3;
$<t.v.dval>$ = $<t.v.dval>1 + $<t.v.dval>3; 
}
|   expr TMINUS term {
if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");
else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0)) strcpy($<t.type>$,"real");
else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"real");
else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) strcpy($<t.type>$,"real");

char str[5], str1[5]="t"; sprintf(str, "%d", temp_char++);
strcat(str1, str); addQuadruple(pop1(), "-", pop1(), str1); display_Quad();
push1(str1);
$<t.v.ival>$ = $<t.v.ival>1 - $<t.v.ival>3;
$<t.v.dval>$ = $<t.v.dval>1 - $<t.v.dval>3; 
}
|   expr TOR term  {
if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");
char str[5], str1[5]="t"; sprintf(str, "%d", temp_char++);
strcat(str1, str); addQuadruple(pop1(), "or", pop1(), str1); display_Quad();
push1(str1);
}
|   term ;
                       
  
                       
term                :   term TMUL factor {
if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"integer"); $<t.v.ival>$ = $<t.v.ival>1 * $<t.v.ival>3; }
else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real"); $<t.v.dval>$ = $<t.v.ival>1 * $<t.v.dval>3; }
else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"real"); $<t.v.dval>$ = $<t.v.dval>1 * $<t.v.ival>3;}
else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real"); $<t.v.dval>$ = $<t.v.dval>1 * $<t.v.dval>3;}

char str[5], str1[5]="t"; sprintf(str, "%d", temp_char++);
strcat(str1, str); addQuadruple(pop1(), "*", pop1(), str1);
display_Quad(); push1(str1);
}
|   term TDIV factor {
strcpy($<t.type>$,"real");
                        if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"real");$<t.v.dval>$ = $<t.v.ival>1 / $<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0))  {strcpy($<t.type>$,"real");$<t.v.dval>$ = $<t.v.ival>1 / $<t.v.dval>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"real");$<t.v.dval>$ = $<t.v.dval>1 / $<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real");$<t.v.dval>$ = $<t.v.dval>1 / $<t.v.dval>3;}
                        char str[5], str1[5]="t"; sprintf(str, "%d", temp_char++);
                        strcat(str1, str); addQuadruple(pop1(), "/", pop1(), str1); display_Quad();
                        push1(str1);
                        
}
|   term TMOD factor {
if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");
else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0)) strcpy($<t.type>$,"integer");
else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");
else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) strcpy($<t.type>$,"integer");
char str[5], str1[5]="t"; sprintf(str, "%d", temp_char++);
strcat(str1, str); addQuadruple(pop1(), "%", pop1(), str1); display_Quad();
push1(str1);
}
|   term TAND factor {
if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");

char str[5], str1[5]="t"; sprintf(str, "%d", temp_char++);
                        strcat(str1, str); addQuadruple(pop1(), "and", pop1(), str1); display_Quad();
                        push1(str1);
                        $<t.v.ival>$ = $<t.v.ival>1 && $<t.v.ival>3;
}
|   factor;
		
	
		
			           
factor              :   IDT 
			|   values 
			|   TLP expression TRP {strcpy($<t.type>$,$<t.type>2);}
			|   TNOT factor {strcpy($<t.type>$,$<t.type>2);
            char str[5], str1[5]="t"; sprintf(str, "%d", temp_char++);
            strcat(str1, str); addQuadruple("", "not", pop1(), str1); display_Quad();
            push1(str1);}
			|   TMINUS factor {strcpy($<t.type>$,$<t.type>2);
             char str[5], str1[5]="t"; sprintf(str, "%d", temp_char++);
            strcat(str1, str); addQuadruple("", "-", pop1(), str1); display_Quad();
            push1(str1);}
			|   IDT TLB expression TRB {
			strcpy($<t.type>$,$<t.type>1);char c[100]; char *name = pop1();char *tempo= pop1(); strcat(tempo,"["); strcat(tempo,name); strcat(tempo,"]");sprintf(c,"%s",tempo);push1(c);
			};
			
			
			
values              :   TINT {strcpy($<t.type>$,"integer"); char c[5]; sprintf(c,"%d",$<t.v.ival>1); push1(c);
$<t.v.ival>$ = $<t.v.ival>1;
} 
                        | TREALV {strcpy($<t.type>$,"real");char c[5]; sprintf(c,"%f",$<t.v.dval>1); push1(c);$<t.v.dval>$ = $<t.v.dval>1;} 
                        | TCHARV {strcpy($<t.type>$,"char");char c[5];strcpy(c,$<t.v.sval>1);push1(c); $<t.v.sval>$ = $<t.v.sval>1;} 
                        | TSTRING ;
                        
                        
%%

void yyerror()
{
printf("\nsyntax error\n");
return;
}

int main(int argc, char *argv[]) 
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "Error: Unable to open file %s\n", argv[1]);
        return 1;
    }
    yyparse();
    // fclose(file);
    return 0;
}


