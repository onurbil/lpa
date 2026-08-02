#!/usr/bin/env bash

if command -v nvidia-smi >/dev/null 2>&1; then

    echo "GPU: NVIDIA"

    nvidia-smi \
      --query-gpu=name,utilization.gpu,memory.used,memory.total \
      --format=csv,noheader,nounits


elif command -v rocm-smi >/dev/null 2>&1; then

    echo "GPU: AMD ROCm"

    rocm-smi \
      --showuse \
      --showmemuse


elif command -v xpu-smi >/dev/null 2>&1; then

    echo "GPU: Intel"

    xpu-smi dump \
      -m 0 \
      | grep -i "GPU Utilization"


elif command -v intel_gpu_top >/dev/null 2>&1; then

	OUTPUT=$(timeout 0.5 intel_gpu_top -J 2>/dev/null || true)

    echo "GPU: Intel Iris"

    USAGE=$(echo "$OUTPUT" \
        | awk '
            /"Render\/3D"/ {render=1}
            render && /"busy"/ {
                match($0, /[0-9]+\.[0-9]+/, a)
                print a[0]
                exit
            }
        ')

    if [[ -n "$USAGE" ]]; then
        printf "Usage: %.1f%%\n" "$USAGE"
    else
        echo "Unable to read GPU usage"
    fi
        

elif command -v radeontop >/dev/null 2>&1; then

    echo "GPU: AMD"

    radeontop \
      -d - \
      -l 1 \
      | grep -i "gpu"


else

    echo "No GPU monitoring tool installed"

fi
