using System;
using System.Collections;

namespace SteelEngine.Input
{
	public enum KeyEvent : uint8
	{
		Down = 0x01,
		Up = 0x02,
	}

	public class Input
	{
		public struct GamepadId : int32 { }

		const let KEY_COUNT = typeof(KeyCode).MaxValue+1;
		const let AXES_COUNT = typeof(AxisCode).MaxValue+1;

		static var _accumulatedEvents = KeyEvent[KEY_COUNT]();
		static var _lastUpdateState = KeyState[KEY_COUNT]();
		static var _accumulatedAxisValues = float[AXES_COUNT]();
		static var _axisValues = float[AXES_COUNT]();

		static Vector2 _mousePos;
		static Vector2 _lastMousePos;
		static Vector2 _mouseDelta;
		static bool _ignoreLastMouseMove;

		static Dictionary<GamepadId, GamepadInfo> _gamepads = new Dictionary<GamepadId, GamepadInfo>() ~ delete _;
		static Dictionary<String, KeyCode> _keycodeActionMap = new Dictionary<String, KeyCode>() ~  DeleteDictionaryAndKeys!(_);

		static ~this()
		{
			for (var pad in _gamepads.Values)
				delete pad;
		}

		static void KeyEvent(KeyCode kc, KeyEvent ke)
		{
			_accumulatedEvents[kc.Underlying] |= ke;
		}

		static void AxisEvent(AxisCode ac, float value)
		{
			_accumulatedAxisValues[ac.Underlying] += value;
		}

		static void GamepadKeyEvent(GamepadId id, KeyCode kc, KeyEvent ke)
		{
			GamepadInfo gamepad;
			if (_gamepads.TryGetValue(id, out gamepad))
			{
				gamepad.[Friend]SetKey(kc, ke);
			}
			KeyEvent(kc, ke);
		}

		static void GamepadAxisEvent(GamepadId id, AxisCode ac, float value)
		{
			GamepadInfo gamepad;
			if (_gamepads.TryGetValue(id, out gamepad))
			{
				gamepad.[Friend]SetAxis(ac, value);
			}
			AxisEvent((.)ac, value);
		}

		static void UpdateMousePosition(float x, float y)
		{
			_mousePos = .(x,y);
			// Hack to prevent weird behavior on sudden cursor position changes (eg. changing CursorState)
			if(_ignoreLastMouseMove)
			{
				_ignoreLastMouseMove = false;
				_lastMousePos = _mousePos;
			}
		}

		static void GamepadConnected(GamepadId gamepadId, StringView deviceName)
		{
			_gamepads.Add(gamepadId, new GamepadInfo(deviceName));
		}

		static void GamepadDisconnected(GamepadId gamepadId)
		{
			if (_gamepads.GetAndRemove(gamepadId) case .Ok(let val))
			{
				delete val.value;
			}
		}

		static void Update()
		{
			// Update keys
			for (int i = 0, let count = _accumulatedEvents.Count; i < count; i++)
			{
				let event = _accumulatedEvents[i];
				var newValue = _lastUpdateState[i] & ~(.Down | .Up);	// Clear up / down flags

				// If we already have key state Hold we don't want to set Down again
				if (event.HasFlag(.Down) && !_lastUpdateState[i].HasFlag(.Hold))
				{
					newValue = .Down | .Hold;								
				}

				// Up key flag can only be set when if the key was down previous update
				if (event.HasFlag(.Up) && _lastUpdateState[i].HasFlag(.Hold))
				{
					// If key was pressed and released we probably want to unset the Hold flag but keep down flag.
					newValue = ( _lastUpdateState[i] & ~.Hold) | .Up;
				}

				_lastUpdateState[i] = newValue;
			}

			// Update gamepads
			for (let pad in _gamepads.Values)
				pad.Update();

			// Update axis
			_axisValues = _accumulatedAxisValues;

			// Update mouse
			_mouseDelta = .(_mousePos.x - _lastMousePos.x, _mousePos.y - _lastMousePos.y);
			_axisValues[(int)AxisCode.MouseX] = _mouseDelta.x;
			_axisValues[(int)AxisCode.MouseY] = _mouseDelta.y;
			_lastMousePos = _mousePos;

			// Clear accumulators
			_accumulatedEvents = default;
			_accumulatedAxisValues = default;
		}

		public static void ResetInput()
		{
			_accumulatedEvents = default;
			_lastUpdateState = default;
			_axisValues = default;
			for (let pad in _gamepads.Values)
				pad.ResetInput();
		}

		public static bool GetKeyDown(KeyCode kc)
		{
			return _lastUpdateState[kc.Underlying].HasFlag(.Down);
		}

