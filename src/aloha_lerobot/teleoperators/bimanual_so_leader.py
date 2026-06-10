"""Bimanual SO leader action helpers.

The real deployment uses two SO-style leader arms as an AlohaMini teleoperator.
This module keeps the public, testable part small: action-key conventions and
configuration objects. Hardware classes can wrap these helpers inside a LeRobot
teleoperator implementation.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping


@dataclass(frozen=True)
class SOArmEndpoint:
    """One leader-arm endpoint.

    ``port`` should be a stable OS device path, not an enumerating tty index.
    For public configs, keep it as a placeholder such as
    ``/dev/serial/by-id/usb-1a86_USB_Single_Serial_LEFT_LEADER-if00``.
    """

    port: str
    arm_profile: str = "am-arm-6dof"
    use_degrees: bool = True


@dataclass(frozen=True)
class BimanualLeaderConfig:
    """Config for two leader arms used as one bimanual teleoperator."""

    left: SOArmEndpoint
    right: SOArmEndpoint
    leader_id: str = "aloha_mini_leader"


def prefix_action(action: Mapping[str, float], prefix: str) -> dict[str, float]:
    """Prefix LeRobot action keys with ``left_`` or ``right_``."""

    if prefix not in {"left", "right"}:
        raise ValueError("prefix must be 'left' or 'right'")
    return {f"{prefix}_{key}": float(value) for key, value in action.items()}


def merge_bimanual_actions(
    left_action: Mapping[str, float],
    right_action: Mapping[str, float],
) -> dict[str, float]:
    """Merge two single-arm action dictionaries into one bimanual action."""

    merged = prefix_action(left_action, "left")
    overlap = set(merged).intersection(prefix_action(right_action, "right"))
    if overlap:
        raise ValueError(f"unexpected duplicate action keys: {sorted(overlap)}")
    merged.update(prefix_action(right_action, "right"))
    return merged


def validate_bimanual_action_keys(
    action: Mapping[str, float],
    single_arm_keys: list[str],
) -> tuple[set[str], set[str]]:
    """Return missing and extra keys for a bimanual action message."""

    expected = {f"left_{key}" for key in single_arm_keys}
    expected.update({f"right_{key}" for key in single_arm_keys})
    actual = set(action)
    return expected - actual, actual - expected
