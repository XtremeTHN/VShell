


public class VShell.App : Adw.Application {
    Gtk.CssProvider provider;
    public App () {
        Object (application_id: "com.github.XtremeTHN.VShell", flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    }

    void add (Gtk.Window win) {
        add_window (win);
        win.present ();
    }

    void init () {
        add (new Bar ());
    }

    void remove_css () {
        Gtk.StyleContext.remove_provider_for_display (Gdk.Display.get_default (), provider);
    }
    
    void load_colors () {
        if (provider != null)
            remove_css ();
        
        provider = new Gtk.CssProvider ();
        var file = File.new_build_filename (GLib.Environment.get_user_config_dir (), "gtk-4.0", "colors.css");
        
        if (file.query_exists (null) == false) {
            warning ("colors.css not found");
            return;
        }

        provider.load_from_file (file);
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

    }

    protected override int command_line (ApplicationCommandLine cmd) {
        if (!cmd.is_remote) {
            init ();
            return 0;
        }

        bool quit = false;
        bool print_help = false;
        bool reload_colors = false;

        var args = cmd.get_arguments ();

        if (args.length == 0) {
            cmd.print_literal ("Already running");
            return 1;
        }

        var ctx = new OptionContext ();
        ctx.set_help_enabled (false);

        OptionEntry[] entries = {
            { "quit", 'q', OptionFlags.NONE, OptionArg.NONE, ref quit, "Quits the shell" },
            { "help", 'h', OptionFlags.NONE, OptionArg.NONE, ref print_help, "Prints this help message" },
            { "reload-colors", 'r', OptionFlags.NONE, OptionArg.NONE, ref reload_colors, "Reload colors" },
        };

        ctx.add_main_entries (entries, null);

        try {
            ctx.parse_strv (ref args);
        } catch (Error e) {
            cmd.printerr ("Couldn't parse arguments: %s\n", e.message);
            return 2;
        }

        if (quit)
            this.quit();
        
        if (print_help)
            cmd.print_literal(ctx.get_help (true, null));
        
        if (reload_colors)
            load_colors ();

        return 0;
    }

    static int main (string[] args) {
        var app = new App ();
        return app.run (args);
    }
}
