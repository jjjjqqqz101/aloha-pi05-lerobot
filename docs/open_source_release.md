# Open Source Release Notes

This repository should present the work as a clean engineering system:

> A LeRobot-based real-robot pipeline for AlohaMini teleoperation, AlohaPro data
> collection, dataset cleaning, Pi0.5 training on A100, and remote Pi0.5
> inference on a 4090 with Orin closed-loop control.

## Suggested Paper / Project Framing

- Problem: large VLA policies are difficult to train, deploy, and run directly
  on embedded robot hardware.
- System: split data collection, training, inference, and low-level control
  across machines that are good at each job.
- Contribution: a reproducible engineering template for turning LeRobot into a
  real Aloha deployment.

## Do Not Publish

- Private repositories or fork history containing secrets.
- Raw robot logs with lab addresses.
- Data or images that reveal private scenes unless reviewed.
- Model checkpoints in Git history.
- SSH config, key paths, or real user names.

## Publish Separately

- Dataset: Hugging Face Dataset Hub.
- Model: Hugging Face Model Hub.
- Code and docs: GitHub.
