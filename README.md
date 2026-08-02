curl -fsSL https://raw.githubusercontent.com/USERNAME/lpa/main/install.sh | bash

REPO looks like:
lpa/
├── lpa
├── install.sh
├── README.md
└── scripts/
    ├── update.sh
    └── gpu-monitor.sh



lpa/
├── lpa                  ← main executable script
├── install.sh
├── README.md
├── scripts/
│   ├── update.sh
│   └── gpu-monitor.sh
├── llama.cpp/           ← llama.cpp source
└── install/             ← built llama.cpp binaries
