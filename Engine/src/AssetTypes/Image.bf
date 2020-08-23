using System;
using System.IO;

namespace SteelEngine.AssetTypes
{
	enum ImageFormat
	{
		L8, //luminance
		LA8, //luminance-alpha
		R8,
		RG8,
		RGB8,
		RGBA8,
		RGBA4444,
		RGB565,
		RF, //float
		RGF,
		RGBF,
		RGBAF,
	}

	class Image
	{
		uint8[] _data ~ delete _;
		public uint32 Width { get; protected set; }
		public uint32 Height { get; protected set; }
		public ImageFormat Format { get; protected set; }
		public int MemorySize => _data?.Count ?? 0;
		public bool IsEmpty => (_data == null || _data.Count == 0);

		public this()
		{

		}

		public this(uint32 width, uint32 height, ImageFormat format, int8[] data)
		{

		}

		public Result<void, FileError> LoadBPM(StringView path)
		{
			const uint BITMAP_SIGNATURE = 0x4d42;
			const uint BITMAP_FILE_HEADER_SIZE = 14;
			const uint BITMAP_INFO_HEADER_MIN_SIZE = 40;

			FileStream reader = scope .();
			if(Assets.OpenFile(path, reader, .Read) case .Err(let err))
				return .Err(.FileOpenError(err));

			BITMAPFILEHEADER fileHeader = ?;
			reader.TryRead(Span<uint8>((uint8*)&fileHeader, BITMAP_FILE_HEADER_SIZE));
			BITMAPINFOHEADER info = ?;
			reader.TryRead(Span<uint8>((uint8*)&info, BITMAP_INFO_HEADER_MIN_SIZE));

			Assert!(info.compression == 0, "BMP loader does not support compression at the moment.");
			Assert!(info.bits >= 24, "BMP loader does not support files with less than 24 bit colors");
			Assert!(fileHeader.id == BITMAP_SIGNATURE, "BMP loader supports only \"BM\" files at the moment.");

			let readSize = info.bits / 8;

			uint8[] data = new .[info.width * Math.Abs(info.height) * readSize];

			var column = info.width;
			var row = info.height > 0 ? info.height - 1 : 0;	// if image is saved as top to bottom height should be negative value

			let rowBytesToSkip = (info.width * info.bits % 32) / 8;

			while(reader.Read<uint32>() case .Ok(let color))
			{
				let offset = (info.width * row * readSize) + --column * readSize;

				switch (info.bits) {
					case 32:
					{
						data[offset + 2] = (uint8)(color & 0xff);
						data[offset + 1] = (uint8)((color >> 8) & 0xff);
						data[offset + 0] = (uint8)((color >> 16) & 0xff);
						data[offset + 3] = (uint8)(color >> 24);
					}

					case 24:
					{
						data[offset + 2] = (uint8)(color & 0xff);
						data[offset + 1] = (uint8)((color >> 8) & 0xff);
						data[offset + 0] = (uint8)((color >> 16) & 0xff);
					}

					case 8, 4, 1: break;	// @TODO(fusion) - implement
				}

				reader.Seek(rowBytesToSkip, .Relative);
				if (column == 0) {
					column = info.width;
					if (info.height > 0)	row--;
					else row++;
				}
			}

			ImageFormat format;
			switch (info.bits) {
				case 32:
					format = .RGBA8;
				case 24:
					format = .RGB8;
				default:
					Assert!(false, "Failed to retrieve image format");
			}

			_data = data;

			return .Ok;
		}

		
		protected static bool PNGCheckResult(libpng.png_image img)
		{
			const int32 PNG_IMAGE_WARNING = 1;
			const int32 PNG_IMAGE_ERROR = 2;

			let result = ((img.warning_or_error & 0x03));
			if(result == PNG_IMAGE_ERROR)
			{
				Log.Error("Error while loading PNG image!\n{0}", img.message);
				return false;
			}

			if(result == PNG_IMAGE_WARNING)
			{
				Log.Warning("Warning while loading PNG image!\n{0}", img.message);
			}
			return true;
		}

		public Result<void, FileError> LoadPNG(StringView path)
		{
			StreamReader reader = scope .();
			if(Assets.OpenRead(path, reader) case .Err(let err))
				return .Err(.FileOpenError(err));

			String resul = scope String();
			reader.ReadToEnd(resul);

			libpng.png_image pngImg = default;
			pngImg.version = libpng.PNG_IMAGE_VERSION;
			void* fileData = resul.CStr();
			uint fsize = (.)resul.Length;
			int32 success = libpng.png_image_begin_read_from_memory(&pngImg, fileData, fsize);
			ImageFormat dstFormat = ?;
			switch(pngImg.format)
			{
			case .Gray: dstFormat = .L8;
			case .GA: dstFormat = .LA8;
			case .RGB: dstFormat = .RGB8;
			case .RGBA: dstFormat = .RGBA8;
			default: break;
			}

			if (!PNGCheckResult(pngImg))
				return .Err(.FileReadError(.Unknown));

			let stride = libpng.ImageRowStride!(pngImg);
			let bufferSize = libpng.ImageBufferSize!(pngImg, stride);
			uint8[] buffer = new .[bufferSize];
			success = libpng.png_image_finish_read(&pngImg, null, buffer.CArray(), (.)stride, null);
			if (!PNGCheckResult(pngImg))
			{
				delete buffer;
				return .Err(.FileReadError(.Unknown));
			}

			_data = buffer;
			Width = pngImg.width;
			Height = pngImg.height;
			Format = dstFormat;
			
			return .Ok;
		}
	}
}
