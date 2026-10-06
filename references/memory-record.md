# Memory record

Path: `<memory-directory>/<id>/`, outside this skill and outside git.

Write a note only with `scripts/note.sh`. The script enforces this shape.

The id is `YYYY-MM-DD-short-slug`. If that directory already exists, append `-2`, `-3`, and so on.

## Files

| File | When |
|---|---|
| `code.md` | Always, while the note exists. The code that was flagged. Not a phrase alone. |
| `reason.md` | Always, while the note exists. Why it failed or seems to have failed. |
| `status.txt` | Always. A single line: `provisional` or `definitive`. |
| `proof.md` | Only if a proof artifact exists. Starts with `failing-test` or `reproduction-steps`, then the command output or the steps. |
| `task.txt` | Only after definitive, and only if a pointer exists. One line, at most 200 characters: a task id or a location. No code. |

## Promotion

`status.txt` may change from `provisional` to `definitive` only when `proof.md` shows the failure in `reason.md`.

`failing-test` shows it when the command output fails because of the code in `code.md` and the reason in `reason.md`. A failure of some other cause does not.

`reproduction-steps` shows it when a reader can follow the steps on that code and see the bug named in `reason.md`. A sentence that only claims the bug was reproduced does not.

## Discard

Delete the directory. Do not leave `status.txt` as `discarded`.

## Visibility

A review that looks for past failures reads only directories whose `status.txt` is `definitive`. It does not read `provisional` directories as memories.

## Copying the skill

A copy of the skill directory includes none of these files, because they are not in it.
