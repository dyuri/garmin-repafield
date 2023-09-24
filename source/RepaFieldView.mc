import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.UserProfile;
import Toybox.WatchUi;
import Toybox.System;

class RepaFieldView extends WatchUi.DataField {

    hidden var hrValue as Numeric;
    hidden var ahrValue as Numeric;
    hidden var mhrValue as Numeric;
    hidden var hrZones as Array<Numeric>;
    hidden var toDestination as Float;
    hidden var distance as Float;
    hidden var timer as Numeric;
    hidden var timerState as Number;
    hidden var offCourse as Float;
    hidden var speed as Float;
    hidden var aspeed as Float;

    function initialize() {
        DataField.initialize();
        hrValue = 0;
        ahrValue = 0;
        mhrValue = 0;
        hrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        toDestination = 0.0f;
        distance = 0.0f;
        timer = 0;
        timerState = Activity.TIMER_STATE_OFF;
        offCourse = 0.0f;
        speed = 0.0f;
        aspeed = 0.0f;
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

    function darken(color as Numeric) as Numeric {
        var r = (color >> 16) & 0xFF;
        var g = (color >> 8) & 0xFF;
        var b = color & 0xFF;
        r = r * 0.5f;
        g = g * 0.5f;
        b = b * 0.5f;
        return (r.toLong() << 16) | (g.toLong() << 8) | b.toLong();
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

    function compute(info as Activity.Info) as Void {
        if(info.currentHeartRate != null) {
            hrValue = info.currentHeartRate as Number;
        } else {
            hrValue = 0;
        }
        if(info.averageHeartRate != null) {
            ahrValue = info.averageHeartRate as Number;
        } else {
            ahrValue = 0;
        }
        if(info.maxHeartRate != null) {
            mhrValue = info.maxHeartRate as Number;
        } else {
            mhrValue = 0;
        }
        if (info.elapsedDistance != null) {
            distance = info.elapsedDistance as Float;
        } else {
            distance = 0.0f;
        }
        if (info.timerTime != null) {
            timer = info.timerTime / 1000;
        } else {
            timer = 0;
        }
        if (info.timerState != null) {
            timerState = info.timerState;
        } else {
            timerState = Activity.TIMER_STATE_OFF;
        }
        if (info.distanceToDestination != null) {
            toDestination = info.distanceToDestination as Float;
        } else {
            toDestination = 0.0f;
        }
        if (info.offCourseDistance != null) {
            offCourse = info.offCourseDistance as Float;
        } else {
            offCourse = 0.0f;
        }
        if (info.currentSpeed != null) {
            speed = info.currentSpeed as Float;
        } else {
            speed = 0.0f;
        }
        if (info.averageSpeed != null) {
            aspeed = info.averageSpeed as Float;
        } else {
            aspeed = 0.0f;
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color - don't ;)
        // (View.findDrawableById("Background") as Background).setColor(getBackgroundColor());

        // HR value
        var hrColor = calculateHRColor(hrValue);
        var hr = View.findDrawableById("hr") as Text;
        hr.setColor(calculateHRColor(hrValue));
        hr.setText(hrValue.format("%d"));
        var ahr = View.findDrawableById("ahr") as Text;
        ahr.setColor(darken(calculateHRColor(ahrValue)));
        ahr.setText(ahrValue.format("%d"));
        var mhr = View.findDrawableById("mhr") as Text;
        mhr.setColor(darken(calculateHRColor(mhrValue)));
        mhr.setText(mhrValue.format("%d"));
        var hrGraph = View.findDrawableById("HeartRate") as HeartRate;
        if (hrGraph != null) {
            hrGraph.setHRColor(hrColor);
            hrGraph.setHRZones(hrZones);
            hrGraph.setHRValue(hrValue);
        }

        // track
        var track = View.findDrawableById("Track") as Track;
        if (track != null) {
            track.setToDestination(toDestination);
            track.setDistance(distance);
            track.setOffCourse(offCourse);
        }

        // time
        var timeField = View.findDrawableById("time") as Text;
        if (timeField != null) {
            var time = System.getClockTime();
            timeField.setText(time.hour.format("%02d") + ":" + time.min.format("%02d"));
        }
        var timerField = View.findDrawableById("timer") as Text;
        if (timerField != null) {
            var trh = timer / 3600;
            var trm = (timer % 3600) / 60;
            var trs = timer % 60;
            if (timerState == Activity.TIMER_STATE_ON) {
                timerField.setColor(Graphics.COLOR_WHITE);
            } else if (timerState == Activity.TIMER_STATE_PAUSED) {
                timerField.setColor(Graphics.COLOR_YELLOW);
            } else {
                timerField.setColor(Graphics.COLOR_RED);
            }
            timerField.setText(trh.format("%02d") + ":" + trm.format("%02d") + ":" + trs.format("%02d"));
        }

        // distance
        var dstField = View.findDrawableById("distance") as Text;
        if (dstField != null) {
            if (distance >= 10000) {
                dstField.setText((distance / 1000).format("%.1f"));
            } else {
                dstField.setText((distance / 1000).format("%.2f"));
            }
        }

        // pace
        var paceField = View.findDrawableById("pace") as Text;
        if (paceField != null) {
            if (speed != 0) {
                var pace = 1000 / 60 / speed; // mps -> min/km
                var pmin = pace.toNumber();
                var psec = (pace - pmin) * 60;
                paceField.setText(pmin.format("%2d") + ":" + psec.format("%02d"));
            } else {
                paceField.setText("--:--");
            }
        }
        var apaceField = View.findDrawableById("apace") as Text;
        if (apaceField != null) {
            if (aspeed != 0) {
                var apace = 1000 / 60 / aspeed; // mps -> min/km
                var apmin = apace.toNumber();
                var apsec = (apace - apmin) * 60;
                apaceField.setText(apmin.format("%2d") + ":" + apsec.format("%02d"));
            } else {
                apaceField.setText("--:--");
            }
        }


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
