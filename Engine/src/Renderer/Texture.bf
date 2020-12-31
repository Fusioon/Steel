using System;

namespace SteelEngine.Renderer
{
	public enum TextureCompression
	{
		None = 0,
		LowQuality,
		MediumQuality,
		HighQuality
	}

	public enum TextureWrapMode
	{
		Repeat,
		Clamp,
		Mirror,
	}

	public abstract class Texture : Resource
	{
		
	}
}
