"""Helpers for LeRobot dataset cleaning command generation."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class DatasetCleanSpec:
    """One source dataset and the bad episode indices that should be removed."""

    name: str
    bad_episodes: tuple[int, ...] = ()


def parse_bad_episode_map(lines: list[str]) -> list[DatasetCleanSpec]:
    """Parse ``name: 1 3 4`` style cleaning specs."""

    specs: list[DatasetCleanSpec] = []
    for raw_line in lines:
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            raise ValueError(f"invalid cleaning line: {raw_line!r}")
        name, values = line.split(":", 1)
        episodes = tuple(int(item) for item in values.split()) if values.strip() else ()
        specs.append(DatasetCleanSpec(name=name.strip(), bad_episodes=episodes))
    return specs


def build_delete_episodes_command(
    spec: DatasetCleanSpec,
    source_root: Path,
    output_root: Path,
) -> list[str]:
    """Build a safe argv list for ``lerobot-edit-dataset delete_episodes``."""

    if not spec.bad_episodes:
        raise ValueError("no bad episodes were provided")
    source = source_root / spec.name
    output = output_root / f"{spec.name}_clean"
    indices = "[" + ", ".join(str(index) for index in spec.bad_episodes) + "]"
    return [
        "lerobot-edit-dataset",
        "--repo_id",
        f"local/{spec.name}",
        "--root",
        str(source),
        "--new_repo_id",
        f"local/{spec.name}_clean",
        "--new_root",
        str(output),
        "--operation.type",
        "delete_episodes",
        "--operation.episode_indices",
        indices,
    ]
