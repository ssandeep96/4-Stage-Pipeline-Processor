/*
*  Example program for CSE 141L
*  Prints "Hello World" using the lib141 SendByte function
*
*  Change Log:
* 	1/18/2012 - Adrian Caulfield - Initial Implementation
*
*/
#include "lib141.h"


void print(char* str) {
	while(*str != '\0') {
		SendByte(*str);
		str++;
	}
}


int main()
{
	print("Hello World\n");
	return 0;
}


