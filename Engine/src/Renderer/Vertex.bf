using System;
using SteelEngine.Math;

namespace SteelEngine.Renderer
{
	[CRepr, Ordered, Reflect]
	struct Vertex
	{
		[VertexUsage(.Position)]
		public Vector3 pos = .Zero;

		[VertexUsage(.Normal)]
		public Vector3 normal = .Zero;

		[VertexUsage(.Tangent)]
		public Vector3 tangent = .Zero;

		[VertexUsage(.TexCoord0)]
		public Vector2 textCoord0 = .Zero;

		[VertexUsage(.TexCoord1)]
		public Vector2 textCoord1 = .Zero;

		[VertexUsage(.TexCoord2)]
		public Vector2 textCoord2 = .Zero;

		[VertexUsage(.TexCoord3)]
		public Vector2 textCoord3 = .Zero;

		[VertexUsage(.Color0)]
		public int32 abgr = 0;

		public this()
		{

		}

		public this(Vector3 p, int32 color)
		{
			pos = p;
			abgr = color;
		}

		public this(Vector3 p, Vector2 coord, int32 color)
		{
			pos = p;
			textCoord0 = coord;
			abgr = color;
		}

		public this(Vector3 p, Vector3 norm, Vector3 tang, Vector2 coord, int32 color)
		{
			pos = p;
			normal = norm;
			tangent = tang;
			textCoord0 = coord;
			abgr = color;
		}


		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, pos.GetHashCode());
			Helpers.HashCombine(ref seed, normal.GetHashCode());
			Helpers.HashCombine(ref seed, tangent.GetHashCode());
			Helpers.HashCombine(ref seed, textCoord0.GetHashCode());
			Helpers.HashCombine(ref seed, textCoord1.GetHashCode());
			Helpers.HashCombine(ref seed, textCoord2.GetHashCode());
			Helpers.HashCombine(ref seed, textCoord3.GetHashCode());
			Helpers.HashCombine(ref seed, abgr.GetHashCode());
			return seed;
		}
	}
	
}
