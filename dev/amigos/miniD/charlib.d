/******************************************************************************
This module contains the 'char' standard library.

License:
Copyright (c) 2008 Jarrett Billingsley

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from the
use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it freely,
subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software in a
	product, an acknowledgment in the product documentation would be
	appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not
	be misrepresented as being the original software.

    3. This notice may not be removed or altered from any source distribution.
******************************************************************************/

module amigos.minid.charlib;

version = Tango;

import amigos.minid.ex;
import amigos.minid.interpreter;
import amigos.minid.types;

import tango.stdc.ctype;
import Uni = tango.text.Unicode;
import Utf = tango.text.convert.Utf;

struct CharLib
{
static:
	public void init(MDThread* t)
	{
		newNamespace(t, "сим");
			newFunction(t, &toLower,    "сим.впроп");    fielda(t, -2, "впроп");
			newFunction(t, &toUpper,    "сим.взаг");    fielda(t, -2, "взаг");
			newFunction(t, &isAlpha,    "сим.буква_ли");    fielda(t, -2, "буква_ли");
			newFunction(t, &isAlNum,    "сим.цифробукв_ли");    fielda(t, -2, "цифробукв_ли");
			newFunction(t, &isLower,    "сим.проп_ли");    fielda(t, -2, "проп_ли");
			newFunction(t, &isUpper,    "сим.заг_ли");    fielda(t, -2, "заг_ли");
			newFunction(t, &isDigit,    "сим.цифра_ли");    fielda(t, -2, "цифра_ли");
			newFunction(t, &isCtrl,     "сим.упр_ли");     fielda(t, -2, "упр_ли");
			newFunction(t, &isPunct,    "сим.пункт_ли");    fielda(t, -2, "пункт_ли");
			newFunction(t, &isSpace,    "сим.пбел_ли");    fielda(t, -2, "пбел_ли");
			newFunction(t, &isHexDigit, "сим.гексЦифра_ли"); fielda(t, -2, "гексЦифра_ли");
			newFunction(t, &isAscii,    "сим.аски_ли");    fielda(t, -2, "аски_ли");
			newFunction(t, &isValid,    "сим.подходит_ли");    fielda(t, -2, "подходит_ли");
		setTypeMT(t, MDValue.Type.Char);
	}

	uword toLower(MDThread* t, uword numParams)
	{
		dchar[4] outbuf = void;
		dchar c = checkCharParam(t, 0);
		pushChar(t, safeCode(t, Uni.toLower((&c)[0 .. 1], outbuf)[0]));
		return 1;
	}

	uword toUpper(MDThread* t, uword numParams)
	{
		dchar[4] outbuf = void;
		dchar c = checkCharParam(t, 0);
		pushChar(t, safeCode(t, Uni.toUpper((&c)[0 .. 1], outbuf)[0]));
		return 1;
	}

	uword isAlpha(MDThread* t, uword numParams)
	{
		pushBool(t, Uni.isLetter(checkCharParam(t, 0)));
		return 1;
	}

	uword isAlNum(MDThread* t, uword numParams)
	{
		pushBool(t, Uni.isLetterOrDigit(checkCharParam(t, 0)));
		return 1;
	}

	uword isLower(MDThread* t, uword numParams)
	{
		pushBool(t, Uni.isLower(checkCharParam(t, 0)));
		return 1;
	}

	uword isUpper(MDThread* t, uword numParams)
	{
		pushBool(t, Uni.isUpper(checkCharParam(t, 0)));
		return 1;
	}

	uword isDigit(MDThread* t, uword numParams)
	{
		pushBool(t, Uni.isDigit(checkCharParam(t, 0)));
		return 1;
	}

	uword isCtrl(MDThread* t, uword numParams)
	{
		pushBool(t, cast(bool)iscntrl(checkCharParam(t, 0)));
		return 1;
	}

	uword isPunct(MDThread* t, uword numParams)
	{
		pushBool(t, cast(bool)ispunct(checkCharParam(t, 0)));
		return 1;
	}

	uword isSpace(MDThread* t, uword numParams)
	{
		pushBool(t, cast(bool)isspace(checkCharParam(t, 0)));
		return 1;
	}

	uword isHexDigit(MDThread* t, uword numParams)
	{
		pushBool(t, cast(bool)isxdigit(checkCharParam(t, 0)));
		return 1;
	}

	uword isAscii(MDThread* t, uword numParams)
	{
		pushBool(t, checkCharParam(t, 0) <= 0x7f);
		return 1;
	}

	uword isValid(MDThread* t, uword numParams)
	{
		pushBool(t, Utf.isValid(checkCharParam(t, 0)));
		return 1;
	}
}