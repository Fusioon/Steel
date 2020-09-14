using System;
using SteelEngine.Math;

namespace SteelEngine
{
	[CRepr]
	public struct Vector3<T> : IHashable where T : IHashable
	{
		public T[3] data;

		// Creates a new Vector with default values
		[Inline]
		public this()
		{
			data = default;
		}

		// Creates a new Vector and sets all components to v
		[Inline]
		public this(T v)
		{
		 	data = .(v, v, v);
		}

		// Creates a new Vector with given x, y components and sets z to default
		[Inline]
		public this(T x, T y)
		{
			data = .(x, y, default);
		}

		// Creates a new Vector with given x, y, z components
		[Inline]
		public this(T x, T y, T z)
		{
			data = .(x, y, z);
		}

		// Creates a new Vector with given array (0 = x, 1 = y, 2 = z)
		[Inline]
		public this(T[3] values)
		{
			data = values;
		}

		// Creates a new Vector with given x, y components and sets z to default
		[Inline]
		public this(Vector2<T> v2)
		{
			data = .(v2.x, v2.y, default);
		}

		public T x
		{
			[Inline] get => data[0];
			[Inline] set mut => data[0] = value;
		}

		public T y
		{
			[Inline] get => data[1];
			[Inline] set mut => data[1] = value;
		}

		public T z
		{
			[Inline] get => data[2];
			[Inline] set mut => data[2] = value;
		}

		public T this[int i]
		{
			[Inline] get => data[i];
			[Inline] set mut => data[i] = value;
		}

		[Inline]
		public Vector2<T> xy => .(x,y);

		[Inline]
		public static bool operator ==(Self value1, Self value2)
		{
		    return (value1.x == value2.x) &&
		        (value1.y == value2.y) &&
		        (value1.z == value2.z);
		}

		[Inline]
		public static bool operator !=(Self value1, Self value2)
		{
		    return !(value1 == value2);
		}

