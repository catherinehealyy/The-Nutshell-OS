%{ 
#include "parser.tab.h"
#include <string.h>
#include "global.h"
#include <stdbool.h>

//#define unput(c) {yytchar= (c); if(yytchar=='\n') {yylineno--; *yysptr++=yytchar;}
char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}
/*bool ifstrWildcard(char* charStr){
	for(int i = 0; i < strlen(charStr); i++){
		if(charStr[i] == '*'){
			return true;
		}
	}
	return false;
}
bool ifcharWildcard(char* charStr){
	for(int i = 0; i < strlen(charStr); i++){
		if(charStr[i] == '?'){
			return true;
		}
	}
	return false;
}
char** subcharWildcards(char* charStr){
	char** matches;
	pid_t pid;
	int fd[2];
	pipe(fd);
	pid = fork();
	if(pid == 0){
		//create process to run LS command and pipe stdout into fd
		dup2(fd[1], STDOUT_FILENO);
		close(fd[1]);
		runLS();
	}
	else{
	
	}
}
char** substrWildcards(char* stringy){
	char** matches;
}*/
%}
%array
%option noyywrap

CHAR            [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR            [)(*?&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*?&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*   //added ?

%x string_condition
%%

<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);}

[ ]		            { }
bye                 { return BYE; }
ls					{ return LS; }
cd		            { return CD; }
alias		        { return ALIAS; }
printenv            { return PRINTENV; }
setenv              { return SETENV; }
"\n"		        { return END; }
[\"]                 { BEGIN(string_condition); }
{CHAR}+              {
					if(ifAlias(yytext)) {
                        printf("yytext before sub: %s\n", yytext);
                        // source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                    }
					/*else if(ifstrWildcard(yytext)){
						printf("string wildcard detected");
						
					}
					}else if(ifcharWildcard(yytext)){
						printf("character wildcard detected");
						
					}*/
					else {
                        printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
                        return STRING;
                    };
                     }
%%
