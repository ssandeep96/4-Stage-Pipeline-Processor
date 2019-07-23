/*
*  Example program for CSE 141L
*  Iterative Fibonacci using the lib141 SendByte, and itoa functions
*
*  Change Log:
* 	1/20/2012 - Trevor Bunker - Initial Implementation
*
*/
#include "lib141.h"


void print(char* str) {
	while(*str != '\0') {
		SendByte(*str);
		str++;
	}
}

int fib(int n)
{
	int a = 0;
	int b = 1;
	int sum;
	int i, j;
	char str[32];

	for (i = n; i > 0; i--) {
		print(int_to_string(a,str,10));
		sum = a + b;
		a = b;
		b = sum;
	}

	return 0;
}

int main()
{
	print("S\n");
	fib(10);
	print("E\n");	
	return 0;
}

