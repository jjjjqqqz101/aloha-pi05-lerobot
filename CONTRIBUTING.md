# Contributing

Thanks for your interest in improving Aloha Pi0.5 LeRobot. This project is a
real-robot research engineering repository, so contributions should keep two
things in balance: make the system easier to reproduce, and keep private lab
details out of public Git history.

## Good Contribution Areas

- Documentation for AlohaMini/AlohaPro hardware setup.
- Safer startup and shutdown scripts for Orin, A100, and 4090 machines.
- Dataset visualization, cleaning, and validation tools.
- Action/state mapping tests and schema checks.
- Remote inference demos that can run without real hardware.
- Public config templates that replace private paths with clear placeholders.

## Local Development

Create an environment and install the package:

```bash
conda create -n aloha_lerobot python=3.10 -y
conda activate aloha_lerobot
python -m pip install -e ".[dev]"
python -m pytest
```

Run the fake demo:

```bash
python examples/fake_remote_inference_demo.py
```

## Before Opening A Pull Request

Please run:

```bash
python -m pytest
```

Then check that the staged files do not contain private information:

```bash
rg -n "<your-secret-or-private-path-pattern>"
```

Also confirm that no large datasets, videos, checkpoints, or logs are staged:

```bash
git status --short
```

## Safety Rules

Real robot code must default to safe behavior:

- Prefer dry-run or no-follower mode for new scripts.
- Validate action dimension, joint order, and numeric finiteness.
- Reject stale observations or actions.
- Keep watchdog and torque-disable behavior close to the robot host.
- Document any command that can move hardware.

## Public Release Hygiene

Do not commit:

- raw datasets, videos, `.parquet` files, or camera dumps,
- `.safetensors`, `.pt`, `.pth`, `.ckpt`, or other model weights,
- wandb runs, training logs, or temporary outputs,
- SSH config, usernames, private IPs, absolute lab paths, or USB serial numbers,
- access tokens or API keys.

Use example config files and environment variables instead of hardcoded local
values.

## Style

- Keep docs concise but operational.
- Prefer explicit command templates over prose-only explanations.
- Keep Python helpers small, typed, and easy to test.
- Add tests when changing action mapping, dataset cleaning, or message schemas.

## Relationship To Upstream Projects

This repository builds on LeRobot concepts and APIs. If a file is adapted from
LeRobot or another upstream project, retain its license header and attribution.
