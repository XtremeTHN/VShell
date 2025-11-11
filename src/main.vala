

namespace VShell {
    public void print_bool (bool cond) {
        message (cond ? "true" : "false");
    }

    public class App : Adw.Application {
        Gtk.CssProvider provider;
        public App () {
            Object (application_id: "com.github.XtremeTHN.VShell", flags: ApplicationFlags.HANDLES_COMMAND_LINE);
        }

        void add (Gtk.Window win, bool hidden = false) {
            add_window (win);
            if (!hidden) win.present ();
        }

        void init () {
            add (new Bar ());
            add (new AppRunner (), true);
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

        int toggle_window (string target, ApplicationCommandLine cmd) {
            Gtk.Window? win = null;
            foreach (var x in get_windows ()) {
                if (x.name != target) continue;
                win = x;
                break;
            }
            
            if (win == null) {
                cmd.printerr ("Couldn't find a window named: %s", target);
                return 1;
            }

            win.set_visible (!win.visible);
            return 0;
        }
        protected override int command_line (ApplicationCommandLine cmd) {
            if (!cmd.is_remote) {
                init ();
                return 0;
            }

            int exit_code = 0;

            bool quit = false;
            bool print_help = false;
            bool reload_colors = false;
            string? target_window = null;

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
                { "toggle", 't', OptionFlags.NONE, OptionArg.STRING, ref target_window, "Toggles the visibility of a window" },
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
            
            if (target_window != null)
                exit_code = toggle_window (target_window, cmd);
            
            if (reload_colors)
                load_colors ();

            return exit_code;
        }

        static int main (string[] args) {
            var app = new App ();
            return app.run (args);
        }
    }
    }