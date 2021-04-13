%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run. 
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
	int mCount = 0;
	char** allFiles;
	char* arr[3] = {parsePath("ls"), "-A1", NULL};
	pid_t pid;
	int fd[2];
	pipe(fd);
	pid = fork();
	if(pid == 0){
		//create process to run LS command and pipe stdout into fd
		dup2(fd[1], STDOUT_FILENO);
		close(fd[1]);
		execv(arr[0], arr);	
	}
	else{
		int aCount = 0;
		char lsOut[100];
		char temp [100];
		int tempCount = 0;
		read(fd[0], lsOut, 100);
		for(int i = 0; i < strlen(lsOut); i++){
			if(lsOut[i] == "\n"){
				allFiles[aCount] = temp;
				aCount++;
				tempCount = 0;
				temp = {};
			}
			else{
				temp[tempCount] = lsOut[i];
				tempCount++;
			}
		}
	}
	for(int i = 0; i < strlen(allFiles); i++){
		if(fnmatch("*", allFiles[i]) == 0){
			matches[mCount] = allFiles[i];
			mCount++;
		}
	}
}
char** substrWildcards(char* stringy){
	char** matches;
}*/
%}
%array
%option noyywrap

CHAR            [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR            [)(*?&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*?&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*

%x string_condition
%%

<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);}

[ ]		            { }
bye                 { return BYE; }
cd		            { return CD;}
alias		        { return ALIAS; }
printenv            { return PRINTENV; }
setenv              { return SETENV; }
unsetenv            { return UNSETENV; }
unalias             { return UNALIAS; }
ls                  { yylval.string = strdup(yytext); return BASIC; }
"\n"		        { return END; }
[\"]                 { BEGIN(string_condition); }
{CHAR}+              {if(ifAlias(yytext)) {
                        printf("yytext before sub: %s\n", yytext);
                        // source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                    } /*else if(ifstrWildcard(yytext)){
						printf("string wildcard detected");
						char** wc = substrWildcards(yytext);
					}
					}else if(ifcharWildcard(yytext)){
						printf("character wildcard detected");
						char** wc = subcharWildcards(yytext);						
					}*/else {
                        printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
                        return STRING;
                    };
                     }
%%
