import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class HeartRate extends WatchUi.Drawable {

    hidden var hrZones as Array<Numeric>;
    hidden var hrValue as Numeric;
    hidden var aColor as Graphics.ColorValue | Number;
    hidden var y as Numeric;

    function initialize(params as Dictionary) {
        Drawable.initialize(params);

        hrZones = [100, 120, 140, 160, 180, 200];
        hrValue = 0.0f;
        aColor = 0xFF8800;
        y = 64;
        if (params.hasKey(:y)) {
            y = params.get(:y) as Number;
        }
    }

    function setHRZones(zones as Array<Numeric>) as Void {
        hrZones = zones;
    }

    function setHRValue(value as Numeric) as Void {
        hrValue = value;
    }

    function setHRColor(color) as Void {
        aColor = color;
    }

    function draw(dc as Dc) as Void {
        dc.setPenWidth(8);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        var width = dc.getWidth();
        dc.drawLine(width * .1, 64, width * .9, 64);

        var percentage = 0.0f;
        var zoneNr = hrZones.size();
        if (hrValue > hrZones[zoneNr - 1]) {
            percentage = 1.0f;
        } else if (hrValue < hrZones[0]) {
            percentage = .0f;
        } else {
            percentage = (hrValue - hrZones[0]).toFloat() / (hrZones[zoneNr - 1] - hrZones[0]);
        }
        dc.setColor(aColor, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(width * .1, 64, width * (.1 + .8 * percentage), 64);
    }
}
