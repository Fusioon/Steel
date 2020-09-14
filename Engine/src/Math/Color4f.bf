using System;

namespace SteelEngine.Math
{
	[CRepr]
	struct Color4<T> where T : struct, IHashable
	{
		public T[4] data;
		public T red { get => data[0]; set mut => data[0] = value; }
		public T green { get => data[1]; set mut => data[1] = value; }
		public T blue { get => data[2]; set mut => data[2] = value; }
		public T alpha { get => data[3]; set mut => data[3] = value; }

		public T this[int i]
		{
			get => data[i];
			set mut => data[i] = value;
		} 

		public this()
		{
			this = default;
		}

		public this(T red, T green, T blue, T alpha)
		{
			data = .(red, green, blue, alpha);
		}

		public this(T[4] values)
		{
			data = values;
		}

		public Self AGBR => .(alpha, green, blue, red);
		public Self ABGR => .(alpha, blue, green, red);
		public Self ARGB => .(alpha, red, green, blue);


		public static operator Vector4<T>(Self v)
		{
			return .(v.data);
		}

		public static operator Self(Vector4<T> v)
		{
			return .(v.data);
		}
	}

	extension Color4<T> where T : operator implicit float
	{
		public static Self White => .(1f, 1f, 1f, 1f);
		public static Self Black => .(0f, 0f, 0f, 1f);
	}
}
