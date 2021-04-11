#include "stdbool.h"
#include <limits.h>

struct evTable{
	char var[128][100];
	char word[128][100];
};
struct aTable {
	char name[128][100];
	char word[128][100];
};
struct comTable {
	char com[128][100];
	char input[128][100];
	char output[128][100];
};

char cwd[PATH_MAX];

struct evTable varTable;

struct aTable aliasTable;

int aliasIndex, varIndex;

char* subAliases(char* name);
