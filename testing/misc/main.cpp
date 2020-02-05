
#include <cstdio>

#include <proto/exec.h>
#include <utils/time/time.h>

#include "utils/utils_def.h"

#include "utils/string/numbers.h"

int main(int argc, char *argv[])
{
	char buffer[128];
	uint32_t value;
	uint32_t len = 0;

	memset(buffer, '0', sizeof(buffer));

	value = 3866565;
	len = ulongToString(value, buffer, 100u, 2u);
	buffer[len] = 0;
	printf("DUWORD - Base 2: %lu, Len: %u - %%%s\n", value, len, buffer);
	len = ulongToString(value, nullptr, 0);
	printf("DUWORD - Base 10: Len: %u\n", len);

	value = 65535;
	len = uwordToString(value, buffer, 100u, 2u);
	buffer[len] = 0;
	printf(" UWORD - Base 2: %lu, Len: %u - %%%s\n", value, len, buffer);
	len = uwordToString(value, nullptr, 0);
	printf(" UWORD - Base 10: Len: %u\n", len);

	// Performance test to see how long the full set of
	// of converstion takes.
	// 13:14.360 / 13:14.220 / 12:35.200
	// Comparing the gcc implementation of itoa (which is not as safe)
	// takes about 40 minutes.
/*	clock_t elapsed;
	printf("Testing AmigaLib uwordToString(0 - 65535)\n");
	elapsed = clock();
	for(value = 0; value <= 65535; value++)
	{
		for(uint16_t i = 2; i <= 62; i++)
		{
			len = uwordToString(value, i, buffer, sizeof(buffer)-1);
			buffer[len] = 0;
			//printf("%lu Base %u : Result: %s : length: %lu\n", value, i, buffer, len);
		}
	}

	elapsed = clock() - elapsed;
	printf("AmigaLib: %s\n", utils::clockToTimeString(elapsed, buffer, sizeof(buffer)));
*/

	return 0;
}
