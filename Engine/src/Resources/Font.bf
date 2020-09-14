using System;
namespace SteelEngine
{
	public class Font : Resource
	{
		uint8[] _data;
		public Span<uint8> Data => _data;

	}
}
