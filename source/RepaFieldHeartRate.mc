import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

class HeartRate extends WatchUi.Drawable {

    hidden var hrHist as Array<Numeric>;
    hidden var hrZoneColors as Array<Numeric>;
    hidden var hrTicks as Number;
    hidden var y as Number;

    function initialize(params as Dictionary) {
        Drawable.initialize(params);

        hrZoneColors = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        hrHist = [0, 0, 0, 0, 0, 0, 0];
        hrTicks = 0;

        y = 64;
        if (params.hasKey(:y)) {
            y = params.get(:y) as Number;
        }
    }

    function setHRZoneColors(zoneColors as Array<Numeric>) as Void {
        hrZoneColors = zoneColors;
    }

    function setHRHist(hist as Array<Numeric>) as Void {
        hrHist = hist;
    }

    function setHRTicks(ticks as Number) as Void {
        hrTicks = ticks;
    }

    function draw(dc as Dc) as Void {
        dc.setPenWidth(8);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        var width = dc.getWidth();
        dc.drawLine(width * .1, 64, width * .9, 64);

        if (hrTicks == 0) {
            return;
        }

        var drawFrom = 0;
        for (var i = 0; i < hrHist.size(); i++) {
            var drawTo = (drawFrom + width * hrHist[i].toFloat() / hrTicks).toNumber();
            dc.setColor(hrZoneColors[i], Graphics.COLOR_TRANSPARENT);
            dc.drawLine(drawFrom, y, drawTo, y);
            drawFrom = drawTo;
        }
    }
}
