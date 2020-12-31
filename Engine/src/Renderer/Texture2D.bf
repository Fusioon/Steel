using System;

using SteelEngine;
namespace SteelEngine.Renderer
{
	public abstract class Texture2D : Texture
	{
		protected uint32 _width = 0;
		protected uint32 _height = 0;
		protected uint32 _mipLevels = 1;
		protected PixelFormat _format = .Unknown;

		public virtual uint32 Width => _width;
		public virtual uint32 Height => _height
		public virtual uint32 MipLevels => _mipLevels
		public virtual PixelFormat Format => _format;
		public abstract Span<uint8> Data { get; }

	}
}
