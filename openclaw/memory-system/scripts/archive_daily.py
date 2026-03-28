#!/usr/bin/env python3
"""archive_daily.py - 归档超过 7 天的 type:log 记忆，按周合并到 archive/"""

import sys

if sys.version_info < (3, 9):
    print("❌ 需要 Python 3.9+，当前版本:", sys.version)
    print("  安装: brew install python3 (macOS) / sudo apt install python3 (Linux)")
    sys.exit(1)

import subprocess
from datetime import date, datetime, timedelta
from pathlib import Path
from collections import defaultdict

# 复用 build_index 的 frontmatter 解析
sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_index import extract_frontmatter


def get_week_id(date_str: str) -> str:
    """返回 ISO 周标识，如 2026-W11"""
    try:
        d = date.fromisoformat(date_str)
        return f"{d.isocalendar()[0]}-W{d.isocalendar()[1]:02d}"
    except ValueError:
        return "unknown"


def main():
    memory_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / ".openclaw/workspace/memory"
    active_dir = memory_dir / "active"
    archive_dir = memory_dir / "archive"
    script_dir = Path(__file__).resolve().parent

    print(f"📦 归档 Memory: {memory_dir}")
    print("   规则: type=log 且创建超过 7 天")
    print()

    archive_dir.mkdir(parents=True, exist_ok=True)

    cutoff = date.today() - timedelta(days=7)
    week_entries = defaultdict(list)  # week_id -> [(filepath, meta)]
    archived_count = 0

    if active_dir.is_dir():
        for f in sorted(active_dir.glob("*.md")):
            meta = extract_frontmatter(f)
            if meta.get("type") != "log":
                continue

            created_str = meta.get("created", "")
            if not created_str:
                continue

            try:
                created = date.fromisoformat(created_str)
            except ValueError:
                continue

            if created > cutoff:
                continue

            week_id = get_week_id(created_str)
            week_entries[week_id].append((f, meta))
            archived_count += 1
            print(f"  📋 归档: {f.name} → archive/{week_id}.md")

    if archived_count == 0:
        print("  ⏭️  没有需要归档的文件")
        return

    # 生成周归档文件
    for week_id, entries in sorted(week_entries.items()):
        archive_file = archive_dir / f"{week_id}.md"

        summaries = []
        for filepath, meta in entries:
            summary = meta.get("summary", filepath.name)
            created = meta.get("created", "")
            summaries.append(f"- {created}: {summary}")

        if not archive_file.exists():
            # 创建新归档文件
            parts = [
                "---",
                "type: archive",
                f"week: {week_id}",
                f'summary: "Week {week_id} archive"',
                f"created: {date.today().isoformat()}",
                "---",
                "",
                f"# Archive: {week_id}",
                "",
                "## Summary",
                "",
                *summaries,
                "",
                "---",
                "",
                "## Entries",
                "",
            ]
            content = "\n".join(parts)
        else:
            # 追加到已有归档
            content = archive_file.read_text(encoding="utf-8")
            content += "\n" + "\n".join(summaries) + "\n\n---\n\n"

        # 追加每条记忆的完整内容
        for filepath, meta in entries:
            content += f"### {filepath.name}\n\n"
            content += filepath.read_text(encoding="utf-8")
            content += "\n\n---\n\n"
            filepath.unlink()

        archive_file.write_text(content, encoding="utf-8")
        print(f"  ✅ 生成归档: archive/{week_id}.md")

    print(f"\n✅ 归档完成: {archived_count} 条记忆已归档")

    # 重建索引
    print("\n🔄 重建索引...")
    subprocess.run(
        [sys.executable, str(script_dir / "build_index.py"), str(memory_dir)],
        check=True,
    )


if __name__ == "__main__":
    main()
