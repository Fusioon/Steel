using System;
using Bgfx;

namespace SteelEngine.Renderer.BGFX
{
	class BgfxImageTexture : ImageTexture
	{
		protected bgfx.TextureHandle _textureHandle;

		public virtual  bgfx.TextureHandle TextureHandle => _textureHandle;

		public this(Image img) : base(img)
		{
		}

		public Result<void> Initialize()
		{
			_textureHandle = bgfx.create_texture_2d((uint16)_width, (uint16)_height, false, 1, .RGBA8, 0, null);
			return _textureHandle.Valid ? .Ok : .Err;
		}

		/*protected override void Delete()
		{
			Bgfx.DestroyTexture(_textureHandle);
			_textureHandle.idx = uint16.MaxValue;
		}

		public override Result<void> GenerateMipmaps(uint32 mipLevel)
		{
			return .Err;
		}
		public override Result<void> Compress(TextureCompression compression)
		{
			return default;
		}

		public override void FreeSystemMemory()
		{
			delete _data;
			_data = null;
		}*/

		/*public override Result<void> Resize()
		{
			return .Err;
		}*/

		/*public override Result<void> Apply()
		{
			if (_data == null || _data.IsEmpty)
				return .Err;

			_memoryUsage = (uint)_data.Count;
			let mem = Bgfx.Copy(_data.CArray(), (uint32)_data.Count);
			Bgfx.UpdateTexture2d(_textureHandle, 1, 1, 0, 0, (uint16)_width, (uint16)_height, mem, 0);
			return .Ok;
		}

		public override void SetData(uint32 width, uint32 height, ref uint8[] data, ImageFormat format)
		{
			_width = width;
			_height = height;
			_data = data;
			_format = format;
			data = null;
		}

		public override void SetData(uint32 width, uint32 height, System.Span<uint8> data, ImageFormat format)
		{
			var dataBuffer = new uint8[data.Length];
			data.CopyTo(dataBuffer);
			SetData(width, height, ref dataBuffer, format);
		}*/

		/*public override void SetData(uint32 width, uint32 height, Span<uint8> data, PixelFormat format)
		{

		}

		public override void SetData(uint32 width, uint32 height, ref uint8[] data, PixelFormat format)
		{

		}*/
		
	}
}
