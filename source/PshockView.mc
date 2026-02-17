import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.ActivityMonitor;

class PshockView extends WatchUi.WatchFace {

    private var d7_16, d7_32, d7_64, d7_96, d7_100, d7_128;
    private var textColor as Number = Graphics.COLOR_WHITE;

    // Get the text color from settings
    function getTextColor() as Number {
        var colorSetting = Application.Properties.getValue("TextColor");
        if (colorSetting == null) {
            return Graphics.COLOR_WHITE;
        }
        switch (colorSetting) {
            case 0: return Graphics.COLOR_WHITE;
            case 1: return Graphics.COLOR_RED;
            case 2: return Graphics.COLOR_GREEN;
            case 3: return Graphics.COLOR_BLUE;
            case 4: return Graphics.COLOR_YELLOW;
            case 5: return Graphics.COLOR_ORANGE;
            default: return Graphics.COLOR_WHITE;
        }
    }

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

        // Get the current text color from settings
        textColor = getTextColor();

        // Get and show the current time
        var clockTime = System.getClockTime();

        // Date
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var monthString =  Lang.format("$1$", [today.month]);
        if(today.month < 10) {
            monthString = Lang.format("0$1$", [today.month]);
        }
        var dayString =  Lang.format("$1$", [today.day]);
        if(today.day < 10) {
            dayString = Lang.format("0$1$", [today.day]);
        }
        var dateString = Lang.format("$1$-$2$",[monthString, dayString]);
        var dateView = View.findDrawableById("DateLabel") as Text;
        dateView.setJustification(Graphics.TEXT_JUSTIFY_LEFT);
        dateView.setText(dateString);
        dateView.setFont(d7_64);
        dateView.setLocation(w * 0.5, h * 0.264);
        dateView.setColor(textColor);

        var todayMedium = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayStringMed = Lang.format("$1$",[todayMedium.day_of_week]);
        var dayLabel = View.findDrawableById("DayLabel") as Text;
        dayLabel.setText(dayStringMed);
        dayLabel.setFont(d7_64);
        dayLabel.setLocation(w * 0.25, h * 0.264);
        dayLabel.setColor(textColor);
        
        // Time
        var hourString = Lang.format("$1$", [clockTime.hour]);
        if(clockTime.hour < 10) {
            hourString = Lang.format("0$1$", [clockTime.hour]);
        }
        var minuteString = Lang.format("$1$", [clockTime.min]);
        if(clockTime.min < 10) {
            minuteString = Lang.format("0$1$", [clockTime.min]);
        }
        var timeString = Lang.format("$1$:$2$", [hourString, minuteString]);
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setText(timeString);
        view.setFont(d7_128);
        view.setLocation(w * 0.74, h * 0.40);
        view.setColor(textColor);

        // Seconds
        var secondString = Lang.format("$1$", [clockTime.sec]);
        if(clockTime.sec < 10) {
            secondString = Lang.format("0$1$", [clockTime.sec]);
        }
        var secondsView = View.findDrawableById("SecondLabel") as Text;
        secondsView.setText(secondString);
        secondsView.setFont(d7_64);
        secondsView.setLocation(w * 0.82, h * 0.515);
        secondsView.setColor(textColor);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Heart rate
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var hrInfo = Activity.getActivityInfo().currentHeartRate;
        if (hrInfo != null) {
            var hrString = hrInfo + " bpm";
            dc.drawText(w * 0.5, h * 0.9, d7_32, hrString, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(w * 0.5, h * 0.9, d7_32, "-- bpm", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Batterie
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var systemStats = System.getSystemStats();
        var battery = systemStats.battery;
        var batteryInDays = systemStats.batteryInDays;
        dc.drawText(w * 0.5, h * 0.07, d7_32, battery.toNumber().toString() + "%" + " (" + batteryInDays.toNumber().toString() + " days)", Graphics.TEXT_JUSTIFY_CENTER);

        // Stress
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var stress = ActivityMonitor.getInfo().stressScore;
        if(stress != null) {
            dc.drawText(w * 0.5, h * 0.16, d7_32, "Stress: " + stress + " /100", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(w * 0.5, h * 0.16, d7_32, "Stress: " + "--" + " /100", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // VO2 Max
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
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
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var deviceSettings = System.getDeviceSettings();
        var is24Hour = deviceSettings.is24Hour;
        if(!is24Hour) {
            var amOrPm = (clockTime.hour < 12) ? "AM" : "PM";
            dc.drawText(w * 0.18, h * 0.3, d7_32, amOrPm, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Border
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var borderOffset = 5;
        dc.drawRoundedRectangle(
            dateView.locX - borderOffset,  
            dateView.locY, 
            dateView.width + (2 * borderOffset),  
            dateView.height, 
            5);

        // Steps
        var info = ActivityMonitor.getInfo();  
        var stepGoal = info.stepGoal;
        var steps = info.steps;

        // Draw text
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        var stepsText = steps.toString() + " / " + stepGoal.toString() + " Steps";
        dc.drawText(w * 0.5, h * 0.66, d7_32, stepsText, Graphics.TEXT_JUSTIFY_CENTER);

        // Progress bar dimensions
        var barX = w * 0.15;
        var barY = h * 0.75;
        var barWidth = w * 0.7;
        var barHeight = h * 0.05;

        // Outline
        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(barX, barY, barWidth, barHeight, 5);

        // Fill percentage
        var percent = (stepGoal > 0) ? (steps.toFloat() / stepGoal.toFloat()) : 0.0;
        var goalReached = (percent >= 1.0);
        if (percent > 1) {
            percent = 1; // cap at 100%
        }

        // Filled bar - green when goal reached, dark gray otherwise
        var fillWidth = barWidth * percent;
        if (goalReached) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRoundedRectangle(barX + 1, barY + 1, fillWidth - 2, barHeight - 2, 5);
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
