using System;
using Bgfx;
using SteelEngine;
using SteelEngine.ECS.Components;

namespace SteelEngine.Renderer.BGFX
{
	[Reflect(.All), AlwaysInclude]
	struct SpriteVertex
	{
		[VertexUsage(.Position)]
		public Vector2 pos;

		public this(float x, float y)
		{
			pos = .(x, y);
		}

		/*[VertexUsage(.TexCoord0)]
		public Vector2 texCoord;

		[VertexUsage(.Color0)]
		public Color4u color;*/
	}

	/*struct SpriteData
	{
		public const uint16 INDEX_COUNT = 6;
		public const uint16 VERTEX_COUNT = 4;

		public bgfx.VertexBufferHandle hVertexBuffer;
	}

	struct BgfxSprite : IDisposable
	{
		public bgfx.VertexBufferHandle hVertexBuffer;

		public void Dispose()
		{
			bgfx.destroy_vertex_buffer(hVertexBuffer);
		}
	}*/

	class Renderer2D 
	{
		public const uint16 INDEX_COUNT = 6;
		public const uint16 VERTEX_COUNT = 4;

		BgfxRenderServer _renderServer;
		bgfx.ProgramHandle _spriteShader;

		//RIDOwner<SpriteData> _spriteData = new RIDOwner<SpriteData>();

		bgfx.IndexBufferHandle _hIndexBuffer;
		bgfx.VertexBufferHandle _hVertexBuffer;


		bgfx.UniformHandle _uView;
		//bgfx.UniformHandle _uProj;
		bgfx.UniformHandle _uViewProj;
		bgfx.UniformHandle _uModelViewProj;
		bgfx.UniformHandle _uModel;

		bgfx.UniformHandle _uTexCoord;
		bgfx.UniformHandle _uTexColor;

		Matrix44 _viewProj;

		public this(BgfxRenderServer _server)
		{
			//ResourceManager.RegisterResourceUpdateHandler<Sprite>(this);

			_renderServer = _server;
			_spriteShader = _renderServer.GetShader("sprite");

			{
				uint16[6] indexBuffer = .(0, 1, 2, 1, 3, 2);
				const let INDEX_BUFFER_SIZE = sizeof(decltype(indexBuffer));
				let mem = bgfx.copy(&indexBuffer, INDEX_BUFFER_SIZE);
				_hIndexBuffer = bgfx.create_index_buffer(mem, 0);
			}
			{
				SpriteVertex[4] vertices = .(.(0,0), .(1, 0), .(0, 1), .(1,1));
				const let VERTEX_BUFFER_SIZE = sizeof(decltype(vertices));
				let mem = bgfx.copy(&vertices, VERTEX_BUFFER_SIZE);
				VertexDescriptors.Create<SpriteVertex>();
				_hVertexBuffer = bgfx.create_vertex_buffer(mem, VertexDescriptors.Get<SpriteVertex>(), 0);
			}

			/*_uView = bgfx.create_uniform("view", .Mat4, 1);
			_uViewProj = bgfx.create_uniform("viewProj", .Mat4, 1);
			_uModelViewProj = bgfx.create_uniform("modelViewProj", .Mat4, 1);
			_uModel = bgfx.create_uniform("model", .Mat4, 1);*/

			_uTexCoord = bgfx.create_uniform("texCoord", .Vec4, 1);
			_uTexColor = bgfx.create_uniform("s_texColor", .Sampler, 1);
		}

		public ~this()
		{
			bgfx.destroy_index_buffer(_hIndexBuffer);
			bgfx.destroy_vertex_buffer(_hVertexBuffer);

			/*bgfx.destroy_uniform(_uViewProj);
			bgfx.destroy_uniform(_uModelViewProj);
			bgfx.destroy_uniform(_uModel);*/
			bgfx.destroy_uniform(_uTexCoord);
			bgfx.destroy_uniform(_uTexColor);
		}

