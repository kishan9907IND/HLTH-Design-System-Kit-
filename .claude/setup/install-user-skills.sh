#!/usr/bin/env bash
# install-user-skills.sh
# -----------------------------------------------------------------------------
# Installs the 4 project skills into ~/.claude/skills/ so they are available in
# EVERY project / session, not just this repo.
#
# HOW TO USE (cloud sessions):
#   Paste the contents of this file into your cloud environment's Setup script
#   (session title bar -> cloud environment menu -> Edit -> Setup script).
#   Every new session on that environment then installs the skills on startup.
#
# HOW TO USE (local machine):
#   Run it once:  bash .claude/setup/install-user-skills.sh
#   ~/.claude/skills/ is read by Claude Code for all local projects.
#
# Sources: each skill is pulled from its PUBLIC upstream repo, so this needs no
# GitHub auth and works inside a setup script (which cannot read repo secrets).
# Prompt-only: no binaries, hooks, proxies, or MCP servers are installed.
# Idempotent: re-runs refresh in place; a single failed source does not abort.
set -uo pipefail

SKILLS_DIR="${HOME}/.claude/skills"
CACHE="${HOME}/.cache/skill-sources"
mkdir -p "${SKILLS_DIR}" "${CACHE}"

clone_or_update() { # url  dest
  local url="$1" dest="$2"
  if [ -d "${dest}/.git" ]; then
    git -C "${dest}" fetch --depth 1 --quiet origin HEAD 2>/dev/null \
      && git -C "${dest}" reset --hard --quiet FETCH_HEAD 2>/dev/null || return 1
  else
    rm -rf "${dest}"
    GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 --quiet "${url}" "${dest}" 2>/dev/null || return 1
  fi
}

install_single() { # repo_dir  src_rel_path  skill_name
  local src="$1/$2" name="$3"
  [ -f "${src}" ] || { echo "  ! ${name}: source file missing (${2})"; return 0; }
  mkdir -p "${SKILLS_DIR}/${name}"
  cp "${src}" "${SKILLS_DIR}/${name}/SKILL.md"
}

# --- caveman / ponytail / taste-skill : single SKILL.md each -------------------
clone_or_update https://github.com/JuliusBrussee/caveman    "${CACHE}/caveman"     && install_single "${CACHE}/caveman"     skills/caveman/SKILL.md     caveman
clone_or_update https://github.com/DietrichGebert/ponytail  "${CACHE}/ponytail"    && install_single "${CACHE}/ponytail"    skills/ponytail/SKILL.md    ponytail
clone_or_update https://github.com/leonxlnx/taste-skill     "${CACHE}/taste-skill" && install_single "${CACHE}/taste-skill" skills/taste-skill/SKILL.md taste-skill

# --- impeccable : SKILL.md + reference/ (prompt-only; scripts/ stripped) -------
if clone_or_update https://github.com/pbakaus/impeccable "${CACHE}/impeccable"; then
  src="${CACHE}/impeccable/plugin/skills/impeccable"
  if [ -d "${src}" ]; then
    rm -rf "${SKILLS_DIR}/impeccable"
    mkdir -p "${SKILLS_DIR}/impeccable"
    cp "${src}/SKILL.md" "${SKILLS_DIR}/impeccable/SKILL.md"
    [ -d "${src}/reference" ] && cp -R "${src}/reference" "${SKILLS_DIR}/impeccable/reference"
  else
    echo "  ! impeccable: plugin/skills/impeccable not found"
  fi
fi

echo "Skills installed to ${SKILLS_DIR}:"
for n in caveman ponytail taste-skill impeccable; do
  [ -d "${SKILLS_DIR}/${n}" ] && echo "  - ${n}"
done
