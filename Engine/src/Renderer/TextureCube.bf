using System;

namespace SteelEngine.Renderer
{
	public abstract class TextureCube : Texture
	{
		public abstract uint32 Width { get; }
		public abstract uint32 Height { get; }
		public abstract Texture2D[6] Textures { get; set; }
		public abstract Texture2D this[int i] { get; set; }

		public abstract Result<void> SetData(uint32 width, uint32 height, Span<uint8>[6] data);
	}
}
