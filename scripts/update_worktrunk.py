#!/usr/bin/env python3
"""Pin Worktrunk to its newest release if that release has the locked commit.

Worktrunk has no release branch, and main keeps the version of the last
release. So the version number cannot tell a newer release from a rollback.
The GitHub compare API can, so the pin moves only when it reports that the
release contains the locked commit.
"""

import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.request import urlopen

API = "https://api.github.com/repos/max-sixty/worktrunk"


def update(flake_dir):
    nodes = json.loads((flake_dir / "flake.lock").read_text())["nodes"]
    pinned = nodes[nodes["root"]["inputs"]["worktrunk-nix"]]["locked"]["rev"]

    with urlopen(f"{API}/releases/latest", timeout=30) as response:
        tag = json.load(response)["tag_name"]
    if not re.fullmatch(r"v[0-9]+\.[0-9]+\.[0-9]+", tag):
        raise ValueError(f"Invalid Worktrunk release tag: {tag}")
    with urlopen(f"{API}/compare/{pinned}...{tag}", timeout=30) as response:
        status = json.load(response)["status"]
    if status in ("behind", "diverged"):
        print(f"Keeping Worktrunk at {pinned}: release {tag} does not contain it ({status}).")
        return
    if status not in ("ahead", "identical"):
        raise ValueError(f"Unexpected status comparing {pinned} with {tag}: {status}")

    flake_file = flake_dir / "flake.nix"
    original = flake_file.read_text()
    updated, count = re.subn(
        r'^(\s*worktrunk-nix\.url = )"github:max-sixty/worktrunk[^"]*";$',
        lambda match: f'{match[1]}"github:max-sixty/worktrunk/{tag}";',
        original,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise ValueError(f"Expected one worktrunk-nix.url assignment in {flake_file}")
    flake_file.write_text(updated)
    try:
        subprocess.run(["nix", "flake", "update", "worktrunk-nix"], cwd=flake_dir, check=True)
    except BaseException:
        # Nix writes flake.lock only on success, so this restores the old pin.
        flake_file.write_text(original)
        raise
    print(f"Worktrunk {tag}")


if __name__ == "__main__":
    update(Path(sys.argv[1]))
