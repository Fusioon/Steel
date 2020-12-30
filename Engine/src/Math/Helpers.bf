using System;

namespace SteelEngine.Math
{
	public class Helpers
	{
		[Inline]
		public static void HashCombine(ref int seed, int _hash)
		{
			int hash = _hash;
			hash += 0x9e3779b9 + (seed << 6) + (seed >> 2);
			seed ^= hash;
		}

		[Inline]
		public static void HashCombine<T, N>(ref int seed, T[N] values)
			where T : IHashable
			where N : const int
		{
			for(int i = 0; i < N; i++)
				HashCombine(ref seed, values[i].GetHashCode());
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

namespace System
{
	extension Math
	{
		public static float SmoothDamp(float current, float target, ref float currentVelocity, float smoothTime, float maxVelocity, float deltaTime)
		{
			var smoothTime, target;

			smoothTime = Math.Max (0.0001f, smoothTime);
			float num = 2f / smoothTime;
			float num2 = num * deltaTime;
			float num3 = 1f / (1f + num2 + 0.48f * num2 * num2 + 0.235f * num2 * num2 * num2);
			float num4 = current - target;
			float num5 = target;
			float num6 = maxVelocity * smoothTime;
			num4 = Math.Clamp (num4, -num6, num6);
			target = current - num4;
			float num7 = (currentVelocity + num * num4) * deltaTime;
			currentVelocity = (currentVelocity - num * num7) * num3;
			float num8 = target + (num4 + num7) * num3;
			if (num5 - current > 0f == num8 > num5)
			{
			    num8 = num5;
			    currentVelocity = (num8 - num5) / deltaTime;
			}
			return num8;
		}

		
	}
}