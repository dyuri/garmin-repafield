import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;

// TODO: stamina not supported yet in the API

class Stamina extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Stamina"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {
        dc.setColor(0xFF8800, Graphics.COLOR_TRANSPARENT);
    }
}
