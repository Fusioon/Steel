using System;
using System.Collections;
using Bgfx;

namespace SteelEngine.Renderer.BGFX
{
	struct BgfxMesh : IDisposable
	{
		public Bgfx.VertexLayout* VertexLayout=> VertexDescriptors.Get(_vertexType);

		public bool IsValid { get; private set mut; }

		Type _vertexType;
		VertexBufferHandle _vertexBuffer;
		IndexBufferHandle _indexBuffer;
		uint32 _vertexCount;
		uint32 _indexCount;

		public this()
		{
			this = default;
		}

		public void Dispose()
		{
			Bgfx.DestroyVertexBuffer(_vertexBuffer);
			Bgfx.DestroyIndexBuffer(_indexBuffer);
		}

		public void SetBuffers()
		{
			Bgfx.SetVertexBuffer(0, _vertexBuffer, 0, _vertexCount);
			Bgfx.SetIndexBuffer(_indexBuffer, 0, _indexCount);
		}

		public Result<void> SetData(Type vertexType, void* vertices, uint32 vertexCount, uint16* indices, uint32 indexCount) mut
		{
			_vertexType = vertexType;
			if (VertexDescriptors.Create(vertexType) case .Ok(var layout))
			{
				{
					Memory* memory = Bgfx.Copy(vertices, (uint32)(vertexCount * (uint32)vertexType.Size));
					_vertexBuffer = Bgfx.CreateVertexBuffer(memory, &layout, 0);
					_vertexCount = vertexCount;
				}
				{
					Memory* memory = Bgfx.Copy(indices, indexCount * sizeof(uint16));
					_indexBuffer = Bgfx.CreateIndexBuffer(memory, 0);
					_indexCount = indexCount;
				}
				return .Ok;
			}

			return .Err;
		}

		public Result<void> SetData<TVertex>(Span<TVertex> vertices, Span<uint16> indices) mut
		{
			if (SetData(typeof(TVertex), vertices.Ptr, (uint32)vertices.Length, indices.Ptr, (uint32)indices.Length) case .Ok)
			{
				return .Ok;
			}
			
			return .Err;
		}

		static Vector3 GetVertexNormalFlatShaded(Vector3 v, Vector3 v1, Vector3 v2)
		{
			return Vector3.CrossProduct(v1 - v, v2 - v);
		}


		public static Self CreateFromMesh(Mesh m)
		{
			//_mesh.Load("res://models/cube.obj", true);
			PositionColorVertex[] vert = new:ScopedAlloc! .[m.vertexData.Count];
			uint16[] ind = new:ScopedAlloc! .[m.indexData.Count];

			for (int i = 0; i < vert.Count; i++)
			{
				var v = ref m.vertexData[i];
				//v.color = (.)gRand.NextI32();
				vert[i] = .(v.position, (.)v.color);
			}

			
			m.indexData.CopyTo(ind);
			
			return Self()..SetData<PositionColorVertex>(vert, ind);
		}

		public static Self CreateFromMeshWithNormals(Mesh m)
		{
			//_mesh.Load("res://models/cube.obj", true);
			PositionColorNormalVertex[] vert = new:ScopedAlloc! .[m.indexData.Count];
			uint16[] ind = new:ScopedAlloc! .[m.indexData.Count];

			for (int i = 0; i < vert.Count; i++)
			{
				let index = m.indexData[i];
				var v = ref m.vertexData[index];

				Vector3 norm = v.normal;
				vert[i] = .(v.position, norm, v.textureCoord, (.)v.color);

				ind[i] = (.)i;
			}

			
			//m.indexData.CopyTo(ind);
			
			return Self()..SetData<PositionColorNormalVertex>(vert, ind);
		}

	}
}
