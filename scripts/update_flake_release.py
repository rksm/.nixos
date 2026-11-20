#!/usr/bin/env python3
"""Pin a GitHub flake input to its latest stable release."""

import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.request import urlopen

def update(flake_dir, input_name):
    lock = json.loads((flake_dir / "flake.lock").read_text())
    nodes = lock["nodes"]
    locked = nodes[nodes[lock["root"]]["inputs"][input_name]]["locked"]
    repo = f'{locked["owner"]}/{locked["repo"]}'
    api = f"https://api.github.com/repos/{repo}"

    with urlopen(f"{api}/releases/latest", timeout=30) as response:
        tag = json.load(response)["tag_name"]
    if not re.fullmatch(r"v[0-9]+\.[0-9]+\.[0-9]+", tag):
        raise ValueError(f"Invalid {input_name} release tag: {tag}")
    # Worktrunk can pin a main commit until a release includes it.
    if input_name == "worktrunk-nix":
        pinned = locked["rev"]
        with urlopen(f"{api}/compare/{pinned}...{tag}", timeout=30) as response:
            status = json.load(response)["status"]
        if status in ("behind", "diverged"):
            print(f"Keeping Worktrunk at {pinned}: release {tag} does not contain it ({status}).")
            return
        if status not in ("ahead", "identical"):
            raise ValueError(f"Unexpected status comparing {pinned} with {tag}: {status}")

    flake_file = flake_dir / "flake.nix"
    original = flake_file.read_text()
    updated, count = re.subn(
        rf'^(\s*{re.escape(input_name)}\.url = )"github:{re.escape(repo)}(?:/[^"]+)?";$',
        lambda match: f'{match[1]}"github:{repo}/{tag}";',
        original,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise ValueError(f"Expected one {input_name}.url assignment in {flake_file}")
    flake_file.write_text(updated)
    try:
        subprocess.run(["nix", "flake", "update", input_name], cwd=flake_dir, check=True)
    except BaseException:
        # Nix writes flake.lock only on success, so this restores the old pin.
        flake_file.write_text(original)
        raise
    print(f"{input_name} {tag}")


if __name__ == "__main__":
    update(Path(sys.argv[1]), sys.argv[2])
