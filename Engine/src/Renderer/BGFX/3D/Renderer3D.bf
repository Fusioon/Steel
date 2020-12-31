using System;
using SteelEngine.ECS.Components;
using static Bgfx.bgfx;

namespace SteelEngine.Renderer.BGFX
{
	enum SkyboxType
	{
		Cubemap,
		Dynamic
	}

	class Renderer3D
	{
		BgfxRenderServer _renderServer;

		BgfxCubemapSkybox _cubemapSkybox ~ delete _;
		BgfxDynamicSkybox _dynamicSkybox ~ delete _;
		SkyboxType _skyboxType;

		public this(BgfxRenderServer server)
		{
			_renderServer = server;
			_cubemapSkybox = new BgfxCubemapSkybox();
			_dynamicSkybox = new BgfxDynamicSkybox();

			_cubemapSkybox.Init(server);
			_dynamicSkybox.Init(32, 32, server);
		}

		public void PrepareFrame(Camera3D cam, float dt, uint16 viewId, Vector2i size)
		{
			ClearFlags clearFlags = .None;
			if (cam.clearFlags.HasFlag(.Color))
				clearFlags |= .Color;
			if (cam.clearFlags.HasFlag(.Depth))
				clearFlags |= .Depth;

			set_view_clear(viewId, clearFlags, *(uint32*)&cam.clearColor, 1, 1);
			set_view_rect(viewId, 0, 0, (.)size.x, (.)size.y);
			touch(viewId);

			Matrix44 view, proj;
			proj = cam.Projection;
			view = cam.View;

			set_view_transform(viewId, &view, &proj);

			if(cam.clearFlags.HasFlag(.Skybox))
			{
				switch(_skyboxType)
				{
				case .Cubemap:_cubemapSkybox.Draw(viewId);
				case .Dynamic: _dynamicSkybox.Draw(viewId);
				}
			}
		}

		public void RenderFrame(Camera3D cam, float dt, uint16 viewId)
		{

		}

		public void PostprocessFrame(Camera3D cam, float dt, uint16 viewId)
		{

		}
	}
}
