# lpa

**lpa** is a lightweight command-line package manager and launcher for **llama.cpp** and **stable-diffusion.cpp**.

It builds the selected project **locally from source**, allowing you to use the latest upstream versions while taking advantage of hardware-specific optimizations. lpa provides a unified interface to build, update, download models, and run local language and image generation models.

## Features

- Build **llama.cpp** and **stable-diffusion.cpp** locally
- Download and manage GGUF models from Hugging Face
- Run local LLMs with a simple command
- Generate images using Stable Diffusion
- Keep upstream projects up to date
- Monitor running inference processes and GPU utilization
- Lightweight terminal-based workflow

---

## Installation

```bash
git clone https://github.com/onurbil/lpa.git
cd lpa
./install.sh
```

---

## Quick Start

### List downloaded llama.cpp models

Lists all llama.cpp models stored in the model directory:

`~/.cache/huggingface/hub`

```bash
lpa list
```

### List downloaded Stable Diffusion models

Lists all Stable Diffusion models stored in the model directory:

`~/.cache/stable-diffusion/models`

```bash
lpa list
```

### Download a language model

```bash
lpa pull bartowski/Qwen3-8B-GGUF Qwen3-8B-Q4_K_M.gguf
```

### Run a language model

```bash
lpa run Qwen3-8B-Q4_K_M.gguf
```

### Start the inference server

```bash
lpa serve Qwen3-8B-Q4_K_M.gguf
```

### Update llama.cpp to the latest upstream versions

```bash
lpa update
```

### Update stable-diffusion.cpp to the latest upstream versions

```bash
lpa sd update
```

### Monitor running models

```bash
lpa ps
```

---

## Repository Structure

```text
lpa/
├── install/                    ← built llama.cpp binaries
├── install_sd/                 ← built stable-diffusion.cpp binaries
├── llama.cpp/                  ← llama.cpp source
├── stable-diffusion.cpp/       ← stable-diffusion.cpp source
├── scripts/
│   ├── gpu-monitor.sh
│   ├── ...
│   └── update_sd.sh
├── install.sh
├── lpa                         ← main executable
└── README.md
```

