using System;
using System.Threading;

namespace SteelEngine
{
	public abstract class Resource : IDisposable, IHashable
	{
		protected String _name ~ delete _;
		protected String _path ~ delete _;
		public virtual StringView Name => _name;
		public virtual StringView Path => _path;

		void SetPath(StringView path)
		{
			if (_path == null)
				_path = new String();

			_path.Set(path);
		}

		public bool IsLoaded { get; protected set; }

		//public virtual RID ResourceId { get; protected set; }

		public int GetHashCode()
		{
			return _path.GetHashCode();
		}

		private void Load()
		{
			if(IsLoaded)
				return;

			if(OnLoad() == .Ok)
			{
				IsLoaded = true;
				ResourceManager.[Friend]ResourceEventLoad(this);
			}
		}

		private void Unload()
		{
			if(!IsLoaded)
				return;

			if(OnUnload() == .Ok)
			{
				IsLoaded = false;
				ResourceManager.[Friend]ResourceEventUnload(this);
			}
		}

		protected virtual Result<void> OnLoad() => .Ok;
		protected virtual Result<void> OnUnload() => .Ok;

#region REFCOUNT

		private int32 _refCount = 1;

		protected this()
		{
			IsLoaded = false;
		}

		private ~this()
		{
			Assert!(_refCount == 0);
		}

		public int RefCount => _refCount;

		public void AddRef()
		{
			Assert!(_refCount >= 1);
			Interlocked.Increment(ref _refCount);
		}

		public void Unref()
		{
			if (ReleaseRefNoDelete() == 0)
			{
				Release();
			}
		}

		protected int ReleaseRefNoDelete()
		{
			int refCount = Interlocked.Decrement(ref _refCount);
			Assert!(refCount >= 0);
			return refCount;
		}

		private void Delete()
		{
			_refCount = 0;
			delete this;
		}

		protected virtual void Release()
		{
			Unload();
			Delete();
		}

		public void IDisposable.Dispose()
		{
			Unref();
		}

#endregion REFCOUNT

	}

	// Even tho i made this class i still don't know what is the purpose
	/*public class SharedResource : Resource
	{
		/*public this(Resource from)
		{

		}*/
	}*/

	public static
	{
		public static void UnrefSafe(this Resource instance)
		{
			if (instance != null)
				instance.Unref();
		}
	}	

}
