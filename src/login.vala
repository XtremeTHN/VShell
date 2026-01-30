interface IManager: DBusProxy {
    public signal void PrepareForSleep (bool start);

    public abstract string[] CanSuspend ();
    public abstract void PowerOff (bool interactive);
    public abstract void Reboot (bool interactive);
    public abstract void Suspend (bool interactive);
}

interface ISession: DBusProxy {
    public abstract string Id { get; set; }

    public abstract void Terminate ();
}

public errordomain LogindErrors {
    PROXY_NULL
}

[SingleInstance]
public class Logind: Object {
    IManager proxy;
    ISession session_proxy;

    public signal void sleep ();
    public signal void wake ();
    
    construct {
        try {
            proxy = Bus.get_proxy_sync (
                BusType.SYSTEM,
                "org.freedesktop.login1",
                "/org/freedesktop/login1",
                DBusProxyFlags.NONE
            );
        } catch (Error e) {
            critical ("Couldn't get login manager dbus proxy: %s", e.message);
            return;
        }

        try {
            session_proxy = Bus.get_proxy_sync (
                BusType.SYSTEM,
                "org.freedesktop.login1",
                "/org/freedesktop/login1/session/auto",
                DBusProxyFlags.NONE
            );
        } catch (Error e) {
            critical ("Couldn't get login session dbus proxy: %s", e.message);
            return;
        }
    }

    public bool can_suspend () {
        if (proxy.CanSuspend ()[0] != "yes")
            return false;
        
        return true;
    }

    public void suspend () throws Error {
        if (!can_suspend ())
            return;

        proxy.Suspend (false);
    }

    public void power_off () throws Error {
        proxy.PowerOff (false);
    }

    public void reboot () {
        proxy.Reboot (false);
    }

    public void log_out () throws Error {
        session_proxy.Terminate ();
    }
}