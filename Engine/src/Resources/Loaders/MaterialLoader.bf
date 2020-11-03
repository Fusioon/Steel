using System;
using System.IO;
using System.Collections;
using SteelEngine.Renderer;


namespace SteelEngine
{
	class MaterialLoader : ResourceLoader<Material>
	{
		/*static var EXTENSIONS = StringView[](".mat");

		public override Span<StringView> SupportedExtensions => .(&EXTENSIONS, EXTENSIONS.Count);*/

		public override Span<StringView> SupportedExtensions => default;

		public override Result<void> Load(StringView absolutePath, StringView originalPath, Stream fileReadStream, Material r_material)
		{
			StreamReader reader = scope .(fileReadStream);
			String buffer = scope .();
			reader.ReadLine(buffer);

			if(ResourceManager.Load<Shader>(buffer) case .Ok(let shader))
			{
				reader.ReadLine(buffer..Clear());
				if(ResourceManager.Load<Image>(buffer) case .Ok(let colorTex))
				{
					reader.ReadLine(buffer..Clear());
					if(ResourceManager.Load<Image>(buffer) case .Ok(let normTex))
					{
						/*r_material.colorTex = ResourceManager.CreateSharedResource<ImageTexture, Image>(colorTex);
						r_material.normTex = ResourceManager.CreateSharedResource<ImageTexture, Image>(normTex);*/

						return .Ok;
					}

					//r_material.colorTex = ResourceManager.CreateSharedResource<ImageTexture, Image>(colorTex);
					return .Ok;
				}
				shader.UnrefSafe();
			}

			return .Err;
		}

	}
}
