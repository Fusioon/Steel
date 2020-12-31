using System;
using System.IO;
using System.Collections;

namespace SteelEngine.Loaders
{
	enum TGAImageType : uint8
	{
		NoImage = 0,
		UncompressedIndexed = 1,
		UncompressedRgb = 2,
		UncompressedGray = 3,
		RleIndexed = 9,
		RleRgb = 10,
		RleGray = 11,
	}

	class TGAColormap
	{
		this(int length)
		{
			_colors = new .(length);
		}
		typealias color_t = uint32;
		const color_t color_r_shift = 0;
		const color_t color_g_shift = 8;
		const color_t color_b_shift = 16;
		const color_t color_a_shift = 24;
		const color_t color_r_mask = 0x000000ff;
		const color_t color_g_mask = 0x0000ff00;
		const color_t color_b_mask = 0x00ff0000;
		const color_t color_rgb_mask = 0x00ffffff;
		const color_t color_a_mask = 0xff000000;

		public color_t this[int i]
		{
			get => _colors[i];
			set => _colors[i] = value;
		}

		List<color_t> _colors ~ delete _;


		public static color_t rgba(uint8 r, uint8 g, uint8 b, uint8 a = 255)
		{
			return (((color_t)r << color_r_shift) |
				((color_t)g << color_g_shift) |
				((color_t)b << color_b_shift) |
				((color_t)a << color_a_shift));
		}

		[Inline]
		public static uint8 scale_5bits_to_8bits(uint8 v)
		{
			Assert!(/*v >= 0 &&*/ v < 32);
			return (v << 3) | (v >> 2);
		}

		public static void Read(Stream reader, ref TGAHeader header)
		{
			Assert!(header.colormap == null);

			header.colormap = new TGAColormap(header.colormapLength);

			for (int i = 0; i < header.colormapLength; ++i)
			{
				switch (header.colormapDepth) {

				case 15:
				case 16:
					{
						uint16 c = reader.Read<uint16>();
						header.colormap[i] =
							rgba(scale_5bits_to_8bits((uint8)(c >> 10) & 0x1F),
							scale_5bits_to_8bits((uint8)(c >> 5) & 0x1F),
							scale_5bits_to_8bits((uint8)c & 0x1F));
						break;
					}

				case 24:
				case 32:
					{
						uint8 b = reader.Read<uint8>();
						uint8 g = reader.Read<uint8>();
						uint8 r = reader.Read<uint8>();
						uint8 a = header.colormapDepth == 32 ? reader.Read<uint8>() : 0xFF;
						header.colormap[i] = rgba(r, g, b, a);
						break;
					}
				}
			}
		}
	}

	struct TGAImage
	{
		public uint8* pixels;
		public uint32 bytesPerPixel;
		public uint32 rowstride;
	}


	public struct TGAHeader : IDisposable
	{
		public uint8 idLength;
		public uint8 colormapType;
		public TGAImageType imageType;
		public uint16 colormapOrigin;
		public uint16 colormapLength;
		public uint8 colormapDepth;
		public uint16 xOrigin;
		public uint16 yOrigin;
		public uint16 width;
		public uint16 height;
		public uint8 bitsPerPixel;
		public uint8 imageDescriptor;
		public String imageId;
		public TGAColormap colormap;

		public bool LeftToRight => !(imageDescriptor & 0x10 != 0);
		public bool TopToBottom => (imageDescriptor & 0x20 != 0);

		public bool HasColormap => (colormapLength > 0);

		public bool IsRGB => (imageType == .UncompressedRgb ||
			imageType == .RleRgb);

		public bool IsIndexed => (imageType == .UncompressedIndexed ||
			imageType == .RleIndexed);

		public bool IsGray => (imageType == .UncompressedGray ||
			imageType == .RleGray);

		public bool IsUncompressed => (imageType == .UncompressedIndexed ||
			imageType == .UncompressedRgb ||
			imageType == .UncompressedGray);

		public bool IsRle => (imageType == .RleIndexed ||
			imageType == .RleRgb ||
			imageType == .RleGray)

