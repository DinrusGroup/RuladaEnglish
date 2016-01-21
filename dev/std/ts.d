import os.windows, std.string, std.utf;

void main(){
char[] s = "jjjj";
wchar* soob = cast(wchar*)("Переполнение стека при преобразовании из типа ткст\n"~toUTF16(s));
ОкноСооб(null, cast(wchar*) soob, "D рантайм: ОшибкаПереполненияПриПреобразовании", СО_ОК|СО_ПИКТОШИБКА);
}