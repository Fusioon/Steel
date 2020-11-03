using System;
using System.Collections;

using Bgfx;

namespace SteelEngine.Renderer.BGFX
{
	struct VertexLayoutData : IDisposable
	{
		public Bgfx.VertexLayout layout;

		public void Dispose()
		{

		}
	}

	public static class VertexDescriptors
	{
		static Dictionary<Type, Bgfx.VertexLayout> _vertexLayouts = new .() ~ delete _;
		static RIDOwner<VertexLayoutData> _layouts;

		public static Bgfx.VertexLayout* Get(Type vertexType) => &_vertexLayouts[vertexType];

		public static Result<Bgfx.VertexLayout> Create(Type vertexType)
		{
			if (_vertexLayouts.TryGetValue(vertexType, var layout))
			{
				return layout;
			}

			let fields = vertexType.GetFields(.Instance | .Public | .NonPublic);
			bool valid = true;
			bool notEmpty = false;

			Bgfx.VertexLayoutBegin(&layout, .Noop);

			for (let f in fields)
			{
				notEmpty = true;
				if (f.GetCustomAttribute<VertexUsageAttribute>() case .Ok(let val))
				{
					uint8 count = 0;
					Bgfx.AttribType type = .Count;
					switch (f.FieldType)
					{
					case typeof(Vector2):
						count = 2;
						type = .Float;
					case typeof(Vector3):
						count = 3;
						type = .Float;
					case typeof(Vector4):
						count = 4;
						type = .Float;
					case typeof(uint32),typeof(int32):
						count = 4;
						type = .Uint8;
					case typeof(uint16),typeof(int16):
						count = 2;
						type = .Uint8;
					}

					if (count > 0 && type != .Count)
					{
						bool normalize = type == .Uint8 ? true : false;
						Bgfx.VertexLayoutAdd(&layout, (Attrib)val.usage, count, type, normalize, false);
					}
					else
					{
						String name = scope .();
						vertexType.GetName(name);
						String fieldTypeName = scope .();
						f.FieldType.GetName(fieldTypeName);
						Log.Error("Couldn't create vertex layout for type {}, field {} is of unsupported type {}.", name, f.FieldType.GetName(fieldTypeName));
						valid = false;
						break;
					}
				}
				else
				{
					String name = scope .();
					vertexType.GetName(name);
					Log.Error("Couldn't create vertex layout for type {}, field {} doesn't contain VertexUsageAttribute.", name, f.Name);
					valid = false;
					break;
				}
			}

			Bgfx.VertexLayoutEnd(&layout);
			if (valid && notEmpty)
			{
				_vertexLayouts[vertexType] = layout;
				return layout;
			}

			return .Err;
		}

	}
}
