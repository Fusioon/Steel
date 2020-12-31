using System;
using System.Collections;

using Bgfx;
using static Bgfx.bgfx;

namespace SteelEngine.Renderer.BGFX
{
	struct VertexLayoutData : IDisposable
	{
		public VertexLayout layout;
		//public VertexLayoutHandle handle;

		public void Dispose()
		{
			//bgfx.destroy_vertex_layout(handle);
		}
	}

	public static class VertexDescriptors
	{
		static Dictionary<Type, VertexLayout> _vertexLayouts = new .() ~ delete _;
		//static RIDOwner<VertexLayoutData> _layouts;

		public static VertexLayout* this[Type vertexType]
		{
			get => &_vertexLayouts[vertexType];
		}

		public static VertexLayout* Get(Type vertexType) => &_vertexLayouts[vertexType];

		
		public static VertexLayout* Get<T>() where T : struct
		{
			return Get(typeof(T));
		}

		public static Result<VertexLayout> Create<T>() where T : struct
		{
			return Create(typeof(T));
		}

		public static Result<VertexLayout> Create(Type vertexType)
		{
			if (_vertexLayouts.TryGetValue(vertexType, var layout))
			{
				return layout;
			}

			let fields = vertexType.GetFields(.Instance | .Public | .NonPublic);
			bool valid = true;
			bool notEmpty = false;
			bgfx.vertex_layout_begin(&layout, .Noop);

			for (let f in fields)
			{
				notEmpty = true;
				if (f.GetCustomAttribute<VertexUsageAttribute>() case .Ok(let val))
				{
					uint8 count = 0;
					AttribType type = .Count;
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
						vertex_layout_add(&layout, (Attrib)val.usage, count, type, normalize, false);
					}
					else
					{
						String name = scope .();
						vertexType.GetName(name);
						String fieldTypeName = scope .();
						f.FieldType.GetName(fieldTypeName);
						Log.Error($"Couldn't create vertex layout for type {name}, field {f.Name} is of unsupported type {fieldTypeName}.");
						valid = false;
						break;
					}
				}
				else
				{
					String name = scope .();
					vertexType.GetName(name);
					Log.Error($"Couldn't create vertex layout for type {name}, field {f.Name} doesn't contain VertexUsageAttribute.");
					valid = false;
					break;
				}
			}

			vertex_layout_end(&layout);
			if (valid && notEmpty)
			{
				_vertexLayouts[vertexType] = layout;
				return layout;
			}

			return .Err;
		}

	}
}
