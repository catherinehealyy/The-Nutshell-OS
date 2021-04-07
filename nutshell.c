
#include <stdio.h>
#include <stdlib.h>
#include "global.h"
#include <string.h>
#include <unistd.h>


char *getcwd(char *buf, size_t size);
int yyparse();

void shell_init(void){
	aliasIndex = 0;
    varIndex = 0;

    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "HOME");
    strcpy(varTable.word[varIndex], ".:/bin");
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");
    strcpy(varTable.word[varIndex], "nutshell~dc$");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");
    strcpy(varTable.word[varIndex], ".:/bin:/usr/bin");
    varIndex++;
    system("clear");
}
void printPrompt(){
     printf("[%s]>> ", varTable.word[2]);
}
int main(){
	shell_init();	
	while(1){
		printPrompt();
		yyparse();
	}
}
