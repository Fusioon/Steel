using Bgfx;
using System;
using System.Collections;
using static Bgfx.bgfx;

namespace SteelEngine.Renderer.BGFX
{
	class BgfxCubemapSkybox
	{
		ProgramHandle _shader;
		IndexBufferHandle _ibh;
		VertexBufferHandle _vhb;

		TextureCube _texture ~ _.UnrefSafe();


		public TextureCube Texture
		{
			get => _texture;
			set
			{
				_texture..UnrefSafe();
				_texture = value..AddRef();
			}
		}
		

		public void Init(BgfxRenderServer server)
		{
			_shader = server.GetShader("cubemap_skybox");
		}

		public void Draw(uint16 viewId)
		{
			//BgfxRenderServer.Instance.GetTextureHandle();
			Log.Error("BgfxCubemapSkybox not implemented!");
		}
	}

}
