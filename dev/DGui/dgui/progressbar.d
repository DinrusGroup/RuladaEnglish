﻿/*
	Copyright (c) 2011 Trogu Antonio Davide

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

module dgui.progressbar;

import dgui.control;

private const string WC_PROGRESSBAR = "msctls_progress32";
private const string WC_DPROGRESSBAR = "DProgressBar";

class ProgressBar: SubclassedControl
{
	private uint _minRange = 0;
	private uint _maxRange = 100;
	private uint _step = 10;
	private uint _position = 0;

	public uint minRange()
	{
		return this._minRange;
	}

	public void minRange(uint mr)
	{
		this._minRange = mr;

		if(this.created)
		{
			this.sendMessage(PBM_SETRANGE32, this._minRange, this._maxRange);
		}
	}
	
	public uint maxRange()
	{
		return this._maxRange;
	}

	public void maxRange(uint mr)
	{
		this._maxRange = mr;

		if(this.created)
		{
			this.sendMessage(PBM_SETRANGE32, this._minRange, this._maxRange);
		}
	}

	public uint step()
	{
		return this._minRange;
	}

	public void step(uint s)
	{
		this._step = s;

		if(this.created)
		{
			this.sendMessage(PBM_SETSTEP, this._step, 0);
		}
	}

	public uint position()
	{
		if(this.created)
		{
			return this.sendMessage(PBM_GETPOS, 0, 0);
		}
		
		return this._position;
	}

	public void position(uint p)
	{
		this._position = p;

		if(this.created)
		{
			this.sendMessage(PBM_SETPOS, p, 0);
		}
	}

	public void increment()
	{
		if(this.created)
		{
			this.sendMessage(PBM_STEPIT, 0, 0);
		}
		else
		{
			debug
			{
				throw new DGuiException("Cannot increment the progress bar", __FILE__, __LINE__);
			}
			else
			{
				throw new DGuiException("Cannot increment the progress bar");
			}
		}
	}

	protected override void preCreateWindow(ref PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_PROGRESSBAR;
		pcw.ClassName = WC_DPROGRESSBAR;

		assert(this._controlInfo.Dock is DockStyle.FILL, "ProgressBar: Invalid Dock Style");

		if(this._controlInfo.Dock is DockStyle.LEFT || this._controlInfo.Dock is DockStyle.RIGHT)
		{
			pcw.Style |= PBS_VERTICAL;
		}
		
		super.preCreateWindow(pcw);
	}
	
	protected override void onHandleCreated(EventArgs e)
	{
		this.sendMessage(PBM_SETRANGE32, this._minRange, this._maxRange);
		this.sendMessage(PBM_SETSTEP, this._step, 0);
		
		super.onHandleCreated(e);
	}
}