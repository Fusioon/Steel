namespace SteelEngine
{
	public class Singleton<T> where T : Singleton<T>
	{
		static T _singleton;
		public static T Instance => _singleton;
		protected this()
		{
			_singleton = (T)this;
		}
	}
}
