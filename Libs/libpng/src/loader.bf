using System;

namespace libpng
{
	public enum FormatFlags : png_uint_32
	{
		Alpha = 0x01,
		Color = 0x02,
		Linear = 0x04,
		Colormap = 0x08,

		BGR = 0x10,
		AFirst = 0x20,
		AssociatedAlpha = 0x40,
	}

	public enum Format : FormatFlags
	{
		Gray = 0,
		GA = (.)FormatFlags.Alpha,
		AG = .GA | (.)FormatFlags.AFirst,
		RGB = (.)FormatFlags.Color,
		BGR = (.)(FormatFlags.Color | FormatFlags.BGR),
		RGBA = (.RGB | (.)FormatFlags.Alpha),
		ARGB = (.RGB | (.)FormatFlags.AFirst),
		BGRA = (.BGR | (.)FormatFlags.Alpha),
		ABGR = (.BGR | (.)FormatFlags.AFirst),
	}

	public static
	{
		[CLink]
		public static extern int32 png_image_begin_read_from_memory(png_image* image, void* memory, uint size);
		[CLink]
		public static extern int32 png_image_finish_read(png_image* image, void* background, void* buffer, int32 row_stride, void* colormap);
		[CLink]
		public static extern void png_image_free(png_image* image);

		public const uint32 PNG_IMAGE_VERSION = 1;


		public static mixin ImageRowStride(png_image img)
		{
			uint32 sampleChannelsSize = ((.)(((FormatFlags)img.format)&(FormatFlags.Color|FormatFlags.Alpha))) + 1;
			sampleChannelsSize * img.width
		}
		public static mixin ImageBufferSize(png_image img, uint32 rowStride)
		{
			uint sampleComponentSize = (((uint32)((FormatFlags)img.format & (FormatFlags.Linear)) >> 2) + 1);
			sampleComponentSize * img.height * rowStride
		}
	}
}
