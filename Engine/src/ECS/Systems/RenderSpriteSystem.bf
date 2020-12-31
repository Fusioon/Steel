using SteelEngine.ECS.Components;
using System.Collections;
using System;
using SteelEngine.Renderer;

namespace SteelEngine.ECS.Systems
{
	public class RenderSpriteSystem : BaseSystem
	{
		public this() : base() {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]( typeof(SpriteComponent), typeof(Transform2D) );
		}

		protected override void Draw(uint64 entityId, List<BaseComponent> components)
		{
			Transform2D transform = null;
			SpriteComponent spriteComponent = null;
			for(let c in components)
			{
				if(c is Transform2D)
					transform = (.)c;
				if(c is SpriteComponent)
					spriteComponent = (.)c;
			}

			if (transform != null && spriteComponent != null)
			{
				RenderServer.Instance.DrawSprite(transform, spriteComponent.sprite);
			}
		}
	}
}
