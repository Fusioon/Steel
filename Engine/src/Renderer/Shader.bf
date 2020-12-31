using System;
using SteelEngine;

namespace SteelEngine.Renderer
{
	public class Shader : Resource
	{
		String _vertShaderCode ~ delete _;
		String _fragShaderCode ~ delete _;
		public StringView VertexShaderCode => _vertShaderCode;
		public StringView FragmentShaderCode => _fragShaderCode;

		ShaderType _shaderType = .Unknown;
		public ShaderType Type => _shaderType; 

		protected override Result<void> OnUnload()
		{
			base.Release();
			return .Ok;
		}

		public void SetData(String vert, String frag)
		{
			Assert!(vert != _vertShaderCode);
			Assert!(frag != _fragShaderCode);

			delete _vertShaderCode;
			delete _fragShaderCode;
			_vertShaderCode = vert;
			_fragShaderCode = frag;
		}
	}

	public class Material : Resource
	{
		public Shader shader ~ _.UnrefSafe();
		public Texture2D colorTex ~ _.UnrefSafe();
		public Texture2D normTex ~ _.UnrefSafe();
	}

}
