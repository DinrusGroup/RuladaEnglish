﻿/******************************************************************************
This module contains the 'thread' standard library, which is part of the base
library.

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

module amigos.minid.threadlib;

import amigos.minid.ex;
import amigos.minid.interpreter;
import amigos.minid.types;
import amigos.minid.vm;

struct ThreadLib
{
static:
	public void init(MDThread* t)
	{
		makeModule(t, "нить", function uword(MDThread* t, uword numParams)
		{
			newFunction(t, &traceback, "трассировка"); newGlobal(t, "трассировка");
			newFunction(t, &halt,      "стой");      newGlobal(t, "стой");
			newFunction(t, &current,   "текущий");   newGlobal(t, "текущий");

			newNamespace(t, "нить");
				newFunction(t, &reset,       "сброс");       fielda(t, -2, "сброс");
				newFunction(t, &state,       "состояние");       fielda(t, -2, "состояние");
				newFunction(t, &isInitial,   "начальное_ли");   fielda(t, -2, "начальное_ли");
				newFunction(t, &isRunning,   "запущеное_ли");   fielda(t, -2, "запущеное_ли");
				newFunction(t, &isWaiting,   "ждущее_ли");   fielda(t, -2, "ждущее_ли");
				newFunction(t, &isSuspended, "приостановленное_ли"); fielda(t, -2, "приостановленное_ли");
				newFunction(t, &isDead,      "мёртвое_ли");      fielda(t, -2, "мёртвое_ли");
			setTypeMT(t, MDValue.Type.Thread);

			return 0;
		});

		importModuleNoNS(t, "нить");
	}

	uword traceback(MDThread* t, uword numParams)
	{
		getTraceback(t);
		return 1;
	}

	uword halt(MDThread* t, uword numParams)
	{
		if(numParams == 0)
			haltThread(t);
		else
		{
			checkParam(t, 1, MDValue.Type.Thread);
			auto thread = getThread(t, 1);
			// if thread is t, this immediately halts, otherwise it puts a pending halt on it
			haltThread(thread);
			auto reg = pushThread(t, thread);
			pushNull(t);
			rawCall(t, reg, 0);
		}

		return 0;
	}

	uword current(MDThread* t, uword numParams)
	{
		if(t is mainThread(getVM(t)))
			pushNull(t);
		else
			pushThread(t, t);

		return 1;
	}

	uword reset(MDThread* t, uword numParams)
	{
		checkParam(t, 0, MDValue.Type.Thread);

		if(optParam(t, 1, MDValue.Type.Function))
		{
			dup(t, 1);
			resetThread(t, 0, true);
		}
		else
			resetThread(t, 0);

		return 0;
	}

	uword state(MDThread* t, uword numParams)
	{
		checkParam(t, 0, MDValue.Type.Thread);
		pushString(t, .stateString(getThread(t, 0)));
		return 1;
	}

	uword isInitial(MDThread* t, uword numParams)
	{
		checkParam(t, 0, MDValue.Type.Thread);
		pushBool(t, .state(getThread(t, 0)) == MDThread.State.Initial);
		return 1;
	}

	uword isRunning(MDThread* t, uword numParams)
	{
		checkParam(t, 0, MDValue.Type.Thread);
		pushBool(t, .state(getThread(t, 0)) == MDThread.State.Running);
		return 1;
	}

	uword isWaiting(MDThread* t, uword numParams)
	{
		checkParam(t, 0, MDValue.Type.Thread);
		pushBool(t, .state(getThread(t, 0)) == MDThread.State.Waiting);
		return 1;
	}

	uword isSuspended(MDThread* t, uword numParams)
	{
		checkParam(t, 0, MDValue.Type.Thread);
		pushBool(t, .state(getThread(t, 0)) == MDThread.State.Suspended);
		return 1;
	}

	uword isDead(MDThread* t, uword numParams)
	{
		checkParam(t, 0, MDValue.Type.Thread);
		pushBool(t, .state(getThread(t, 0)) == MDThread.State.Dead);
		return 1;
	}
}