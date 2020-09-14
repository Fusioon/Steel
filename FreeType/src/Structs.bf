using System;

namespace FreeType
{
	struct FT_UnitVector {
	    FT_F2Dot14 x;
	    FT_F2Dot14 y;
	}

	struct FT_Matrix {
	    FT_Fixed xx, xy;
	    FT_Fixed yx, yy;
	}

	struct FT_Data {
	    FT_Byte* pointer;
	    FT_Int length;
	}

	struct FT_Generic {
	    void* data;
	    FT_Generic_Finalizer finalizer;
	}

	struct FT_ListNodeRec {
	    FT_ListNode prev;
	    FT_ListNode next;
	    void* data;
	}

	struct FT_ListRec {
	    FT_ListNode head;
	    FT_ListNode tail;
	}

	struct FT_Glyph_Metrics {
	    FT_Pos width;
	    FT_Pos height;
	    FT_Pos horiBearingX;
	    FT_Pos horiBearingY;
	    FT_Pos horiAdvance;
	    FT_Pos vertBearingX;
	    FT_Pos vertBearingY;
	    FT_Pos vertAdvance;
	}

	struct FT_Bitmap_Size {
	    FT_Short height;
	    FT_Short width;
	    FT_Pos size;
	    FT_Pos x_ppem;
	    FT_Pos y_ppem;
	}

	struct FT_CharMapRec {
	    FT_Face face;
	    FT_Encoding encoding;
	    FT_UShort platform_id;
	    FT_UShort encoding_id;
	}

	struct FT_FaceRec {
	    FT_Long num_faces;
	    FT_Long face_index;
	    FT_Long face_flags;
	    FT_Long style_flags;
	    FT_Long num_glyphs;
	    FT_String* family_name;
	    FT_String* style_name;
	    FT_Int num_fixed_sizes;
	    FT_Bitmap_Size* available_sizes;
	    FT_Int num_charmaps;
	    FT_CharMap* charmaps;
	    FT_Generic generic;
	    FT_BBox bbox;
	    FT_UShort units_per_EM;
	    FT_Short ascender;
	    FT_Short descender;
	    FT_Short height;
	    FT_Short max_advance_width;
	    FT_Short max_advance_height;
	    FT_Short underline_position;
	    FT_Short underline_thickness;
	    FT_GlyphSlot glyph;
	    FT_Size size;
	    FT_CharMap charmap;
	    FT_Driver driver;
	    FT_Memory memory;
	    FT_Stream stream;
	    FT_ListRec sizes_list;
	    FT_Generic autohint;
	    void* extensions;
	    FT_Face_Internal _internal;
	}

	struct FT_Size_Metrics {
	    FT_UShort x_ppem;
	    FT_UShort y_ppem;

	    FT_Fixed x_scale;
	    FT_Fixed y_scale;

	    FT_Pos ascender;
	    FT_Pos descender;
	    FT_Pos height;
	    FT_Pos max_advance;
	}

	struct FT_SizeRec {
	    FT_Face face;
	    FT_Generic generic;
	    FT_Size_Metrics metrics;
	    FT_Size_Internal _internal;
	}

	struct FT_GlyphSlotRec {
	    FT_Library library;
	    FT_Face face;
	    FT_GlyphSlot next;
	    FT_UInt reserved;
	    FT_Generic generic;
	    FT_Glyph_Metrics metrics;
	    FT_Fixed linearHoriAdvance;
	    FT_Fixed linearVertAdvance;
	    FT_Vector advance;
	    FT_Glyph_Format format;
	    FT_Bitmap bitmap;
	    FT_Int bitmap_left;
	    FT_Int bitmap_top;
	    FT_Outline outline;
	    FT_UInt num_subglyphs;
	    FT_SubGlyph subglyphs;
	    void* control_data;
	    int32 control_len;
	    FT_Pos lsb_delta;
	    FT_Pos rsb_delta;
	    void* other;
	    FT_Slot_Internal _internal;
	}

	struct FT_Parameter {
	    FT_ULong tag;
	    FT_Pointer data;
	}

	struct FT_Open_Args {
	    FT_UInt flags;
	    FT_Byte* memory_base;
	    FT_Long memory_size;
	    FT_String* pathname;
	    FT_Stream stream;
	    FT_Module driver;
	    FT_Int num_params;
	    FT_Parameter* _params;
	}

	struct FT_Size_RequestRec {
	    FT_Size_Request_Type type;
	    FT_Long width;
	    FT_Long height;
	    FT_UInt horiResolution;
	    FT_UInt vertResolution;
	}

