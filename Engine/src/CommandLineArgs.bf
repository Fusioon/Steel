using System;
using System.Collections;

namespace SteelEngine
{
	public class CommandLineArgs :
		IEnumerable<(StringView key, StringView value)>
	{
		const char8 APP_COMMAND_START_CHAR = '-';
		const char8 CONSOLE_COMMAND_START_CHAR = '+';

		public Result<StringView> this[StringView name]
		{
			[Inline] get => _parsedArgs.TryGetValue(name, let val) ? StringView(val) : .Err;
		}

		List<String> _allocatedArgs = new .() ~  DeleteContainerAndItems!(_);
		Dictionary<StringView, StringView> _parsedArgs = new .() ~ delete _;
		Dictionary<StringView, StringView> _parsedGameConsoleArgs = new	.() ~ delete _;

		public decltype(_parsedGameConsoleArgs).Enumerator GameConsoleArgs => _parsedGameConsoleArgs.GetEnumerator();

		private void AddArg(Span<String> args, int start, int end)
		{
			Assert!(start != end);

			StringView name = args[start];
			let c = name[0];
			name = name.Substring(1);
			let length = end - start - 1;
			Assert!(length >= 0);

			StringView value = default;
			if(length == 1)
			{
				value = args[start+length];
			}
			else if(length >= 1)
			{
				String allocatedArg = new .();
				for(int i = start + 1; i < end; i++)
				{
					allocatedArg.Append(args[i]);
					allocatedArg.Append(' ');
				}
				allocatedArg.RemoveFromEnd(1);
				_allocatedArgs.Add(allocatedArg);
				value = allocatedArg;
			}

			if(c == CONSOLE_COMMAND_START_CHAR)
			{
				_parsedGameConsoleArgs.Add(name, value);
			}
			else
			{
				_parsedArgs.Add(name, value);
			}
		}

		public this(Span<String> args)
		{
			int i = 0;
			int lastCommandStart = i;
			for(i = 0; i < args.Length; i++)
			{
				let a = args[i];
				if(a.Length > 0)
				{
					let c = a[0];
					if(c == APP_COMMAND_START_CHAR || c == CONSOLE_COMMAND_START_CHAR)
					{
						if(i == lastCommandStart)
						{
							continue;
						}

						AddArg(args, lastCommandStart, i);
						lastCommandStart = i;
					}
				}	
			}
			if(i != lastCommandStart)
			{
				AddArg(args, lastCommandStart, i);
			}
		}

		public decltype(_parsedArgs).Enumerator GetEnumerator()
		{
			return _parsedArgs.GetEnumerator();
		}

	}
}
