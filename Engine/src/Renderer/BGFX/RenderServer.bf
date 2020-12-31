using System;
using System.Collections;
using System.IO;

using glfw_beef;
using Bgfx;
using static Bgfx.bgfx;

using SteelEngine.Input;
using SteelEngine.Window;
using SteelEngine.Math;
using SteelEngine.Console;
using SteelEngine.ECS.Components;

namespace SteelEngine.Renderer.BGFX
{
	public enum FullscreenMode
	{
		Window,
		Borderless,
		Exclusive
	}

	public static class CubeMesh
	{
		public static var vertices = Vertex[](
			.(.(-1.0f, 1.0f, 1.0f), (int32)0xff000000),
			.(.(1.0f, 1.0f, 1.0f), (int32)0xff0000ff),
			.(.(-1.0f, -1.0f, 1.0f), (int32)0xff00ff00),
			.(.(1.0f, -1.0f, 1.0f), (int32)0xff00ffff),
			.(.(-1.0f, 1.0f, -1.0f), (int32)0xffff0000),
			.(.(1.0f, 1.0f, -1.0f), (int32)0xffff00ff),
			.(.(-1.0f, -1.0f, -1.0f), (int32)0xffffff00),
			.(.(1.0f, -1.0f, -1.0f), (int32)0xffffffff)
			);

		public static var indices = uint16[](
			2, 1, 0,// 0
			2, 3, 1,
			5, 6, 4,// 2
			7, 6, 5,
			4, 2, 0,// 4
			6, 2, 4,
			3, 5, 1,// 6
			3, 7, 5,
			1, 4, 0,// 8
			1, 5, 4,
			6, 3, 2,// 10
			7, 3, 6
			);
	}

	struct Renderable : IDisposable
	{
		public Mesh mesh;
		public Material material;

		public void Dispose()
		{
			mesh.UnrefSafe();
			material.UnrefSafe();
		}
	}

	class BgfxRenderServer : RenderServer
	{
		public new static Self Instance => (Self)(RenderServer.Instance);

		RendererType _rendererType = .OpenGL;
		FullscreenMode _fullscreenMode;
		bool _vsync = true;

		DebugFlags _debugFlags = .None;
		uint32 _width, _height;
		bool _resolutionChanged;
		Window _window;

		Renderer2D _render2d ~ delete _;
		Renderer3D _render3d ~ delete _;

		/*RIDOwner<BgfxMesh> _meshes = new RIDOwner<BgfxMesh>() ~ delete _;
		RIDOwner<ProgramHandle> _shaders = new RIDOwner<ProgramHandle>() ~ delete _;
		RIDOwner<TextureHandle> _textures = new RIDOwner<TextureHandle>() ~ delete _;*/

		List<Camera2D> _drawingCameras2D = new List<Camera2D>() ~ delete _;
		List<Camera3D> _drawingCameras3D = new List<Camera3D>() ~ delete _;

		List<Sprite> _spritesToRender = new .() ~ delete _;
		List<Transform2D> _spriteTransforms = new .() ~ delete _;

		Dictionary<String, bgfx.ProgramHandle> _compiledShaders = new .() ~ { for (let kv in _) delete kv.key; delete _; };
		public Result<bgfx.ProgramHandle> GetShader(StringView name)
		{
			if (_compiledShaders.TryGetAlt(name, let k, let v))
				return v;

			return .Err;
		}

		public override void DrawCamera(Camera3D cam)
		{
			_drawingCameras3D.Add(cam);
		}


		bgfx.UniformHandle _uFrameTimeResolution;

		public Result<void> Init(Window window, bool initialize3d = true)
		{
			GameConsole.Instance
				..RegisterVariable("r.type", "Renderer type (Needs restart)", ref _rendererType, .Config)
				..RegisterVariable("r.debugflags", "Debug draw flags", ref _debugFlags, .Config | .Flags, new (cvar) => set_debug(_debugFlags))
				..RegisterVariable("r.vsync", "Toggles vertical sync", ref _vsync, .Config)
				..RegisterVariable("r.fullscreen", "Window mode", ref _fullscreenMode, .Config);

			_window = window;

		#if BF_PLATFORM_WINDOWS
			PlatformData pd = default;
			pd.nwh = Glfw.GetWin32Window(window.Handle);
		#else
			#error "Unsupported platform"
		#endif

			set_platform_data(&pd);
			{
				int width = 0, height = 0;
				Glfw.GetWindowSize(_window.Handle, ref width, ref height);

				_width = (uint32)width;
				_height = (uint32)height;
			}

			bgfx.Init info = ?;
			bgfx.init_ctor(&info);
			info.platformData = pd;
			info.type = _rendererType;
			info.resolution.width = _width;
			info.resolution.height = _height;

			if (_vsync)
				info.resolution.reset |= .Vsync;
			if (_fullscreenMode != .Window)
				info.resolution.reset |= .Fullscreen;

			if (!bgfx.init(&info))
				Log.Fatal("Failed to initialize BGFX");

			CompileShaders("res://shaders", "res://shadersbin");

			_render2d = new Renderer2D(this);

			if (initialize3d)
				_render3d = new Renderer3D(this);

			_uFrameTimeResolution = bgfx.create_uniform("frame_time_res", .Vec4, 1);

			return .Ok;
		}

