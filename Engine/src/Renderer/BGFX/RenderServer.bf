using System;
using System.Collections;
using System.IO;

using glfw_beef;
using Bgfx;

using SteelEngine.Input;
using SteelEngine.Window;
using SteelEngine.Math;
using SteelEngine.Console;
using SteelEngine.ECS.Components;

using static SteelEngine.Renderer.BGFX.Metaballs;

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
			.(.(-1.0f,  1.0f,  1.0f), (int32)0xff000000 ),
			.(.( 1.0f,  1.0f,  1.0f), (int32)0xff0000ff ),
			.(.(-1.0f, -1.0f,  1.0f), (int32)0xff00ff00 ),
			.(.( 1.0f, -1.0f,  1.0f), (int32)0xff00ffff ),
			.(.(-1.0f,  1.0f, -1.0f), (int32)0xffff0000 ),
			.(.( 1.0f,  1.0f, -1.0f), (int32)0xffff00ff ),
			.(.(-1.0f, -1.0f, -1.0f), (int32)0xffffff00 ),
			.(.( 1.0f, -1.0f, -1.0f), (int32)0xffffffff ),
		);

		public static var indices = uint16[](
			2, 1, 0, // 0
			2, 3, 1,
			5, 6, 4, // 2
			7, 6, 5,
			4, 2, 0, // 4
			6, 2, 4,
			3, 5, 1, // 6
			3, 7, 5,
			1, 4, 0, // 8
			1, 5, 4,
			6, 3, 2, // 10
			7, 3, 6,
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
		public static Bgfx.TextureFormat GetBGFXPixelFormat(this PixelFormat format)
		{
			switch (format)
			{
			case .RGBA8: return .RGBA8;
			case .RGB8: return .RGB8;
			default: break;
			}
			Log.Warning("GetBGFXPixelFormat returning Unknown for {} format!", format);
			return .Unknown;
		}

		RendererType _rendererType = .OpenGL;
		FullscreenMode _fullscreenMode;
		bool _vsync = true;

		Bgfx.DebugFlags _debugFlags = .None;
		uint32 _width, _height;
		bool _resolutionChanged;
		Window _window;

		Renderer3D _render3d ~ delete _;

		Grid[] _grid ~ delete _;
		ProgramHandle _metaballsProgram;
		ProgramHandle _raymarchProgram;

		UniformHandle _uMtx;
		UniformHandle _uLightDirTime;
		UniformHandle _uTime;

		UniformHandle _uSTexColor;
		UniformHandle _uSTexNormal;
		const int NUM_LIGHTS = 4;
		UniformHandle _uLightPosRadius;
		UniformHandle _uLightRGBInnerR;

		/*Renderable _cube ~ _.Dispose();
		Renderable _mesh ~ _.Dispose();
		Renderable _instanced ~ _.Dispose();*/

		/*Renderable _bump ~ _.Dispose();
		ImageTexture _textureColor ~ _.UnrefSafe();
		ImageTexture _textureNormal ~ _.UnrefSafe();*/

		RIDOwner<BgfxMesh> _meshes = new RIDOwner<BgfxMesh>() ~ delete _;
		RIDOwner<ProgramHandle> _shaders = new RIDOwner<ProgramHandle>() ~ delete _;
		RIDOwner<TextureHandle> _textures = new RIDOwner<TextureHandle>() ~ delete _;

		Texture2D _texture ~ _.UnrefSafe();

		Vector3 eye;
		Vector3 rotation;

		public Result<void> Init(Window window)
		{
			GameConsole.Instance
			..RegisterVariable("r.type", "Renderer type (Needs restart)", ref _rendererType, .Config)
			..RegisterVariable("r.debugflags", "Debug draw flags", ref _debugFlags, .Config | .Flags, new (cvar) => Bgfx.SetDebug(_debugFlags))
			..RegisterVariable("r.vsync", "Toggles vertical sync", ref _vsync, .Config)
			..RegisterVariable("r.fullscreen", "Window mode", ref _fullscreenMode, .Config);

			_window = window;

		#if BF_PLATFORM_WINDOWS
			PlatformData pd = default;
			pd.nwh = Glfw.GetWin32Window(window.Handle);
		#else
			#error "Unsupported platform"
		#endif

			SetPlatformData(&pd);

			{
				int width = 0, height = 0;
				Glfw.GetWindowSize(_window.Handle, ref width, ref height);

				_width = (uint32)width;
				_height = (uint32)height;
			}
			
			InitInfo info = ?;
			InitCtor(&info);
			info.platformData = pd;
			info.type = _rendererType;
			info.resolution.width = _width;
			info.resolution.height = _height;

			if (_vsync)
				info.resolution.reset |= .Vsync;
			if (_fullscreenMode != .Window)
				info.resolution.reset |= .Fullscreen;

			if (!Bgfx.Init(&info))
				Log.Fatal("Failed to initialize BGFX");

			/*_cam = new Camera();
			_cam.SetPerspective(_width, _height, 95, 0.1f, 1000);
			_cam.clearColor = Color4u(127, 0, 127, 0).ABGR;

			_render3d = new Renderer3D();
			_render3d.Init(this);

			Bgfx.SetDebug(_debugFlags);

			eye = .(0, 0, 15);
			rotation = .(0, Math.PI_f, 0);
			UpdateCameraPos();*/
			return .Ok;
		}

		struct InstancedData
		{
			public Matrix44 transform;
			public Color4f color;
		}

		void DrawMesh(Mesh mesh, Material mat)
		{
			let m = _meshes.GetOrDefault(mesh.ResourceId);
			if (m == null)
				return;

			Bgfx.SetState(.WriteZ | .WriteMask | .CullCcw | .DepthTestLess | .Msaa, 0);
			m.SetBuffers();
			Bgfx.Submit(0, *_shaders.GetOrDefault(mat.shader.ResourceId), 0, .All);
		}

		/*void UpdateCameraPos()
		{
			const float mouseSense = 0.3f;
			const float speed = 5;
			const float fastSpeed = 10;
			let speedDt = (Input.GetKey(.LeftShift) ? fastSpeed : speed) * Time.DeltaTime;

			Vector3 dir = .Zero;
			if (Input.GetKey(.W)) dir.z += speedDt;
			if (Input.GetKey(.S)) dir.z -= speedDt;
			if (Input.GetKey(.A)) dir.x -= speedDt;
			if (Input.GetKey(.D)) dir.x += speedDt;

			let mouseX = SteelEngine.Math.Deg2Rad!(Input.GetAxis(.MouseX));
			let mouseY = SteelEngine.Math.Deg2Rad!(Input.GetAxis(.MouseY));

			rotation.x += mouseY * mouseSense;
			rotation.y += mouseX * mouseSense;
			rotation.x = Math.Clamp(rotation.x, Deg2Rad!(-89.9f), Deg2Rad!(89.9f));

			let quat = Quaternion.FromEulerAngles(rotation);
			eye += dir * quat.ToMatrix44();

			if (Input.GetKey(.Space))
				eye.y += speedDt;
			if (Input.GetKey(.LeftControl))
				eye.y -= speedDt;

			_cam.SetPositionRotation(eye, quat);
		}*/

		public void Draw()
		{
			let cams = Camera.Cameras;
			let dt = Time.DeltaTime;

			uint16 viewId = 0;

			for(let c in cams)
			{
				if(!c.IsEnabled)
				{
					continue;
				}
				

				DrawCameraView(c, dt, viewId);
			}	

			/*if (Input.GetKey(.Mouse0)) 
				UpdateCameraPos();*/
			
			_resolutionChanged = false;
			
			Bgfx.Frame(false);
		}

		void DrawCameraView(Camera cam, float dt, uint16 viewId)
		{
			PrepareFrame(cam, dt, viewId);
			RenderFrame(cam, dt, viewId);
			PostprocessFrame(cam, dt, viewId);
		}

		void PrepareFrame(Camera cam, float dt, uint16 viewId)
		{
			ClearFlags clearFlags = .None;
			if (cam.clearFlags.HasFlag(.Color))
				clearFlags |= .Color;
			if (cam.clearFlags.HasFlag(.Depth))
				clearFlags |= .Depth;

			Bgfx.SetViewClear(viewId, clearFlags, *(uint32*)&cam.clearColor, 1, 1);
			Bgfx.SetViewRect(viewId, 0, 0, (.)_width, (.)_height);
			Bgfx.Touch(viewId);

			Matrix44 view, proj;
			proj = cam.Projection;
			view = cam.View;

			Bgfx.SetViewTransform(viewId, &view, &proj);
		}

		void RenderFrame(Camera cam, float dt, uint16 viewId)
		{

		}

		void PostprocessFrame(Camera cam, float dt, uint16 viewId)
		{

		}

		protected Result<void, FileError> LoadFile(StringView path, String buffer)
		{
			System.IO.StreamReader reader = scope .();
			if (ResourceManager.OpenRead(path, reader) case .Err(let err))
				return .Err(.FileOpenError(err));

			if( reader.ReadToEnd(buffer) case .Err(let err) )
 				return .Err(.FileReadError(err));

			return .Ok;
		}

		public Result<(Bgfx.ShaderHandle shaderHandle, Memory* mem)> CreateShader(StringView shaderPath, String buffer)
		{
			buffer.Clear();
			if (LoadFile(shaderPath, buffer) case .Err)
				return .Err;

			let memory = Copy(buffer.Ptr, (uint32)buffer.Length);
			let handle = Bgfx.CreateShader(memory);
			return .Ok((handle, memory));
		}

		public Result<(Bgfx.ShaderHandle shaderHandle, Memory* mem)> CreateShader(StringView data)
		{
			let memory = Copy(data.Ptr, (uint32)data.Length);
			let handle = Bgfx.CreateShader(memory);
			return .Ok((handle, memory));
		}

		public Result<ProgramHandle> CreateProgram(StringView vertShaderPath, StringView fragShaderPath)
		{
			String buffer = scope .();
			if (CreateShader(vertShaderPath, buffer) case .Ok(let vert))
			{
				if (CreateShader(fragShaderPath, buffer) case .Ok(let frag))
				{
					return Bgfx.CreateProgram(vert.shaderHandle, frag.shaderHandle, true);
				}

				// @TODO(fusion) - free BGFX allocated memory (don't even know if it is needed)
			}
			return .Err;
		}

		public Result<ProgramHandle> CreateProgram(ShaderHandle vert, ShaderHandle frag)
		{
			return Bgfx.CreateProgram(vert, frag, true);
		}

		public Result<void> InitializeShader(Shader shader)
		{
			if (shader.ResourceId.IsValid)
				return .Ok;

			if (CreateShader(shader.FragmentShaderCode) case .Ok(let vert))
			{
				if (CreateShader(shader.VertexShaderCode) case .Ok(let frag))
				{
					let program =  Bgfx.CreateProgram(vert.shaderHandle, frag.shaderHandle, true);
					shader.[Friend]ResourceId = _shaders.MakeRID(program);
					return .Ok;
				}

				// @TODO(fusion) - free BGFX allocated memory (don't even know if it is needed)
			}
			return .Err;
		}

		public Result<void> InitializeMesh(Mesh mesh)
		{
			if (mesh.ResourceId.IsValid)
			{
				let handlePtr = _meshes[mesh];
				if (handlePtr != null)
				{
					return .Ok;
					//return *handlePtr;
				}
			}
				
			BgfxMesh meshHandle = .CreateFromMeshWithNormals(mesh);
			mesh.[Friend]ResourceId = _meshes.MakeRID(meshHandle);
			return .Ok;
			//return meshHandle;
		}

		public Result<TextureHandle> InitializeTexture2D(Texture2D texture)
		{
			if (texture.ResourceId.IsValid)
			{
				let handlePtr = _textures[texture.ResourceId];
				if (handlePtr != null)
				{
					return *handlePtr;
				}
			}

			let memory = Bgfx.Copy(texture.Data.Ptr, (uint32)texture.Data.Length);
			
			let tex = CreateTexture2d((uint16)texture.Width, (uint16)texture.Height, texture.MipLevels > 1, 1, texture.Format.GetBGFXPixelFormat(), .None, memory);
			if (tex.Valid)
			{
				texture.[Friend]ResourceId = _textures.MakeRID(tex);
				return tex;
			}

			return .Err;
		}

		public void Resize(uint32 width, uint32 height)
		{
			_resolutionChanged = true;
			_width = width;
			_height = height;
			Bgfx.Reset(_width, _height, .None, .Count);
			
		}

		protected override void DrawMeshInstance(Matrix44 transform, Material mat, Mesh m)
		{
			if(m == null)
				return;

			if(m.ResourceId.IsNull)
			{
				InitializeMesh(m);
			}

			if(mat == null) // @TODO - Use pink_squares shader in this case
				return;

			if(mat.shader.ResourceId.IsNull) InitializeShader(mat.shader);
			if(mat.colorTex.ResourceId.IsNull) InitializeTexture2D(mat.colorTex);
			if(mat.normTex.ResourceId.IsNull) InitializeTexture2D(mat.normTex);

			if(_textures.Owns(mat.colorTex.ResourceId))
				Bgfx.SetTexture(0, _uSTexColor, *_textures[mat.colorTex], .None);
			if(_textures.Owns(mat.normTex.ResourceId))
				Bgfx.SetTexture(1, _uSTexNormal, *_textures[mat.normTex], .None);

			Matrix44 t = transform;
			SetTransform(&t, 1);
			DrawMesh(m, mat);
		}
	}
}