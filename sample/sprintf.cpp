// sprintf.cpp : This file contains the 'main' function. Program execution begins and ends there.
//
#include "pch.h"
#define _CRT_SECURE_NO_WARNINGS

#include <cstdio>
#include <iostream>
#include <cstdint>
#include <cstdarg>
#include <string>
#include <stdlib.h>

using namespace std;

#define C_FUNCTION	extern "C"

typedef enum
{
	RESULT_OK,
	RESULT_OVERFLOW,
	RESULT_INVALID_CHAR,
	RESULT_ERROR
} RESULT_STATE;

C_FUNCTION uint32_t uLongToString(uint32_t value, char *buffer, const uint32_t BufferLen, const uint32_t base = 10u)
{
	char s[40] = { 0 };

	char *p = _itoa(value, s, base);
	uint32_t strLen = strlen(p);
	memcpy(buffer, s, strLen);
	return strLen;
}

C_FUNCTION uint32_t uWordToString(uint16_t value, char *buffer, const uint32_t BufferLen, const uint32_t base = 10u)
{
	return uLongToString(value, buffer, BufferLen, base);
}

C_FUNCTION uint32_t sLongToString(int32_t value, char *buffer, const uint32_t BufferLen, const uint32_t base = 10u)
{
	char s[40] = { 0 };

	char *p = _itoa(value, s, base);
	uint32_t strLen = strlen(p);
	memcpy(buffer, s, strLen);
	return strLen;
}

C_FUNCTION uint32_t sWordToString(int16_t value, char *buffer, const uint32_t BufferLen, const uint32_t base = 10u)
{
	return sLongToString(value, buffer, BufferLen, base);
}

C_FUNCTION uint16_t stringToUWord(const char *buffer, const uint32_t BufferLen, uint32_t base = 10u, RESULT_STATE *state = nullptr, char **endPointer = nullptr)
{
	size_t strLen = 0;
	uint16_t val = stoi(buffer, &strLen, base);
	if (endPointer)
	{
		char *p = (char *)&buffer[strLen];
		*endPointer = p;
	}

	return val;
}

C_FUNCTION uint32_t vsPrintString(char *buffer, uint32_t bufferLen, const char *format, va_list args);

C_FUNCTION uint32_t sPrintString(char *buffer, uint32_t bufferLen, const char *format, ...)
{
	va_list args;
	va_start(args, format);

	uint32_t count = vsPrintString(buffer, bufferLen, format, args);

	va_end(args);

	return count;
}

// **************************************************************************
// **************************************************************************
// **************************************************************************
// **************************************************************************
// **************************************************************************

#define CONTROL_MODE	(1 << 0)
#define FORMAT_MODE		(1 << 1)
#define ZERO_FILL		(1 << 2)
#define ALIGN_RIGHT		(1 << 3)
#define PARAM_32		(1 << 4)
#define SIGNED			(1 << 5)

#define SAVE_CHAR(ch) \
if(p < e)\
{\
	*p++ = ch;\
}\
count++;

static uint32_t insertString(char mode, uint32_t strLen, uint32_t fieldWidth, const char *source, char *&p, char *e)
{
	uint32_t count = 0;
	char c;
	char fillChar;
	uint32_t fillLen = 0;

	if (!(mode & ALIGN_RIGHT))
	{
		if (strLen == (uint32_t)-1)
		{
			// If we have to align right, we need to know the length
			strLen = strlen(source);
		}

		if (fieldWidth > strLen)
		{
			fillLen = fieldWidth - strLen;

			if (mode & ZERO_FILL)
				fillChar = '0';
			else
				fillChar = ' ';

			while (fillLen > 0)
			{
				SAVE_CHAR(fillChar);
				fillLen--;
			}
		}
	}

	const char *src = source;
	while ((c = *src++) != 0)
	{
		SAVE_CHAR(c);
	}

	strLen = src - source - 1;

	if (mode & ALIGN_RIGHT)
	{
		while (strLen < fieldWidth)
		{
			SAVE_CHAR(' ');
			strLen++;
		}
	}

	return count;
}

static uint32_t insertUnsignedNumber(uint32_t value, char mode, uint32_t base, uint32_t fieldWidth, char *&p, char *e)
{
	uint32_t count = 0;
	char valueStr[34];		// maximum numeric value can be a 32 bit binary string with +/
	uint32_t strLen;

	if (mode & PARAM_32)
		strLen = uLongToString(value, valueStr, sizeof(valueStr), base);
	else
		strLen = uWordToString(value, valueStr, sizeof(valueStr), base);

	valueStr[strLen] = 0;

	count += insertString(mode, strLen, fieldWidth, valueStr, p, e);

	return count;
}

static uint32_t insertSignedNumber(int32_t value, char mode, uint32_t base, uint32_t fieldWidth, char *&p, char *e)
{
	uint32_t count = 0;
	char valueStr[34];		// maximum numeric value can be a 32 bit binary string with +/
	uint32_t strLen;

	if (mode & PARAM_32)
		strLen = sLongToString(value, valueStr, sizeof(valueStr), base);
	else
		strLen = sWordToString(value, valueStr, sizeof(valueStr), base);

	valueStr[strLen] = 0;

	count += insertString(mode, strLen, fieldWidth, valueStr, p, e);

	return count;
}

