#include <stdio.h>

#define FIZZ        "Fizz"
#define BUZZ        "Buzz"
#define FIZZBUZZ    "Fizz Buzz"
#define ISFIZZ(n)   (n % 3) ? 0 : 1
#define ISBUZZ(n)   (n % 5) ? 0 : 1
#define GETINDEX(n) ((ISFIZZ(n))|(ISBUZZ(n)<<1))

void main(void){
    char buf[8] = {'\0'};
    char* str[4] = {buf, FIZZ, BUZZ, FIZZBUZZ};
    for(int num=1; num<=100; num++){
        sprintf(buf, "%d", num);
        printf(str[GETINDEX(num)]);
        printf(", ");
    }
    return;
}
