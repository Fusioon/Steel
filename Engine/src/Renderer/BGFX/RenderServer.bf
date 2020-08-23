using System;
using System.Collections;
using System.IO;

using glfw_beef;
using Bgfx;

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

	class Renderable
	{
		public VertexBufferHandle vertexBufferHandle;
		public uint32 vertexCount;
		public IndexBufferHandle indexBufferHandle;
		public uint32 indexCount;
		public ProgramHandle program;

		public this(VertexBufferHandle vertices, uint32 vcount, IndexBufferHandle indices, uint32 icount, ProgramHandle program)
		{
			vertexBufferHandle = vertices;
			vertexCount = vcount;
			indexBufferHandle = indices;
			indexCount = icount;
			this.program = program;
		}

		public void SetVertexAndIndexBuffers()
		{
			Bgfx.SetVertexBuffer(0, vertexBufferHandle, 0, vertexCount);
			Bgfx.SetIndexBuffer(indexBufferHandle, 0, indexCount);
		}
	}

	class RenderServer
	{
		public static var cubeVertices = Vertex[](
			.(.(-1.0f,  1.0f,  1.0f), (int32)0xff000000 ),
			.(.( 1.0f,  1.0f,  1.0f), (int32)0xff0000ff ),
			.(.(-1.0f, -1.0f,  1.0f), (int32)0xff00ff00 ),
			.(.( 1.0f, -1.0f,  1.0f), (int32)0xff00ffff ),
			.(.(-1.0f,  1.0f, -1.0f), (int32)0xffff0000 ),
			.(.( 1.0f,  1.0f, -1.0f), (int32)0xffff00ff ),
			.(.(-1.0f, -1.0f, -1.0f), (int32)0xffffff00 ),
			.(.( 1.0f, -1.0f, -1.0f), (int32)0xffffffff ),
		);

		public static var cubeIndices = uint16[](
			0, 1, 2, // 0
			1, 3, 2,
			4, 6, 5, // 2
			5, 6, 7,
			0, 2, 4, // 4
			4, 2, 6,
			1, 5, 3, // 6
			5, 7, 3,
			0, 4, 1, // 8
			4, 5, 1,
			2, 3, 6, // 10
			6, 3, 7);

		void InitVertexLayout()
		{
			Bgfx.VertexLayoutBegin(&_vertexLayout, .Noop);
			Bgfx.VertexLayoutAdd(&_vertexLayout, .Position, 3, .Float, false, false);
			Bgfx.VertexLayoutAdd(&_vertexLayout, .TexCoord0, 2, .Float, false, false);
			Bgfx.VertexLayoutAdd(&_vertexLayout, .Color0, 4, .Uint8, true, false);
			Bgfx.VertexLayoutEnd(&_vertexLayout);

			Bgfx.VertexLayoutBegin(&_posColNormvertexLayout, .Noop);
			Bgfx.VertexLayoutAdd(&_posColNormvertexLayout, .Position, 3, .Float, false, false);
			Bgfx.VertexLayoutAdd(&_posColNormvertexLayout, .Normal, 3, .Float, false, false);
			Bgfx.VertexLayoutAdd(&_posColNormvertexLayout, .TexCoord0, 2, .Float, false, false);
			Bgfx.VertexLayoutAdd(&_posColNormvertexLayout, .Color0, 4, .Uint8, true, false);
			Bgfx.VertexLayoutEnd(&_posColNormvertexLayout);

		};

		Bgfx.VertexLayout _vertexLayout;
		Bgfx.VertexLayout _posColNormvertexLayout;

		RendererType _rendererType = .OpenGL;
		FullscreenMode _fullscreenMode;
		int _clearColor = 0x770077FF;
		bool _vsync = true;

		Bgfx.DebugFlags _debugFlags = .None;
		uint32 _width, _height;
		Window _window;

		Renderer3D _render3d ~ delete _;

		Renderable _cube ~ delete _;

		Grid[] _grid ~ delete _;
		ProgramHandle _metaballsProgram;
		ProgramHandle _raymarchProgram;

		UniformHandle _uMtx;
		UniformHandle _uLightDirTime;

		void OnDebugChange(CVar cvar)
		{
			Bgfx.SetDebug(_debugFlags);
		}

		public Result<void> Init(Window window)
		{
			GameConsole.Instance
			..RegisterVariable("r.type", "Renderer type (Needs restart)", ref _rendererType, .Config)
			..RegisterVariable("r.clearcolor", "Clear color", ref _clearColor, .Config)
			..RegisterVariable("r.debugflags", "Debug draw flags", ref _debugFlags, .Config | .Flags, new => OnDebugChange)
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

			InitVertexLayout();

			_render3d = new Renderer3D();
			_render3d.Init(this);

			Bgfx.SetViewClear(0, .Color | .Depth, (.)_clearColor, 1, 0);

			Bgfx.SetDebug(_debugFlags);

			{
				let defaultShader = CreateProgram("res://shaders/vs_cubes.bin", "res://shaders/fs_cubes.bin");
				_cube = CreateRenderable(.(&cubeVertices, (.)cubeVertices.Count), .(&cubeIndices, cubeIndices.Count), defaultShader);
			}
			{
				_metaballsProgram = CreateProgram("res://shaders/vs_metaballs.bin", "res://shaders/fs_metaballs.bin");
				_grid = new Grid[kMaxDims*kMaxDims*kMaxDims];
			}
			{
				_raymarchProgram = CreateProgram("res://shaders/vs_raymarching.bin", "res://shaders/fs_raymarching.bin");
				_uMtx = CreateUniform("u_mtx", .Mat4, 1);
				_uLightDirTime = CreateUniform("u_lightDirTime", .Vec4, 1);
			}
			/*{
				_raymarchProgram = CreateProgram("res://shaders/vs_raymarching.bin", "res://shaders/fs_raymarching.bin");
				_uMtx = CreateUniform("u_mtx", .Mat4, 1);
				_uLightDirTime = CreateUniform("u_lightDirTime", .Vec4, 1);
			}*/

			return .Ok;
		}

		void DrawCubes()
		{
			for (uint32 yy = 0; yy < 11; ++yy)
			{
				for (uint32 xx = 0; xx < 11; ++xx)
				{
					Quaternion rotation = .Identity;
					Matrix44 transform = .Transform(.(-15.0f + float(xx)*3.0f, -15.0f + float(yy)*3.0f), .Identity, .(1, 1, 1));

					Bgfx.SetTransform(&transform, 1);

					// Set vertex and index buffer.
					/*Bgfx.SetVertexBuffer(0, _cube.ver, 0, _cube.vc);
					Bgfx.SetIndexBuffer(_cube.ibh, 0, _cube.ic);*/
					_cube.SetVertexAndIndexBuffers();

					// Set render states.
					Bgfx.SetState(.WriteZ | .WriteMask | .CullCw | .DepthTestLess | .Msaa, 0);

					// Submit primitive for rendering to view 0.
					Bgfx.Submit(0, _cube.program, 0, .All);
				}
			}
		}

		void DrawMetaballs()
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
			int64 profUpdate = 0;
			int64 profNormal = 0;
			int64 profTriangulate = 0;

			// Allocate 32K vertices in transient vertex buffer.
			uint32 maxVertices = (32<<10);
			TransientVertexBuffer tvb = ?;
			AllocTransientVertexBuffer(&tvb, maxVertices, &_posColNormvertexLayout);
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

		
		void RenderScreenSpaceQuad(uint8 view, Vector2 pos, Vector2 size)
		{
			Bgfx.TransientVertexBuffer tvb = default;
			Bgfx.TransientIndexBuffer tib = default;

			const int vertexCount = 4;
			const int indexCount = 6;
			if (Bgfx.AllocTransientBuffers(&tvb, &_vertexLayout, vertexCount, &tib, indexCount) )
			{
				Vertex* vertex = (Vertex*)tvb.data;

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

				uint16* indices = (uint16*)tib.data;

				indices[0] = 0;
				indices[1] = 2;
				indices[2] = 1;
				indices[3] = 0;
				indices[4] = 3;
				indices[5] = 2;

				Bgfx.SetState(.Default, 0);
				Bgfx.SetTransientIndexBuffer(&tib, 0, indexCount);
				Bgfx.SetTransientVertexBuffer(0, &tvb, 0, vertexCount);
				Bgfx.Submit(view, _raymarchProgram, 0, .All);
			}
		}

		public void Draw()
		{
			let aspect = _width / float(_height);
			let handedness = -1;

			Bgfx.SetViewRect(0, 0, 0, (.)_width, (.)_height);
			Bgfx.SetViewRect(1, 0, 0, (.)_width, (.)_height);
			Bgfx.Touch(0);

			Vector3 at = .Zero;
			Vector3 eye = .(0,0, -35);
				
			Matrix44 view, proj;
			view = .LookAt(at, eye, .Up, handedness);
			proj = .Perspective(Deg2Rad!(60), aspect, 0.1f, 100, handedness);

			Bgfx.SetViewTransform(0, &view, &proj);

			DrawCubes();
			DrawMetaballs();
			var time = Time.TimeSinceStart;
			Matrix44 ortho = .Ortho(0, _width, _height, 0, 0, 100, handedness);
			// Set view and projection matrix for view 0.
			Bgfx.SetViewTransform(1, null, &ortho);

			Matrix44 mtxx = .RotationX(time);
			Matrix44 mtxy = .RotationY(time * 0.37f);
			Matrix44 mtx = mtxx * mtxy;
			Matrix44 mtxInv = mtx.Inverse;
			var lightDirModelN = Vector3(-0.4f, -0.5f, -1.0f).Normalized;
			Vector4 lightDirTime = .(lightDirModelN * mtxInv, time);
			SetUniform(_uLightDirTime, &lightDirTime, 1);

			Matrix44 vp = proj * view;
			Matrix44 mvp = vp * mtx;
			Matrix44 mvpInv = mvp.Inverse;
			SetUniform(_uMtx, &mvpInv, 1);

			RenderScreenSpaceQuad(1, .Zero, .(_width, _height));

			Bgfx.Frame(false);
		}

		protected Result<void, FileError> LoadFile(StringView path, String buffer)
		{
			System.IO.StreamReader reader = scope .();
			if (Assets.OpenRead(path, reader) case .Err(let err))
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

		public Bgfx.VertexBufferHandle CreateVertexBuffer(Span<Vertex> vertices)
		{
			Memory* memory = Bgfx.Copy(vertices.Ptr, (.)vertices.Length* sizeof(Vertex));
			let handle = Bgfx.CreateVertexBuffer(memory, &_vertexLayout, 0);
			return handle;
		}

		public Bgfx.IndexBufferHandle CreateIndexBuffer(Span<uint16> indices)
		{
			Memory* memory = Bgfx.Copy(indices.Ptr, (.)indices.Length * sizeof(uint16));

			let handle = Bgfx.CreateIndexBuffer(memory, 0);
			return handle;
		}

		public Renderable CreateRenderable(Span<Vertex> vertices, Span<uint16> indices, ProgramHandle program)
		{
			let vert = CreateVertexBuffer(vertices);
			let ind = CreateIndexBuffer(indices);
			return new .(vert, (.)vertices.Length, ind, (.)indices.Length, program);
		}

		public void Resize(uint32 width, uint32 height)
		{
			_width = width;
			_height = height;
			Bgfx.Reset(_width, _height, .None, .Count);
		}
	}
}