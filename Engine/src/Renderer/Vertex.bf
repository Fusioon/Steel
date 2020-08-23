using System;
using SteelEngine.Math;

namespace SteelEngine.Renderer
{
	[CRepr, Ordered]
	struct PositionColorVertex : IHashable
	{
		public Vector3 pos;
		public Vector2 textCoord;
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

	[CRepr, Ordered]
	struct PositionColorNormalVertex : IHashable
	{
		public Vector3 pos;
		public Vector3 normal;
		public Vector2 textCoord;
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
