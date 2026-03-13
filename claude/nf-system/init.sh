#!/bin/bash
# nf-init - 在任何项目中初始化 NF 系统
# 用法：./nf-init.sh [项目路径]

set -e

PROJECT_PATH="${1:-.}"

echo "🚀 NF 系统安装程序"
echo "====================="
echo ""

# 确认项目路径
if [ "$PROJECT_PATH" = "." ]; then
    PROJECT_PATH=$(pwd)
fi

echo "目标：$PROJECT_PATH"
echo ""

# ============================================================
# 技术栈自动检测
# ============================================================
detect_tech_stack() {
    local p="$1"
    local tech_stack=""
    local code_standards=""
    local test_standards=""

    # --- 语言/框架检测 ---
    local lang=""
    local framework=""

    if [ -f "$p/package.json" ]; then
        lang="JavaScript/TypeScript"
        # 检测 TypeScript
        if [ -f "$p/tsconfig.json" ]; then
            lang="TypeScript"
        fi
        # 检测前端框架
        if grep -q '"react"' "$p/package.json" 2>/dev/null; then
            framework="React"
        elif grep -q '"vue"' "$p/package.json" 2>/dev/null; then
            framework="Vue"
        elif grep -q '"@angular/core"' "$p/package.json" 2>/dev/null; then
            framework="Angular"
        elif grep -q '"svelte"' "$p/package.json" 2>/dev/null; then
            framework="Svelte"
        elif grep -q '"next"' "$p/package.json" 2>/dev/null; then
            framework="Next.js"
        elif grep -q '"nuxt"' "$p/package.json" 2>/dev/null; then
            framework="Nuxt"
        elif grep -q '"express"' "$p/package.json" 2>/dev/null; then
            framework="Express"
        elif grep -q '"fastify"' "$p/package.json" 2>/dev/null; then
            framework="Fastify"
        elif grep -q '"koa"' "$p/package.json" 2>/dev/null; then
            framework="Koa"
        fi
    elif [ -f "$p/pyproject.toml" ] || [ -f "$p/requirements.txt" ] || [ -f "$p/setup.py" ]; then
        lang="Python"
        if [ -f "$p/pyproject.toml" ]; then
            if grep -q 'django' "$p/pyproject.toml" 2>/dev/null; then
                framework="Django"
            elif grep -q 'fastapi' "$p/pyproject.toml" 2>/dev/null; then
                framework="FastAPI"
            elif grep -q 'flask' "$p/pyproject.toml" 2>/dev/null; then
                framework="Flask"
            fi
        elif [ -f "$p/requirements.txt" ]; then
            if grep -qi 'django' "$p/requirements.txt" 2>/dev/null; then
                framework="Django"
            elif grep -qi 'fastapi' "$p/requirements.txt" 2>/dev/null; then
                framework="FastAPI"
            elif grep -qi 'flask' "$p/requirements.txt" 2>/dev/null; then
                framework="Flask"
            fi
        fi
    elif [ -f "$p/go.mod" ]; then
        lang="Go"
        if grep -q 'gin-gonic' "$p/go.mod" 2>/dev/null; then
            framework="Gin"
        elif grep -q 'echo' "$p/go.mod" 2>/dev/null; then
            framework="Echo"
        elif grep -q 'fiber' "$p/go.mod" 2>/dev/null; then
            framework="Fiber"
        fi
    elif [ -f "$p/Cargo.toml" ]; then
        lang="Rust"
        if grep -q 'actix' "$p/Cargo.toml" 2>/dev/null; then
            framework="Actix"
        elif grep -q 'axum' "$p/Cargo.toml" 2>/dev/null; then
            framework="Axum"
        elif grep -q 'rocket' "$p/Cargo.toml" 2>/dev/null; then
            framework="Rocket"
        fi
    elif [ -f "$p/pom.xml" ] || [ -f "$p/build.gradle" ] || [ -f "$p/build.gradle.kts" ]; then
        lang="Java"
        if grep -q 'spring-boot' "$p/pom.xml" 2>/dev/null || grep -q 'spring-boot' "$p/build.gradle" 2>/dev/null || grep -q 'spring-boot' "$p/build.gradle.kts" 2>/dev/null; then
            framework="Spring Boot"
        fi
    elif [ -f "$p/mix.exs" ]; then
        lang="Elixir"
        if grep -q 'phoenix' "$p/mix.exs" 2>/dev/null; then
            framework="Phoenix"
        fi
    else
        lang="Unknown"
    fi

    # --- CSS 框架检测 ---
    local css_framework=""
    if [ -f "$p/tailwind.config.js" ] || [ -f "$p/tailwind.config.ts" ] || [ -f "$p/tailwind.config.mjs" ]; then
        css_framework="TailwindCSS"
    fi

    # --- 构建工具检测 ---
    local build_tool=""
    if [ -f "$p/vite.config.js" ] || [ -f "$p/vite.config.ts" ] || [ -f "$p/vite.config.mjs" ]; then
        build_tool="Vite"
    elif [ -f "$p/webpack.config.js" ] || [ -f "$p/webpack.config.ts" ]; then
        build_tool="Webpack"
    elif [ -f "$p/next.config.js" ] || [ -f "$p/next.config.ts" ] || [ -f "$p/next.config.mjs" ]; then
        build_tool="Next.js"
    elif [ -f "$p/turbo.json" ]; then
        build_tool="Turborepo"
    elif [ -f "$p/Makefile" ]; then
        build_tool="Make"
    fi

    # --- 包管理器检测 ---
    local pkg_mgr=""
    if [ -f "$p/bun.lockb" ] || [ -f "$p/bun.lock" ]; then
        pkg_mgr="bun"
    elif [ -f "$p/pnpm-lock.yaml" ]; then
        pkg_mgr="pnpm"
    elif [ -f "$p/yarn.lock" ]; then
        pkg_mgr="yarn"
    elif [ -f "$p/package-lock.json" ]; then
        pkg_mgr="npm"
    elif [ -f "$p/Pipfile.lock" ]; then
        pkg_mgr="pipenv"
    elif [ -f "$p/poetry.lock" ]; then
        pkg_mgr="poetry"
    elif [ -f "$p/uv.lock" ]; then
        pkg_mgr="uv"
    fi

    # --- 测试框架检测 ---
    local test_framework=""
    local test_cmd=""
    local coverage_cmd=""
    # Node.js 项目
    if [ -f "$p/package.json" ]; then
        if [ -f "$p/vitest.config.js" ] || [ -f "$p/vitest.config.ts" ] || grep -q '"vitest"' "$p/package.json" 2>/dev/null; then
            test_framework="Vitest"
            test_cmd="${pkg_mgr:-npm} test"
            coverage_cmd="${pkg_mgr:-npm} run coverage"
        elif [ -f "$p/jest.config.js" ] || [ -f "$p/jest.config.ts" ] || grep -q '"jest"' "$p/package.json" 2>/dev/null; then
            test_framework="Jest"
            test_cmd="${pkg_mgr:-npm} test"
            coverage_cmd="${pkg_mgr:-npm} run coverage"
        elif grep -q '"mocha"' "$p/package.json" 2>/dev/null; then
            test_framework="Mocha"
            test_cmd="${pkg_mgr:-npm} test"
        fi
        # E2E 检测
        if grep -q '"playwright"' "$p/package.json" 2>/dev/null || grep -q '"@playwright/test"' "$p/package.json" 2>/dev/null; then
            test_framework="${test_framework:+$test_framework + }Playwright (E2E)"
        elif grep -q '"cypress"' "$p/package.json" 2>/dev/null; then
            test_framework="${test_framework:+$test_framework + }Cypress (E2E)"
        fi
    fi
    # Python 项目
    if [ "$lang" = "Python" ]; then
        if [ -f "$p/pytest.ini" ] || [ -f "$p/pyproject.toml" ] && grep -q 'pytest' "$p/pyproject.toml" 2>/dev/null; then
            test_framework="pytest"
            test_cmd="pytest"
            coverage_cmd="pytest --cov"
        elif [ -f "$p/tox.ini" ]; then
            test_framework="tox + pytest"
            test_cmd="tox"
        else
            test_framework="pytest"
            test_cmd="pytest"
            coverage_cmd="pytest --cov"
        fi
    fi
    # Go 项目
    if [ "$lang" = "Go" ]; then
        test_framework="go test"
        test_cmd="go test ./..."
        coverage_cmd="go test -cover ./..."
    fi
    # Rust 项目
    if [ "$lang" = "Rust" ]; then
        test_framework="cargo test"
        test_cmd="cargo test"
    fi
    # Java 项目
    if [ "$lang" = "Java" ]; then
        if [ -f "$p/pom.xml" ]; then
            test_framework="JUnit (Maven)"
            test_cmd="mvn test"
        elif [ -f "$p/build.gradle" ] || [ -f "$p/build.gradle.kts" ]; then
            test_framework="JUnit (Gradle)"
            test_cmd="./gradlew test"
        fi
    fi

    # --- 组装 tech_stack ---
    tech_stack="- ${lang}"
    if [ -n "$framework" ]; then
        tech_stack="${tech_stack} + ${framework}"
    fi
    if [ -n "$css_framework" ]; then
        tech_stack="${tech_stack}\n- ${css_framework}"
    fi
    if [ -n "$build_tool" ]; then
        tech_stack="${tech_stack}\n- ${build_tool}"
    fi
    if [ -n "$pkg_mgr" ]; then
        tech_stack="${tech_stack}\n- 包管理器：${pkg_mgr}"
    fi

    # --- 组装 code_standards ---
    case "$lang" in
        "TypeScript"|"JavaScript/TypeScript")
            code_standards="- 避免 \`any\` 类型，用 \`unknown\` 或具体类型\n- 优先使用函数式编程风格\n- 测试文件与源码同级或在 \`__tests__/\` 目录"
            ;;
        "Python")
            code_standards="- 遵循 PEP 8 代码风格\n- 使用 type hints\n- docstring 使用 Google 风格"
            ;;
        "Go")
            code_standards="- 遵循 Go 官方代码规范\n- 使用 gofmt / goimports 格式化\n- 导出函数必须有注释"
            ;;
        "Rust")
            code_standards="- 遵循 Rust API Guidelines\n- 使用 clippy 进行代码检查\n- 使用 rustfmt 格式化"
            ;;
        "Java")
            code_standards="- 遵循 Google Java Style Guide\n- 使用 Lombok 减少样板代码（如项目已引入）\n- 接口优先设计"
            ;;
        *)
            code_standards="- 遵循项目已有代码风格\n- 保持一致性\n- 添加必要的注释"
            ;;
    esac

    # --- 组装 test_standards ---
    if [ -n "$test_framework" ]; then
        test_standards="- 测试框架：${test_framework}"
        if [ -n "$test_cmd" ]; then
            test_standards="${test_standards}\n- 运行测试：\`${test_cmd}\`"
        fi
        if [ -n "$coverage_cmd" ]; then
            test_standards="${test_standards}\n- 覆盖率：\`${coverage_cmd}\`"
        fi
    else
        test_standards="- 测试框架：[待配置]\n- 运行测试：[待配置]"
    fi

    # --- 输出检测结果摘要 ---
    echo "🔍 技术栈检测结果："
    echo "   语言：$lang"
    [ -n "$framework" ] && echo "   框架：$framework"
    [ -n "$css_framework" ] && echo "   CSS：$css_framework"
    [ -n "$build_tool" ] && echo "   构建：$build_tool"
    [ -n "$pkg_mgr" ] && echo "   包管理：$pkg_mgr"
    [ -n "$test_framework" ] && echo "   测试：$test_framework"
    echo ""

    # --- 导出结果 ---
    DETECTED_TECH_STACK="$tech_stack"
    DETECTED_CODE_STANDARDS="$code_standards"
    DETECTED_TEST_STANDARDS="$test_standards"
}

