using System;
using System.IO;

using SteelEngine.Console;
namespace SteelEditor
{
	class Program
	{
		static void Main(String[] args)
		{
			String asd = scope String();
			Path.GetTempPath(asd);
			Path.GetTempFileName(asd);
			//SteelEngine.Assets.[Friend]Initialize(default);
			SteelEngine.Log.AddHandle(System.Console.Out);
			ExampleUsage.Run();
		}
	}
}
