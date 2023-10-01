import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.UserProfile;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;

class RepaFieldView extends WatchUi.DataField {

    // settings
    hidden var themeColor as Numeric;
    hidden var themeColor2 as Numeric;
    hidden var themeColor3 as Numeric;
    hidden var hrZones as Array<Numeric>;
    hidden var hrHist as Array<Numeric>;
    hidden var hrZoneColors as Array<Numeric>;
    hidden var cadenceZones as Array<Numeric>;
    hidden var cadenceZoneColors as Array<Numeric>;
    hidden var isDistanceMetric as Boolean;
    hidden var isElevationMetric as Boolean;
    hidden var mileToKm as Float = 1.609344f;
    hidden var meterToFeet as Float = 3.28084f;

    // fields
    hidden var fBgOverlay;
    hidden var fTrack;
    hidden var fPace;
    hidden var fAPace;
    hidden var fElevation;
    hidden var fElevationGain;
    hidden var fElevationLoss;
    hidden var fCadence;
    hidden var fDistance;
    hidden var fTime;
    hidden var fTimer;
    hidden var fTimerSec;
    hidden var fHr;
    hidden var fAHr;
    hidden var fMHr;
    hidden var fHrGraph;

    // values
    hidden var hrTicks as Number;
    hidden var hrValue as Numeric;
    hidden var ahrValue as Numeric;
    hidden var mhrValue as Numeric;
    hidden var toDestination as Float;
    hidden var distance as Float;
    hidden var timer as Numeric;
    hidden var timerState as Number;
    hidden var offCourse as Float;
    hidden var speed as Float;
    hidden var aspeed as Float;
    hidden var pace as Float;
    hidden var apace as Float;
    hidden var altitude as Float;
    hidden var egain as Number;
    hidden var edrop as Number;
    hidden var cadence as Number;

    function initialize() {
        DataField.initialize();

        themeColor = Application.Properties.getValue("themeColor").toNumberWithBase(16);
        themeColor2 = Application.Properties.getValue("themeColor2").toNumberWithBase(16);
        themeColor3 = Application.Properties.getValue("themeColor3").toNumberWithBase(16);

        hrValue = 0;
        ahrValue = 0;
        mhrValue = 0;
        hrZones = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
        hrHist = [0, 0, 0, 0, 0, 0, 0];
        hrTicks = 0;
        hrZoneColors = [Graphics.COLOR_DK_GRAY, Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_RED, Graphics.COLOR_DK_RED];
        cadenceZones = [153, 163, 173, 183];
        cadenceZoneColors = [Graphics.COLOR_RED, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN, Graphics.COLOR_BLUE, Graphics.COLOR_PURPLE];
        toDestination = 0.0f;
        distance = 0.0f;
        timer = 0;
        timerState = Activity.TIMER_STATE_OFF;
        offCourse = 0.0f;
        speed = 0.0f;
        aspeed = 0.0f;
        pace = 0.0f;
        apace = 0.0f;
        altitude = 0.0f;
        egain = 0;
        edrop = 0;
        cadence = 0;

        var settings = System.getDeviceSettings();
        isDistanceMetric = settings.distanceUnits == System.UNIT_METRIC;
        isElevationMetric = settings.elevationUnits == System.UNIT_METRIC;
    }

    function tickHr(v as Number) {
        hrTicks++;
        var hrzsize = hrZones.size();
        for (var i = 0; i < hrzsize; i++) {
            if (v < hrZones[i]) {
                hrHist[i]++;
                return;
            }
        }
        // out of range
        hrHist[hrzsize]++;
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

        // Top layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopLayout(dc));
            return;

        // Bottom layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomLayout(dc));
            return;
        }

        // Use the generic, centered layout
        View.setLayout(Rez.Layouts.MainLayout(dc));

        // fields
        fBgOverlay = View.findDrawableById("BgOverlay") as BgOverlay;
        fTrack = View.findDrawableById("Track") as Track;
        fPace = View.findDrawableById("pace") as Text;
        fAPace = View.findDrawableById("apace") as Text;
        fElevation = View.findDrawableById("elevation") as Text;
        fElevationGain = View.findDrawableById("elevationGain") as Text;
        fElevationLoss = View.findDrawableById("elevationLoss") as Text;
        fTime = View.findDrawableById("time") as Text;
        fTimer = View.findDrawableById("timerHM") as Text;
        fTimerSec = View.findDrawableById("timerS") as Text;
        fCadence = View.findDrawableById("cadence") as Text;
        fDistance = View.findDrawableById("distance") as Text;
        fHr = View.findDrawableById("hr") as Text;
        fAHr = View.findDrawableById("ahr") as Text;
        fMHr = View.findDrawableById("mhr") as Text;
        fHrGraph = View.findDrawableById("HeartRate") as HeartRate;

        // init fields
        fHrGraph.setHRZoneColors(hrZoneColors);

        // theme setup
        fBgOverlay.setColor1(darken(themeColor, 4));
        fBgOverlay.setColor2(darken(themeColor, 2));
        fAPace.setColor(themeColor);
        fElevation.setColor(themeColor2);
        fElevationGain.setColor(themeColor2);
        fElevationLoss.setColor(themeColor2);
        fTime.setColor(themeColor3);

