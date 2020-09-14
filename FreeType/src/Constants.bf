namespace FreeType
{
	static
	{
		static mixin FT_MAKE_TAG(char8 x1, char8 x2, char8 x3, char8 x4)
		{
			FT_UInt32(((FT_UInt32)x1 << 24) | ((FT_UInt32)x2 << 16) | ((FT_UInt32)x3 << 8) | (FT_UInt32)x4)
		}

		const let FT_ADVANCE_FLAG_FAST_ONLY = 0x20000000;

		const let FT_OUTLINE_CONTOURS_MAX = int16.MaxValue;

		const let FT_OUTLINE_POINTS_MAX = int16.MaxValue;

		const FT_UInt32 FT_PARAM_TAG_INCREMENTAL = FT_MAKE_TAG!('i','n','c','r');

		const FT_UInt32 FT_PARAM_TAG_IGNORE_PREFERRED_FAMILY = FT_MAKE_TAG!('i','g','p','f');

		const FT_UInt32 FT_PARAM_TAG_IGNORE_PREFERRED_SUBFAMILY = FT_MAKE_TAG!('i','g','p','s');

		const let TT_INTERPRETER_VERSION_35 = 35;

		const let TT_INTERPRETER_VERSION_38 = 38;

		const let T1_MAX_MM_DESIGNS = 16;

		const let T1_MAX_MM_AXIS = 4;

		const let T1_MAX_MM_MAP_POINTS = 20;
	}
	
}
