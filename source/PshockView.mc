import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;

class PshockView extends WatchUi.WatchFace {

    private var d7_16, d7_32, d7_64, d7_96, d7_100, d7_128;

    function initialize() {
        WatchFace.initialize();
        d7_16 = Application.loadResource(Rez.Fonts.d7_16);
        d7_32 = Application.loadResource(Rez.Fonts.d7_32);
        d7_64 = Application.loadResource(Rez.Fonts.d7_64);
        d7_96 = Application.loadResource(Rez.Fonts.d7_96);
        d7_100 = Application.loadResource(Rez.Fonts.d7_100);
        d7_128 = Application.loadResource(Rez.Fonts.d7_128);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Get and show the current time
        var clockTime = System.getClockTime();

        // Date
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$-$2$",[today.month,today.day]);
        var dateView = View.findDrawableById("DateLabel") as Text;
        dateView.setText(dateString);
        dateView.setFont(d7_64);
        dateView.setLocation(w * 0.57, h * 0.264);

        var todayMedium = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayString = Lang.format("$1$",[todayMedium.day_of_week]);
        var dayLabel = View.findDrawableById("DayLabel") as Text;
        dayLabel.setText(dayString);
        dayLabel.setFont(d7_64);
        dayLabel.setLocation(w * 0.25, h * 0.264);
        
        // Time
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setText(timeString);
        view.setFont(d7_128);
        view.setLocation(w * 0.40, h * 0.40);

        // Seconds
        var secondString = Lang.format("$1$", [clockTime.sec]);
        var secondsView = View.findDrawableById("SecondLabel") as Text;
        secondsView.setText(secondString);
        secondsView.setFont(d7_64);
        secondsView.setLocation(w * 0.82, h * 0.515);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Heart rate
        var hrInfo = Activity.getActivityInfo().currentHeartRate;
        if (hrInfo != null) {
            var hrString = hrInfo + " bpm";
            dc.drawText(w * 0.5, h * 0.9, d7_32, hrString, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(w * 0.5, h * 0.9, d7_32, "-- bpm", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Batterie
        var systemStats = System.getSystemStats();
        var battery = systemStats.battery;
        var batteryInDays = systemStats.batteryInDays;
        dc.drawText(w * 0.5, h * 0.1, d7_32, battery.toNumber().toString() + "%" + " (" + batteryInDays.toNumber().toString() + " days)", Graphics.TEXT_JUSTIFY_CENTER);

        // VO2 Max
        var profile = UserProfile.getProfile();
        if (profile != null) {
            var vo2run = profile.vo2maxRunning;
            if (vo2run != null) {
                dc.drawText(w * 0.5, h * 0.83, d7_32, vo2run.toString() + " VO2 max", Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText(w * 0.5, h * 0.83, d7_32, "-- VO2 max", Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        // AM / PM
        var deviceSettings = System.getDeviceSettings();
        var is24Hour = deviceSettings.is24Hour;
        if(!is24Hour) {
            var amOrPm = (clockTime.hour < 12) ? "AM" : "PM";
            dc.drawText(w * 0.18, h * 0.3, d7_32, amOrPm, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Border
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // dc.drawRoundedRectangle(w * 0.15, h * 0.25, w * 0.7,  h * 0.5, 5);

        // Date Border
        dc.drawRoundedRectangle(w * 0.48,  h * 0.26, w * 0.36,  h * 0.15, 5);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
