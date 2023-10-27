import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class Track extends WatchUi.Drawable {

    hidden var _toDestination as Float;
    hidden var _toNextPoint as Float;
    hidden var _distance as Float;
    hidden var _offCourse as Float;

    function initialize() {
        var dictionary = {
            :identifier => "Track"
        };

        Drawable.initialize(dictionary);

        _toDestination = 0.0f;
        _toNextPoint = 0.0f;
        _distance = 0.0f;
        _offCourse = 0.0f;
    }

    function setToDestination(tdst as Float) as Void {
        _toDestination = tdst;
    }

    function setToNextPoint(tnp as Float) as Void {
        _toNextPoint = tnp;
    }

    function setDistance(dst as Float) as Void {
        _distance = dst;
    }

    function setOffCourse(off as Float) as Void {
        _offCourse = off;
    }

    function setTrackData(tdst as Float, tnp as Float, dst as Float, off as Float) as Void {
        _toDestination = tdst;
        _toNextPoint = tnp;
        _distance = dst;
        _offCourse = off;
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
        dc.setPenWidth((dc.getWidth() * 0.01).toNumber());
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(w / 2, h / 2, w / 2 - 2, Graphics.ARC_COUNTER_CLOCKWISE, astart, aend);

        if (trackPercentage <= 0.0f) {
            return;
        }

        // color
        if (_offCourse > 50.0f) {
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
        dc.drawArc(w / 2, h / 2, w / 2 - 2, Graphics.ARC_COUNTER_CLOCKWISE, astart, acurrent);

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
            dc.setColor(0xFFFF00, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(w / 2, h / 2, w / 2 - 2, Graphics.ARC_COUNTER_CLOCKWISE, acurrent, anext);
        }
    }
}
