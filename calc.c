#include <stdio.h>
#include <stdlib.h>
#define MAX_LEN 100
long long calc_rec(char * str, int len, long long (*string_convert)(char*));


void calc_expr(long long (*string_convert)(char*), int (*result_as_string)(long long)){
    char * in_str;
    long long res;
    scanf("%s", in_str);
    res = calc_rec(in_str, len(in_str), string_convert);
    result_as_string(res);
}

long long calc_rec(char * str, int len, long long (*string_convert)(char*)){
    int diff = 0, left, right;
    for(int i = 0; i < len; i++){
        char curr = str[i];
        if(curr == "(") diff++;
        else if(curr == ")") diff--;   
        if(diff == 1){
            if(curr == "-"){
                if(str[i-1] == "(") continue;
                left = calc_rec(str[1, i-1], i - 2);
                right = calc_rec(str[i+1, len-2], len - i + 2);
                return left - right;
            }
            if(curr == "+"){
                left = calc_rec(str[1, i-1], i - 2);
                right = calc_rec(str[i+1, len-2], len - i + 2);
                return left + right;
            }
            if(curr == "/"){ 
                left = calc_rec(str[1, i-1], i - 2);
                right = calc_rec(str[i+1, len-2], len - i + 2);
                return left / right;
            }
            if(curr == "*"){
                left = calc_rec(str[1, i-1], i - 2);
                right = calc_rec(str[i+1, len-2], len - i + 2);
                return left * right;
            }
        }        
    }
    if(str[0] == "(") return string_convert(str[1,len-1]);
    else return string_convert(str);
}

/*
 * This variable will not change.
 */
char what_to_print[MAX_LEN];

/*
 * This is an example for an implementation of string_convert(char* num).
 * BE CAREFUL - this implementation can be different in other tests.
 * The function declaration will (of course) always be the same and the return value will always be the conversion of
 * the string num into a 10 base representation long long variable.
 */
long long string_convert(char* num) {
    return strtol(num, NULL, 10);
}

/*
 * This is an example for an implementation of result_as_string(long long num).
 * BE CAREFUL - this implementation can be different in other tests.
 * The function declaration will (of course) always be the same and the return value will always be the length
 * of the string that was copied into 'what_to_print'
 */
int result_as_string(long long num) {
    return snprintf(what_to_print, MAX_LEN, "Result is: %lld\n", num);
}

int main() {
    calc_expr(&string_convert, &result_as_string);
    return 0;
}