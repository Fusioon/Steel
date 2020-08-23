using System;
using SteelEngine.Math;

namespace SteelEngine.Renderer
{
	[CRepr, Ordered, Reflect]
	struct PositionColorVertex : IHashable
	{
		[VertexUsage(.Position)]
		public Vector3 pos;
		[VertexUsage(.TexCoord0)]
		public Vector2 textCoord;
		[VertexUsage(.Color0)]
		public int32 abgr;

		public this(Vector3 p, int32 color)
		{
			this = default;
			pos = p;
			abgr = color;
		}

		public this(Vector3 p, Vector2 coord, int32 color)
		{
			this = default;
			pos = p;
			textCoord = coord;
			abgr = color;
		}


		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, pos.GetHashCode());
			Helpers.HashCombine(ref seed, textCoord.GetHashCode());
			Helpers.HashCombine(ref seed, textCoord.GetHashCode());
			return seed;
		}
	}

	typealias Vertex = PositionColorVertex;

	[CRepr, Ordered, Reflect]
	struct PositionColorNormalVertex : IHashable
	{
		[VertexUsage(.Position)]
		public Vector3 pos;
		[VertexUsage(.Normal)]
		public Vector3 normal;
		[VertexUsage(.TexCoord0)]
		public Vector2 textCoord;
		[VertexUsage(.Color0)]
		public int32 abgr;

		public this(Vector3 p, int32 color)
		{
			this = default;
			pos = p;
			abgr = color;
		}

		public this(Vector3 p, Vector2 coord, int32 color)
		{
			this = default;
			pos = p;
			textCoord = coord;
			abgr = color;
		}


		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, pos.GetHashCode());
			Helpers.HashCombine(ref seed, normal.GetHashCode());
			Helpers.HashCombine(ref seed, textCoord.GetHashCode());
			Helpers.HashCombine(ref seed, textCoord.GetHashCode());
			return seed;
		}
	}
}
