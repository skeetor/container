#include <stdio.h>

#include <exec/exec>

#include "utilslib/time/timeutils.h"

//struct Library *SysBase = *((struct Library **)0x04);

uint32_t testLibrary(void);
uint32_t testVector(void);

int main(int argc, char **argv)
{
	uint32_t success = 0;
	const char *test;

	test = "testLibrary";
	printf("%s ... \n", test);
//	printf("%s - %u\n", (success == 0) ? "OK" : "FAILED", success);
/*	try
	{
		test = "testLibrary";
		printf("%s ... ", test);
		success = testLibrary();
		printf("%s - %u\n", (success == 0) ? "OK" : "FAILED", success);
			
		test = "testVector";
		printf("%s ... ", test);
		testVector();
		printf("%s - %u\n", (success == 0) ? "OK" : "FAILED", success);
	}
	catch(...)
	{
		printf("%s throws an exception\n", test);
	}
*/
	return 0;
}
