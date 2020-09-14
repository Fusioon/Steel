using System;

namespace SteelEngine.Math
{
	[CRepr]
	public struct Point<T>
	{
		public T x, y;

		public this()
		{
			this = default;
		}

		public this(T _x, T _y)
		{
			x = _x;
			y = _y;
		}
	}
}
