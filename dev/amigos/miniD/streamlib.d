/******************************************************************************
This module contains the 'stream' standard library.

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

module amigos.minid.streamlib;

import tango.core.Traits;
import tango.io.Console;
import tango.io.device.Conduit;
import tango.io.stream.Format;
import tango.io.stream.Lines;
import tango.math.Math;

import amigos.minid.ex;
import amigos.minid.interpreter;
import amigos.minid.misc;
import amigos.minid.types;
import amigos.minid.vector;
import amigos.minid.vm;

// TODO: abstract out common functionality between the three types of streams

struct StreamLib
{
static:
	public void init(MDThread* t)
	{
		makeModule(t, "поток", function uword(MDThread* t, uword numParams)
		{
			InStreamObj.init(t);
			OutStreamObj.init(t);
			InoutStreamObj.init(t);
			VectorInStreamObj.init(t);
			VectorOutStreamObj.init(t);
			VectorInoutStreamObj.init(t);

				pushGlobal(t, "ВхоПоток");
				pushNull(t);
				pushNativeObj(t, cast(Object)Cin.stream);
				pushBool(t, false);
				rawCall(t, -4, 1);
			newGlobal(t, "стдвхо");

				pushGlobal(t, "ВыхПоток");
				pushNull(t);
				pushNativeObj(t, cast(Object)Cout.stream);
				pushBool(t, false);
				rawCall(t, -4, 1);
			newGlobal(t, "стдвых");

				pushGlobal(t, "ВыхПоток");
				pushNull(t);
				pushNativeObj(t, cast(Object)Cerr.stream);
				pushBool(t, false);
				rawCall(t, -4, 1);
			newGlobal(t, "стдош");

			return 0;
		});

		importModuleNoNS(t, "поток");
	}
}

struct InStreamObj
{
static:
	enum Fields
	{
		stream,
		lines
	}

	align(1) struct Members
	{
		InputStream stream;
		Lines!(char) lines;
		bool closed = true;
		bool closable = true;
	}
	
	public InputStream getStream(MDThread* t, word idx)
	{
		return checkInstParam!(Members)(t, idx, "поток.ВхоПоток").stream;
	}

	public InputStream getOpenStream(MDThread* t, word idx)
	{
		auto ret = checkInstParam!(Members)(t, idx, "поток.ВхоПоток");

		if(ret.closed)
			throwException(t, "Attempting to perform operation on a closed stream");

		return ret.stream;
	}

	public void init(MDThread* t)
	{
		CreateClass(t, "ВхоПоток", (CreateClass* c)
		{
			c.method("конструктор", &constructor);
			c.method("читайБайт",    &readVal!(byte));
			c.method("читайББайт",   &readVal!(ubyte));
			c.method("читайКрат",   &readVal!(short));
			c.method("читайБКрат",  &readVal!(ushort));
			c.method("читайЦел",     &readVal!(int));
			c.method("читайБЦел",    &readVal!(uint));
			c.method("читайДол",    &readVal!(long));
			c.method("читайБДол",   &readVal!(ulong));
			c.method("читайПлав",   &readVal!(float));
			c.method("читайДво",  &readVal!(double));
			c.method("читайСим",    &readVal!(char));
			c.method("читайШим",   &readVal!(wchar));
			c.method("читайДим",   &readVal!(dchar));
			c.method("читайТкст",  &readString);
			c.method("читайстр",      &readln);
			c.method("читайСимы",   &readChars);
			c.method("читайВектор",  &readVector);
			c.method("сыроЧит",     &rawRead);
			c.method("пропусти",        &skip);

			c.method("перейди",        &seek);
			c.method("позиция",    &position);
			c.method("размер",        &size);
			c.method("закрой",       &close);
			c.method("открыт_ли",      &isOpen);

				newFunction(t, &iterator, "ВхоПоток.обходчик");
			c.method("опПрименить", &opApply, 1);
		});

		newFunction(t, &allocator, "ВхоПоток.аллокатор");
		setAllocator(t, -2);
		
		newFunction(t, &finalizer, "ВхоПоток.финализатор");
		setFinalizer(t, -2);

		newGlobal(t, "ВхоПоток");
	}

	private Members* getThis(MDThread* t)
	{
		return checkInstParam!(Members)(t, 0, "ВхоПоток");
	}
	
	private Members* getOpenThis(MDThread* t)
	{
		auto ret = checkInstParam!(Members)(t, 0, "ВхоПоток");
		
		if(ret.closed)
			throwException(t, "Attempting to perform operation on a closed stream");
			
		return ret;
	}
	
	private void readExact(MDThread* t, Members* memb, void* dest, uword size)
	{
		while(size > 0)
		{
			auto numRead = memb.stream.read(dest[0 .. size]);

			if(numRead == IOStream.Eof)
				throwException(t, "End-of-flow encountered while reading");

			size -= numRead;
			dest += numRead;
		}
	}
	
	private uword readAtMost(MDThread* t, Members* memb, void* dest, uword size)
	{
		auto initial = size;

		while(size > 0)
		{
			auto numRead = memb.stream.read(dest[0 .. size]);

			if(numRead == IOStream.Eof)
				break;
			else if(numRead < size)
			{
				size -= numRead;
				break;
			}

			size -= numRead;
			dest += numRead;
		}

		return initial - size;
	}

	uword allocator(MDThread* t, uword numParams)
	{
		newInstance(t, 0, Fields.max + 1, Members.sizeof);
		*(cast(Members*)getExtraBytes(t, -1).ptr) = Members.init;

		dup(t);
		pushNull(t);
		rotateAll(t, 3);
		methodCall(t, 2, "конструктор", 0);
		return 1;
	}

	uword finalizer(MDThread* t, uword numParams)
	{
		auto memb = cast(Members*)getExtraBytes(t, 0).ptr;

		if(memb.closable && !memb.closed)
		{
			memb.closed = true;
			safeCode(t, memb.stream.close());
		}

		return 0;
	}

	public uword constructor(MDThread* t, uword numParams)
	{
		auto memb = getThis(t);

		if(memb.stream !is null)
			throwException(t, "Attempting to call constructor on an already-initialized InStream");

		checkParam(t, 1, MDValue.Type.NativeObj);
		auto input = cast(InputStream)getNativeObj(t, 1);

		if(input is null)
			throwException(t, "instances of InStream may only be created using instances of the Tango InputStream");

		memb.closable = optBoolParam(t, 2, true);
		memb.stream = input;
		memb.lines = new Lines!(char)(memb.stream);
		memb.closed = false;

		pushNativeObj(t, cast(Object)memb.stream); setExtraVal(t, 0, Fields.stream);
		pushNativeObj(t, memb.lines);              setExtraVal(t, 0, Fields.lines);

		return 0;
	}

	public uword readVal(T)(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		T val = void;
		
		safeCode(t, readExact(t, memb, &val, T.sizeof));

		static if(isIntegerType!(T))
			pushInt(t, cast(mdint)val);
		else static if(isRealType!(T))
			pushFloat(t, val);
		else static if(isCharType!(T))
			pushChar(t, val);
		else
			static assert(false);

		return 1;
	}

	public uword readString(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);

		safeCode(t,
		{
			uword length = void;

			safeCode(t, readExact(t, memb, &length, length.sizeof));

			auto dat = t.vm.alloc.allocArray!(char)(length);

			scope(exit)
				t.vm.alloc.freeArray(dat);

			safeCode(t, readExact(t, memb, dat.ptr, dat.length * char.sizeof));

			pushString(t, dat);
		}());

		return 1;
	}

	public uword readln(MDThread* t, uword numParams)
	{
		auto ret = safeCode(t, getOpenThis(t).lines.next());

		if(ret.ptr is null)
			throwException(t, "Stream has no more data.");

		pushString(t, ret);
		return 1;
	}

	public uword readChars(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto num = checkIntParam(t, 1);

		if(num < 0 || num > uword.max)
			throwException(t, "Invalid number of characters ({})", num);

		safeCode(t,
		{
			auto dat = t.vm.alloc.allocArray!(char)(cast(uword)num);

			scope(exit)
				t.vm.alloc.freeArray(dat);

			safeCode(t, readExact(t, memb, dat.ptr, dat.length * char.sizeof));
			pushString(t, dat);
		}());

		return 1;
	}

	public uword readVector(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkAnyParam(t, 1);

		mdint size = void;
		VectorObj.Members* vecMemb = void;

		if(isString(t, 1))
		{
			auto type = getString(t, 1);
			size = checkIntParam(t, 2);

			pushGlobal(t, "Вектор");
			pushNull(t);
			pushString(t, type);
			pushInt(t, size);
			rawCall(t, -4, 1);

			vecMemb = getMembers!(VectorObj.Members)(t, -1);
		}
		else
		{
			vecMemb = checkInstParam!(VectorObj.Members)(t, 1, "Вектор");
			size = optIntParam(t, 2, vecMemb.length);

			if(size != vecMemb.length)
			{
				dup(t, 1);
				pushNull(t);
				pushInt(t, size);
				methodCall(t, -3, "опПрисвоитьДлину", 0);
			}

			dup(t, 1);
		}

		uword numBytes = cast(uword)size * vecMemb.type.itemSize;
		safeCode(t, readExact(t, memb, vecMemb.data, numBytes));
		return 1;
	}

	public uword rawRead(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto size = checkIntParam(t, 1);

		if(size < 0)
			throwException(t, "Invalid size: {}", size);

		VectorObj.Members* vecMemb = void;

		if(optParam(t, 2, MDValue.Type.Instance))
		{
			vecMemb = checkInstParam!(VectorObj.Members)(t, 2, "Вектор");
			auto typeCode = vecMemb.type.code;

			if(typeCode != VectorObj.TypeCode.i8 && typeCode != VectorObj.TypeCode.u8)
				throwException(t, "Passed-in vector must be of type i8 or u8, not '{}'", VectorObj.typeNames[typeCode]);

			if(size != vecMemb.length)
			{
				dup(t, 2);
				pushNull(t);
				pushInt(t, size);
				methodCall(t, -3, "опПрисвоитьДлину", 0);
			}

			dup(t, 2);
		}
		else
		{
			pushGlobal(t, "Вектор");
			pushNull(t);
			pushString(t, "u8");
			pushInt(t, size);
			rawCall(t, -4, 1);

			vecMemb = getMembers!(VectorObj.Members)(t, -1);
		}

		auto realSize = safeCode(t, readAtMost(t, memb, vecMemb.data, cast(uword)size));

		if(realSize != size)
		{
			dup(t);
			pushNull(t);
			pushInt(t, realSize);
			methodCall(t, -3, "опПрисвоитьДлину", 0);
		}

		return 1;
	}

	private uword iterator(MDThread* t, uword numParams)
	{
		auto index = checkIntParam(t, 1) + 1;
		auto line = safeCode(t, getOpenThis(t).lines.next());

		if(line.ptr is null)
			return 0;

		pushInt(t, index);
		pushString(t, line);
		return 2;
	}

	public uword opApply(MDThread* t, uword numParams)
	{
		checkInstParam(t, 0, "ВхоПоток");
		getUpval(t, 0);
		dup(t, 0);
		pushInt(t, 0);
		return 3;
	}

	public uword skip(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto dist_ = checkIntParam(t, 1);

		if(dist_ < 0 || dist_ > uword.max)
			throwException(t, "Invalid skip distance ({})", dist_);

		auto dist = cast(uword)dist_;

		// it's OK if this is shared - it's just a bit bucket
		static ubyte[1024] dummy;

		while(dist > 0)
		{
			uword numBytes = dist < dummy.length ? dist : dummy.length;
			safeCode(t, readExact(t, memb, dummy.ptr, numBytes));
			dist -= numBytes;
		}

		return 0;
	}

	public uword seek(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto pos = checkIntParam(t, 1);
		auto whence = checkCharParam(t, 2);

		if(whence == 'b')
			safeCode(t, memb.stream.seek(pos, IOStream.Anchor.Begin));
		else if(whence == 'c')
			safeCode(t, memb.stream.seek(pos, IOStream.Anchor.Current));
		else if(whence == 'e')
			safeCode(t, memb.stream.seek(pos, IOStream.Anchor.End));
		else
			throwException(t, "Invalid seek type '{}'", whence);

		dup(t, 0);
		return 1;
	}

	public uword position(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);

		if(numParams == 0)
		{
			pushInt(t, safeCode(t, cast(mdint)memb.stream.seek(0, IOStream.Anchor.Current)));
			return 1;
		}
		else
		{
			safeCode(t, memb.stream.seek(checkIntParam(t, 1), IOStream.Anchor.Begin));
			return 0;
		}
	}

	public uword size(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto pos = safeCode(t, memb.stream.seek(0, IOStream.Anchor.Current));
		auto ret = safeCode(t, memb.stream.seek(0, IOStream.Anchor.End));
		safeCode(t, memb.stream.seek(pos, IOStream.Anchor.Begin));
		pushInt(t, cast(mdint)ret);
		return 1;
	}

	public uword close(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);

		if(!memb.closable)
			throwException(t, "Attempting to close an unclosable stream");

		memb.closed = true;
		safeCode(t, memb.stream.close());

		return 0;
	}

	public uword isOpen(MDThread* t, uword numParams)
	{
		pushBool(t, !getThis(t).closed);
		return 1;
	}
}

struct OutStreamObj
{
static:
	enum Fields
	{
		stream,
		print
	}

	align(1) struct Members
	{
		OutputStream stream;
		FormatOutput!(char) print;
		bool closed = true;
		bool closable = true;
	}
	
	public OutputStream getStream(MDThread* t, word idx)
	{
		return checkInstParam!(Members)(t, idx, "поток.ВыхПоток").stream;
	}

	public OutputStream getOpenStream(MDThread* t, word idx)
	{
		auto ret = checkInstParam!(Members)(t, idx, "поток.ВыхПоток");

		if(ret.closed)
			throwException(t, "Attempting to perform operation on a closed stream");

		return ret.stream;
	}

	public void init(MDThread* t)
	{
		CreateClass(t, "ВыхПоток", (CreateClass* c)
		{
			c.method("конструктор", &constructor);
			c.method("пишиБайт",   &writeVal!(byte));
			c.method("пишиББайт",  &writeVal!(ubyte));
			c.method("пишиКрат",  &writeVal!(short));
			c.method("пишиБКрат", &writeVal!(ushort));
			c.method("пишиЦел",    &writeVal!(int));
			c.method("пишиБЦел",   &writeVal!(uint));
			c.method("пишиДол",   &writeVal!(long));
			c.method("пишиБДол",  &writeVal!(ulong));
			c.method("пишиПлав",  &writeVal!(float));
			c.method("пишиДво", &writeVal!(double));
			c.method("пишиСим",   &writeVal!(char));
			c.method("пишиШим",  &writeVal!(wchar));
			c.method("пишиДим",  &writeVal!(dchar));
			c.method("пишиТкст", &writeString);
			c.method("пиши",       &write);
			c.method("пишистр",     &writeln);
			c.method("пишиф",      &writef);
			c.method("пишифстр",    &writefln);
			c.method("пишиСимы",  &writeChars);
			c.method("пишиДжейСОН",   &writeJSON);
			c.method("пишиВектор", &writeVector);
			c.method("слей",       &flush);
			c.method("копируй",        &copy);
			c.method("слейНаНС",   &flushOnNL);

			c.method("перейди",        &seek);
			c.method("позиция",    &position);
			c.method("размер",        &size);
			c.method("закрой",       &close);
			c.method("открыт_ли",      &isOpen);
		});

		newFunction(t, &allocator, "ВыхПоток.аллокатор");
		setAllocator(t, -2);

		newFunction(t, &finalizer, "ВыхПоток.финализатор");
		setFinalizer(t, -2);

		newGlobal(t, "ВыхПоток");
	}
	
	Members* getThis(MDThread* t)
	{
		return checkInstParam!(Members)(t, 0, "ВыхПоток");
	}

	private Members* getOpenThis(MDThread* t)
	{
		auto ret = checkInstParam!(Members)(t, 0, "ВыхПоток");
		
		if(ret.closed)
			throwException(t, "Attempting to perform operation on a closed stream");
			
		return ret;
	}
	
	private void writeExact(MDThread* t, Members* memb, void* src, uword size)
	{
		while(size > 0)
		{
			auto numWritten = memb.stream.write(src[0 .. size]);
			
			if(numWritten == IOStream.Eof)
				throwException(t, "End-of-flow encountered while writing");
				
			size -= numWritten;
			src += numWritten;
		}
	}

	uword allocator(MDThread* t, uword numParams)
	{
		newInstance(t, 0, Fields.max + 1, Members.sizeof);
		*(cast(Members*)getExtraBytes(t, -1).ptr) = Members.init;

		dup(t);
		pushNull(t);
		rotateAll(t, 3);
		methodCall(t, 2, "конструктор", 0);
		return 1;
	}

	uword finalizer(MDThread* t, uword numParams)
	{
		auto memb = cast(Members*)getExtraBytes(t, 0).ptr;

		if(memb.closable && !memb.closed)
		{
			memb.closed = true;
			safeCode(t, memb.stream.flush());
			safeCode(t, memb.stream.close());
		}

		return 0;
	}

	public uword constructor(MDThread* t, uword numParams)
	{
		auto memb = getThis(t);

		if(memb.stream !is null)
			throwException(t, "Attempting to call constructor on an already-initialized OutStream");

		checkParam(t, 1, MDValue.Type.NativeObj);
		auto output = cast(OutputStream)getNativeObj(t, 1);

		if(output is null)
			throwException(t, "instances of OutStream may only be created using instances of the Tango OutputStream");

		memb.closable = optBoolParam(t, 2, true);
		memb.stream = output;
		memb.print = new FormatOutput!(char)(t.vm.formatter, memb.stream);
		memb.closed = false;

		pushNativeObj(t, cast(Object)memb.stream); setExtraVal(t, 0, Fields.stream);
		pushNativeObj(t, memb.print);              setExtraVal(t, 0, Fields.print);

		return 0;
	}

	public uword writeVal(T)(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);

		static if(isIntegerType!(T))
			T val = cast(T)checkIntParam(t, 1);
		else static if(isRealType!(T))
			T val = cast(T)checkFloatParam(t, 1);
		else static if(isCharType!(T))
			T val = cast(T)checkCharParam(t, 1);
		else
			static assert(false);

		safeCode(t, writeExact(t, memb, &val, val.sizeof));
		dup(t, 0);
		return 1;
	}

	public uword writeString(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto str = checkStringParam(t, 1);

		safeCode(t,
		{
			auto len = str.length;
			writeExact(t, memb, &len, len.sizeof);
			writeExact(t, memb, str.ptr, str.length * char.sizeof);
		}());

		dup(t, 0);
		return 1;
	}

	public uword write(MDThread* t, uword numParams)
	{
		auto p = getOpenThis(t).print;

		for(uword i = 1; i <= numParams; i++)
		{
			pushToString(t, i);
			safeCode(t, p.print(getString(t, -1)));
			pop(t);
		}

		dup(t, 0);
		return 1;
	}

	public uword writeln(MDThread* t, uword numParams)
	{
		auto p = getOpenThis(t).print;

		for(uword i = 1; i <= numParams; i++)
		{
			pushToString(t, i);
			safeCode(t, p.print(getString(t, -1)));
			pop(t);
		}

		safeCode(t, p.newline());
		dup(t, 0);
		return 1;
	}

	public uword writef(MDThread* t, uword numParams)
	{
		auto p = getOpenThis(t).print;

		safeCode(t, formatImpl(t, numParams, delegate uint(char[] s)
		{
			p.print(s);
			return s.length;
		}));

		dup(t, 0);
		return 1;
	}

	public uword writefln(MDThread* t, uword numParams)
	{
		auto p = getOpenThis(t).print;

		safeCode(t, formatImpl(t, numParams, delegate uint(char[] s)
		{
			p.print(s);
			return s.length;
		}));

		safeCode(t, p.newline());
		dup(t, 0);
		return 1;
	}

	public uword writeChars(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto str = checkStringParam(t, 1);
		safeCode(t, writeExact(t, memb, str.ptr, str.length * char.sizeof));
		dup(t, 0);
		return 1;
	}

	public uword writeJSON(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkAnyParam(t, 1);
		auto pretty = optBoolParam(t, 2, false);
		JSON.save(t, 1, pretty, memb.print);
		dup(t, 0);
		return 1;
	}

	public uword writeVector(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto vecMemb = checkInstParam!(VectorObj.Members)(t, 1, "Вектор");
		auto lo = optIntParam(t, 2, 0);
		auto hi = optIntParam(t, 3, vecMemb.length);

		if(lo < 0)
			lo += vecMemb.length;

		if(lo < 0 || lo > vecMemb.length)
			throwException(t, "Invalid low index: {} (vector length: {})", lo, vecMemb.length);

		if(hi < 0)
			hi += vecMemb.length;

		if(hi < lo || hi > vecMemb.length)
			throwException(t, "Invalid indices: {} .. {} (vector length: {})", lo, hi, vecMemb.length);

		auto isize = vecMemb.type.itemSize;
		safeCode(t, writeExact(t, memb, vecMemb.data + (cast(uword)lo * isize), (cast(uword)(hi - lo)) * isize));
		dup(t, 0);
		return 1;
	}

	public uword flush(MDThread* t, uword numParams)
	{
		safeCode(t, getOpenThis(t).stream.flush());
		dup(t, 0);
		return 1;
	}

	public uword copy(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkInstParam(t, 1);

		InputStream stream;
		pushGlobal(t, "ВхоПоток");

		if(as(t, 1, -1))
		{
			pop(t);
			stream = getMembers!(InStreamObj.Members)(t, 1).stream;
		}
		else
		{
			pop(t);
			pushGlobal(t, "Проток");

			if(as(t, 1, -1))
			{
				pop(t);
				stream = getMembers!(InoutStreamObj.Members)(t, 1).conduit;
			}
			else
				paramTypeError(t, 1, "InStream|InoutStream");
		}

		safeCode(t, memb.stream.copy(stream));
		dup(t, 0);
		return 1;
	}
	
	public uword flushOnNL(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		safeCode(t, memb.print.flush = checkBoolParam(t, 1));
		return 0;
	}

	public uword seek(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto pos = checkIntParam(t, 1);
		auto whence = checkCharParam(t, 2);

		if(whence == 'b')
			safeCode(t, memb.stream.seek(pos, IOStream.Anchor.Begin));
		else if(whence == 'c')
			safeCode(t, memb.stream.seek(pos, IOStream.Anchor.Current));
		else if(whence == 'e')
			safeCode(t, memb.stream.seek(pos, IOStream.Anchor.End));
		else
			throwException(t, "Invalid seek type '{}'", whence);

		dup(t, 0);
		return 1;
	}

	public uword position(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);

		if(numParams == 0)
		{
			pushInt(t, safeCode(t, cast(mdint)memb.stream.seek(0, IOStream.Anchor.Current)));
			return 1;
		}
		else
		{
			safeCode(t, memb.stream.seek(checkIntParam(t, 1), IOStream.Anchor.Begin));
			return 0;
		}
	}

	public uword size(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto pos = safeCode(t, memb.stream.seek(0, IOStream.Anchor.Current));
		auto ret = safeCode(t, memb.stream.seek(0, IOStream.Anchor.End));
		safeCode(t, memb.stream.seek(pos, IOStream.Anchor.Begin));
		pushInt(t, cast(mdint)ret);
		return 1;
	}

	public uword close(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		
		if(!memb.closable)
			throwException(t, "Attempting to close an unclosable stream");

		memb.closed = true;
		safeCode(t, memb.stream.flush());
		safeCode(t, memb.stream.close());
		return 0;
	}

	public uword isOpen(MDThread* t, uword numParams)
	{
		pushBool(t, !getThis(t).closed);
		return 1;
	}
}

struct InoutStreamObj
{
static:
	enum Fields
	{
		conduit,
		lines,
		print
	}

	align(1) struct Members
	{
		IConduit conduit;
		Lines!(char) lines;
		FormatOutput!(char) print;
		bool closed = true;
		bool closable = true;
		bool dirty = false;
	}
	
	public IConduit getConduit(MDThread* t, word idx)
	{
		return checkInstParam!(Members)(t, idx, "поток.Проток").conduit;
	}

	public IConduit getOpenConduit(MDThread* t, word idx)
	{
		auto ret = checkInstParam!(Members)(t, idx, "поток.Проток");

		if(ret.closed)
			throwException(t, "Attempting to perform operation on a closed stream");

		return ret.conduit;
	}

	public void init(MDThread* t)
	{
		CreateClass(t, "Поток", (CreateClass* c)
		{
			c.method("конструктор", &constructor);

			c.method("читайБайт",    &readVal!(byte));
			c.method("читайББайт",   &readVal!(ubyte));
			c.method("читайКрат",   &readVal!(short));
			c.method("читайБКрат",  &readVal!(ushort));
			c.method("читайЦел",     &readVal!(int));
			c.method("читайБЦел",    &readVal!(uint));
			c.method("читайДол",    &readVal!(long));
			c.method("читайБДол",   &readVal!(ulong));
			c.method("читайПлав",   &readVal!(float));
			c.method("читайДво",  &readVal!(double));
			c.method("читайСим",    &readVal!(char));
			c.method("читайШим",   &readVal!(wchar));
			c.method("читайДим",   &readVal!(dchar));
			c.method("читайТкст",  &readString);
			c.method("читайстр",      &readln);
			c.method("читайСимы",   &readChars);
			c.method("читайВектор",  &readVector);
			c.method("сыроЧит",     &rawRead);

				newFunction(t, &iterator, "Проток.обходчик");
			c.method("опПрименить", &opApply, 1);

			c.method("пишиБайт",   &writeVal!(byte));
			c.method("пишиББайт",  &writeVal!(ubyte));
			c.method("пишиКрат",  &writeVal!(short));
			c.method("пишиБКрат", &writeVal!(ushort));
			c.method("пишиЦел",    &writeVal!(int));
			c.method("пишиБЦел",   &writeVal!(uint));
			c.method("пишиДол",   &writeVal!(long));
			c.method("пишиБДол",  &writeVal!(ulong));
			c.method("пишиПлав",  &writeVal!(float));
			c.method("пишиДво", &writeVal!(double));
			c.method("пишиСим",   &writeVal!(char));
			c.method("пишиШим",  &writeVal!(wchar));
			c.method("пишиДим",  &writeVal!(dchar));
			c.method("пишиТкст", &writeString);
			c.method("пиши",       &write);
			c.method("пишистр",     &writeln);
			c.method("пишиф",      &writef);
			c.method("пишифстр",    &writefln);
			c.method("пишиСимы",  &writeChars);
			c.method("пишиДжейСОН",   &writeJSON);
			c.method("пишиВектор", &writeVector);
			c.method("слей",       &flush);
			c.method("копируй",        &copy);
			c.method("слейНаНС",   &flushOnNL);

			c.method("пропусти",        &skip);
			c.method("перейди",        &seek);
			c.method("позиция",    &position);
			c.method("размер",        &size);
			c.method("закрой",       &close);
			c.method("открыт_ли",      &isOpen);
		});

		newFunction(t, &allocator, "Проток.аллокатор");
		setAllocator(t, -2);

		newFunction(t, &finalizer, "Проток.финализатор");
		setFinalizer(t, -2);

		newGlobal(t, "Проток");
	}

	Members* getThis(MDThread* t)
	{
		return checkInstParam!(Members)(t, 0, "Проток");
	}

	private Members* getOpenThis(MDThread* t)
	{
		auto ret = checkInstParam!(Members)(t, 0, "Проток");
		
		if(ret.closed)
			throwException(t, "Attempting to perform operation on a closed stream");

		return ret;
	}

	private void readExact(MDThread* t, Members* memb, void* dest, uword size)
	{
		while(size > 0)
		{
			auto numRead = memb.conduit.read(dest[0 .. size]);

			if(numRead == IOStream.Eof)
				throwException(t, "End-of-flow encountered while reading");

			size -= numRead;
			dest += numRead;
		}
	}

	private uword readAtMost(MDThread* t, Members* memb, void* dest, uword size)
	{
		auto initial = size;

		while(size > 0)
		{
			auto numRead = memb.conduit.read(dest[0 .. size]);

			if(numRead == IOStream.Eof)
				break;
			else if(numRead < size)
			{
				size -= numRead;
				break;
			}

			size -= numRead;
			dest += numRead;
		}

		return initial - size;
	}

	private void writeExact(MDThread* t, Members* memb, void* src, uword size)
	{
		while(size > 0)
		{
			auto numWritten = memb.conduit.write(src[0 .. size]);

			if(numWritten == IOStream.Eof)
				throwException(t, "End-of-flow encountered while writing");

			size -= numWritten;
			src += numWritten;
		}
	}

	uword allocator(MDThread* t, uword numParams)
	{
		newInstance(t, 0, Fields.max + 1, Members.sizeof);
		*(cast(Members*)getExtraBytes(t, -1).ptr) = Members.init;

		dup(t);
		pushNull(t);
		rotateAll(t, 3);
		methodCall(t, 2, "конструктор", 0);
		return 1;
	}

	uword finalizer(MDThread* t, uword numParams)
	{
		auto memb = cast(Members*)getExtraBytes(t, 0).ptr;

		if(memb.closable && !memb.closed)
		{
			memb.closed = true;
			
			if(memb.dirty)
			{
				safeCode(t, memb.conduit.flush());
				memb.dirty = false;
			}

			safeCode(t, memb.conduit.close());
		}

		return 0;
	}

	public uword constructor(MDThread* t, uword numParams)
	{
		auto memb = getThis(t);

		if(memb.conduit !is null)
			throwException(t, "Attempting to call constructor on an already-initialized InoutStream");

		checkParam(t, 1, MDValue.Type.NativeObj);
		auto conduit = cast(IConduit)getNativeObj(t, 1);

		if(conduit is null)
			throwException(t, "instances of Stream may only be created using instances of Tango's IConduit");

		memb.closable = optBoolParam(t, 2, true);
		memb.conduit = conduit;
		memb.lines = new Lines!(char)(memb.conduit);
		memb.print = new FormatOutput!(char)(t.vm.formatter, memb.conduit);
		memb.closed = false;

		pushNativeObj(t, cast(Object)memb.conduit); setExtraVal(t, 0, Fields.conduit);
		pushNativeObj(t, memb.lines);               setExtraVal(t, 0, Fields.lines);
		pushNativeObj(t, memb.print);               setExtraVal(t, 0, Fields.print);

		return 0;
	}

	void checkDirty(MDThread* t, Members* memb)
	{
		if(memb.dirty)
		{
			memb.dirty = false;
			safeCode(t, memb.conduit.flush());
		}
	}

	public uword readVal(T)(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkDirty(t, memb);

		T val = void;

		safeCode(t, readExact(t, memb, &val, T.sizeof));

		static if(isIntegerType!(T))
			pushInt(t, cast(mdint)val);
		else static if(isRealType!(T))
			pushFloat(t, val);
		else static if(isCharType!(T))
			pushChar(t, val);
		else
			static assert(false);

		return 1;
	}

	public uword readString(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkDirty(t, memb);

		safeCode(t,
		{
			uword length = void;

			safeCode(t, readExact(t, memb, &length, length.sizeof));

			auto dat = t.vm.alloc.allocArray!(char)(length);

			scope(exit)
				t.vm.alloc.freeArray(dat);

			safeCode(t, readExact(t, memb, dat.ptr, dat.length * char.sizeof));

			pushString(t, dat);
		}());

		return 1;
	}

	public uword readln(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkDirty(t, memb);
		auto ret = safeCode(t, memb.lines.next());

		if(ret.ptr is null)
			throwException(t, "Stream has no more data.");

		pushString(t, ret);
		return 1;
	}

	public uword readChars(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto num = checkIntParam(t, 1);

		if(num < 0 || num > uword.max)
			throwException(t, "Invalid number of characters ({})", num);

		checkDirty(t, memb);

		safeCode(t,
		{
			auto dat = t.vm.alloc.allocArray!(char)(cast(uword)num);

			scope(exit)
				t.vm.alloc.freeArray(dat);

			safeCode(t, readExact(t, memb, dat.ptr, dat.length * char.sizeof));
			pushString(t, dat);
		}());

		return 1;
	}

	public uword readVector(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkDirty(t, memb);

		checkAnyParam(t, 1);

		mdint size = void;
		VectorObj.Members* vecMemb = void;

		if(isString(t, 1))
		{
			auto type = getString(t, 1);
			size = checkIntParam(t, 2);

			pushGlobal(t, "Вектор");
			pushNull(t);
			pushString(t, type);
			pushInt(t, size);
			rawCall(t, -4, 1);

			vecMemb = getMembers!(VectorObj.Members)(t, -1);
		}
		else
		{
			vecMemb = checkInstParam!(VectorObj.Members)(t, 1, "Вектор");
			size = optIntParam(t, 2, vecMemb.length);

			if(size != vecMemb.length)
			{
				dup(t, 1);
				pushNull(t);
				pushInt(t, size);
				methodCall(t, -3, "опПрисвоитьДлину", 0);
			}

			dup(t, 1);
		}

		uword numBytes = cast(uword)size * vecMemb.type.itemSize;
		safeCode(t, readExact(t, memb, vecMemb.data, numBytes));
		return 1;
	}

	public uword rawRead(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkDirty(t, memb);

		auto size = checkIntParam(t, 1);

		if(size < 0)
			throwException(t, "Invalid size: {}", size);

		VectorObj.Members* vecMemb = void;

		if(optParam(t, 2, MDValue.Type.Instance))
		{
			vecMemb = checkInstParam!(VectorObj.Members)(t, 2, "Вектор");
			auto typeCode = vecMemb.type.code;

			if(typeCode != VectorObj.TypeCode.i8 && typeCode != VectorObj.TypeCode.u8)
				throwException(t, "Passed-in vector must be of type i8 or u8, not '{}'", VectorObj.typeNames[typeCode]);

			if(size != vecMemb.length)
			{
				dup(t, 2);
				pushNull(t);
				pushInt(t, size);
				methodCall(t, -3, "опПрисвоитьДлину", 0);
			}

			dup(t, 2);
		}
		else
		{
			pushGlobal(t, "Вектор");
			pushNull(t);
			pushString(t, "u8");
			pushInt(t, size);
			rawCall(t, -4, 1);

			vecMemb = getMembers!(VectorObj.Members)(t, -1);
		}

		auto realSize = safeCode(t, readAtMost(t, memb, vecMemb.data, cast(uword)size));

		if(realSize != size)
		{
			dup(t);
			pushNull(t);
			pushInt(t, realSize);
			methodCall(t, -3, "опПрисвоитьДлину", 0);
		}

		return 1;
	}

	private uword iterator(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkDirty(t, memb);
		auto index = checkIntParam(t, 1) + 1;
		auto line = safeCode(t, memb.lines.next());

		if(line.ptr is null)
			return 0;

		pushInt(t, index);
		pushString(t, line);
		return 2;
	}

	public uword opApply(MDThread* t, uword numParams)
	{
		checkInstParam(t, 0, "Проток");
		getUpval(t, 0);
		dup(t, 0);
		pushInt(t, 0);
		return 3;
	}

	public uword writeVal(T)(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);

		static if(isIntegerType!(T))
			T val = cast(T)checkIntParam(t, 1);
		else static if(isRealType!(T))
			T val = cast(T)checkFloatParam(t, 1);
		else static if(isCharType!(T))
			T val = cast(T)checkCharParam(t, 1);
		else
			static assert(false);

		safeCode(t, writeExact(t, memb, &val, val.sizeof));
		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword writeString(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto str = checkStringParam(t, 1);

		safeCode(t,
		{
			auto len = str.length;
			writeExact(t, memb, &len, len.sizeof);
			writeExact(t, memb, str.ptr, str.length * char.sizeof);
		}());

		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword write(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto p = memb.print;

		for(uword i = 1; i <= numParams; i++)
		{
			pushToString(t, i);
			safeCode(t, p.print(getString(t, -1)));
			pop(t);
		}

		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword writeln(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto p = memb.print;
		
		for(uword i = 1; i <= numParams; i++)
		{
			pushToString(t, i);
			safeCode(t, p.print(getString(t, -1)));
			pop(t);
		}

		safeCode(t, p.newline());
		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword writef(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto p = memb.print;

		safeCode(t, formatImpl(t, numParams, delegate uint(char[] s)
		{
			p.print(s);
			return s.length;
		}));

		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword writefln(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto p = memb.print;

		safeCode(t, formatImpl(t, numParams, delegate uint(char[] s)
		{
			p.print(s);
			return s.length;
		}));

		safeCode(t, p.newline());
		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword writeChars(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto str = checkStringParam(t, 1);
		safeCode(t, writeExact(t, memb, str.ptr, str.length * char.sizeof));
		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword writeJSON(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkAnyParam(t, 1);
		auto pretty = optBoolParam(t, 2, false);
		JSON.save(t, 1, pretty, memb.print);
		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword writeVector(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto vecMemb = checkInstParam!(VectorObj.Members)(t, 1, "Вектор");
		auto lo = optIntParam(t, 2, 0);
		auto hi = optIntParam(t, 3, vecMemb.length);

		if(lo < 0)
			lo += vecMemb.length;

		if(lo < 0 || lo > vecMemb.length)
			throwException(t, "Invalid low index: {} (vector length: {})", lo, vecMemb.length);

		if(hi < 0)
			hi += vecMemb.length;

		if(hi < lo || hi > vecMemb.length)
			throwException(t, "Invalid indices: {} .. {} (vector length: {})", lo, hi, vecMemb.length);

		auto isize = vecMemb.type.itemSize;
		safeCode(t, writeExact(t, memb, vecMemb.data + (cast(uword)lo * isize), (cast(uword)(hi - lo)) * isize));
		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword flush(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		safeCode(t, memb.conduit.flush());
		//safeCode(t, memb.conduit.clear());
		memb.dirty = false;
		dup(t, 0);
		return 1;
	}

	public uword copy(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkInstParam(t, 1);

		InputStream stream;
		pushGlobal(t, "ВхоПоток");

		if(as(t, 1, -1))
		{
			pop(t);
			stream = getMembers!(InStreamObj.Members)(t, 1).stream;
		}
		else
		{
			pop(t);
			pushGlobal(t, "Проток");

			if(as(t, 1, -1))
			{
				pop(t);
				stream = getMembers!(InoutStreamObj.Members)(t, 1).conduit;
			}
			else
				paramTypeError(t, 1, "InStream|InoutStream");
		}

		safeCode(t, memb.conduit.copy(stream));
		memb.dirty = true;
		dup(t, 0);
		return 1;
	}

	public uword flushOnNL(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		safeCode(t, memb.print.flush = checkBoolParam(t, 1));
		return 0;
	}

	public uword skip(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		auto dist_ = checkIntParam(t, 1);

		if(dist_ < 0 || dist_ > uword.max)
			throwException(t, "Invalid skip distance ({})", dist_);

		auto dist = cast(uword)dist_;

		checkDirty(t, memb);

		// it's OK if this is shared - it's just a bit bucket
		static ubyte[1024] dummy;

		while(dist > 0)
		{
			uword numBytes = dist < dummy.length ? dist : dummy.length;
			safeCode(t, readExact(t, memb, dummy.ptr, numBytes));
			dist -= numBytes;
		}

		return 0;
	}

	public uword seek(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkDirty(t, memb);
		auto pos = checkIntParam(t, 1);
		auto whence = checkCharParam(t, 2);

		if(whence == 'b')
			safeCode(t, memb.conduit.seek(pos, IOStream.Anchor.Begin));
		else if(whence == 'c')
			safeCode(t, memb.conduit.seek(pos, IOStream.Anchor.Current));
		else if(whence == 'e')
			safeCode(t, memb.conduit.seek(pos, IOStream.Anchor.End));
		else
			throwException(t, "Invalid seek type '{}'", whence);

		dup(t, 0);
		return 1;
	}

	public uword position(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);

		if(numParams == 0)
		{
			pushInt(t, safeCode(t, cast(mdint)memb.conduit.seek(0, IOStream.Anchor.Current)));
			return 1;
		}
		else
		{
			checkDirty(t, memb);
			safeCode(t, memb.conduit.seek(checkIntParam(t, 1), IOStream.Anchor.Begin));
			return 0;
		}
	}

	public uword size(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);
		checkDirty(t, memb);
		auto pos = safeCode(t, memb.conduit.seek(0, IOStream.Anchor.Current));
		auto ret = safeCode(t, memb.conduit.seek(0, IOStream.Anchor.End));
		safeCode(t, memb.conduit.seek(pos, IOStream.Anchor.Begin));
		pushInt(t, cast(mdint)ret);
		return 1;
	}

	public uword close(MDThread* t, uword numParams)
	{
		auto memb = getOpenThis(t);

		if(!memb.closable)
			throwException(t, "Attempting to close an unclosable stream");

		memb.closed = true;
		safeCode(t, memb.conduit.flush());
		safeCode(t, memb.conduit.close());

		return 0;
	}

	public uword isOpen(MDThread* t, uword numParams)
	{
		pushBool(t, !getThis(t).closed);
		return 1;
	}
}

class VectorConduit : Conduit, Conduit.Seek
{
	private MDVM* vm;
	private ulong mVec;
	private uword mPos = 0;

	private this(MDVM* vm, ulong vec)
	{
		super();
		this.vm = vm;
		mVec = vec;
	}
	
	override char[] toString()
	{
		return "<vector>";
	}

	override uword bufferSize()
	{
		return 1024;
	}

	override void detach()
	{

	}

	override uword read(void[] dest)
	{
		auto t = currentThread(vm);
		pushRef(t, mVec);
		auto memb = getMembers!(VectorObj.Members)(t, -1);
		pop(t);

		auto byteSize = memb.length * memb.type.itemSize;

		if(mPos >= byteSize)
			return Eof;

		auto numBytes = min(byteSize - mPos, dest.length);
		dest[0 .. numBytes] = memb.data[mPos .. mPos + numBytes];
		mPos += numBytes;
		return numBytes;
	}

	override uword write(void[] src)
	{
		auto t = currentThread(vm);
		pushRef(t, mVec);
		auto memb = getMembers!(VectorObj.Members)(t, -1);

		auto byteSize = memb.length * memb.type.itemSize;
		auto bytesLeft = byteSize - mPos;

		if(src.length > bytesLeft)
		{
			auto newByteSize = byteSize - bytesLeft + src.length;
			auto newSize = newByteSize / memb.type.itemSize;

			if((newSize * memb.type.itemSize) < newByteSize)
				newSize++;

			pushNull(t);
			pushInt(t, newSize);
			methodCall(t, -3, "опПрисвоитьДлину", 0);
		}
		else
			pop(t);

		memb.data[mPos .. mPos + src.length] = src[];
		mPos += src.length;
		return src.length;
	}

	override long seek(long offset, Anchor anchor = Anchor.Begin)
	{
		auto t = currentThread(vm);
		pushRef(t, mVec);
		auto memb = getMembers!(VectorObj.Members)(t, -1);
		pop(t);

		auto byteSize = memb.length * memb.type.itemSize;

		if(offset > byteSize)
			offset = byteSize;

		switch(anchor)
		{
			case Anchor.Begin:
				mPos = cast(uword)offset;
				break;

			case Anchor.End:
				mPos = cast(uword)(byteSize - offset);
				break;

			case Anchor.Current:
				auto off = cast(uword)(mPos + offset);

				if(off < 0)
					off = 0;

				if(off > byteSize)
					off = byteSize;

				mPos = off;
				break;

			default: assert(false);
		}

		return mPos;
	}
}

struct VectorInStreamObj
{
static:
	alias InStreamObj.Members Members;

	public void init(MDThread* t)
	{
		CreateClass(t, "ВекторныйВхоПоток", "ВхоПоток", (CreateClass* c)
		{
			c.method("конструктор", &constructor);
		});

		newFunction(t, &finalizer, "ВекторныйВхоПоток.финализатор");
		setFinalizer(t, -2);

		newGlobal(t, "ВекторныйВхоПоток");
	}

	uword finalizer(MDThread* t, uword numParams)
	{
		auto memb = cast(Members*)getExtraBytes(t, 0).ptr;

		if(!memb.closed)
		{
			memb.closed = true;
			removeRef(t, (cast(VectorConduit)memb.stream).mVec);
		}

		return 0;
	}

	public uword constructor(MDThread* t, uword numParams)
	{
		auto memb = InStreamObj.getThis(t);

		if(memb.stream !is null)
			throwException(t, "Attempting to call constructor on an already-initialized VectorInStream");

		checkInstParam(t, 1, "Вектор");

		pushNull(t);
		dup(t);
		pushNativeObj(t, new VectorConduit(getVM(t), createRef(t, 1)));
		pushBool(t, true);
		superCall(t, -4, "конструктор", 0);

		return 0;
	}
}

struct VectorOutStreamObj
{
static:
	alias OutStreamObj.Members Members;

	public void init(MDThread* t)
	{
		CreateClass(t, "ВекторныйВыхПоток", "ВыхПоток", (CreateClass* c)
		{
			c.method("конструктор", &constructor);
		});

		newFunction(t, &finalizer, "ВекторныйВыхПоток.финализатор");
		setFinalizer(t, -2);

		newGlobal(t, "ВекторныйВыхПоток");
	}

	uword finalizer(MDThread* t, uword numParams)
	{
		auto memb = cast(Members*)getExtraBytes(t, 0).ptr;

		if(!memb.closed)
		{
			memb.closed = true;
			removeRef(t, (cast(VectorConduit)memb.stream).mVec);
		}

		return 0;
	}

	public uword constructor(MDThread* t, uword numParams)
	{
		auto memb = OutStreamObj.getThis(t);

		if(memb.stream !is null)
			throwException(t, "Attempting to call constructor on an already-initialized VectorOutStream");

		checkInstParam(t, 1, "Вектор");

		pushNull(t);
		dup(t);
		pushNativeObj(t, new VectorConduit(getVM(t), createRef(t, 1)));
		pushBool(t, true);
		superCall(t, -4, "конструктор", 0);

		return 0;
	}
}

struct VectorInoutStreamObj
{
static:
	alias InoutStreamObj.Members Members;

	public void init(MDThread* t)
	{
		CreateClass(t, "ВекторныйПроток", "Проток", (CreateClass* c)
		{
			c.method("конструктор", &constructor);
		});

		newFunction(t, &finalizer, "ВекторныйПроток.финализатор");
		setFinalizer(t, -2);

		newGlobal(t, "ВекторныйПроток");
	}

	uword finalizer(MDThread* t, uword numParams)
	{
		auto memb = cast(Members*)getExtraBytes(t, 0).ptr;

		if(!memb.closed)
		{
			memb.closed = true;
			removeRef(t, (cast(VectorConduit)memb.conduit).mVec);
		}

		return 0;
	}

	public uword constructor(MDThread* t, uword numParams)
	{
		auto memb = InoutStreamObj.getThis(t);

		if(memb.conduit !is null)
			throwException(t, "Attempting to call constructor on an already-initialized VectorInoutStream");

		checkInstParam(t, 1, "Вектор");

		pushNull(t);
		dup(t);
		pushNativeObj(t, new VectorConduit(getVM(t), createRef(t, 1)));
		pushBool(t, true);
		superCall(t, -4, "конструктор", 0);

		return 0;
	}
}