		public void DrawSprite(Vector2 pos, float rot, Vector2 scale, Sprite sprite, uint16 viewId)
		{
			/*bgfx.set_uniform(_uModel, &modelMatrix, 1);
			modelMatrix *= _viewProj;
			bgfx.set_uniform(_uModelViewProj, &modelMatrix, 1);*/

			let size = Vector2(sprite.Texture.Width, sprite.Texture.Height);
			let r = sprite.Rectangle;

			Vector4 textureCoord = ?; //.(r.x / size.x, r.y / size.y, r.Right, r.Bottom);
			textureCoord.x = r.Left / size.x;
			textureCoord.y = r.Top / size.y;
			textureCoord.z = r.Right / size.x - textureCoord.x;
			textureCoord.w = r.Bottom / size.y - textureCoord.y;
			bgfx.set_uniform(_uTexCoord, &textureCoord, 1);

			Matrix44 modelMatrix = .Transform(.(pos.x, pos.y, 0), .FromEulerAngles(0, 0, rot), .(scale.x, scale.y, 1));
			bgfx.set_transform(&modelMatrix, 1);

			bgfx.set_index_buffer(_hIndexBuffer, 0, INDEX_COUNT);
			bgfx.set_vertex_buffer(0, _hVertexBuffer, 0, VERTEX_COUNT);

			bgfx.set_texture(0, _uTexColor, sprite.Texture, .MinPoint | .MagPoint | .MipPoint | .UClamp | .VClamp);

			bgfx.submit(viewId, _spriteShader, 0, .None);
		}

		void PrepareFrame(uint16 viewId, Camera2D cam)
		{
			var view = cam.View, proj = cam.Proj;
			bgfx.set_view_transform(viewId, &view, &proj);
			bgfx.set_view_clear(viewId, .Color | .Depth, *(uint32*)&cam.clearColor, 1, 0xFF);
			bgfx.set_view_rect(viewId, 0, 0, (uint16)cam.Size.x, (uint16)cam.Size.y);
			bgfx.set_uniform(_uViewProj, &_viewProj, 1);

			bgfx.touch(viewId);
			
			bgfx.set_state(.WriteRgb | bgfx.blend_function(.BlendSrcAlpha, .BlendInvSrcAlpha), 0);
		}

		public void DrawFrame(uint16 viewId, Camera2D cam, Span<Sprite> sprites, Span<Transform2D> transforms)
		{
			PrepareFrame(viewId, cam);

			Assert!(sprites.Length == transforms.Length);

			for(int i < sprites.Length)
			{
				let t = ref transforms[i];
				DrawSprite(t.position, t.rotation, t.scale, sprites[i], viewId);
			}

		}


		/*void IResourceEventHandler<Sprite>.Load(Sprite sprite)
		{
			/*SpriteVertex[4] vertices = ?;

			let width = sprite.Texture.Width;
			let height = sprite.Texture.Width;
			Assert!(width != 0);
			Assert!(height != 0);

			let rect = sprite.Rectangle;

			vertices[0] = .()
				{
					pos = .(0, 0),
					texCoord = .((float)rect.Left / width, (float)rect.Top / height),
					color = .(255, 255, 255, 255)
				};
			vertices[1] = .()
				{
					pos = .(1, 0),
					texCoord = .((float)rect.Right / width, (float)rect.Top / height),
					color = .(255, 255, 255, 255)
				};
			vertices[2] = .()
				{
					pos = .(0, 1),
					texCoord = .((float)rect.Left / width, (float)rect.Bottom / height),
					color = .(255, 255, 255, 255)
				};
			vertices[3] = .()
				{
					pos = .(1, 1),
					texCoord = .((float)rect.Right / width, (float)rect.Bottom / height),
					color = .(255, 255, 255, 255)
				};

			let layout = VertexDescriptors.Get<SpriteVertex>();

			const let VERTICES_SIZE = sizeof(decltype(vertices));
			let mem = bgfx.copy(&vertices, VERTICES_SIZE);
			SpriteData sd = ?;
			sd.hVertexBuffer = bgfx.create_vertex_buffer(mem, layout, 0);
			sprite.[Friend]ResourceId = _spriteData.MakeRID(sd);*/
		}

		void IResourceEventHandler<Sprite>.Unload(Sprite resource)
		{
			//_spriteData.Free(resource);
		}*/
	}
}
