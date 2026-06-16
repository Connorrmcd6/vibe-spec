#!/usr/bin/env bash
#
# secret-audit.sh — deterministic secret-leak audit for Vibe-Spec apps.
#
# TRUST BOUNDARY: this script is the ONLY thing that ever reads secret *values*.
# It reads .env files and the built bundle, does exact-match string work locally,
# and prints a REDACTED report — variable NAMES, verdicts, and file:line locations
# only. Secret values are never printed, never leave this process, never go over
# the network. /spec-secrets locks Claude's tools to just this script, so secrets
# never enter the model's context. (Same pattern as /spec-doctor.)
#
# Usage:
#   secret-audit.sh [--dir <path>] [--build] [--staged] [--no-color] [--help]
#
#   (default)   Static checks; also scans .next/static if a build already exists.
#   --build     Run `pnpm build` first, then do the dynamic bundle scan too.
#   --staged    Pre-commit mode: fast static checks on staged files only; exit
#               non-zero on any 🚨 so the commit is blocked. No build.
#   --dir       Project root to audit (default: current directory).
#
# Exit codes:  0 = clean   1 = leak / hardcoded secret found   2 = usage error
#
set -uo pipefail

# ----------------------------------------------------------------------------- config

PROJECT_DIR="."
DO_BUILD=0
STAGED=0
USE_COLOR=1

# Variable NAMES that are sensitive by definition in the Vibe-Spec stack. A name
# match alone is enough to treat a var as a secret (catalog beats entropy guessing).
CATALOG='AUTH_SECRET|AUTH_GOOGLE_SECRET|SESSION_SECRET|S3_SECRET_ACCESS_KEY|S3_ACCESS_KEY_ID|VAPID_PRIVATE_KEY|PIPELINE_API_KEY|DATABASE_URL|DB_PASSWORD|POSTGRES_PASSWORD|PGADMIN_DEFAULT_PASSWORD'

# Generic NAME patterns that look secret-ish regardless of the stack.
NAME_RE='SECRET|PASSWORD|PASSWD|PRIVATE_KEY|_TOKEN|API_?KEY|ACCESS_KEY|CREDENTIAL|_DSN|CONNECTION_STRING'

# VALUE shapes that are unambiguously secret-shaped (used for hardcoded-literal and
# mis-prefix detection). Order/precision matters more than recall here.
VALUE_RE='sk_live_[A-Za-z0-9]|sk_test_[A-Za-z0-9]|rk_(live|test)_|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}|[a-z]+://[^:@/ ]+:[^@/ ]+@'

# Files holding the user's allowlist of intentionally-public var names (one per line,
# '#' comments allowed). Lets the user silence false positives without editing code.
ALLOW_FILE=".spec-secrets-allow"

# --------------------------------------------------------------------------- arg parse

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)      PROJECT_DIR="${2:-}"; shift 2 ;;
    --build)    DO_BUILD=1; shift ;;
    --staged)   STAGED=1; shift ;;
    --no-color) USE_COLOR=0; shift ;;
    -h|--help)
      sed -n '3,30p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "secret-audit: unknown argument '$1'" >&2; exit 2 ;;
  esac
done

if [ ! -d "$PROJECT_DIR" ]; then
  echo "secret-audit: directory not found: $PROJECT_DIR" >&2; exit 2
fi
cd "$PROJECT_DIR" || { echo "secret-audit: cannot enter $PROJECT_DIR" >&2; exit 2; }

if [ "$USE_COLOR" -eq 1 ] && [ -t 1 ]; then
  R=$'\033[31m'; G=$'\033[32m'; Y=$'\033[33m'; B=$'\033[1m'; X=$'\033[0m'
else
  R=""; G=""; Y=""; B=""; X=""
fi

LEAK=0   # set to 1 on any confirmed leak / hardcoded secret -> exit 1

# --------------------------------------------------------------------------- helpers

# is_secret_name NAME -> 0 if the name is sensitive (catalog or generic pattern).
is_secret_name() {
  printf '%s' "$1" | grep -Eq "^($CATALOG)$" && return 0
  printf '%s' "$1" | grep -Eiq "($NAME_RE)" && return 0
  return 1
}

# is_allowlisted NAME -> 0 if user marked it intentionally public.
is_allowlisted() {
  [ -f "$ALLOW_FILE" ] || return 1
  grep -vE '^\s*#' "$ALLOW_FILE" 2>/dev/null | grep -qx "$(printf '%s' "$1" | tr -d '[:space:]')"
}

# env_files — the .env files Next.js actually resolves, in load order. Skips
# *.example / *.sample templates (those are meant to be committed with placeholders).
env_files() {
  for f in .env .env.local .env.development .env.development.local \
           .env.production .env.production.local; do
    [ -f "$f" ] && printf '%s\n' "$f"
  done
}

