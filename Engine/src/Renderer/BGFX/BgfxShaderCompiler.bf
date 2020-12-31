using System;
using System.IO;
using Bgfx;
using SteelEngine.Renderer;
using SteelEngine.Resources;

namespace SteelEngine.Renderer.BGFX
{
	public class BgfxShaderCompiler
	{
		const String TOOL_NAME = "shadercRelease.exe";
		const bool APPEND_PLATFORM_EXTENSION = false;

		public const String VERTEX_SHADER_EXTENSION = ".vs.bin";
		public const String FRAGMENT_SHADER_EXTENSION = ".fs.bin";

		public const String TMP_VERTEX_SHADER_EXTENSION = ".vs.sc";
		public const String TMP_FRAGMENT_SHADER_EXTENSION = ".fs.sc";
		public const String TMP_VARYING_SHADER_EXTENSION = ".var.def.sc";

		const String VARYINGT_START_TAG = "[VAR]";
		const String VERTEX_START_TAG = "[VERT]";
		const String FRAGMENT_START_TAG = "[FRAG]";

		static StringView GetPlatformName(EPlatform platform)
		{
			/**
			android
			asm.js
			ios
			linux
			orbis
			osx
			windows
			*/
			switch(platform)
			{
			case .Linux: return "linux";
			case .MacOS: return "osx";
			case .Windows: return "windows";
			default: Log.Fatal("Unsupported PlatformID!"); return "unknown";
			}	
		}

		static StringView GetRendererTypeName(bgfx.RendererType rendererType)
		{
			switch(rendererType)
			{
			case .Direct3D9: return "d3d9";
			case .Direct3D11: return "d3d11";
			case .Direct3D12: return "d3d12";

			case .OpenGL: return "ogl";
			case .OpenGLES: return "ogles";
			case .Vulkan: return "vulkan";
			case .Metal: return "metal";
			case .WebGPU: return "webgl";

			default : Log.Fatal("Unsupported RendererType!"); return "unknown";
			}
		}

		static StringView GetShaderModel(bgfx.RendererType rendererType, ShaderType type)
		{
			switch(rendererType)
			{
				
				default : Log.Fatal("Unsupported RendererType!"); return "unknown";
			}
		}

		static void PrintResult(Result<int> result, String text, StringView filePath, ShaderType shaderType)
		{
			int returnCode = 0;
			if((result case .Ok(let val)) && val != 0)
			{
				returnCode = val;
				Log.Error(scope $"Error occurred while compiling {filePath}! \nShaderType: {shaderType} \nReturn code: {returnCode}");
			}

			if(!text.IsEmpty)
			{
				if(returnCode == 0)
				{
					Log.Warning(text);
				}
				else
				{
					Log.Error(text);
				}
			}
		}

		static void WriteIfChanged(StringView filePath, StringView contents)
		{
			var trimed = contents;
			trimed.Trim();

			if(trimed.IsEmpty)
				return;

			CHECK_VERSION: do
			{
				if(!File.Exists(filePath))
				{
					break CHECK_VERSION;
				}
				String tmp = scope .();
				if(File.ReadAllText(filePath, tmp) case .Err(let err))
				{
					//Log.Error("Failed to read temp shader file!");
				}
				else if(tmp.GetHashCode() == trimed.GetHashCode())
				{
					return;
				}
			}

			if(File.WriteAllText(filePath, trimed) case .Err(let err))
			{
				Log.Error("Failed to write temp shader file!");
			}
		}


