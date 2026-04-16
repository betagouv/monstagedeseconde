---
name: commit
description: "Generate standard commit messages from staged git changes. Use when writing a commit message, summarizing staged files, or producing a conventional type-and-scope commit title from staged diffs."
argument-hint: "Paste the staged diff or describe the staged changes"
user-invocable: true
---

# Standard Commit Messages

Use this skill when generating a commit message from staged changes and the team wants a consistent conventional format.

## Goal

Produce a concise commit message that reflects the main intent of the staged changes and follows a standard activity, scope, and summary structure. 10 words or less is ideal for the title, and 1 to 2 sentences for the details summary.

## Commit Format

Use this structure:

type(scope): short imperative summary

[blank line]

details summary

Examples:
- feat(posts): add post filtering to index page

	Add category-based filtering to the posts index and update the request handling to preserve the selected filter.
- fix(auth): handle broken login redirect

	Correct the redirect target after sign in so users return to the intended page instead of the default dashboard.
- refactor(flash-messages): simplify flash message rendering

	Consolidate duplicated rendering logic and keep alert presentation consistent across pages.
- docs(seeds): document demo account seed data

	Clarify the available seeded accounts and the intended local development usage.

## When To Use

Use this skill for requests like:
- write a commit message from staged files
- summarize staged changes for a commit
- generate a standard conventional commit title
- turn a staged diff into a commit message
- produce a typed commit message for git commit

Do not use this skill for:
- writing release notes
- generating pull request titles unless explicitly requested
- summarizing unstaged or unrelated working tree changes unless explicitly requested

## Inputs

Prefer these inputs, in order:
1. The staged git diff
2. The staged file list with a short summary
3. A plain-language description of the staged changes

If the input mixes unrelated changes, say so and recommend splitting the commit.

## Procedure

1. Inspect the staged changes only.
2. Identify the primary intent of the change.
3. Choose one standard activity type from the allowed list.
4. Choose an abstract scope that describes the area being changed.
5. Write a concise imperative summary of what changes.
6. Output the commit title.
7. Skip one blank line.
8. Add a short details summary explaining the notable changes.

## Rules

- Use staged changes only.
- Use this exact title structure: `type(scope): summary`
- Choose `type` only from this limited list: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf`, `style`
- Use `:` as the separator after the closing scope.
- Choose a short abstract scope such as `auth`, `posts`, `search`, `ui`, `seeds`, `routing`, `build`, or `tests`.
- Keep the title concise and specific.
- Prefer imperative verbs such as add, fix, update, remove, refactor, rename.
- Keep the scope abstract and stable rather than tied to one filename.
- Avoid vague summaries like `misc updates` or `small fixes`.
- Do not mention implementation details unless they are central to the change.
- After the title, output one blank line and then a prose details summary.
- The details summary should explain what changed and why in 1 to 3 sentences.
- Do not output markdown fences.
- Do not output multiple alternatives unless asked.
- Do not give any piece of advice but only describe the change itself

## Decision Rules

- If one change clearly dominates, summarize that change.
- If several files support one feature or fix, summarize the feature or fix, not each file.
- If the staged changes contain unrelated work, state that the commit should be split.
- If the change is purely cleanup, prefer `refactor`, `chore`, or `style` depending on the intent.
- If the change updates developer-facing explanation only, use `docs`.
- If the change improves speed or query efficiency, use `perf`.

## Output Expectations
There is no presentation line like : "Here is a git commit message that follows the rules"

Default output:
- one commit title
- one blank line
- one short details summary

Optional extended output when requested:
- one commit title
- a blank line
- a longer details summary

## Completion Checklist

- Only staged changes were considered
- The message uses an allowed standard activity type
- The title follows the `type(scope): summary` format
- The scope is abstract and relevant to the change
- The summary is imperative and concise
- The output includes a blank line after the title
- The output includes a clear details summary
- The title reflects the main intent of the change
- Unrelated staged changes were flagged instead of forced into one message