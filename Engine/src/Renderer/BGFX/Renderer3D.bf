using System;

using Bgfx;

namespace SteelEngine.Renderer.BGFX
{
	class Renderer3D
	{
		RenderServer _renderServer;

		Renderable _cube;

		public Result<void> Init(RenderServer server)
		{
			_renderServer = server;

			/*_program = server.CreateProgram("shaders/fs_cubes.bin", "shaders/vs_cubes.bin");

			let vb = server.CreateVertexBuffer(.(&vertices, vertices.Count));
			let ib = server.CreateIndexBuffer(.(&indices, indices.Count));
			_cube = server.CreateRenderable("cube", vb, vertices.Count , ib, indices.Count);*/

			return .Ok;
		}

		public void Draw(uint32 width, uint32 height)
		{
			/*Matrix44 view, proj;
			view = .LookAt(.Zero, .(0, 0, -35.0f ), .Up);
			proj = .Perspective(51,(float) width / height, 0.001f, 1000);
			Bgfx.SetViewTransform(0, &view, &proj);*/

			// Submit 11x11 cubes.


		}
	}
}