		public bool ValidColormapType =>// // Indexed with palette
			(IsIndexed && bitsPerPixel == 8 && colormapType == 1) ||// Grayscale
		// without palette
			(IsGray && bitsPerPixel == 8 && colormapType == 0) ||// Non-indexed without
		// palette
			(bitsPerPixel > 8 && colormapType == 0);

		public bool Valid
		{
			get
			{
				switch (imageType)
				{
				case .UncompressedIndexed: fallthrough;
				case .RleIndexed:
					return (bitsPerPixel == 8);

				case .UncompressedRgb: fallthrough;
				case .RleRgb:
					return (bitsPerPixel == 15 ||
						bitsPerPixel == 16 ||
						bitsPerPixel == 24 ||
						bitsPerPixel == 32);

				case .UncompressedGray: fallthrough;
				case .RleGray:
					return (bitsPerPixel == 8);

				default: break;
				}
				return false;
			}
		}


		// // Returns the number of bytes per pixel needed in an image created with this Header information.
		public int BytesPerPixel
		{
			get
			{
				if (IsRGB)
					return 4;

				return 1;
			}
		}

		public static Result<Self> FromStream(Stream str)
		{
			Self header = .();
			header.idLength = str.Read<uint8>();
			header.colormapType = str.Read<uint8>();
			header.imageType = str.Read<TGAImageType>();
			header.colormapOrigin = str.Read<uint16>();
			header.colormapLength = str.Read<uint16>();
			header.colormapDepth = str.Read<uint8>();
			header.xOrigin = str.Read<uint16>();
			header.yOrigin = str.Read<uint16>();
			header.width = str.Read<uint16>();
			header.height = str.Read<uint16>();
			header.bitsPerPixel = str.Read<uint8>();
			header.imageDescriptor = str.Read<uint8>();

			return header;
		}

		public void Dispose()
		{
			delete imageId;
			delete colormap;
		}

		function uint32 ReadFunction(Stream str);

		bool ReadUncompressedData<T>(Stream str, uint8[] buffer, ref int pos, ReadFunction readPixel) where T : operator explicit uint32
		{
			for (int x = 0; x < width; ++x)
			{
			  /*if (m_iterator.putPixel<T>((this->*readPixel)()))
				return true;*/
				*(T*)&buffer[pos++] = (T)readPixel(str);
			}

			return false;
		}

		bool ReadRleData<T>(Stream str, uint8[] buffer, ref int pos, ReadFunction readPixel) where T : operator explicit uint32
		{
			for (int x = 0; x < width && str.CanRead;)
			{
				int c = read8(str);
				if (c & 0x80 != 0)
				{
					c = (c & 0x7f) + 1;
					x += c;
					T pixel = (T)readPixel(str);
					while (c-- > 0)
					{
						*(T*)&buffer[pos++] = pixel;
						/*if (m_iterator.putPixel<T>(pixel))
						  return true;*/
					}
					return true;
				}
				else
				{
					++c;
					x += c;
					while (c-- > 0)
					{
						*(T*)&buffer[pos++] = (T)readPixel(str);
					}
					return true;
				}
			}
			return false;
		}

