
#include <stdio.h>
#include <stdlib.h>

#define BYE 0
#define ERRORS 1
#define OK 2

unsigned char command_buf[500];

void shell_init(void){
	return;
}
void getCommand(char** input){
	/*init_scanner_and_parser();
	if(yyparse()){
		understand_errors();
	}
	else{
		return OK;
	}*/
}
void recover_from_errors(void){
	return;
}
void processCommand(void){
	return;
}
void do_it(){
	return;
}
void printPrompt(){
	printf("nutshell~cd$ ");
}
void execute_it(){/*
	if(! Executable()){
		//use access() system call
		nuterr("Command not Found");
		return;
	}
	//check io file existance in case of I/O redirection
	if(check_in_file() == SYSERR){
		nuterr("Can't read from : %s", srcf);
		return;
	}
	if(check_out_file() == SYSERR){
		nuterr("Can't write to : %s", distf);
		return;
	}
	//build up pipeline 
	//process background*/
}

int main(int ac __attribute__((unused)), char **av __attribute__((unused))){
	//shell_init();
	while(1){
		printPrompt();
		gets(command_buf);
		/*char** CMD = getCommand(stdin);
		if(CMD == BYE){
			exit();
		}
		else if(CMD == ERRORS){
			recover_from_errors();
		}
		else if(CMD == OK){
			processCommand();
		}*/
	}
}
