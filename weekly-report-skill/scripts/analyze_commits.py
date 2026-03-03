import json
import re
from typing import List, Dict, Optional
from collections import defaultdict
from pathlib import Path


# 工作类型分类规则（基于 CLASSIFICATION.md）
CLASSIFICATION_RULES = {
    '需求开发': {
        'keywords': ['feat', 'feature', '新增', '支持', 'add', 'implement', 'feat', 'init'],
        'description': '直接交付业务能力或用户功能'
    },
    'Bug 修复': {
        'keywords': ['fix', 'bug', '修复', '问题', 'issue', 'bugfix'],
        'description': '修复已知问题或线上缺陷'
    },
    '技术债 / 重构 / 优化': {
        'keywords': ['refactor', 'optimize', 'clean', '重构', '优化', '改进', 'improve'],
        'description': '不直接改变业务能力，提升代码质量、结构或性能'
    },
    '支撑性工作': {
        'keywords': ['配置', 'CI', '脚手架', '依赖升级', 'config', 'setup', 'upgrade', 'deps'],
        'description': '为业务或团队提供保障，但不直接交付功能'
    },
    '协作 / 合并': {
        'keywords': ['merge', 'sync', 'chore', '合并', '同步'],
        'description': '非主要产出型工作'
    }
}


# 兜底映射规则（基于 MODULE_MAPPING.md）
FALLBACK_MAPPING = {
    'NFC 挪车码': {
        'repo_contains': ['nfc'],
        'path_contains': ['/nfc/']
    }
}


def classify_commit(commit_message: str, paths: List[str] = None) -> str:
    """
    分类 commit 的工作类型
    
    Args:
        commit_message: commit 消息
        paths: 涉及的文件路径列表
    
    Returns:
        工作类型分类
    """
    message_lower = commit_message.lower()
    
    # 按优先级检查分类规则
    for category, rule in CLASSIFICATION_RULES.items():
        for keyword in rule['keywords']:
            if keyword.lower() in message_lower:
                return category
    
    # 根据路径特征判断（可选）
    if paths:
        path_str = ' '.join(paths).lower()
        # 如果涉及配置文件、CI 文件等，可能是支撑性工作
        if any(kw in path_str for kw in ['config', 'ci', '.yml', '.yaml', 'package.json', 'requirements.txt']):
            return '支撑性工作'
    
    # 默认归类为支撑性工作
    return '支撑性工作'


def identify_project(commit: Dict, fallback_mapping: Dict = None) -> str:
    """
    识别项目名称（基于 MODULE_MAPPING.md 规则）
    
    优先级：
    1. 仓库名 = 项目名（最高优先级）
    2. 仓库内主目录名
    3. commit message 中的显式关键词
    4. 兜底映射规则
    
    Args:
        commit: commit 字典，包含 repo, paths, message
        fallback_mapping: 兜底映射规则
    
    Returns:
        项目名称
    """
    repo = commit.get('repo', '')
    paths = commit.get('paths', [])
    message = commit.get('message', '')
    
    # 优先级1: 仓库名直接作为项目名（默认策略）
    if repo:
        # 先检查兜底映射
        if fallback_mapping:
            for project_name, rules in fallback_mapping.items():
                # 检查仓库名是否匹配
                if any(keyword in repo.lower() for keyword in rules.get('repo_contains', [])):
                    return project_name
                # 检查路径是否匹配
                if any(keyword in '/'.join(paths).lower() for keyword in rules.get('path_contains', [])):
                    return project_name
        
        # 如果没有匹配兜底规则，使用仓库名
        return repo
    
    # 优先级2: 从路径提取主目录名
    if paths:
        main_dirs = set()
        for path in paths:
            parts = Path(path).parts
            if len(parts) > 0:
                main_dirs.add(parts[0])
        if main_dirs:
            # 返回最常见的目录名
            return list(main_dirs)[0]
    
    # 优先级3: 从 commit message 提取（简单实现）
    # 这里可以扩展更复杂的提取逻辑
    
    return '未知项目'


