using System;

namespace SteelEngine
{
	[CRepr, Ordered]
	struct Plane
	{
		public Vector3 normal;
		public float d;

		[Inline]
		public Vector3 Center => normal * d;

		[Inline]
		public float DistanceTo(Vector3 point) => Vector3.DotProduct(normal, point) - d;
	}
}