		public override void ToString(String str)
		{
		    str.AppendF("{0:0.0#}, {1:0.0#}, {2:0.0#}", x, y, z);
		}

		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, x.GetHashCode());
			Helpers.HashCombine(ref seed, y.GetHashCode());
			Helpers.HashCombine(ref seed, z.GetHashCode());
			return seed;
		}
	}

	public extension Vector3<T> where T : operator implicit int
	{
		[Inline] public static Self Zero=> .(0, 0, 0);
		[Inline] public static Self One=> .(1,1,1);

		[Inline] public static Self Left=> .(-1, 0, 0);
		[Inline] public static Self Right=> .(1, 0, 0);
		[Inline] public static Self Up=> .(0, 1, 0);
		[Inline] public static Self Down=> .(0, -1, 0);
		[Inline] public static Self Forward=> .(0, 0, -1);
		[Inline] public static Self Back=> .(0, 0, 1);
	}

	public extension Vector3<T>
		where T : operator implicit float
		where float : operator implicit T
	{
		[Inline] public static Self PositiveInfinity => .(float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity);
		[Inline] public static Self NegativeInfinity => .(float.NegativeInfinity, float.NegativeInfinity, float.NegativeInfinity);
	}

	public extension Vector3<T> 
		where T : operator implicit double
		where double : operator implicit T
	{
		[Inline] public static Self PositiveInfinity => .(double.PositiveInfinity, double.PositiveInfinity, double.PositiveInfinity);
		[Inline] public static Self NegativeInfinity => .(double.NegativeInfinity, double.NegativeInfinity, double.NegativeInfinity);
	}


	public extension Vector3<T> where T : operator T + T, operator T - T, operator T * T, operator T / T, operator -T
	{
		[Inline]
		public void operator+=(Self rv) mut
		{
			x += rv.x;
			y += rv.y;
			z += rv.z;
		}

		[Inline]
		public static Self operator+(Self lv, Self rv)
		{
			return .(lv.x + rv.x, lv.y + rv.y, lv.z + rv.z);
		}

		[Inline]
		public void operator+=(T rv) mut
		{
			x += rv;
			y += rv;
			z += rv;
		}

		[Inline, Commutable]
		public static Self operator+(Self lv, T rv)
		{
			return .(lv.x + rv, lv.y + rv, lv.z + rv);
		}

		[Inline]
		public static Self operator-(Self lv)
		{
			return .(-lv.x, -lv.y, -lv.z);
		}

		[Inline]
		public void operator-=(Self rv) mut
		{
			x -= rv.x;
			y -= rv.y;
			z -= rv.z;
		}

		[Inline]
		public static Self operator-(Self lv, Self rv)
		{
			return .(lv.x - rv.x, lv.y - rv.y, lv.z - rv.z);
		}

		[Inline]
		public void operator-=(T rv) mut
		{
			x -= rv;
			y -= rv;
			z -= rv;
		}

		[Inline, Commutable]
		public static Self operator-(Self lv, T rv)
		{
			return .(lv.x - rv, lv.y - rv, lv.z + rv);
		}

		[Inline]
		public void operator*=(Self rv) mut
		{
			x *= rv.x;
			y *= rv.y;
			z *= rv.z;
		}

		[Inline]
		public static Self operator*(Self lv, Self rv)
		{
		    return .(lv.x * rv.x, lv.y * rv.y, lv.z * rv.z);
		}

		[Inline]
		public void operator*=(T rv) mut
		{
			x *= rv;
			y *= rv;
			z *= rv;
		}

		[Inline, Commutable]
		public static Self operator*(Self lv, T rv)
		{
			return .(lv.x * rv, lv.y * rv, lv.z * rv);
		}

		[Inline]
		public void operator/=(Self rv) mut
		{
			x /= rv.x;
			y /= rv.y;
			z /= rv.z;
		}

		[Inline]
		public static Self operator/(Self lv, Self rv)
		{
			return .(lv.x / rv.x, lv.y / rv.y, lv.z / rv.z);
		}

		[Inline]
		public void operator/=(T rv) mut
		{
			x /= rv;
			y /= rv;
			z /= rv;
		}

		[Inline, Commutable]
		public static Self operator/(Self lv, T rv)
		{
			return .(lv.x / rv, lv.y / rv, lv.y / rv);
		}

		/// <returns>
		/// Squared length of this vector
		/// </returns>
		[Inline]
		public T LengthSquared=> x * x + y * y + z * z;
		
		/// <returns>
		/// Squared distance between two vectors
		/// </returns>
		[Inline]
		public static T DistanceSquared(Self v1, Self v2)
		{
			return (v1 - v2).LengthSquared;
		}

	}

	public extension Vector3<T> 
		where T : operator T * T, operator T + T, operator T - T, operator T / T, operator -T, operator implicit float, operator explicit double
		where int : operator T <=> T
		where double : operator implicit T
	{
		/// <returns>
		/// Magnitude of vector
		/// </returns>
		[Inline]
		public T Length => (T)System.Math.Sqrt(LengthSquared);

		/// <summary>
		/// Makes this vector have a magnitude of 1
		/// </summary>
		public T Normalize()	mut
		{
			let length = Length;
			let factor = 1 / length;
			x *= factor;
			y *= factor; 
			z *= factor;
			return length;
		}

		/// <returns>
		/// This vector with magnitude of 1
		/// </returns>
		public Self Normalized
		{
			[Inline]
			get
			{
				var tmp = this;
				return tmp..Normalize();
			}
		}

		/// <returns>
		/// Unsigned angle in radians between vectors
		/// </returns>
		public static T Angle(Self v1, Self v2)
		{
			let div = (v1.Length * v2.Length);
			// div can be 0 so we need to make sure we are not dividing by zero
			if (div == 0)
				return 0;
			let cosVal = DotProduct(v1, v2) / div;
			// cosVal > 1 the Acos will return NaN
			return (T)(cosVal > 1 ? 0 : Math.Acos(cosVal));
		}

		/// <returns>
		/// Distance between vectors
		/// </returns>
		[Inline]
		public static T Distance(Self v1, Self v2)
		{
			return (v1 - v2).Length;
		}

		/// <returns>
		/// Vector with magnitude clamped to value
		/// </returns>
		[Inline]
		public static Self ClampMagnitude(Self v, T value)
		{
			let length = v.Length;
			let factor = value / length;
			return .(v.x * factor, v.y * factor, v.z * factor);
		}

		[Inline]
		public static bool IsEqualsApprox(Self v1, Self v2)
		{
			return Helpers.IsEqualsApprox(v1.x, v2.x) && Helpers.IsEqualsApprox(v1.y, v2.y) && Helpers.IsEqualsApprox(v1.z, v2.z);
		}
	}

	public extension Vector3<T> where T : operator T + T, operator T - T, operator T * T, operator -T
	{
		/// <summary>
		///	Linearly interpolates between vectors by value
		/// </summary>
		/// <returns>
		///	Vector containing interpolated value
		/// </returns>
		[Inline]
		public static Self Lerp(Self v1, Self v2, T value)
		{
			return .(v1.x + value * (v2.x - v1.x), v1.y + value * (v2.y - v1.y), v1.z + value * (v2.z - v1.z));
		}

		/// <returns>
		/// Dot product of vectors
		/// </returns>
		[Inline]
		public static T DotProduct(Self v1, Self v2)
		{
			return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
		}

		/// <returns>
		/// Cross product of vectors
		/// </returns>
		[Inline]
		public static Self CrossProduct(Self v1, Self v2)
		{
			return .(v1.y * v2.z - v2.y * v1.z,
				-(v1.x * v2.z - v2.x * v1.z),
				v1.x * v2.y - v2.x * v1.y);
		}
	}

	public extension Vector3<T> where T : operator T <=> T
	{
		[Inline]
		public static Self Min(Self v1, Self v2)
		{
			return .(Math.Min(v1.x, v2.x), Math.Min(v1.y, v2.y), Math.Min(v1.z, v2.z));
		}

		[Inline]
		public static Self Max(Self v1, Self v2)
		{
			return .(Math.Max(v1.x, v2.x), Math.Max(v1.y, v2.y), Math.Max(v1.z, v2.z));
		}
	}
}
