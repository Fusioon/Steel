using System;

namespace SteelEngine
{
	struct RID : IHashable
	{
		const uint64 NULL = 0;
		private uint64 _id;
		public uint64 Id => _id; 

		public bool IsValid => this._id != NULL;
		public bool IsNull => this._id == NULL;

		[Inline]
		public this()
		{
			_id = NULL;
		}

		public override void ToString(System.String strBuffer)
		{
			_id.ToString(strBuffer);
		}

		[Inline]
		public int GetHashCode() => _id.GetHashCode();

		public static bool operator ==(Self lv, Self rv) => lv._id == rv._id;
		public static bool operator !=(Self lv, Self rv) => lv._id != rv._id;
		public static bool operator <(Self lv, Self rv) => lv._id < rv._id;
		public static bool operator <=(Self lv, Self rv) => lv._id <= rv._id;
		public static bool operator >(Self lv, Self rv) => lv._id > rv._id;
		public static bool operator >=(Self lv, Self rv) => lv._id >= rv._id;
	}
}
