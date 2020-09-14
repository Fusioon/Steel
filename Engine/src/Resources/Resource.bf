using System;
using System.Threading;

namespace SteelEngine
{
	public abstract class Resource : IDisposable
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


		public RID ResourceId { get; private set; }

#region REFCOUNT

		private int32 _refCount = 1;

		protected this()
		{
		}

		private ~this()
		{
			// maybe we can never call the destructor and load when refcount is 0
			Assert!(_refCount == 0);
		}

		public int RefCount => _refCount;

		public void AddRef()
		{
			Interlocked.Increment(ref _refCount);
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
			Delete();
		}

		public virtual void Dispose()
		{
			if (ReleaseRefNoDelete() == 0)
			{
				Release();
			}
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
		public static void DisposeSafe(this Resource instance)
		{
			if (instance != null)
				instance.Dispose();
		}
	}	

}
