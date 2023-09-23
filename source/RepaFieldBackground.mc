import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;

class Background extends WatchUi.Drawable {

    hidden var mColor as ColorValue;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);

        mColor = Graphics.COLOR_BLACK;
    }

    function setColor(color as ColorValue) as Void {
        mColor = color;
    }

    function draw(dc as Dc) as Void {
        var x = 132;
        var y = 62;
        var width = 300;
        var height = 260;
        var diff = -20;
        dc.setColor(0x002244, mColor);
        dc.clear();
        dc.fillPolygon([[x+width, y], [x, y], [x-diff, y+height], [x+width, y+height]]);
        dc.setColor(0x003366, mColor);
        dc.setPenWidth(1);
        dc.drawLine(x+width, y, x, y);
        dc.drawLine(x, y, x-diff, y+height);
        dc.drawLine(x-diff, y+height, x+width, y+height);
    }

}
