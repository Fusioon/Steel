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

	}

	public abstract class Texture : RefCounted, IDisposable
	{
		public abstract uint32 MipLevels { get; }

		public virtual uint MemoryUsage => 0;
		public abstract TextureFormat Format { get; }

		protected ~this()
 		{
			 Delete();
		}

		protected abstract void Delete();

		public void Dispose()
		{
			ReleaseRef();
		}

		public abstract Result<void> Apply();

		public abstract Result<void> Compress(TextureCompression compression);

		public abstract Result<void> GenerateMipmaps(uint32 mipLevel);

		public abstract void FreeSystemMemory();
	}
}
