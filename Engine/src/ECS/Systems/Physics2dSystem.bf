using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class Physics2dSystem : BaseSystem
	{
		public this() : base() {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]( typeof(Physics2dComponent), typeof(Transform3D) );
		}
	}
}