	struct FT_Prop_GlyphToScriptMap {
	    FT_Face face;
	    FT_UShort* map;
	}

	struct FT_Prop_IncreaseXHeight {
	    FT_Face face;
	    FT_UInt32 limit;
	}

	struct BDF_PropertyRec {
	        /*BDF_PropertyType type;
	        union u {
	         char* atom;
	         FT_Int32 integer;
	         FT_UInt32 cardinal;
	        }*/
	}

	struct FTC_ScalerRec {
	    FTC_FaceID face_id;
	    FT_UInt width;
	    FT_UInt height;
	    FT_Int pixel;
	    FT_UInt x_res;
	    FT_UInt y_res;
	}

	struct FTC_ImageTypeRec {
	    FTC_FaceID face_id;
	    FT_UInt width;
	    FT_UInt height;
	    FT_Int32 flags;
	}

	struct FTC_SBitRec {
	    FT_Byte width;
	    FT_Byte height;
	    FT_Char left;
	    FT_Char top;
	    FT_Byte format;
	    FT_Byte max_grays;
	    FT_Short pitch;
	    FT_Char xadvance;
	    FT_Char yadvance;
	    FT_Byte* buffer;
	}

	struct FT_GlyphRec {
	    FT_Library library;
	    FT_Glyph_Class* clazz;
	    FT_Glyph_Format format;
	    FT_Vector advance;
	}

	struct FT_BitmapGlyphRec {
	    FT_GlyphRec root;
	    FT_Int left;
	    FT_Int top;
	    FT_Bitmap bitmap;
	}

	struct FT_OutlineGlyphRec {
	    FT_GlyphRec root;
	    FT_Outline outline;
	}

	struct FT_Vector {
	    FT_Pos x;
	    FT_Pos y;
	}

	struct FT_BBox {
	    FT_Pos xMin, yMin;
	    FT_Pos xMax, yMax;
	}

	struct FT_Bitmap {
	    uint32 rows;
	    uint32 width;
	    int32 pitch;
	    uint8* buffer;
	    uint16 num_grays;
	    uint8 pixel_mode;
	    uint8 palette_mode;
	    void* palette;
	}

	struct FT_Outline {
	    int16 n_contours;
	    int16 n_points;
	    FT_Vector* points;
	    int8* tags;
	    int16* contours;
	    int32 flags;
	}

	struct FT_Outline_Funcs {
	    FT_Outline_MoveToFunc move_to;
	    FT_Outline_LineToFunc line_to;
	    FT_Outline_ConicToFunc conic_to;
	    FT_Outline_CubicToFunc cubic_to;
	    int32 shift;
	    FT_Pos delta;
	}

	struct FT_Span {
	    int16 x;
	    uint16 len;
	    uint8 coverage;
	}

	struct FT_Raster_Params {
	    FT_Bitmap* target;
	    void* source;
	    int32 flags;
	    FT_SpanFunc gray_spans;
	    void* black_spans;
	    void* bit_test;
	    void* bit_set;
	    void* user;
	    FT_BBox clip_box;
	}

	struct FT_Raster_Funcs {
	    FT_Glyph_Format glyph_format;
	    FT_Raster_NewFunc raster_new;
	    FT_Raster_ResetFunc raster_reset;
	    FT_Raster_SetModeFunc raster_set_mode;
	    FT_Raster_RenderFunc raster_render;
	    FT_Raster_DoneFunc raster_done;
	}

	struct FT_Incremental_MetricsRec {
	    FT_Long bearing_x;
	    FT_Long bearing_y;
	    FT_Long advance;
	}

	struct FT_Incremental_FuncsRec {
	    FT_Incremental_GetGlyphDataFunc get_glyph_data;
	    FT_Incremental_FreeGlyphDataFunc free_glyph_data;
	    FT_Incremental_GetGlyphMetricsFunc get_glyph_metrics;
	}

	struct FT_Incremental_InterfaceRec {
	    FT_Incremental_FuncsRec* funcs;
	    FT_Incremental object;
	}

	struct FT_MM_Axis {
	    FT_String* name;
	    FT_Long minimum;
	    FT_Long maximum;
	}

	struct FT_Multi_Master {
	    FT_UInt num_axis;
	    FT_UInt num_designs;
	    FT_MM_Axis[4] axis;
	}

	struct FT_Var_Axis {
	    FT_String* name;
	    FT_Fixed minimum;
	    FT_Fixed def;
	    FT_Fixed maximum;
	    FT_ULong tag;
	    FT_UInt strid;
	}

