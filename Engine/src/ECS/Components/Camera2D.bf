using System;

using SteelEngine;

namespace SteelEngine.ECS.Components
{
	class Camera2D : BaseComponent
	{
		public const float HANDEDNESS = -1;

		Matrix44 _view;
		Matrix44 _proj;

		public Matrix44 View => _view;
		public Matrix44 Proj => _proj;

		Vector2 _pos = .Zero;
		float _rotation = 0;

		Vector2i _size = .(1920, 1080);
		float _zoom = 100;

		public this()
		{
			UpdateProjMatrix();
			UpdateViewMatrix();
		}

		public Color4u clearColor = .(0, 0, 0, 0xFF);

		public Vector2 Position
		{
			get => _pos;
			set
			{
				_pos = value;
				UpdateViewMatrix();
			}
		}

		public float Rotation
		{
			get => _rotation;
			set
			{
				_rotation = value;
				UpdateViewMatrix();
			}
		}

		public Vector2i Size
		{
			get => _size;
			set
			{
				_size = value;
				UpdateProjMatrix();
			}
		}

		public float Zoom
		{
			get => _zoom;
			set
			{
				_zoom = value;
				UpdateProjMatrix();
			}
		}

		void UpdateProjMatrix()
		{
			_proj = .Ortho(-_size.x, _size.x, _size.y, -_size.y, 0.01f, 1000f, HANDEDNESS) * .Scale(.(_zoom));
		}

		void UpdateViewMatrix()
		{
			_view = .Transform(.(_pos.x, _pos.y, 0), .Identity, .(1, 1, 1)).Inverse;
		}
	}
}