def should_merge_commit(commit: Dict) -> bool:
    """
    判断是否应该合并或弱化显示的 commit
    """
    category = commit.get('category', '')
    message = commit.get('message', '').lower()
    
    # 协作/合并类默认弱化
    if category == '协作 / 合并':
        return True
    
    # merge/sync/chore 类提交
    if any(kw in message for kw in ['merge', 'sync', 'chore', '合并', '同步']):
        return True
    
    return False


def deduplicate_and_merge(commits: List[Dict]) -> List[Dict]:
    """
    去噪和合并相似的 commits
    
    Args:
        commits: 原始 commits 列表
    
    Returns:
        处理后的 commits 列表
    """
    # 按项目和工作类型分组
    grouped = defaultdict(list)
    
    for commit in commits:
        # 跳过应该合并的 commit（可选：可以合并显示）
        if should_merge_commit(commit):
            # 仍然保留，但标记为弱化
            commit['_weak'] = True
        else:
            commit['_weak'] = False
        
        key = (commit.get('project', ''), commit.get('category', ''))
        grouped[key].append(commit)
    
    # 对于同一项目同一类型的多个 commits，可以合并描述
    merged_commits = []
    for (project, category), group_commits in grouped.items():
        if len(group_commits) == 1:
            merged_commits.append(group_commits[0])
        else:
            # 多个 commits 可以合并为一个条目
            # 这里保留所有，但在渲染时可以合并显示
            merged_commits.extend(group_commits)
    
    return merged_commits


def enrich_commits(commits: List[Dict], fallback_mapping: Dict = None, repo_paths_map: Dict[str, str] = None) -> List[Dict]:
    """
    丰富 commits 信息：项目识别、工作分类、代码流程梳理、价值抽象
    
    Args:
        commits: 原始 commits 列表
        fallback_mapping: 兜底映射规则
        repo_paths_map: 仓库路径映射 {repo_name: repo_path}
    
    Returns:
        丰富后的 commits 列表
    """
    enriched = []
    
    for commit in commits:
        # 项目识别
        commit['project'] = identify_project(commit, fallback_mapping)
        
        # 工作分类
        commit['category'] = classify_commit(
            commit.get('message', ''),
            commit.get('paths', [])
        )
        
        # 代码流程梳理（包含关键代码提取）
        repo_name = commit.get('repo', '')
        repo_path = repo_paths_map.get(repo_name, None) if repo_paths_map else None
        code_flow_info = extract_code_flow(commit, repo_path)
        commit['code_flow'] = code_flow_info.get('description', '')
        commit['code_snippets'] = code_flow_info.get('code_snippets', [])
        
        # 价值抽象
        commit['value'] = abstract_value(commit)
        
        enriched.append(commit)
    
    # 去噪和合并
    enriched = deduplicate_and_merge(enriched)
    
    return enriched


def extract_code_snippets(commit: Dict, repo_path: str = None) -> List[Dict]:
    """
    从 commit 中提取关键代码片段
    
    Args:
        commit: commit 字典，包含 hash, paths, message
        repo_path: 仓库路径（用于读取文件内容）
    
    Returns:
        代码片段列表，每个片段包含 {file, lines, code}
    """
    import subprocess
    
    snippets = []
    commit_hash = commit.get('hash', '')
    paths = commit.get('paths', [])
    
    if not commit_hash or not paths or not repo_path:
        return snippets
    
    # 只处理代码文件（排除配置文件、样式文件等）
    code_extensions = ['.js', '.jsx', '.ts', '.tsx', '.py', '.java', '.go', '.rs', '.cpp', '.c']
    code_files = [p for p in paths if any(p.endswith(ext) for ext in code_extensions)]
    
    # 限制处理文件数量，避免过多
    for file_path in code_files[:3]:  # 最多处理3个文件
        try:
            # 使用 git show 获取该文件在此 commit 中的变更
            cmd = ['git', '-C', repo_path, 'show', f'{commit_hash}:{file_path}']
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
            
            if result.returncode == 0 and result.stdout:
                code = result.stdout
                # 提取关键代码片段（函数定义、类定义等）
                lines = code.split('\n')
                
                # 查找关键代码：函数定义、类定义、重要逻辑
                key_lines = []
                for i, line in enumerate(lines[:100], 1):  # 只处理前100行
                    stripped = line.strip()
                    # 查找函数/方法定义
                    if any(stripped.startswith(kw) for kw in ['function ', 'const ', 'export ', 'class ', 'def ', 'async ']):
                        # 提取函数及其后续几行（最多5行）
                        snippet_lines = lines[i-1:min(i+4, len(lines))]
                        if snippet_lines:
                            key_lines.append({
                                'line_num': i,
                                'code': '\n'.join(snippet_lines[:5])  # 最多5行
                            })
                            if len(key_lines) >= 2:  # 最多提取2个关键片段
                                break
                
                if key_lines:
                    snippets.append({
                        'file': Path(file_path).name,
                        'file_path': file_path,
                        'snippets': key_lines
                    })
        except Exception:
            # 如果读取失败，跳过该文件
            continue
    
    return snippets


