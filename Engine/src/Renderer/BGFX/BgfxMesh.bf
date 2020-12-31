using System;
using System.Collections;
using Bgfx;

namespace SteelEngine.Renderer.BGFX
{
	struct BgfxMesh
	{
		public bgfx.VertexLayout* VertexLayout=> VertexDescriptors.Get(_vertexType);

		//public bool IsValid { get; private set mut; }

		Type _vertexType;
		bgfx.VertexBufferHandle _vertexBuffer;
		bgfx.IndexBufferHandle _indexBuffer;
		uint32 _vertexCount;
		uint32 _indexCount;

		/*protected override Result<void> OnUnload()
		{
			bgfx.destroy_vertex_buffer(_vertexBuffer);
			bgfx.destroy_index_buffer(_indexBuffer);
			return .Ok;
		}*/

		public void SetBuffers()
		{
			bgfx.set_vertex_buffer(0, _vertexBuffer, 0, _vertexCount);
			bgfx.set_index_buffer(_indexBuffer, 0, _indexCount);
		}

		public Result<void> SetData(Type vertexType, void* vertices, uint32 vertexCount, uint16* indices, uint32 indexCount) mut
		{
			_vertexType = vertexType;
			if (VertexDescriptors.Create(vertexType) case .Ok(var layout))
			{
				{
					bgfx.Memory* memory = bgfx.copy(vertices, (uint32)(vertexCount * (uint32)vertexType.Size));
					_vertexBuffer = bgfx.create_vertex_buffer(memory, &layout, 0);
					_vertexCount = vertexCount;
				}
				{
					bgfx.Memory* memory = bgfx.copy(indices, indexCount * sizeof(uint16));
					_indexBuffer = bgfx.create_index_buffer(memory, 0);
					_indexCount = indexCount;
				}
				return .Ok;
			}

			return .Err;
		}

		public Result<void> SetData<TVertex>(Span<TVertex> vertices, Span<uint16> indices) mut => SetData(typeof(TVertex), vertices.Ptr, (uint32)vertices.Length, indices.Ptr, (uint32)indices.Length);

		public static Self CreateFromMesh(Mesh m)
		{
			//_mesh.Load("res://models/cube.obj", true);
			Vertex[] vert = new:ScopedAlloc! .[m.VertexData.Length];
			uint16[] ind = new:ScopedAlloc! .[m.IndexData.Length];

			for (int i = 0; i < vert.Count; i++)
			{
				var v = ref m.VertexData[i];
				//v.color = (.)gRand.NextI32();
				vert[i] = .(v.position, (.)v.color);
			}

			
			m.IndexData.CopyTo(ind);
			
			return Self()..SetData<Vertex>(vert, ind);
		}

		public static Self CreateFromMeshWithNormals(Mesh m)
		{
			//_mesh.Load("res://models/cube.obj", true);
			Vertex[] vert = new:ScopedAlloc! .[m.IndexData.Length];
			uint16[] ind = new:ScopedAlloc! .[m.IndexData.Length];

			for (int i = 0; i < vert.Count; i++)
			{
				let index = m.IndexData[i];
				var v = ref m.VertexData[index];

				vert[i] = .()
				{
					pos = v.position,
					normal = v.normal,
				};

				ind[i] = (.)i;
			}

			
			m.IndexData.CopyTo(ind);
			
			return Self()..SetData<Vertex>(vert, ind);
		}

	}
}