	struct FT_Var_Named_Style {
	    FT_Fixed* coords;
	    FT_UInt strid;
	}

	struct FT_MM_Var {
	    FT_UInt num_axis;
	    FT_UInt num_designs;
	    FT_UInt num_namedstyles;
	    FT_Var_Axis* axis;
	    FT_Var_Named_Style* namedstyle;
	}

	struct FT_Module_Class {
	    FT_ULong module_flags;
	    FT_Long module_size;
	    FT_String* module_name;
	    FT_Fixed module_version;
	    FT_Fixed module_requires;
	    void* module_interface;
	    FT_Module_Constructor module_init;
	    FT_Module_Destructor module_done;
	    FT_Module_Requester get_interface;
	}

	struct FT_Glyph_Class {  // typedef'd in ftglyph.h
	    FT_Long glyph_size;
	    FT_Glyph_Format glyph_format;
	    FT_Glyph_InitFunc glyph_init;
	    FT_Glyph_DoneFunc glyph_done;
	    FT_Glyph_CopyFunc glyph_copy;
	    FT_Glyph_TransformFunc glyph_transform;
	    FT_Glyph_GetBBoxFunc glyph_bbox;
	    FT_Glyph_PrepareFunc glyph_prepare;
	}

	struct FT_Renderer_Class {
	    FT_Module_Class root;
	    FT_Glyph_Format glyph_format;
	    FT_Renderer_RenderFunc render_glyph;
	    FT_Renderer_TransformFunc transform_glyph;
	    FT_Renderer_GetCBoxFunc get_glyph_cbox;
	    FT_Renderer_SetModeFunc set_mode;
	    FT_Raster_Funcs* raster_class;
	}

	struct FT_SfntName {
	    FT_UShort platform_id;
	    FT_UShort encoding_id;
	    FT_UShort language_id;
	    FT_UShort name_id;
	    FT_Byte* string;
	    FT_UInt string_len;
	}

	struct FT_MemoryRec {
	    void* user;
	    FT_Alloc_Func alloc;
	    FT_Free_Func free;
	    FT_Realloc_Func realloc;
	}

	[Union]
	struct FT_StreamDesc {
	    int32 value;
	    void* pointer;
	}

	struct FT_StreamRec {
	    uint8* _base;
	    uint32 size;
	    uint32 pos;
	    FT_StreamDesc descriptor;
	    FT_StreamDesc pathname;
	    FT_Stream_IoFunc read;
	    FT_Stream_CloseFunc close;
	    FT_Memory memory;
	    uint8* cursor;
	    uint8* limit;
	}

	struct FT_WinFNT_HeaderRec {
	    FT_UShort _version;
	    FT_ULong file_size;
	    FT_Byte[60] copyright;
	    FT_UShort file_type;
	    FT_UShort nominal_point_size;
	    FT_UShort vertical_resolution;
	    FT_UShort horizontal_resolution;
	    FT_UShort ascent;
	    FT_UShort internal_leading;
	    FT_UShort external_leading;
	    FT_Byte italic;
	    FT_Byte underline;
	    FT_Byte strike_out;
	    FT_UShort weight;
	    FT_Byte charset;
	    FT_UShort pixel_width;
	    FT_UShort pixel_height;
	    FT_Byte pitch_and_family;
	    FT_UShort avg_width;
	    FT_UShort max_width;
	    FT_Byte first_char;
	    FT_Byte last_char;
	    FT_Byte default_char;
	    FT_Byte break_char;
	    FT_UShort bytes_per_row;
	    FT_ULong device_offset;
	    FT_ULong face_name_offset;
	    FT_ULong bits_pointer;
	    FT_ULong bits_offset;
	    FT_Byte reserved;
	    FT_ULong flags;
	    FT_UShort A_space;
	    FT_UShort B_space;
	    FT_UShort C_space;
	    FT_UShort color_table_offset;
	    FT_ULong[4] reserved1;
	}

	struct PS_FontInfoRec {
	    FT_String* _version;
	    FT_String* notice;
	    FT_String* full_name;
	    FT_String* family_name;
	    FT_String* weight;
	    FT_Long italic_angle;
	    FT_Bool is_fixed_pitch;
	    FT_Short underline_position;
	    FT_UShort underline_thickness;
	}

