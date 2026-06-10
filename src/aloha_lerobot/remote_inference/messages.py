"""Message helpers for Orin-to-GPU remote inference bridges."""

from __future__ import annotations

import math
import time
from dataclasses import dataclass, field
from typing import Any, Mapping


ALOHA_14DOF_JOINT_ORDER = [
    "left_shoulder_pan",
    "left_shoulder_lift",
    "left_elbow_flex",
    "left_wrist_flex",
    "left_wrist_yaw",
    "left_wrist_roll",
    "left_gripper",
    "right_shoulder_pan",
    "right_shoulder_lift",
    "right_elbow_flex",
    "right_wrist_flex",
    "right_wrist_yaw",
    "right_wrist_roll",
    "right_gripper",
]

DEFAULT_IMAGE_KEYS = [
    "observation.images.chest",
    "observation.images.wrist_left",
    "observation.images.wrist_right",
]


def finite_float_list(values: Any, expected_len: int, name: str) -> list[float]:
    """Validate and coerce a fixed-size numeric list."""

    if not isinstance(values, list) or len(values) != expected_len:
        raise ValueError(f"{name} must be list[{expected_len}]")
    out = [float(value) for value in values]
    if any(not math.isfinite(value) for value in out):
        raise ValueError(f"{name} contains NaN or Inf")
    return out


def preview_right_arm(values: list[float]) -> dict[str, Any]:
    """Return a compact preview of right-arm joints for logging."""

    finite_float_list(values, len(ALOHA_14DOF_JOINT_ORDER), "action")
    return {
        "right_arm": [round(x, 4) for x in values[7:13]],
        "right_gripper": round(values[13], 4),
    }


@dataclass(frozen=True)
class RemoteObservationPacket:
    """Serializable observation packet sent from robot host to policy server."""

    state: list[float]
    images: Mapping[str, str]
    task: str
    timestamp: float = field(default_factory=time.time)
    schema: str = "aloha.remote_observation.v1"

    def validate(self, state_dim: int = len(ALOHA_14DOF_JOINT_ORDER)) -> None:
        finite_float_list(self.state, state_dim, "state")
        missing_images = [key for key in DEFAULT_IMAGE_KEYS if key not in self.images]
        if missing_images:
            raise ValueError(f"missing images: {missing_images}")
        if not self.task.strip():
            raise ValueError("task must not be empty")


@dataclass(frozen=True)
class RemoteActionPacket:
    """Serializable action packet sent from policy server to robot host."""

    action: list[float]
    timestamp: float = field(default_factory=time.time)
    schema: str = "aloha.remote_action.v1"

    def validate(self, action_dim: int = len(ALOHA_14DOF_JOINT_ORDER)) -> None:
        finite_float_list(self.action, action_dim, "action")
