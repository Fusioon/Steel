namespace SteelEngine.Renderer
{
	public enum TextureFormat
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
		RH, //half float
		RGH,
		RGBH,
		RGBAH,
		RGBE9995,
		DXT1, //s3tc bc1
		DXT3, //bc2
		DXT5, //bc3
		RGTC_R,
		RGTC_RG,
		BPTC_RGBA, //btpc bc7
		BPTC_RGBF, //float bc6h
		BPTC_RGBFU, //unsigned float bc6hu
		PVRTC2, //pvrtc
		PVRTC2A,
		PVRTC4,
		PVRTC4A,
		ETC, //etc1
		ETC2_R11, //etc2
		ETC2_R11S, //signed, NOT srgb.
		ETC2_RG11,
		ETC2_RG11S,
		ETC2_RGB8,
		ETC2_RGBA8,
		ETC2_RGB8A1,
		ETC2_RA_AS_RG, //used to make basis universal happy
		DXT5_RA_AS_RG, //used to make basis universal happy

		
		UnknownDepth,
		D16,
		D24,
		D24S8,
		D32,
		D16F,
		D24F,
		D32F,
		D0S8,
	}
}
