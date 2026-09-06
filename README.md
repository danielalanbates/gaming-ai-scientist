# Gaming AI Scientist

A never-stopping autonomous game-design research loop, combining **AI-Scientist**'s structured idea-generation pipeline with **BabyAGI**'s continuous loop architecture.

**No API keys needed.** Runs entirely offline with semantic deduplication.

## Quick Start

### Start the background loop
```bash
bash run.sh
```
Generates game ideas every 30 seconds, logs to `logs/loop.log`. Press Ctrl+C to detach; process runs in background.

### Stop the loop
```bash
bash stop.sh
```
Gracefully exits after the current iteration, cleaning up the `.loop.pid` file.

### Chat with live input
```bash
python3 interface/chat.py
```
Type ideas interactively. Each line is seeded into the generation pipeline as if it were a free-form prompt, and logged to `conversations/session-TIMESTAMP.md`.

## Architecture

### Core Pipeline (one iteration)

1. **Generate** (`core/generator.py`)
   - Combines random genres, verbs, and narrative twists
   - Or seeds from interactive chat input
   - Returns: `{title, hook, core_loop, verbs, genre, theme, why_new}`

2. **Embed & Dedupe** (`core/embeddings.py`)
   - Hashing-based embedder (offline, no API key)
   - Compares new idea against:
     - Seed corpus of shipped games (`data/seed_corpus.json`)
     - All previously logged ideas (`ideas/*.md`)

3. **Score** (`core/scoring.py`)
   - **Novelty:** cosine similarity distance from existing ideas (higher = more novel)
   - **Buildability:** heuristic scoring on mechanical coherence and scope
   - **Overall:** weighted blend of the above

4. **Write** (`ideas/YYYY-MM-DD-<slug>.md`)
   - Structured markdown per idea:
     - Hook, core loop, verb list
     - Novelty + buildability scores
     - Nearest existing game for reference
   - Files deduplicate by date + slugified title

### Loop Control

- **`run.sh`** — Start as background daemon with nohup; PID stored in `.loop.pid`
- **`stop.sh`** — Touches `STOP` file, waits for graceful exit, force-kills if needed
- **`STOP` file** — Any time this exists at repo root, the loop will exit cleanly

## Configuration

### Env Vars
- `GAI_LOOP_INTERVAL_SECONDS` (default: 30) — Sleep between iterations
- `GAI_EMBEDDING_BACKEND` (default: hashing) — Switch to `openai` if implemented

### Command-line Flags (`core/loop.py`)
- `--interval N` — Override sleep seconds per iteration
- `--once` — Run exactly one iteration, then exit (for smoke tests)

Example:
```bash
python3 core/loop.py --interval 60 --once
```

## File Layout

```
.
├── core/
│   ├── loop.py              # Main infinite loop
│   ├── generator.py         # Idea generation (random + seed)
│   ├── embeddings.py        # Semantic deduplication
│   └── scoring.py           # Novelty + buildability scoring
├── interface/
│   └── chat.py              # Interactive CLI chat box
├── ideas/                   # Generated ideas (output)
├── conversations/           # Chat session logs (output)
├── logs/
│   └── loop.log             # Loop runtime log (output)
├── data/                    # Seed corpus (ignored by git)
├── run.sh / stop.sh         # Daemon control
└── config.yaml              # Config (future extension)
```

## Next Steps

1. **LLM Integration** — Replace `core/generator.py`'s random-combo with a real LLM call
   - Wire up Anthropic API (or OpenAI embeddings)
   - Keep the return shape unchanged so downstream stays decoupled
   
2. **Real Embeddings** — Upgrade `core/embeddings.py` to semantic embeddings
   - E.g., sentence-transformers or OpenAI's embedding API
   - Improves novelty detection accuracy
   
3. **GUI Frontend** — Build a web dashboard for browsing ideas + controlling loop
   - Flask server already stubbed in `pyproject.toml`
   
4. **Corpus Seeding** — Expand `data/shipped_games.json` with real game data
   - Improves deduplication against actual market baseline

## Licensing

**Poly Non-Commercial License** — See `LICENSE` file.  
Copyright © 2026 Bates LLC. All rights reserved.  
Contact: help@batesai.org | https://batesai.org

---

Built by **Bates LLC Game Studio** with **Claude Haiku 4.5**.
