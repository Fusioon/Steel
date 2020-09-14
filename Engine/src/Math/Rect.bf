using System;

namespace SteelEngine
{
	[CRepr]
	public struct Rect<T> where T : IHashable, operator T+T
	{
		public T x, y;
		public T width, height;

		public T Top => y;
		public T Left => x;
		public T Right => x + width;
		public T Bottom => y + height;

		public this()
		{
			this = default;
		}	
	}
}
