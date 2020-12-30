using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class Render3DSystem : BaseSystem
	{
		public this() : base() {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]( typeof(Drawable3dComponent), typeof(TransformComponent) );
		}

		protected override void Draw(uint64 entityId, List<BaseComponent> components)
		{
			TransformComponent transform = null;
			Drawable3dComponent draw3d = null;
			for(let c in components)
			{
				if(c is TransformComponent)
					transform = (.)c;
				if(c is Drawable3dComponent)
					draw3d = (.)c;
			}

			if (transform != null && draw3d != null)
			{
				draw3d.Draw(transform.matrix);
			}
		}
	}
}
