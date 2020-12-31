using System;
using SteelEngine.Input;
using SteelEngine.Math;

using SteelEngine.Renderer;
namespace SteelEngine.ECS.Components
{
	class FreecamBehavior : BehaviorComponent
	{
		Vector3 _position = .(0, 0, 15);
		Vector3 _currentRotation = .(-0.12f, 4.93f, 0);
		Vector3 _targetRotation = .(-0.12f, 4.93f, 0);

		float[2] _smoothVelocity;

		float _smoothTime = 0.05f;

		protected override void Update(float delta)
		{
			const float mouseSens = 0.3f;
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

			_targetRotation.x += mouseY * mouseSens;
			_targetRotation.y += mouseX * mouseSens;
			_targetRotation.x = Math.Clamp(_targetRotation.x, Deg2Rad!(-89.5f), Deg2Rad!(89.5f));

			_currentRotation.x = Math.SmoothDamp(_currentRotation.x, _targetRotation.x, ref _smoothVelocity[0], _smoothTime, float.MaxValue, Time.DeltaTime);
			_currentRotation.y = Math.SmoothDamp(_currentRotation.y, _targetRotation.y, ref _smoothVelocity[1], _smoothTime, float.MaxValue, Time.DeltaTime);

			let quat = Quaternion.FromEulerAngles(_currentRotation);
			_position += dir * quat.ToMatrix44();

			if (Input.GetKey(.Space))
				_position.y += speedDt;
			if (Input.GetKey(.LeftControl))
				_position.y -= speedDt;

			Parent.GetComponent<Camera3D>().SetPositionRotation(_position, quat);
		}
	}
}
