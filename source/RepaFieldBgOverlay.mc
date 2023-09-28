import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class BgOverlay extends WatchUi.Drawable {

    hidden var x as Number;
    hidden var y as Number;
    hidden var w as Number;
    hidden var h as Number;
    hidden var d as Number;

    hidden var c1 as Number;
    hidden var c2 as Number;

    function initialize(params as Dictionary) {
        Drawable.initialize(params);
        x = 132;
        if (params.hasKey(:x)) {
            x = params.get(:x) as Number;
        }
        y = 62;
        if (params.hasKey(:y)) {
            y = params.get(:y) as Number;
        }
        w = 300;
        if (params.hasKey(:w)) {
            w = params.get(:w) as Number;
        }
        h = 260;
        if (params.hasKey(:h)) {
            h = params.get(:h) as Number;
        }
        d = -20;
        if (params.hasKey(:d)) {
            d = params.get(:d) as Number;
        }

        c1 = 0x002244;
        c2 = 0x003366;
    }

    function setColor1(c as Number) as Void {
        c1 = c;
    }

    function setColor2(c as Number) as Void {
        c2 = c;
    }

    function draw(dc as Dc) as Void {
        dc.setColor(c1, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[x+w, y], [x, y], [x-d, y+h], [x+w, y+h]]);
        dc.setColor(c2, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(x+w, y, x, y);
        dc.drawLine(x, y, x-d, y+h);
        dc.drawLine(x-d, y+h, x+w, y+h);
    }

}
