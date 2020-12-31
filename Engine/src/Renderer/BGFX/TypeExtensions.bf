using System;
using SteelEngine;

using Bgfx;
using static Bgfx.bgfx;

#if RENDERER_BGFX

using SteelEngine.Renderer.BGFX;


namespace SteelEngine.Renderer
{
	extension PixelFormat
	{
		public bgfx.TextureFormat BGFX
		{
			get
			{
				switch (this)
				{
				case .RGBA8: return .RGBA8;
				case .RGB8: return .RGB8;
				default: break;
				}
				Log.Warning($"BGFXPixelFormat returning Unknown for {this} format!");
				return .Unknown;
			}
		}
	}


	extension Shader
	{
		bgfx.ProgramHandle program;

		protected override Result<void> OnLoad()
		{
			
			return base.OnLoad();
		}
	}

	extension Texture2D
	{
		bgfx.TextureHandle hTexture;

		public static operator bgfx.TextureHandle(Self s)
		{
			return s.hTexture;
		}

		protected override Result<void> OnLoad()
		{
			let memory = bgfx.copy(Data.Ptr, (uint32)Data.Length);
			let tex = bgfx.create_texture_2d((uint16)Width, (uint16)Height, MipLevels > 1, 1, Format.BGFX, (.)SamplerFlags.None, memory);
			if (tex.Valid)
			{
				hTexture = tex;
				return .Ok;
			}
			return .Err;
		}

		protected override Result<void> OnUnload()
		{
			bgfx.destroy_texture(hTexture);
			return .Ok;
		}
	}

	extension Mesh
	{
		typealias VertexType = Vertex;

		bgfx.IndexBufferHandle hIndexBuffer;
		bgfx.VertexBufferHandle hVertexBuffer;
		uint32 indexCount;
		uint32 vertexCount;

		protected override Result<void> OnLoad()
		{
			//_mesh.Load("res://models/cube.obj", true);
			Vertex[] vert = new:ScopedAlloc! .[VertexData.Length];
			uint16[] ind = new:ScopedAlloc! .[IndexData.Length];

			for (int i = 0; i < vert.Count; i++)
			{
				var v = ref VertexData[i];
				// @TODO
				vert[i] = .(v.position, (.)v.color);
			}


			IndexData.CopyTo(ind);

			if (VertexDescriptors.Create<VertexType>() case .Ok(var layout))
			{
				{
					bgfx.Memory* memory = bgfx.copy(vert.CArray(), (uint32)(vertexCount * (uint32)sizeof(VertexType)));
					hVertexBuffer = bgfx.create_vertex_buffer(memory, &layout, 0);
					vertexCount = vertexCount;
				}
				{
					bgfx.Memory* memory = bgfx.copy(ind.CArray(), indexCount * sizeof(uint16));
					hIndexBuffer = bgfx.create_index_buffer(memory, 0);
					indexCount = indexCount;
				}
				return .Ok;
			}


			String b = scope .();
			typeof(VertexType).GetName(b);
			Log.Error(scope $"Failed to create vertex descriptor for type {b}");
			return .Err;
		}

		protected override Result<void> OnUnload()
		{
			bgfx.destroy_index_buffer(hIndexBuffer);
			bgfx.destroy_vertex_buffer(hVertexBuffer);
			return .Ok;
		}

		public void SetBuffers()
		{
			bgfx.set_index_buffer(hIndexBuffer, 0, indexCount);
			bgfx.set_vertex_buffer(0, hVertexBuffer, 0, vertexCount);
		}
	}
}

#endif
