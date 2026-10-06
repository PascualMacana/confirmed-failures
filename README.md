# Confirmed Failures

A separate Agent Skill from [adversarial code review](https://github.com/PascualMacana/adversarial-code-review).
It remembers failures that were shown to be real, and it can still report wrong code when it has no memories.

## What it does

With an empty memory folder, it still reports code that is wrong. It does not need past cases to speak.

It asks whether to correct them, and it waits. It does not note, prove, and fix in that same step.
If the operator says yes, it saves each fault's code as it is, before any edit, with why it seems wrong.
That note is not background. The implementing agent may then fix every listed fault without waiting for proof.
This skill does not edit the project.
If the operator says no, nothing is written and nothing is edited.

The note becomes a definitive memory only when an artifact shows the failure:

- a test that fails because of that code, or
- steps that reproduce the bug and can be followed again.

Looking at the code does not count. An agent saying "I reproduced it" does not count.
The agent may write the test or the steps. The note is promoted only when the artifact itself shows the failure.

If the artifact does not show that failure, the note is discarded. The edit, if it already happened, is not undone by this skill.
A task may point at a definitive memory. It must not paste the code that was replaced.

On a later review, definitive memories that match the current code are shown as well as faults found with no background.
Provisional notes are not shown as past failures.

## What it does not do

- It does not replace or modify the adversarial code review skill. Either skill can be used without the other.
- It does not store memories inside this skill. Notes and definitive memories stay in a folder on the operator's machine. A copy of this skill does not include them.
- It does not treat a suspicion as experience.

## Model and agent compatibility

The skill follows the open [Agent Skills specification](https://agentskills.io/home). It uses only the portable `name` and `description` frontmatter fields. `agents/openai.yaml` is optional Codex UI metadata and does not change the workflow.

Compatibility depends on the coding agent loading `SKILL.md`, not on the underlying language model. The same skill can guide Codex, Claude, Gemini, Qwen, Grok, and other capable models.

| Agent/client | Support | Suggested location |
|---|---|---|
| [OpenAI Codex](https://learn.chatgpt.com/docs/build-skills) | Native | `~/.agents/skills/confirmed-failures` |
| [Claude Code](https://code.claude.com/docs/en/skills) | Native | `~/.claude/skills/confirmed-failures` |
| [Cursor](https://cursor.com/docs/skills) | Native | `~/.agents/skills/confirmed-failures` |
| [Gemini CLI](https://geminicli.com/docs/cli/skills/) | Native | `~/.gemini/skills/confirmed-failures` |
| [GitHub Copilot](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) | Native | `~/.agents/skills/confirmed-failures` |
| [Qwen Code](https://qwenlm.github.io/qwen-code-docs/en/users/features/skills/) | Native | `~/.qwen/skills/confirmed-failures` |
| Grok | Native | `~/.grok/skills/confirmed-failures` |
| Other coding agents or models | Manual fallback | Clone anywhere and ask the agent to read `SKILL.md` |

Grok also scans `.agents/skills` and `.claude/skills`. Recent Qwen Code builds also read `.agents/skills`. Gemini CLI also accepts `~/.agents/skills` on current builds. One copy in `~/.agents/skills` covers Codex, Cursor, Copilot, and those fallbacks. Claude Code and the Qwen and Grok native folders still want their own path if that fallback is not enabled.

## Install

For Codex, Cursor, Copilot, and the shared `.agents` folder:

```bash
git clone https://github.com/PascualMacana/confirmed-failures.git \
  ~/.agents/skills/confirmed-failures
```

For Claude Code:

```bash
git clone https://github.com/PascualMacana/confirmed-failures.git \
  ~/.claude/skills/confirmed-failures
```

For Qwen Code:

```bash
git clone https://github.com/PascualMacana/confirmed-failures.git \
  ~/.qwen/skills/confirmed-failures
```

For Grok:

```bash
git clone https://github.com/PascualMacana/confirmed-failures.git \
  ~/.grok/skills/confirmed-failures
```

For Gemini CLI, if it is not already reading `~/.agents/skills`:

```bash
git clone https://github.com/PascualMacana/confirmed-failures.git \
  ~/.gemini/skills/confirmed-failures
```

For a single project, copy this directory into that client's project skills folder, such as `.agents/skills/confirmed-failures`, `.claude/skills/confirmed-failures`, `.qwen/skills/confirmed-failures`, or `.grok/skills/confirmed-failures`.

## Use

Ask naturally:

```text
Use the confirmed-failures skill to review this change.
```

Codex users can invoke it as `$confirmed-failures`. Clients with slash commands may expose `/confirmed-failures`.

If the agent does not support automatic skill discovery:

```text
Read /path/to/confirmed-failures/SKILL.md and follow it to review this change.
```

Memories are not in this repository. The skill asks once where to keep them on that machine.
