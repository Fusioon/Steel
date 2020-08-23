using System;
using System.Collections;
using Bgfx;

namespace SteelEngine.Renderer.BGFX
{
	class BgfxMesh : Mesh
	{

		public Bgfx.VertexLayout* VertexLayout => _valid ? VertexDescriptors.Get(_vertexType) : null;
		public ProgramHandle shader;

		Type _vertexType;
		VertexBufferHandle _vertexBuffer;
		IndexBufferHandle _indexBuffer;
		uint32 _vertexCount;
		uint32 _indexCount;

		public this(StringView name)
		{
			_name = new .(name);
		}

		public void SetBuffers()
		{
			Bgfx.SetVertexBuffer(0, _vertexBuffer, 0, _vertexCount);
			Bgfx.SetIndexBuffer(_indexBuffer, 0, _indexCount);
		}

		protected override void Delete()
		{
			Bgfx.DestroyVertexBuffer(_vertexBuffer);
			Bgfx.DestroyIndexBuffer(_indexBuffer);
		}

		protected override Result<void> SetData(Type vertexType, void* vertices, uint32 vertexCount, uint16* indices, uint32 indexCount)
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
	}
}
