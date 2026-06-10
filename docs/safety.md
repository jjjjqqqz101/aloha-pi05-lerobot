# Safety

Real robot control is a safety-critical workflow. This project provides
templates, not a certified safety system.

## Required Checks

- Confirm action dimension and joint order before enabling motors.
- Clamp every action to robot-specific joint limits.
- Reject `NaN`, `Inf`, stale timestamps, and malformed packets.
- Keep a watchdog on the robot host.
- Disable torque on normal shutdown.
- Use dry-run, no-follower, or fake-bridge modes before real control.

## Process Shutdown

Stop in this order:

```bash
pkill -f "robot_client"
pkill -f "robot_host"
pkill -f "policy_server"
```

Avoid force-killing the robot host during real operation because cleanup hooks
may be responsible for disabling torque.

## Open Source Hygiene

Before pushing changes:

- Search for private IPs, usernames, SSH key paths, and absolute lab paths.
- Check that no dataset, video, checkpoint, or log file is staged.
- Keep hardware-specific values in local config files ignored by Git.
