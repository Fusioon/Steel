using System;
using System.Collections;
using System.IO;

using glfw_beef;
using Bgfx;

using SteelEngine.Input;
using SteelEngine.Window;
using SteelEngine.Math;
using SteelEngine.Console;

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
			mesh.DisposeSafe();
			material.DisposeSafe();
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

		Renderable _cube ~ _.Dispose();
		Renderable _mesh ~ _.Dispose();
		Renderable _instanced ~ _.Dispose();

		Renderable _bump ~ _.Dispose();
		ImageTexture _textureColor ~ _.Dispose();
		ImageTexture _textureNormal ~ _.Dispose();

		RIDOwner<BgfxMesh> _meshes = new RIDOwner<BgfxMesh>() ~ delete _;
		RIDOwner<ProgramHandle> _shaders = new RIDOwner<ProgramHandle>() ~ delete _;
		RIDOwner<TextureHandle> _textures = new RIDOwner<TextureHandle>() ~ delete _;

		Camera _cam ~ delete _;

		Texture2D _texture ~ _.DisposeSafe();

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

			_cam = new Camera();
			_cam.SetPerspective(_width, _height, 95, 0.1f, 1000);
			_cam.clearColor = Color4u(127, 0, 127, 0).ABGR;

			_render3d = new Renderer3D();
			_render3d.Init(this);

			Resources.AddResourceLoader<SteelEngine.ImageLoader>();
			Resources.AddResourceLoader<SteelEngine.MeshLoader>();
			Resources.AddResourceLoader<SteelEngine.ShaderLoader>();
			Resources.AddResourceLoader<SteelEngine.MaterialLoader>();

			Bgfx.SetDebug(_debugFlags);
			//let defaultShader = CreateProgram("res://shaders/vs_cubes.bin", "res://shaders/fs_cubes.bin");
			let defaultShaderProgram = Resources.Load<Shader>("res://shaders/cubes.shader");
			InitializeShader(defaultShaderProgram);
			{
				BgfxMesh cube = ?;
				cube.SetData<Vertex>(.(&CubeMesh.vertices, CubeMesh.vertices.Count), .(&CubeMesh.indices, CubeMesh.indices.Count));
				//_cube = new Mesh();
				_cube.mesh = new Mesh();
				_cube.mesh.[Friend]ResourceId = _meshes.MakeRID(cube);
				_cube.material = new Material(defaultShaderProgram);
			}
			{
				_metaballsProgram = CreateProgram("res://shader_bin/vs_metaballs.bin", "res://shader_bin/fs_metaballs.bin");
				_grid = new Grid[kMaxDims*kMaxDims*kMaxDims];
			}
			{
				_raymarchProgram = CreateProgram("res://shader_bin/vs_raymarching.bin", "res://shader_bin/fs_raymarching.bin");
				_uMtx = CreateUniform("u_mtx", .Mat4, 1);
				_uLightDirTime = CreateUniform("u_lightDirTime", .Vec4, 1);
			}
			{
				let meshProgram = Resources.Load<Shader>("res://shaders/mesh.shader");
				InitializeShader(meshProgram);
				//_meshProgram = CreateProgram("res://shaders/vs_mesh.bin", "res://shaders/fs_mesh.bin");
				_uTime = CreateUniform("u_time", .Vec4, 1);

				_mesh.mesh = Resources.Load<Mesh>("res://models/cube.obj");
				BgfxMesh mesh = .CreateFromMeshWithNormals(_mesh.mesh);
				_mesh.mesh.[Friend]ResourceId = _meshes.MakeRID(mesh);
				_mesh.material = new Material(meshProgram);
			}
			{
				let shader = Resources.Load<Shader>("res://shaders/instancing.shader");
				InitializeShader(shader);
				_instanced.mesh = Resources.Load<Mesh>("res://models/cube.obj");
				_instanced.material = new Material(shader);
			}
			{
				_uLightPosRadius = Bgfx.CreateUniform("u_lightPosRadius", .Vec4, NUM_LIGHTS);
				_uLightRGBInnerR = Bgfx.CreateUniform("u_lightRgbInnerR", .Vec4, NUM_LIGHTS);

				let shader = Resources.Load<Shader>("res://shaders/bump.shader");
				InitializeShader(shader);
				_bump.mesh = Resources.Load<Mesh>("res://models/plane.obj");
				InitializeMesh(_bump.mesh);
				_bump.material = new Material(shader);

				using(Image img = Resources.Load<Image>("res://textures/head.png"))
				{
					_textureColor = new ImageTexture(img);
					InitializeTexture2D(_textureColor);

					_uSTexColor = CreateUniform("s_texColor", .Sampler, 1);
				}
				using(Image img = Resources.Load<Image>("res://textures/head_normal.png"))
				{
					_textureNormal = new ImageTexture(img);
					InitializeTexture2D(_textureNormal);
					
					_uSTexNormal = Bgfx.CreateUniform("s_texNormal", .Sampler, 1);
				}
				
			}

			eye = .(0, 0, 15);
			rotation = .(0, Math.PI_f, 0);
			UpdateCameraPos();
			return .Ok;
		}

		void EXAMPLE_DrawCubes()
		{
			for (uint32 yy = 0; yy < 11; ++yy)
			{
				for (uint32 xx = 0; xx < 11; ++xx)
				{
					Quaternion rotation = .Identity;
					Matrix44 transform = .Transform(.(-15.0f + float(xx)*3.0f, -15.0f + float(yy)*3.0f), rotation, .(1, 1, 1));

					Bgfx.SetTransform(&transform, 1);

					DrawMesh(_cube.mesh, _cube.material);
				}
			}
		}

		void EXAMPLE_DrawMetaballs()
		{
			let time = Time.TimeSinceStart;

			const uint32 ypitch = kMaxDims;
			const uint32 zpitch = kMaxDims*kMaxDims;

			float iso = 0.75f;
			uint32 numDims = kMaxDims;


			readonly float numDimsF = float(numDims);
			readonly float scale    = kMaxDimsF/numDimsF;
			readonly float invDim   = 1.0f/(numDimsF-1.0f);

			// Stats.
			uint32 numVertices = 0;
			/*int64 profUpdate = 0;
			int64 profNormal = 0;
			int64 profTriangulate = 0;*/

			// Allocate 32K vertices in transient vertex buffer.
			uint32 maxVertices = (32<<10);
			TransientVertexBuffer tvb = ?;
			var layout = VertexDescriptors.Create(typeof(PositionColorNormalVertex)).Value;
			AllocTransientVertexBuffer(&tvb, maxVertices, &layout);
			const uint32 numSpheres = 16;
			float[numSpheres][4] sphere;

			for (var ii = 0; ii < numSpheres; ++ii)
			{
				sphere[ii][0] = Math.Sin(time*(ii*0.21f)+ii*0.37f) * (kMaxDimsF * 0.5f - 8.0f);
				sphere[ii][1] = Math.Sin(time*(ii*0.37f)+ii*0.67f) * (kMaxDimsF * 0.5f - 8.0f);
				sphere[ii][2] = Math.Cos(time*(ii*0.11f)+ii*0.13f) * (kMaxDimsF * 0.5f - 8.0f);
				sphere[ii][3] = 1.0f/(3.0f + (Math.Sin(time*(ii*0.13f) )*0.5f+0.5f)*0.9f );
			}

			for (var zz = 0; zz < numDims; ++zz)
			{
				for (var yy = 0; yy < numDims; ++yy)
				{
					var offset = (zz*kMaxDims+yy)*kMaxDims;

					for (var xx = 0; xx < numDims; ++xx)
					{
						var xoffset = offset + xx;

						float dist = 0.0f;
						float prod = 1.0f;
						for (var ii = 0; ii < numSpheres; ++ii)
						{
							float* pos = &sphere[ii];
							float dx   = pos[0] - (-kMaxDimsF*0.5f + float(xx)*scale);
							float dy   = pos[1] - (-kMaxDimsF*0.5f + float(yy)*scale);
							float dz   = pos[2] - (-kMaxDimsF*0.5f + float(zz)*scale);
							float invR = pos[3];
							float dot  = dx*dx + dy*dy + dz*dz;
							dot *= invR * invR;

							dist *= dot;
							dist += prod;
							prod *= dot;
						}

						_grid[xoffset].val = dist / prod - 1.0f;
					}
				}
			}

			for (var zz = 1; zz < numDims-1; ++zz)
			{
				for (var yy = 1; yy < numDims-1; ++yy)
				{
					var offset = (zz*kMaxDims+yy)*kMaxDims;

					for (var xx = 1; xx < numDims-1; ++xx)
					{
						var xoffset = offset + xx;

						
						_grid[xoffset].normal = Vector3(
							_grid[xoffset-1     ].val - _grid[xoffset+1     ].val,
							_grid[xoffset-ypitch].val - _grid[xoffset+ypitch].val,
							_grid[xoffset-zpitch].val - _grid[xoffset+zpitch].val).Normalized;
					}
				}
			}

			
			PositionColorNormalVertex* vertex = (PositionColorNormalVertex*)tvb.data;

			for (var zz = 0; zz < numDims-1 && numVertices+12 < maxVertices; ++zz)
			{
				float[6] rgb;
				rgb[2] = zz*invDim;
				rgb[5] = (zz+1)*invDim;

				for (var yy = 0; yy < numDims-1 && numVertices+12 < maxVertices; ++yy)
				{
					var offset = (zz*kMaxDims+yy)*kMaxDims;

					rgb[1] = yy*invDim;
					rgb[4] = (yy+1)*invDim;

					for (var xx = 0; xx < numDims-1 && numVertices+12 < maxVertices; ++xx)
					{
						var xoffset = offset + xx;

						rgb[0] = xx*invDim;
						rgb[3] = (xx+1)*invDim;

						Vector3 pos = .(-kMaxDimsF*0.5f + float(xx)*scale,
										-kMaxDimsF*0.5f + float(yy)*scale,
										-kMaxDimsF*0.5f + float(zz)*scale);

						Grid* grid = _grid.CArray();
						Grid*[8] val = Grid*[](&grid[xoffset+zpitch+ypitch ],
							&grid[xoffset+zpitch+ypitch+1],
							&grid[xoffset+ypitch+1       ],
							&grid[xoffset+ypitch         ],
							&grid[xoffset+zpitch         ],
							&grid[xoffset+zpitch+1       ],
							&grid[xoffset+1              ],
							&grid[xoffset                ]);

						var num = triangulate(vertex, &rgb, pos, val, iso, scale);
						vertex += num;
						numVertices += num;
					}
				}
			}

			SetTransientVertexBuffer(0, &tvb, 0, numVertices);
			// Set vertex and index buffer.
			//bgfx.setVertexBuffer(0, &tvb, 0, numVertices);

			// Set render states.
			SetState(.Default,  0);

			// Submit primitive for rendering to view 0.
			Submit(0, _metaballsProgram, 0, .All);
		}

		
		void EXAMPLE_RenderScreenSpaceQuad(uint8 view, Vector2 pos, Vector2 size)
		{
			
			float time = Time.DeltaTime;
			Matrix44 ortho = .Ortho(0, _width, _height, 0, 0, 100, Camera.HANDEDNESS);
			// Set view and projection matrix for view 0.
			Bgfx.SetViewTransform(1, null, &ortho);

			Matrix44 mtxx = .RotationX(time);
			Matrix44 mtxy = .RotationY(time * 0.37f);
			Matrix44 mtx = mtxx * mtxy;
			Matrix44 mtxInv = mtx.Inverse;
			var lightDirModelN = Vector3(-0.4f, -0.5f, -1.0f).Normalized;
			Vector4 lightDirTime = .(lightDirModelN * mtxInv, time);
			SetUniform(_uLightDirTime, &lightDirTime, 1);

			Matrix44 vp = _cam.Projection * _cam.View;
			Matrix44 mvp = vp * mtx;
			Matrix44 mvpInv = mvp.Inverse;
			SetUniform(_uMtx, &mvpInv, 1);


			Bgfx.TransientVertexBuffer tvb = default;
			Bgfx.TransientIndexBuffer tib = default;

			const int vertexCount = 4;
			const int indexCount = 6;
			if ((VertexDescriptors.Create(typeof(PositionTextColorVertex)) case .Ok(var layout)) && Bgfx.AllocTransientBuffers(&tvb, &layout, vertexCount, &tib, indexCount) )
			{
				PositionTextColorVertex* vertex = (PositionTextColorVertex*)tvb.data;

				float zz = 0.0f;

				Vector2 min = pos;
				Vector2 max = pos + size;

				Vector2 minCoord = .(-1, -1);
				Vector2 maxCoord = .(1, 1);

				vertex[0].pos = .(min.x, min.y, zz);
				vertex[0].abgr = (int32)0xff0000ff;
				vertex[0].textCoord = .(minCoord.x, minCoord.y);

				vertex[1].pos = .(max.x, min.y, zz);
				vertex[1].abgr = (int32)0xff00ff00;
				vertex[1].textCoord = .(maxCoord.x, minCoord.y);

				vertex[2].pos = .(max.x, max.y, zz);
				vertex[2].abgr = (int32)0xffff0000;
				vertex[2].textCoord = .(maxCoord.x, maxCoord.y);

				vertex[3].pos = .(min.x, max.y, zz);
				vertex[3].abgr = (int32)0xffffffff;
				vertex[3].textCoord = .(minCoord.x, maxCoord.y);

				uint16[6]* indices = (uint16[6]*)tib.data;

				*indices = .(0, 2, 1, 0, 3, 2);

				/*indices[0] = 0;
				indices[1] = 2;
				indices[2] = 1;
				indices[3] = 0;
				indices[4] = 3;
				indices[5] = 2;*/

				Bgfx.SetState(.Default, 0);
				Bgfx.SetTransientIndexBuffer(&tib, 0, indexCount);
				Bgfx.SetTransientVertexBuffer(0, &tvb, 0, vertexCount);
				Bgfx.Submit(view, _raymarchProgram, 0, .All);
			}
		}

		void EXAMPLE_DrawMesh()
		{
			float time = Time.DeltaTime;
			Quaternion rotation = .FromEulerAngles(0, time * 0.37f, 0); 
			Matrix44 transform = .Transform(.(0, 0, 10), rotation, .(1, 1, 1));

			Bgfx.SetTransform(&transform, 1);
			Vector4 vec4time = .(Time.TimeSinceStart);
			Bgfx.SetUniform(_uTime, &vec4time, 1);
			DrawMesh(_mesh.mesh, _mesh.material);
		}

		struct InstancedData
		{
			public Matrix44 transform;
			public Color4f color;
		}

		void EXAMPLE_Instancing()
		{
			let caps = Bgfx.GetCapabilities();
			if (caps.supported.HasFlag(.Instancing))
			{
				// 80 bytes stride = 64 bytes for 4x4 matrix + 16 bytes for RGBA color.
				// 11x11 cubes
				const uint32 WIDTH = 11;
				const uint32 HEIGHT = 11;
				const uint32 INSTANCE_COUNT   = WIDTH * HEIGHT;

				let time = Time.TimeSinceStart;

				if (INSTANCE_COUNT == Bgfx.GetAvailableInstanceDataBuffer(INSTANCE_COUNT, strideof(InstancedData)) )
				{
					Bgfx.InstanceDataBuffer idb = ?;
					Bgfx.AllocInstanceDataBuffer(&idb, INSTANCE_COUNT, strideof(InstancedData));

					InstancedData* data = (InstancedData*)idb.data;

					// Write instance data for 11x11 cubes.
					for (uint32 yy = 0; yy < HEIGHT; ++yy)
					{
						for (uint32 xx = 0; xx < WIDTH; ++xx)
						{
							data.transform = .Transform(
								Vector3(-15.0f + float(xx)*3.0f, -15.0f + float(yy)*3.0f, -5),
								Quaternion.FromEulerAngles(time + xx*0.21f, time + yy*0.37f, 0),
								Vector3.One);

							data.color = .(Math.Sin(time+float(xx)/11.0f)*0.5f+0.5f,
								Math.Cos(time+float(yy)/11.0f)*0.5f+0.5f,
								Math.Sin(time*3.0f)*0.5f+0.5f,
								1);

							++data;
						}
					}


					// Set vertex and index buffer.

					let mesh = _meshes.GetOrDefault(_instanced.mesh.ResourceId);
					mesh.SetBuffers();
					/*Bgfx.SetVertexBuffer(0, m_vbh);
					Bgfx.SetIndexBuffer(m_ibh);*/

					// Set instance data buffer.
					Bgfx.SetInstanceDataBuffer(&idb, 0, INSTANCE_COUNT);

					// Set render states.
					//Bgfx.SetState(BGFX_STATE_DEFAULT);

					// Submit primitive for rendering to view 0.
					//Bgfx.submit(0, m_program);
					
					Bgfx.Submit(0, * _shaders.GetOrDefault(_instanced.material.shader.ResourceId), 0, .All);
					//mesh.Submit();
				}
			}
		}	

		void EXAMPLE_Bump()
		{
			float time = Time.TimeSinceStart;

			Vector4[4] lightPosRadius;
			for (uint32 ii = 0; ii < NUM_LIGHTS; ++ii)
			{
				lightPosRadius[ii] = .( Math.Sin( (time*(0.1f + ii*0.17f) + ii*Math.PI_f/2*1.37f ) )*3.0f,
										Math.Cos( (time*(0.2f + ii*0.29f) + ii*Math.PI_f/2*1.49f ) )*3.0f,
										-2.5f,
										5.0f );
			}

			Bgfx.SetUniform(_uLightPosRadius, &lightPosRadius, NUM_LIGHTS);


			Vector4[4] lightRgbInnerR = .(
				.( 1.0f, 0.7f, 0.2f, 0.8f ),
				.( 0.7f, 0.2f, 1.0f, 0.8f ),
				.( 0.2f, 1.0f, 0.7f, 0.8f ),
				.( 1.0f, 0.4f, 0.2f, 0.8f ),
			);

			Bgfx.SetUniform(_uLightRGBInnerR, &lightRgbInnerR, NUM_LIGHTS);

			for (uint32 yy = 0; yy < 3; ++yy)
			{
				for (uint32 xx = 0; xx < 3; ++xx)
				{
					Matrix44 mtx = .Transform(Vector3(-3.0f + float(xx)*3.0f, 0, -3.0f + float(yy)*3.0f), .Identity, .One);

					// Set transform for draw call.
					Bgfx.SetTransform(&mtx, 1);

					// Set vertex and index buffer.
					/*bgfx::setVertexBuffer(0, m_vbh);
					bgfx::setIndexBuffer(m_ibh);*/

					_meshes[_bump.mesh].SetBuffers();
					/*let m = _meshes.GetOrDefault(_bump.mesh.ResourceId);
					if (m == null)
						return;

					m.SetBuffers();*/

					Bgfx.SetTexture(0, _uSTexColor, *_textures[_textureColor], .None);
					Bgfx.SetTexture(1, _uSTexNormal, *_textures[_textureNormal], .None);

					Bgfx.SetState(.WriteRgb | .WriteA | .WriteZ | .DepthTestLess | .Msaa, 0);
					// Set render states.
					/*bgfx::setState(0
							| BGFX_STATE_WRITE_RGB
							| BGFX_STATE_WRITE_A
							| BGFX_STATE_WRITE_Z
							| BGFX_STATE_DEPTH_TEST_LESS
							| BGFX_STATE_MSAA
							);*/

					// Submit primitive for rendering to view 0.
					//bgfx::submit(0, m_program);*/
					
					Bgfx.Submit(0, *_shaders[_bump.material.shader], 0, .All);
				}
			}
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

		void UpdateCameraPos()
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

			if (Input.GetKey(.Space)) eye.y += speedDt;
			if (Input.GetKey(.LeftControl)) eye.y -= speedDt;

			/*let aspect = _width / float(_height);*/
			_cam.SetPositionRotation(eye, quat);
		}

		public void Draw()
		{
			if (Input.GetKey(.Mouse0)) 
				UpdateCameraPos();
			

			ClearFlags clearFlags = .None;
			if (_cam.clearFlags.HasFlag(.Color))
				clearFlags |= .Color;
			if (_cam.clearFlags.HasFlag(.Depth))
				clearFlags |= .Depth;

			Bgfx.SetViewClear(0, clearFlags, *(uint32*)&_cam.clearColor, 1, 1);
			Bgfx.SetViewRect(0, 0, 0, (.)_width, (.)_height);
			Bgfx.SetViewRect(1, 0, 0, (.)_width, (.)_height);
			Bgfx.Touch(0);


			//view = .LookAt(at, eye, .Up, handedness);
			//proj = .Perspective(Deg2Rad!(60), aspect, 0.1f, 1000, handedness);
			Matrix44 view, proj;
			proj = _cam.Projection;
			view = _cam.View;

			Bgfx.SetViewTransform(0, &view, &proj);

			EXAMPLE_DrawCubes();
			//EXAMPLE_DrawMetaballs();
			//EXAMPLE_RenderScreenSpaceQuad(1, .Zero, .(_width, _height));
			EXAMPLE_DrawMesh();

			//EXAMPLE_Instancing();
			EXAMPLE_Bump();

			Bgfx.Frame(false);
		}

		protected Result<void, FileError> LoadFile(StringView path, String buffer)
		{
			System.IO.StreamReader reader = scope .();
			if (Resources.OpenRead(path, reader) case .Err(let err))
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
			_width = width;
			_height = height;
			Bgfx.Reset(_width, _height, .None, .Count);
			_cam.SetResolution(_width, _height);
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

			if(mat.ResourceId.IsNull)
			{
				InitializeShader(mat.shader);
				InitializeTexture2D(mat.colorTex);
				InitializeTexture2D(mat.normTex); // Have empty texture prepared so this can be empty
			}

			Bgfx.SetTexture(0, _uSTexColor, *_textures[mat.colorTex], .None);
			Bgfx.SetTexture(1, _uSTexNormal, *_textures[mat.normTex], .None);
			Matrix44 t = transform;
			SetTransform(&t, 0);
			DrawMesh(m, mat);
		}
	}
}