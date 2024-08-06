%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;


char f[10000];
int ff=0;
char *s[50] = {NULL};
int p=0;
int is=0;
typedef struct {
    char name[50];
    char type[20];
    char value[100]; // Assuming values can be string representation
    int size;        // For arrays, if needed
} Symbol;

// Define a symbol table as an array of symbols
Symbol symbolTable[100]; // Adjust the size as needed

// Keep track of the current index in the symbol table
int symbolTableIndex = 0;

void insertSymbol(char *names, char *type, char *value, int size) {
    char *token = strtok(names, ",");
    while (token != NULL) {
        // Check if the symbol already exists in the symbol table
        if (findSymbol(token) ==1) {
            printf("\nError: Variable %s is already declared.\n", token);
            token = strtok(NULL, ",");
            continue;
        }
        Symbol symbol;
        strcpy(symbol.name, token);
        strcpy(symbol.type, type); // Store the variable type
        strcpy(symbol.value, value);
        symbol.size = size;
        symbolTable[symbolTableIndex++] = symbol;
        token = strtok(NULL, ",");
    }
}


int findSymbol(char *name) {
    for (int i = 0; i < symbolTableIndex; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return 1;
        }
    }
    return 0; // Symbol not found
}

%}

/*%name parse*/


%union{
struct{
char type[10];
char s[10000];
union{
int ival;
double dval;
char *sval;
}v; }t;
}

%token TPROGRAM TVAR TBEGIN TEND TREAD TWRITE TIF TTHEN TELSE TWHILE TDO TCASE TTO TDOWNTO TFOR TEQUAL TNOTEQUAL TGE TGT TLE TLT TASSIGN TPLUS TMINUS TMUL TDIV TOR TAND TNOT TMOD TLB TRB TLP TRP TSEMI TDOT TDOTDOT TCOMMA TCOLON TINTEGER TBOOLEAN TARRAY TOF TREAL TCHAR TINT TREALV TID TCHARV TSTRING


%%

start               :   TPROGRAM ID TSEMI declare TDOT {printf("\nvalid input\n");ff=1;};


declare             :   simple_var complex_stmt 


simple_var          :   TVAR simplevar_dec  |  ;


simplevar_dec       :   simplevar_dec simplevar_decl 
                    |   simplevar_decl 


simplevar_decl      :   listn TCOLON types TSEMI { insertSymbol($<t.v.sval>1, $<t.type>3, "", is);
                        strcpy($<t.s>$,"[ln[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[:]");strcat($<t.s>$,"[tp[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]] [;] ");} ;


types               :   simple_types { strcpy($<t.v.sval>$,$<t.v.sval>1); strcpy($<t.type>$,$<t.type>1);is=0;strcpy($<t.s>$,"[st[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");} 
                    |   array_types { strcpy($<t.v.sval>$,$<t.v.sval>1); strcpy($<t.type>$,$<t.type>1);strcpy($<t.s>$,"[at[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");};
                    
                    
array_types         :   TARRAY TLB TINT TDOTDOT TINT TRB TOF simple_types { strcpy($<t.type>$,$<t.type>8); is=1;
                        strcpy($<t.s>$,"[array][lb]");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"[..]");strcat($<t.s>$,$<t.s>5);strcat($<t.s>$,"[rb][of]");strcat($<t.s>$,"[st[");strcat($<t.s>$,$<t.s>8);strcat($<t.s>$,"]]");};


simple_types        :   TINTEGER { strcpy($<t.type>$,"integer"); strcpy($<t.s>$,"integer");} 
                    |   TBOOLEAN { strcpy($<t.type>$,"boolean"); strcpy($<t.s>$,"boolean");} 
                    |   TREAL { strcpy($<t.type>$,"real"); strcpy($<t.s>$,"real");} 
                    |   TCHAR { strcpy($<t.type>$,"char"); strcpy($<t.s>$,"char");};
                    
                    
