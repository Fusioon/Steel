using System;

#define PNG_READ_SUPPORTED
#define PNG_COLORSPACE_SUPPORTED
#define PNG_GAMMA_SUPPORTED

namespace libpng
{
	
	typealias png_uint_16 = uint16;
	typealias png_uint_32 = uint32;
	typealias png_byte = uint8;
	typealias png_const_byte = png_byte;
	typealias png_fixed_point = int32;

	[CRepr]
	struct png_xy
	{
	   public png_fixed_point redx, redy;
	   public png_fixed_point greenx, greeny;
	   public png_fixed_point bluex, bluey;
	   public png_fixed_point whitex, whitey;
	}

	[CRepr]
	struct png_XYZ
	{
	   public png_fixed_point red_X, red_Y, red_Z;
	   public png_fixed_point green_X, green_Y, green_Z;
	   public png_fixed_point blue_X, blue_Y, blue_Z;
	}

	[CRepr]
	struct png_struct
	{

	}

	[CRepr]
	struct png_color
	{
		public png_byte red;
		public png_byte green;
		public png_byte blue;
	}

struct png_colorspace
	{
#if PNG_GAMMA_SUPPORTED
	   png_fixed_point gamma;        /* File gamma */
#endif

#if PNG_COLORSPACE_SUPPORTED
	   png_xy      end_points_xy;    /* End points as chromaticities */
	   png_XYZ     end_points_XYZ;   /* End points as CIE XYZ colorant values */
	   png_uint_16 rendering_intent; /* Rendering intent of a profile */
#endif

	   /* Flags are always defined to simplify the code. */
	   png_uint_16 flags;            /* As defined below */
	}

	[CRepr]
	struct png_info
	{
		/* The following are necessary for every PNG file */
		public png_uint_32 width;       /* width of image in pixels (from IHDR) */
		public png_uint_32 height;      /* height of image in pixels (from IHDR) */
		public png_uint_32 valid;       /* valid chunk data (see PNG_INFO_ below) */
		public uint rowbytes;         /* bytes needed to hold an untransformed row */
		public png_color* palette;      /* array of color values (valid & PNG_INFO_PLTE) */
		public png_uint_16 num_palette; /* number of color entries in "palette" (PLTE) */
		public png_uint_16 num_trans;   /* number of transparent palette color (tRNS) */
		public png_byte bit_depth;      /* 1, 2, 4, 8, or 16 bits/channel (from IHDR) */
		public png_byte color_type;     /* see PNG_COLOR_TYPE_ below (from IHDR) */
		/* The following three should have been named *_method not *_type */
		public png_byte compression_type; /* must be PNG_COMPRESSION_TYPE_BASE (IHDR) */
		public png_byte filter_type;    /* must be PNG_FILTER_TYPE_BASE (from IHDR) */
		public png_byte interlace_type; /* One of PNG_INTERLACE_NONE, PNG_INTERLACE_ADAM7 */

		/* The following are set by png_set_IHDR, called from the application on
		 * write, but the are never actually used by the write code.
		 */
		public png_byte channels;       /* number of data channels per pixel (1, 2, 3, 4) */
		public png_byte pixel_depth;    /* number of bits per pixel */
		public png_byte spare_byte;     /* to align the data, and for future use */

#if PNG_READ_SUPPORTED
		/* This is never set during write */
		public png_byte[8] signature;   /* magic bytes read by libpng from start of file */
#endif

		/* The rest of the data is optional.  If you are reading, check the
		 * valid field to see if the information in these are valid.  If you
		 * are writing, set the valid field to those chunks you want written,
		 * and initialize the appropriate fields below.
		 */

#if PNG_COLORSPACE_SUPPORTED || PNG_GAMMA_SUPPORTED
		/* png_colorspace only contains 'flags' if neither GAMMA or COLORSPACE are
		 * defined.  When COLORSPACE is switched on all the colorspace-defining
		 * chunks should be enabled, when GAMMA is switched on all the gamma-defining
		 * chunks should be enabled.  If this is not done it becomes possible to read
		 * inconsistent PNG files and assign a probably incorrect interpretation to
		 * the information.  (In other words, by carefully choosing which chunks to
		 * recognize the system configuration can select an interpretation for PNG
		 * files containing ambiguous data and this will result in inconsistent
		 * behavior between different libpng builds!)
		 */
		public png_colorspace colorspace;
#endif
	}

	[CRepr]
	struct png_control
	{
		public png_struct* png_ptr;
		public png_info   info_ptr;
		public void*   error_buf;           /* Always a jmp_buf at present. */

		public png_const_byte* memory;          /* Memory buffer. */
		public uint          	size;            /* Size of the memory buffer. */

		public bool for_write      ; /* Otherwise it is a read structure */
		public bool owned_file     ; /* We own the file in io_ptr */
	}

	[CRepr]
	struct png_image
	{
	  	public png_control* 	opaque;    /* Initialize to NULL, free with png_image_free */
	  	public png_uint_32 		version;   /* Set to PNG_IMAGE_VERSION */
		public png_uint_32 		width;     /* Image width in pixels (columns) */
		public png_uint_32 		height;    /* Image height in pixels (rows) */
		public Format 			format;    /* Image format as defined below */
		public png_uint_32 		flags;     /* A bit mask containing informational flags */
		public png_uint_32 		colormap_entries;
	                           /* Number of entries in the color-map */

	   /* In the event of an error or warning the following field will be set to a
	    * non-zero value and the 'message' field will contain a '\0' terminated
	    * string with the libpng error or warning message.  If both warnings and
	    * an error were encountered, only the error is recorded.  If there
	    * are multiple warnings, only the first one is recorded.
	    *
	    * The upper 30 bits of this value are reserved, the low two bits contain
	    * a value as follows:
	    */
//#  define PNG_IMAGE_WARNING 1
//#  define PNG_IMAGE_ERROR 2
	   /*
	    * The result is a two-bit code such that a value more than 1 indicates
	    * a failure in the API just called:
	    *
	    *    0 - no warning or error
	    *    1 - warning
	    *    2 - error
	    *    3 - error preceded by warning
	    */
//#  define PNG_IMAGE_FAILED(png_cntrl) ((((png_cntrl).warning_or_error)&0x03)>1)

	   public png_uint_32  warning_or_error;

	   public char8[64]         message;
	}
}
