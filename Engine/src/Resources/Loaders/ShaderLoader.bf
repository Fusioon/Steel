using System;
using System.IO;

namespace SteelEngine
{
	class ShaderLoader : ResourceLoader<Shader>
	{
		/*static var EXTENSIONS = StringView[](".shader");
		public override Span<StringView> SupportedExtensions => .(&EXTENSIONS, EXTENSIONS.Count);*/
		public override Span<StringView> SupportedExtensions => default;

		public override Result<void> Load(StringView absolutePath, StringView originalPath, Stream fileReadStream, Shader r_shader)
		{
			StreamReader reader = scope .(fileReadStream);
			String shaderPath = scope .();

			// @TODO - add error handling

			String vertShader, fragShader;
			{
				reader.ReadLine(shaderPath);

				StreamReader shaderReader = scope .();
				ResourceManager.OpenRead(shaderPath, shaderReader);
				vertShader = new String();
				shaderReader.ReadToEnd(vertShader);
			}
			{
				shaderPath.Clear();
				reader.ReadLine(shaderPath);

				StreamReader shaderReader = scope .();
				ResourceManager.OpenRead(shaderPath, shaderReader);
				fragShader = new String();
				shaderReader.ReadToEnd(fragShader);
			}

			r_shader.SetData(vertShader, fragShader);

			return .Ok;
		}
	}
}
