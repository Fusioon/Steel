using System;

namespace SteelEngine
{
	public interface IGame
	{
		Result<void> Setup();
		Result<void> Init();
		void Start();
		void Update();
		void Shutdown();
	}
}
