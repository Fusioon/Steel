using System;
using SteelEngine.Math;

namespace SteelEngine.Renderer
{
	public enum CameraProjectionMode
	{
		Perspective,
		Ortho
	}

	public enum CameraClearFlags
	{
		Nothing = 0,
		Color = 1,
		Depth = 2,
		DepthAndColor = .Color | .Depth,
		Skybox = 4,
	}

	public class Camera
	{
		public const float HANDEDNESS = -1;
		Matrix44 _view;
		Matrix44 _projection;

		public Matrix44 Projection => _projection;
		public Matrix44 View => _view;

		public CameraClearFlags clearFlags = .DepthAndColor;
		public Color4u clearColor = .(0,0,0, 1);

		CameraProjectionMode _mode = .Perspective;

		float _width = 1920;
		float _height = 1080;
		float _znear = 0.003f;
		float _zfar = 1000;

		float _fovy = 59;
		float _size = 5;

		public void SetPositionRotation(Vector3 position, Quaternion rotation)
		{
			_view = Matrix44.Transform(position, rotation, .One).Inverse;
		}

		public Vector3 Position
		{
			[Inline] get => _view.columns[3].xyz;
			[Inline] set mut => _view.columns[3] = .(value, 1);
		}

		public Quaternion Rotation
		{
			[Inline] get => .FromMatrix(_view.RotationMatrix);
			[Inline] set mut
			{
				let rot = value.ToMatrix();
				_view = .(
					.(rot.columns[0], _view.columns[0].w),
					.(rot.columns[1], _view.columns[1].w),
					.(rot.columns[2], _view.columns[2].w),
					_view.columns[3]
				);
			}
		}
		

		public float FieldOfView
		{
			get
			{
				return HorizontalFov(Rad2Deg!(_fovy), _width, _height);
			}
			set mut
			{
				_fovy = VerticalFov(Deg2Rad!(value), _width, _height);
				if (_mode case .Perspective) UpdateProjectionMatrix();
			}
		}

		public float Size
		{
			get
			{
				return _size;
			}
			set mut
			{
				_size = value;
				if (_mode case .Ortho) UpdateProjectionMatrix();
			}
		}

		public float ZNear
		{
			get { return _znear; }
			set mut { _znear = value; UpdateProjectionMatrix(); }
		}

		public float ZFar
		{
			get { return _zfar; }
			set mut { _zfar = value; UpdateProjectionMatrix(); }
		}

		public void SetPerspective(float width, float height, float hFov, float znear, float zfar)
		{
			_mode = .Perspective;
			_fovy = VerticalFov(Deg2Rad!(hFov), width, height);
			_width = width;
			_height = height;
			_znear = znear;
			_zfar = zfar;

			UpdateProjectionMatrix();
		}

		public void SetPerspective(Vector2 resolution, float hFov, float znear, float zfar)
		{
			SetPerspective(resolution.x, resolution.y, hFov, znear, zfar);
		}

		public void SetOrthogonal(float width, float height, float size, float znear, float zfar)
		{
			_mode = .Ortho;

			_width = width;
			_height = height;
			_znear = znear;
			_zfar = zfar;

			UpdateProjectionMatrix();
		}

		public void SetOrthogonal(Vector2 resolution, float size, float znear, float zfar)
		{
			SetOrthogonal(resolution.x, resolution.y, size, znear, zfar);
		}

		public void SetResolution(float width, float height)
		{
			_width = width;
			_height = height;
			UpdateProjectionMatrix();
		}

		protected void UpdateProjectionMatrix()
		{
			switch (_mode)
			{
			case .Perspective:
				_projection = Matrix44.Perspective(_fovy, _width / _height, _znear, _zfar, HANDEDNESS);

			case .Ortho:
				_projection = Matrix44.Ortho(-_size, _size, _size, -_size, _znear, _zfar, HANDEDNESS);
			}

			//_projection[5] *= -1;
		}

		public static float DiagonalToVerticalFov(float dFov, float width, float height)
		{
			return dFov * (height / width);
		}
		public static float VerticalToDiagonalFov(float vFov, float width, float height)
		{
			return vFov * (width / height);
		}

		public static float VerticalFov(float hFov, float width, float height)
		{
			let aspectRatio =  height / width;
			let tan = Math.Tan(hFov / 2);
			//let tanAspect = tan * aspectRatio;
			let atan = Math.Atan(tan * aspectRatio);
			//let deg = rad2deg!(atan);
			return float(2.0d * atan);
			//return real_t(2.0d *  Math.Atan(Math.Tan(hFov/2) * aspectRatio));
		}
		public static float HorizontalFov(float hFov, float width, float height)
		{
			let aspectRatio = height / width;
			return 2 * Math.Atan(Math.Tan(hFov/2) * aspectRatio);
		}
	}
}
