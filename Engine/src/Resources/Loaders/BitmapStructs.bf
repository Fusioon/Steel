using System;

namespace SteelEngine.Loaders
{
	[CRepr, Ordered]
	struct BITMAPFILEHEADER
	{
		public uint16 id;
		public uint32 size;
		public uint32 reserved;
		public uint32 offset;
	}

	[CRepr, Ordered]
	struct BITMAPINFOHEADER
	{
		public uint32 header_size;
		public int32 width;
		public int32 height;
		public uint16 planes;
		public uint16 bits;
		public uint32 compression;
		public uint32 size;
		public int32 res_horizontal;
		public int32 res_vertical;
		public uint32 colors;
		public uint32 important_colors;

	}

	[CRepr, Ordered]
	struct PIXELDATA
	{
		public uint8 blue;
		public uint8 green;
		public uint8 red;
		public uint8 alpha;
		uint32 RGBBA => red | ((uint32)green << 8) | ((uint32)blue << 16) | ((uint32)alpha << 24);
		uint32 RGB => red | ((uint32)green << 8) | ((uint32)blue << 16);
	}
}
