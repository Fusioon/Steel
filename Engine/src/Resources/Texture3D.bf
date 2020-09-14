using System;

namespace SteelEngine.Renderer
{
	public abstract class Texture3D : Texture
	{
		public abstract uint32 Width { get; }
		public abstract uint32 Height { get; }
		public abstract uint32 Depth { get; }

		public abstract void SetData(uint32 width, uint32 height, uint32 depth, Span<uint8> data);
	}
}
