﻿/******************************************************************************
This module contains internal implementation of the weakref object.

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

module amigos.minid.weakref;

import amigos.minid.types;
import amigos.minid.utils;

struct weakref
{
static:
	// ================================================================================================================================================
	// Package
	// ================================================================================================================================================

	// Create a new weakref object.  Weak reference objects that refer to the same object are reused.  Thus,
	// if two weak references are identical, they refer to the same object.
	package MDWeakRef* create(MDVM* vm, MDBaseObject* obj)
	{
		if(auto r = vm.weakRefTab.lookup(obj))
			return *r;

		auto ret = vm.alloc.allocate!(MDWeakRef);
		ret.obj = obj;
		*vm.weakRefTab.insert(vm.alloc, obj) = ret;
		return ret;
	}

	// Free a weak reference object.
	package void free(MDVM* vm, MDWeakRef* r)
	{
		if(r.obj !is null)
		{
			auto b = vm.weakRefTab.remove(r.obj);
			assert(b);
		}

		vm.alloc.free(r);
	}

	package MDBaseObject* getObj(MDVM* vm, MDWeakRef* r)
	{
		return r.obj;	
	}
}