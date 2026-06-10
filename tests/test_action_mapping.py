import pytest

from aloha_lerobot.remote_inference.messages import finite_float_list, preview_right_arm
from aloha_lerobot.teleoperators.bimanual_so_leader import (
    merge_bimanual_actions,
    validate_bimanual_action_keys,
)


def test_merge_bimanual_actions_prefixes_sides():
    merged = merge_bimanual_actions({"joint.pos": 1}, {"joint.pos": 2})

    assert merged == {"left_joint.pos": 1.0, "right_joint.pos": 2.0}


def test_validate_bimanual_action_keys_reports_diff():
    missing, extra = validate_bimanual_action_keys(
        {"left_a": 1.0, "right_a": 2.0, "right_b": 3.0},
        ["a", "b"],
    )

    assert missing == {"left_b"}
    assert extra == set()


def test_finite_float_list_rejects_nan():
    with pytest.raises(ValueError):
        finite_float_list([1.0, float("nan")], 2, "state")


def test_preview_right_arm():
    values = [float(i) for i in range(14)]

    preview = preview_right_arm(values)

    assert preview["right_arm"] == [7.0, 8.0, 9.0, 10.0, 11.0, 12.0]
    assert preview["right_gripper"] == 13.0
