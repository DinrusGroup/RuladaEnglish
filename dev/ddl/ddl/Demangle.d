/+
	Copyright (c) 2005-2006 Eric Anderton
	        
	Permission is hereby granted, free of charge, to any person
	obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following
	conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
+/
/**
	Provides support for parsing and decoding D's name mangling syntax. 
	Wraps std.demangle from phobos.
	
	Authors: Eric Anderton
	License: BSD Derivative (see source for details)
	Copyright: 2005-2006 Eric Anderton
*/
module ddl.Demangle;

private import std.demangle;

debug private import ddl.Utils;

/**
	The type of symbol that is represented by a given mangled name.
	
	Any ordinary type of symbol that doesn't match a D symbol, or a D special symbol
	is merely of type 'PublicSymbol'.
*/
enum DemangleType{
	PublicSymbol,
	ClassDefinition,
	Initalizer,
	Vtable,
	VarArguments,
	PlatformHook,
	DAssert,
	DArray,
	ModuleCtor,
	ModuleDtor,
	ModuleInfo,
	Main,
	WinMain,
	Nullext
}


/**
	Parses a mangled D symbol and returns the equivalent D code to match the symbol.
	
	Params:
		symbol = The mangled D symbol.
		
	Returns:
		A D code representation of the symbol.
*/
public char[] demangleSymbol(char[] symbol){
	return std.demangle.demangle(symbol);
}

bool startsWith(char[] value,char[] test){
	return value.length >= test.length && value[0..test.length] == test;
}

/**
	Parses a mangled D symbol and returns its DemangleType.
	
	Params:
		symbol = The mangled D symbol.
		
	Returns:
		The DemangleType for the symbol.
*/
public DemangleType getDemangleType(char[] symbol){
	if(symbol.startsWith("_Class")){
		return DemangleType.ClassDefinition;
	}
	else if(symbol.startsWith("__init_")){
		return DemangleType.Initalizer;
	}
	else if(symbol.startsWith("__vtbl_")){
		return DemangleType.Vtable;
	}
	else if(symbol.startsWith("__arguments_")){
		return DemangleType.VarArguments;
	}
	else if(symbol.startsWith("__d")){
		return DemangleType.PlatformHook;
	}
	else if(symbol.startsWith("_assert_")){
		return DemangleType.DAssert;
	}
	else if(symbol.startsWith("_array_")){
		return DemangleType.DArray;
	}	
	else if(symbol.startsWith("__modctor_")){
		return DemangleType.ModuleCtor;
	}
	else if(symbol.startsWith("__moddtor_")){
		return DemangleType.ModuleDtor;
	}
	else if(symbol.startsWith("__ModuleInfo_")){
		return DemangleType.ModuleInfo;
	}
	else if(symbol.startsWith("__nullext")){
		return DemangleType.Nullext;
	}
	else if(symbol.startsWith("_Dmain")){
		return DemangleType.Main;
	}	
	else if(symbol.startsWith("_DWinMain")){
		return DemangleType.WinMain;
	}		
	else if(symbol.startsWith("_D")){
		return DemangleType.PublicSymbol;
	}
	// no particular type, default the symbol to a 'public'
	return DemangleType.PublicSymbol;
}