		struct InstancedData
		{
			public Matrix44 transform;
			public Color4f color;
		}

		void CompileShaders(StringView inDir, StringView outDir)
		{
			let builder = scope SteelEngine.Renderer.BGFX.BgfxShaderCompiler();

			let inDirStr = ResourceManager.GlobalizePath(scope:: String(inDir));
			let outDirStr = ResourceManager.GlobalizePath(scope:: String(outDir));

			Assert!(Directory.Exists(inDirStr));
			if ((Directory.CreateDirectory(outDirStr) case .Err(let err)) && err != .AlreadyExists)
			{
				Assert!(false, scope $"Failed to create shader output directory! ({err})");
			}

			void EnumerateDirectory(StringView path, int recursionDepth = 0)
			{
				Assert!(recursionDepth < 512);
				{
					let fileEnumerator = Directory.EnumerateFiles(path, "*.shader");
					String tmpPath = scope .();
					for (let f in fileEnumerator)
					{
						tmpPath.Clear();
						f.GetFilePath(tmpPath);
						CompileFile(tmpPath);
					}
				}
				{
					let dirEnumerator = Directory.EnumerateDirectories(path);
					String tmpPath = scope .();
					for (let d in dirEnumerator)
					{
						tmpPath.Clear();
						d.GetFilePath(tmpPath);
						EnumerateDirectory(tmpPath, recursionDepth + 1);
					}
				}
			}

			void CompileFile(StringView path)
			{
				String vertPath = scope .();
				String fragPath = scope .();

				if (builder.Build(path, Application.Platform, _rendererType, outDirStr, vertPath, fragPath) case .Err(let err))
				{
					Log.Error(scope $"Failed to build shader file! ({err})\n{path}");
					return;
				}

				if (CreateProgram(vertPath, fragPath) case .Ok(let val))
				{
					let name = Path.GetFileNameWithoutExtension(path);
					_compiledShaders.Add(new .(name), val);
				}
			}

			EnumerateDirectory(inDirStr);
		}

		public virtual void DrawMesh(Mesh mesh, Material mat)
		{
			/*BgfxMesh m = (.)mesh;
			m.SetBuffers();

			let m = _meshes.GetOrDefault(mesh.ResourceId);
			if (m == null)
				return;

			set_state(.WriteZ | .WriteMask | .CullCcw | .DepthTestLess | .Msaa, 0);
			m.SetBuffers();
			submit(0, *_shaders.GetOrDefault(mat.shader.ResourceId), 0, .All);*/
		}


		uint64 _frame = 0;

		public void Draw()
		{
			let dt = Time.DeltaTime;
			uint16 viewId = 0;

			Vector4 frameTimeResolution = .(_frame, Time.TimeSinceStart, _width, _height);
			bgfx.set_uniform(_uFrameTimeResolution, &frameTimeResolution, 1);

			DRAW2D:do
			{
				for (let c in _drawingCameras2D)
				{
					c.Size = .((.)_width, (.)_height);

					if (!c.IsEnabled)
					{
						continue;
					}
 
					_render2d.DrawFrame(viewId, c, _spritesToRender, _spriteTransforms);
					viewId++;
				}
				_drawingCameras2D.Clear();
				_spritesToRender.Clear();
				_spriteTransforms.Clear();
			}


			DRAW3D:do
			{
				if (_render3d == null)
					break DRAW3D;

				for (let c in _drawingCameras3D)
				{
					if (!c.IsEnabled)
					{
						continue;
					}

					DrawCameraView(c, dt, viewId);
					viewId++;
				}
				_drawingCameras3D.Clear();
			}

			_resolutionChanged = false;

			_frame++;
			frame(false);
		}

		void DrawCameraView(Camera3D cam, float dt, uint16 viewId)
		{
			_render3d.PrepareFrame(cam, dt, viewId, .((.)_width, (.)_height));
			_render3d.RenderFrame(cam, dt, viewId);
			_render3d.PostprocessFrame(cam, dt, viewId);
		}

