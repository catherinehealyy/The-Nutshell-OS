%{
	// Only "alias name word", "cd word", "bye" run, "printenv", "alias", "setenv variable word","unalias name", unsetenv variable", "ls"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

	int yylex();
	int yyerror(char* s);
	char* parsePath();
	int runLS();
	int runCD(char* arg);
	int runSetAlias(char* name, char* word);
	int runPrintEValues();
	int runPrintAlias();
	int runSetVariable(char* variable, char* word);
	int runRemoveVariable(char* variable);
	int runRemoveAlias(char* name);

	%}

%union { char* string; }

%start cmd_line
%token <string> BYE CD STRING ALIAS END PRINTENV SETENV UNSETENV UNALIAS LS

%%
cmd_line    :
BYE END{ exit(1); return 1; }
| LS END{ runLS(); return 1; }
| CD STRING END{ runCD($2); return 1; }
| ALIAS STRING STRING END{ runSetAlias($2, $3); return 1; }
| PRINTENV END{ runPrintEValues(); return 1; }
| ALIAS END{ runPrintAlias(); return 1; }
| SETENV STRING STRING END{ runSetVariable($2, $3); return 1; }
| UNSETENV STRING END{ runRemoveVariable($2); return 1; }
| UNALIAS STRING END{ runRemoveAlias($2); return 1; }

%%

int yyerror(char* s) {
	printf("there's an error ");
	printf("%s\n", s);
	return 0;
}

char* parsePath(char* exeName) {
	//https://www.tutorialspoint.com/c_standard_library/c_function_strtok.htm
	char* token = strtok(varTable.word[3], ":");
	while (token != NULL) {
		//try to access executable
		char* temp = strcat(token, "/");
		temp = strcat(temp, exeName);
		int fd = access(temp, F_OK);
		if (fd != -1) {
			fd = access(temp, X_OK);
			if (fd != -1) {
				return token;
			}
		}
		token = strtok(varTable.word[3], ":");
	}
	return NULL;
}

int runLS() {
	printf("in run LS");
	char* arr[2] = { parsePath("ls"), NULL };
	if (arr[0] != NULL) {
		execv(arr[0], arr);
		printf("Path found %s", arr[0]);
	}
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
		int e_var_size = sizeof(varTable.var[i]) / sizeof(varTable.var[i][0]);
		for (int j = 0; j < e_var_size; j++) {
			printf("%c", varTable.var[i][j]);
		}
		printf("=");
		int e_word_size = sizeof(varTable.word[i]) / sizeof(varTable.word[i][0]);
		for (int j = 0; j < e_word_size; j++) {
			printf("%c", varTable.word[i][j]);
		}
		printf("\n");
	}
	return 1;
}

int runPrintAlias() {
	for (int i = 0; i < aliasIndex; i++) {
		int Asize = sizeof(aliasTable.name[i]) / sizeof(aliasTable.name[i][0]);
		for (int j = 0; j < Asize; j++) {
			printf("%c", aliasTable.name[i][j]);
		}
		printf("=");
		int a_word_size = sizeof(aliasTable.word[i]) / sizeof(aliasTable.word[i][0]);
		for (int j = 0; j < a_word_size; j++) {
			printf("%c", aliasTable.word[i][j]);
		}
		printf("\n");
	}
	return 1;
}

int runSetVariable(char* variable, char* word) {
	for (int i = 0; i < varIndex; i++) {
		if (strcmp(variable, word) == 0) {
			printf("Error, expansion of \"%s\" would create a loop.\n", variable);
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

int runRemoveVariable(char* variable) {
	for (int i = 0; i < varIndex; i++) {
		if (strcmp(varTable.var[i], variable) == 0) {
			for (int k = i; k < varIndex - 1; k++) {
				int e_var_size = sizeof(varTable.var[i]) / sizeof(varTable.var[i][0]);
				for (int j = 0; j < e_var_size; j++) {
					varTable.var[k][j] = varTable.var[k+1][j];
				}
				int e_word_size = sizeof(varTable.word[i]) / sizeof(varTable.word[i][0]);
				for (int j = 0; j < e_word_size; j++) {
					varTable.word[k][j] = varTable.word[k+1][j];
				}
			}
			i--;
			varIndex--;
		}
	}
	return 1;
}

int runRemoveAlias(char* name) {
	for (int i = 0; i < aliasIndex; i++) {
		if (strcmp(aliasTable.word[i], name) == 0) {
			for (int k = i; k < aliasIndex - 1; k++) {
				int a_name_size = sizeof(aliasTable.name[i]) / sizeof(aliasTable.name[i][0]);
				for (int j = 0; j < a_name_size; j++) {
					aliasTable.name[k][j] = aliasTable.name[k + 1][j];
				}
				int a_word_size = sizeof(aliasTable.word[i]) / sizeof(aliasTable.word[i][0]);
				for (int j = 0; j < a_word_size; j++) {
					aliasTable.word[k][j] = aliasTable.word[k + 1][j];
				}
			}
			i--;
			aliasIndex--;
		}
	}
	return 1;

}
