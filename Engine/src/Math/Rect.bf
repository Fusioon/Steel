using System;

namespace SteelEngine
{
	[CRepr]
	public struct Rect<T> where T : IHashable, operator T+T
	{
		public T x, y;
		public T width, height;

		[Inline] public T Top => y;
		[Inline] public T Left => x;
		[Inline] public T Right => x + width;
		[Inline] public T Bottom => y + height;

		public this()
		{
			this = default;
		}	
	}
}
