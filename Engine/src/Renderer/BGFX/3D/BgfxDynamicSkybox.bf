using System;
using Bgfx;
using static Bgfx.bgfx;

namespace SteelEngine.Renderer.BGFX
{
	public class SunController
	{
		public enum Month : int
		{
			January = 0,
			February,
			March,
			April,
			May,
			June,
			July,
			August,
			September,
			October,
			November,
			December
		};

		public this()
		{
			m_latitude = 50.0f;
			m_month = .June;
			m_eclipticObliquity = SteelEngine.Math.Deg2Rad!(23.4f);
			m_delta = 0f;

			m_northDir = .(1, 0, 0);
			m_sunDir = .(0, -1, 0);
			m_upDir = .(0, 1, 0);
		}

		public void Update(float _time)
		{
			CalculateSunOrbit();
			UpdateSunPosition(_time - 12.0f);
		}

		Vector3 m_northDir;
		Vector3 m_sunDir;
		public Vector3 Direction => m_sunDir;
		Vector3 m_upDir;
		float m_latitude;
		Month m_month;


		void CalculateSunOrbit()
		{
			float day = 30.0f * m_month.Underlying + 15.0f;
			float lambda = 280.46f + 0.9856474f * day;
			lambda = SteelEngine.Math.Deg2Rad!(lambda);
			m_delta = Math.Asin(Math.Sin(m_eclipticObliquity) * Math.Sin(lambda));
		}

		void UpdateSunPosition(float _hour)
		{
			readonly float latitude = SteelEngine.Math.Deg2Rad!(m_latitude);
			readonly float hh = _hour * Math.PI_f / 12.0f;
			readonly float azimuth = Math.Atan2(
				Math.Sin(hh)
				, Math.Cos(hh) * Math.Sin(latitude) - Math.Tan(m_delta) * Math.Cos(latitude)
				);

			readonly float altitude = Math.Asin(
				Math.Sin(latitude) * Math.Sin(m_delta) + Math.Cos(latitude) * Math.Cos(m_delta) * Math.Cos(hh)
				);

			readonly Quaternion rot0 = .FromAngleAxis(-azimuth, m_upDir);
			readonly Vector3 dir = rot0 * m_northDir;
			readonly Vector3 uxd = .CrossProduct(m_upDir, dir);

			readonly Quaternion rot1 = .FromAngleAxis(altitude, uxd);
			m_sunDir = rot1 * dir;
		}

		float m_eclipticObliquity;
		float m_delta;
	}

	[Reflect]
	struct ScreenPosVertex
	{
		[VertexUsage(.Position)]
		Vector2 pos;
		public this()
		{
			pos = default;
		}
		public this(float x, float y)
		{
			pos = .(x, y);
		}
	}

	typealias DirectionalLight = void;

	class BgfxDynamicSkybox
	{
		typealias Color = Vector3;

		public static Gradient _sunLuminanceXYZ = new Gradient(
			(5.0f / 24, Color4f(0.000000f, 0.000000f, 0.000000f)),
			(7.0f / 24, Color4f(12.703322f, 12.989393f, 9.100411f)),
			(8.0f / 24, Color4f(13.202644f, 13.597814f, 11.524929f)),
			(9.0f / 24, Color4f(13.192974f, 13.597458f, 12.264488f)),
			(10.0f / 24, Color4f(13.132943f, 13.535914f, 12.560032f)),
			(11.0f / 24, Color4f(13.088722f, 13.489535f, 12.692996f)),
			(12.0f / 24, Color4f(13.067827f, 13.467483f, 12.745179f)),
			(13.0f / 24, Color4f(13.069653f, 13.469413f, 12.740822f)),
			(14.0f / 24, Color4f(13.094319f, 13.495428f, 12.678066f)),
			(15.0f / 24, Color4f(13.142133f, 13.545483f, 12.526785f)),

			(16.0f / 24, Color4f(13.201734f, 13.606017f, 12.188001f)),
			(17.0f / 24, Color4f(13.182774f, 13.572725f, 11.311157f)),
			(18.0f / 24, Color4f(12.448635f, 12.672520f, 8.267771f)),
			(20.0f / 24, Color4f(0.000000f, 0.000000f, 0.000000f))
			) ~ delete _;

