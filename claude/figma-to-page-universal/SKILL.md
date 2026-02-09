---
name: Figma to Page 通用技能
description: 自动检测项目技术栈，智能适配生成符合当前项目规范的高质量页面/组件。支持 React、Vue2、Vue3、Angular、Svelte 等多框架，自动识别 UI 库和样式方案。
---

# Figma to Page 通用技能

> Claude Code 通用技能：自动检测项目技术栈，智能适配生成符合当前项目规范的高质量页面/组件

## 技能特点

### 🔍 智能项目检测
- **框架识别**：自动检测 React、Vue2、Vue3、Angular、Svelte 等
- **UI库识别**：自动识别 Ant Design、Vant、Element UI、Material UI 等
- **样式方案检测**：自动检测 Tailwind CSS、Less、Sass、CSS Modules 等
- **构建工具识别**：自动识别 Vite、Webpack、Umi、Next.js 等
- **单位系统检测**：自动检测 px、rem、em 的使用偏好

### 🎯 通用设计识别引擎
- **布局分析算法**：基于元素分布智能判断布局方式
- **组件映射系统**：多技术栈的组件映射规则
- **样式单位转换**：根据项目偏好自动转换样式单位
- **响应式识别**：自动生成适合项目的响应式代码

### ✅ 强制验证体系
- **截图对比验证**：Figma 设计稿 vs 生成页面对比
- **技术栈符合度检查**：确保生成代码符合项目规范
- **代码质量评估**：TypeScript、ESLint、Prettier 兼容性检查

---

## 使用流程

### 步骤 1：项目上下文自动检测

在生成任何代码之前，技能会自动扫描项目并识别技术栈：

#### 1.1 检测方式

```typescript
interface ProjectDetector {
  // 读取配置文件
  detectFromPackageJson(): TechStackInfo;
  // 扫描项目结构
  detectFromFileStructure(): ProjectStructure;
  // 分析现有代码
  detectFromExistingCode(): CodingPatterns;
  // 检测样式偏好
  detectStylePreferences(): StyleConfig;
}
```

#### 1.2 检测维度

| 维度 | 检测文件/方式 | 可能结果 |
|------|---------------|----------|
| **前端框架** | package.json dependencies | React, Vue2, Vue3, Angular, Svelte |
| **UI组件库** | package.json, imports | Ant Design, Vant, Element UI, Material UI, Chakra UI |
| **样式方案** | 配置文件, 文件扩展名 | Tailwind CSS, Less, Sass, CSS Modules, Styled Components |
| **构建工具** | 配置文件 | Vite, Webpack, Umi, Next.js, Nuxt.js |
| **TypeScript** | tsconfig.json, 文件扩展名 | TypeScript, JavaScript |
| **状态管理** | package.json, imports | Redux, Zustand, Pinia, Vuex |
| **样式单位** | 现有CSS文件分析 | px, rem, em |

#### 1.3 检测算法

```typescript
// 框架检测
async function detectFramework(): Promise<Framework> {
  const packageJson = await readPackageJson();

  if (packageJson.dependencies?.vue) {
    const vueVersion = packageJson.dependencies.vue;
    return vueVersion.startsWith('^3') || vueVersion.startsWith('3') ? 'vue3' : 'vue2';
  }

  if (packageJson.dependencies?.react) return 'react';
  if (packageJson.dependencies?.['@angular/core']) return 'angular';
  if (packageJson.dependencies?.svelte) return 'svelte';

  return 'unknown';
}

// UI库检测
async function detectUILibrary(): Promise<UILibrary> {
  const packageJson = await readPackageJson();

  if (packageJson.dependencies?.['@ant-design/pro-components']) return 'antd-pro';
  if (packageJson.dependencies?.antd) return 'antd';
  if (packageJson.dependencies?.vant) return 'vant';
  if (packageJson.dependencies?.['element-plus']) return 'element-plus';
  if (packageJson.dependencies?.['element-ui']) return 'element-ui';
  if (packageJson.dependencies?.['@mui/material']) return 'material-ui';
  if (packageJson.dependencies?.['@chakra-ui/react']) return 'chakra-ui';

  return 'none';
}

// 样式方案检测
async function detectStyleSystem(): Promise<StyleSystem> {
  const hasFile = await checkFileExists;

  if (await hasFile('tailwind.config.js') || await hasFile('tailwind.config.ts')) {
    return { type: 'tailwind', units: await detectTailwindUnits() };
  }

  if (await hasFile('*.less')) return { type: 'less', units: await detectUnitsInFiles('**/*.less') };
  if (await hasFile('*.scss')) return { type: 'scss', units: await detectUnitsInFiles('**/*.scss') };

  const hasStyledComponents = await checkPackageDependency('styled-components');
  if (hasStyledComponents) return { type: 'styled-components', units: 'px' };

  return { type: 'css', units: 'px' };
}

// 样式单位检测
async function detectUnitsInFiles(pattern: string): Promise<StyleUnit> {
  const files = await globFiles(pattern);
  const units = { px: 0, rem: 0, em: 0 };

  for (const file of files) {
    const content = await readFile(file);
    units.px += (content.match(/\d+px/g) || []).length;
    units.rem += (content.match(/\d+rem/g) || []).length;
    units.em += (content.match(/\d+em/g) || []).length;
  }

  // 返回使用最多的单位
  return Object.keys(units).reduce((a, b) => units[a] > units[b] ? a : b) as StyleUnit;
}
```

