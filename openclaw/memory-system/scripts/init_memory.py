#!/usr/bin/env python3
"""init_memory.py - 初始化 OpenClaw Memory 目录结构"""

import sys

if sys.version_info < (3, 9):
    print("❌ 需要 Python 3.9+，当前版本:", sys.version)
    print()
    print("安装方式:")
    print("  macOS:        brew install python3")
    print("  Ubuntu/Debian: sudo apt install python3")
    print("  CentOS/RHEL:  sudo yum install python3")
    print("  Windows:      https://www.python.org/downloads/")
    sys.exit(1)

import os
from datetime import date
from pathlib import Path

def main():
    memory_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / ".openclaw/workspace/memory"
    script_dir = Path(__file__).resolve().parent
    template_dir = script_dir.parent / "templates"

    print(f"📦 初始化 Memory 系统: {memory_dir}")

    (memory_dir / "active").mkdir(parents=True, exist_ok=True)
    (memory_dir / "archive").mkdir(parents=True, exist_ok=True)

    index_file = memory_dir / "MEMORY.md"
    if not index_file.exists():
        template = template_dir / "MEMORY.md.template"
        if template.exists():
            content = template.read_text(encoding="utf-8")
            content = content.replace("{{date}}", date.today().isoformat())
        else:
            content = f"""# Memory Index

> Last updated: {date.today().isoformat()} | Active: 0 | Archived: 0

---

## By Type

_No active memories yet._

---

## By Project

_No project-linked memories yet._

---

## Archived

_No archives yet._
"""
        index_file.write_text(content, encoding="utf-8")
        print("  ✅ 创建 MEMORY.md")
    else:
        print("  ⏭️  MEMORY.md 已存在，跳过")

    print(f"""
✅ Memory 系统初始化完成

目录结构:
  {memory_dir}/
  ├── MEMORY.md      # 索引（会话启动时加载）
  ├── active/        # 活跃记忆
  └── archive/       # 归档记忆

下一步:
  1. 创建第一条记忆: 复制 templates/memory-entry.md.template 到 active/
  2. 重建索引: python3 {script_dir}/build_index.py""")

if __name__ == "__main__":
    main()
