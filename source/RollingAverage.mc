import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;
import Toybox.System;

class RollingAverage {
    hidden var _size as Number;
    hidden var _values as Array<Numeric>;
    hidden var _index as Number;

    function initialize(size as Number) {
        _size = size;
        _values = new[size];
        _index = 0;
    }

    function insert(value as Numeric) {
        _values[_index] = value;
        _index = (_index + 1) % _size;
    }

    function get() as Numeric {
        var sum = 0.0;
        var count = 0;
        for (var i = 0; i < _size; i++) {
            var value = _values[i];
            if (value != null) {
                sum += value;
                count++;
            }
        }
        return count == 0 ? 0.0 : sum / count;
    }
}