# parse_env FILE -> emits "NAME<TAB>VALUE" for each assignment. Strips `export`,
# surrounding quotes, inline comments on unquoted values, and blank/comment lines.
parse_env() {
  awk -F= '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
      line=$0
      sub(/^[[:space:]]*export[[:space:]]+/, "", line)
      eq=index(line,"=")
      if (eq==0) next
      name=substr(line,1,eq-1); val=substr(line,eq+1)
      gsub(/[[:space:]]/,"",name)
      if (name !~ /^[A-Za-z_][A-Za-z0-9_]*$/) next
      # strip matching surrounding quotes; else drop trailing inline comment
      if (val ~ /^".*"$/)      { val=substr(val,2,length(val)-2) }
      else if (val ~ /^'"'"'.*'"'"'$/) { val=substr(val,2,length(val)-2) }
      else                     { sub(/[[:space:]]+#.*$/,"",val); gsub(/[[:space:]]+$/,"",val) }
      printf "%s\t%s\n", name, val
    }' "$1"
}

hr() { printf '  %s\n' "------------------------------------------------------------"; }

# ----------------------------------------------------------- collect env (names+values)
# Values are held only in shell locals; they are NEVER printed.

ENV_PRESENT=0
declare -a E_NAME E_VALUE E_FILE
while IFS= read -r ef; do
  ENV_PRESENT=1
  while IFS=$'\t' read -r n v; do
    [ -n "$n" ] || continue
    E_NAME+=("$n"); E_VALUE+=("$v"); E_FILE+=("$ef")
  done < <(parse_env "$ef")
done < <(env_files)

# ============================================================================ STAGED
# Pre-commit mode: only the fast, build-free checks, scoped to what's being committed.
# Blocks the commit (exit 1) on a mis-prefixed secret or a hardcoded secret literal.

if [ "$STAGED" -eq 1 ]; then
  staged=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
  found=0

  # (a) a .env file staged for commit is almost always a mistake
  envstaged=$(printf '%s\n' "$staged" | grep -E '(^|/)\.env(\.[A-Za-z]+)*$' | grep -vE '\.(example|sample|template)$' || true)
  if [ -n "$envstaged" ]; then
    found=1
    printf '%s🚨 .env file staged for commit:%s\n' "$R" "$X"
    printf '%s\n' "$envstaged" | sed 's/^/     /'
    echo "     -> unstage it and add the pattern to .gitignore."
  fi

  # (b) mis-prefixed secret: a NEXT_PUBLIC_* var whose name looks secret-ish
  for i in "${!E_NAME[@]}"; do
    n="${E_NAME[$i]}"
    case "$n" in NEXT_PUBLIC_*)
      base="${n#NEXT_PUBLIC_}"
      if ! is_allowlisted "$n" && printf '%s' "$base" | grep -Eiq "($NAME_RE)"; then
        found=1
        printf '%s🚨 mis-prefixed secret:%s %s — NEXT_PUBLIC_ vars ship to the browser.\n' "$R" "$X" "$n"
      fi ;;
    esac
  done

  # (c) hardcoded secret-shaped literals in staged source files
  src=$(printf '%s\n' "$staged" | grep -E '\.(ts|tsx|js|jsx|mjs|cjs)$' | grep -vE '(^|/)(node_modules|\.next)/' || true)
  if [ -n "$src" ]; then
    while IFS= read -r f; do
      [ -f "$f" ] || continue
      while IFS=: read -r ln _; do
        [ -n "$ln" ] || continue
        found=1
        printf '%s🚨 hardcoded secret-shaped literal:%s %s:%s\n' "$R" "$X" "$f" "$ln"
      done < <(grep -nEo "$VALUE_RE" "$f" 2>/dev/null | cut -d: -f1 | sort -un | sed 's/$/:/')
    done < <(printf '%s\n' "$src")
  fi

  if [ "$found" -eq 1 ]; then
    printf '\n%sCommit blocked by secret-audit.%s Fix the above, or `git commit --no-verify` to override.\n' "$B" "$X"
    exit 1
  fi
  exit 0
fi

# ============================================================================ FULL REPORT

APP=$(basename "$(pwd)")
printf '%sSECRET LEAK AUDIT — %s%s\n\n' "$B" "$APP" "$X"

# ---------------------------------------------------------------- 1. hygiene (git)
echo "Hygiene"
hr
if [ -f .gitignore ] && grep -qE '(^|/)\.env' .gitignore; then
  printf '  %s✓%s  .env is gitignored\n' "$G" "$X"
else
  printf '  %s⚠%s  .env is NOT in .gitignore — add `.env*` (keep `!.env.example`)\n' "$Y" "$X"
fi
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  committed=$(git log --all --oneline -- .env .env.local .env.production 2>/dev/null | head -1)
  if [ -n "$committed" ]; then
    LEAK=1
    printf '  %s🚨%s  a .env file appears in git history — rotate those secrets and purge history\n' "$R" "$X"
  else
    printf '  %s✓%s  no .env file in git history\n' "$G" "$X"
  fi
fi
echo

if [ "$ENV_PRESENT" -eq 0 ]; then
  printf '  No .env file found in %s — nothing to audit.\n' "$APP"
  echo "  (Looked for .env, .env.local, .env.*.local in Next.js load order.)"
  exit 0
fi

