import Toybox.Lang;
import Toybox.Time;
import Toybox.Math;
import Toybox.System;

class RollingAverage {
    hidden var _size as Number;
    hidden var _safeCount as Number;
    hidden var _values as Array<Float>;
    hidden var _index as Number;
    hidden var _last;
    hidden var _totalSum as Float;
    hidden var _totalCount as Number;
    hidden var _totalMin;
    hidden var _totalMax;
    hidden var _lapSum;
    hidden var _lapCount as Number;
    hidden var _lapMin;
    hidden var _lapMax;

    function initialize(size as Number) {
        _size = size;
        _safeCount = size * 2;
        _values = new[size];
        _index = 0;
        _last = null;

        _totalSum = 0.0;
        _totalCount = 0;
        _totalMin = null;
        _totalMax = null;

        _lapSum = 0.0;
        _lapCount = 0;
        _lapMin = null;
        _lapMax = null;

    }

    function setSafeCount(count as Number) {
        _safeCount = count;
    }

    function insert(value as Numeric) {
        // total
        _totalCount += 1;
        _totalSum += value;
        if (_totalMin == null || value < _totalMin) {
            _totalMin = value;
        }
        if (_totalMax == null || value > _totalMax) {
            _totalMax = value;
        }

        // lap
        _lapCount += 1;
        _lapSum += value;
        if (_lapMin == null || value < _lapMin) {
            _lapMin = value;
        }
        if (_lapMax == null || value > _lapMax) {
            _lapMax = value;
        }

        // rolling
        _values[_index] = value;
        _index = (_index + 1) % _size;
    }

    function totalAvg() { return _totalCount == 0 ? null : _totalSum / _totalCount; }
    function totalMin() { return _totalMin; }
    function totalMax() { return _totalMax; }
    function lapAvg() { return _lapCount == 0 ? null : _lapSum / _lapCount; }
    function lapMin() { return _lapMin; }
    function lapMax() { return _lapMax; }

    function reset() {
        _totalSum = 0.0;
        _totalCount = 0;
        _totalMin = null;
        _totalMax = null;
        lapReset();
    }

    function lapReset() {
        _lapSum = 0.0;
        _lapCount = 0;
        _lapMin = null;
        _lapMax = null;
    }

    function getRolling() {
        if (_totalCount < _safeCount) {
            return null;
        }
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