		public static Gradient _skyLuminanceXYZ = new Gradient(
			(0.0f / 24, Color4f(0.308f, 0.308f, 0.411f)),
			(1.0f / 24, Color4f(0.308f, 0.308f, 0.410f)),
			(2.0f / 24, Color4f(0.301f, 0.301f, 0.402f)),
			(3.0f / 24, Color4f(0.287f, 0.287f, 0.382f)),
			(4.0f / 24, Color4f(0.258f, 0.258f, 0.344f)),
			(5.0f / 24, Color4f(0.258f, 0.258f, 0.344f)),
			(7.0f / 24, Color4f(0.962851f, 1.000000f, 1.747835f)),
			(8.0f / 24, Color4f(0.967787f, 1.000000f, 1.776762f)),
			(9.0f / 24, Color4f(0.970173f, 1.000000f, 1.788413f)),
			(10.0f / 24, Color4f(0.971431f, 1.000000f, 1.794102f)),
			(11.0f / 24, Color4f(0.972099f, 1.000000f, 1.797096f)),
			(12.0f / 24, Color4f(0.972385f, 1.000000f, 1.798389f)),
			(13.0f / 24, Color4f(0.972361f, 1.000000f, 1.798278f)),
			(14.0f / 24, Color4f(0.972020f, 1.000000f, 1.796740f)),
			(15.0f / 24, Color4f(0.971275f, 1.000000f, 1.793407f)),
			(16.0f / 24, Color4f(0.969885f, 1.000000f, 1.787078f)),
			(17.0f / 24, Color4f(0.967216f, 1.000000f, 1.773758f)),
			(18.0f / 24, Color4f(0.961668f, 1.000000f, 1.739891f)),
			(20.0f / 24, Color4f(0.264f, 0.264f, 0.352f)),
			(21.0f / 24, Color4f(0.264f, 0.264f, 0.352f)),
			(22.0f / 24, Color4f(0.290f, 0.290f, 0.386f)),
			(23.0f / 24, Color4f(0.303f, 0.303f, 0.404f))
			) ~ delete _;


		// HDTV rec. 709 matrix.
		static readonly float[9] M_XYZ2RGB = .(
			3.240479f, -0.969256f, 0.055648f,
			-1.53715f, 1.875991f, -0.204043f,
			-0.49853f, 0.041556f, 1.057311f
			);

		// Converts color repesentation from CIE XYZ to RGB color-space.
		public static Color4f xyzToRgb(Color4f xyz)
		{
			return .(
				M_XYZ2RGB[0] * xyz.v.x + M_XYZ2RGB[3] * xyz.v.y + M_XYZ2RGB[6] * xyz.v.z,
				M_XYZ2RGB[1] * xyz.v.x + M_XYZ2RGB[4] * xyz.v.y + M_XYZ2RGB[7] * xyz.v.z,
				M_XYZ2RGB[2] * xyz.v.x + M_XYZ2RGB[5] * xyz.v.y + M_XYZ2RGB[8] * xyz.v.z,
				1);
		};

		// Turbidity tables. Taken from:
		// A. J. Preetham, P. Shirley, and B. Smits. A Practical Analytic Model for Daylight. SIGGRAPH ’99
		// Coefficients correspond to xyY colorspace.
		public static readonly Color[5] ABCDE = .(
			Color(-0.2592f, -0.2608f, -1.4630f),
			Color(0.0008f, 0.0092f, 0.4275f),
			Color(0.2125f, 0.2102f, 5.3251f),
			Color(-0.8989f, -1.6537f, -2.5771f),
			Color(0.0452f, 0.0529f, 0.3703f)
			);
		public static readonly Color[5] ABCDE_t = .(
			Color(-0.0193f, -0.0167f, 0.1787f),
			Color(-0.0665f, -0.0950f, -0.3554f),
			Color(-0.0004f, -0.0079f, -0.0227f),
			Color(-0.0641f, -0.0441f, 0.1206f),
			Color(-0.0033f, -0.0109f, -0.0670f)
			);

		UniformHandle u_sunLuminance;
		UniformHandle u_skyLuminanceXYZ;
		UniformHandle u_skyLuminance;
		UniformHandle u_sunDirection;
		UniformHandle u_parameters;
		UniformHandle u_perezCoeff;

		IndexBufferHandle _ibh;
		VertexBufferHandle _vbh;
		ProgramHandle _skyProgram;

		VertexLayout _vertLayout;

		int numIndices;
		int numVertices;

		float _turbidity = 2.15f;
		public float Turbidity { get => _turbidity; set => _turbidity = value; }

		const float SUN_SIZE_MULTIPLIER = 0.02f;
		float _sunSize = 1f;
		public float SunSize { get => _sunSize; set => _sunSize = value; }

		float _sunBloom = 3f;
		public float SunBloom { get => _sunBloom; set => _sunBloom = value; }
		float _exposition = 0.1f;

		SunController _sun = new .() ~ delete _;
		public SunController SunController => _sun;
		public DirectionalLight Sun;

