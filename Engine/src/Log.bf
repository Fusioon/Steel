using System.Collections;
using System.IO;
using System;
using System.Diagnostics;

namespace SteelEngine
{
	public delegate void LogCallback(LogLevel level, StringView message);

	public static class Log
	{
		public static LogLevel LogLevel = .Trace;

		private static List<StreamWriter> _handles = new .() ~ delete _;
		private static List<LogCallback> _callbacks = new .() ~ DeleteContainerAndItems!(_);

		public static void AddHandle(StreamWriter handle) => _handles.Add(handle);
		public static bool RemoveHandle(StreamWriter handle) => _handles.Remove(handle);

		public static void AddCallback(LogCallback cb) => _callbacks.Add(cb);
		public static bool RemoveCallback(LogCallback cb) => _callbacks.Remove(cb);
		 
		[Inline] public static void Trace(StringView message) => Print(.Trace, message);
		[Inline] public static void Info(StringView message) => Print(.Info, message);
		[Inline] public static void Warning(StringView message) => Print(.Warning, message);
		[Inline] public static void Error(StringView message) => Print(.Error, message);

		[Inline] public static void Trace(String message) => Trace(StringView(message));
		[Inline] public static void Info(String message) => Info(StringView(message));
		[Inline] public static void Warning(String message) => Warning(StringView(message));
		[Inline] public static void Error(String message) => Error(StringView(message));

		[Inline] public static void Trace<T>(T value) => Print(.Trace, value);
		[Inline] public static void Info<T>(T value) => Print(.Info, value);
		[Inline] public static void Warning<T>(T value) => Print(.Warning, value);
		[Inline] public static void Error<T>(T value) => Print(.Error, value);

		[Inline] public static void Trace(StringView format, params Object[] args) => Print(.Trace, format, params args);
		[Inline] public static void Info(StringView format, params Object[] args) => Print(.Info, format, params args);
		[Inline] public static void Warning(StringView format, params Object[] args) => Print(.Warning, format, params args);
		[Inline] public static void Error(StringView format, params Object[] args) => Print(.Error, format, params args);


		public static void Fatal(StringView message, String CallerName = Compiler.CallerMemberName, int CallerLine = Compiler.CallerLineNum, String CallerFilePath = Compiler.CallerFilePath)
		{
			var msg = scope String()..AppendF("{}\n{} ({}:{})", message, CallerName, CallerFilePath, CallerLine);
			Print(.Fatal, message);
			Runtime.FatalError(msg);
		}

		public static void Fatal(StringView format, params Object[] args)
		{
			var message = scope String()..AppendF(format, params args);
			Print(.Fatal, message);
			Runtime.FatalError(message);
		}

		private static void Print<T>(LogLevel level, T val)
		{
			String msg = scope String();
			val.ToString(msg);
			Print(level, StringView(msg));
		}

		private static void Print(LogLevel level, StringView format, params Object[] args)
		{
			String msg = scope String()..AppendF(format, params args);
			Print(level, msg);
		}

		private static void Print(LogLevel level, StringView message)
		{
			ConsoleColor color;

			switch (level)
			{
			case .Trace:
				color = .Gray;
				break;
			case .Info:
				color = .White;
				break;
			case .Warning:
				color = .Yellow;
				break;
			case .Error, .Fatal:
				color = .Red;
				break;
			}

			var origin = Console.ForegroundColor; // Store original color
			Console.ForegroundColor = color; // Set new color

			var time = scope String()..AppendF("{}:{}:{}", DateTime.Now.Minute, DateTime.Now.Second, DateTime.Now.Millisecond); // Format current time
			var line = scope String()..AppendF("[{}] {}: {}", time, level, message); // Format line to print

			// Print the line to all handles
			for (var handle in _handles)
				handle.WriteLine(line);

			for (var cb in _callbacks)
				cb(level, message);

			Console.ForegroundColor = origin; // Set color back to original
		}
	}
}