# ============================================================
# 主流程
# ============================================================

# 创建目录
echo "📁 创建目录..."
mkdir -p "$PROJECT_PATH/docs/features/archive"
mkdir -p "$PROJECT_PATH/docs/dev_guide"
mkdir -p "$PROJECT_PATH/.claude/commands"

# 复制模板
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📄 创建 FEATURE_INDEX.md..."
cp "$SKILL_DIR/templates/FEATURE_INDEX.md" "$PROJECT_PATH/docs/features/FEATURE_INDEX.md"
# 更新 FEATURE_INDEX.md 中的日期
sed -i.bak "s/{{date}}/$(date +%Y-%m-%d)/g" "$PROJECT_PATH/docs/features/FEATURE_INDEX.md"
rm -f "$PROJECT_PATH/docs/features/FEATURE_INDEX.md.bak"

echo "📄 创建 TEMPLATE.md..."
cp "$SKILL_DIR/templates/NF-TEMPLATE.md" "$PROJECT_PATH/docs/features/TEMPLATE.md"
sed -i.bak "s/{{date}}/$(date +%Y-%m-%d)/g" "$PROJECT_PATH/docs/features/TEMPLATE.md"
rm -f "$PROJECT_PATH/docs/features/TEMPLATE.md.bak"

echo "📄 创建开发规范示例..."
cat > "$PROJECT_PATH/docs/dev_guide/README.md" << 'EOF'
# 开发指南

