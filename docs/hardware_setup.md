# Hardware Setup

This document describes the public hardware contract. Do not commit real USB
serial numbers, private IPs, or lab-specific absolute paths.

## AlohaMini Leader

Use stable device paths for both leader arms. Avoid `/dev/ttyUSB*` because the
index can change after reconnecting USB devices.

Example:

```text
/dev/serial/by-id/usb-1a86_USB_Single_Serial_LEFT_LEADER-if00
/dev/serial/by-id/usb-1a86_USB_Single_Serial_RIGHT_LEADER-if00
```

## AlohaPro / Orin Host

The robot host should own:

- follower-arm motor buses,
- camera capture,
- lift/base control if present,
- watchdog and torque shutdown,
- ZMQ or gRPC bridge endpoints.

Recommended camera feature names:

```text
observation.images.chest
observation.images.wrist_left
observation.images.wrist_right
```

## Joint Order

Keep one action/state order throughout data collection, training, and inference.
The helper package exposes `ALOHA_14DOF_JOINT_ORDER` as a public reference.

If your real robot uses a different dimension, create a new constant and update:

- dataset feature definitions,
- model output features,
- inference client validation,
- safety limits,
- documentation.

## Safety Baseline

- Start every new setup in dry-run or no-follower mode.
- Verify camera timestamps and action dimensions before enabling torque.
- Keep a physical emergency stop reachable.
- Stop processes in this order: client, robot host, policy server.
