public class Quick.BacklightSlider: Slider {
    Backlight light;

    construct {
        light = new Backlight ();

        if (light.has_backlight_support () == false) {
            set_visible (false);
        }
    }
}