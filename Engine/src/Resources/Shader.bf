using System;
using SteelEngine.Renderer;

namespace SteelEngine
{
	public class Shader : Resource
	{
		String _vertShaderCode ~ delete _;
		String _fragShaderCode ~ delete _;
		public StringView VertexShaderCode => _vertShaderCode;
		public StringView FragmentShaderCode => _fragShaderCode;

		protected override void Release()
		{
			base.Release();
		}

		public this(String vert, String frag)
		{
			_vertShaderCode = vert;
			_fragShaderCode = frag;
		}
	}

	public class Material : Resource
	{
		public Shader shader ~ _.DisposeSafe();
		public Texture2D colorTex ~ _.DisposeSafe();
		public Texture2D normTex ~ _.DisposeSafe();

		public this(Shader shader)
		{
			this.shader = shader;
		}
	}

}
