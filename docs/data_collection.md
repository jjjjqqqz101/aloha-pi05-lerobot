# Data Collection

Data collection uses AlohaMini leader arms to command the AlohaPro robot through
a LeRobot-compatible robot client.

## Recommended Episode Flow

1. Start the robot host on Orin.
2. Start local or remote leader bridge.
3. Record one short dry-run episode.
4. Inspect camera views, state dimensions, and action ranges.
5. Record full episodes with consistent task descriptions.
6. Save episodes locally.
7. Push only curated datasets to the Hugging Face Dataset Hub.

## Dataset Features

Use LeRobot dataset features generated from the robot observation/action
features. Keep feature names stable between collection and training.

Typical features:

```text
observation.state
observation.images.chest
observation.images.wrist_left
observation.images.wrist_right
action
task
timestamp
```

## Cleaning

Bad episodes should be tracked explicitly. Prefer a text or YAML record such as:

```text
task_0429_01: 1 3 4
task_0429_02: 0 1 2 6
task_0429_03:
```

Then generate `lerobot-edit-dataset` commands from the spec. This keeps cleaning
auditable and avoids silently modifying raw data.

## Visualization

A dataset visualizer should help answer:

- Are all camera streams present?
- Does the robot state match the video?
- Are actions smooth and in the expected range?
- Do failed episodes share a time segment or camera issue?

Do not commit visualizer caches, videos, or generated thumbnails to this repo.
