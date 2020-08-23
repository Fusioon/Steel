using System;

namespace SteelEngine.Renderer
{
	class Mesh : RefCounted, IDisposable
	{
		protected Vertex[] _vertices;
		protected uint16[] _indices;

		public void Dispose()
		{
			ReleaseRef();
		}
	}
}
