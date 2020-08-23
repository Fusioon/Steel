using System;

using SteelEngine;
namespace SteelEngine.Renderer
{
	public abstract class Texture2D : Texture
	{
		protected uint8[] _data ~ delete _;
		protected TextureFormat _dataFormat;

		protected uint32 _width = 0;
		protected uint32 _height = 0;
		protected uint32 _mipLevels = 1;
		protected TextureFormat _format;

		public virtual uint32 Width => _width;
		public virtual uint32 Height => _height
		public override uint32 MipLevels => _mipLevels
		public override TextureFormat Format => _format;

		public abstract Result<void> Resize();

		public abstract void SetData(uint32 width, uint32 height, Span<uint8> data, TextureFormat format);
		public abstract void SetData(uint32 width, uint32 height, ref uint8[] data, TextureFormat format);
	}
}
