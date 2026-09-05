#!/usr/bin/env python3

import json
import re
import subprocess
import tarfile
from pathlib import Path
from urllib.request import urlopen


def update(package_file):
    registry = "https://registry.npmjs.org"
    with urlopen(f"{registry}/pi-agent-browser-native/latest", timeout=30) as response:
        release = json.load(response)
    extension_version = release["version"]
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", extension_version):
        raise ValueError(f"Invalid Pi extension version: {extension_version}")

    extension = json.loads(subprocess.check_output(
        [
            "nix", "store", "prefetch-file", "--json", "--hash-type", "sha512",
            "--expected-hash", release["dist"]["integrity"],
            f"{registry}/pi-agent-browser-native/-/pi-agent-browser-native-{extension_version}.tgz",
        ],
        text=True,
    ))
    with tarfile.open(extension["storePath"]) as archive:
        target = archive.extractfile("package/scripts/agent-browser-target.mjs").read().decode()
    versions = re.findall(
        r'^export const TARGET_AGENT_BROWSER_VERSION = "([0-9]+\.[0-9]+\.[0-9]+)";$',
        target,
        re.MULTILINE,
    )
    if len(versions) != 1:
        raise ValueError("Pi extension must declare one stable agent-browser target version")
    browser_version = versions[0]

    browser = json.loads(subprocess.check_output(
        [
            "nix", "store", "prefetch-file", "--json",
            f"{registry}/agent-browser/-/agent-browser-{browser_version}.tgz",
        ],
        text=True,
    ))
    original = package_file.read_text()
    updated = original
    for attribute, value in (
        ("version", browser_version),
        ("passthru.piAgentBrowserNativeVersion", extension_version),
        ("hash", browser["hash"]),
    ):
        updated, count = re.subn(
            rf'^(\s*{re.escape(attribute)} = )"[^"]+";',
            lambda match: f'{match[1]}"{value}";',
            updated,
            flags=re.MULTILINE,
        )
        if count != 1:
            raise ValueError(f"Expected one {attribute} assignment in {package_file}")

    if updated != original:
        package_file.write_text(updated)
    print(f"agent-browser {browser_version}; pi-agent-browser-native {extension_version}")


if __name__ == "__main__":
    update(Path(__file__).with_name("package.nix"))
