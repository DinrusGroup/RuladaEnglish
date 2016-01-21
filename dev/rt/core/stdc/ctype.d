/**
 * D header file for C99.
 *
 * Copyright: Public Domain
 * License:   Public Domain
 * Authors:   Sean Kelly
 * Standards: ISO/IEC 9899:1999 (E)
 */
module rt.core.stdc.ctype;

alias tolower впроп;
alias toupper взаг;
alias isalnum числобукв_ли;
alias isalpha буква_ли;
alias iscntrl управ_ли;
alias isdigit цифра_ли;
alias islower пропись_ли;
alias ispunct пунктзнак_ли;
alias isspace межбукв_ли;
alias isupper заглавн_ли;
alias isxdigit цифраикс_ли;

extern  (C):

int isalnum(int c);
int isalpha(int c);
int isblank(int c);
int iscntrl(int c);
int isdigit(int c);
int isgraph(int c);
int islower(int c);
int isprint(int c);
int ispunct(int c);
int isspace(int c);
int isupper(int c);
int isxdigit(int c);
int tolower(int c);
int toupper(int c);