def extract_code_flow(commit: Dict, repo_path: str = None) -> Dict:
    """
    梳理 commit 的代码流程，提取关键代码信息
    
    Args:
        commit: commit 字典，包含 hash, paths, message
        repo_path: 仓库路径（可选，用于读取文件内容）
    
    Returns:
        包含流程描述和代码片段的字典
    """
    paths = commit.get('paths', [])
    message = commit.get('message', '')
    
    if not paths:
        return {'description': '', 'code_snippets': []}
    
    # 分析文件路径，提取关键信息
    flow_parts = []
    
    # 按文件类型分类
    components = [p for p in paths if any(kw in p.lower() for kw in ['component', 'page', 'view'])]
    utils = [p for p in paths if any(kw in p.lower() for kw in ['util', 'helper', 'tool', 'service', 'api'])]
    configs = [p for p in paths if any(kw in p.lower() for kw in ['config', 'constant', 'setting'])]
    styles = [p for p in paths if any(kw in p.lower() for kw in ['.css', '.scss', '.less', 'style'])]
    
    if components:
        flow_parts.append(f"组件/页面: {', '.join([Path(p).name for p in components[:3]])}")
    if utils:
        flow_parts.append(f"工具/服务: {', '.join([Path(p).name for p in utils[:3]])}")
    if configs:
        flow_parts.append(f"配置: {', '.join([Path(p).name for p in configs[:2]])}")
    
    # 从 commit message 提取关键信息
    if 'feat' in message.lower() or '新增' in message:
        flow_parts.append("新增功能实现")
    elif 'fix' in message.lower() or '修复' in message:
        flow_parts.append("问题修复")
    elif 'refactor' in message.lower() or '重构' in message:
        flow_parts.append("代码重构")
    
    description = " | ".join(flow_parts) if flow_parts else "代码修改"
    
    # 提取关键代码片段（如果提供了仓库路径）
    code_snippets = []
    if repo_path:
        code_snippets = extract_code_snippets(commit, repo_path)
    
    return {
        'description': description,
        'code_snippets': code_snippets
    }


def abstract_value(commit: Dict) -> str:
    """
    对 commit 进行价值抽象，提取业务价值
    
    Args:
        commit: commit 字典，包含 category, message, paths
    
    Returns:
        价值描述字符串
    """
    category = commit.get('category', '')
    message = commit.get('message', '')
    paths = commit.get('paths', [])
    
    # 根据分类和价值关键词提取价值
    value_keywords = {
        '需求开发': ['功能', '支持', '新增', '实现', '优化体验', '提升'],
        'Bug 修复': ['修复', '解决', '改进', '提升稳定性'],
        '技术债 / 重构 / 优化': ['优化', '提升', '改进', '增强'],
        '支撑性工作': ['保障', '支持', '提升效率']
    }
    
    # 从 message 中提取价值描述
    message_lower = message.lower()
    
    # 尝试提取中文价值描述
    if category == '需求开发':
        if any(kw in message for kw in ['支持', '新增', '增加', '实现', '优化体验', '提升', 'feat', 'feature', 'init', 'implement']):
            # 提取功能描述
            for kw in ['支持', '新增', '增加', '实现', '优化', 'feat', 'feature', 'init', 'implement']:
                if kw in message:
                    idx = message.find(kw)
                    # 提取后续的描述
                    desc = message[idx:idx+50] if len(message) > idx+50 else message[idx:]
                    return desc.strip()
        return "交付新功能，提升用户体验"
    
    elif category == 'Bug 修复':
        if '修复' in message or 'fix' in message_lower:
            return "修复问题，提升系统稳定性"
        return "解决已知问题"
    
    elif category == '技术债 / 重构 / 优化':
        if '优化' in message or 'optimize' in message_lower:
            return "优化代码结构，提升可维护性"
        elif '重构' in message or 'refactor' in message_lower:
            return "重构代码，提升代码质量"
        return "技术优化，提升系统性能"
    
    elif category == '支撑性工作':
        return "支撑业务发展，提升开发效率"
    
    return "完成开发工作"