### 步骤 2：项目预设匹配

基于检测结果，自动选择对应的项目预设：

#### 2.1 预设定义

```typescript
interface ProjectPreset {
  id: string;
  name: string;
  framework: Framework;
  uiLibrary: UILibrary;
  styleSystem: StyleSystem;
  componentMapping: ComponentMapping;
  templates: CodeTemplates;
  imports: ImportPatterns;
}

const PRESETS: ProjectPreset[] = [
  {
    id: 'react-antd-tailwind',
    name: 'React + Ant Design + Tailwind CSS',
    framework: 'react',
    uiLibrary: 'antd',
    styleSystem: { type: 'tailwind', units: 'rem' },
    componentMapping: REACT_ANTD_MAPPING,
    templates: REACT_ANTD_TEMPLATES,
    imports: REACT_ANTD_IMPORTS
  },

  {
    id: 'react-antd-pro',
    name: 'React + Ant Design Pro Components',
    framework: 'react',
    uiLibrary: 'antd-pro',
    styleSystem: { type: 'less', units: 'px' },
    componentMapping: REACT_ANTD_PRO_MAPPING,
    templates: REACT_ANTD_PRO_TEMPLATES,
    imports: REACT_ANTD_PRO_IMPORTS
  },

  {
    id: 'vue3-element-plus',
    name: 'Vue 3 + Element Plus',
    framework: 'vue3',
    uiLibrary: 'element-plus',
    styleSystem: { type: 'scss', units: 'px' },
    componentMapping: VUE3_ELEMENT_MAPPING,
    templates: VUE3_ELEMENT_TEMPLATES,
    imports: VUE3_ELEMENT_IMPORTS
  },

  {
    id: 'vue2-vant',
    name: 'Vue 2 + Vant (Mobile)',
    framework: 'vue2',
    uiLibrary: 'vant',
    styleSystem: { type: 'scss', units: 'rem' },
    componentMapping: VUE2_VANT_MAPPING,
    templates: VUE2_VANT_TEMPLATES,
    imports: VUE2_VANT_IMPORTS
  },

  // 更多预设...
];
```

#### 2.2 智能匹配算法

```typescript
function matchPreset(detectedStack: TechStackInfo): ProjectPreset {
  // 精确匹配
  const exactMatch = PRESETS.find(preset =>
    preset.framework === detectedStack.framework &&
    preset.uiLibrary === detectedStack.uiLibrary &&
    preset.styleSystem.type === detectedStack.styleSystem.type
  );

  if (exactMatch) return exactMatch;

  // 部分匹配 - 框架 + UI库
  const partialMatch = PRESETS.find(preset =>
    preset.framework === detectedStack.framework &&
    preset.uiLibrary === detectedStack.uiLibrary
  );

  if (partialMatch) {
    return {
      ...partialMatch,
      styleSystem: detectedStack.styleSystem // 使用检测到的样式系统
    };
  }

  // 框架匹配
  const frameworkMatch = PRESETS.find(preset =>
    preset.framework === detectedStack.framework
  );

  if (frameworkMatch) return frameworkMatch;

  // 兜底：返回通用预设
  return createCustomPreset(detectedStack);
}
```

