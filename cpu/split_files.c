#include <stdio.h>

int main(void)
{
	unsigned char c;
	int i;
	FILE *files[4];
	files[0] = fopen("mod0.bin", "wb");
	files[1] = fopen("mod1.bin", "wb");
	files[2] = fopen("mod2.bin", "wb");
	files[3] = fopen("mod3.bin", "wb");

	if (!(files[0] && files[1] && files[2] && files[3]))
		return 1;

	i = 0;
	c = getchar();
	while (!feof(stdin)) {
		fputc(c, files[i % 4]);
		i++;
		c = getchar();
	}

	fclose(files[0]);
	fclose(files[1]);
	fclose(files[2]);
	fclose(files[3]);

	return 0;
}