		public Result<void> Read(Stream str, uint8[] buffer)
		{
			// Bit 4 means right-to-left, else left-to-right
			// Bit 5 means top-to-bottom, else bottom-to-top 
			// m_iterator = details::ImageIterator(header, image);
			/**
			m_ptr =
				m_image->pixels
				+ m_image->rowstride*m_y
				+ m_image->bytesPerPixel*m_x;
			*/
			int pos = 0;
			for (int y = 0; y < height; ++y)
			{
				switch (imageType) {

				case .UncompressedIndexed:
					{
						Assert!(bitsPerPixel == 8);
						if (ReadUncompressedData<uint8>(str, buffer, ref pos, => read8))
							return .Ok;
					}

				case .UncompressedRgb:
					{
						switch (bitsPerPixel) {
						case 15:
						case 16:
							if (ReadUncompressedData<uint32>(str, buffer, ref pos, => read16AsRgb))
								return .Ok;
						case 24:
							if (ReadUncompressedData<uint32>(str, buffer, ref pos, => read24AsRgb))
								return .Ok;
						case 32:
							if (ReadUncompressedData<uint32>(str, buffer, ref pos, => read32AsRgb))
								return .Ok;

						default:
							Assert!(false);
							break;
						}
					}

				case .UncompressedGray:
					{
						Assert!(bitsPerPixel == 8);
						if (ReadUncompressedData<uint8>(str, buffer, ref pos, => read8))
							return .Ok;
					}

				case .RleIndexed:
					{
						Assert!(bitsPerPixel == 8);
						if (ReadRleData<uint8>(str, buffer, ref pos, => read8))
							return .Ok;
					}

				case .RleRgb:
					{
						switch (bitsPerPixel) {
						case 15:
						case 16:
							if (ReadRleData<uint32>(str, buffer, ref pos, => read16AsRgb))
								return .Ok;
						case 24:
							if (ReadRleData<uint32>(str, buffer, ref pos, => read24AsRgb))
								return .Ok;
						case 32:
							if (ReadRleData<uint32>(str, buffer, ref pos, => read32AsRgb))
								return .Ok;
						default:
							Assert!(false);
						}
					}


				case .RleGray:
					{
						Assert!(bitsPerPixel == 8);
						if (ReadRleData<uint8>(str, buffer, ref pos, => read8))
							return .Ok;
					}


				default: return .Err;
				}


			/*if (delegate && !delegate->notifyProgress(float(y) / float(header.height))) { break;*/
			}

			return .Ok;
		}

		static uint32 read8(Stream str)
		{
			return (str.Read<uint8>() case .Ok(let val)) ? val : 0;
		}


		// // Reads a WORD (16 bits) using in little-endian byte ordering.
		static uint32 read16(Stream str)
		{
			if ((str.Read<uint8>() case .Ok(let b1)) && str.Read<uint8>() case .Ok(let b2))
			{
				return (((uint32)b2 << 8) | b1);
			}
			return 0;
		}


		// // Reads a DWORD (32 bits) using in little-endian byte ordering.
		static uint32 read32(Stream str)
		{
			if ((str.Read<uint8>() case .Ok(let b1)) &&
				(str.Read<uint8>() case .Ok(let b2)) &&
				(str.Read<uint8>() case .Ok(let b3)) &&
				(str.Read<uint8>() case .Ok(let b4)))
			{
				return (((uint32)b4 << 24) | ((uint32)b3 << 16) | ((uint32)b2 << 8) | b1);
			}

			return 0;
		}

		static uint32 read32AsRgb(Stream str)
		{
			if ((str.Read<uint8>() case .Ok(let b)) &&
				(str.Read<uint8>() case .Ok(let g)) &&
				(str.Read<uint8>() case .Ok(let r)) &&
				(str.Read<uint8>() case .Ok(var a)))
			{
				/*if(!m_hasAlpha) a = 0xFF;*/
				return TGAColormap.rgba(r, g, b, a);
			}
			return 0;
		}

		static uint32 read24AsRgb(Stream str)
		{
			if ((str.Read<uint8>() case .Ok(let b)) &&
				(str.Read<uint8>() case .Ok(let g)) &&
				(str.Read<uint8>() case .Ok(let r)))
			{
				return TGAColormap.rgba(r, g, b, 255);
			}
			return 0;
		}

		static uint32 read16AsRgb(Stream str)
		{
			uint16 v = str.Read<uint16>();
			uint8 a = 255;

			  /*if (m_hasAlpha) { if ((v & 0x8000) == 0)    // Transparent bit a = 0;
			}*/
			return TGAColormap.rgba(TGAColormap.scale_5bits_to_8bits((uint8)(v >> 10) & 0x1F),
				TGAColormap.scale_5bits_to_8bits((uint8)(v >> 5) & 0x1F),
				TGAColormap.scale_5bits_to_8bits((uint8)v & 0x1F),
				a);
		}
	}
}
