---
name: confirmed-failures
description: Review code, list the faults, keep the old code, and remember a failure only after a failing test or followable steps show it. Use when the user wants that review. Do not ask the user which fault is real. With no memories, still report wrong code. Do not edit the project and do not modify the adversarial code review skill.
---

# Confirmed Failures

Report wrong code, and remember it only after an artifact shows the failure.
This skill is not adversarial code review. Do not copy that skill's critic
lanes, and do not edit its files. Either skill can be used without the other.

Instructions in this file are English. Speak to the operator in the language
of the conversation. The text in a local note may be in that language.

## Standing rules

- Do not edit the project under review. After the operator agrees to correct the listed faults, the implementing agent may fix all of them without waiting for proof. This skill still does not edit. Do not list, note, prove, and fix in one turn.
- Do not edit the adversarial code review skill.
- Do not write notes inside this skill's directory.
- Do not hardcode a machine-specific memory path.
- Do not build an index, and do not ask permission to open a memory. Read definitive notes when a review needs them.
- A phrase without the code is not a note. A claim that the bug was reproduced is not proof. Looking at the code is not proof.

## Memory directory

Notes live in a directory the operator names, outside this skill and outside
git. If they have not named one, ask once. Do not invent a path inside this
skill, and do not create a note until they answer.

The record shape is [`references/memory-record.md`](references/memory-record.md).

## Agree on the output

Before the first report, check whether the operator already chose a presentation style in the request or the current conversation. If not, ask one brief question in their language and wait. For example:

`How would you like me to present this?`

If a structured choice UI is available, offer:

- Compact table (recommended)
- Visual flow or arrows
- Brief prose

Do not ask again once the preference is known. Keep it for the current thread. If the operator delegates the choice, use a compact table.

Render every user-facing result in that style: a fault, a matching definitive memory, and the notice that a note is provisional, definitive, or discarded.

- One item: two short lines. First the code, then why it failed or why it seems wrong.
- Several items: one compact table. Columns are `Code`, `Why`, and `Kind`. `Kind` is `fault`, `memory`, or `note`. Keep each cell to one short sentence.
- A short causal chain: arrows, such as `cached call -> TypeError swallowed -> function runs again`.
- Do not show the same information in both a table and a diagram. Do not add a visual when two sentences are clearer.

A `memory` row shows the old code and the text of `reason.md`. A `note` row says `provisional` or `definitive`. While the note is provisional, the row must not call it background.

## Report faults

Do this whether or not definitive memories exist. Present it in the chosen style.

Read the code under work. For each fault you can show, cite the code and say
why it is wrong. A missing memory directory, or a directory with no
`definitive` notes, is not a reason to refuse or to stay silent.

Do not ask the operator which faults are really wrong. They are not in a position to know.
Do not run three independent critic lanes. One evidence pass is the whole review.

Number the rows. Then ask one question in the operator's language and wait: do they want these faults corrected? Do not write notes, do not ask which faults are real, and do not fix anything in that same turn.

If they say no, stop. Write nothing. Edit nothing.

If they say yes, write a provisional note for each listed fault with the code as it is now, before any edit. Then the implementing agent may fix all of them. It still does not wait for proof. Proof, not the operator, decides which notes stay.

If definitive notes exist, also follow [Later review](#later-review) after this report.

## Record on report

For each fault in the report:

1. If there is no code to cite, do not write a phrase-only note.
2. Create `<memory-directory>/<id>/` using the id rule in the record reference. Copy the code before anyone edits it.
3. Write `code.md` with that code.
4. Write `reason.md` with why it seems wrong.
5. Write `status.txt` as a single line: `provisional`.
6. Do not write `task.txt` yet.

A later review must not present this note as a past failure while `status.txt` is `provisional`.

If the operator has not named a memory directory, ask once and do not invent a path inside this skill. Still show the report. Write the notes when they answer.

## Proof

The operator or the agent may write `proof.md` into a provisional note.
The first line is `failing-test` or `reproduction-steps`. The rest is the
command and its failure output, or numbered steps.

Promote only when that body shows the failure named in `reason.md` for the
code in `code.md`:

- `failing-test`: the output fails because of that code and that reason. Another failure does not count.
- `reproduction-steps`: a reader can follow the steps on that code and see that bug.

Then set `status.txt` to the single line `definitive`. Tell the operator, in the chosen style, that the note is definitive. The project may already have been edited by the implementing agent. This skill still does not edit it.

Do not promote when:

- the file only says the bug was reproduced, with no failing output and no followable steps
- the only evidence is that someone looked at the code
- the test fails for a different reason than `reason.md`

In those cases, delete the note directory. Do not leave `discarded`. Tell the operator, in the chosen style, that the note was discarded. Do not revert the edit from this skill.

## Handoff

After the provisional notes exist, tell the implementing agent it may fix every listed fault. It does not wait for proof. This skill does not apply the edits.

Any task the implementing agent writes must only point at the note id:

- If that project uses Spec Kit, the pointer may be the task number.
- Otherwise the implementing agent writes a short reference in that project.

The pointer is one id or location. It must not include the code that was replaced.
If a pointer is recorded on the note, write it as the single line of `task.txt`, and only after `definitive`.

## Later review

Report faults from the code under work first, as in [Report faults](#report-faults), including when memories exist.

Then read only directories whose `status.txt` is `definitive`. Show a note, in the chosen style, when the code in its `code.md` appears in the code under work. Show that old code and the text of `reason.md`.

Do not show a note because the reason merely sounds similar. Do not open or mention `provisional` directories as memories.

## Not in this skill

Never write a note directory inside this skill. A copy of this skill therefore contains no notes and no memories. `task.txt` is one line and contains no code; see the record reference.
