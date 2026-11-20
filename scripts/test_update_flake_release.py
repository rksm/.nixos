import io
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from urllib.error import URLError

from update_flake_release import update

PINNED = "397136ea31a6840901f17d5e68c6450b1a99299e"


class UpdateTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.flake_dir = Path(directory.name)
        self.flake_file = self.flake_dir / "flake.nix"
        self.original = f'''{{
  inputs = {{
    worktrunk-nix.url = "github:max-sixty/worktrunk/{PINNED}";
    mr-boxington.url = "github:jdx/mr-boxington/v1.29.0";
  }};
}}
'''
        self.flake_file.write_text(self.original)
        (self.flake_dir / "flake.lock").write_text(json.dumps({
            "root": "root",
            "nodes": {
                "root": {"inputs": {"worktrunk-nix": "worktrunk-nix", "mr-boxington": "mr-boxington"}},
                "worktrunk-nix": {"locked": {"owner": "max-sixty", "repo": "worktrunk", "rev": PINNED}},
                "mr-boxington": {"locked": {"owner": "jdx", "repo": "mr-boxington"}},
            },
        }))

    def run_update(self, tag, status, nix_error=None):
        responses = [{"tag_name": tag}, {"status": status}]
        with (
            patch(
                "update_flake_release.urlopen",
                side_effect=[io.BytesIO(json.dumps(body).encode()) for body in responses],
            ) as urlopen,
            patch("update_flake_release.subprocess.run", side_effect=nix_error) as nix,
        ):
            update(self.flake_dir, "worktrunk-nix")
        return urlopen, nix

    def test_keeps_pin_when_release_lacks_pinned_commit(self):
        for status in ("behind", "diverged"):
            with self.subTest(status=status):
                urlopen, nix = self.run_update("v0.80.0", status)
                self.assertEqual(
                    urlopen.call_args.args[0],
                    f"https://api.github.com/repos/max-sixty/worktrunk/compare/{PINNED}...v0.80.0",
                )
                self.assertEqual(self.flake_file.read_text(), self.original)
                nix.assert_not_called()

    def test_adopts_release_that_contains_pinned_commit(self):
        for current, status in ((PINNED, "ahead"), (PINNED, "identical"), ("v0.80.0", "ahead")):
            with self.subTest(current=current, status=status):
                self.flake_file.write_text(self.original.replace(PINNED, current))
                _, nix = self.run_update("v0.81.0", status)
                self.assertEqual(
                    self.flake_file.read_text(), self.original.replace(PINNED, "v0.81.0")
                )
                nix.assert_called_once_with(
                    ["nix", "flake", "update", "worktrunk-nix"], cwd=self.flake_dir, check=True
                )

    def test_failures_leave_pin_intact(self):
        for tag, status, nix_error in (
            ("latest", "ahead", None),
            ("v0.81.0-rc.1", "ahead", None),
            ("v0.81.0", "unknown", None),
            ("v0.81.0", "ahead", subprocess.CalledProcessError(1, "nix flake update")),
        ):
            with (
                self.subTest(tag=tag, status=status, nix_error=nix_error),
                self.assertRaises((ValueError, subprocess.CalledProcessError)),
            ):
                self.run_update(tag, status, nix_error)
            self.assertEqual(self.flake_file.read_text(), self.original)

    def test_unreachable_api_leaves_pin_intact(self):
        with (
            patch("update_flake_release.urlopen", side_effect=URLError("offline")),
            patch("update_flake_release.subprocess.run") as nix,
            self.assertRaises(URLError),
        ):
            update(self.flake_dir, "worktrunk-nix")
        self.assertEqual(self.flake_file.read_text(), self.original)
        nix.assert_not_called()

    def test_updates_mbx_from_the_latest_release(self):
        with (
            patch("update_flake_release.urlopen", return_value=io.BytesIO(b'{"tag_name":"v1.30.0"}')) as fetch,
            patch("update_flake_release.subprocess.run") as nix,
        ):
            update(self.flake_dir, "mr-boxington")
        fetch.assert_called_once_with("https://api.github.com/repos/jdx/mr-boxington/releases/latest", timeout=30)
        self.assertEqual(self.flake_file.read_text(), self.original.replace("v1.29.0", "v1.30.0"))
        nix.assert_called_once_with(["nix", "flake", "update", "mr-boxington"], cwd=self.flake_dir, check=True)


if __name__ == "__main__":
    unittest.main()