# ---------------------------------------------------------------- 2. mis-prefix scan
echo "Mis-prefixed vars (NEXT_PUBLIC_* that look secret)"
hr
mis=0
for i in "${!E_NAME[@]}"; do
  n="${E_NAME[$i]}"; v="${E_VALUE[$i]}"
  case "$n" in NEXT_PUBLIC_*)
    is_allowlisted "$n" && continue
    base="${n#NEXT_PUBLIC_}"
    if printf '%s' "$base" | grep -Eiq "($NAME_RE)" || printf '%s' "$v" | grep -Eq "$VALUE_RE"; then
      LEAK=1; mis=1
      printf '  %s🚨%s  %s — name/value is secret-shaped but ships to the browser\n' "$R" "$X" "$n"
    fi ;;
  esac
done
[ "$mis" -eq 0 ] && printf '  %s✓%s  no secret-shaped NEXT_PUBLIC_ vars\n' "$G" "$X"
echo

# ---------------------------------------------------------------- 3. client-code refs
echo "Secrets referenced in client code (\"use client\")"
hr
clientfiles=$(grep -rlE '^[[:space:]]*["'"'"']use client["'"'"']' \
  --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
  src app components lib 2>/dev/null || true)
cref=0
if [ -n "$clientfiles" ]; then
  for i in "${!E_NAME[@]}"; do
    n="${E_NAME[$i]}"
    case "$n" in NEXT_PUBLIC_*) continue ;; esac
    is_secret_name "$n" || continue
    hits=$(printf '%s\n' "$clientfiles" | xargs grep -nE "process\.env\.$n\b" 2>/dev/null || true)
    if [ -n "$hits" ]; then
      LEAK=1; cref=1
      printf '  %s🚨%s  %s read inside a client component:\n' "$R" "$X" "$n"
      printf '%s\n' "$hits" | sed 's/^/         /'
    fi
  done
fi
[ "$cref" -eq 0 ] && printf '  %s✓%s  no server-only vars read in client components\n' "$G" "$X"
echo

# ---------------------------------------------------------------- 4. hardcoded literals
echo "Hardcoded secret-shaped literals in source"
hr
hard=$(grep -rnEo "$VALUE_RE" \
  --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
  --include='*.mjs' --include='*.cjs' \
  src app components lib scripts 2>/dev/null | cut -d: -f1,2 | sort -u || true)
if [ -n "$hard" ]; then
  LEAK=1
  printf '%s\n' "$hard" | while IFS= read -r loc; do
    printf '  %s🚨%s  secret-shaped literal at %s\n' "$R" "$X" "$loc"
  done
else
  printf '  %s✓%s  no secret-shaped literals in source\n' "$G" "$X"
fi
echo

# ---------------------------------------------------------------- 5. dynamic bundle scan
echo "Bundle scan (.next/static)"
hr
if [ "$DO_BUILD" -eq 1 ]; then
  echo "  Running pnpm build (this can take a minute)..."
  if ! pnpm build >/dev/null 2>&1; then
    printf '  %s⚠%s  pnpm build failed — fix the build, then re-run with --build\n' "$Y" "$X"
  fi
fi
if [ -d .next/static ]; then
  printf '  %-26s %-13s %-10s %s\n' "VAR" "PREFIX" "IN BUNDLE" "VERDICT"
  for i in "${!E_NAME[@]}"; do
    n="${E_NAME[$i]}"; v="${E_VALUE[$i]}"
    # skip empty/short values (entropy too low to match reliably)
    [ "${#v}" -ge 8 ] || continue
    case "$n" in
      NEXT_PUBLIC_*)
        in_bundle=$(grep -rlF -- "$v" .next/static 2>/dev/null | head -1 || true)
        [ -n "$in_bundle" ] && state="yes" || state="no"
        printf '  %-26s %-13s %-10s %sok (public by design)%s\n' "$n" "public" "$state" "$G" "$X"
        ;;
      *)
        is_secret_name "$n" || continue   # only worry about secret-shaped server vars
        in_bundle=$(grep -rlF -- "$v" .next/static 2>/dev/null | head -1 || true)
        if [ -n "$in_bundle" ]; then
          LEAK=1
          printf '  %-26s %-13s %s%-10s LEAK -> %s%s\n' "$n" "server-only" "$R" "YES" "$in_bundle" "$X"
        else
          printf '  %-26s %-13s %-10s %ssafe%s\n' "$n" "server-only" "no" "$G" "$X"
        fi
        ;;
    esac
  done
else
  printf '  %sno build found%s — run `/spec-secrets build` (or re-run with --build) for the\n' "$Y" "$X"
  echo "  definitive browser-exposure check. Static checks above still apply."
fi
echo

# ---------------------------------------------------------------- summary
hr
if [ "$LEAK" -eq 1 ]; then
  printf '  %s🚨 Findings above need attention.%s Values were redacted — only names/locations shown.\n' "$R$B" "$X"
  exit 1
else
  printf '  %s✓ No secret leaks detected.%s\n' "$G$B" "$X"
  exit 0
fi
