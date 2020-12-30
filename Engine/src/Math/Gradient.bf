using System;
using System.Collections;

namespace SteelEngine
{
	public class Gradient
	{
		public enum GradientMode
		{
			Blend,
			Fixed
		} 

		public GradientMode mode;

		public typealias ValueType = (float time, Color4f value);
		List<ValueType> _values = new .() ~ delete _;

		public void AddColorPoint(float time, Color4f color)
		{
			for (int i = 0; i < _values.Count; i++)
			{
				Assert!(time != _values[i].time);
				if (time < _values[i].time)
				{
					_values.Insert(i, (time, color));
					return;
				}
			}

			_values.Add((time, color));
		}

		public void Clear()
		{
			if(_values.Count <= 2)
				return;

			_values.RemoveRange(1, _values.Count - 2);
		}

		static void Lerp(float d, Color4f a, Color4f b)
		{

		}

		public Color4f GetValue(float time)
		{
			Assert!(!_values.IsEmpty);

			int i = 0;
			for(;i < _values.Count; i++)
			{
				if(_values[i].time < time)
				{
					break;
				}
			}

			if(i >= _values.Count - 1)
			{
				return _values.Back.value;
			}

			let begin =_values[i];
			let end = _values[i+1];

			switch(mode)
			{
			case .Fixed:
				return (time - begin.time) < (end.time - time) ? begin.value : end.value;
			case .Blend:
				return .Lerp(begin.value, end.value, (time - begin.time) / (end.time - begin.time));
			}
		}


		public this() : this(.(1,1,1), .(1,1,1))
		{ }

		public this(Color4f begin, Color4f end)
		{
			ValueType[2] tmp = .((0, begin), (1, end));
			_values.AddRange(.(&tmp, tmp.Count));
		}

		public this(Span<ValueType> values)
		{
			Assert!(values.Length >= 2);
			_values.AddRange(values);
		}

		public this(params ValueType[] values)
		{
			Assert!(values.Count >= 2);
			_values.AddRange(values);
		}
	}
}