def group_by_project_and_category(commits: List[Dict]) -> Dict[str, Dict[str, List[Dict]]]:
    """
    按项目和分类分组 commits
    
    Returns:
        {项目名: {分类: [commits]}}
    """
    grouped = defaultdict(lambda: defaultdict(list))
    
    for commit in commits:
        project = commit.get('project', '未知项目')
        category = commit.get('category', '未知分类')
        grouped[project][category].append(commit)
    
    return dict(grouped)


def extract_commit_diff(commit: Dict, repo_path: str = None) -> List[Dict]:
    """
    提取commit的diff信息，包含具体的代码变更对比

    Args:
        commit: commit 字典，包含 hash
        repo_path: 仓库路径

    Returns:
        diff信息列表，每个包含 {file, additions, deletions, diff_content}
    """
    import subprocess

    diff_info = []
    commit_hash = commit.get('hash', '')

    if not commit_hash or not repo_path:
        return diff_info

    try:
        # 获取该commit的diff信息
        cmd = ['git', '-C', repo_path, 'show', '--stat', '--format=', commit_hash]
        stat_result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)

        # 获取详细的diff内容
        diff_cmd = ['git', '-C', repo_path, 'show', '--no-merges', commit_hash]
        diff_result = subprocess.run(diff_cmd, capture_output=True, text=True, timeout=15)

        if stat_result.returncode == 0 and diff_result.returncode == 0:
            # 解析stat信息
            stat_lines = stat_result.stdout.strip().split('\n')
            file_changes = {}

            for line in stat_lines:
                if '|' in line and ('+' in line or '-' in line):
                    parts = line.split('|')
                    if len(parts) >= 2:
                        file_path = parts[0].strip()
                        changes = parts[1].strip()

                        # 解析添加和删除的行数
                        additions = changes.count('+')
                        deletions = changes.count('-')

                        file_changes[file_path] = {
                            'additions': additions,
                            'deletions': deletions,
                            'changes': changes
                        }

            # 解析diff内容
            diff_content = diff_result.stdout

            # 按文件分组diff内容
            file_diffs = {}
            current_file = None
            current_diff = []

            for line in diff_content.split('\n'):
                if line.startswith('diff --git'):
                    # 保存上一个文件的diff
                    if current_file and current_diff:
                        file_diffs[current_file] = '\n'.join(current_diff)

                    # 解析新文件路径
                    parts = line.split()
                    if len(parts) >= 4:
                        current_file = parts[3][2:]  # 移除 'b/' 前缀
                        current_diff = []
                elif current_file:
                    # 只保留有意义的diff行（跳过文件头信息）
                    if line.startswith('@@') or line.startswith('+') or line.startswith('-'):
                        current_diff.append(line)
                    elif line.startswith('index') or line.startswith('---') or line.startswith('+++'):
                        continue  # 跳过文件元信息
                    else:
                        current_diff.append(line)

            # 保存最后一个文件的diff
            if current_file and current_diff:
                file_diffs[current_file] = '\n'.join(current_diff)

            # 合并stat和diff信息
            for file_path, stats in file_changes.items():
                diff_content = file_diffs.get(file_path, '')

                # 提取关键的diff片段（最多前50行）
                diff_lines = diff_content.split('\n')[:50] if diff_content else []

                diff_info.append({
                    'file': Path(file_path).name,
                    'file_path': file_path,
                    'additions': stats['additions'],
                    'deletions': stats['deletions'],
                    'changes_summary': stats['changes'],
                    'diff_preview': '\n'.join(diff_lines) if diff_lines else ''
                })

    except Exception as e:
        print(f"⚠️ 获取commit {commit_hash[:8]} 的diff信息失败: {e}")

    return diff_info


