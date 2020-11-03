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

		public RID ResourceId { get; private set; }

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
			}
		}

		private void Unload()
		{
			if(!IsLoaded)
				return;

			if(OnUnload() == .Ok)
			{
				IsLoaded = false;
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

	public class SharedResource : Resource
	{
		/*public this(Resource from)
		{

		}*/
	}

	public static
	{
		public static void UnrefSafe(this Resource instance)
		{
			if (instance != null)
				instance.Unref();
		}
	}	

}
