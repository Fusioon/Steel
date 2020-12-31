using System;
using System.IO;
using System.Collections;

namespace SteelEngine
{
	public static class ResourceManager
	{
		private static String _contentPath ~ delete _;
		private static String _userPath ~ delete _;
		private static String _tmpPath ~ delete _;
		private static String _cachePath ~ delete _;


		static StdAllocator allocator = .();
		//public delegate Resource ResourceFactory(IRawAllocator allocator);

		static Dictionary<StringView, ResourceLoaderBase> _resourceLoadersFileExts = new .() ~ delete _;
		static List<ResourceLoaderBase> _resourceLoaders = new .() ~ DeleteContainerAndItems!(_);
		static Dictionary<StringView, Resource> _loadedResources = new .() ~ delete _;
		//static Dictionary<Type, ResourceFactory> _resourceCreator = new .() ~ delete _;

		public static ~this()
		{
			/*for(let res in _loadedResources.
			Values)
			{
				if(res.RefCount > 0)
				{
					res.[Friend]Delete();
				}
			}

			for(let res in _sharedResources.Values)
			{
				if(res.RefCount > 0)
				{
					res.[Friend]Delete();
				}
			}*/
		}

		static void Initialize(String contentPath, String companyName, String appName)
		{
			// To make sure we only ever call initialize once
			Runtime.Assert(_contentPath == null);

			_contentPath = new String();

			if (contentPath.IsEmpty)
			{
				Directory.GetCurrentDirectory(_contentPath);
			}
			else
			{
				_contentPath.Set(contentPath);
			}

			if (!Directory.Exists(_contentPath))
				Log.Fatal("Content path directory doesn't exist!");

			if (!_contentPath.EndsWith(Path.DirectorySeparatorChar))
				_contentPath.Append(Path.DirectorySeparatorChar);


			Dictionary<String, String> envVars = scope .();
			Environment.GetEnvironmentVariables(envVars);

			// @TODO(fusion) - this will probably only work on windows

			if (!envVars.TryGetValue("APPDATA", out _userPath))
			{
				if (!envVars.TryGetValue("USERPROFILE", out _userPath))
				{
					Log.Fatal("Couldn't get User directory!");
				}
			}

			// Current value is allocated by Environment.GetEnvironmentVariables 
			// so we create new because old one is about to get deleted
			_userPath = new String(_userPath);

			for (let kv in envVars)
			{
				delete kv.key;
				delete kv.value;
			}

			Path.InternalCombine(_userPath, companyName, appName);
			if ((Directory.CreateDirectory(_userPath) case .Err(let err)) && err != .AlreadyExists)
			{
				Log.Fatal($"Couldn't create User directory! {err}");
			}

			_tmpPath = new String();
			if (Path.GetTempPath(_tmpPath) case .Ok)
			{
				Path.InternalCombine(_tmpPath, companyName, appName, "");
				if ((Directory.CreateDirectory(_userPath) case .Err(let err)) && err != .AlreadyExists)
				{
					Log.Fatal($"Couldn't create temp directory! {err}");
				}
			}

			// @TODO(fusion) - add implementation for cache folder
			_cachePath = new String();
		}

		public static T AddResourceLoader<T>() where T : ResourceLoaderBase, new, delete
		{
			let loader = new T();

			for (let ext in loader.SupportedExtensions)
			{
				if (!_resourceLoadersFileExts.TryAdd(ext, loader))
				{
					String name = scope .();
					typeof(T).GetFullName(name);
					Log.Error(scope $"Error registering {name}. Resource loader for '{ext}' files is already defined!");
				}
			}
			_resourceLoaders.Add(loader);
			return loader;
		}

		/// Returns passed value
		public static String GlobalizePath(String path)
		{
			path.Replace("res://", _contentPath);
			path.Replace("user://", _userPath);
			path.Replace("tmp://", _tmpPath);
			path.Replace("cache://", _cachePath);
			return path;
		}

