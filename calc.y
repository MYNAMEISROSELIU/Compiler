%{
#include "heading.h"
int yyerror(char *s);
int yylex(void);
FILE *fout = fopen("output.s","w");
int FindS_Register(string s);	//find where the ID save
int FreeS_Register(string s);	//find and use the register which is free
int FreeT_Register();
void setT_RegisterFree(int d);

string s0 = "";
string s1 = "";
string s2 = "";
string s3 = "";
string s4 = "";
string s5 = "";
string s6 = "";
string s7 = "";

//use for calc tmp save, lock its competence 
int t[10] = {1,1,0,0,0,0,0,0,0,0};

int tmp;

int block = 0;
%}

%union{
	int	int_val;
	string*	op_val;
	string*	str;
}

%start input

%token	MAIN
%token	RETURN
%token	INT
%token	CHAR
%token	PRINT
%token	READ
%token	BREAK
%token	<int_val>	IF
%token	<int_val>	ELSE
%token	<int_val>	WHILE
%token	<str>		ID
%token	<str>		STRID
%token	<int_val>	INTEGER_LITERAL
%token	SEMICOLON
%token	<int_val>	LCB
%token	<int_val>	RCB
%token	LP
%token	RP
%token	EQU_OP
%token	NOT_EQU
%token	BIG_EQU
%token	SMALL_EQU
%token	BIG_EQU
%token	BIG
%token	SMALL


%type	<int_val>		def
%type	<int_val>		output
%type	<int_val>		read
%type	<int_val>		exp
%type	<str>		content
%type	<int_val>		BLOCK
%type	<int_val>		condition
%type	<int_val>		compare
%type	<int_val>		if_condition
%type	<int_val>		if_content
%type	<str>			statement



%left	EQUAL EQU_OP NOT_EQU BIG_EQU SMALL_EQU BIG SMALL
%left	PLUS SUB
%left	MULT DIV
%left	LP RP

%%

input:	/* empty */{
		cout<< "ERROR: cannot find main!!!\n";
		exit(1);
	}
		| main {fclose(fout);}
		;

main:	INT MAIN LP RP BLOCK{
	}

RE:	RETURN INTEGER_LITERAL{
	}

content: /* empty*/
		| statement content
		;

BLOCK:	LCB content RCB {
			fprintf(fout,"BLOCK_End%d:\n",block);
			block ++;
			$$ = block;
		}
		| condition LCB content RCB{
		fprintf(fout,"\tjal WHILE%d\n",$1);
		fprintf(fout,"WHILE%dEnd:\n",$1);
		fprintf(fout,"BLOCK_End%d:\n",block);
		block ++;
		}
		| if_content ELSE LCB content RCB{
		fprintf(fout,"ELSE_End%d:\n",$2);
		fprintf(fout,"BLOCK_End%d:\n",block);
		block ++;
		}

condition:	WHILE  compare{

			fprintf(fout,"\tbeq $t%d,0,WHILE%dEnd\n",$2 - 10,$1);
			$$ = $1;
		}

if_condition:	IF compare {
			fprintf(fout,"\tbeq $t%d,0,ELSE%d\n",$2 - 10,$1);
			$$ = $1;
		}
if_content:	if_condition LCB content RCB{
			fprintf(fout,"\tjal ELSE_End%d\n",$1 );
		}

/*
ALL:	condition BLOCK {
		fprintf(fout,"\tjal WHILE%d\n",$1);
		fprintf(fout,"WHILE%dEnd:\n",$1);}
*/

compare:	LP exp EQU_OP exp RP{
			$$ = FreeT_Register();
			fprintf(fout,"\tseq $t%d,$t%d,$t%d\n",$$-10,$2-10,$4-10);
			setT_RegisterFree($2);
			setT_RegisterFree($4);
		}
		|LP exp NOT_EQU exp RP{
			$$ = FreeT_Register();
			fprintf(fout,"\tsne $t%d,$t%d,$t%d\n",$$-10,$2-10,$4-10);
			setT_RegisterFree($2);
			setT_RegisterFree($4);
		}
		|LP exp SMALL_EQU exp RP{
			$$ = FreeT_Register();
			fprintf(fout,"\tsle $t%d,$t%d,$t%d\n",$$-10,$2-10,$4-10);
			setT_RegisterFree($2);
			setT_RegisterFree($4);
		}
		|LP exp BIG_EQU exp RP{
			$$ = FreeT_Register();
			fprintf(fout,"\tsge $t%d,$t%d,$t%d\n",$$-10,$2-10,$4-10);
			setT_RegisterFree($2);
			setT_RegisterFree($4);
		}
		|LP exp SMALL exp RP{
			$$ = FreeT_Register();
			fprintf(fout,"\tslt $t%d,$t%d,$t%d\n",$$-10,$2-10,$4-10);
			setT_RegisterFree($2);
			setT_RegisterFree($4);
		}
		|LP exp BIG exp RP{
			$$ = FreeT_Register();
			fprintf(fout,"\tsgt $t%d,$t%d,$t%d\n",$$-10,$2-10,$4-10);
			setT_RegisterFree($2);
			setT_RegisterFree($4);
		}
		|exp{

		}


statement:	def SEMICOLON
		| exp SEMICOLON
		| output SEMICOLON
		| read SEMICOLON
		| RE SEMICOLON
		| BLOCK
		| BREAK SEMICOLON{
			fprintf(fout,"\tjal BLOCK_End%d\n",block);
		}
		;

