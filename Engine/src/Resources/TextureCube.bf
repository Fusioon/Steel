using System;
namespace SteelEngine.Renderer.BGFX
{
	public abstract class TextureCube : Texture
	{
		public abstract uint32 Width { get; }
		public abstract uint32 Height { get; }

		public abstract Result<void> SetData(uint32 width, uint32 height, Span<uint8>[6] data);
		
	}
}
