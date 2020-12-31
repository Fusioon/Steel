using System;

using SteelEngine;

namespace BasicSteelGame
{
	class Program
	{
		static void Main(String[] args)
		{
			scope Application().Run(args, scope:: Game());
		}
	}
}