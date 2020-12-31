using System;
using System.Diagnostics;

namespace SteelEngine
{
	class Time
	{
		static Stopwatch s_stopwatch ~ delete _;

		protected static void Initialize()
		{
			TimeScale = 1.0f;

			StartTime = DateTime.Now;

			s_stopwatch = new Stopwatch();
			s_stopwatch.Start();
		}

		protected static float Update()
		{
			const let US_MULTIPLIER = 1 / 1000000.0f;
			float dt = s_stopwatch.ElapsedMicroseconds * US_MULTIPLIER;
			s_stopwatch.Restart();

			DeltaTime = dt * TimeScale;
			DeltaTimeUnscaled = dt;

			TimeSinceStart += DeltaTime;
			TimeSinceStartUnscaled += DeltaTimeUnscaled;
			return dt;
		}
		
		public static float TimeScale { get; set; }
		public static DateTime StartTime { get; private set; }
		public static float DeltaTime { get; private set; }
		public static float DeltaTimeUnscaled { get; private set; }
		public static float TimeSinceStart { get; private set; }
		public static float TimeSinceStartUnscaled { get; private set; }
	}
}
