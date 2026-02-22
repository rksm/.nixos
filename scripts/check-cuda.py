#!/usr/bin/env -S nix develop /etc/nixos#cuda --command python3
"""Check if CUDA is available and NVIDIA drivers are ready for AI/ML workloads."""

import subprocess
import sys


def check_nvidia_smi():
    """Check nvidia-smi output."""
    try:
        result = subprocess.run(
            ["nvidia-smi"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            print("FAIL: nvidia-smi returned non-zero exit code")
            print(result.stderr.strip())
            return False
        print("OK: nvidia-smi")
        for line in result.stdout.strip().splitlines()[:4]:
            print(f"  {line}")
        return True
    except FileNotFoundError:
        print("FAIL: nvidia-smi not found")
        return False
    except subprocess.TimeoutExpired:
        print("FAIL: nvidia-smi timed out")
        return False


def check_torch_cuda():
    """Check PyTorch CUDA support."""
    try:
        import torch

        print(f"OK: PyTorch {torch.__version__}")
        if not torch.cuda.is_available():
            print("FAIL: torch.cuda.is_available() returned False")
            return False
        print(f"OK: CUDA available (version {torch.version.cuda})")
        count = torch.cuda.device_count()
        print(f"OK: {count} CUDA device(s)")
        for i in range(count):
            name = torch.cuda.get_device_name(i)
            mem = torch.cuda.get_device_properties(i).total_mem / (1024**3)
            print(f"  [{i}] {name} ({mem:.1f} GB)")

        # Quick compute test
        x = torch.randn(256, 256, device="cuda")
        y = torch.matmul(x, x)
        y.cpu()
        print("OK: CUDA compute test passed")
        return True
    except ImportError:
        print("SKIP: PyTorch not installed")
        return None
    except Exception as e:
        print(f"FAIL: PyTorch CUDA test: {e}")
        return False


def check_tensorflow_cuda():
    """Check TensorFlow GPU support."""
    try:
        import tensorflow as tf

        print(f"OK: TensorFlow {tf.__version__}")
        gpus = tf.config.list_physical_devices("GPU")
        if not gpus:
            print("FAIL: TensorFlow found no GPUs")
            return False
        print(f"OK: TensorFlow sees {len(gpus)} GPU(s)")
        for gpu in gpus:
            print(f"  {gpu.name}")
        return True
    except ImportError:
        print("SKIP: TensorFlow not installed")
        return None
    except Exception as e:
        print(f"FAIL: TensorFlow GPU test: {e}")
        return False


def main():
    print("=== CUDA Readiness Check ===\n")

    results = {}

    print("--- NVIDIA Driver ---")
    results["nvidia-smi"] = check_nvidia_smi()
    print()

    print("--- PyTorch ---")
    results["torch"] = check_torch_cuda()
    print()

    print("--- TensorFlow ---")
    results["tensorflow"] = check_tensorflow_cuda()
    print()

    # Summary
    print("=== Summary ===")
    failures = [k for k, v in results.items() if v is False]
    passes = [k for k, v in results.items() if v is True]
    skips = [k for k, v in results.items() if v is None]

    if passes:
        print(f"  Passed: {', '.join(passes)}")
    if skips:
        print(f"  Skipped: {', '.join(skips)}")
    if failures:
        print(f"  Failed: {', '.join(failures)}")
        sys.exit(1)

    if not passes:
        print("  No frameworks available to test CUDA")
        sys.exit(1)

    print("\nCUDA is ready for AI/ML workloads.")


if __name__ == "__main__":
    main()
