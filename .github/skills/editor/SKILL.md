---
name: editor
description: "when generating content for ruby or slim files, follow the style and conventions of the existing codebase. Use the existing code as a guide for formatting, naming, and structure. When asked to write new code, prefer to reuse patterns and styles already present in the codebase."
argument-hint: "column style is preferred for new code, with 80 character line length."
user-invocable: true
---

# Editor Style Guide

- 80 characters per line length is preferred for new code.
- When generating content for ruby or slim files, follow the style and conventions of the existing code

## Guard clause
Use guard clauses to handle edge cases and errors early in the method, improving readability and reducing nesting.
```ruby
def example_method(param)
  return unless param.valid?

  # main logic here
end
```
Take note of the empty line after the guard clause, which helps visually separate the edge case handling from the main logic.


## Goal

Produce code that can be read in a column to avoid sight hidden characters and improve readability.



## When To Use

Use this skill when suggested to **add code** or **implement functionality or feature or fix a bug**:

Do not use this skill for:
- writing release notes
- generating pull request titles unless explicitly requested
- summarizing unstaged or unrelated working tree changes unless explicitly requested


## Procedure

1. Inspect existing code
2. Identify the style and conventions used in the codebase
3. Follow the identified style and conventions when generating new code
4. Ensure that the generated code is formatted correctly and adheres to the identified style and conventions

## Rules

- 80 character line length is preferred for new code.

## Decision Rules

- If a line of code was to reach 80 characteurs, then edit a carriage return.
- If a line of code was to was to reach 150 characters, then extend the 80 characters per line rule to 120 characters perline.


## Completion Checklist
- [ ] The generated code follows the style and conventions of the existing codebase.
- [ ] The generated code is formatted correctly and adheres to the identified style and conventions.
- [ ] The generated code is readable and can be read in a column without hidden characters.