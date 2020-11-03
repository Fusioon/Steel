using System;

using Bgfx;

namespace SteelEngine.Renderer.BGFX
{
	class Renderer3D
	{
		BgfxRenderServer _renderServer;

		public Result<void> Init(BgfxRenderServer server)
		{
			_renderServer = server;

			return .Ok;
		}

		public void Draw(uint32 width, uint32 height)
		{
			


		}
	}
}
