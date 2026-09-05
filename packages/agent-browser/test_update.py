import io
import json
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from update import update


class UpdateTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.package_file = Path(directory.name) / "package.nix"
        self.original = '''{
  version = "0.36.0";
  passthru.piAgentBrowserNativeVersion = "0.6.5";
  src = {
    hash = "old-hash";
  };
}
'''
        self.package_file.write_text(self.original)
        self.archive = Path(directory.name) / "extension.tgz"

    def run_update(self, target, browser_result):
        with tarfile.open(self.archive, "w:gz") as archive:
            content = target.encode()
            member = tarfile.TarInfo("package/scripts/agent-browser-target.mjs")
            member.size = len(content)
            archive.addfile(member, io.BytesIO(content))
        release = io.BytesIO(json.dumps({
            "version": "0.6.6",
            "dist": {"integrity": "sha512-test"},
        }).encode())
        with (
            patch("update.urlopen", return_value=release),
            patch(
                "update.subprocess.check_output",
                side_effect=[json.dumps({"storePath": str(self.archive)}), browser_result],
            ) as prefetch,
        ):
            update(self.package_file)
        return prefetch

    def test_updates_pair_even_when_browser_version_stays_the_same(self):
        for version in ("0.36.0", "0.37.0"):
            with self.subTest(version=version):
                self.package_file.write_text(self.original)
                prefetch = self.run_update(
                    f'export const TARGET_AGENT_BROWSER_VERSION = "{version}";',
                    json.dumps({"hash": "new-hash"}),
                )
                self.assertEqual(
                    self.package_file.read_text(),
                    self.original.replace("0.6.5", "0.6.6")
                    .replace("0.36.0", version)
                    .replace("old-hash", "new-hash"),
                )
                self.assertEqual(
                    prefetch.call_args.args[0][-1],
                    f"https://registry.npmjs.org/agent-browser/-/agent-browser-{version}.tgz",
                )

    def test_unknown_target_format_leaves_current_pair_intact(self):
        for target in (
            "// No declared target",
            'export const TARGET_AGENT_BROWSER_VERSION = "latest";',
            'export const TARGET_AGENT_BROWSER_VERSION = "0.36.0";\n' * 2,
        ):
            with self.subTest(target=target), self.assertRaises(ValueError):
                self.run_update(target, json.dumps({"hash": "new-hash"}))
            self.assertEqual(self.package_file.read_text(), self.original)

    def test_failed_browser_download_leaves_current_pair_intact(self):
        with self.assertRaises(subprocess.CalledProcessError):
            self.run_update(
                'export const TARGET_AGENT_BROWSER_VERSION = "0.37.0";',
                subprocess.CalledProcessError(1, "nix store prefetch-file"),
            )
        self.assertEqual(self.package_file.read_text(), self.original)


if __name__ == "__main__":
    unittest.main()
