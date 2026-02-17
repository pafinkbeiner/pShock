import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

class PshockSettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Settings"});
        
        // Add color selection menu item
        var currentColor = Application.Properties.getValue("TextColor");
        if (currentColor == null) {
            currentColor = 0;
        }
        
        var colorNames = ["White", "Red", "Green", "Blue", "Yellow", "Orange"];
        var subLabel = colorNames[currentColor];
        
        addItem(new WatchUi.MenuItem("Text Color", subLabel, :textColor, null));
    }
}

class PshockSettingsDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :textColor) {
            // Show color picker submenu
            WatchUi.pushView(new ColorPickerMenu(), new ColorPickerDelegate(), WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class ColorPickerMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title => "Text Color"});
        
        var currentColor = Application.Properties.getValue("TextColor");
        if (currentColor == null) {
            currentColor = 0;
        }
        
        addItem(new WatchUi.ToggleMenuItem("White", null, 0, currentColor == 0, null));
        addItem(new WatchUi.ToggleMenuItem("Red", null, 1, currentColor == 1, null));
        addItem(new WatchUi.ToggleMenuItem("Green", null, 2, currentColor == 2, null));
        addItem(new WatchUi.ToggleMenuItem("Blue", null, 3, currentColor == 3, null));
        addItem(new WatchUi.ToggleMenuItem("Yellow", null, 4, currentColor == 4, null));
        addItem(new WatchUi.ToggleMenuItem("Orange", null, 5, currentColor == 5, null));
    }
}

class ColorPickerDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var colorValue = item.getId() as Number;
        
        // Save the selected color
        Application.Properties.setValue("TextColor", colorValue);
        
        // Go back to watchface
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
