using System;
using System.IO;

namespace SteelEngine
{
	public abstract class ResourceLoaderBase
	{
		public abstract Type ResourceType { get; }
		public abstract Span<StringView> SupportedExtensions { get; }
	}

	public abstract class ResourceLoader<T> : ResourceLoaderBase
	{
		public override Type ResourceType => typeof(T); 
		public abstract Result<void> Load(StringView absolutePath, StringView originalPath, Stream fileReadStream, T r_resource);
	}
}
