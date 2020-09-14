using System;
using System.IO;

namespace SteelEngine
{
	public abstract class ResourceLoader
	{
		public abstract Type ResourceType { get; }
		public abstract Span<StringView> SupportedExtensions { get; }
		public abstract Result<Resource> Load(StringView absolutePath, StringView originalPath, Stream fileReadStream);
		public abstract bool HandlesType(Type type);
	}
}
