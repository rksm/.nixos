#!/usr/bin/env python3
"""Check a real separate desktop without sending input to the host."""

import argparse
import base64
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("host_bus_id")
    parser.add_argument("--input", action="store_true", help="Also test portal mouse and keyboard input; requires GNOME consent")
    args = parser.parse_args()
    assert not Path("/dev/uinput").exists(), "Host input device is visible"
    assert not Path(os.environ["YDOTOOL_SOCKET"]).exists(), "Host input socket is visible"
    bus_id = subprocess.check_output([
        "gdbus", "call", "--session", "--dest", "org.freedesktop.DBus",
        "--object-path", "/org/freedesktop/DBus", "--method", "org.freedesktop.DBus.GetId",
    ], text=True).strip()
    assert bus_id != args.host_bus_id, "The desktop shares the host session bus"

    scratch = Path("/tmp/computer-use-check.txt")
    scratch.write_text("Before the MCP edit.\n")
    editor = subprocess.Popen(["gnome-text-editor", "--standalone", str(scratch)])
    server = subprocess.Popen(
        ["computer-use-linux", "mcp"],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True,
    )
    request_id = 0

    def request(method, params):
        nonlocal request_id
        request_id += 1
        print(f"Checking {params.get('name', method)}", file=sys.stderr, flush=True)
        server.stdin.write(json.dumps({
            "jsonrpc": "2.0", "id": request_id, "method": method, "params": params,
        }) + "\n")
        server.stdin.flush()
        signal.alarm(60)
        try:
            while line := server.stdout.readline():
                response = json.loads(line)
                if response.get("id") == request_id:
                    assert "error" not in response, response
                    return response["result"]
            raise RuntimeError("MCP server closed its output")
        finally:
            signal.alarm(0)

    def call(name, arguments):
        result = request("tools/call", {"name": name, "arguments": arguments})
        assert not result.get("isError"), result
        return json.loads(next(item["text"] for item in result["content"] if item["type"] == "text"))

    try:
        request("initialize", {
            "protocolVersion": "2024-11-05", "capabilities": {},
            "clientInfo": {"name": "desktop-check", "version": "1"},
        })
        server.stdin.write('{"jsonrpc":"2.0","method":"notifications/initialized"}\n')
        server.stdin.flush()
        tools = request("tools/list", {})
        assert "get_app_state" in {tool["name"] for tool in tools["tools"]}

        for _ in range(30):
            windows = call("list_windows", {})
            target = next((window for window in windows["windows"]
                           if "computer-use-check.txt" in (window.get("title") or "")), None)
            if target:
                break
            time.sleep(0.2)
        assert target, "The scratch editor window did not appear"
        call("activate_window", {"window_id": target["window_id"]})

        state = call("get_app_state", {"window_id": target["window_id"]})
        assert not state["screenshot_error"], state["screenshot_error"]
        screenshot = base64.b64decode(state["screenshot"]["data_url"].split(",", 1)[1])
        assert screenshot.startswith(b"\x89PNG\r\n\x1a\n") and len(screenshot) > 1000
        field = next(node for node in state["accessibility_tree"] if node["supports_editable_text"])
        text = "MCP wrote: Zwölf Yaks aßen Öl. 日本語 ✓"
        result = call("set_value", {"element_index": field["index"], "value": text})
        assert result["ok"], result
        state = call("get_app_state", {"window_id": target["window_id"], "include_screenshot": False})
        assert text in json.dumps(state["accessibility_tree"], ensure_ascii=False), "Text did not reach the editor"
        print("PASS: private input devices and D-Bus, MCP, focus, screenshot, and Unicode accessibility editing")
        if args.input:
            bounds = field["bounds"]
            result = call("click", {
                "window_id": target["window_id"],
                "x": bounds["x"] + bounds["width"] // 2,
                "y": bounds["y"] + bounds["height"] // 2,
            })
            assert result["ok"], result
            for name, arguments in [
                ("press_key", {"key": "ctrl+a"}),
                ("type_text", {"text": text + " through keyboard"}),
                ("press_key", {"key": "ctrl+s"}),
            ]:
                result = call(name, {"window_id": target["window_id"], **arguments})
                assert result["ok"], result
            for _ in range(30):
                if scratch.read_text().strip() == text + " through keyboard":
                    break
                time.sleep(0.1)
            assert scratch.read_text().strip() == text + " through keyboard", "Keyboard input did not reach the file"
            print("PASS: portal mouse and Unicode keyboard input, verified in the saved file")
    finally:
        server.stdin.close()
        server.wait(timeout=10)
        editor.terminate()
        editor.wait(timeout=10)


if __name__ == "__main__":
    main()
