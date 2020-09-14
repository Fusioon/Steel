using System;
using SteelEngine;
using SteelEngine.Input;
using SteelEngine.ECS.Components;
using SteelEngine.ECS;
using SteelEngine.ECS.Systems;
using System.Collections;

public static
{
	[CLink]
	public static extern Windows.IntBool IsDebuggerPresent();
}


namespace BasicSteelGame
{
	class GameImpl : IGame
	{
		const String QUIT_ACTION_NAME = "quit_app";
		const String SPAWN_ENT_ACTION_NAME = "spawn_ent";

		public Result<void> Setup()
		{
			IsDebuggerPresent();

			return .Ok;
		}

		public Result<void> Init()
		{
			return .Ok;
		}

		public void Start()
		{
			let entity = Application.Instance.CreateEntity();

			entity.AddComponent(new MyBehavior());
			// Even adding a system after entity creation should register the components it requires.
			//Application.Instance.CreateSystem<MySystem>();

			// Only registering one of the required Components for the RenderSpriteSystem should cause the SpriteComponent to not register with the system.
			entity.AddComponent(new SpriteComponent());

			Input.SetInputMapping(QUIT_ACTION_NAME, .Escape);
			Input.SetInputMapping(SPAWN_ENT_ACTION_NAME, .Q);
			Input.SetCursorState(.Confined);
		}

		public void Update()
		{
			if (Input.IsJustPressed(QUIT_ACTION_NAME))
			{
				Application.Instance.Quit();
			}
			if(Input.IsJustPressed(SPAWN_ENT_ACTION_NAME))
			{
				let entity = Application.Instance.CreateEntity();
				entity.AddComponent<TransformComponent>().Position = .(gRand.Next(-20, 20), gRand.Next(-20, 20), gRand.Next(-20, 20));
				let draw = entity.AddComponent<Drawable3dComponent>();
				draw.Mesh = Resources.Load<Mesh>("res://models/cube.obj")..Dispose();
				draw.Material = Resources.Load<Material>("res://test.mat")..Dispose();
			}
		}

		public void Shutdown()
		{

		}
	}

	// MySystem calls its own update function on each Update cycle.
	// MySystem can either be a totally new system, or it can inherit from an existing System if it desires the previously defined logic.
	class MySystem : BaseSystem
	//class MySystem : BehaviorSystem
	{
		public this() : base() {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(MyBehavior) };
		}

		protected override void Update(EntityId entityId, List<BaseComponent> components, float delta)
		{
			Entity entity = ?;
			if (!Entity.EntityStore.TryGetValue(entityId, out entity) || !entity.IsEnabled)
			{
				return;
			}
			
			for (let component in components)
			{
				if (!component.IsEnabled)
				{
					continue;
				}
				(component as MyBehavior).[Friend]MyUpdate(delta);
			}
		}

		protected override void Draw(EntityId entityId, List<BaseComponent> components)
		{
			for (let component in components)
			{
				if (!component.IsEnabled)
				{
					continue;
				}
				(component as MyBehavior).[Friend]MyDraw();
			}
		}
	}

	class MyBehavior : BehaviorComponent
	{
		public bool IsUpdated = false;
		public TransformComponent transform;

		protected override void Update(float delta)
		{
			// On first frame, add the second component required by the RenderSpriteSystem
			if (!IsUpdated)
			{
				transform = new TransformComponent();
				Parent.AddComponent(transform);
			}
			// On the next frame, remove the TransformComponent.
			// The RenderSpriteSystem will automatically unregister the SpriteComponent since the Entity has become invalid for that system.
			else if (Parent.RemoveComponent(transform))
			{
				transform = null;
			}
			IsUpdated = true;

			//Console.WriteLine("BehaviorSystem update hook");
		}

		protected void MyDraw()
		{
			//Console.WriteLine("MySystem draw hook");
		}

		protected void MyUpdate(float delta)
		{
			//Console.WriteLine("MySystem update hook");
		}
	}
}