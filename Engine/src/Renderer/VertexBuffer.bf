using System;

namespace SteelEngine.Renderer
{
	class VertexBuffer : RefCounted, IDisposable
	{
		public void Dispose()
		{
			ReleaseRef();
		}
	}
}