		public Result<ShaderType, FileError> Build(StringView filePath, EPlatform platform, bgfx.RendererType rendererType, StringView outDirPath, String outVertShaderPath = null, String outFragShaderPath = null)
		{
			FileStream fs = scope .();
			if(fs.Open(filePath, .Read) case .Err(let err))
			{
				return .Err(.FileOpenError(err));
			}

			String buffer = scope .();
			
			if(scope StreamReader(fs).ReadToEnd(buffer) case .Err)
				return .Err(.FileReadError(.Unknown));

			if(buffer.IsEmpty)
				return .Err(.FileReadError(.Unknown));

			let varyingStartIndex = buffer.IndexOf(VARYINGT_START_TAG);
			let vertexStartIndex = buffer.IndexOf(VERTEX_START_TAG);
			let fragmentStartIndex = buffer.IndexOf(FRAGMENT_START_TAG);

			if(varyingStartIndex < 0)
			{
				Log.Error(scope $"Shader does not contain {VARYINGT_START_TAG} tag! File: {filePath}");
				return .Err(.FileReadError(.Unknown));
			}

			Assert!(varyingStartIndex != -1);
			Assert!(vertexStartIndex != -1 || fragmentStartIndex != -1);
			Assert!((varyingStartIndex < vertexStartIndex || vertexStartIndex == -1) && (varyingStartIndex < fragmentStartIndex || fragmentStartIndex == -1));

			int vertexCodeLength, fragmentCodeLength;

			if(vertexStartIndex < fragmentStartIndex)
			{
				vertexCodeLength = fragmentStartIndex - vertexStartIndex;
				fragmentCodeLength = buffer.Length - fragmentStartIndex;
			}
			else
			{
				vertexCodeLength = buffer.Length - vertexStartIndex;
				fragmentCodeLength = vertexStartIndex - fragmentStartIndex;
			}

			int afterVarBlockStart = (vertexStartIndex < fragmentStartIndex) ? vertexStartIndex : fragmentStartIndex;
			StringView varCode = .(buffer, varyingStartIndex + VARYINGT_START_TAG.Length, afterVarBlockStart - varyingStartIndex - VARYINGT_START_TAG.Length);
			StringView vertexCode = vertexStartIndex == -1 ? default :  .(buffer, vertexStartIndex + VERTEX_START_TAG.Length, vertexCodeLength - VERTEX_START_TAG.Length);
			StringView fragmentCode = fragmentStartIndex == -1 ? default : .(buffer, fragmentStartIndex + FRAGMENT_START_TAG.Length, fragmentCodeLength - FRAGMENT_START_TAG.Length);

			String tmpPath = scope .();
			Path.GetTempPath(tmpPath);

			StringView filename = Path.GetFileNameWithoutExtension(filePath);
			String fileDir = scope .();
			Path.GetDirectoryPath(filePath, fileDir);
			
			CreateTMPShadersDir:
			{
				if(Directory.CreateDirectory(ResourceManager.GlobalizePath(scope:CreateTMPShadersDir .("tmp://shaders"))) case .Err(let err))
				{
					if(err != .AlreadyExists)
					{
						Log.Error(scope $"Failed to create temp shader directory! ({err})");
						return .Err(.FileOpenError(.Unknown));
					}
				}
			}
			
			String outBuffer = scope .();
			String errBuffer = scope .();

			String includeDirArg = scope $"-i \"{fileDir}\"";
			String platformArg = scope $"--plaform {GetPlatformName(platform)}";

			String filePathOut;
			if(APPEND_PLATFORM_EXTENSION)
			{
				String targetExtension = scope $"{GetPlatformName(platform)}.{GetRendererTypeName(rendererType)}";
				filePathOut = scope:: $"{outDirPath}/{filename}.{targetExtension}";
			}
			else
			{
				filePathOut = scope:: $"{outDirPath}/{filename}";
			}


			String varFilePathIn = ResourceManager.GlobalizePath(scope:: $"tmp://shaders/{filename}{TMP_VARYING_SHADER_EXTENSION}");
			WriteIfChanged(varFilePathIn, varCode);
			String varyingFileArg = scope $"--varyingdef \"{varFilePathIn}\"";

			ShaderType shaderTypes = default;

			if(!vertexCode.IsEmpty)
			{
				outBuffer.Clear();
				errBuffer.Clear();

				String vertexFilePathIn = ResourceManager.GlobalizePath(scope:: $"tmp://shaders/{filename}{TMP_VERTEX_SHADER_EXTENSION}");
				WriteIfChanged(vertexFilePathIn, vertexCode);

				String vertexFilePathOut = scope $"{filePathOut}.vert.bin";

				var args = scope $"-f \"{vertexFilePathIn}\" {varyingFileArg} -o \"{vertexFilePathOut}\" {includeDirArg} --type vertex {platformArg}";
				let result =  Tools.Execute(TOOL_NAME, args, outBuffer, errBuffer);
				PrintResult(result, outBuffer, filePath, .Vertex);
				
				shaderTypes |= .Vertex;
				if(outVertShaderPath != null)
					outVertShaderPath.Set(vertexFilePathOut);
			}

			if(!fragmentCode.IsEmpty)
			{
				outBuffer.Clear();
				errBuffer.Clear();

				String fragmentFilePathIn = ResourceManager.GlobalizePath(scope:: $"tmp://shaders/{filename}{TMP_FRAGMENT_SHADER_EXTENSION}");
				WriteIfChanged(fragmentFilePathIn, fragmentCode);

				String fragmentFilePathOut = scope $"{filePathOut}.frag.bin";

				let args = scope $"-f \"{fragmentFilePathIn}\" {varyingFileArg} -o \"{fragmentFilePathOut}\" {includeDirArg} --type fragment {platformArg}";
				let result = Tools.Execute(TOOL_NAME, args, outBuffer, errBuffer);
				PrintResult(result, outBuffer, filePath, .Fragment);
				shaderTypes |= .Fragment;
				if(outFragShaderPath != null)
					outFragShaderPath.Set(fragmentFilePathOut);
			}
			
			return .Ok(shaderTypes);
		}

		
		public Result<void> BuildCompute(StringView filePath, PlatformID platform, bgfx.RendererType rendererType)
		{
			Runtime.NotImplemented();
			String outBuffer = scope .();
			String errBuffer = scope .();
			let args = scope $"";
			let result = Tools.Execute("shaderc.exe", args, outBuffer, errBuffer);

			return .Err;
		}
	}
}
