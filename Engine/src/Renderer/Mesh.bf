using System;

namespace SteelEngine.Renderer
{
	abstract class Mesh : RefCounted, IDisposable
	{
		protected String _name ~ delete _;
		public StringView Name => _name;

		protected bool _valid;

		protected abstract void Delete();

		protected this()
		{
			_valid = false;
		}

		private ~this()
		{
			Delete();
		}

		public void Dispose()
		{
			ReleaseRef();
		}


		protected abstract Result<void> SetData(Type vertexType, void* vertices, uint32 vertexCount, uint16* indices, uint32 indexCount);

		public Result<void> SetData<TVertex>(TVertex[] vertices, uint16[] indices)
		{
			if (SetData(typeof(TVertex), vertices.CArray(), (uint32)vertices.Count, indices.CArray(), (uint32)indices.Count) case .Ok)
			{
				_valid = true;
				return .Ok;
			}

			return .Err;
		}

		public Result<void> SetData<TVertex>(Span<TVertex> vertices, Span<uint16> indices)
		{
			if (SetData(typeof(TVertex), vertices.Ptr, (uint32)vertices.Length, indices.Ptr, (uint32)indices.Length) case .Ok)
			{
				_valid = true;
				return .Ok;
			}

			return .Err;
		}
	}
}
