using System;

namespace SteelEngine.ECS.Components
{
	public class TransformComponent : BaseComponent
	{
		/*
		public Vector3 Position { get; set; }
		public Vector3 Rotation { get; set; }
		public Vector3 Scale { get; set; }
		*/
		public Matrix44 matrix = .Identity;

		public Vector3 Position
		{
			[Inline] get => matrix.columns[3].xyz;
			[Inline] set mut => matrix.columns[3] = .(value, 1);
		}
	}
}
