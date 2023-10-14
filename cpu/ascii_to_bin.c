#include <stdio.h>

#define BYTE 8

int getbyte(char *buf)
{
	char c;
	int i;
	for (i = 0; i < BYTE; i++) {
		if ((c = getchar()) == EOF)
			return 1;
		buf[i] = c;
	}
	getchar();

	return 0;
}

unsigned char ascii_to_bin(char *buf)
{
	int i;
	unsigned char b = 0;
	for (i = 0; i < BYTE; i++)
		b = b * 2 + (buf[i] - 0x30);
	return b;
}

int main(void)
{
	char byte[BYTE];
	while (!getbyte(byte))
		putchar(ascii_to_bin(byte));

	return 0;
}
