using System;
using System.IO;
using System.Collections;

using SteelEngine.Renderer;

namespace SteelEngine.Resources.Loaders
{
	public class MeshLoader : ResourceLoader<Mesh>
	{
		static let EXTENSIONS = new StringView[](".obj") ~ delete _;
		public override Span<StringView> SupportedExtensions => EXTENSIONS;

		public override Result<void> Load(StringView absolutePath, StringView originalPath, Stream fileReadStream, Mesh r_mesh)
		{
			tinyobj.ObjReader reader = scope .();

			if (reader.ParseFromStream(fileReadStream) case .Err(let err))
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
					vertex.normal = *(Vector3*)&reader.attrs.normals[index.normal_index];
					
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
			}

			r_mesh.SetData(vertices, indices);
			return .Ok;
		}
	}
}
