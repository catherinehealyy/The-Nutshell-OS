%{
	// Only "alias name word", "cd word", "bye" run, "printenv", "alias", "setenv variable word"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

	int yylex();
	int yyerror(char* s);
	int runCD(char* arg);
	int runSetAlias(char* name, char* word);
	int runPrintEValues();
	int runPrintAlias();
	int runSetVariable(char* variable, char* word);
	%}

%union { char* string; }

%start cmd_line
%token <string> BYE CD STRING ALIAS END PRINTENV SETENV

%%
cmd_line    :
BYE END{ exit(1); return 1; }
| CD STRING END{ runCD($2); return 1; }
| ALIAS STRING STRING END{ runSetAlias($2, $3); return 1; }
| PRINTENV END{ runPrintEValues(); return 1; }
| ALIAS END{ runPrintAlias(); return 1; }
| SETENV STRING STRING END{ runSetVariable($2, $3); return 1; }

%%

int yyerror(char* s) {
	printf("%s\n", s);
	return 0;
}

int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if (chdir(varTable.word[0]) == 0) {
			strcpy(aliasTable.word[0], varTable.word[0]);
			strcpy(aliasTable.word[1], varTable.word[0]);
			char* pointer = strrchr(aliasTable.word[1], '/');
			while (*pointer != '\0') {
				*pointer = '\0';
				pointer++;
			}
		}
		else {
			//strcpy(varTable.word[0], varTable.word[0]); // fix
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if (chdir(arg) == 0) {
			strcpy(aliasTable.word[0], arg);
			strcpy(aliasTable.word[1], arg);
			strcpy(varTable.word[0], arg);
			char* pointer = strrchr(aliasTable.word[1], '/');
			while (*pointer != '\0') {
				*pointer = '\0';
				pointer++;
			}
		}
		else {
			printf("Directory not found\n");
			return 1;
		}
	}
	return 1;
}

int runSetAlias(char* name, char* word) {
	for (int i = 0; i < aliasIndex; i++) {
		if (strcmp(name, word) == 0) {
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if ((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)) {
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if (strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}

int runPrintEValues() {
	for (int i = 0; i < varIndex; i++) {
		printf(varTable.var[i], "=", varTable.word[i]);
	}	
	return 1;
}

int runPrintAlias() {
	for (int i = 0; i < aliasIndex; i++) {
		printf(aliasTable.name[i])
	}
	return 1;
}

int runSetVariable(char* variable, char* word) {
	for (int i = 0; i < varIndex; i++) {
		if (strcmp(name, word) == 0) {
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if ((strcmp(varTable.var[i], variable) == 0) && (strcmp(varTable.word[i], word) == 0)) {
			printf("Error, expansion of \"%s\" would create a loop.\n", variable);
			return 1;
		}
		else if (strcmp(varTable.var[i], variable) == 0) {
			strcpy(varTable.word[i], word);
			return 1;
		}
	}
	strcpy(varTable.var[varIndex], variable);
	strcpy(varTable.word[varIndex], word);
	varIndex++;

	return 1;
}


