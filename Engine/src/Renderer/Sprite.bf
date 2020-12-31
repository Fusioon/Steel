namespace SteelEngine.Renderer
{
	class SpriteAtlas : Resource
	{
	}

	class Sprite : Resource
	{
		public Texture2D Texture { get; protected set; }
		public Rect Rectangle { get; protected set; }

		public ~this()
		{
			Texture.UnrefSafe();
		}

		public void SetData(Texture2D texture, Rect rect)
		{
			let tmp = Texture;
			Texture = texture..AddRef();
			tmp.UnrefSafe();

			Rectangle = rect;
		}
	}
}