此目录包含项目特定的开发规范。

## 建议的文件

根据项目技术栈添加对应的规范文件，例如：
- `components.md` - 组件/模块约定
- `testing.md` - 测试策略和工具
- `styling.md` - 样式约定
- `api.md` - API 设计模式

## 使用方式

Agent 通过 `/nf-explore` 或在提示时按需读取这些文件。
EOF

echo "📄 复制斜杠命令..."
cp "$SKILL_DIR/commands/"*.md "$PROJECT_PATH/.claude/commands/"

# 检测技术栈
echo "🔍 检测项目技术栈..."
detect_tech_stack "$PROJECT_PATH"

echo "📄 更新 CLAUDE.md..."
if [ -f "$PROJECT_PATH/CLAUDE.md" ]; then
    # 如果不存在则追加 NF 系统章节
    if ! grep -q "NF 系统" "$PROJECT_PATH/CLAUDE.md"; then
        echo "" >> "$PROJECT_PATH/CLAUDE.md"
        # 复制模板并替换占位符
        TMP_CLAUDE=$(mktemp)
        cp "$SKILL_DIR/templates/CLAUDE.md" "$TMP_CLAUDE"
        # 使用 awk 替换多行占位符（兼容 macOS）
        awk -v ts="$DETECTED_TECH_STACK" '{gsub(/\{\{TECH_STACK\}\}/, ts)}1' "$TMP_CLAUDE" > "${TMP_CLAUDE}.tmp" && mv "${TMP_CLAUDE}.tmp" "$TMP_CLAUDE"
        awk -v cs="$DETECTED_CODE_STANDARDS" '{gsub(/\{\{CODE_STANDARDS\}\}/, cs)}1' "$TMP_CLAUDE" > "${TMP_CLAUDE}.tmp" && mv "${TMP_CLAUDE}.tmp" "$TMP_CLAUDE"
        awk -v tt="$DETECTED_TEST_STANDARDS" '{gsub(/\{\{TEST_STANDARDS\}\}/, tt)}1' "$TMP_CLAUDE" > "${TMP_CLAUDE}.tmp" && mv "${TMP_CLAUDE}.tmp" "$TMP_CLAUDE"
        cat "$TMP_CLAUDE" >> "$PROJECT_PATH/CLAUDE.md"
        rm -f "$TMP_CLAUDE"
    else
        echo "  (CLAUDE.md 已有 NF 系统章节)"
    fi
