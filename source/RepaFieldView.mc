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
    hidden var hrZoneColors as Array<Numeric>;
    hidden var cadenceZones as Array<Numeric>;
    hidden var cadenceZoneColors as Array<Numeric>;
    hidden var toDestination as Float;
    hidden var distance as Float;
    hidden var timer as Numeric;
    hidden var timerState as Number;
    hidden var offCourse as Float;
    hidden var speed as Float;
    hidden var aspeed as Float;
    hidden var altitude as Float;
    hidden var egain as Number;
    hidden var edrop as Number;
    hidden var cadence as Number;

    function initialize() {
        DataField.initialize();
        hrValue = 0;
        ahrValue = 0;
        mhrValue = 0;
        hrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        hrZoneColors = [Graphics.COLOR_BLACK, Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_RED, Graphics.COLOR_DK_RED];
        cadenceZones = [153, 163, 173, 183];
        cadenceZoneColors = [Graphics.COLOR_RED, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN, Graphics.COLOR_BLUE, Graphics.COLOR_PURPLE];
        toDestination = 0.0f;
        distance = 0.0f;
        timer = 0;
        timerState = Activity.TIMER_STATE_OFF;
        offCourse = 0.0f;
        speed = 0.0f;
        aspeed = 0.0f;
        altitude = 0.0f;
        egain = 0;
        edrop = 0;
        cadence = 0;
    }

    function calculateZoneColor(v as Numeric, zones as Array<Numeric>, zoneColors as Array<Numeric>) as Numeric {
        for (var i = 0; i < zones.size(); i++) {
            if (v < zones[i]) {
                return zoneColors[i];
            }
        }
        return zoneColors[zoneColors.size() - 1];
    }

    function darken(color as Numeric, factor as Numeric) as Numeric {
        var r = (color >> 16) & 0xFF;
        var g = (color >> 8) & 0xFF;
        var b = color & 0xFF;
        r = r / factor.toFloat();
        g = g / factor.toFloat();
        b = b / factor.toFloat();
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
        if (info.altitude != null) {
            altitude = info.altitude as Float;
        } else {
            altitude = 0.0f;
        }
        if (info.totalAscent != null) {
            egain = info.totalAscent as Number;
        } else {
            egain = 0;
        }
        if (info.totalDescent != null) {
            edrop = info.totalDescent as Number;
        } else {
            edrop = 0;
        }
        if (info.currentCadence != null) {
            cadence = info.currentCadence as Number;
        } else {
            cadence = 0;
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color - don't ;)
        // (View.findDrawableById("Background") as Background).setColor(getBackgroundColor());

        // HR value
        var hrColor = calculateZoneColor(hrValue, hrZones, hrZoneColors);
        var hr = View.findDrawableById("hr") as Text;
        hr.setColor(hrColor);
        hr.setText(hrValue.format("%d"));
        var ahr = View.findDrawableById("ahr") as Text;
        ahr.setColor(darken(calculateZoneColor(ahrValue, hrZones, hrZoneColors), 2));
        ahr.setText(ahrValue.format("%d"));
        var mhr = View.findDrawableById("mhr") as Text;
        mhr.setColor(darken(calculateZoneColor(mhrValue, hrZones, hrZoneColors), 2));
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
        var timerField = View.findDrawableById("timerHM") as Text;
        var timerSecField = View.findDrawableById("timerS") as Text;
        if (timerField != null) {
            var trh = timer / 3600;
            var trm = (timer % 3600) / 60;
            var trs = timer % 60;
            var timerColor = Graphics.COLOR_RED;
            if (timerState == Activity.TIMER_STATE_ON) {
                timerColor = Graphics.COLOR_WHITE;
            } else if (timerState == Activity.TIMER_STATE_PAUSED) {
                timerColor = Graphics.COLOR_YELLOW;
            }
            timerField.setColor(timerColor);
            if (trh > 0) {
                timerField.setText(trh.format("%d") + ":" + trm.format("%02d"));
            } else {
                timerField.setText(trm.format("%02d"));
            }
            if (timerSecField != null) {
                timerSecField.setColor(darken(timerColor, 1.5));
                timerSecField.setText(trs.format("%02d"));
            }
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

        // alt/egain/edrop
        var altField = View.findDrawableById("elevation") as Text;
        if (altField != null) {
            // draw icon
            altField.setText(altitude.format("%.0f"));
        }
        var eGainField = View.findDrawableById("elevationGain") as Text;
        if (eGainField != null) {
            eGainField.setText(egain.format("%d"));
        }
        var eDropField = View.findDrawableById("elevationLoss") as Text;
        if (eDropField != null) {
            eDropField.setText(edrop.format("%d"));
        }

        // cadence
        var cadenceColor = darken(calculateZoneColor(cadence, cadenceZones, cadenceZoneColors), 1.5);
        var cadenceField = View.findDrawableById("cadence") as Text;
        cadenceField.setColor(cadenceColor);
        if (cadenceField != null) {
            if (cadence != 0) {
                cadenceField.setText(cadence.format("%d"));
            } else {
                cadenceField.setText("-");
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
        // var bitmap = WatchUi.loadResource(Rez.Drawables.iconHills);
        // dc.drawBitmap(132, 132, bitmap);
        // TODO
        /*
        var bm = new WatchUi.Bitmap({
            :rezId => Rez.Drawables.iconHills,
            :locX => 132,
            :locY => 132
        });
        bm.draw(dc);
        */
    }

}
