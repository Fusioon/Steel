using System;
using System.Collections;

using SteelEngine;
using SteelEngine.Input;
using SteelEngine.ECS.Components;
using SteelEngine.ECS;
using SteelEngine.ECS.Systems;
using SteelEngine.Renderer;

namespace BasicSteelGame
{
	public class Game : IGame
	{
		const String QUIT_ACTION_NAME = "quit_app";
		const String SPAWN_ENT_ACTION_NAME = "spawn_ent";

		public Result<void> Setup()
		{
			return .Ok;
		}

		public Result<void> Init()
		{
			return .Ok;
		}

		void Create3DScene()
		{
			if (let entity = Application.Instance.CreateEntity())
			{
				entity.AddComponent<MyBehavior>();
				entity.AddComponent<SpriteComponent>();
				entity.AddComponent(new MyBehavior());
				entity.AddComponent(new SpriteComponent());
			}
			if (let entity = Application.Instance.CreateEntity())
			{
				let cam = entity.AddComponent<Camera3D>();
				cam.clearColor = .(255, 71, 0xAA, 0xFF);
				entity.AddComponent<FreecamBehavior>();
				cam.clearFlags = .DepthAndColor | .Skybox;
			}
		}

		Transform2D hero;
		Camera2D camera;

		void Create2DScene()
		{
			// For some unknown reason this can create linker errors 
			// FIX: comment out the function call on the next line -> clean -> build -> uncomment -> now build should work
			Image img = ResourceManager.Load<Image>("res://sprites/hero.png");
			defer img.Unref();
			ImageTexture texture = new ImageTexture(img);
			defer texture.Unref();
			texture.[Friend]Load();

			if (let entity = Application.Instance.CreateEntity())
			{
				hero = entity.AddComponent<Transform2D>();
				let sprite = new Sprite();
				defer sprite.Unref();
				sprite.SetData(texture, .(0, 0, 43, 37));

				let spriteComponent = entity.AddComponent<SpriteComponent>();
				spriteComponent.sprite = sprite..AddRef();
			}

			/*if (let entity = Application.Instance.CreateEntity())
			{
				entity.AddComponent<Transform2D>().position = .(48, 0);
				let sprite = new Sprite();
				defer sprite.Unref();
				sprite.SetData(texture, .(57, 263, 43, 37));

				let spriteComponent = entity.AddComponent<SpriteComponent>();
				spriteComponent.sprite = sprite..AddRef();
			}*/

			if (let entity = Application.Instance.CreateEntity())
			{
				entity.AddComponent<Transform2D>();
				camera = entity.AddComponent<Camera2D>();
				// 009DFF
				camera.clearColor = .(0x00, 0x9D, 0xFF, 0xFF);
			}
		}

		public void Start()
		{
			//Create3DScene();

			Create2DScene();

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

			if(hero != null)
			{
				Vector2 input = .Zero;
				if(Input.GetKey(.W)) input.y -= 1;
				if(Input.GetKey(.S)) input.y += 1;
				if(Input.GetKey(.A)) input.x -= 1;
				if(Input.GetKey(.D)) input.x += 1;

				if(input.LengthSquared > 1)
					input.Normalize();

				let speed = 0.1f;
				hero.position += input * speed;
			}
			if(camera != null)
			{
				let mouseX = Input.GetAxis(.MouseX);
				let mouseY = Input.GetAxis(.MouseY);
				camera.Position += .(mouseX, mouseY) * 0.01f;
			}

			/*if(Input.IsJustPressed(SPAWN_ENT_ACTION_NAME))
			{
				let entity = Application.Instance.CreateEntity();
				entity.AddComponent<Transform3D>().position = .(gRand.Next(-20, 20), gRand.Next(-20, 20),
		gRand.Next(-20, 20)); let draw = entity.AddComponent<Drawable3dComponent>(); // For some reason creates linker
		errors /*draw.Mesh = ResourceManager.Load<Mesh>("res://models/cube.obj"); draw.Material =
		ResourceManager.Load<Material>("res://test.mat");*/
			}*/
		}

		public void Shutdown()
		{
		}
	}

	// MySystem calls its own update function on each Update cycle.
	// MySystem can either be a totally new system, or it can inherit from an existing System if it desires the
	// previously defined logic.
	class MySystem : BaseSystem
	//class MySystem : BehaviorSystem
	{
		public this() : base() { }

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[](typeof(MyBehavior));
		}

		protected override void Update(EntityId entityId, List<BaseComponent> components, float delta)
		{
			if (!Entity.EntityStore.TryGetValue(entityId, let entity) || !entity.IsEnabled)
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
		public Transform3D transform;

		protected override void Update(float delta)
		{
			// On first frame, add the second component required by the RenderSpriteSystem
			if (!IsUpdated)
			{
				transform = new Transform3D();
				Parent.AddComponent(transform);
			}
			// On the next frame, remove the TransformComponent.
			// The RenderSpriteSystem will automatically unregister the SpriteComponent since the Entity has become
			// invalid for that system.
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