		public static Result<void, FileOpenError> OpenRead(StringView path, StreamReader stream)
		{
			String tmpPath = scope .(path);
			GlobalizePath(tmpPath);
			return stream.Open(tmpPath);
		}

		public static Result<void, FileOpenError> OpenFile(StringView path, FileStream stream, FileAccess access)
		{
			String tmpPath = scope .(path);
			GlobalizePath(tmpPath);
			return stream.Open(tmpPath, access);
		}

		[NoDiscard]
		public static Result<T, FileError> Load<T>(StringView path) where T : Resource
		{
			T res = null;
			if (_loadedResources.TryGetValue(path, let val))
			{
				res = val as T;
				if (res != null && res.RefCount != 0)
				{
					res.AddRef();
					return .Ok(res);
				}
			}

			String ext = scope .();
			if (Path.GetExtension(path, ext) case .Err)
				return .Err(.FileOpenError(.Unknown));

			FileStream fstream = scope .();
			if (OpenFile(path, fstream, .Read) case .Err(let err))
			{
				return .Err(.FileOpenError(err));
			}

			if (res == null || res.RefCount == 0)
			{
				if (res == null)
				{
					/*if (_resourceCreator.TryGetValue(typeof(T), let fn))
						res = (T)fn(allocator);
					else*/
						res = new .();
				}

				if (_resourceLoadersFileExts.TryGetValue(ext, let genericLoader))
				{
					let loader = genericLoader as ResourceLoader<T>;
					if (loader != null)
					{
						let result = loader.Load(path, path, fstream, res);
						switch (result)
						{
						case .Ok:
							res.[Friend]SetPath(path);
							_loadedResources[res.Path] = res;

						case .Err(let err):
							return .Err(err);
						}
					}
					
				}
				else
				{
					Log.Error(scope $"No resource loader registered for '{ext}' file types.");
					return .Err(.FileReadError(.Unknown));
				}
			}

			return .Ok(res);
		}


		/*static Dictionary<StringView, SharedResource> _sharedResources = new .() ~ delete _;

		public static T CreateSharedResource<T, O>(O from)
			//where T : SharedResource, new
			where O : Resource
		{
			StringView path = from.Path;

			// @TODO - handle this case properly 
			if(path.IsEmpty)
			{
				return default;
			}
			
			if(_sharedResources.TryGetAlt(from.Path, let n, let v))
			{
				return (T)v;
			}

			return (T)(_sharedResources[from.Path] = new T(from));
		}*/

		/*public static void RegisterResourceExtension<T, R>(ResourceFactory fn)
			where T : Resource
			where R : T
		{
			_resourceCreator.Add(typeof(T), fn);
		}*/

		

		static Dictionary<Type, IResourceEventHandlerInternal> _eventHandlers = new .() ~ delete _;

		public static void RegisterResourceUpdateHandler<T>(IResourceEventHandler<T> handler) where T : Resource
		{
			Assert!(!_eventHandlers.ContainsKey(typeof(T)));
			_eventHandlers.Add(typeof(T), handler);
		}

		static void ResourceEventLoad(Resource r)
		{
			if(_eventHandlers.TryGetValue(r.GetType(), let v))
				v.Loaded(r);
		}

		static void ResourceEventUnload(Resource r)
		{
			if(_eventHandlers.TryGetValue(r.GetType(), let v))
				v.Unloaded(r);
		}
	}

	using internal SteelEngine.ResourceManager;

	interface IResourceEventHandlerInternal
	{
		void Loaded(Resource resource);
		void Unloaded(Resource resource);
		//void Deleted(Resource resource);
	}

	public interface IResourceEventHandler<T> : IResourceEventHandlerInternal where T : Resource
	{
		override void Loaded(Resource resource) => Load((T)resource);
		override void Unloaded(Resource resource) => Unload((T)resource);
		//override void Deleted(Resource resource) => Deleted((T)resource);
		public void Load(T resource);
		public void Unload(T resource);
	}
}
