# Pi0.5 Training On A100

The A100 machine is used for heavyweight Pi0.5 training. The public scripts in
this repository are templates; replace dataset IDs and paths locally.

## Inputs

- A cleaned LeRobot-format dataset.
- A local or Hub-hosted Pi0.5 base checkpoint.
- A training environment with CUDA, PyTorch, Accelerate, and LeRobot installed.

## Important Options

Recommended defaults for large checkpoints:

```text
policy.type=pi05
policy.dtype=bfloat16
policy.gradient_checkpointing=true
policy.normalization_mapping={ACTION: MEAN_STD, STATE: MEAN_STD, VISUAL: IDENTITY}
mixed_precision=bf16
```

## Resume Training

Resume from a checkpoint directory that includes both:

```text
checkpoints/last/pretrained_model/
checkpoints/last/training_state/
```

When resuming, prefer passing the saved `train_config.json` plus `--resume=true`
instead of trying to override dataset and policy options from the command line.

## Export

The remote inference server expects a complete `pretrained_model` directory with
at least:

```text
config.json
model.safetensors
policy_preprocessor.json
policy_postprocessor.json
train_config.json
```

Large files should be published through the Hugging Face Model Hub or copied to
the inference machine through private infrastructure. They should not enter this
Git repository.