	struct PS_PrivateRec {
	    FT_Int unique_id;
	    FT_Int lenIV;
	    FT_Byte num_blue_values;
	    FT_Byte num_other_blues;
	    FT_Byte num_family_blues;
	    FT_Byte num_family_other_blues;
	    FT_Short[14] blue_values;
	    FT_Short[10] other_blues;
	    FT_Short[14] family_blues;
	    FT_Short[10] family_other_blues;
	    FT_Fixed blue_scale;
	    FT_Int blue_shift;
	    FT_Int blue_fuzz;
	    FT_UShort[1] standard_width;
	    FT_UShort[1] standard_height;
	    FT_Byte num_snap_widths;
	    FT_Byte num_snap_heights;
	    FT_Bool force_bold;
	    FT_Bool round_stem_up;
	    FT_Short[13] snap_widths;
	    FT_Short[13] snap_heights;
	    FT_Fixed expansion_factor;
	    FT_Long language_group;
	    FT_Long password;
	    FT_Short[2] min_feature;
	}

	struct PS_DesignMapRec {
	    FT_Byte num_points;
	    FT_Long* design_points;
	    FT_Fixed* blend_points;
	}

	struct PS_BlendRec {
	    FT_UInt num_designs;
	    FT_UInt num_axis;
	    FT_String*[T1_MAX_MM_AXIS] axis_names;
	    FT_Fixed*[T1_MAX_MM_DESIGNS] design_pos;
	    PS_DesignMapRec[T1_MAX_MM_AXIS] design_map;
	    FT_Fixed* weight_vector;
	    FT_Fixed* default_weight_vector;
	    PS_FontInfo[T1_MAX_MM_DESIGNS+1] font_infos;
	    PS_Private[T1_MAX_MM_DESIGNS+1] privates;
	    FT_ULong blend_bitflags;
	    FT_BBox*[T1_MAX_MM_DESIGNS+1] bboxes;
	    FT_UInt[T1_MAX_MM_DESIGNS] default_design_vector;
	    FT_UInt num_default_design_vector;
	}

	struct CID_FaceDictRec {
	    PS_PrivateRec private_dict;
	    FT_UInt len_buildchar;
	    FT_Fixed forcebold_threshold;
	    FT_Pos stroke_width;
	    FT_Fixed expansion_factor;
	    FT_Byte paint_type;
	    FT_Byte font_type;
	    FT_Matrix font_matrix;
	    FT_Vector font_offset;
	    FT_UInt num_subrs;
	    FT_ULong subrmap_offset;
	    FT_Int sd_bytes;
	}

	struct CID_FaceInfoRec {
	    FT_String* cid_font_name;
	    FT_Fixed cid_version;
	    FT_Int cid_font_type;
	    FT_String* registry;
	    FT_String* ordering;
	    FT_Int supplement;
	    PS_FontInfoRec font_info;
	    FT_BBox font_bbox;
	    FT_ULong uid_base;
	    FT_Int num_xuid;
	    FT_ULong[16] xuid;
	    FT_ULong cidmap_offset;
	    FT_Int fd_bytes;
	    FT_Int gd_bytes;
	    FT_ULong cid_count;
	    FT_Int num_dicts;
	    CID_FaceDict font_dicts;
	    FT_ULong data_offset;
	}

	struct TT_Header {
	    FT_Fixed Table_Version;
	    FT_Fixed Font_Revision;
	    FT_Long CheckSum_Adjust;
	    FT_Long Magic_Number;
	    FT_UShort Flags;
	    FT_UShort Units_Per_EM;
	    FT_Long[2] Created;
	    FT_Long[2] Modified;
	    FT_Short xMin;
	    FT_Short yMin;
	    FT_Short xMax;
	    FT_Short yMax;
	    FT_UShort Mac_Style;
	    FT_UShort Lowest_Rec_PPEM;
	    FT_Short Font_Direction;
	    FT_Short Index_To_Loc_Format;
	    FT_Short Glyph_Data_Format;
	}

	struct TT_HoriHeader {
	    FT_Fixed Version;
	    FT_Short Ascender;
	    FT_Short Descender;
	    FT_Short Line_Gap;
	    FT_UShort advance_Width_Max;
	    FT_Short min_Left_Side_Bearing;
	    FT_Short min_Right_Side_Bearing;
	    FT_Short xMax_Extent;
	    FT_Short caret_Slope_Rise;
	    FT_Short caret_Slope_Run;
	    FT_Short caret_Offset;
	    FT_Short[4] Reserved;
	    FT_Short metric_Data_Format;
	    FT_UShort number_Of_HMetrics;
	    void* long_metrics;
	    void* short_metrics;
	}

