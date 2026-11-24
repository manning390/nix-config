"""Run with python3 test-area-screenshot.py; no graphical session required."""

import concurrent.futures
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("area_screenshot", Path(__file__).with_name("area-screenshot.py"))
tools = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tools)


class AreaScreenshotTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.env = patch.dict(os.environ, {
            "XDG_CACHE_HOME": str(self.root / "cache"),
            "XDG_STATE_HOME": str(self.root / "state"),
            "CAELESTIA_SCREENSHOTS_DIR": str(self.root / "Pictures/Screenshots"),
        })
        self.env.start()
        self.notification = patch.object(tools, "notify", return_value="")
        self.notify = self.notification.start()

    def tearDown(self):
        self.notification.stop()
        self.env.stop()
        self.temporary.cleanup()

    def cache_captures(self):
        return list((self.root / "cache/caelestia/area-screenshot").glob("capture-*"))

    def capture_backend(self, args, **kwargs):
        if args[0] == "slurp":
            return subprocess.CompletedProcess(args, 0, "10,20 30x40\n", "")
        if args[0] == "grim":
            Path(args[-1]).write_bytes(b"png")
        if args[0] == "wl-copy":
            self.assertEqual(kwargs["stdin"].read(), b"png")
        return subprocess.CompletedProcess(args, 0, "", "")

    def test_cancel_does_not_copy_or_leave_files(self):
        with patch.object(tools.subprocess, "run", return_value=subprocess.CompletedProcess([], 1, "", "")) as run:
            tools.screenshot()
        self.assertEqual(run.call_count, 1)
        self.assertEqual(self.cache_captures(), [])
        self.assertFalse(tools.screenshots_dir().exists())

    def test_dismiss_copies_without_permanent_save(self):
        with patch.object(tools.subprocess, "run", side_effect=self.capture_backend) as run:
            tools.screenshot()
        self.assertEqual([call.args[0][0] for call in run.call_args_list], ["slurp", "grim", "wl-copy"])
        self.assertEqual(list(tools.screenshots_dir().glob("*.png")), [])
        self.assertEqual(self.cache_captures(), [])

    def test_notification_save_and_immediate_save(self):
        for immediate in (False, True):
            self.notify.return_value = "save"
            with patch.object(tools.subprocess, "run", side_effect=self.capture_backend):
                tools.screenshot(save=immediate)
        self.assertEqual(len(list(tools.screenshots_dir().glob("*.png"))), 2)
        self.assertEqual(self.cache_captures(), [])

    def test_capture_error_cleans_up(self):
        def backend(args, **kwargs):
            if args[0] == "wl-copy":
                raise subprocess.CalledProcessError(1, args)
            return self.capture_backend(args, **kwargs)

        with patch.object(tools.subprocess, "run", side_effect=backend):
            with self.assertRaises(subprocess.CalledProcessError):
                tools.screenshot()
        self.assertEqual(self.cache_captures(), [])
        self.assertFalse(tools.screenshots_dir().exists())

    def test_busy_area_capture_does_not_start_another_selection(self):
        with tools.lock() as acquired:
            self.assertTrue(acquired)
            with patch.object(tools.subprocess, "run") as run:
                tools.screenshot()
                run.assert_not_called()
        self.assertEqual(self.cache_captures(), [])

    def test_failed_save_removes_partial_file(self):
        source = self.root / "source.png"
        source.write_bytes(b"image")
        with patch.object(tools.shutil, "copyfileobj", side_effect=OSError("write failed")):
            with self.assertRaises(OSError):
                tools.save_capture(source)
        self.assertEqual(list(tools.screenshots_dir().glob("*.png")), [])

    def test_concurrent_saves_have_unique_filenames(self):
        source = self.root / "source.png"
        source.write_bytes(b"image")
        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
            paths = list(pool.map(lambda _: tools.save_capture(source), range(20)))
        self.assertEqual(len(set(paths)), 20)
        self.assertTrue(all(path.read_bytes() == b"image" for path in paths))


if __name__ == "__main__":
    unittest.main()
