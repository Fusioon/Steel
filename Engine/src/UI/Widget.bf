using System;
using System.Collections;

namespace SteelEngine.UI
{
	public abstract class Widget
	{
		protected String _name ~ delete _;
		public StringView Name => _name;
		protected List<Widget> _children;
		protected Rect _rect;


		protected this(String name)
		{
			_name = name;
		}
	}
}
