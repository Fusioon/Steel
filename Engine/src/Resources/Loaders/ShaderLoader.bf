using System;
using System.IO;

namespace SteelEngine
{
	class ShaderLoader : ResourceLoader
	{
		public override Type ResourceType => typeof(Shader);

		static var EXTENSIONS = StringView[](".shader");
		public override Span<StringView> SupportedExtensions
		{
			get => .(&EXTENSIONS, EXTENSIONS.Count);
		}

		public override Result<Resource> Load(StringView absolutePath, StringView originalPath, Stream fileReadStream)
		{
			StreamReader reader = scope .(fileReadStream);
			String shaderPath = scope .();

			// @TODO - add error handling

			String vertShader, fragShader;
			{
				reader.ReadLine(shaderPath);

				StreamReader shaderReader = scope .();
				Resources.OpenRead(shaderPath, shaderReader);
				vertShader = new String();
				shaderReader.ReadToEnd(vertShader);
			}
			{
				shaderPath.Clear();
				reader.ReadLine(shaderPath);

				StreamReader shaderReader = scope .();
				Resources.OpenRead(shaderPath, shaderReader);
				fragShader = new String();
				shaderReader.ReadToEnd(fragShader);
			}
			
			return .Ok(new Shader(vertShader, fragShader));
		}

		public override bool HandlesType(Type type)
		{
			return type == typeof(Shader);
		}
	}
}
