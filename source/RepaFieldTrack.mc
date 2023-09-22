import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;

class Track extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Track"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {
        dc.setColor(0xFF8800, Graphics.COLOR_TRANSPARENT);
    }
}
