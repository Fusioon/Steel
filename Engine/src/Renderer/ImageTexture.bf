using System;
namespace SteelEngine.Renderer
{
	public class ImageTexture : Texture2D
	{
		Image _img ~ _.Dispose();
		public Image Image => _img;

		public override Span<uint8> Data => _img.Data;

		public this(Image img)
		{
			_img = img..AddRef();
			_width = img.Width;
			_height = img.Height;
			_format = img.Format;
			_mipLevels = 1;
		}
	}
}
