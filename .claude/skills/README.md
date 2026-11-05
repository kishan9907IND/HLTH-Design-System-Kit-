# Project skills

Skill-only prompt instructions vendored from third-party repos (MIT or
Apache-2.0 licensed). These only shape how Claude responds in this repo — no
executables, hooks, proxies, or MCP servers were installed from the source
projects.

| Skill | Source | What it does |
|---|---|---|
| `caveman` | https://github.com/JuliusBrussee/caveman (`skills/caveman/SKILL.md`) | Terse, compressed response style (`/caveman lite\|full\|ultra\|off`) |
| `ponytail` | https://github.com/dietrichgebert/ponytail (`skills/ponytail/SKILL.md`) | Minimal-code discipline, avoids over-engineering (`/ponytail lite\|full\|ultra`) |
| `taste-skill` | https://github.com/leonxlnx/taste-skill (`skills/taste-skill/SKILL.md`) | Anti-generic frontend design guidance for landing pages/portfolios |
| `impeccable` | https://impeccable.style · https://github.com/pbakaus/impeccable (`plugin/skills/impeccable/`) | Design vocabulary for UI work — 24 playbooks (`bolder`, `quieter`, `critique`, `audit`, `polish`, `shape`, etc.) under `reference/`. Launcher scripts and hooks were skipped; the skill's documented launcher-unavailable path applies |

Each source repo also ships a larger plugin (binaries, hooks, MCP servers,
proxies) — only the plain-text SKILL.md instructions (and, for
`impeccable`, its `reference/*.md` playbooks) were pulled in here.
