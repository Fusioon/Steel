using System;
using System.Diagnostics;

namespace SteelEngine
{
	public static
	{
		public static mixin Assert(bool condition)
		{
			Debug.Assert(condition);
		}

		public static mixin Assert(bool condition, String message)
		{
			Debug.Assert(condition, message);
		}

	}
}
