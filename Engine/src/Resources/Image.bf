using System;
using System.IO;
using SteelEngine.Renderer;

namespace SteelEngine
{
	class Image : Resource
	{
		public const int MAX_WIDTH = 16384;
		public const int MAX_HEIGHT = 16384;

		uint8[] _data ~ delete _;
		public Span<uint8> Data => .(_data);
		public uint32 Width { get; protected set; }
		public uint32 Height { get; protected set; }
		public PixelFormat Format { get; protected set; }
		public int MemorySize => _data?.Count ?? 0;
		public bool IsEmpty => MemorySize != 0;

		public this()
		{ 
			
		}

		public this(uint32 width, uint32 height, PixelFormat format, uint8[] data)
		{
			SetData(width, height, format, data);
		}

		public ~this()
		{
		}

		public Color4u GetPixel(uint32 x, uint32 y)
		{
			Color4u c;
			switch (Format)
			{
			case .RGBA8:
			{
				uint8* ptr = &_data[x + (Width * y)];
				c = .(*((uint8[4]*)ptr));
			}

			default:
				return default;
			}

			return c;
		}

		public void SetData(uint32 width, uint32 height, PixelFormat format, uint8[] data)
		{
			Cleanup();
			Assert!(width > 0 && width <= MAX_WIDTH);
			Assert!(height > 0 && height <= MAX_HEIGHT);
			Assert!(data != null && !data.IsEmpty);
			_data = data;
			Width = width;
			Height = height;
			Format = format;
		}


		void Cleanup()
		{
			Width = 0;
			Height = 0;
			Format = .Unknown;
			delete _data;
			_data = null;
		}
	}
}
