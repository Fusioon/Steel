namespace System.IO
{
	extension Path
	{
		public static StringView GetFileNameWithoutExtension(StringView inPath)
		{
			int lastSlash = Math.Max(inPath.LastIndexOf('\\'), inPath.LastIndexOf('/'));

			int i;
			if ((i = inPath.LastIndexOf('.')) != -1)
			{
				int len = i - lastSlash - 1;
				if (len > 0)
				{
					return .(inPath, lastSlash + 1, i - lastSlash - 1);
				}
			}

			return .(inPath, lastSlash);
		}

		public static StringView GetFileName(StringView inPath)
		{
			Runtime.NotImplemented();
			if (inPath.IsEmpty)
				return default;

			CheckInvalidPathChars(inPath);

			int length = inPath.Length;
			for (int i = length; --i >= 0; )
			{
				char8 ch = inPath[i];
				if (ch == DirectorySeparatorChar || ch == AltDirectorySeparatorChar || ch == VolumeSeparatorChar)
				{
					//outFileName.Append(inPath, i + 1, length - i - 1);
					return .();
				}
			}
			//outFileName.Append(inPath);
			return .();

		}
	}
}