        // units
        if (!isDistanceMetric) {
            var fdl = View.findDrawableById("distanceLabel") as Text;
            fdl.setText("mi");
        }
    }

    function compute(info as Activity.Info) as Void {
        if(info.currentHeartRate != null) {
            hrValue = info.currentHeartRate as Number;
            tickHr(hrValue);
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
        if (info has :distanceToDestination && info.distanceToDestination != null) {
            toDestination = info.distanceToDestination as Float;
        } else {
            toDestination = 0.0f;
        }
        if (info has :offCourseDistance && info.offCourseDistance != null) {
            offCourse = info.offCourseDistance as Float;
        } else {
            offCourse = 0.0f;
        }
        if (info.currentSpeed != null) {
            speed = info.currentSpeed as Float;
            if (speed == 0) {
                pace = 0.0f;
            } else {
                pace = 1000 / 60 / speed;
            }
        } else {
            speed = 0.0f;
            pace = 0.0f;
        }
        if (info.averageSpeed != null) {
            aspeed = info.averageSpeed as Float;
            if (aspeed == 0) {
                apace = 0.0f;
            } else {
                apace = 1000 / 60 / aspeed;
            }
        } else {
            aspeed = 0.0f;
            apace = 0.0f;
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

        // convert units to imperial if needed
        if (!isDistanceMetric) {
            distance = distance / mileToKm;
            toDestination = toDestination / mileToKm;
            pace = pace * mileToKm;
            apace = apace * mileToKm;
        }
        if (!isElevationMetric) {
            altitude = altitude * meterToFeet;
            egain = (egain * meterToFeet).toNumber();
            edrop = (edrop * meterToFeet).toNumber();
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // HR value
        var hrColor = calculateZoneColor(hrValue, hrZones, hrZoneColors);
        fHr.setColor(hrColor);
        fHr.setText(hrValue.format("%d"));
        fAHr.setColor(darken(calculateZoneColor(ahrValue, hrZones, hrZoneColors), 2));
        fAHr.setText(ahrValue.format("%d"));
        fMHr.setColor(darken(calculateZoneColor(mhrValue, hrZones, hrZoneColors), 2));
        fMHr.setText(mhrValue.format("%d"));
        if (fHrGraph != null) {
            fHrGraph.setHRHist(hrHist);
            fHrGraph.setHRTicks(hrTicks);
        }

        // track
        if (fTrack != null) {
            fTrack.setToDestination(toDestination);
            fTrack.setDistance(distance);
            fTrack.setOffCourse(offCourse);
        }

        // time
        if (fTime != null) {
            var time = System.getClockTime();
            var tstr = time.hour.format("%02d") + ":" + time.min.format("%02d");
            fTime.setText(tstr);
        }

        // timer
        if (fTimer != null) {
            var trh = timer / 3600;
            var trm = (timer % 3600) / 60;
            var trs = timer % 60;
            var timerColor = Graphics.COLOR_RED;
            if (timerState == Activity.TIMER_STATE_ON) {
                timerColor = Graphics.COLOR_WHITE;
            } else if (timerState == Activity.TIMER_STATE_PAUSED) {
                timerColor = Graphics.COLOR_YELLOW;
            }
            fTimer.setColor(timerColor);
            if (trh > 0) {
                fTimer.setText(trh.format("%d") + ":" + trm.format("%02d"));
            } else {
                fTimer.setText(trm.format("%02d"));
            }
            if (fTimerSec != null) {
                fTimerSec.setColor(darken(timerColor, 1.5));
                fTimerSec.setText(":" + trs.format("%02d"));
            }
        }

        // distance
        if (fDistance != null) {
            if (distance >= 10000) {
                fDistance.setText((distance / 1000).format("%.1f"));
            } else {
                fDistance.setText((distance / 1000).format("%.2f"));
            }
        }

        // pace
        if (fPace != null) {
            if (speed != 0) {
                var pmin = pace.toNumber();
                var psec = (pace - pmin) * 60;
                fPace.setText(pmin.format("%2d") + ":" + psec.format("%02d"));
            } else {
                fPace.setText("--:--");
            }
        }
        if (fAPace != null) {
            if (aspeed != 0) {
                var apmin = apace.toNumber();
                var apsec = (apace - apmin) * 60;
                fAPace.setText(apmin.format("%2d") + ":" + apsec.format("%02d"));
            } else {
                fAPace.setText("--:--");
            }
        }

        // alt/egain/edrop
        if (fElevation != null) {
            // draw icon
            fElevation.setText(altitude.format("%.0f"));
        }
        if (fElevationGain != null) {
            fElevationGain.setText(egain.format("%d"));
        }
        if (fElevationLoss != null) {
            fElevationLoss.setText(edrop.format("%d"));
        }

        // cadence
        if (fCadence != null) {
            var cadenceColor = darken(calculateZoneColor(cadence, cadenceZones, cadenceZoneColors), 1.5);
            fCadence.setColor(cadenceColor);
            if (cadence != 0) {
                fCadence.setText(cadence.format("%d"));
            } else {
                fCadence.setText("-");
            }
        }

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
