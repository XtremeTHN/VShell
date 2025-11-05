public class CircularProgressPaintable : Object, Gdk.Paintable, Gtk.SymbolicPaintable {
    private Gtk.Widget _widget;
    public Gtk.Widget widget {
        get {
            return _widget;
        }
        set {
            _widget = value;
            value.notify["scale-factor"].connect (on_scale_change);
        }
    }

    private double _fraction;
    public double fraction {
        get {
            return _fraction;
        }
        set {
            if (value > 1)
                _fraction = 1;
            else if (value < 0)
                _fraction = 0;
            else
                _fraction = value;
            
            invalidate_contents ();
        }
    }

    public CircularProgressPaintable () {
        Object ();
    }

    private void on_scale_change () {
        invalidate_size ();
    }

    protected void snapshot (Gdk.Snapshot snapshot, double width, double height) {}

    protected void snapshot_symbolic (Gdk.Snapshot snap, double width, double height, Gdk.RGBA[] colors) {
        var snapshot = (Gtk.Snapshot) snap;

        var f_width = (float) width;
        var ctx = snapshot.append_cairo (Graphene.Rect ().init (-2, -2, f_width + 4, f_width + 4));

        double arc_end = fraction * GLib.Math.PI * 2 - GLib.Math.PI / 2;

        ctx.translate (width / 2.0, height / 2.0);
        
        // get the normal color
        var bg = colors[0];
        ctx.set_source_rgba (bg.red, bg.green, bg.blue, bg.alpha);

        ctx.arc (0, 0, width / 2.0 + 1, -GLib.Math.PI / 2.0, arc_end);
        ctx.stroke ();

        var fg = bg.copy ();
        fg.alpha *= 0.25f;

        ctx.set_source_rgba (fg.red, fg.green, fg.blue, fg.alpha);
        ctx.arc (0, 0, width / 2.0 + 1, arc_end, 3.0 * GLib.Math.PI / 2.0);
        ctx.stroke ();
    }

    protected override int get_intrinsic_height () {
        return 16 * _widget.get_scale_factor ();
    }

    protected override int get_intrinsic_width () {
        return 16 * _widget.get_scale_factor ();
    }
}
