using System;

namespace Launcher
{
	class Program
	{
		public static int Main(String[] args)
		{
			scope SteelEngine.Application()..Run(args, scope BasicSteelGame.GameImpl());
			return 0;
		}
	}
}