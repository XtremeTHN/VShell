[DBus (name = "org.freedesktop.login1.Manager")]
interface IManager: DBusProxy {
    public signal void prepare_for_sleep (bool start);

    public abstract string can_suspend () throws Error;
    public abstract void power_off (bool interactive) throws Error;
    public abstract void reboot (bool interactive) throws Error;
    public abstract void suspend (bool interactive) throws Error;
    public abstract void schedule_shutdown (string type, uint64 micro_seconds) throws Error;
    public abstract bool cancel_scheduled_shutdown () throws Error;
    public abstract UnixInputStream inhibit (string what, string who, string why, string mode) throws Error;
}

[DBus (name = "org.freedesktop.login1.Session")]
interface ISession: DBusProxy {
    public abstract string id { owned get; set; }
    public abstract string name { owned get; set; }
    public abstract string desktop { owned get; set; }

    public abstract void terminate () throws Error;
    public abstract void lock () throws Error;
    public abstract void unlock () throws Error;
}

public errordomain LogindErrors {
    PROXY_NULL
}

public enum InhibitMode {
    BLOCK,
    DELAY;

    public string to_string () {
        switch (this) {
            case BLOCK:
                return "block";
            case DELAY:
                return "delay";
            default:
                return "unknown";
        }
    }
}

public enum ShutdownMode {
    POWEROFF,
    DRY_POWEROFF,
    REBOOT,
    DRY_REBOOT,
    HALT,
    DRY_HALT;

    public string to_string () {
        switch (this) {
            case POWEROFF:
                return "poweroff";
            case DRY_POWEROFF:
                return "dry-poweroff";
            case REBOOT:
                return "reboot";
            case DRY_REBOOT:
                return "dry-reboot";
            case HALT:
                return "halt";
            case DRY_HALT:
                return "dry-halt";
            default:
                return "unknown";
        }
    }
}

public class Logind: Object {
    IManager proxy;
    ISession session_proxy;

    public signal void sleep ();
    public signal void wake ();


    private static GLib.Once<Logind> instance;

    public static Logind get_instance () {
        return instance.once (() => {
            return new Logind ();
        });
    }
    
    Logind () {
        Object ();
        
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

        proxy.prepare_for_sleep.connect ((start) => {
            if (start)
                sleep ();
            else
                wake ();
        });
    }

    public bool can_suspend () {
        try {
            if (proxy.can_suspend () != "yes")
                return false;
        } catch (Error e) {
            critical ("Couldn't call CanSuspend: %s", e.message);
            return false;
        }

        return true;
    }

    public void suspend () throws Error {
        if (!can_suspend ())
            return;

        proxy.suspend (false);
    }

    public void power_off () throws Error {
        proxy.power_off (false);
    }

    public void reboot () throws Error {
        proxy.reboot (false);
    }

    public void log_out () throws Error {
        session_proxy.terminate ();
    }

    public void lock () throws Error {
        session_proxy.lock ();
    }

    public void unlock () throws Error {
        session_proxy.unlock ();
    }

    public bool cancel_scheduled_shutdown () throws Error {
        return proxy.cancel_scheduled_shutdown ();
    }

    public void schedule_shutdown (ShutdownMode mode, uint64 seconds) throws Error {
        var real_time = (int64) get_real_time ();
        var delay = (uint64) (real_time + seconds * 1000000);
        
        proxy.schedule_shutdown (mode.to_string (), delay);
    }

    public UnixInputStream inhibit (string lock_types, string who, string description, InhibitMode mode) throws Error {
        return proxy.inhibit (lock_types, who, description, mode.to_string ());
    }
}