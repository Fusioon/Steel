using System;

namespace FreeType
{
	public static
	{
		[CLink]
		public static extern FT_Error FT_Init_FreeType(FT_Library* Library);
		    
		[CLink]
		public static extern FT_Error FT_Done_FreeType(FT_Library Library);
		    
		[CLink]
		public static extern FT_Error FT_New_Face(FT_Library Library, char8 _char, FT_Long _FT_Long, FT_Face _FT_Face);
		    
		[CLink]
		public static extern FT_Error FT_New_Memory_Face(FT_Library Library, FT_Byte _FT_Byte, FT_Long _FT_Long, FT_Long _FT_Long2, FT_Face _FT_Face);
		    
		[CLink]
		public static extern FT_Error FT_Open_Face(FT_Library Library, FT_Open_Args _FT_Open_Args, FT_Long _FT_Long, FT_Face _FT_Face);
		    
		[CLink]
		public static extern FT_Error FT_Attach_File(FT_Face Face, char8 _char);
		    
		[CLink]
		public static extern FT_Error FT_Attach_Stream(FT_Face Face, FT_Open_Args _FT_Open_Args);
		    
		[CLink]
		public static extern FT_Error FT_Reference_Face(FT_Face Face);
		    
		[CLink]
		public static extern FT_Error FT_Done_Face(FT_Face Face);
		    
		[CLink]
		public static extern FT_Error FT_Select_Size(FT_Face Face, FT_Int _FT_Int);
		    
		[CLink]
		public static extern FT_Error FT_Request_Size(FT_Face Face, FT_Size_Request _FT_Size_Request);
		    
		[CLink]
		public static extern FT_Error FT_Set_Char_Size(FT_Face Face, FT_F26Dot6 _FT_F26Dot6, FT_F26Dot6 _FT_F26Dot6_2, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2);
		    
		[CLink]
		public static extern FT_Error FT_Set_Pixel_Sizes(FT_Face Face, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2);
		    
		[CLink]
		public static extern FT_Error FT_Load_Glyph(FT_Face Face, FT_UInt _FT_UInt, FT_Int32 _FT_Int32);
		    
		[CLink]
		public static extern FT_Error FT_Load_Char(FT_Face Face, FT_ULong _FT_ULong, FT_Int32 _FT_Int32);
		    
		[CLink]
		public static extern void FT_Set_Transform(FT_Face Face, FT_Matrix _FT_Matrix, FT_Vector _FT_Vector);
		    
		[CLink]
		public static extern FT_Error FT_Render_Glyph(FT_GlyphSlot GlyphSlot, FT_Render_Mode _FT_Render_Mode);
		    
		[CLink]
		public static extern FT_Error FT_Get_Kerning(FT_Face Face, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2, FT_UInt _FT_UInt_3, FT_Vector _FT_Vector);
		    
		[CLink]
		public static extern FT_Error FT_Get_Track_Kerning(FT_Face Face, FT_Fixed _FT_Fixed, FT_Int _FT_Int, FT_Fixed _FT_Fixed_2);
		    
		[CLink]
		public static extern FT_Error FT_Get_Glyph_Name(FT_Face Face, FT_UInt _FT_UInt, FT_Pointer _FT_Pointer, FT_UInt _FT_UInt_2);
		    
		[CLink]
		public static extern char8* FT_Get_Postscript_Name(FT_Face Face);
		    
		[CLink]
		public static extern FT_Error FT_Select_Charmap(FT_Face Face, FT_Encoding _FT_Encoding);
		    
		[CLink]
		public static extern FT_Error FT_Set_Charmap(FT_Face Face, FT_CharMap _FT_CharMap);
		    
		[CLink]
		public static extern FT_Int FT_Get_Charmap_Index(FT_CharMap CharMap);
		    
		[CLink]
		public static extern FT_UInt FT_Get_Char_Index(FT_Face Face, FT_ULong _FT_ULong);
		    
		[CLink]
		public static extern FT_ULong FT_Get_First_Char(FT_Face Face, FT_UInt _FT_UInt);
		    
		[CLink]
		public static extern FT_ULong FT_Get_Next_Char(FT_Face Face, FT_ULong _FT_ULong, FT_UInt _FT_UInt);
		    
		[CLink]
		public static extern FT_UInt FT_Get_Name_Index(FT_Face Face, FT_String _FT_String);
		    
		[CLink]
		public static extern FT_Error FT_Get_SubGlyph_Info(FT_GlyphSlot GlyphSlot, FT_UInt _FT_UInt, FT_Int _FT_Int, FT_UInt _FT_UInt_2, FT_Int _FT_Int_2, FT_Int _FT_Int_3, FT_Matrix _FT_Matrix);
		    
		[CLink]
		public static extern FT_UShort FT_Get_FSType_Flags(FT_Face Face);
		    
		[CLink]
		public static extern FT_UInt FT_Face_GetCharVariantIndex(FT_Face Face, FT_ULong _FT_ULong, FT_ULong _FT_ULong_2);
		    
		[CLink]
		public static extern FT_Int FT_Face_GetCharVariantIsDefault(FT_Face Face, FT_ULong _FT_ULong, FT_ULong _FT_ULong_2);
		    
		[CLink]
		public static extern FT_UInt32* FT_Face_GetVariantSelectors(FT_Face Face);
		    
		[CLink]
		public static extern FT_UInt32* FT_Face_GetVariantsOfChar(FT_Face Face, FT_ULong _FT_ULong);
		    
		[CLink]
		public static extern FT_UInt32* FT_Face_GetCharsOfVariant(FT_Face Face, FT_ULong _FT_ULong);
		    
		[CLink]
		public static extern FT_Long FT_MulDiv(FT_Long Long, FT_Long _FT_Long, FT_Long _FT_Long_2);
		    
		[CLink]
		public static extern FT_Long FT_MulFix(FT_Long Long, FT_Long _FT_Long);
		    
		[CLink]
		public static extern FT_Long FT_DivFix(FT_Long Long, FT_Long _FT_Long);
		    
		[CLink]
		public static extern FT_Fixed FT_RoundFix(FT_Fixed Fixed);
		    
		[CLink]
		public static extern FT_Fixed FT_CeilFix(FT_Fixed Fixed);
		    
		[CLink]
		public static extern FT_Fixed FT_FloorFix(FT_Fixed Fixed);
		    
		[CLink]
		public static extern void FT_Vector_Transform(FT_Vector* Vector, FT_Matrix _FT_Matrix);
		    
		[CLink]
		public static extern void FT_Library_Version(FT_Library Library, FT_Int _FT_Int, FT_Int _FT_Int_2, FT_Int _FT_Int_3);
		    
		[CLink]
		public static extern FT_Bool FT_Face_CheckTrueTypePatents(FT_Face Face);
		    
		[CLink]
		public static extern FT_Bool FT_Face_SetUnpatentedHinting(FT_Face Face, FT_Bool _FT_Bool);

		    // ftadvanc.h
		    
		[CLink]
		public static extern FT_Error FT_Get_Advance(FT_Face Face, FT_UInt _FT_UInt, FT_Int32 _FT_Int32, FT_Fixed _FT_Fixed);
		    
		[CLink]
		public static extern FT_Error FT_Get_Advances(FT_Face Face, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2, FT_Int32 _FT_Int32, FT_Fixed _FT_Fixed);

		    // ftbbox.h
		    
		[CLink]
		public static extern FT_Error FT_Outline_Get_BBox(FT_Outline* Outline, FT_BBox _FT_BBox);

	    // ftbdf.h
	    //version(linux) {
	        
			/*[CLink]
			public static extern FT_Error FT_Get_BDF_Charset_ID(FT_Face Face, char8 _char, acharset_encoding, char _char acharset_registry);*/
			        
			[CLink]
			public static extern FT_Error FT_Get_BDF_Property(FT_Face Face, char8 _char, BDF_PropertyRec _BDF_PropertyRec);
	    //}

		    // ftbitmap.h
		    
		[CLink]
		public static extern void FT_Bitmap_Init(FT_Bitmap* Bitmap);
		    
		[CLink]
		public static extern FT_Error FT_Bitmap_Copy(FT_Library Library, FT_Bitmap _FT_Bitmap, FT_Bitmap _FT_Bitmap_2);
		    
		[CLink]
		public static extern FT_Error FT_Bitmap_Embolden(FT_Library Library, FT_Bitmap _FT_Bitmap, FT_Pos _FT_Pos, FT_Pos _FT_Pos_2);
		    
		[CLink]
		public static extern FT_Error FT_Bitmap_Convert(FT_Library Library, FT_Bitmap _FT_Bitmap, FT_Bitmap _FT_Bitmap_2, FT_Int _FT_Int);
		    
		[CLink]
		public static extern FT_Error FT_GlyphSlot_Own_Bitmap(FT_GlyphSlot GlyphSlot);
		    
		[CLink]
		public static extern FT_Error FT_Bitmap_Done(FT_Library Library, FT_Bitmap _FT_Bitmap);

		    // ftbzip2.h
		    
		[CLink]
		public static extern FT_Error FT_Stream_OpenBzip2(FT_Stream Stream, FT_Stream _FT_Stream);

		    // ftcache.h
		    
		[CLink]
		public static extern FT_Error FTC_Manager_New(FT_Library Library, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2, FT_ULong _FT_ULong, FTC_Face_Requester _FTC_Face_Requester, FT_Pointer _FT_Pointer, FTC_Manager _FTC_Manager);
		    
		[CLink]
		public static extern void FTC_Manager_Reset(FTC_Manager manager);
		    
		[CLink]
		public static extern void FTC_Manager_Done(FTC_Manager manager);
		    
		[CLink]
		public static extern FT_Error FTC_Manager_LookupFace(FTC_Manager manager, FTC_FaceID _FTC_FaceID, FT_Face _FT_Face);
		    
		[CLink]
		public static extern FT_Error FTC_Manager_LookupSize(FTC_Manager manager, FTC_Scaler _FTC_Scaler, FT_Size _FT_Size);
		    
		[CLink]
		public static extern void FTC_Node_Unref(FTC_Node node, FTC_Manager _FTC_Manager);
		    
		[CLink]
		public static extern void FTC_Manager_RemoveFaceID(FTC_Manager manager, FTC_FaceID _FTC_FaceID);
		    
		[CLink]
		public static extern FT_Error FTC_CMapCache_New(FTC_Manager manager, FTC_CMapCache _FTC_CMapCache);
		    
		[CLink]
		public static extern FT_UInt FTC_CMapCache_Lookup(FTC_CMapCache manager, FTC_FaceID _FTC_FaceID, FT_Int _FT_Int, FT_UInt32 _FT_UInt32);
		    
		[CLink]
		public static extern FT_Error FTC_ImageCache_New(FTC_Manager manager, FTC_ImageCache _FTC_ImageCache);
		    
		[CLink]
		public static extern FT_Error FTC_ImageCache_Lookup(FTC_ImageCache cache, FTC_ImageType _FTC_ImageType, FT_UInt _FT_UInt, FT_Glyph _FT_Glyph, FTC_Node _FTC_Node);
		    
		[CLink]
		public static extern FT_Error FTC_ImageCache_LookupScaler(FTC_ImageCache cache, FTC_Scaler _FTC_Scaler, FT_ULong _FT_ULong, FT_UInt _FT_UInt, FT_Glyph _FT_Glyph, FTC_Node _FTC_Node);
		    
		[CLink]
		public static extern FT_Error FTC_SBitCache_New(FTC_Manager manager, FTC_SBitCache _FTC_SBitCache);
		    
		[CLink]
		public static extern FT_Error FTC_SBitCache_Lookup(FTC_SBitCache cache, FTC_ImageType _FTC_ImageType, FT_UInt _FT_UInt, FTC_SBit _FTC_SBit, FTC_Node _FTC_Node);
		    
		[CLink]
		public static extern FT_Error FTC_SBitCache_LookupScaler(FTC_SBitCache cache, FTC_Scaler _FTC_Scaler, FT_ULong _FT_ULong, FT_UInt _FT_UInt, FTC_SBit _FTC_SBit, FTC_Node _FTC_Node);

		    // ftcid.h
		    
		[CLink]
		public static extern FT_Error FT_Get_CID_Registry_Ordering_Supplement(FT_Face Face, char8 _char, char8 _char_2, FT_Int _FT_Int);
		    
		[CLink]
		public static extern FT_Error FT_Get_CID_Is_Internally_CID_Keyed(FT_Face Face, FT_Bool _FT_Bool);
		    
		[CLink]
		public static extern FT_Error FT_Get_CID_From_Glyph_Index(FT_Face Face, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2);

		    // ftgasp.h
		    
		[CLink]
		public static extern FT_Int FT_Get_Gasp(FT_Face Face, FT_UInt _FT_UInt);

		    // ftglyph.h
		    
		[CLink]
		public static extern FT_Error FT_Get_Glyph(FT_GlyphSlot GlyphSlot, FT_Glyph _FT_Glyph);
		    
		[CLink]
		public static extern FT_Error FT_Glyph_Copy(FT_Glyph Glyph, FT_Glyph _FT_Glyph);
		    
		[CLink]
		public static extern FT_Error FT_Glyph_Transform(FT_Glyph Glyph, FT_Matrix _FT_Matrix, FT_Vector _FT_Vector);
		    
		[CLink]
		public static extern void FT_Glyph_Get_CBox(FT_Glyph Glyph, FT_UInt _FT_UInt, FT_BBox _FT_BBox);
		    
		[CLink]
		public static extern FT_Error FT_Glyph_To_Bitmap(FT_Glyph* Glyph, FT_Render_Mode _FT_Render_Mode, FT_Vector _FT_Vector, FT_Bool _FT_Bool);
		    
		[CLink]
		public static extern void FT_Done_Glyph(FT_Glyph Glyph);
		    
		[CLink]
		public static extern void FT_Matrix_Multiply(FT_Matrix* Matrix, FT_Matrix _FT_Matrix);
		    
		[CLink]
		public static extern FT_Error FT_Matrix_Invert(FT_Matrix* Matrix);

		    // ftgxval.h
		    
		[CLink]
		public static extern FT_Error FT_TrueTypeGX_Validate(FT_Face Face, FT_UInt _FT_UInt, FT_Bytes _FT_Bytes, FT_UInt _FT_UInt_2);
		    
		[CLink]
		public static extern void FT_TrueTypeGX_Free(FT_Face Face, FT_Bytes _FT_Bytes);
		    
		[CLink]
		public static extern FT_Error FT_ClassicKern_Validate(FT_Face Face, FT_UInt _FT_UInt, FT_Bytes _FT_Bytes);
		    
		[CLink]
		public static extern void FT_ClassicKern_Free(FT_Face Face, FT_Bytes _FT_Bytes);

		    // ftgzip.h
		    
		[CLink]
		public static extern FT_Error FT_Stream_OpenGzip(FT_Stream Stream, FT_Stream _FT_Stream);
		    
		[CLink]
		public static extern FT_Error FT_Gzip_Uncompress(FT_Memory Memory, FT_Byte _FT_Byte, FT_ULong _FT_ULong, FT_Byte _FT_Byte_2, FT_ULong _FT_ULong_2);

		    // ftlcdfil.h
		    
		[CLink]
		public static extern FT_Error FT_Library_SetLcdFilter(FT_Library Library, FT_LcdFilter _FT_LcdFilter);
		    
		[CLink]
		public static extern FT_Error FT_Library_SetLcdFilterWeights(FT_Library Library, uint8 _ubyte);

		    
		[CLink]
		public static extern FT_ListNode FT_List_Find(FT_List List, void _void);
		    
		[CLink]
		public static extern void FT_List_Add(FT_List List, FT_ListNode _FT_ListNode);
		    
		[CLink]
		public static extern void FT_List_Insert(FT_List List, FT_ListNode _FT_ListNode);
		    
		[CLink]
		public static extern void FT_List_Remove(FT_List List, FT_ListNode _FT_ListNode);
		    
		[CLink]
		public static extern void FT_List_Up(FT_List List, FT_ListNode _FT_ListNode);
		    
		[CLink]
		public static extern FT_Error FT_List_Iterate(FT_List List, FT_List_Iterator _FT_List_Iterator, void _void);
		    
		[CLink]
		public static extern void FT_List_Finalize(FT_List List, FT_List_Destructor _FT_List_Destructor, FT_Memory _FT_Memory, void _void);

		    // ftlzw.h
		    
		[CLink]
		public static extern FT_Error FT_Stream_OpenLZW(FT_Stream Stream, FT_Stream _FT_Stream);

		    // ftmm.h
		    
		[CLink]
		public static extern FT_Error FT_Get_Multi_Master(FT_Face Face, FT_Multi_Master _FT_Multi_Master);
		    
		[CLink]
		public static extern FT_Error FT_Get_MM_Var(FT_Face Face, FT_MM_Var _FT_MM_Var);
		    
		[CLink]
		public static extern FT_Error FT_Set_MM_Design_Coordinates(FT_Face Face, FT_UInt _FT_UInt, FT_Long _FT_Long);
		    
		[CLink]
		public static extern FT_Error FT_Set_Var_Design_Coordinates(FT_Face Face, FT_UInt _FT_UInt, FT_Fixed _FT_Fixed);
		    
		[CLink]
		public static extern FT_Error FT_Set_MM_Blend_Coordinates(FT_Face Face, FT_UInt _FT_UInt, FT_Fixed _FT_Fixed);
		    
		[CLink]
		public static extern FT_Error FT_Set_Var_Blend_Coordinates(FT_Face Face, FT_UInt _FT_UInt, FT_Fixed _FT_Fixed);

		    // ftmodapi.h
		    
		[CLink]
		public static extern FT_Error FT_Add_Module(FT_Library Library, FT_Module_Class _FT_Module_Class);
		    
		[CLink]
		public static extern FT_Module FT_Get_Module(FT_Library Library, char8 _char);
		    
		[CLink]
		public static extern FT_Error FT_Remove_Module(FT_Library Library, FT_Module _FT_Module);
		    
		[CLink]
		public static extern FT_Error FT_Property_Set(FT_Library Library, FT_String _FT_String, FT_String _FT_String_2, void _void);
		    
		[CLink]
		public static extern FT_Error FT_Property_Get(FT_Library Library, FT_String _FT_String, FT_String _FT_String_2, void _void);
		    
		[CLink]
		public static extern FT_Error FT_Reference_Library(FT_Library Library);
		    
		[CLink]
		public static extern FT_Error FT_New_Library(FT_Memory Memory, FT_Library _FT_Library);
		    
		[CLink]
		public static extern FT_Error FT_Done_Library(FT_Library Library);
		    
		[CLink]
		public static extern void FT_Set_Debug_Hook(FT_Library Library, FT_UInt _FT_UInt, FT_DebugHook_Func _FT_DebugHook_Func);
		    
		[CLink]
		public static extern void FT_Add_Default_Modules(FT_Library Library);
		    
		[CLink]
		public static extern FT_TrueTypeEngineType FT_Get_TrueType_Engine_Type(FT_Library Library);

		    // ftotval.h
		    
		[CLink]
		public static extern FT_Error FT_OpenType_Validate(FT_Face Face, FT_UInt _FT_UInt, FT_Bytes _FT_Bytes, FT_Bytes _FT_Bytes_2, FT_Bytes _FT_Bytes_3, FT_Bytes _FT_Bytes_4, FT_Bytes _FT_Bytes_5);
		    
		[CLink]
		public static extern void FT_OpenType_Free(FT_Face Face, FT_Bytes _FT_Bytes);

		    // ftoutln.h
		    
		[CLink]
		public static extern FT_Error FT_Outline_Decompose(FT_Outline* Outline, FT_Outline_Funcs _FT_Outline_Funcs, void _void);
		    
		[CLink]
		public static extern FT_Error FT_Outline_New(FT_Library Library, FT_UInt _FT_UInt, FT_Int _FT_Int, FT_Outline _FT_Outline);
		    
		[CLink]
		public static extern FT_Error FT_Outline_Done(FT_Library Library, FT_Outline _FT_Outline);
		    
		[CLink]
		public static extern FT_Error FT_Outline_Check(FT_Outline* Outline);
		    
		[CLink]
		public static extern void FT_Outline_Get_CBox(FT_Outline* Outline, FT_BBox _FT_BBox);
		    
		[CLink]
		public static extern void FT_Outline_Translate(FT_Outline* Outline, FT_Pos _FT_Pos, FT_Pos _FT_Pos_2);
		    
		[CLink]
		public static extern FT_Error FT_Outline_Copy(FT_Outline* Outline, FT_Outline _FT_Outline);
		    
		[CLink]
		public static extern void FT_Outline_Transform(FT_Outline* Outline, FT_Matrix _FT_Matrix);
		    
		[CLink]
		public static extern FT_Error FT_Outline_Embolden(FT_Outline* Outline, FT_Pos _FT_Pos);
		    
		[CLink]
		public static extern FT_Error FT_Outline_EmboldenXY(FT_Outline* Outline, FT_Pos _FT_Pos, FT_Pos _FT_Pos_2);
		    
		[CLink]
		public static extern void FT_Outline_Reverse(FT_Outline* Outline);
		    
		[CLink]
		public static extern FT_Error FT_Outline_Get_Bitmap(FT_Library Library, FT_Outline _FT_Outline, FT_Bitmap _FT_Bitmap);
		    
		[CLink]
		public static extern FT_Error FT_Outline_Render(FT_Library Library, FT_Outline _FT_Outline, FT_Raster_Params _FT_Raster_Params);
		    
		[CLink]
		public static extern FT_Orientation FT_Outline_Get_Orientation(FT_Outline* Outline);

		    // ftpfr.h
		    
		[CLink]
		public static extern FT_Error FT_Get_PFR_Metrics(FT_Face Face, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2, FT_Fixed _FT_Fixed, FT_Fixed _FT_Fixed_2);
		    
		[CLink]
		public static extern FT_Error FT_Get_PFR_Kerning(FT_Face Face, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2, FT_Vector _FT_Vector);
		    
		[CLink]
		public static extern FT_Error FT_Get_PFR_Advance(FT_Face Face, FT_UInt _FT_UInt, FT_Pos _FT_Pos);

		    // ftrender.h
		    
		[CLink]
		public static extern FT_Renderer FT_Get_Renderer(FT_Library Library, FT_Glyph_Format _FT_Glyph_Format);
		    
		[CLink]
		public static extern FT_Error FT_Set_Renderer(FT_Library Library, FT_Renderer _FT_Renderer, FT_UInt _FT_UInt, FT_Parameter _FT_Parameter);

		    // ftsizes.h
		    
		[CLink]
		public static extern FT_Error FT_New_Size(FT_Face Face, FT_Size _FT_Size);
		    
		[CLink]
		public static extern FT_Error FT_Done_Size(FT_Size Size);
		    
		[CLink]
		public static extern FT_Error FT_Activate_Size(FT_Size Size);

		    // ftsnames.h
		    
		[CLink]
		public static extern FT_UInt FT_Get_Sfnt_Name_Count(FT_Face Face);

		    // ftstroke.h
		    
		[CLink]
		public static extern FT_StrokerBorder FT_Outline_GetInsideBorder(FT_Outline* Outline);
		    
		[CLink]
		public static extern FT_StrokerBorder FT_Outline_GetOutsideBorder(FT_Outline* Outline);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_New(FT_Memory Memory, FT_Stroker _FT_Stroker);
		    
		[CLink]
		public static extern void FT_Stroker_Set(FT_Stroker Stroker, FT_Fixed _FT_Fixed, FT_Stroker_LineCap _FT_Stroker_LineCap, FT_Stroker_LineJoin _FT_Stroker_LineJoin, FT_Fixed _FT_Fixed_2);
		    
		[CLink]
		public static extern void FT_Stroker_Rewind(FT_Stroker Stroker);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_ParseOutline(FT_Stroker Stroker, FT_Outline _FT_Outline, FT_Bool _FT_Bool);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_BeginSubPath(FT_Stroker Stroker, FT_Vector _FT_Vector, FT_Bool _FT_Bool);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_EndSubPath(FT_Stroker Stroker);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_LineTo(FT_Stroker Stroker, FT_Vector _FT_Vector);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_ConicTo(FT_Stroker Stroker, FT_Vector _FT_Vector, FT_Vector _FT_Vector_2);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_CubicTo(FT_Stroker Stroker, FT_Vector _FT_Vector, FT_Vector _FT_Vector_2, FT_Vector _FT_Vector_3);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_GetBorderCounts(FT_Stroker Stroker, FT_StrokerBorder _FT_StrokerBorder, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2);
		    
		[CLink]
		public static extern void FT_Stroker_ExportBorder(FT_Stroker Stroker, FT_StrokerBorder _FT_StrokerBorder, FT_Outline _FT_Outline);
		    
		[CLink]
		public static extern FT_Error FT_Stroker_GetCounts(FT_Stroker Stroker, FT_UInt _FT_UInt, FT_UInt _FT_UInt_2);
		    
		[CLink]
		public static extern void FT_Stroker_Export(FT_Stroker Stroker, FT_Outline _FT_Outline);
		    
		[CLink]
		public static extern void FT_Stroker_Done(FT_Stroker Stroker);
		    
		[CLink]
		public static extern FT_Error FT_Glyph_Stroke(FT_Glyph* Glyph, FT_Stroker _FT_Stroker, FT_Bool _FT_Bool);
		    
		[CLink]
		public static extern FT_Error FT_Glyph_StrokeBorder(FT_Glyph* Glyph, FT_Stroker _FT_Stroker, FT_Bool _FT_Bool, FT_Bool _FT_Bool_2);

		    // ftsynth.h
		    
		[CLink]
		public static extern void FT_GlyphSlot_Embolden(FT_GlyphSlot GlyphSlot);
		    
		[CLink]
		public static extern void FT_GlyphSlot_Oblique(FT_GlyphSlot GlyphSlot);

		    // fttrigon.h
		    
		[CLink]
		public static extern FT_Fixed FT_Sin(FT_Angle Angle);
		    
		[CLink]
		public static extern FT_Fixed FT_Cos(FT_Angle Angle);
		    
		[CLink]
		public static extern FT_Fixed FT_Tan(FT_Angle Angle);
		    
		[CLink]
		public static extern FT_Angle FT_Atan2(FT_Fixed Fixed, FT_Fixed _FT_Fixed);
		    
		[CLink]
		public static extern FT_Angle FT_Angle_Diff(FT_Angle Angle, FT_Angle _FT_Angle);
		    
		[CLink]
		public static extern void FT_Vector_Unit(FT_Vector* Vector, FT_Angle _FT_Angle);
		    
		[CLink]
		public static extern void FT_Vector_Rotate(FT_Vector* Vector, FT_Angle _FT_Angle);
		    
		[CLink]
		public static extern FT_Fixed FT_Vector_Length(FT_Vector* Vector);
		    
		[CLink]
		public static extern void FT_Vector_Polarize(FT_Vector* Vector, FT_Fixed _FT_Fixed, FT_Angle _FT_Angle);
		    
		[CLink]
		public static extern void FT_Vector_From_Polar(FT_Vector* Vector, FT_Fixed _FT_Fixed, FT_Angle _FT_Angle);

		    // ftwinfnt.h
		    
		[CLink]
		public static extern FT_Error FT_Get_WinFNT_Header(FT_Face Face, FT_WinFNT_HeaderRec _FT_WinFNT_HeaderRec);

		    // ftxf86.h
		    
		[CLink]
		public static extern char8* FT_Get_X11_Font_Format(FT_Face Face);

		    // t1tables.h
		    
		[CLink]
		public static extern FT_Int FT_Has_PS_Glyph_Names(FT_Face Face);
		    
		[CLink]
		public static extern FT_Error FT_Get_PS_Font_Info(FT_Face Face, PS_FontInfoRec _PS_FontInfoRec);
		    
		[CLink]
		public static extern FT_Error FT_Get_PS_Font_Private(FT_Face Face, PS_PrivateRec _PS_PrivateRec);
		    
		[CLink]
		public static extern FT_Long FT_Get_PS_Font_Value(FT_Face Face, PS_Dict_Keys _PS_Dict_Keys, FT_UInt _FT_UInt, FT_Long _FT_Long);

		    // tttables.h
		    
		[CLink]
		public static extern void* FT_Get_Sfnt_Table(FT_Face Face, FT_Sfnt_Tag _FT_Sfnt_Tag);
		    
		[CLink]
		public static extern FT_Error FT_Load_Sfnt_Table(FT_Face Face, FT_ULong _FT_ULong, FT_Long _FT_Long, FT_Byte _FT_Byte, FT_ULong _FT_ULong_2);
		    
		[CLink]
		public static extern FT_Error FT_Sfnt_Table_Info(FT_Face Face, FT_UInt _FT_UInt, FT_ULong _FT_ULong, FT_ULong _FT_ULong_2);
		    
		[CLink]
		public static extern FT_ULong FT_Get_CMap_Language_ID(FT_CharMap CharMap);
		    
		[CLink]
		public static extern FT_ULong FT_Get_CMap_Format(FT_CharMap CharMap);
		    
		[CLink]
		public static extern FT_Error FT_Get_Sfnt_Name(FT_Face Face, FT_UInt _FT_UInt, FT_SfntName _FT_SfntName);
	}
}
