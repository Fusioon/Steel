using System;
using System.IO;

namespace SteelEngine
{
	public static class Assets
	{
		private static String _contentPath ~ delete _;
		private static String _userPath ~ delete _;

		static void Initialize(StringView contentPath)
		{
			if (contentPath.IsEmpty)
			{
				_contentPath = new String();
				Directory.GetCurrentDirectory(_contentPath);
			}
			else
			{
				_contentPath = new String(contentPath);
			}
				
			if (!Directory.Exists(_contentPath))
				Log.Fatal("Content path directory doesn't exist!");

			if(!_contentPath.EndsWith(Path.DirectorySeparatorChar))
				_contentPath.Append(Path.DirectorySeparatorChar);
		}

		public static void GlobalizePath(String path)
		{
			path.Replace("res://", _contentPath);

			// @TODO(fusion) - add implementation
			//path.Replace("user://", _userPath);
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
	}
}
