using System;
using System.IO;
using System.Collections;
using SteelEngine.Renderer;


namespace SteelEngine
{
	class MaterialLoader : ResourceLoader
	{
		StringView[] _extensions = new StringView[](".mat") ~ delete _;

		public override Type ResourceType => typeof(Mesh);

		public override Span<StringView> SupportedExtensions => _extensions;

		public override Result<Resource> Load(StringView absolutePath, StringView originalPath, Stream fileReadStream)
		{
			StreamReader reader = scope .(fileReadStream);
			String buffer = scope .();
			reader.ReadLine(buffer);

			if(Resources.Load<Shader>(buffer) case .Ok(let shader))
			{
				reader.ReadLine(buffer..Clear());
				if(Resources.Load<Image>(buffer) case .Ok(let colorTex))
				{
					reader.ReadLine(buffer..Clear());
					if(Resources.Load<Image>(buffer) case .Ok(let normTex))
					{
						return new Material(shader)
						{
						  	colorTex = Resources.CreateSharedResource<ImageTexture, Image>(colorTex),
							normTex = Resources.CreateSharedResource<ImageTexture, Image>(normTex)
						};
					}
					return new Material(shader)
					{
						colorTex = Resources.CreateSharedResource<ImageTexture, Image>(colorTex),
					};
				}
				shader.DisposeSafe();
			}

			return .Err;
		}

		public override bool HandlesType(Type type)
		{
			return type == typeof(Material);
		}
	}
}