	struct TT_VertHeader {
	    FT_Fixed Version;
	    FT_Short Ascender;
	    FT_Short Descender;
	    FT_Short Line_Gap;
	    FT_UShort advance_Height_Max;
	    FT_Short min_Top_Side_Bearing;
	    FT_Short min_Bottom_Side_Bearing;
	    FT_Short yMax_Extent;
	    FT_Short caret_Slope_Rise;
	    FT_Short caret_Slope_Run;
	    FT_Short caret_Offset;
	    FT_Short[4] Reserved;
	    FT_Short metric_Data_Format;
	    FT_UShort number_Of_VMetrics;
	    void* long_metrics;
	    void* short_metrics;
	}

	struct TT_OS2 {
	    FT_UShort _version;
	    FT_Short xAvgCharWidth;
	    FT_UShort usWeightClass;
	    FT_UShort usWidthClass;
	    FT_UShort fsType;
	    FT_Short ySubscriptXSize;
	    FT_Short ySubscriptYSize;
	    FT_Short ySubscriptXOffset;
	    FT_Short ySubscriptYOffset;
	    FT_Short ySuperscriptXSize;
	    FT_Short ySuperscriptYSize;
	    FT_Short ySuperscriptXOffset;
	    FT_Short ySuperscriptYOffset;
	    FT_Short yStrikeoutSize;
	    FT_Short yStrikeoutPosition;
	    FT_Short sFamilyClass;
	    FT_Byte[10] panose;
	    FT_ULong ulUnicodeRange1;
	    FT_ULong ulUnicodeRange2;
	    FT_ULong ulUnicodeRange3;
	    FT_ULong ulUnicodeRange4;
	    FT_Char[4] achVendID;
	    FT_UShort fsSelection;
	    FT_UShort usFirstCharIndex;
	    FT_UShort usLastCharIndex;
	    FT_Short sTypoAscender;
	    FT_Short sTypoDescender;
	    FT_Short sTypoLineGap;
	    FT_UShort usWinAscent;
	    FT_UShort usWinDescent;
	    FT_ULong ulCodePageRange1;
	    FT_ULong ulCodePageRange2;
	    FT_Short sxHeight;
	    FT_Short sCapHeight;
	    FT_UShort usDefaultChar;
	    FT_UShort usBreakChar;
	    FT_UShort usMaxContext;
	    FT_UShort usLowerOpticalPointSize;
	    FT_UShort usUpperOpticalPointSize;
	}

	struct TT_Postscript {
	    FT_Fixed FormatType;
	    FT_Fixed italicAngle;
	    FT_Short underlinePosition;
	    FT_Short underlineThickness;
	    FT_ULong isFixedPitch;
	    FT_ULong minMemType42;
	    FT_ULong maxMemType42;
	    FT_ULong minMemType1;
	    FT_ULong maxMemType1;
	}

	struct TT_PCLT {
	    FT_Fixed Version;
	    FT_ULong FontNumber;
	    FT_UShort Pitch;
	    FT_UShort xHeight;
	    FT_UShort Style;
	    FT_UShort TypeFamily;
	    FT_UShort CapHeight;
	    FT_UShort SymbolSet;
	    FT_Char[16] TypeFace;
	    FT_Char[8] CharacterComplement;
	    FT_Char[6] FileName;
	    FT_Char StrokeWeight;
	    FT_Char WidthType;
	    FT_Byte SerifStyle;
	    FT_Byte Reserved;
	}

	struct TT_MaxProfile {
	    FT_Fixed _version;
	    FT_UShort numGlyphs;
	    FT_UShort maxPoints;
	    FT_UShort maxContours;
	    FT_UShort maxCompositePoints;
	    FT_UShort maxCompositeContours;
	    FT_UShort maxZones;
	    FT_UShort maxTwilightPoints;
	    FT_UShort maxStorage;
	    FT_UShort maxFunctionDefs;
	    FT_UShort maxInstructionDefs;
	    FT_UShort maxStackElements;
	    FT_UShort maxSizeOfInstructions;
	    FT_UShort maxComponentElements;
	    FT_UShort maxComponentDepth;
	}

	struct FT_LibraryRec { }

	struct FT_ModuleRec { }

	struct FT_DriverRec { }

	struct FT_RendererRec { }

	struct FT_Face_InternalRec { }

	struct FT_Size_InternalRec { }

	struct FT_SubGlyphRec { }

	struct FT_Slot_InternalRec { }

	struct FTC_ManagerRec { }

	struct FTC_NodeRec { }

	struct FTC_CMapCacheRec { }

	struct FTC_ImageCacheRec { }

	struct FTC_SBitCacheRec { }

	struct FT_RasterRec { }

	struct FT_IncrementalRec { }

	struct FT_StrokerRec { }

}