def:	INT ID  {
		$$ = FreeS_Register(*$2);
		fprintf(fout,"\tmove $s%d ,$zero\n",$$);

	}
		| INT ID EQUAL exp{
		fprintf(fout,"\tmove $t0 , $t%d\n",$4 - 10);
		setT_RegisterFree($4);
		$$ = FreeS_Register(*$2);
		fprintf(fout,"\tmove $s%d , $t0\n",$$);
		}
		| CHAR STRID 
		;

output:	PRINT exp {
		fprintf(fout,"\tmove $t0, $t%d\n",$2 - 10);
		setT_RegisterFree($2);
		fprintf(fout,"\tli $v0,1\n");
		fprintf(fout,"\tmove $a0,$t0\n\tsyscall\n");
	}

read:	READ ID {
		$$ = FindS_Register(*$2);
		fprintf(fout,"\tli $v0, 5\n");
		fprintf(fout,"\tsyscall\n");
		fprintf(fout,"\tmove $s%d,$v0\n",$$);
		
	}

exp: INTEGER_LITERAL {
		$$ = FreeT_Register();
		fprintf(fout,"\tli $t%d, %d\n",$$ - 10,$1);
	} 
		|ID {
		$$ = FindS_Register(*$1);
		tmp = $$;
		$$ = FreeT_Register();
		fprintf(fout,"\tmove $t%d , $s%d\n",$$-10,tmp);
	}
		| SUB exp {
			fprintf(fout,"\tli $t0,0\n");
			fprintf(fout,"\tmove $t1,$t%d\n",$2-10);
			setT_RegisterFree($2);
			$$ = FreeT_Register();
			fprintf(fout,"\tsub $t%d,$t0,$t1\n",$$ - 10);
		}
		| LP exp RP {
			$$ = $2;
	}
		|ID EQUAL exp {

			fprintf(fout,"\tmove $t0 ,$t%d\n",$3-10);
			setT_RegisterFree($3);
			$$ = FindS_Register(*$1);
			fprintf(fout,"\tmove $s%d ,$t0\n",$$);
			
	}	|exp PLUS exp {
			fprintf(fout,"\tmove $t0,$t%d\n",$1-10);
			fprintf(fout,"\tmove $t1,$t%d\n",$3-10);
			setT_RegisterFree($1);
			setT_RegisterFree($3);
			$$ = FreeT_Register();
			fprintf(fout,"\tadd $t%d,$t0,$t1\n",$$ - 10);

	}	|exp SUB exp {
			fprintf(fout,"\tmove $t0,$t%d\n",$1-10);
			fprintf(fout,"\tmove $t1,$t%d\n",$3-10);
			setT_RegisterFree($1);
			setT_RegisterFree($3);
			$$ = FreeT_Register();
			fprintf(fout,"\tsub $t%d,$t0,$t1\n",$$ - 10);
	}
		|exp MULT exp {
			fprintf(fout,"\tmove $t0,$t%d\n",$1-10);
			fprintf(fout,"\tmove $t1,$t%d\n",$3-10);
			setT_RegisterFree($1);
			setT_RegisterFree($3);
			$$ = FreeT_Register();
			fprintf(fout,"\tmul $t%d,$t0,$t1\n",$$ - 10);
	}
		|exp DIV exp {
			fprintf(fout,"\tmove $t0,$t%d\n",$1-10);
			fprintf(fout,"\tmove $t1,$t%d\n",$3-10);
			setT_RegisterFree($1);
			setT_RegisterFree($3);
			$$ = FreeT_Register();
			fprintf(fout,"\tdiv $t%d,$t0,$t1\n",$$ - 10);
	}

%%

int yyerror(string s) {
	extern int yylineno;
	extern char **yytext;

	cerr << "ERROR: " << s << " at symbol \"" << yytext;
	cerr << "\" on line " << yylineno << endl;
}

int yyerror(char *s) {
	return yyerror(string(s));
}

int yyerror() {
	return yyerror(string(""));
}

int FreeS_Register(string s){
	if(s0 == ""){
		s0 = s;
		return 0;
	}else if(s1 == ""){
		s1 = s;
		return 1;
	}else if(s2 == ""){
		s2 = s;
		return 2;
	}else if(s3 == ""){
		s3 = s;
		return 3;
	}else if(s4 == ""){
		s4 = s;
		return 4;
	}else if(s5 == ""){
		s5 = s;
		return 5;
	}else if(s6 == ""){
		s6 = s;
		return 6;
	}else{
		s7 = s;
		return 7;
	}
}

int FindS_Register(string s){
	if(s0 == s){
		return 0;
	}else if(s1 == s){
		return 1;
	}else if(s2 == s){
		return 2;
	}else if(s3 == s){
		return 3;
	}else if(s4 == s){
		return 4;
	}else if(s5 == s){
		return 5;
	}else if(s6 == s){
		return 6;
	}else if(s7 == s){
		return 7;
	}else{
		cout<< "ERROR: "<< s <<"is not defined.\n";
		exit(1);
	}
}

int FreeT_Register(){
	int free = 0;
	int i;
	for(i = 3;i < 10;i++){
		if(t[i] == 0){
			free = 1;
			break;
		}
	}

	if(free == 1){
		t[i] = 1;
		//fprintf(fout,"\tli $t%d,%d\n",i,d);
		return (i + 10);
	}else{
	cout<< "Error: the T_Register is not enough...\n";
	exit(1);
	}
}

void setT_RegisterFree(int d){
	d = d - 10;
	t[d] = 0;
}

