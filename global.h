// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
struct evTable {
   char var[128][100];
   char word[128][100];
};
struct aTable {
	char name[128][100];
	char word[128][100];
};
struct bcTable {
	char command[128][100];
	int argCount[128];
	char comArgs[128][100];
	char temp[128][100];
	char input[128][100];
	char output[128][100];
};

//char cwd[_MAX_PATH];


struct evTable varTable;
struct aTable aliasTable;
struct bcTable commandTable;

int aliasIndex, varIndex, bcIndex;

char* args(char* name);

char* subAliases(char* name);
