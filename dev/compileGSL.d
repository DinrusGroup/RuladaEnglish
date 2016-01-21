import std.file;
import std.process;
import std.io, std.string;


цел компилируйПакет(ткст путь, ткст англИмяСтатБиб)
{

sys("del *.obj");	
scope files = std.file.listdir(путь, "*.d"); 
     foreach (d; files)
	 {
		sys("..\\..\\bin\\dmd -c "~d);	
		say("Попытка компилировать модуль:"); writefln(d);
	 }
	 sys("..\\..\\bin\\ls2 -d *.obj>>objs.rsp");	
	 sys(format("..\\..\\bin\\lib -p128 -c "~англИмяСтатБиб~".lib @objs.rsp"));	
	 sys("del *.obj");
	 return 0;
}

 цел удалиФайлы(ткст флрасш)
 { 
 цел удалено = 0;

скажи("Подождите пока строится список файлов => "~флрасш).нс;
нс;
	auto файлы = списпап(".", флрасш);
	foreach (d; файлы)
	{	try
		{
		удали(d);
		удалено++;
		}
		catch(ВВИскл искл){throw искл;}
		скажи("Удалён : "~d).нс;		
	}
	нс;
	скажи("Файлов удалено: "); пишифнс("%d", удалено);
	нс;
	return 0;
}

void main()
{
	компилируйПакет("..\\..\\imp\\rulada\\auxc\\gsl", "gsl");
}