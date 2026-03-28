#!/usr/bin/env python3
"""build_index.py - 扫描所有记忆文件的 frontmatter，重建 MEMORY.md 索引"""

import sys

if sys.version_info < (3, 9):
    print("❌ 需要 Python 3.9+，当前版本:", sys.version)
    print("  安装: brew install python3 (macOS) / sudo apt install python3 (Linux)")
    sys.exit(1)

import re
from datetime import datetime
from pathlib import Path
from collections import defaultdict


def extract_frontmatter(filepath: Path) -> dict:
    """从 markdown 文件中提取 frontmatter 字段"""
    text = filepath.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?\n)---", text, re.DOTALL)
    if not match:
        return {}

    fields = {}
    for line in match.group(1).splitlines():
        m = re.match(r"^(\w+):\s*(.*)", line)
        if m:
            key, val = m.group(1), m.group(2).strip()
            # 去除引号
            val = val.strip("\"'")
            # 解析 tags 数组 [a, b, c]
            if key == "tags" and val.startswith("["):
                val = [t.strip().strip("\"'") for t in val.strip("[]").split(",") if t.strip()]
            fields[key] = val
    return fields


def build_index_line(filename: str, meta: dict, subdir: str) -> str:
    """构造一条索引行"""
    name = filename.removesuffix(".md")
    summary = meta.get("summary", name)
    tags = meta.get("tags", [])
    importance = meta.get("importance", "")

    parts = [f"- [{name}]({subdir}/{filename}) — {summary}"]
    if tags:
        parts.append(f" [{', '.join(tags)}]")
    if importance:
        parts.append(f" ({importance})")
    return "".join(parts)


def main():
    memory_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / ".openclaw/workspace/memory"
    active_dir = memory_dir / "active"
    archive_dir = memory_dir / "archive"
    index_file = memory_dir / "MEMORY.md"

    print(f"🔄 重建 Memory 索引: {memory_dir}")

    # --- 收集 active 记忆 ---
    type_groups = defaultdict(list)  # type -> [index_line]
    project_groups = defaultdict(list)  # project -> [index_line]
    active_count = 0

    if active_dir.is_dir():
        for f in sorted(active_dir.glob("*.md")):
            meta = extract_frontmatter(f)
            if not meta:
                continue

            line = build_index_line(f.name, meta, "active")
            mem_type = meta.get("type", "log")
            type_groups[mem_type].append(line)

            project = meta.get("project", "")
            if project:
                project_groups[project].append(line)

            active_count += 1

    # --- 收集 archive 摘要 ---
    archives = []
    archive_count = 0

    if archive_dir.is_dir():
        for f in sorted(archive_dir.glob("*.md")):
            meta = extract_frontmatter(f)
            summary = meta.get("summary", "")
            if not summary:
                # 尝试从文件前 5 行找 > 开头的摘要
                lines = f.read_text(encoding="utf-8").splitlines()[:5]
                for line in lines:
                    if line.startswith(">"):
                        summary = line.lstrip("> ").strip()
                        break
            if not summary:
                summary = f.name
            name = f.name.removesuffix(".md")
            archives.append(f"- [{name}](archive/{f.name}) — {summary}")
            archive_count += 1

    # --- 生成 MEMORY.md ---
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    lines = [
        "# Memory Index",
        "",
        f"> Last updated: {now} | Active: {active_count} | Archived: {archive_count}",
        "",
        "---",
        "",
        "## By Type",
        "",
    ]

    type_order = ["decision", "learning", "preference", "context", "log"]
    type_labels = {
        "decision": "Decisions",
        "learning": "Learnings",
        "preference": "Preferences",
        "context": "Contexts",
        "log": "Logs",
    }

    has_any = False
    for t in type_order:
        if t in type_groups:
            lines.append(f"### {type_labels[t]}")
            lines.extend(type_groups[t])
            lines.append("")
            has_any = True

    if not has_any:
        lines.append("_No active memories yet._")
        lines.append("")

    lines.extend(["---", "", "## By Project", ""])

    if project_groups:
        for proj in sorted(project_groups):
            lines.append(f"### {proj}")
            lines.extend(project_groups[proj])
            lines.append("")
    else:
        lines.append("_No project-linked memories yet._")
        lines.append("")

    lines.extend(["---", "", "## Archived", ""])

    if archives:
        lines.extend(archives)
        lines.append("")
    else:
        lines.append("_No archives yet._")
        lines.append("")

    index_file.write_text("\n".join(lines), encoding="utf-8")
    print(f"✅ 索引重建完成: Active={active_count}, Archived={archive_count}")


if __name__ == "__main__":
    main()
