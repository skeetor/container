#include <stdio.h>
#include <unistd.h>

#include <exec/exec>
#include <hardware/custom.h>
#include <hardware/custom_registers.h>
#include <string/numbers.h>

#include "utilslib/time/timeutils.h"

ExecLibrary ExecLibrary;

int main(int argc, char **argv)
{
	printf("Hello ... \n");

	Custom *custom = (Custom *)HWREGBASE;

	char buffer[20];
	
	for(uint16_t i = 0; i < 50; i++)
	{		
		uint16_t val = custom->joy1dat;
		printf("Port: 0x%04X - %s\n", val, utils::toBinary(val, buffer, sizeof(buffer)));
	}

	return 0;
}