		public void Init(uint32 verticalCount, uint32 horizontalCount, BgfxRenderServer server)
		{
			_vertLayout = VertexDescriptors.Create(typeof(ScreenPosVertex));

			u_sunLuminance = bgfx.create_uniform("u_sunLuminance", .Vec4, 1);
			u_skyLuminanceXYZ = bgfx.create_uniform("u_skyLuminanceXYZ", .Vec4, 1);
			u_skyLuminance = bgfx.create_uniform("u_skyLuminance", .Vec4, 1);
			u_sunDirection = bgfx.create_uniform("u_sunDirection", .Vec4, 1);
			u_parameters = bgfx.create_uniform("u_parameters", .Vec4, 1);
			u_perezCoeff = bgfx.create_uniform("u_perezCoeff", .Vec4, 5);
			_skyProgram = server.GetShader("dynamic_skybox");

			numVertices = verticalCount * horizontalCount;
			ScreenPosVertex[] _vertices = new:ScopedAlloc! .[numVertices];

			for (int i = 0; i < verticalCount; i++)
			{
				for (int j = 0; j < horizontalCount; j++)
				{
					_vertices[i * verticalCount + j] = .(
						float(j) / (horizontalCount - 1) * 2.0f - 1.0f,
						float(i) / (verticalCount - 1) * 2.0f - 1.0f);
				}
			}

			numIndices = (verticalCount - 1) * (horizontalCount - 1) * 6;
			uint16[] _indices = new:ScopedAlloc! .[numIndices];

			int k = 0;
			for (int i = 0; i < verticalCount - 1; i++)
			{
				for (int j = 0; j < horizontalCount - 1; j++)
				{
					_indices[k++] = (uint16)(j + 0 + horizontalCount * (i + 0));
					_indices[k++] = (uint16)(j + 1 + horizontalCount * (i + 0));
					_indices[k++] = (uint16)(j + 0 + horizontalCount * (i + 1));

					_indices[k++] = (uint16)(j + 1 + horizontalCount * (i + 0));
					_indices[k++] = (uint16)(j + 1 + horizontalCount * (i + 1));
					_indices[k++] = (uint16)(j + 0 + horizontalCount * (i + 1));
				}
			}

			_vbh = bgfx.create_vertex_buffer(bgfx.copy(_vertices.CArray(), (uint32)(sizeof(ScreenPosVertex) * _indices.Count)), &_vertLayout, 0);
			_ibh = bgfx.create_index_buffer(bgfx.copy(_indices.CArray(), (uint32)(sizeof(uint16) * _indices.Count)), 0);
		}

		static void ComputePerezCoeff<N>(float _turbidity, ref Vector4[N] _outPerezCoeff) where N : const int
		{
			Vector3 turbidity = .(_turbidity);
			for (int ii = 0; ii < N; ++ii)
			{
				_outPerezCoeff[ii] = .((ABCDE_t[ii] * turbidity) + ABCDE[ii], 0);
			}
		}

		public void Draw(uint16 viewId)
		{
			const let DAY_START = 150;
			const let DAY_LENGTH = 600;
			let time = ((DAY_START + Time.TimeSinceStart) % DAY_LENGTH) / DAY_LENGTH;
			SunController.Update(time);	// @TODO - use directional light as source for sun position

			Color4f sunLuminanceXYZ = _sunLuminanceXYZ.GetValue(time);
			Color4f sunLuminanceRGB = xyzToRgb(sunLuminanceXYZ);

			Color4f skyLuminanceXYZ = _skyLuminanceXYZ.GetValue(time);
			Color4f skyLuminanceRGB = xyzToRgb(skyLuminanceXYZ);

			bgfx.set_uniform(u_sunLuminance, &sunLuminanceRGB, 1);
			bgfx.set_uniform(u_skyLuminanceXYZ, &skyLuminanceXYZ, 1);
			bgfx.set_uniform(u_skyLuminance, &skyLuminanceRGB, 1);

			var sunDir = SunController.Direction;
			bgfx.set_uniform(u_sunDirection, &sunDir, 1);

			Vector4 exposition = .(_sunSize * SUN_SIZE_MULTIPLIER, _sunBloom, _exposition, time * 24);
			bgfx.set_uniform(u_parameters, &exposition, 1);

			Vector4[5] perezCoeff = ?;
			ComputePerezCoeff(_turbidity, ref perezCoeff);
			bgfx.set_uniform(u_perezCoeff, &perezCoeff, perezCoeff.Count);
			
			bgfx.set_state(.WriteRgb | .DepthTestEqual, 0);
			bgfx.set_index_buffer(_ibh, 0, (uint32)numIndices);
			bgfx.set_vertex_buffer(0, _vbh, 0, (uint32)numVertices);
			bgfx.submit(viewId, _skyProgram, 0, .None);
		}
	}
}
