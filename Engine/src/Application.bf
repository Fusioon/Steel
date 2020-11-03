using System;
using System.Collections;
using SteelEngine.Window;
using SteelEngine.Events;
using SteelEngine.Input;
using SteelEngine.ECS;
using SteelEngine.ECS.Systems;
using SteelEngine.ECS.Components;
using SteelEngine.Console;
using SteelEngine.Renderer.BGFX;

namespace SteelEngine
{
	public class Application : Singleton<Application>
	{
		public virtual StringView CompanyName => "SteelCorp";
		public virtual StringView ProductName => "SteelEngine";
		public virtual Version Version => .(0, 0, 0, 1);
		public virtual bool IsEditor => false;
		
		private bool _isRunning = false;

		public CommandLineArgs CmdArgs { get; private set; }
		private Window _window ~ delete _;
		private Window.EventCallback _eventCallback = new => OnEvent ~ delete _;

		private List<BaseSystem> _systems ~ delete _;
		private Dictionary<ComponentId, BaseComponent> _components ~ delete _;
		private List<BaseComponent> _componentsToDelete ~ delete _;
		private List<EntityId> _entitiesToRemoveFromStore ~ delete _;
		private GLFWInputManager _inputManager = new GLFWInputManager() ~ delete _;
		private GameConsole _gameConsole = new GameConsole() ~ delete _;
		private BgfxRenderServer _renderServer = new BgfxRenderServer() ~ delete _;
		private IGame _game;

		public Window MainWindow => _window;

		public this()
		{
			
		}

		public ~this()
		{
			delete CmdArgs;
		}

		/// <summary>
		/// Creates a new <see cref="SteelEngine.ECS.BaseSystem"/>. This operation is expensive, as it runs through all entities and registers viable ones to the new system.
		/// Systems should be added as close to the start of the <see cref="SteelEngine.Application"/> as possible to avoid slowdowns.
		/// </summary>
		public BaseSystem CreateSystem<T>() where T : BaseSystem
		{
			let system = new T();
			_systems.Add(system);

			for (let item in Entity.EntityStore)
			{
				let entity = item.value;
				for (let item in _components)
				{
					let component = item.value;
					if (component.Parent != null && component.Parent.Id == entity.Id)
					{
						system.[Friend]AddComponent(component);
					}
				}
				system.[Friend]RefreshEntityRegistration(entity.Id);
			}

			return system;
		}

		[NoDiscard]
		public Entity CreateEntity()
		{
			return new Entity();
		}

		public void Run(String[] args, IGame game)
		{
			CmdArgs = new .(args);

			_game = game;
			Setup();
			Init();
			
			var windowConfig = WindowConfig(1280, 720, "SteelEngine", false, true);
			_window = new Window(windowConfig, _eventCallback);
			
			Start();
			_isRunning = true;
			while (_isRunning)
			{
				Window.ProcessEvents();
				Update();
				Draw();
			}

			Cleanup(); 
		}

		
		protected virtual void Setup()
		{
			Log.AddHandle(Console.Out);

			// @TODO(fusion) add way to set this through command line arguments or cvar
			ResourceManager.[Friend]Initialize("D:\\SteelEngine\\content", CompanyName, ProductName);

			// @TODO(fusion) - find better way to add resource loaders
			ResourceManager.AddResourceLoader<ImageLoader>();
			ResourceManager.AddResourceLoader<MeshLoader>();
			ResourceManager.AddResourceLoader<ShaderLoader>();
			ResourceManager.AddResourceLoader<MaterialLoader>();

			_gameConsole.[Friend]Initialize(scope String[]("config.cfg", "res://config.cfg"), CmdArgs);
			
			_game.Setup();
		}

		// Gets called right before the window is created
		protected virtual void Start()
		{
			_renderServer.Init(_window);

			Time.[Friend]Initialize();
			_inputManager.Initialize();
			for (let system in _systems)
			{
				switch (system.[Friend]Initialize())
				{
					case .Ok: continue;
					case .Err(.AlreadyInitialized): Log.Warning("Tried to initialize a system that was already initialized.");
					case .Err(.Unknown):
					default: Log.Fatal("Unknown error initializing a system");
				}
			}

			// For testing purposes only
			/*FreeType.FT_Library lib = ?;
			if(FreeType.FT_Init_FreeType(&lib) != 0)
			{
				Runtime.Assert(false);
			}

			String tmp = scope .("res://font.ttf");
			Resources.GlobalizePath(tmp);
			tmp.EnsureNullTerminator();
			FreeType.FT_Face face = ?;
			var error = FreeType.FT_New_Face( lib,
				tmp.CStr(),
				0,
				&face );
			Runtime.Assert(error == 0);
			let size = _window.Size;
			error = FreeType.FT_Set_Char_Size(face, 0, 16 * 64, (.)size.x, (.)size.y);
			Runtime.Assert(error == 0);
			let glyphIndex = FreeType.FT_Get_Char_Index( face, 65 );
			error = FreeType.FT_Load_Glyph(face, glyphIndex, 0 );
			Runtime.Assert(error == 0);
			
			FreeType.FT_Err ss = (.)FreeType.FT_Render_Glyph( face.glyph,   /* glyph slot  */
				(uint)FreeType.FT_RENDER_MODE.FT_RENDER_MODE_MONO  ); /* render mode */*/
			