listn               :   listn TCOMMA ID { strcpy($<t.v.sval>$,strcat($<t.v.sval>1, ",")); strcat($<t.v.sval>$,$<t.v.sval>3);
                        strcpy($<t.s>$,"[ln[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[,]");strcat($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");} 
                    |   ID { strcpy($<t.v.sval>$,$<t.v.sval>1);strcpy($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");};
                    
                    
ID                  :   TID { strcpy($<t.v.sval>$,$<t.v.sval>1); strcpy($<t.type>$,$<t.type>1);};





IDT                 :   TID {
    if(findSymbol($<t.v.sval>1)==0) printf("\nsemantic error: undeclared variable\n");
    int flag=0;
    for(int i=0;i<p;i++) if(strcmp(s[i],$<t.v.sval>1)==0) flag=1; if(flag==0) printf("\nunaasigned variable used\n") ;
    for(int i=0;i<symbolTableIndex;i++) 
    {
        if(strcmp(symbolTable[i].name,$<t.v.sval>1)==0) 
        {
            strcpy($<t.s>$,symbolTable[i].name);
            strcpy($<t.type>$,symbolTable[i].type);
            if((strcmp($<t.type>$,"integer") == 0))
            {
                    $<t.v.ival>$ = atoi(symbolTable[i].value);
            }
            else if((strcmp($<t.type>$,"real") == 0))
            {
                $<t.v.dval>$ = atof(symbolTable[i].value);
            }
            else if((strcmp($<t.type>$,"char") == 0))
            {
                strcpy($<t.v.sval>$,symbolTable[i].value);
            }
        }
    }
                             };
                            
IDTI                 :   TID {for(int i=0;i<symbolTableIndex;i++) if(strcmp(symbolTable[i].name,$<t.v.sval>1)==0) strcpy($<t.type>$,symbolTable[i].type); 
                            if(findSymbol($<t.v.sval>1)==0) printf("\nsemantic error: undeclared variable\n");
                            s[p++]=strdup($<t.v.sval>1);
                            for(int i=0;i<symbolTableIndex;i++) 
                            {
                                if(strcmp(symbolTable[i].name,$<t.v.sval>1)==0) 
                                {
                                    strcpy($<t.s>$,symbolTable[i].name);
                                    strcpy($<t.type>$,symbolTable[i].type);
                                    if((strcmp($<t.type>$,"integer") == 0))
                                    {
                                            $<t.v.ival>$ = atoi(symbolTable[i].value);
                                    }
                                    else if((strcmp($<t.type>$,"real") == 0))
                                    {
                                        $<t.v.dval>$ = atof(symbolTable[i].value);
                                    }
                                    else if((strcmp($<t.type>$,"char") == 0))
                                    {
                                        strcpy($<t.v.sval>$,symbolTable[i].value);
                                    }
                                }
                            }
                            };


complex_stmt_tail   :   TBEGIN stmt_list_tail TEND  {strcpy($<t.s>$,"[begin]");strcat($<t.s>$,"[slt[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[end]");};


complex_stmt        :   TBEGIN stmt_list TEND  {strcpy($<t.s>$,"[begin]");strcat($<t.s>$,"[sl[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[end]");};


stmt_list           :   stmt_list stmt TSEMI {strcpy($<t.s>$,"[stl[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[sm[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[;]"); }| {strcpy($<t.s>$,"");} ;


stmt_list_tail      :   stmt_list_tail stmt_tail TSEMI {strcpy($<t.s>$,"[slt[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[st[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[;]");}|  {strcpy($<t.s>$,"");};


stmt                :   no_label_stmt;


no_label_stmt       :   assign_stmt {strcpy($<t.s>$,"[as[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}
                        | complex_stmt {strcpy($<t.s>$,"[cs[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}
                        | if_stmt {strcpy($<t.s>$,"[ifs[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}
                        | while_stmt {strcpy($<t.s>$,"[ws[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}
                        | for_stmt {strcpy($<t.s>$,"[fs[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}
                        | proc_stmt {strcpy($<t.s>$,"[ps[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}  ;


stmt_tail           :   TINT TCOLON no_label_stmt_tail { strcpy($<t.s>$,"[int][:]");strcat($<t.s>$,"[nlst[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");} 
                    |   no_label_stmt_tail {strcpy($<t.s>$,"[nlst[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");};


no_label_stmt_tail  :   assign_stmt {strcpy($<t.s>$,"[as[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}| complex_stmt_tail {strcpy($<t.s>$,"[cst[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}| while_stmt_tail {strcpy($<t.s>$,"[wsl[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}| for_stmt_tail {strcpy($<t.s>$,"[fsl[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");}| proc_stmt  {strcpy($<t.s>$,"[ps[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");} ;


assign_stmt         :   IDTI TASSIGN expression {
    if(strcmp($<t.type>1,$<t.type>3)!=0) printf("semantic error: type mismatch \n");
    for(int i=0;i<symbolTableIndex;i++)
    {
        if(strcmp(symbolTable[i].name,$<t.s>1) == 0)
        {
            if(strcmp($<t.type>1,"integer") == 0)
                                {
                                    sprintf(symbolTable[i].value,"%d",$<t.v.ival>3);
                                }
                                else if(strcmp($<t.type>1,"real") == 0)
                                {
                                    sprintf(symbolTable[i].value,"%f",$<t.v.dval>3);
                                }
                                else
                                {
                                    strcpy(symbolTable[i].value,$<t.v.sval>3);
                                }    
        }
    }
                        }
                    |   IDTI TLB expression TRB TASSIGN expression { 
                        strcpy($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[lb]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");
                        strcat($<t.s>$,"[rb]");strcat($<t.s>$,"[assign]");strcat($<t.s>$,"[ex");strcat($<t.s>$,$<t.s>6);strcat($<t.s>$,"]]");
                        } ;


if_stmt             :   TIF expression TTHEN stmt_tail  else_clause {strcpy($<t.s>$,"[if]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");
                        strcat($<t.s>$,"[then]");strcat($<t.s>$,"[st[");strcat($<t.s>$,$<t.s>4);strcat($<t.s>$,"]]");strcat($<t.s>$,"[ec[");strcat($<t.s>$,$<t.s>5);strcat($<t.s>$,"]]");};


else_clause         :   TELSE stmt_tail {strcpy($<t.s>$,"[else]");strcat($<t.s>$,"[st[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");}| /* empty */ ;


while_stmt_tail     :   TWHILE expression TDO stmt_tail {strcpy($<t.s>$,"[while]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[do]");strcat($<t.s>$,"[st[");strcat($<t.s>$,$<t.s>4);strcat($<t.s>$,"]]");};


for_stmt_tail       :   TFOR IDTI TASSIGN expression TTO expression TDO stmt_tail {if(strcmp($<t.type>2,$<t.type>4)!=0) printf("semantic error:type mismatch \n");
                        strcpy($<t.s>$,"[for]");strcat($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[assign]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>4);strcat($<t.s>$,"]]");
                        strcat($<t.s>$,"[to]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>6);strcat($<t.s>$,"]]");strcat($<t.s>$,"[do]");strcat($<t.s>$,"[st[");strcat($<t.s>$,$<t.s>8);strcat($<t.s>$,"]]");}
                    |   TFOR IDTI TASSIGN expression TDOWNTO expression TDO stmt_tail {if(strcmp($<t.type>2,$<t.type>4)!=0) printf("semantic error:type mismatch \n");
                        strcpy($<t.s>$,"[for]");strcat($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[assign]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>4);strcat($<t.s>$,"]]");
                        strcat($<t.s>$,"[downto]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>6);strcat($<t.s>$,"]]");strcat($<t.s>$,"[do]");strcat($<t.s>$,"[st[");strcat($<t.s>$,$<t.s>8);strcat($<t.s>$,"]]");};  
                    
                    
while_stmt          :   TWHILE expression TDO stmt {strcpy($<t.s>$,"[while]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[do]");strcat($<t.s>$,"[st[");
                        strcat($<t.s>$,$<t.s>4);strcat($<t.s>$,"]]");};


for_stmt            :   TFOR IDTI TASSIGN expression TTO expression TDO stmt {if(strcmp($<t.type>2,$<t.type>4)!=0) printf("semantic error:type mismatch \n");
                        strcpy($<t.s>$,"[for]");strcat($<t.s>$,"[id[");strcat($<t.s>$, $<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[assign]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>4);strcat($<t.s>$,"]]");
                        strcat($<t.s>$,"[to]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>6);strcat($<t.s>$,"]]");strcat($<t.s>$,"[do]");strcat($<t.s>$,"[sm[");strcat($<t.s>$,$<t.s>8);strcat($<t.s>$,"]]");}  
                    |   TFOR IDTI TASSIGN expression TDOWNTO expression TDO stmt {if(strcmp($<t.type>2,$<t.type>4)!=0) printf("semantic error:type mismatch \n");
                        strcpy($<t.s>$,"[for]");strcat($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>2);strcat($<t.s>$,"]]");strcat($<t.s>$,"[assign]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>4);strcat($<t.s>$,"]]");
                        strcat($<t.s>$,"[downto]");strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>6);strcat($<t.s>$,"]]");strcat($<t.s>$,"[do]");strcat($<t.s>$,"[sm[");strcat($<t.s>$,$<t.s>8);strcat($<t.s>$,"]]");};  
                    
                    
proc_stmt           :   IDT { strcpy($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]"); } 
                    |   TREAD TLP listnn TRP { strcpy($<t.s>$,"[read][lp]");strcat($<t.s>$,"[lnn[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");strcat($<t.s>$,"[rp]"); } 
                    |   TWRITE TLP args_list TRP { strcpy($<t.s>$,"[write][lp]");strcat($<t.s>$,"[al[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");strcat($<t.s>$,"[rp]"); } ;


listnn              :   listnn TCOMMA IDTI { strcpy($<t.v.sval>$,strcat($<t.v.sval>1, ",")); strcat($<t.v.sval>$,$<t.v.sval>3);
                       } 
                    |   IDTI
                    |   listnn TCOMMA IDTI TLB expression TRB  {strcpy($<t.v.sval>$,strcat($<t.v.sval>1, ",")); strcat($<t.v.sval>$,$<t.v.sval>3);
                        strcpy($<t.s>$,"[lnn[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[,]");strcat($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");strcat($<t.s>$,"[lb]");
                        strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>5);strcat($<t.s>$,"]]");strcat($<t.s>$,"[rb]");}
                    |   IDTI TLB expression TRB {strcpy($<t.v.sval>$,$<t.v.sval>1);strcpy($<t.s>$,"[id[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[lb]");
                        strcat($<t.s>$,"[ex[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");strcat($<t.s>$,"[rb]");};


args_list           :   args_list TCOMMA expression | expression ;
			              
			              
expression          :   expression TGE expr {strcpy($<t.type>$,"integer");
                        if($<t.v.ival>1>=$<t.v.ival>3)$<t.v.ival>$=1;else $<t.v.ival>$=0;}
                    |   expression TGT expr {strcpy($<t.type>$,"integer");
                        if($<t.v.ival>1>$<t.v.ival>3)$<t.v.ival>$=1;else $<t.v.ival>$=0;} 
                    |   expression TLE expr {strcpy($<t.type>$,"integer");
                        if($<t.v.ival>1<=$<t.v.ival>3)$<t.v.ival>$=1;else $<t.v.ival>$=0;}
                    |   expression TLT expr {strcpy($<t.type>$,"integer");
                        if($<t.v.ival>1<$<t.v.ival>3)$<t.v.ival>$=1;else $<t.v.ival>$=0;}
                    |   expression TEQUAL expr {strcpy($<t.type>$,"integer");
                        if($<t.v.ival>1==$<t.v.ival>3)$<t.v.ival>$=1;else $<t.v.ival>$=0;}
                    |   expression TNOTEQUAL expr {strcpy($<t.type>$,"integer");
                        if($<t.v.ival>1!=$<t.v.ival>3)$<t.v.ival>$=1;else $<t.v.ival>$=0;}
                    |   expr {};
	
	
			         
			    
expr                :   expr TPLUS term {
                        if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"integer");$<t.v.ival>$ = $<t.v.ival>1 + $<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real");
                        $<t.v.dval>$ = $<t.v.ival>1 + $<t.v.dval>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"real");
                        $<t.v.dval>$ = $<t.v.dval>1 + $<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real");
                        $<t.v.dval>$ = $<t.v.dval>1 + $<t.v.dval>3;}
                        else printf("type mismatch");
                        strcpy($<t.s>$,"[ep[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[+]");strcat($<t.s>$,"[tm[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");}
                    |   expr TMINUS term {
                        if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"integer"); $<t.v.ival>$ = $<t.v.ival>1 - $<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real");  $<t.v.dval>$ = $<t.v.ival>1 - $<t.v.dval>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"real");  $<t.v.dval>$ = $<t.v.dval>1 - $<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real"); $<t.v.dval>$ = $<t.v.dval>1 - $<t.v.dval>3;}
                        else printf("type mismatch");
                        }
                    |   expr TOR term  {
                        if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");
                        else printf("type mismatch");
                        $<t.v.ival>$ = $<t.v.ival>1 || $<t.v.ival>3;
                        }
                    |   term ;
                       
  
                       
term                :   term TMUL factor {
                        if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"integer"); $<t.v.ival>$ = $<t.v.ival>1 * $<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real");  $<t.v.dval>$ = $<t.v.ival>1 * $<t.v.dval>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"real");  $<t.v.dval>$ = $<t.v.dval>1 * $<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real"); $<t.v.dval>$ = $<t.v.dval>1 * $<t.v.dval>3;}
                        else printf("type mismatch");
                        }
                    |   term TDIV factor {
                        if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"real"); $<t.v.dval>$ = $<t.v.ival>1/$<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real");  $<t.v.dval>$ = $<t.v.ival>1/$<t.v.dval>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"integer")==0)) {strcpy($<t.type>$,"real");  $<t.v.dval>$ = $<t.v.dval>1/$<t.v.ival>3;}
                        else if((strcmp($<t.type>1,"real")==0) && (strcmp($<t.type>3,"real")==0)) {strcpy($<t.type>$,"real"); $<t.v.dval>$ = $<t.v.dval>1/$<t.v.dval>3;}
                        else printf("type mismatch");                       
                        }
                    |   term TMOD factor {
                        if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");
                        else printf("type mismatch");
                        $<t.v.ival>$ = $<t.v.ival>1 % $<t.v.ival>3;
                        strcpy($<t.s>$,"[tm[");strcat($<t.s>$,$<t.s>1);strcat($<t.s>$,"]]");strcat($<t.s>$,"[%]");strcat($<t.s>$,"[fr[");strcat($<t.s>$,$<t.s>3);strcat($<t.s>$,"]]");}
                    |   term TAND factor {
                        if((strcmp($<t.type>1,"integer")==0) && (strcmp($<t.type>3,"integer")==0)) strcpy($<t.type>$,"integer");
                        else printf("type mismatch");
                        $<t.v.ival>$ = $<t.v.ival>1 && $<t.v.ival>3;
                        }
                    |   factor;
		
	
		
			           
factor              :   IDT 
	            |   values 
		    |   TLP expression TRP {
                strcpy($<t.type>$,$<t.type>2);
                if((strcmp($<t.type>2,"integer") == 0))
                {
                    $<t.v.ival>$ = $<t.v.ival>2;
                }
                else if((strcmp($<t.type>2,"real") == 0))
                {
                    $<t.v.dval>$ = $<t.v.dval>2;
                }
                else if((strcmp($<t.type>2,"char") == 0))
                {
                    strcpy($<t.v.sval>$,$<t.v.sval>2);
                }

                }
		    |   TNOT factor {
                if(strcmp($<t.type>2,"integer")!=0) printf("not should be applied on integer");strcpy($<t.type>$,$<t.type>2);
                if($<t.v.ival>2 == 0)
                    $<t.v.ival>$ = 1;
                else
                    $<t.v.ival>$ = 0;
                }
		    |   TMINUS factor {
                if((strcmp($<t.type>2,"integer")!=0) && ((strcmp($<t.type>2,"real")!=0)))printf("minus can be only applied on integer or real");strcpy($<t.type>$,$<t.type>2);
		        
                if((strcmp($<t.type>2,"integer") == 0))
                    $<t.v.ival>$ = -$<t.v.ival>2;
                if((strcmp($<t.type>2,"real") == 0))
                    $<t.v.dval>$ = -$<t.v.dval>2;
                 }
		    |   IDT TLB expression TRB {if(strcmp($<t.type>3,"integer")!=0) printf("index should be an integer");strcpy($<t.type>$,$<t.type>1);
		        };
			
			
			
values              :   TINT {strcpy($<t.type>$,"integer");$<t.v.ival>$ = $<t.v.ival>1; } 
                    |   TREALV {strcpy($<t.type>$,"real");$<t.v.dval>$ = $<t.v.dval>1;} 
                    |   TCHARV {strcpy($<t.type>$,"char");strcpy($<t.v.sval>$,$<t.v.sval>1);} 
                    |   TSTRING {strcpy($<t.s>$,$<t.v.sval>1);};
                        
                        
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
     printf("Symbol Table Contents:\n");
printf("---------------------------------------------------\n");
printf("%-20s %-10s %-10s \n", "Variable", "Type", "Value");
printf("--------------------------------------------------\n");
for (int i = 0; i < symbolTableIndex; i++) {
    printf("%-20s %-10s %-10s\n", symbolTable[i].name, symbolTable[i].type, symbolTable[i].value);
    printf("------------------------------------------------------\n");
}

    // fclose(file);
    //if(ff==1) printf("%s\n",f);
    //FILE *fp=fopen("syntaxtree.txt","w");
    //fprintf(fp,"%s",f);
    //fclose(fp);
    return 0;
}


