using System;
using SteelEngine.Math;

namespace SteelEngine
{
	[CRepr, Union]
	struct Color4u : IHashable
	{
		typealias ValueType = uint8;
		public Vector4<ValueType> v;
		public ValueType[4] data;
		public ValueType red { [Inline] get => data[0]; [Inline] set mut => data[0] = value; }
		public ValueType green { [Inline] get => data[1]; [Inline] set mut => data[1] = value; }
		public ValueType blue { [Inline] get => data[2]; [Inline] set mut => data[2] = value; }
		public ValueType alpha { [Inline] get => data[3]; [Inline] set mut => data[3] = value; }

		public ValueType this[int i]
		{
			[Inline] get => data[i];
			[Inline] set mut => data[i] = value;
		}

		[Inline]
		public this()
		{
			this = default;
		}

		[Inline]
		public this(ValueType red, ValueType green, ValueType blue, ValueType alpha)
		{
			data = .(alpha, blue, green, red);
		}

		[Inline]
		public this(ValueType[4] v) : this(v[0], v[1], v[2], v[3])
		{
			data = .();
		}

		[Inline]
		public this(Vector4<ValueType> value) : this(value.x, value.y, value.z, value.w)
		{
			
		}

		[Inline] public Self AGBR => .(alpha, green, blue, red);
		[Inline] public Self ABGR => .(alpha, blue, green, red);
		[Inline] public Self ARGB => .(alpha, red, green, blue);

		[Inline]
		public static operator Vector4<ValueType>(Self v)
		{
			return v.v;
		}

		[Inline]
		public static operator Self(Vector4<ValueType> v)
		{
			return .(v.data);
		}

		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, data);
			return seed;
		}
	}

	[CRepr, Union]
	struct Color4f : IHashable
	{
		typealias ValueType = float;
		public Vector4<ValueType> v;
		public ValueType[4] data;
		public ValueType red { [Inline] get => data[0]; [Inline] set mut => data[0] = value; }
		public ValueType green { [Inline] get => data[1]; [Inline] set mut => data[1] = value; }
		public ValueType blue { [Inline] get => data[2]; [Inline] set mut => data[2] = value; }
		public ValueType alpha { [Inline] get => data[3]; [Inline] set mut => data[3] = value; }

		public ValueType this[int i]
		{
			[Inline] get => data[i];
			[Inline] set mut => data[i] = value;
		}

			[Inline]
		public this()
		{
			this = default;
		}

		[Inline]
		public this(ValueType red, ValueType green, ValueType blue, ValueType alpha = 1.0f)
		{
			data = .(red, green, blue, alpha);
		}

		[Inline]
		public this(ValueType[4] values)
		{
			data = values;
		}

		[Inline]
		public this(Vector4<ValueType> value)
		{
			v = value;
		}

		[Inline] public Self AGBR => .(alpha, green, blue, red);
		[Inline] public Self ABGR => .(alpha, blue, green, red);
		[Inline] public Self ARGB => .(alpha, red, green, blue);

		[Inline]
		public static operator Vector4<ValueType>(Self v)
		{
			return v.v;
		}

		[Inline]
		public static operator Self(Vector4<ValueType> v)
		{
			return .(v.data);
		}

		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, data);
			return seed;
		}


		[Inline]
		public static Self Lerp(Self v1, Self v2, ValueType value)
		{
			return .(v1.v.x + value * (v2.v.x - v1.v.x), v1.v.y + value * (v2.v.y - v1.v.y), v1.v.z + value * (v2.v.z - v1.v.z), v1.v.w + value * (v2.v.w - v1.v.w));
		}
	}
}