		protected Result<void, FileError> LoadFile(StringView path, String buffer)
		{
			System.IO.StreamReader reader = scope .();
			if (ResourceManager.OpenRead(path, reader) case .Err(let err))
				return .Err(.FileOpenError(err));

			if (reader.ReadToEnd(buffer) case .Err(let err))
				return .Err(.FileReadError(err));

			return .Ok;
		}

		public Result<(ShaderHandle shaderHandle, Memory* mem)> CreateShader(StringView shaderPath, String buffer)
		{
			buffer.Clear();
			if (LoadFile(shaderPath, buffer) case .Err)
				return .Err;

			let memory = copy(buffer.Ptr, (uint32)buffer.Length);
			let handle = create_shader(memory);
			return .Ok((handle, memory));
		}

		public Result<(ShaderHandle shaderHandle, Memory* mem)> CreateShader(StringView data)
		{
			let memory = copy(data.Ptr, (uint32)data.Length);
			let handle = create_shader(memory);
			return .Ok((handle, memory));
		}

		public Result<ProgramHandle> CreateProgram(StringView vertShaderPath, StringView fragShaderPath)
		{
			String buffer = scope .();
			if (CreateShader(vertShaderPath, buffer) case .Ok(let vert))
			{
				if (CreateShader(fragShaderPath, buffer) case .Ok(let frag))
				{
					return CreateProgram(vert.shaderHandle, frag.shaderHandle);
				}

				// @TODO(fusion) - free BGFX allocated memory (don't even know if it is needed)
			}
			return .Err;
		}

		public Result<ProgramHandle> CreateProgram(ShaderHandle vert, ShaderHandle frag)
		{
			return create_program(vert, frag, true);
		}

		public Result<void> InitializeShader(Shader shader)
		{
			/*if (shader.ResourceId.IsValid)
				return .Ok;

			if (CreateShader(shader.FragmentShaderCode) case .Ok(let vert))
			{
				if (CreateShader(shader.VertexShaderCode) case .Ok(let frag))
				{
					let program = CreateProgram(vert.shaderHandle, frag.shaderHandle);
					shader.[Friend]ResourceId = _shaders.MakeRID(program);
					return .Ok;
				}
			}*/
			return .Err;
		}

		public Result<void> InitializeMesh(Mesh mesh)
		{
			if (mesh.IsLoaded)
			{
				return .Ok;
			}
			
			/*BgfxMesh meshHandle = .CreateFromMeshWithNormals(mesh);
			mesh.[Friend]ResourceId = _meshes.MakeRID(meshHandle);*/
			return .Err;
			//return meshHandle;
		}

		Result<TextureHandle> InitializeTexture2D(Texture2D texture)
		{
			/*if (texture.[Friend]hTexture.Valid)
			{
				return texture.[Friend]hTexture;
			}*/

			return .Err;
		}

		public TextureHandle GetTextureHandle(Texture2D texture)
		{
			if (InitializeTexture2D(texture) case .Ok(let val))
				return val;

			return TextureHandle() { idx = uint16.MaxValue };
		}

		public void Resize(uint32 width, uint32 height)
		{
			_resolutionChanged = true;
			_width = width;
			_height = height;
			reset(_width, _height, .None, .Count);
		}

		public override void DrawMesh(Matrix44 transform, Material mat, Mesh m)
		{
			if (m == null)
				return;

			
			/*if (m.ResourceId.IsNull)
			{
				InitializeMesh(m);
			}

			if (mat == null)// @TODO - Use pink_squares shader in this case
				return;

			if (mat.shader.ResourceId.IsNull) InitializeShader(mat.shader);
			if (mat.colorTex.ResourceId.IsNull) InitializeTexture2D(mat.colorTex);
			if (mat.normTex.ResourceId.IsNull) InitializeTexture2D(mat.normTex);*/

			/*if(_textures.Owns(mat.colorTex.ResourceId))
				set_texture(0, _uSTexColor, *_textures[mat.colorTex], .None);
			if(_textures.Owns(mat.normTex.ResourceId))
				set_texture(1, _uSTexNormal, *_textures[mat.normTex], .None);*/

			Matrix44 t = transform;
			set_transform(&t, 1);
			DrawMesh(m, mat);
		}

		public override void DrawCamera(Camera2D cam)
		{
			_drawingCameras2D.Add(cam);
		}

		public override void DrawSprite(Transform2D transform, Sprite sprite)
		{
			_spritesToRender.Add(sprite);
			_spriteTransforms.Add(transform);
		}
	}
}