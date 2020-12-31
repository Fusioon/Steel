using System;
using SteelEngine.ECS.Components;
using SteelEngine.Renderer;

namespace SteelEngine.ECS.Systems
{
	class Camera2DRenderingSystem : BaseSystem
	{
		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]( typeof(Camera2D) );
		}

		protected override void Draw(uint64 entityId, System.Collections.List<BaseComponent> components)
		{
			for(let c in components)
			{
				if(c is Camera2D)
					RenderServer.Instance.DrawCamera((Camera2D)c);
			}
		}
	}

	class Camera3DRenderingSystem : BaseSystem
	{
		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]( typeof(Camera3D) );
		}

		protected override void Draw(uint64 entityId, System.Collections.List<BaseComponent> components)
		{
			for(let c in components)
			{
				if(c is Camera3D)
					RenderServer.Instance.DrawCamera((Camera3D)c);
			}
		}
	}
}
