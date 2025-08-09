# 📑 MANDATORY: Files-to-be-modified Content Preview

## Requirement
After the “Potential Impact” section in every plan, you MUST include a “Files to be modified” section that:
- Lists each file to be created/modified/deleted
- Shows the exact proposed content per file:
  - For JSON/YAML: full object as it will appear
  - For Markdown: excerpted section(s) to be replaced/added
  - For code: minimal diff-style snippet(s) sufficient to understand the change

## Format (use exactly)
```
Files to be modified:
- path/to/file.ext
  - Proposed content:
    ```<lang>
    ...content or minimal diff...
    ```
- path/to/another-file.md
  - Proposed content:
    ```markdown
    ...content or minimal diff...
    ```
```

## Notes
- Keep previews precise; avoid unrelated context
- If content is long, include only the edited section(s) and clearly mark additions/replacements
- This rule applies to all tasks, including documentation-only changes