### 步骤 3：智能设计分析

#### 3.1 通用间距计算

```typescript
// 根据项目样式单位偏好，智能转换间距
function calculateSpacing(pixelDistance: number, styleConfig: StyleConfig): string {
  const { type, units } = styleConfig;

  if (type === 'tailwind') {
    // Tailwind CSS 间距映射
    if (pixelDistance <= 4) return 'space-1';
    if (pixelDistance <= 8) return 'space-2';
    if (pixelDistance <= 16) return 'space-4';
    if (pixelDistance <= 24) return 'space-6';
    if (pixelDistance <= 32) return 'space-8';
    return `space-${Math.ceil(pixelDistance / 4)}`;
  }

  if (units === 'rem') {
    // 转换为 rem（假设基础字体大小为 16px）
    const remValue = pixelDistance / 16;
    return `${remValue.toFixed(2)}rem`;
  }

  if (units === 'em') {
    // 转换为 em
    const emValue = pixelDistance / 16;
    return `${emValue.toFixed(2)}em`;
  }

  // 默认使用 px
  return `${pixelDistance}px`;
}
```

#### 3.2 跨框架布局识别

```typescript
function generateLayoutCode(
  direction: 'row' | 'column',
  spacing: string,
  framework: Framework,
  styleSystem: StyleSystem
): string {
  if (framework === 'react') {
    if (styleSystem.type === 'tailwind') {
      return direction === 'row'
        ? `className="flex flex-row gap-${spacing}"`
        : `className="flex flex-col gap-${spacing}"`;
    }

    return direction === 'row'
      ? `style={{ display: 'flex', flexDirection: 'row', gap: '${spacing}' }}`
      : `style={{ display: 'flex', flexDirection: 'column', gap: '${spacing}' }}`;
  }

  if (framework === 'vue3' || framework === 'vue2') {
    if (styleSystem.type === 'tailwind') {
      return direction === 'row'
        ? `class="flex flex-row gap-${spacing}"`
        : `class="flex flex-col gap-${spacing}"`;
    }

    return direction === 'row'
      ? `:style="{ display: 'flex', flexDirection: 'row', gap: '${spacing}' }"`
      : `:style="{ display: 'flex', flexDirection: 'column', gap: '${spacing}' }"`;
  }

  return '';
}
```

### 步骤 4：跨技术栈组件映射

#### 4.1 通用组件映射表

```typescript
interface ComponentMapping {
  [designElement: string]: {
    [techStack: string]: ComponentInfo;
  };
}

const UNIVERSAL_COMPONENT_MAPPING: ComponentMapping = {
  button: {
    'react-antd': { component: 'Button', imports: 'antd', props: 'type="primary"' },
    'react-antd-pro': { component: 'Button', imports: 'antd', props: 'type="primary"' },
    'vue3-element-plus': { component: 'el-button', imports: 'element-plus', props: 'type="primary"' },
    'vue2-vant': { component: 'van-button', imports: 'vant', props: 'type="primary"' },
    'react-mui': { component: 'Button', imports: '@mui/material', props: 'variant="contained"' }
  },

  input: {
    'react-antd': { component: 'Input', imports: 'antd', props: 'placeholder="请输入"' },
    'react-antd-pro': { component: 'ProFormText', imports: '@ant-design/pro-components', props: 'label="字段"' },
    'vue3-element-plus': { component: 'el-input', imports: 'element-plus', props: 'placeholder="请输入"' },
    'vue2-vant': { component: 'van-field', imports: 'vant', props: 'label="字段" placeholder="请输入"' }
  },

  table: {
    'react-antd': { component: 'Table', imports: 'antd', props: 'dataSource={data} columns={columns}' },
    'react-antd-pro': { component: 'ProTable', imports: '@ant-design/pro-components', props: 'request={request}' },
    'vue3-element-plus': { component: 'el-table', imports: 'element-plus', props: ':data="tableData"' },
    'vue2-vant': { component: 'van-list', imports: 'vant', props: 'v-model="list"' }
  },

  form: {
    'react-antd': { component: 'Form', imports: 'antd', props: 'layout="vertical"' },
    'react-antd-pro': { component: 'ProForm', imports: '@ant-design/pro-components', props: 'onFinish={onFinish}' },
    'vue3-element-plus': { component: 'el-form', imports: 'element-plus', props: ':model="form" label-width="120px"' },
    'vue2-vant': { component: 'van-form', imports: 'vant', props: '@submit="onSubmit"' }
  },

  card: {
    'react-antd': { component: 'Card', imports: 'antd', props: 'title="标题"' },
    'react-antd-pro': { component: 'ProCard', imports: '@ant-design/pro-components', props: 'title="标题"' },
    'vue3-element-plus': { component: 'el-card', imports: 'element-plus', props: 'header="标题"' },
    'vue2-vant': { component: 'van-card', imports: 'vant', props: 'title="标题"' }
  },

  modal: {
    'react-antd': { component: 'Modal', imports: 'antd', props: 'title="标题" visible={visible}' },
    'react-antd-pro': { component: 'Modal', imports: 'antd', props: 'title="标题" open={open}' },
    'vue3-element-plus': { component: 'el-dialog', imports: 'element-plus', props: 'title="标题" v-model="visible"' },
    'vue2-vant': { component: 'van-dialog', imports: 'vant', props: 'title="标题" v-model="show"' }
  }
};
```

