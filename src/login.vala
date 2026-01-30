public errordomain LogindErrors {
    PROXY_NULL
}

[SingleInstance]
public class Logind: Object {
    DBusProxy proxy;
    DBusProxy session_proxy;
    
    construct {
        try {
            proxy = new DBusProxy.for_bus_sync (
                BusType.SYSTEM,
                DBusProxyFlags.NONE,
                null,
                "org.freedesktop.login1",
                "/org/freedesktop/login1",
                "org.freedesktop.login1.Manager",
                null
            );
        } catch (Error e) {
            critical ("Couldn't get login manager dbus proxy: %s", e.message);
            return;
        }

        try {
            session_proxy = new DBusProxy.for_bus_sync (
                BusType.SYSTEM,
                DBusProxyFlags.NONE,
                null,
                "org.freedesktop.login1",
                "/org/freedesktop/login1/session/auto",
                "org.freedesktop.login1.Session",
                null
            );
        } catch (Error e) {
            critical ("Couldn't get login session dbus proxy: %s", e.message);
            return;
        }
    }

    // FIXME: if this blocks too much, use async methods
    Variant call (DBusProxy? proxy, string method, Variant? args) throws Error {
        if (proxy == null) {
            critical ("proxy is null");
            throw new LogindErrors.PROXY_NULL ("proxy is null");
        }
        
        try {
            return proxy.call_sync (
                method,
                args,
                DBusCallFlags.NONE,
                -1
            );
        } catch (Error e) {
            critical ("Error while calling %s in %s: %s", method, proxy.get_interface_name (), e.message);
            throw e;
        }
    }

    Variant get_boolean_variant (bool value) {
        bool[] args = {value};
        return new Variant ("(b)", args);
    }
    
    public bool can_suspend () {
        try {
            var res = call (proxy, "CanSuspend", null);
            return res.get_boolean ();
        } catch (Error e) {
            return false;
        }
    }

    public void suspend () throws Error {
        if (!can_suspend ())
            return;

        call (proxy, "Suspend", get_boolean_variant (false));
    }

    public void power_off () throws Error {
        call (proxy, "PowerOff", get_boolean_variant (false));
    }

    public void log_out () throws Error {
        call (proxy, "Terminate", null);
    }
}