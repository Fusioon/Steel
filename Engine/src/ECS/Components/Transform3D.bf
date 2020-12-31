using System;
namespace SteelEngine.ECS.Components
{
	public class Transform3D : BaseComponent
	{
		public Vector3 position = .Zero;
		public Quat rotation = .Identity;
		public Vector3 scale = .One;
	}
}
