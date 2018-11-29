#include <stdio.h>
#include <stdlib.h>

int a = 0x01020304;

int main(){
	char *p = &a;
	printf("ret = %d\n", *p);
	printf("&a = %p\n", &a);

	return 0;
}