		public static bool GetKeyUp(KeyCode kc)
		{
			return _lastUpdateState[kc.Underlying].HasFlag(.Up);
		}

		public static bool GetKey(KeyCode kc)
		{
			return _lastUpdateState[kc.Underlying].HasFlag(.Hold);
		}

		public static float GetAxis(AxisCode ac)
		{
			return _axisValues[ac.Underlying];
		}

		public static bool GetGamepadKeyDown(GamepadId gamepadId,KeyCode kc)
		{
			GamepadInfo gamepad;
			if (_gamepads.TryGetValue(gamepadId, out gamepad))
			{
				return gamepad.GetKeyDown(kc);
			}
			return false;
		}

		public static bool GetGamepadKeyUp(GamepadId gamepadId,KeyCode kc)
		{
			GamepadInfo gamepad;
			if (_gamepads.TryGetValue(gamepadId, out gamepad))
			{
				return gamepad.GetKeyUp(kc);
			}
			return false;
		}

		public static bool GetGamepadKey(GamepadId gamepadId, KeyCode kc)
		{
			GamepadInfo gamepad;
			if (_gamepads.TryGetValue(gamepadId, out gamepad))
			{
				return gamepad.GetKey(kc);
			}
			return false;
		}

		public static float GetGamepadAxis(GamepadId gamepadId, AxisCode ac)
		{
			GamepadInfo gamepad;
			if (_gamepads.TryGetValue(gamepadId, out gamepad))
			{
				return gamepad.GetAxis(ac);
			}
			return default;
		}

		public static StringView GetGamepadName(GamepadId gamepadId)
		{
			GamepadInfo gamepad;
			if (_gamepads.TryGetValue(gamepadId, out gamepad))
			{
				return gamepad.Name;
			}
			return .();
		}

		public static Vector2 MousePosition => _mousePos;
		public static Dictionary<GamepadId, GamepadInfo>.KeyEnumerator ConnectedGamepads => _gamepads.Keys;
		public static int ConnectedGamepadsCount => _gamepads.Count;

		public static void SetInputMapping(StringView action, KeyCode kc)
		{
			String key;
			KeyCode boundKeyCode;
			if (_keycodeActionMap.TryGetAlt(action, out key, out boundKeyCode))
			{
				_keycodeActionMap[key] = kc;
			}
			else
			{
				key = new String(action);
				_keycodeActionMap[key] = kc;
			}
		}

		public static void RemoveInputMapping(StringView action)
		{
			String key;
			KeyCode boundKeyCode;
			if (_keycodeActionMap.TryGetAlt(action, out key, out boundKeyCode))
			{
				_keycodeActionMap.RemoveAlt(action);
				delete key;
			}
		}

		public static bool IsJustPressed(StringView action)
		{
			String key;
			KeyCode boundKeyCode;
			if (_keycodeActionMap.TryGetAlt(action, out key, out boundKeyCode))
			{
				return GetKeyDown(boundKeyCode);	
			}
			return false;
		}

		public static bool IsJustReleased(StringView action)
		{
			String key;
			KeyCode boundKeyCode;
			if (_keycodeActionMap.TryGetAlt(action, out key, out boundKeyCode))
			{
				return GetKeyUp(boundKeyCode);	
			}
			return false;
		}

		public static bool IsHeld(StringView action)
		{
			String key;
			KeyCode boundKeyCode;
			if (_keycodeActionMap.TryGetAlt(action, out key, out boundKeyCode))
			{
				return GetKey(boundKeyCode);	
			}
			return false;
		}

		public static void SetCursorState(CursorState state)
		{
			glfw_beef.GlfwInput.CursorInputMode mode = .Normal;
			bool rawInput = false;
			switch (state)
			{
				case .Visible:
					mode = .Normal;
				case .Hidden:
					mode = .Hidded;
				case .Confined:
					mode = .Disabled;
					rawInput = true;
					_ignoreLastMouseMove = true;
				case .Captured:
					mode = .Disabled;
			}

			if (glfw_beef.Glfw.RawMouseMotionSupported())
			{
				if (rawInput)
				{
					glfw_beef.Glfw.SetInputMode(Application.Instance.MainWindow.Handle, .RawMouseMotion, glfw_beef.Glfw.TRUE);
				}
				else
				{
					glfw_beef.Glfw.SetInputMode(Application.Instance.MainWindow.Handle, .RawMouseMotion, glfw_beef.Glfw.FALSE);
				}	
			}
			
			

			glfw_beef.Glfw.SetInputMode(Application.Instance.MainWindow.Handle, .Cursor, mode);
			
		}

	}
}
