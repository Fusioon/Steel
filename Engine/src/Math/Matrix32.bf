using System;

namespace SteelEngine.Math
{
	[CRepr, Union]
	public struct Matrix32<T> 
		where T : operator T * T, operator T + T, operator T - T, operator T / T, operator -T, operator implicit float, operator explicit double
		where int : operator T <=> T
		where double : operator implicit T
	{
		public const let ROWS = 2;
		public const let COLUMNS = 3;
		public const let SIZE = ROWS * COLUMNS;

		public T[COLUMNS][ROWS] data2d;
		public T[SIZE] data;                          
		public Vector2<T>[COLUMNS] columns;

		public this()
		{
			this = default;
		}

		public this(T m00, T m01, T m02,
					T m10, T m11, T m12,
					T m20, T m21, T m22)
		{
			data = .(m00, m01, m02,
					m10, m11, m12);
		}

		public this(Vector2<T> c1, Vector2<T> c2, Vector2<T> c3)
		{
			columns = .(c1, c2, c3);
		}

		public T m00 { [Inline] get { return data[0]; } [Inline] set mut { data[0] = value; } }
		public T m01 { [Inline] get { return data[1]; } [Inline] set mut { data[1] = value; } }
		public T m02 { [Inline] get { return data[2]; } [Inline] set mut { data[2] = value; } }

		public T m10 { [Inline] get { return data[3]; } [Inline] set mut { data[3] = value; } }
		public T m11 { [Inline] get { return data[4]; } [Inline] set mut { data[4] = value; } }
		public T m12 { [Inline] get { return data[5]; } [Inline] set mut { data[5] = value; } }
	}
}