if __name__ == '__main__':
    import sys
    import os
    from datetime import datetime

    # 修改参数处理，支持基于commits_data.json或直接指定仓库路径
    if len(sys.argv) < 2:
        print("使用方法:")
        print("  python analyze_commits.py <仓库路径>")
        print("  - 将基于已存在的 commits_data.json 进行分析")
        print("  - 如果 commits_data.json 不存在，请先运行 collect_commits.py")
        print("")
        print("输出:")
        print("  - analysis_result_with_diff.json 保存到 skill 目录")
        sys.exit(1)

    repo_path = sys.argv[1]

    # 确定skill目录路径
    script_dir = os.path.dirname(os.path.abspath(__file__))
    skill_dir = os.path.dirname(script_dir)
    commits_data_file = os.path.join(skill_dir, "commits_data.json")

    print("🔍 开始分析Git提交记录...")

    # 检查commits_data.json是否存在
    if not os.path.exists(commits_data_file):
        print(f"❌ 未找到 {commits_data_file}")
        print("请先运行 collect_commits.py 收集提交数据")
        sys.exit(1)

    # 读取commits数据
    print(f"📊 读取提交数据: {commits_data_file}")
    try:
        with open(commits_data_file, 'r', encoding='utf-8') as f:
            commits_data = json.load(f)
    except Exception as e:
        print(f"❌ 读取commits_data.json失败: {e}")
        sys.exit(1)

    # 添加repo信息
    repo_name = os.path.basename(repo_path)
    for commit in commits_data:
        commit['repo'] = repo_name

    print(f"📊 找到 {len(commits_data)} 个提交记录")

    # 丰富数据，包含diff分析
    print("🔄 正在分析提交数据...")
    enriched = enrich_commits(commits_data, FALLBACK_MAPPING, {repo_name: repo_path})

    # 为每个commit添加diff信息
    print("🔄 正在提取diff信息...")
    for commit in enriched:
        commit['diff_info'] = extract_commit_diff(commit, repo_path)

    # 分组
    grouped = group_by_project_and_category(enriched)

    # 输出分析结果到skill目录
    analysis_file = os.path.join(skill_dir, "analysis_result_with_diff.json")
    result = {
        'commits': enriched,
        'grouped': grouped,
        'stats': {
            'total_commits': len(commits_data),
            'effective_commits': len([c for c in enriched if not c.get('_weak', False)]),
            'projects': list(grouped.keys())
        },
        'analysis_timestamp': datetime.now().isoformat(),
        'repo_analyzed': repo_name
    }

    with open(analysis_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"✅ 分析完成，结果保存到: {analysis_file}")

    # 输出统计信息到控制台
    print(f"📈 统计信息:")
    print(f"  - 总提交数: {result['stats']['total_commits']}")
    print(f"  - 有效提交数: {result['stats']['effective_commits']}")
    print(f"  - 涉及项目: {len(result['stats']['projects'])}")

    for project, categories in grouped.items():
        print(f"\n📁 {project}:")
        for category, commits_list in categories.items():
            effective = len([c for c in commits_list if not c.get('_weak', False)])
            if effective > 0:
                print(f"  • {category}: {effective} 个")

    # 输出简化的JSON数据
    print(f"\n📄 简化输出预览:")
    simplified_result = {
        'stats': result['stats'],
        'projects_summary': {project: list(categories.keys()) for project, categories in grouped.items()}
    }
    print(json.dumps(simplified_result, ensure_ascii=False, indent=2))