using System;
using SteelEngine.Input;
using SteelEngine.Math;

using SteelEngine.Renderer;
namespace SteelEngine.ECS.Components
{
	class FreecamBehavior : BehaviorComponent
	{
		Camera _cam;

		Vector3 _position = .(0, 0, 15);
		Vector3 _rotation = .Zero;
		
		protected override void Update(float delta)
		{
			if(_cam == null)
			{
				_cam = Parent.GetComponent<Camera>();
				return;
			}

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

			_rotation.x += mouseY * mouseSens;
			_rotation.y += mouseX * mouseSens;
			_rotation.x = Math.Clamp(_rotation.x, Deg2Rad!(-89.9f), Deg2Rad!(89.9f));

			let quat = Quaternion.FromEulerAngles(_rotation);
			_position += dir * quat.ToMatrix44();

			if (Input.GetKey(.Space))
				_position.y += speedDt;
			if (Input.GetKey(.LeftControl))
				_position.y -= speedDt;

			_cam.SetPositionRotation(_position, quat);
		}
	}
}
