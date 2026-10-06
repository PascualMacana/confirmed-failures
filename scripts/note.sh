#!/usr/bin/env bash
# Create, promote, discard, and point at a confirmed-failures note.
# The agent decides whether a fault is real and whether proof matches it.
# This script only enforces the record shape.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  note.sh note --memory DIR --id ID --code-file FILE --reason-file FILE
  note.sh proof --note DIR --file FILE
  note.sh promote --note DIR
  note.sh discard --note DIR
  note.sh task --note DIR --pointer TEXT
EOF
  exit 2
}

skill_root=$(cd "$(dirname "$0")/.." && pwd)

die() {
  printf 'note.sh: %s\n' "$1" >&2
  exit 1
}

is_inside_skill() {
  local path=$1
  local abs
  abs=$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path") || return 1
  case "$abs" in
    "$skill_root"|"$skill_root"/*) return 0 ;;
    *) return 1 ;;
  esac
}

# Bash 3.2 aborts the script when a function returns non-zero and the caller
# did not use if/&&. End on success so a note outside the skill is allowed.
require_note() {
  local dir=$1
  [ -d "$dir" ] || die "note directory does not exist"
  [ -f "$dir/status.txt" ] || die "not a note (missing status.txt)"
  if is_inside_skill "$dir"; then
    die "refusing to touch a note inside the skill directory"
  fi
  return 0
}

status_of() {
  tr -d '\r\n' < "$1/status.txt"
}

cmd_note() {
  local memory="" id="" code_file="" reason_file=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --memory) memory=$2; shift 2 ;;
      --id) id=$2; shift 2 ;;
      --code-file) code_file=$2; shift 2 ;;
      --reason-file) reason_file=$2; shift 2 ;;
      *) usage ;;
    esac
  done
  [ -n "$memory" ] && [ -n "$id" ] && [ -n "$code_file" ] && [ -n "$reason_file" ] || usage
  [ -d "$memory" ] || die "memory directory does not exist"
  is_inside_skill "$memory" && die "memory directory must be outside the skill"
  printf '%s\n' "$id" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[a-z0-9]+(-[a-z0-9]+)*$' \
    || die "id must look like YYYY-MM-DD-short-slug"
  [ -f "$code_file" ] || die "code file does not exist"
  [ -s "$code_file" ] || die "code file is empty"
  [ -f "$reason_file" ] || die "reason file does not exist"
  [ -s "$reason_file" ] || die "reason file is empty"
  grep -Eq '[][(){}=<>;:+*/&|!-]' "$code_file" || die "code file looks like a phrase, not code"

  local dest="$memory/$id" n=2
  while [ -e "$dest" ]; do
    dest="$memory/${id}-${n}"
    n=$((n + 1))
  done
  mkdir "$dest"
  cp "$code_file" "$dest/code.md"
  cp "$reason_file" "$dest/reason.md"
  printf 'provisional\n' > "$dest/status.txt"
  printf '%s\n' "$dest"
}

validate_proof() {
  local file=$1
  [ -s "$file" ] || die "proof file is empty"
  local kind
  kind=$(head -n 1 "$file" | tr -d '\r')
  case "$kind" in
    failing-test|reproduction-steps) ;;
    *) die "proof must start with failing-test or reproduction-steps" ;;
  esac
  local body
  body=$(tail -n +2 "$file" | sed '/^[[:space:]]*$/d')
  [ -n "$body" ] || die "proof has no body"
  if [ "$kind" = "failing-test" ]; then
    printf '%s\n' "$body" | grep -Eq 'FAIL|ERROR|Error|AssertionError|Traceback|not equal|!=' \
      || die "failing-test body does not show a failure"
  else
    local lines
    lines=$(printf '%s\n' "$body" | wc -l | tr -d ' ')
    [ "$lines" -ge 2 ] || die "reproduction-steps needs more than a single claim"
  fi
}

cmd_proof() {
  local note="" file=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --note) note=$2; shift 2 ;;
      --file) file=$2; shift 2 ;;
      *) usage ;;
    esac
  done
  [ -n "$note" ] && [ -n "$file" ] || usage
  require_note "$note"
  [ "$(status_of "$note")" = "provisional" ] || die "proof can only be attached to a provisional note"
  validate_proof "$file"
  if [ "$(cd "$(dirname "$file")" && pwd)/$(basename "$file")" != "$(cd "$note" && pwd)/proof.md" ]; then
    cp "$file" "$note/proof.md"
  fi
  printf '%s\n' "$note/proof.md"
}

cmd_promote() {
  local note=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --note) note=$2; shift 2 ;;
      *) usage ;;
    esac
  done
  [ -n "$note" ] || usage
  require_note "$note"
  [ "$(status_of "$note")" = "provisional" ] || die "only a provisional note can be promoted"
  [ -f "$note/proof.md" ] || die "missing proof.md"
  validate_proof "$note/proof.md"
  printf 'definitive\n' > "$note/status.txt"
  printf '%s\n' "$note"
}

cmd_discard() {
  local note=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --note) note=$2; shift 2 ;;
      *) usage ;;
    esac
  done
  [ -n "$note" ] || usage
  require_note "$note"
  rm -rf "$note"
  printf 'discarded\n'
}

cmd_task() {
  local note="" pointer=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --note) note=$2; shift 2 ;;
      --pointer) pointer=$2; shift 2 ;;
      *) usage ;;
    esac
  done
  [ -n "$note" ] && [ -n "$pointer" ] || usage
  require_note "$note"
  [ "$(status_of "$note")" = "definitive" ] || die "task pointer is only allowed after definitive"
  case "$pointer" in
    *$'\n'*) die "pointer must be one line" ;;
  esac
  [ "${#pointer}" -le 200 ] || die "pointer is too long"
  local code_line
  while IFS= read -r code_line || [ -n "$code_line" ]; do
    code_line=$(printf '%s' "$code_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$code_line" ] && continue
    case "$code_line" in
      '```'*|'#'*) continue ;;
    esac
    case "$pointer" in
      *"$code_line"*) die "pointer must not contain the replaced code" ;;
    esac
  done < "$note/code.md"
  printf '%s\n' "$pointer" > "$note/task.txt"
  printf '%s\n' "$note/task.txt"
}

[ $# -ge 1 ] || usage
cmd=$1
shift
case "$cmd" in
  note) cmd_note "$@" ;;
  proof) cmd_proof "$@" ;;
  promote) cmd_promote "$@" ;;
  discard) cmd_discard "$@" ;;
  task) cmd_task "$@" ;;
  *) usage ;;
esac
