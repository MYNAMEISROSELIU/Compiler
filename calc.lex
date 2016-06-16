%option	noinput
%option	nounput

%{
#include "heading.h"
#include "tok.h"
int yyerror(char *s);
int yyerror();
extern FILE *fout;
int while_count = 0;
int LCB_count = 0;
int RCB_count = 0;
int block_count = 0;
int if_count = 0;
int else_count = 0;
%}

int_const	[0-9]+

%%
"idMain"	{fprintf(fout,"main:\n");
	return MAIN;}
"int"	{return INT;}
"char"	{return CHAR;}
"print"	{return PRINT;}
"read"	{return READ;}
"while"	{while_count = while_count + 1;
	//fprintf(fout,"\tjal WHILE%dEnd\n",while_count);
	fprintf(fout,"WHILE%d:\n",while_count);
	yylval.int_val = while_count;
	return WHILE;}
"break"	{//fprintf(fout,"\tjal BLOCK_End%d\n",block_count);
	return BREAK;
	}

"if"	{if_count += 1;
	fprintf(fout,"IF%d:\n",if_count);
	yylval.int_val = if_count;
	return IF;
	}

"else"	{else_count += 1;
	fprintf(fout,"ELSE%d:\n",else_count);
	yylval.int_val = else_count;
	return ELSE;
	}

"return"	{return RETURN;}
id[A-Z][a-z]*	{yylval.str = new std::string(yytext);
		return ID;}
\"[A-Za-z0-9]\" {
		yylval.str = new std::string(yytext);
		return STRID;
		}

{int_const}	{ yylval.int_val = atoi(yytext); 
	return INTEGER_LITERAL; }
"=="	{return EQU_OP;}
"!="	{return NOT_EQU;}
">="	{return BIG_EQU;}
"<="	{return SMALL_EQU;}
">"	{return BIG;}
"<"	{return SMALL;}

"+"	{yylval.op_val = new std::string(yytext);
	return PLUS; }
"*"	{yylval.op_val = new std::string(yytext);
	return MULT; }
"-"	{yylval.op_val = new std::string(yytext);
	return SUB; }
"/"	{yylval.op_val = new std::string(yytext);
	return DIV; }
"="	{yylval.op_val = new std::string(yytext);
	return EQUAL;}
";"	{yylval.op_val = new std::string(yytext);
	return SEMICOLON;}
"{"	{LCB_count = LCB_count + 1;
	yylval.int_val = LCB_count;
	//fprintf(fout,"BLOCK%d:\n",LCB_count);
	block_count ++;
	return LCB;}
"}"	{RCB_count = RCB_count + 1;
	yylval.int_val = RCB_count;
	//fprintf(fout,"RCB%d:\n",RCB_count);
	block_count --;
	return RCB;}
"("	{return LP;}
")"	{return RP;}

\/\/[^\n]*	{}

[ \t]*		{}
[\n]		{ yylineno++; }

.		{ std::cerr << "SCANNER "; 
		yyerror(); 
		exit(1); }
