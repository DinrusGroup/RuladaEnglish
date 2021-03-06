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

module dgui.listbox;

public import dgui.control;

const string WC_LISTBOX = "ListBox";
const string WC_DLISTBOX = "DListBox";

struct ListBoxInfo
{
	int SelectedIndex;
	Object SelectedItem;
}

class ListBox: OwnerDrawControl
{
	private Collection!(Object) _items;
	private ListBoxInfo _lbxInfo;

	public this()
	{
		super();

		this.setStyle(WS_BORDER, true);
	}

	public final int addItem(string s)
	{
		return this.addItem(new ObjectContainer!(string)(s));
	}

	public final int addItem(Object obj)
	{
		if(!this._items)
		{
			this._items = new Collection!(Object)();
		}

		this._items.add(obj);

		if(this.created)
		{
			return ListBox.insertItem(this, obj);
		}

		return this._items.length - 1;
	}

	public final void removeItem(int idx)
	{
		if(this.created)
		{
			this.sendMessage(LB_DELETESTRING, idx, 0);
		}

		this._items.removeAt(idx);
	}

	public final int selectedIndex()
	{
		if(this.created)
		{
			return this.sendMessage(LB_GETCURSEL, 0, 0);
		}

		return this._lbxInfo.SelectedIndex;
	}

	public final void selectedIndex(int i)
	{
		this._lbxInfo.SelectedIndex = i;

		if(this.created)
		{
			this.sendMessage(LB_SETCURSEL, i, 0);
		}
	}

	public final Object selectedItem()
	{
		int idx = this.selectedIndex;

		if(this._items)
		{
			return this._items[idx];
		}

		return null;
	}

	public final string selectedString()
	{
		Object obj = this.selectedItem;
		return (obj ? obj.toString() : null);
	}

	public final Collection!(Object) items()
	{
		return this._items;
	}

	private static int insertItem(ListBox lb, Object obj)
	{
		return lb.sendMessage(LB_ADDSTRING, 0, cast(LPARAM)toStringz(obj.toString()));
	}
	
	protected override void preCreateWindow(inout PreCreateWindow pcw)
	{
		pcw.OldClassName = WC_LISTBOX;
		pcw.ClassName = WC_DLISTBOX;
		pcw.DefaultBackColor = SystemColors.colorWindow;

		super.preCreateWindow(pcw);
	}

	protected override void onHandleCreated(EventArgs e)
	{
		if(this._items)
		{
			foreach(Object obj; this._items)
			{
				ListBox.insertItem(this, obj);
			}
		}

		super.onHandleCreated(e);
	}
}