import Gio from "gi://Gio";
import Shell from "gi://Shell";

import { Extension } from "resource:///org/gnome/shell/extensions/extension.js";

const BUS_NAME = "com.freestyle.FocusBridge";
const OBJECT_PATH = "/com/freestyle/FocusBridge";

const DBUS_XML = `
<node>
  <interface name="com.freestyle.FocusBridge">
    <method name="GetActiveWindow">
      <arg type="s" name="payload" direction="out"/>
    </method>
  </interface>
</node>`;

function readString(value) {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function readNumber(value) {
  return typeof value === "number" && Number.isFinite(value) && value > 0
    ? Math.floor(value)
    : null;
}

function callOrNull(target, methodName) {
  try {
    const method = target?.[methodName];
    return typeof method === "function" ? method.call(target) : null;
  } catch {
    return null;
  }
}

function getFocusedWindowPayload() {
  const metaWindow = global.display.focus_window;
  if (!metaWindow) {
    return {};
  }

  const shellApp = Shell.WindowTracker.get_default().get_window_app(metaWindow);
  const payload = {
    app:
      readString(callOrNull(shellApp, "get_id")) ??
      readString(callOrNull(shellApp, "get_name")),
    title: readString(callOrNull(metaWindow, "get_title")),
    wmClass: readString(callOrNull(metaWindow, "get_wm_class")),
    wmClassInstance: readString(
      callOrNull(metaWindow, "get_wm_class_instance"),
    ),
    pid: readNumber(callOrNull(metaWindow, "get_pid")),
    sandboxedAppId: readString(callOrNull(metaWindow, "get_sandboxed_app_id")),
    gtkApplicationId: readString(
      callOrNull(metaWindow, "get_gtk_application_id"),
    ),
  };

  return Object.fromEntries(
    Object.entries(payload).filter(([, value]) => value !== null),
  );
}

class FocusBridge {
  GetActiveWindow() {
    return JSON.stringify(getFocusedWindowPayload());
  }
}

export default class FreestyleFocusBridgeExtension extends Extension {
  enable() {
    this._dbusImpl = Gio.DBusExportedObject.wrapJSObject(
      DBUS_XML,
      new FocusBridge(),
    );
    this._dbusImpl.export(Gio.DBus.session, OBJECT_PATH);
    this._ownName = Gio.DBus.session.own_name(
      BUS_NAME,
      Gio.BusNameOwnerFlags.ALLOW_REPLACEMENT | Gio.BusNameOwnerFlags.REPLACE,
      () => {},
      () => {},
    );
  }

  disable() {
    if (this._ownName) {
      Gio.DBus.session.unown_name(this._ownName);
      this._ownName = null;
    }

    if (this._dbusImpl) {
      this._dbusImpl.unexport();
      this._dbusImpl = null;
    }
  }
}
