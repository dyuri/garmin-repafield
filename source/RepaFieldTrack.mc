import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class Track extends WatchUi.Drawable {

    hidden var _toDestination as Float;
    hidden var _toNextPoint as Float;
    hidden var _distance as Float;
    hidden var _offCourse as Float;
    hidden var _nextPointName as String;
    hidden var _showNextPoint as Boolean;
    hidden var _font;

    function initialize() {
        var dictionary = {
            :identifier => "Track"
        };

        Drawable.initialize(dictionary);

        _toDestination = 0.0f;
        _toNextPoint = 0.0f;
        _distance = 0.0f;
        _offCourse = 0.0f;
        _nextPointName = "";
        _showNextPoint = true;

        if (Graphics has :getVectorFont) {
            _font = Graphics.getVectorFont({:face => "RobotoCondensedRegular", :size => 24});
        } else {
            _font = null;
        }
    }

    function setTrackData(tdst as Float, tnp as Float, dst as Float, off as Float, nextPointName as String, showNextPoint as Boolean) as Void {
        _toDestination = tdst;
        _toNextPoint = tnp;
        _distance = dst;
        _offCourse = off;
        _nextPointName = nextPointName;
        _showNextPoint = showNextPoint;
    }

    function draw(dc as Dc) as Void {
        if (_toDestination == 0.0f) {
            return;
        }

        var trackPercentage = _distance / (_distance + _toDestination);
        if (trackPercentage > 1.0f) {
            trackPercentage = 1.0f;
        }

        // draw
        var w = dc.getWidth();
        var h = dc.getHeight();
        var astart = 150;
        var aend = 390;
        var offtrack = _offCourse > 50.0f;
        dc.setPenWidth((dc.getWidth() * 0.01).toNumber() + 1);
        dc.setColor(offtrack ? 0x880000 : 0x555555, Graphics.COLOR_TRANSPARENT);
        // the center is between two points, so draw twice
        dc.drawArc(w / 2 - 1, h / 2, w / 2 - 1, Graphics.ARC_COUNTER_CLOCKWISE, astart, aend);
        dc.drawArc(w / 2, h / 2, w / 2 - 1, Graphics.ARC_COUNTER_CLOCKWISE, astart, aend);

        if (trackPercentage <= 0.0f) {
            return;
        }

        // color
        if (offtrack) {
            dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT);
        } else if (trackPercentage < 0.2) {
            dc.setColor(0x8800FF, Graphics.COLOR_TRANSPARENT);
        } else if (trackPercentage < 0.4) {
            dc.setColor(0x0000FF, Graphics.COLOR_TRANSPARENT);
        } else if (trackPercentage < 0.6) {
            dc.setColor(0x0055FF, Graphics.COLOR_TRANSPARENT);
        } else if (trackPercentage < 0.8) {
            dc.setColor(0x00AAFF, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(0x00FFFF, Graphics.COLOR_TRANSPARENT);
        }

        var acurrent = astart + (aend - astart) * trackPercentage;
        if (acurrent < astart + 1) {
            acurrent = astart + 1;
        } else if (acurrent > aend) {
            acurrent = aend;
        }
        dc.drawArc(w / 2 - 1, h / 2, w / 2 - 1, Graphics.ARC_COUNTER_CLOCKWISE, astart, acurrent);
        dc.drawArc(w / 2, h / 2, w / 2 - 1, Graphics.ARC_COUNTER_CLOCKWISE, astart, acurrent);

        // next point
        if (_toNextPoint > 0.0f) {
            var nextPercentage = _toNextPoint / _toDestination;

            var anext = acurrent + (aend - acurrent) * nextPercentage;
            if (anext < astart + 1) {
                anext = astart + 1;
            } else if (anext > aend) {
                anext = aend;
            }
            dc.setPenWidth((dc.getWidth() * 0.01).toNumber());
            if (offtrack) {
                dc.setColor(0xAA0000, Graphics.COLOR_TRANSPARENT);
            } else if (_toNextPoint > 500) {
                dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(0xAAFF44, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawArc(w / 2, h / 2, w / 2 - 1, Graphics.ARC_COUNTER_CLOCKWISE, acurrent, anext);
            dc.drawArc(w / 2 - 1, h / 2, w / 2 - 1, Graphics.ARC_COUNTER_CLOCKWISE, acurrent, anext);

            // next point name
            if (_showNextPoint && _font != null && h > 350) {
                var pointText = (_toNextPoint / 1000.0).format("%.1f");
                if (_nextPointName.length() > 0 && _nextPointName.length() <= 20) {
                    pointText += " | " + _nextPointName;
                } else if (_nextPointName.length() > 20) {
                    pointText += " | " + _nextPointName.substring(0, 17) + "...";
                }
                if (_toNextPoint > 500) {
                    dc.setColor(0x88FFFF, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(0xAAFF44, Graphics.COLOR_TRANSPARENT);
                }
                dc.drawRadialText(w / 2, h / 2, _font, pointText, Graphics.TEXT_JUSTIFY_CENTER, 270, h / 2 - 12, Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE);
            }
        }
    }
}
