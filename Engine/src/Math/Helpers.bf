using System;

namespace SteelEngine.Math
{
	public class Helpers
	{
		public static void HashCombine(ref int seed, int _hash)
		{
			int hash = _hash;
			hash += 0x9e3779b9 + (seed << 6) + (seed >> 2);
			seed ^= hash;
		}

		[Inline]
		public static bool IsEqualsApprox<T>(T v1, T v2)
			where bool : operator T < T where T : operator -T
			where T : operator explicit double, operator T * T, operator T - T
		{
			const double CMP_EPSILON = 0.00001;

			// Check exact value for infinity cases
			if (v1 == v2)
				return true;

			T tolerance = (Math.Abs(v1) * (T)CMP_EPSILON);
			if (tolerance < (T)CMP_EPSILON)
				tolerance = (T)CMP_EPSILON;

			return Math.Abs(v1 - v2) < tolerance;
		}
	}

	public static
	{
		public static mixin Deg2Rad(float deg)
		{
			float(deg / 180 * System.Math.PI_f)
		}
		public static mixin Rad2Deg(float rad)
		{
			float(rad / System.Math.PI_f * 180)
		}

		public static mixin Deg2Rad(double deg)
		{
			double(deg / 180 * System.Math.PI_d)
		}
		public static mixin Rad2Deg(double rad)
		{
			double(rad / System.Math.PI_d * 180)
		}
	}
}