C_FUNCTION uint32_t vsPrintString(char *buffer, uint32_t bufferLen, const char *format, va_list args)
{
	if (!buffer)
		bufferLen = 0;

	uint32_t count = 0;
	uint32_t fieldWidth = 0;
	char *p = buffer;
	char *e = &buffer[bufferLen];

	char c;
	char mode = 0;

	while ((c = *format++) != 0)
	{
		if (mode & CONTROL_MODE)
		{
			switch (c)
			{
			case 'n':
				SAVE_CHAR(0x0d);
				break;

			case 'r':
				SAVE_CHAR(0x0a);
				break;

			case 't':
				SAVE_CHAR(0x09);
				break;

			default:
				SAVE_CHAR(c);
				break;
			}

			mode = 0;
		}
		else if (mode & FORMAT_MODE)
		{
			switch (c)
			{
				case 'c':
				{
					uint32_t ch = va_arg(args, uint32_t);

					SAVE_CHAR(ch & 0xff);
					mode = 0;
				}
				continue;

				case 'l':
					mode |= PARAM_32;
				continue;

				case '-':
					mode |= ALIGN_RIGHT;
				continue;

				case '0':
					mode |= ZERO_FILL;

				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					format--;
					fieldWidth = stringToUWord(format, 10000u, 10u, nullptr, (char **)&format);
				continue;

				case 's':
				{
					const char *src = va_arg(args, const char *);
					if (!src)
						src = "[null]";

					count += insertString(mode, -1, fieldWidth, src, p, e);

					mode = 0;
				}
				continue;

				case 'p':
				{
					SAVE_CHAR('0');
					SAVE_CHAR('x');

					mode |= ZERO_FILL | PARAM_32;
					fieldWidth = 16;
				}

				case 'x':
				case 'X':
				{
					uint32_t val = va_arg(args, uint32_t);

					count += insertUnsignedNumber(val, mode, 16u, fieldWidth, p, e);

					mode = 0;
				}
				continue;

				case 'b':
				{
					uint32_t val = va_arg(args, uint32_t);

					count += insertUnsignedNumber(val, mode, 2u, fieldWidth, p, e);

					mode = 0;
				}
				continue;

				case 'u':
				{
					uint32_t val = va_arg(args, uint32_t);

					count += insertUnsignedNumber(val, mode, 10u, fieldWidth, p, e);

					mode = 0;
				}
				continue;

				case 'd':
				{
					int32_t val = va_arg(args, int32_t);

					mode |= SIGNED;
					count += insertSignedNumber(val, mode, 10u, fieldWidth, p, e);

					mode = 0;
				}
				continue;

				case 'n':
				{
					uint32_t *p = va_arg(args, uint32_t *);
					if (p)
						*p = count;

					mode = 0;
				}
				continue;

				// floating point not supported yet.
				case 'e':
				case 'f':
				{
					SAVE_CHAR('I');
					SAVE_CHAR('N');
					SAVE_CHAR('F');
					mode = 0;
				}
				continue;

				case '%':
				default:
				{
					SAVE_CHAR(c);
					mode = 0;
				}
				continue;
			}
		}
		else
		{
			if (c == '%')
			{
				mode |= FORMAT_MODE;
				fieldWidth = 0;

				continue;
			}

			if (c == '\\')
			{
				mode |= CONTROL_MODE;
				continue;
			}

			SAVE_CHAR(c);
		}

	}

	SAVE_CHAR(0);
	count--;

	return count;
}

int main(int argc, char *argv[])
{
	char buffer[4096];
	const char *format;
	uint32_t len;

	snprintf(buffer, sizeof(buffer), "%-s", "test");

	format = "Text\n\r";
	len = sPrintString(buffer, sizeof(buffer), format);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "Text: %s";
	len = sPrintString(buffer, sizeof(buffer), format, "TestString");
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "Binary: %b";
	len = sPrintString(buffer, sizeof(buffer), format, 0xabab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "0x%8X";
	len = sPrintString(buffer, sizeof(buffer), format, 0xabab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "0x%16x";
	len = sPrintString(buffer, sizeof(buffer), format, 0xabab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "Unsigned: %u";
	len = sPrintString(buffer, sizeof(buffer), format, 23567);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "Signed: %d";
	len = sPrintString(buffer, sizeof(buffer), format, -23567);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "%02X";
	len = sPrintString(buffer, sizeof(buffer), format, 0xabab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "%016lX";
	len = sPrintString(buffer, sizeof(buffer), format, 0x123abab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "%032lX";
	len = sPrintString(buffer, sizeof(buffer), format, 0x123abab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "%032lX";
	len = sPrintString(buffer, 0, format, 0x123abab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "%032lX";
	len = sPrintString(nullptr, sizeof(buffer), format, 0x123abab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "%032lX";
	len = sPrintString(nullptr, 0, format, 0x123abab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	format = "%032lX";
	len = sPrintString(buffer, 10, format, 0x123abab);
	cout << "Len :" << to_string(len) << ":" << format << ": [" << buffer << "]" << endl;
	memset(buffer, 0, sizeof(buffer));

	return 0;
}
