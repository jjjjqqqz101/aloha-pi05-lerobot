#!/usr/bin/env python3
"""Run a tiny fake remote-inference loop without robot hardware."""

from __future__ import annotations

from aloha_lerobot.remote_inference import (
    ALOHA_14DOF_JOINT_ORDER,
    DEFAULT_IMAGE_KEYS,
    RemoteActionPacket,
    RemoteObservationPacket,
    preview_right_arm,
)


def main() -> int:
    state = [0.01 * i for i in range(len(ALOHA_14DOF_JOINT_ORDER))]
    images = {key: "base64-jpeg-placeholder" for key in DEFAULT_IMAGE_KEYS}
    obs = RemoteObservationPacket(state=state, images=images, task="pick up the object")
    obs.validate()

    action = [value + 0.1 for value in state]
    packet = RemoteActionPacket(action=action)
    packet.validate()

    print("observation schema:", obs.schema)
    print("action schema:", packet.schema)
    print("right arm preview:", preview_right_arm(packet.action))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
