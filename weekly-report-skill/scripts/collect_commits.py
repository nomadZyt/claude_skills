import subprocess
import os
from typing import List, Dict, Tuple, Optional
from datetime import datetime, timedelta

def get_git_config(repo_path: str) -> Tuple[Optional[str], Optional[str]]:
    """从目标仓库获取git配置的用户名和邮箱"""
    try:
        # 获取用户名
        name_result = subprocess.run(
            ['git', '-C', repo_path, 'config', 'user.name'],
            capture_output=True, text=True
        )

        # 获取邮箱
        email_result = subprocess.run(
            ['git', '-C', repo_path, 'config', 'user.email'],
            capture_output=True, text=True
        )

        name = name_result.stdout.strip() if name_result.returncode == 0 else None
        email = email_result.stdout.strip() if email_result.returncode == 0 else None

        return name, email
    except Exception as e:
        print(f"获取git配置失败: {e}")
        return None, None

def get_commits(repo_path: str, author_email: str = None, since: datetime = None) -> List[Dict]:
    """获取指定作者的 git commit，包含文件路径信息
    只收集【用户本人】的提交记录，基于git配置的邮箱进行过滤

    Args:
        repo_path: 仓库路径
        author_email: 作者邮箱，如果为None则从仓库配置自动获取
        since: 起始时间，默认为7天前
    """
    # 如果没有指定作者邮箱，从仓库配置获取
    if author_email is None:
        _, email = get_git_config(repo_path)
        if email is None:
            raise ValueError("无法获取仓库git配置中的用户邮箱，请确保仓库已配置user.email")
        author_email = email
        print(f"从仓库配置获取作者邮箱: {author_email}")
    else:
        print(f"使用指定的作者邮箱: {author_email}")

    # 如果没有指定时间范围，默认获取最近7天
    if since is None:
        since = datetime.now() - timedelta(days=7)
        print(f"获取时间范围: {since.strftime('%Y-%m-%d')} 至今")

    # 构建 git log 命令
    cmd = [
        'git', '-C', repo_path, 'log', '--author=' + author_email,
        '--pretty=format:%H||%an||%ae||%ad||%s',
        '--name-only'
    ]
    
    # 如果指定了时间范围，添加 --since 参数
    if since:
        cmd.extend(['--since', since.strftime('%Y-%m-%d')])
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    commits = []
    lines = result.stdout.strip().split('\n')
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
            
        # 解析 commit 信息
        if '||' in line:
            parts = line.split('||')
            if len(parts) >= 5:
                hash_, name, email, date, message = parts[0], parts[1], parts[2], parts[3], '||'.join(parts[4:])
                
                # 收集该 commit 涉及的文件路径
                paths = []
                i += 1
                while i < len(lines) and lines[i].strip() and '||' not in lines[i]:
                    path = lines[i].strip()
                    if path:  # 忽略空行
                        paths.append(path)
                    i += 1
                
                # 二次验证：确保邮箱完全匹配（防止部分匹配问题）
                if email.lower() == author_email.lower():
                    commits.append({
                        'hash': hash_,
                        'author': name,
                        'email': email,
                        'date': date,
                        'message': message,
                        'paths': paths
                    })
                else:
                    # 这种情况理论上不应该出现，但作为保险
                    print(f"警告: 跳过不匹配的提交 {hash_[:8]} (邮箱: {email}, 期望: {author_email})")
                continue
        i += 1
    
    return commits

if __name__ == '__main__':
    import sys
    import json

    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("使用方法: python collect_commits.py <仓库路径> [作者邮箱]")
        print("示例: python collect_commits.py /path/to/repo")
        print("      python collect_commits.py /path/to/repo user@example.com")
        print("")
        print("说明:")
        print("  - 如果不指定作者邮箱，将自动从仓库git配置中获取")
        print("  - 默认获取最近7天内的提交记录")
        print("  - 只收集【用户本人】的commit，基于邮箱严格匹配")
        print("  - commits_data.json 将保存到weekly-report-skill目录下")
        sys.exit(1)

    repo_path = sys.argv[1]
    author_email = sys.argv[2] if len(sys.argv) == 3 else None

    # 获取提交记录，如果未指定作者和时间，函数内部会自动设置默认值
    commits = get_commits(repo_path, author_email)

    print(f"找到 {len(commits)} 个提交记录")

    # 确定输出文件路径 - 保存到skill目录下
    # 获取当前脚本所在目录的上级目录（即skill目录）
    script_dir = os.path.dirname(os.path.abspath(__file__))
    skill_dir = os.path.dirname(script_dir)  # 上级目录
    output_file = os.path.join(skill_dir, "commits_data.json")

    # 输出JSON格式的数据到skill目录
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(commits, f, ensure_ascii=False, indent=2)

    print(f"提交数据已保存到: {output_file}")

    # 同时打印到控制台
    for c in commits:
        print(f"[{c['date']}] {c['message']} ({len(c['paths'])} files)")