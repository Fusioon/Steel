using System;
using System.Collections;
namespace SteelEngine.Console
{
	class ExampleUsage
	{
		public static void Run()
		{
			GameConsole c = scope .();

			//let configFiles = scope String[]("config.cfg");
			c.Initialize(scope String[]("config.cfg"));

			int32 width, height;
			width = height = 0;

			c.RegisterVariable("r.width", "Width component of rendering resolution", ref width, .Config);
			c.RegisterVariable("r.height", "Height component of rendering resolution", ref height, .Config);

			bool b = false;
			int32 x = 5;
			int64 q = 6;
			float f = 7;
			String s = scope .("sad");
			CVarFlags flags = .Cheat;

			String buffer = scope .();
			
			let bv = c.RegisterVariable("sv.bool", "", ref b)..GetValueString(buffer);
			bv.GetType();
			let xv = c.RegisterVariable("sv.int32", "", ref x)..GetValueString(buffer);
			let qv = c.RegisterVariable("sv.int64", "", ref q)..GetValueString(buffer);
			let fv = c.RegisterVariable("sv.float", "", ref f)..GetValueString(buffer);
			let sv = c.RegisterVariable("sv.string", "", ref s)..GetValueString(buffer);
			let flv = c.RegisterVariable("sv.enum", "", ref flags)..GetValueString(buffer);

			c.Execute("sv.int32 16; sv.float 14.1;");
			c.Execute("sv.string \"wowo dsjakdas\"; sv.float 14.1;");
			c.Execute("sv.string \"\";dasd");
			c.Execute("echo halo you beautiful person; echo second command?;");

			c.History.Resize(100);

			String line = scope .();

			for (int i = 0; i < 50; i++)
			{
				c.History.At(i);
			}

			String buf = scope .();
			for (int i = 15000; i > 0; i--)
			{
				buf.Clear();
				i.ToString(buf);
				c.PrintInfo(buf);
				c.History.Add(buf);
			}

			c.History.Resize(200);
			for (int i = 0; i < 50; i++)
			{
				buf.Clear();
				i.ToString(buf);
				c.History.Add(buf);
			}

			c.History.Resize(5);
			c.History.Resize(500);
			for (int i = 0; i < 100; i++)
			{
				buf.Clear();
				i.ToString(buf);
				c.History.Add(buf);
			}
			c.History.Resize(10);

			for (int i = 0; i < 100; i++)
			{
				let h = c.History.At(i);
				if (!h.IsEmpty)
					Log.Info(h);
			}

			Time.[Friend]Initialize();

			while (true)
			{
				Time.[Friend]Update();

				line.Clear();
				Console.ReadLine(line).IgnoreError();
				if (line == "quit")
					break;

				c.Enqueue(line);
				c.Update();
			}

			x = 10;
			q = 50;
			f = 14.1f;
			//s = "dasdadas";

			flags = .Config;

			//StringView[1] asd = .("12");

			buffer.Append("  ");
			xv.GetValueString(buffer);
			qv.GetValueString(buffer);
			fv.GetValueString(buffer);
			sv.GetValueString(buffer);
			flv.GetValueString(buffer);
		}
	}
}
