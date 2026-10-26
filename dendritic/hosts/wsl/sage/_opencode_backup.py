"""Keep dated OpenCode data snapshots without copying a live SQLite database."""

import datetime
from contextlib import closing
import os
from pathlib import Path
import shutil
import sqlite3
import sys
import tempfile


def backup(source: Path, destination: Path) -> None:
    if not source.is_dir():
        print(f"No OpenCode data at {source}; skipping backup.")
        return

    os.umask(0o077)
    destination.mkdir(parents=True, exist_ok=True, mode=0o700)
    staging = Path(tempfile.mkdtemp(prefix=".incomplete-", dir=destination))
    database = source / "opencode.db"

    def ignore(directory: str, names: list[str]) -> set[str]:
        if Path(directory) == source:
            return set(names) & {
                "log",
                "opencode.db",
                "opencode.db-wal",
                "opencode.db-shm",
                "opencode.db-journal",
            }
        return set()

    try:
        # Includes file-based session storage used by older OpenCode versions.
        shutil.copytree(source, staging, dirs_exist_ok=True, ignore=ignore)
        staging.chmod(0o700)
        if database.is_file():
            # Read-only access prevents accidentally creating an empty source DB.
            with closing(sqlite3.connect(f"{database.as_uri()}?mode=ro", uri=True)) as live:
                with closing(sqlite3.connect(staging / "opencode.db")) as snapshot:
                    live.backup(snapshot)
                    snapshot.execute("PRAGMA journal_mode=DELETE")

        timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S-%f")
        snapshot_path = destination / timestamp
        staging.rename(snapshot_path)
        print(f"OpenCode backup saved to {snapshot_path}")
    except BaseException:
        shutil.rmtree(staging)
        raise


if __name__ == "__main__":
    backup(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())
