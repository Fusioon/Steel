using System;
using System.IO;
using SteelEngine.Renderer;
using SteelEngine.Loaders;

namespace SteelEngine.Resources.Loaders
{
	public class ImageLoader : ResourceLoader<Image>
	{
		static let EXTENSIONS = new StringView[](".bmp", ".png", ".tga") ~ delete _;
		public override Span<StringView> SupportedExtensions => EXTENSIONS;

		public override Result<void> Load(StringView absolutePath, StringView originalPath, Stream fileReadStream, Image r_image)
		{
			String ext = scope .();
			if (Path.GetExtension(absolutePath, ext) case .Err)
			{
				Log.Error("ImageLoader::Load - Failed to load resource! (Couldn't get file extension)");
				return .Err;
			}

			switch (ext)
			{
			case ".bmp":
				{
					if (LoadBMP(fileReadStream, r_image) case .Ok)
					{
						return .Ok;
					}
				}

			case ".png":
				{
					if (LoadPNG(scope .(fileReadStream), r_image) case .Ok)
					{
						return .Ok;
					}
				}

			case ".tga":
				{
					if (LoadTGA(fileReadStream, r_image) case .Ok)
					{
						return .Ok;
					}
				}
			}

			return .Err;
		}

		public static Result<void> LoadBMP(Stream reader, Image image)
		{
			const uint BITMAP_SIGNATURE = 0x4d42;
			const uint BITMAP_FILE_HEADER_SIZE = 14;
			const uint BITMAP_INFO_HEADER_MIN_SIZE = 40;

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
			var row = info.height > 0 ? info.height - 1 : 0;// if image is saved as top to bottom height should be
			// negative 	value

			let rowBytesToSkip = (info.width * info.bits % 32) / 8;

			while (reader.Read<uint32>() case .Ok(let color))
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

				case 8,4,1: break;// @TODO(fusion) - implement
				}

				reader.Seek(rowBytesToSkip, .Relative);
				if (column == 0)
				{
					column = info.width;
					if (info.height > 0) row--;
					else row++;
				}
			}

			PixelFormat format;
			switch (info.bits) {
			case 32:
				format = .RGBA8;
			case 24:
				format = .RGB8;

			case 8: fallthrough;
			case 4: fallthrough;
			case 1:
				{
					Log.Error("BMPImageLoader - Unsupported image format!");
					return .Err;
				}

			default:
				Assert!(false, "Failed to retrieve image format");
				return .Err;
			}

			image.SetData((uint32)info.width, (uint32)info.height, format, data);
			return .Ok;
		}


		protected static bool PNGCheckResult(libpng.png_image img)
		{
			const int32 PNG_IMAGE_WARNING = 1;
			const int32 PNG_IMAGE_ERROR = 2;

			let result = ((img.warning_or_error & 0x03));
			if (result == PNG_IMAGE_ERROR)
			{
				Log.Error($"Error while loading PNG image!\n{img.message}");
				return false;
			}

			if (result == PNG_IMAGE_WARNING)
			{
				Log.Warning($"Warning while loading PNG image!\n{img.message}");
			}
			return true;
		}

		public Result<void> LoadPNG(StreamReader reader, Image image)
		{
			String resul = scope String();
			reader.ReadToEnd(resul);

			libpng.png_image pngImg = default;
			pngImg.version = libpng.PNG_IMAGE_VERSION;
			void* fileData = resul.CStr();
			uint fsize = (.)resul.Length;
			int32 success = libpng.png_image_begin_read_from_memory(&pngImg, fileData, fsize);
			PixelFormat dstFormat = ?;
			switch (pngImg.format)
			{
			case .Gray: dstFormat = .L8;
			case .GA: dstFormat = .LA8;
			case .RGB: dstFormat = .RGB8;
			case .RGBA: dstFormat = .RGBA8;
			default: break;
			}

			if (!PNGCheckResult(pngImg))
				return .Err;

			let stride = libpng.ImageRowStride!(pngImg);
			let bufferSize = libpng.ImageBufferSize!(pngImg, stride);
			uint8[] buffer = new .[bufferSize];
			success = libpng.png_image_finish_read(&pngImg, null, buffer.CArray(), (.)stride, null);
			if (!PNGCheckResult(pngImg))
			{
				delete buffer;
				return .Err;
			}

			image.SetData(pngImg.width, pngImg.height, dstFormat, buffer);
			return .Ok;
		}

		public static Result<void> LoadTGA(Stream reader, Image image)
		{
			TGAHeader header = .FromStream(reader);
			defer header.Dispose();
			// Invalid image size
			if (header.width == 0 || header.height == 0)
				return .Err;

			// Skip ID string (idLength bytes)
			if (header.idLength > 0)
			{
				header.imageId = new String();
				uint8 i = header.idLength;
				while (i-- != 0)
				{
					char8 chr = reader.Read<char8>();
					header.imageId.Append(chr);
				}
			}

			let hasAlpha = (header.bitsPerPixel == 32) || (header.bitsPerPixel == 16);
			if (header.colormapType == 1)
				TGAColormap.Read(reader, ref header);

			if (!(header.ValidColormapType && header.Valid))
			{
				return .Err;
			}



			return .Ok;
		}

	}
}