			_game.Start();
		}

		protected virtual void Init()
		{
			_components = new Dictionary<ComponentId, BaseComponent>();
			_componentsToDelete = new List<BaseComponent>();
			_entitiesToRemoveFromStore = new List<EntityId>();

			_systems = new List<BaseSystem>();
			// The order of these systems will greatly affect the behavior of the engine.
			// As functionality is added, the order of these updates should become more established.
			// Maybe some kind of priority filtering could be added to make sure that systems execute in a defined order established at runtime.
			CreateSystem<Physics2dSystem>();
			CreateSystem<Physics3dSystem>();
			CreateSystem<Render3DSystem>();
			CreateSystem<RenderSpriteSystem>();
			CreateSystem<RenderTextSystem>();
			CreateSystem<SoundSystem>();
			CreateSystem<BehaviorSystem>();

			_game.Init();
		}

		protected virtual void Cleanup()
		{
			_game.Shutdown();

			_window.Destroy();

			// Order of deletion is important. Deleting from lowest to highest abstraction is safe.
			for (let item in _components)
			{
				delete item.value;
			}
			_components.Clear();
			for (let item in Entity.EntityStore)
			{
				delete item.value;
			}
			Entity.EntityStore.Clear();
			for (let system in _systems)
			{
				delete system;
			}
			_systems.Clear();
		}

		// Gets called when an event occurs in the window
		public void OnEvent(Event event)
		{
			_inputManager.OnEvent(event);

			var dispatcher = scope EventDispatcher(event);
			dispatcher.Dispatch<WindowCloseEvent>(scope => OnWindowClose);
			dispatcher.Dispatch<WindowResizeEvent>(scope => OnWindowResize);
		}

		private bool OnWindowClose(WindowCloseEvent event)
		{
			_isRunning = false;
			return true;
		}

		private bool OnWindowResize(WindowResizeEvent event)
		{
			_renderServer.Resize((uint32)event.Width, (uint32)event.Height);
			return true;
		}

		protected virtual void Update()
		{
			let dt = Time.[Friend]Update();

			_inputManager.Update();

			DeleteQueuedComponents();
			DeleteQueuedEntities();

			_game.Update();

			for (let system in _systems)
			{
				system.[Friend]PreUpdate();
				system.[Friend]Update(dt);
				system.[Friend]PostUpdate();
			}

		}

		protected virtual void Draw()
		{
			for (let system in _systems)
			{
				system.[Friend]Draw();
			}

			_renderServer.Draw();
		}


		private bool AddComponent(BaseComponent component)
		{
			if (_components.ContainsKey(component.Id))
			{
				return false;
			}
			var parent = component.Parent;
			if (parent == null)
			{
				return false;
			}

			for (let item in _components)
			{
				let entityComponent = item.value;
				if (entityComponent.Parent != null && entityComponent.Parent.Id == component.Parent.Id)
				{
					// Try adding all of the entity's component. If the component is already present on a system, it will not add again.
					// This makes sure that when doing an entity registration check, all available components are in the system. This allows the systems to dynamically register whole entities to run logic on.
					for (let system in _systems)
					{
						system.[Friend]AddComponent(entityComponent);
					}
				}
			}
			for (let system in _systems)
			{
				system.[Friend]AddComponent(component);
			}
			_components[component.Id] = component;
			return true;
		}

		private void DeleteQueuedComponents()
		{
			for (let item in _components)
			{
				let component = item.value;
				if (component.IsQueuedForDeletion)
				{
					_componentsToDelete.Add(component);
				}
			}
			defer _componentsToDelete.Clear();

			for (let component in _componentsToDelete)
			{
				for (let system in _systems)
				{
					system.[Friend]RemoveComponent(component);
				}
				_components.Remove(component.Id);
				delete component;
			}
		}

		private void DeleteQueuedEntities()
		{
			for (let entityId in _entitiesToRemoveFromStore)
			{
				Entity entity = ?;
				if (Entity.EntityStore.TryGetValue(entityId, out entity))
				{
					delete entity;
					Entity.EntityStore.Remove(entityId);
				}
			}
		}

		private void QueueComponentForDeletion(BaseComponent component)
		{
			component.[Friend]IsQueuedForDeletion = true;
		}

		private bool RemoveComponent(BaseComponent component)
		{
			// Queue component for deletion. Gets dequeued if added to a system.
			QueueComponentForDeletion(component);
			return true;
		}

		private bool RemoveEntity(Entity entity)
		{
			if (entity == null)
			{
				return false;
			}
			for (let item in _components)
			{
				let component = item.value;
				if (component?.Parent != null && component.Parent.Id == entity.Id)
				{
					RemoveComponent(component);
				}
			}
			_entitiesToRemoveFromStore.Add(entity.Id);
			return true;
		}

		public virtual void Quit()
		{
			// @TODO - override in editor to exit play mode
			_isRunning = false;
		}
	}
}
