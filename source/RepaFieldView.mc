import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.UserProfile;
import Toybox.WatchUi;

class RepaFieldView extends WatchUi.DataField {

    hidden var hrValue as Numeric;
    hidden var ahrValue as Numeric;
    hidden var mhrValue as Numeric;
    hidden var hrZones as Array<Numeric>;

    function initialize() {
        DataField.initialize();
        hrValue = 0;
        ahrValue = 0;
        mhrValue = 0;
        hrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
    }

    function calculateHRColor(hr as Numeric) as Numeric {
        var hrColor = Graphics.COLOR_BLACK;
        if (hrZones != null) {
            if (hr < hrZones[1]) {
                hrColor = Graphics.COLOR_LT_GRAY;
            } else if (hr < hrZones[2]) {
                hrColor = Graphics.COLOR_BLUE;
            } else if (hr < hrZones[3]) {
                hrColor = Graphics.COLOR_GREEN;
            } else if (hr < hrZones[4]) {
                hrColor = Graphics.COLOR_YELLOW;
            } else if (hr < hrZones[5]) {
                hrColor = Graphics.COLOR_ORANGE;
            } else {
                hrColor = Graphics.COLOR_RED;
            }
        }
        return hrColor;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        var obscurityFlags = DataField.getObscurityFlags();

        // TODO ?
        // Top layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopLayout(dc));

        // Bottom layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
        }

        var label = View.findDrawableById("label") as Text;
        if (label != null) {
            label.setText(Rez.Strings.label);
        }
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.
        if (info has :currentHeartRate){
            if(info.currentHeartRate != null){
                hrValue = info.currentHeartRate as Number;
            } else {
                hrValue = 0;
            }
        }
        if (info has :averageHeartRate){
            if(info.averageHeartRate != null){
                ahrValue = info.averageHeartRate as Number;
            } else {
                ahrValue = 0;
            }
        }
        if (info has :maxHeartRate){
            if(info.maxHeartRate != null){
                mhrValue = info.maxHeartRate as Number;
            } else {
                mhrValue = 0;
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Background).setColor(getBackgroundColor());

        // HR value
        var hrColor = calculateHRColor(hrValue);
        var hr = View.findDrawableById("hr") as Text;
        hr.setColor(hrColor);
        hr.setText(hrValue.format("%d"));
        var ahr = View.findDrawableById("ahr") as Text;
        ahr.setText(ahrValue.format("%d"));
        var mhr = View.findDrawableById("mhr") as Text;
        mhr.setText(mhrValue.format("%d"));
        var hrGraph = View.findDrawableById("HeartRate") as HeartRate;
        hrGraph.setHRColor(hrColor);
        hrGraph.setHRZones(hrZones);
        hrGraph.setHRValue(hrValue);

        // Set the foreground color and value
        var value = View.findDrawableById("value") as Text;
        if (value != null) {
            if (getBackgroundColor() == Graphics.COLOR_BLACK) {
                value.setColor(Graphics.COLOR_WHITE);
            } else {
                value.setColor(Graphics.COLOR_BLACK);
            }
            value.setText(hrValue.format("%d"));
        }

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
