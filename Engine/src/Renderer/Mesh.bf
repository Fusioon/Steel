using System;
using System.Collections;
using SteelEngine.Math;

namespace SteelEngine.Renderer
{
	struct VertexData : IHashable
	{
		public Vector3 position;
		public Vector3 normal;
		public Vector2 textureCoord;
		public uint32 color;

		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, position.GetHashCode());
			Helpers.HashCombine(ref seed, textureCoord.GetHashCode());
			Helpers.HashCombine(ref seed, color.GetHashCode());
			return seed;
		}
	}

	class Mesh : Resource
	{
		List<VertexData> _vertexData ~ delete _;
		List<uint16> _indexData ~ delete _;

		public Span<VertexData> VertexData => _vertexData;
		public Span<uint16> IndexData => _indexData;

		public bool IsValid { get; private set; }

		Result<void> Load(StringView path, bool uniqueVerticesOnly = true)
		{
			String tmpPath = scope .(path);
			ResourceManager.GlobalizePath(tmpPath);

			tinyobj.ObjReader reader = scope .();

			if (reader.ParseFromFile(tmpPath) case .Err(let err))
			{
				if (!String.IsNullOrEmpty(reader.Errors))
					Log.Error(reader.Errors);

				Assert!(false);
				return .Err;
			}
			else if (!String.IsNullOrEmpty(reader.Warnings))
			{
				Log.Warning(reader.Warnings);
			}


			List<VertexData> vertices = new .();
			List<uint16> indices = new .();

			Dictionary<int, uint16> uniqueVertices = scope .();

			for (let shape in reader.shapes)
			{
				for (let index in shape.mesh.indices)
				{
					VertexData vertex = ?;
					vertex.position = .(reader.attrs.vertices[index.vertex_index].x,
						reader.attrs.vertices[index.vertex_index].y,
						reader.attrs.vertices[index.vertex_index].z);

					vertex.textureCoord = .(reader.attrs.texcoords[index.texcoord_index].x,
						1.0f - reader.attrs.texcoords[index.texcoord_index].y);

					vertex.color = 0xFFFFFFFF;
					vertex.normal = .Zero;

					if (uniqueVerticesOnly)
					{
						let hash = vertex.GetHashCode();

						uint16 value;
						if (!uniqueVertices.TryGetValue(hash, out value))
						{
							value = (.)vertices.Count;
							vertices.Add(vertex);
							uniqueVertices.Add(hash, value);
							
						}

						indices.Add(value);
					}
					else
					{
						indices.Add((uint16)vertices.Count);
						vertices.Add(vertex);
					}
				}
			}

			_vertexData = vertices;
			_indexData = indices;
			IsValid = true;
			return .Ok;
		}

		public this() : base()
		{
			
		}

		public this(List<VertexData> vertices, List<uint16> indices, bool copyData = false)
		{
			if (copyData)
			{
				_vertexData = new .()..AddRange(vertices.GetEnumerator());
				_indexData = new .()..AddRange(indices.GetEnumerator());
			}
			else
			{
				_vertexData = vertices;
				_indexData = indices;
			}
			IsValid = true;
		}

		public this(Span<VertexData> vertices, Span<uint16> indices)
		{
			_vertexData = new .(vertices.Length)..AddRange(vertices);
			_indexData = new .(indices.Length)..AddRange(indices);
			IsValid = true;
		}

		void Cleanup()
		{
			delete _vertexData;
			_vertexData = null;
			delete _indexData;
			_indexData = null;
		}

		public void SetData(List<VertexData> vertices, List<uint16> indices)
		{
			Cleanup();
			_vertexData = vertices;
			_indexData = indices;
		}

		[Inline]
		static Vector3 GetVertexNormalFlatShaded(Vector3 v, Vector3 v1, Vector3 v2)
		{
			return Vector3.CrossProduct(v1 - v, v2 - v);
		}
	}
}
