using System;

using SteelEngine;
namespace SteelEngine.Renderer
{
	public abstract class Texture2D : Texture
	{
		/*RID _rid;
		public override RID ResourceId => _rid;*/

		protected uint32 _width = 0;
		protected uint32 _height = 0;
		protected uint32 _mipLevels = 1;
		protected PixelFormat _format;

		public virtual uint32 Width => _width;
		public virtual uint32 Height => _height
		public virtual uint32 MipLevels => _mipLevels
		public virtual PixelFormat Format => _format;
		public abstract Span<uint8> Data { get; }

		/*public abstract Result<void> Resize();*/

		/*public abstract void SetData(uint32 width, uint32 height, Span<uint8> data, PixelFormat format);
		public abstract void SetData(uint32 width, uint32 height, ref uint8[] data, PixelFormat format);*/

	}
}
