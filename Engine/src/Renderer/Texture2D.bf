using System;

namespace SteelEngine.Renderer
{
	public abstract class Texture2D : RefCounted, IDisposable
	{
		public abstract uint32 Width { get; }
		public abstract uint32 Height { get; }

		private ~this()
		{
			
		}

		public void Dispose()
		{
			ReleaseRef();
		}
	}
}
