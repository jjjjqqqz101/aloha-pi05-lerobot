from pathlib import Path

from aloha_lerobot.dataset_tools.episode_cleaning import (
    DatasetCleanSpec,
    build_delete_episodes_command,
    parse_bad_episode_map,
)


def test_parse_bad_episode_map():
    specs = parse_bad_episode_map(["# comment", "task_01: 1 3 4", "task_02:"])

    assert specs == [
        DatasetCleanSpec("task_01", (1, 3, 4)),
        DatasetCleanSpec("task_02", ()),
    ]


def test_build_delete_episodes_command_is_argv_not_shell_string():
    cmd = build_delete_episodes_command(
        DatasetCleanSpec("task_01", (1, 3)),
        Path("/data/raw"),
        Path("/data/clean"),
    )

    assert cmd[0] == "lerobot-edit-dataset"
    assert "--operation.episode_indices" in cmd
    assert "[1, 3]" in cmd
    assert str(Path("/data/raw") / "task_01") in cmd
    assert str(Path("/data/clean") / "task_01_clean") in cmd
