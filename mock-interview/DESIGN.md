# Mock Interview System - Design Document

> NF-003 | Status: Design | Created: 2026-03-21

## 1. System Overview

### 1.1 Purpose

A CLI-based mock interview system that helps users practice technical and behavioral interviews through structured, interactive sessions. The system leverages AI (Claude) to act as an interviewer, providing real-time feedback and scoring.

### 1.2 Goals

- Provide realistic interview simulation covering multiple domains (frontend, backend, system design, behavioral)
- Support configurable difficulty levels and interview types
- Deliver structured feedback with scoring and improvement suggestions
- Maintain interview history for progress tracking
- Keep the system lightweight and dependency-minimal

### 1.3 Non-Goals

- Real-time voice/video interviews (text-based only)
- Multi-user or networked sessions
- Integration with external job platforms

---

## 2. Core Modules

```
mock-interview/
├── DESIGN.md                  # This document
├── README.md                  # Usage guide
├── package.json               # Dependencies and scripts
├── src/
│   ├── index.ts               # CLI entry point
│   ├── config.ts              # Configuration management
│   ├── core/
│   │   ├── session.ts         # Interview session lifecycle
│   │   ├── interviewer.ts     # AI interviewer logic (prompt engineering)
│   │   └── evaluator.ts       # Answer evaluation and scoring
│   ├── questions/
│   │   ├── loader.ts          # Question bank loader
│   │   ├── selector.ts        # Question selection strategy
│   │   └── bank/
│   │       ├── frontend.json  # Frontend questions
│   │       ├── backend.json   # Backend questions
│   │       ├── system-design.json
│   │       ├── behavioral.json
│   │       └── algorithms.json
│   ├── feedback/
│   │   ├── reporter.ts        # Feedback report generator
│   │   └── templates/         # Report templates
│   └── history/
│       ├── store.ts           # Session history persistence
│       └── analytics.ts       # Progress analytics
├── data/
│   └── sessions/              # Saved interview sessions
└── tests/
    └── ...                    # Unit tests
```

### 2.1 Module Descriptions

| Module | Responsibility |
|--------|---------------|
| **core/session** | Manages interview lifecycle: start, question flow, pause/resume, end |
| **core/interviewer** | Constructs AI prompts, manages conversation context, handles follow-up questions |
| **core/evaluator** | Scores answers based on completeness, accuracy, clarity; generates per-question ratings |
| **questions/loader** | Loads and validates question bank files |
| **questions/selector** | Selects questions based on category, difficulty, and history (avoid repeats) |
| **feedback/reporter** | Generates structured post-interview reports (markdown or terminal output) |
| **history/store** | Persists session data to local JSON files |
| **history/analytics** | Aggregates historical performance for trend analysis |

---

## 3. Technology Selection

| Area | Choice | Rationale |
|------|--------|-----------|
| Language | TypeScript | Type safety, good DX, consistent with modern JS ecosystem |
| Runtime | Node.js (>=18) | Widely available, good CLI support |
| CLI Framework | Commander.js | Lightweight, well-documented |
| Terminal UI | Inquirer.js | Interactive prompts, good UX for Q&A flow |
| AI Integration | Claude API (Anthropic SDK) | High-quality reasoning for interview simulation |
| Data Storage | Local JSON files | Zero-dependency persistence, human-readable |
| Testing | Vitest | Fast, TypeScript-native |

---

## 4. Interview Flow Design

### 4.1 Session Lifecycle

```
[Start] -> Configure -> Generate Questions -> Interview Loop -> Evaluate -> Report -> [End]
```

**Detailed Flow:**

1. **Configure** - User selects interview type, difficulty, duration, and focus areas
2. **Generate Questions** - System selects questions from the bank, optionally generates new ones via AI
3. **Interview Loop** - For each question:
   - Present the question
   - User types their answer
   - AI evaluates and may ask follow-up questions (up to 2 follow-ups)
   - Score the answer
   - Move to next question or end if time is up
4. **Evaluate** - Aggregate scores, identify strengths and weaknesses
5. **Report** - Output a structured feedback report

### 4.2 Interview Types

| Type | Description | Duration | Questions |
|------|-------------|----------|-----------|
| Quick Practice | Single topic, short | 15 min | 3-5 |
| Standard Interview | Mixed topics | 30 min | 6-8 |
| Full Mock | Comprehensive simulation | 60 min | 10-15 |
| Deep Dive | Single topic, thorough | 45 min | 5-8 with extensive follow-ups |

### 4.3 Difficulty Levels

- **Junior** - Fundamental concepts, straightforward questions
- **Mid-level** - Applied knowledge, trade-off analysis
- **Senior** - System design, architecture decisions, leadership scenarios

