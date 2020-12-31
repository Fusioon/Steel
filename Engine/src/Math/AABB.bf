using System;

namespace SteelEngine
{
	[CRepr, Ordered]
	struct AABB
	{
		public Vector3 position;
		public Vector3 size;

		mixin P2(var v)
		{
			v + v
		}

		[Inline] public float Area => P2!(size.x * size.y) + P2!(size.x * size.z) + P2!(size.y * size.z);
		[Inline] public bool HasNoSurface => (size.x <= 0 && size.y <= 0 && size.z <= 0);

		[Inline]
		public static bool operator==(Self lv, Self rv)
		{
			return (lv.position == rv.position) && (lv.size == rv.size);
		}

		[Inline]
		public bool IsEqualApprox(Self other) => Vector3.IsEqualsApprox(position, other.position) && Vector3.IsEqualsApprox(size, other.size);

		 /// Both AABBs overlap
		[Inline]
		public bool Intersects(Self other)
		{
			if (position.x >= (other.position.x + other.size.x))
				return false;
			if ((position.x + size.x) <= other.position.x)
				return false;
			if (position.y >= (other.position.y + other.size.y))
				return false;
			if ((position.y + size.y) <= other.position.y)
				return false;
			if (position.z >= (other.position.z + other.size.z))
				return false;
			if ((position.z + size.z) <= other.position.z)
				return false;

			return true;
		}


		/// Both AABBs (or their faces) overlap
		[Inline]
		bool IntersectsInclusive(Self other)
		{
			if (position.x > (other.position.x + other.size.x))
				return false;
			if ((position.x + size.x) < other.position.x)
				return false;
			if (position.y > (other.position.y + other.size.y))
				return false;
			if ((position.y + size.y) < other.position.y)
				return false;
			if (position.z > (other.position.z + other.size.z))
				return false;
			if ((position.z + size.z) < other.position.z)
				return false;

			return true;
		}

		/// other AABB is completely inside this AABB
		[Inline]
		bool Encloses(Self other)
		{
			Vector3 src_min = position;
			Vector3 src_max = position + size;
			Vector3 dst_min = other.position;
			Vector3 dst_max = other.position + other.size;

			return (src_min.x <= dst_min.x) &&
				(src_max.x > dst_max.x) &&
				(src_min.y <= dst_min.y) &&
				(src_max.y > dst_max.y) &&
				(src_min.z <= dst_min.z) &&
				(src_max.z > dst_max.z);
		}

		Self Merge(Self with)
		{
			var t = this; return t..MergeWith(with);
		}
		void MergeWith(Self aabb) { }///merge with another AABB

		Self Intersection(Self aabb) { return default; }///get box where two intersect, empty if no intersection occurs
		bool IntersectsSegment(Vector3 from, Vector3 to, out Vector3 clip, out Vector3 normal) { clip = normal = default; return false; }
		bool IntersectsRay(Vector3 from, Vector3 dir, out Vector3 clip, out Vector3 normal) { clip = normal = default; return false; }

		bool smits_intersect_ray(Vector3 from, Vector3 dir, float t0, float t1) { return false; }

		//bool IntersectsConvexShape(const Plane *p_planes, int p_plane_count, const Vector3 *p_points, int
		// p_point_count) const; bool inside_convex_shape(const Plane *p_planes, int p_plane_count) const;
		public bool IntersectsPlane(Plane plane)
		{
			Vector3[8] points = .(
				Vector3(position.x, position.y, position.z),
				Vector3(position.x, position.y, position.z + size.z),
				Vector3(position.x, position.y + size.y, position.z),
				Vector3(position.x, position.y + size.y, position.z + size.z),
				Vector3(position.x + size.x, position.y, position.z),
				Vector3(position.x + size.x, position.y, position.z + size.z),
				Vector3(position.x + size.x, position.y + size.y, position.z),
				Vector3(position.x + size.x, position.y + size.y, position.z + size.z)
				);

			bool over = false;
			bool under = false;

			for (int i = 0; i < 8; i++)
			{
				if (plane.DistanceTo(points[i]) > 0)
				{
					over = true;
				} else
				{
					under = true;
				}
			}

			return under && over;
		}

		// @TODO

		bool HasPoint(Vector3 point) { return default; }
		Vector3 GetSupport(Vector3 normal) { return default; }

		Vector3 LongestAxis => default;
		int LongestAxisIndex => default;
		float LongestAxisSize => default;

		Vector3 ShortestAxis => default;
		int ShortestAxisIndex => default;
		float ShortestAxisSize => default;

		Self Grow(float by) { return default; }
		void GrowBy(float amount) { }

		void get_edge(int edge, out Vector3 from, out Vector3 to) { from = to = default; }
		Vector3 get_endpoint(int point) { return default; }

		Self Expand(Vector3 vector) { return default; }
		//void ProjectRangeInPlane(Plane plane, out float min, out float max) { min = max = default; }const;
		void ExpandTo(Vector3 vector) { }/** expand to contain a point if necessary */



		public this()
		{
			this = default;
		}

		public this(Vector3 pos, Vector3 _size)
		{
			position = pos;
			size = _size;
		}
	}
}