else
    cp "$SKILL_DIR/templates/CLAUDE.md" "$PROJECT_PATH/CLAUDE.md"
    # 替换占位符
    TMP_CLAUDE="$PROJECT_PATH/CLAUDE.md"
    awk -v ts="$DETECTED_TECH_STACK" '{gsub(/\{\{TECH_STACK\}\}/, ts)}1' "$TMP_CLAUDE" > "${TMP_CLAUDE}.tmp" && mv "${TMP_CLAUDE}.tmp" "$TMP_CLAUDE"
    awk -v cs="$DETECTED_CODE_STANDARDS" '{gsub(/\{\{CODE_STANDARDS\}\}/, cs)}1' "$TMP_CLAUDE" > "${TMP_CLAUDE}.tmp" && mv "${TMP_CLAUDE}.tmp" "$TMP_CLAUDE"
    awk -v tt="$DETECTED_TEST_STANDARDS" '{gsub(/\{\{TEST_STANDARDS\}\}/, tt)}1' "$TMP_CLAUDE" > "${TMP_CLAUDE}.tmp" && mv "${TMP_CLAUDE}.tmp" "$TMP_CLAUDE"
fi

echo "📄 创建初始 NF-000..."
cat > "$PROJECT_PATH/docs/features/NF-000-init.md" << EOF
NF-000: NF 系统初始化

状态：Complete      优先级：High
工作量：Small       影响：开发工作流基础

## 问题
需要结构化的方法来管理 AI Agent 的功能开发。

## 方案
实现 NF (New Feature) 系统：
1. 创建 docs/features/ 目录结构
2. 创建 FEATURE_INDEX.md 用于追踪
3. 创建 NF 模板
4. 安装 6 个斜杠命令
5. 更新 CLAUDE.md 约定
6. 自动检测项目技术栈

## 修改的文件
- docs/features/FEATURE_INDEX.md (新增)
- docs/features/TEMPLATE.md (新增)
- docs/dev_guide/README.md (新增)
- .claude/commands/nf-*.md (新增 6 个)
- CLAUDE.md (修改)

## 验证
- [x] 目录结构已创建
- [x] 所有文件到位
- [x] 斜杠命令已安装
- [x] 技术栈已自动检测

---
创建日期：$(date +%Y-%m-%d)
完成日期：$(date +%Y-%m-%d)
EOF

echo ""
echo "✅ NF 系统安装成功！"
echo ""
echo "📁 已创建的结构："
echo "   docs/features/FEATURE_INDEX.md"
echo "   docs/features/TEMPLATE.md"
echo "   docs/features/NF-000-init.md"
echo "   docs/dev_guide/"
echo "   .claude/commands/nf-*.md (6 个命令)"
echo "   CLAUDE.md (已更新)"
echo ""
echo "🚀 下一步："
echo "   1. 查看 docs/features/NF-000-init.md"
echo "   2. 运行 /nf-explore 加载上下文"
echo "   3. 运行 /nf-new 创建第一个 NF"
echo ""
echo "📚 可用命令："
echo "   /nf-new      - 创建新 NF"
echo "   /nf-status   - 查看所有 NF"
echo "   /nf-explore  - 加载项目上下文"
echo "   /nf-verify   - 验证代码"
echo "   /nf-close    - 关闭 NF"
echo "   /nf-deep     - 并行分析"
echo ""