---

## 5. Question Bank Design

### 5.1 Question Schema

```json
{
  "id": "fe-001",
  "category": "frontend",
  "subcategory": "react",
  "difficulty": "mid",
  "type": "technical",
  "question": "Explain the React reconciliation algorithm...",
  "keyPoints": ["virtual DOM diffing", "fiber architecture", "keys"],
  "followUps": [
    "How does React decide when to re-render a component?",
    "What role do keys play in list rendering performance?"
  ],
  "scoringCriteria": {
    "completeness": "Covers all key points",
    "depth": "Explains underlying mechanisms",
    "clarity": "Well-structured explanation"
  },
  "tags": ["react", "performance", "virtual-dom"]
}
```

### 5.2 Categories

- **Frontend**: React, Vue, CSS, Browser APIs, Performance
- **Backend**: Node.js, Databases, APIs, Authentication, Caching
- **System Design**: Scalability, High Availability, Data Modeling
- **Algorithms**: Data Structures, Sorting, Searching, Dynamic Programming
- **Behavioral**: Leadership, Conflict Resolution, Project Management

### 5.3 Question Sources

- Built-in static question bank (JSON files, curated)
- AI-generated questions based on topic and difficulty (runtime)
- User-contributed questions (future enhancement)

---

## 6. Scoring Mechanism

### 6.1 Per-Question Scoring

Each answer is evaluated on three dimensions (1-5 scale):

| Dimension | Weight | Description |
|-----------|--------|-------------|
| **Completeness** | 40% | Covers expected key points |
| **Depth** | 35% | Demonstrates deep understanding |
| **Clarity** | 25% | Well-organized, concise explanation |

**Per-question score** = weighted average, mapped to 0-100.

### 6.2 Session Scoring

- **Overall Score**: Average of all question scores
- **Category Breakdown**: Scores grouped by topic
- **Rating**: S / A / B / C / D based on overall score thresholds

| Rating | Score Range | Description |
|--------|------------|-------------|
| S | 90-100 | Exceptional |
| A | 75-89 | Strong |
| B | 60-74 | Competent |
| C | 45-59 | Needs Improvement |
| D | 0-44 | Significant Gaps |

### 6.3 Feedback Report Contents

- Overall score and rating
- Per-question breakdown with specific feedback
- Strengths identified
- Areas for improvement with study suggestions
- Comparison with previous sessions (if history exists)

---

## 7. CLI Commands

```bash
# Start an interview
mock-interview start [--type quick|standard|full|deep] [--level junior|mid|senior] [--category frontend|backend|...]

# Resume a paused session
mock-interview resume [session-id]

# View history
mock-interview history [--last N]

# View a specific session report
mock-interview report <session-id>

# View progress analytics
mock-interview stats

# Manage question bank
mock-interview questions list [--category] [--difficulty]
mock-interview questions add <file>
```

---

## 8. Implementation Roadmap

### Phase 1: Foundation (MVP)
- Project scaffolding and configuration
- Basic question bank (frontend + backend, 30+ questions)
- Simple interview session loop (no follow-ups)
- Basic scoring (completeness only)
- Terminal output report

### Phase 2: AI Integration
- Claude API integration for dynamic interviewing
- Follow-up question generation
- AI-powered answer evaluation (all 3 dimensions)
- Improved feedback quality

### Phase 3: History and Analytics
- Session persistence
- History browsing
- Progress tracking and trend charts (terminal-based)
- Weak area identification

### Phase 4: Enhanced Experience
- More question categories (system design, algorithms)
- Timed interview mode
- Customizable question bank
- Export reports to markdown files

---

## 9. Key Design Decisions

1. **CLI-first**: Keeps the system simple and accessible without web infrastructure overhead. Can be extended to web later if needed.

2. **Local-only storage**: No server or database dependency. Sessions stored as JSON files in `data/sessions/`. Easy to backup, inspect, and version control.

3. **AI as interviewer, not just evaluator**: The AI doesn't just score answers - it conducts the interview dynamically, asking contextual follow-ups just like a real interviewer would.

4. **Structured question bank + dynamic generation**: Static questions ensure consistency and quality; AI generation fills gaps and prevents memorization.

5. **Progressive scoring**: Start with simple keyword matching in MVP, evolve to AI-powered evaluation. This allows early delivery while improving quality over time.

---

## 10. Open Questions

- Should we support multiple AI providers or lock to Claude?
- Should interview sessions support multiple languages (Chinese + English)?
- Should we add a "study mode" that shows ideal answers after each question?
- How should we handle API rate limits and costs for AI-powered evaluation?

---

*This document is the Phase 1 deliverable for NF-003. Implementation begins after design review approval.*