#### 4.2 智能组件选择

```typescript
function selectComponent(
  designElement: string,
  presetId: string,
  complexity: 'basic' | 'advanced' = 'basic'
): ComponentInfo {
  const mapping = UNIVERSAL_COMPONENT_MAPPING[designElement];

  if (!mapping) {
    return generateFallbackComponent(designElement, presetId);
  }

  // 优先选择当前预设的组件
  if (mapping[presetId]) {
    return mapping[presetId];
  }

  // 框架级别匹配
  const frameworkMatch = Object.keys(mapping).find(key =>
    key.startsWith(presetId.split('-')[0])
  );

  if (frameworkMatch) {
    return mapping[frameworkMatch];
  }

  // 返回通用组件
  return generateGenericComponent(designElement, presetId);
}
```

### 步骤 5：代码模板生成

#### 5.1 React 模板

```typescript
const REACT_TEMPLATES = {
  page: `
import React from 'react';
{{#if useAntd}}
import { {{components}} } from 'antd';
{{/if}}
{{#if useAntdPro}}
import { {{proComponents}} } from '@ant-design/pro-components';
{{/if}}

interface {{pageName}}Props {
  // 组件属性
}

const {{pageName}}: React.FC<{{pageName}}Props> = () => {
  return (
    <div{{#if useTailwind}} className="{{tailwindClasses}}"{{/if}}>
      {{content}}
    </div>
  );
};

export default {{pageName}};
  `,

  component: `
import React from 'react';
{{imports}}

interface {{componentName}}Props {
  {{props}}
}

export const {{componentName}}: React.FC<{{componentName}}Props> = ({{destructuredProps}}) => {
  return (
    {{componentJSX}}
  );
};
  `
};
```

#### 5.2 Vue 模板

```typescript
const VUE_TEMPLATES = {
  vue3: `
<template>
  <div{{#if useTailwind}} class="{{tailwindClasses}}"{{/if}}>
    {{content}}
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
{{imports}}

// 定义Props
interface Props {
  {{props}}
}

const props = defineProps<Props>();

// 响应式数据
{{reactiveData}}
</script>

<style scoped{{#if useLess}} lang="less"{{/if}}{{#if useScss}} lang="scss"{{/if}}>
{{styles}}
</style>
  `,

  vue2: `
<template>
  <div{{#if useTailwind}} class="{{tailwindClasses}}"{{/if}}>
    {{content}}
  </div>
</template>

<script>
{{imports}}

export default {
  name: '{{componentName}}',
  props: {
    {{props}}
  },
  data() {
    return {
      {{data}}
    };
  },
  methods: {
    {{methods}}
  }
};
</script>

<style scoped{{#if useLess}} lang="less"{{/if}}{{#if useScss}} lang="scss"{{/if}}>
{{styles}}
</style>
  `
};
```

### 步骤 6：样式适配生成

#### 6.1 Tailwind CSS 适配

```typescript
function generateTailwindStyles(spacing: SpacingInfo, colors: ColorInfo): string {
  const classes = [];

  // 布局类
  if (spacing.direction === 'row') classes.push('flex', 'flex-row');
  if (spacing.direction === 'column') classes.push('flex', 'flex-col');

  // 间距类
  if (spacing.gap) classes.push(`gap-${convertPixelToTailwind(spacing.gap)}`);
  if (spacing.padding) classes.push(`p-${convertPixelToTailwind(spacing.padding)}`);
  if (spacing.margin) classes.push(`m-${convertPixelToTailwind(spacing.margin)}`);

  // 颜色类
  if (colors.background) classes.push(getTailwindBackgroundClass(colors.background));
  if (colors.text) classes.push(getTailwindTextClass(colors.text));

  return classes.join(' ');
}
```

#### 6.2 Less/Sass 适配

```typescript
function generateCustomStyles(
  spacing: SpacingInfo,
  colors: ColorInfo,
  units: StyleUnit
): string {
  const styles = [];

  styles.push('display: flex;');
  styles.push(`flex-direction: ${spacing.direction};`);

  if (spacing.gap) {
    styles.push(`gap: ${convertPixel(spacing.gap, units)};`);
  }

  if (colors.background) {
    styles.push(`background-color: ${colors.background};`);
  }

  if (colors.text) {
    styles.push(`color: ${colors.text};`);
  }

  return styles.join('\n  ');
}

function convertPixel(px: number, targetUnit: StyleUnit): string {
  switch (targetUnit) {
    case 'rem': return `${(px / 16).toFixed(2)}rem`;
    case 'em': return `${(px / 16).toFixed(2)}em`;
    default: return `${px}px`;
  }
}
```

### 步骤 7：响应式适配

#### 7.1 通用响应式策略

```typescript
interface ResponsiveConfig {
  breakpoints: {
    mobile: number;
    tablet: number;
    desktop: number;
  };
  strategy: 'mobile-first' | 'desktop-first';
}

function generateResponsiveCode(
  element: DesignElement,
  config: ResponsiveConfig,
  framework: Framework,
  styleSystem: StyleSystem
): string {
  if (styleSystem.type === 'tailwind') {
    return generateTailwindResponsive(element, config);
  }

  if (framework === 'react') {
    return generateReactResponsive(element, config);
  }

  if (framework === 'vue3' || framework === 'vue2') {
    return generateVueResponsive(element, config);
  }

  return generateCSSResponsive(element, config);
}
```

### 步骤 8：验证体系

#### 8.1 技术栈符合度检查

```typescript
interface ValidationResult {
  score: number;
  issues: ValidationIssue[];
  suggestions: string[];
}

async function validateGeneratedCode(
  code: string,
  preset: ProjectPreset
): Promise<ValidationResult> {
  const issues: ValidationIssue[] = [];
  let score = 100;

  // 检查导入语句
  const importCheck = validateImports(code, preset);
  if (!importCheck.valid) {
    issues.push(...importCheck.issues);
    score -= 10;
  }

  // 检查组件使用
  const componentCheck = validateComponents(code, preset);
  if (!componentCheck.valid) {
    issues.push(...componentCheck.issues);
    score -= 15;
  }

  // 检查样式一致性
  const styleCheck = validateStyles(code, preset);
  if (!styleCheck.valid) {
    issues.push(...styleCheck.issues);
    score -= 10;
  }

  // 检查TypeScript类型
  if (preset.framework === 'react' && code.includes('.tsx')) {
    const typeCheck = validateTypeScript(code);
    if (!typeCheck.valid) {
      issues.push(...typeCheck.issues);
      score -= 5;
    }
  }

  return {
    score: Math.max(0, score),
    issues,
    suggestions: generateSuggestions(issues, preset)
  };
}
```

---

## 预设配置详情

### React 生态系统预设

#### React + Ant Design
```typescript
const REACT_ANTD_PRESET = {
  id: 'react-antd',
  framework: 'react',
  uiLibrary: 'antd',
  styleSystem: { type: 'less', units: 'px' },
  imports: {
    components: "import { Button, Input, Form, Table, Card } from 'antd';",
    icons: "import { SearchOutlined, PlusOutlined } from '@ant-design/icons';",
    styles: "import './index.less';"
  },
  componentMapping: {
    button: 'Button',
    input: 'Input',
    form: 'Form',
    table: 'Table',
    card: 'Card'
  }
};
```

#### React + Ant Design Pro
```typescript
const REACT_ANTD_PRO_PRESET = {
  id: 'react-antd-pro',
  framework: 'react',
  uiLibrary: 'antd-pro',
  styleSystem: { type: 'less', units: 'px' },
  imports: {
    components: "import { ProTable, ProForm, PageContainer } from '@ant-design/pro-components';",
    antd: "import { Button, message } from 'antd';"
  },
  componentMapping: {
    table: 'ProTable',
    form: 'ProForm',
    page: 'PageContainer',
    input: 'ProFormText',
    select: 'ProFormSelect'
  }
};
```

### Vue 生态系统预设

#### Vue 3 + Element Plus
```typescript
const VUE3_ELEMENT_PRESET = {
  id: 'vue3-element-plus',
  framework: 'vue3',
  uiLibrary: 'element-plus',
  styleSystem: { type: 'scss', units: 'px' },
  imports: {
    components: "import { ElButton, ElInput, ElForm, ElTable } from 'element-plus';",
    styles: "import 'element-plus/dist/index.css';"
  },
  componentMapping: {
    button: 'el-button',
    input: 'el-input',
    form: 'el-form',
    table: 'el-table'
  }
};
```

#### Vue 2 + Vant
```typescript
const VUE2_VANT_PRESET = {
  id: 'vue2-vant',
  framework: 'vue2',
  uiLibrary: 'vant',
  styleSystem: { type: 'scss', units: 'rem' },
  imports: {
    components: "import { Button, Field, Form, List, Card } from 'vant';",
    styles: "import 'vant/lib/index.css';"
  },
  componentMapping: {
    button: 'van-button',
    input: 'van-field',
    form: 'van-form',
    list: 'van-list',
    card: 'van-card'
  }
};
```

---

## 使用示例

### 自动检测使用

```bash
# 技能会自动检测项目并适配
请基于这个 Figma 设计稿创建一个用户管理页面
```

### 指定技术栈使用

```bash
# 强制使用特定预设
请使用 Vue 3 + Element Plus 预设，基于 Figma 设计创建一个表单页面
```

### 验证和优化

```bash
# 包含验证步骤
请创建页面并进行技术栈符合度验证，提供优化建议
```

---

## 扩展新预设

如果遇到未预置的技术栈组合，可以快速创建新预设：

```typescript
// 创建自定义预设
function createCustomPreset(detectedStack: TechStackInfo): ProjectPreset {
  return {
    id: `custom-${Date.now()}`,
    name: `${detectedStack.framework} + ${detectedStack.uiLibrary}`,
    framework: detectedStack.framework,
    uiLibrary: detectedStack.uiLibrary,
    styleSystem: detectedStack.styleSystem,
    componentMapping: generateBasicMapping(detectedStack),
    templates: generateBasicTemplates(detectedStack),
    imports: generateBasicImports(detectedStack)
  };
}
```

---

## 验收标准

### 必须通过的检查项

- [ ] **项目检测准确率** >= 95%
- [ ] **技术栈适配正确率** >= 90%
- [ ] **生成代码可编译率** >= 95%
- [ ] **UI组件映射准确率** >= 85%
- [ ] **样式单位一致性** >= 90%
- [ ] **响应式适配完整性** >= 80%
- [ ] **导入语句正确率** >= 95%

### 性能指标

- 项目检测时间 < 3s
- 代码生成时间 < 5s
- 单个组件生成时间 < 1s

---

## 更新日志

### v1.0.0 (当前版本)
- 🔍 自动项目技术栈检测
- 🎯 多框架组件映射系统
- 🎨 智能样式适配
- ✅ 技术栈符合度验证
- 📱 通用响应式方案
- 🔧 可扩展预设系统

---

*这个通用版 Figma to Page 技能可以适配大多数前端项目，通过智能检测和预设匹配，确保生成的代码符合项目的技术栈和编码规范。*