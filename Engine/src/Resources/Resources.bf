using System;
using System.IO;
using System.Collections;

namespace SteelEngine
{
	public static class Resources
	{
		private static String _contentPath ~ delete _;
		private static String _userPath ~ delete _;

		static Dictionary<StringView, ResourceLoader> _resourceLoadersFileExts = new Dictionary<StringView, ResourceLoader>() ~ delete _;
		static List<ResourceLoader> _resourceLoaders = new List<ResourceLoader>() ~ DeleteContainerAndItems!(_);
		static Dictionary<StringView, Resource> _loadedResources = new Dictionary<StringView, Resource>() ~ delete _;

		static ~this()
		{
			/*for(let res in _loadedResources.Values)
			{
				if(res.RefCount > 0)
				{
					res.[Friend]Delete();
				}
			}*/

			for(let res in _sharedResources.Values)
			{
				if(res.RefCount > 0)
				{
					res.[Friend]Delete();
				}
			}	
		}

		static void Initialize(StringView contentPath, StringView companyName, StringView appName)
		{
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

			if(!_contentPath.EndsWith(Path.DirectorySeparatorChar))
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

			Path.InternalCombine(_userPath, scope .(companyName), scope .(appName));
			if ((Directory.CreateDirectory(_userPath) case .Err(let err)) && err != .AlreadyExists)
			{
				Log.Fatal("Couldn't create User directory! {}", err);
			}
		}

		public static T AddResourceLoader<T>() where T : ResourceLoader, new, delete
		{
			let loader = new T();

			for (let ext in loader.SupportedExtensions)
			{
				if (!_resourceLoadersFileExts.TryAdd(ext, loader))
				{
					String name = scope .();
					typeof(T).GetFullName(name);
					Log.Error("Error registering {}. Resource loader for {} files is already defined!", name, ext);
				}
			}
			_resourceLoaders.Add(loader);
			return loader;
		}

		public static void GlobalizePath(String path)
		{
			path.Replace("res://", _contentPath);
			path.Replace("user://", _userPath);
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

			
			if (res == null)
			{
				if (_resourceLoadersFileExts.TryGetValue(ext, let loader) && loader.HandlesType(typeof(T)))
				{
					res = (T)loader.Load(path, path, fstream);
					res.[Friend]SetPath(path);
				}
				else
				{
					return .Err(.FileReadError(.Unknown));
				}
			}
			else if (res.RefCount == 0)
			{
				res.AddRef();
			}

			_loadedResources[res.Path] = res;

			return .Ok(res);
		}


		static Dictionary<StringView, SharedResource> _sharedResources = new .() ~ delete _;

		public static T CreateSharedResource<T, O>(O from)
			where T : SharedResource, new
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
		}
	}
}
