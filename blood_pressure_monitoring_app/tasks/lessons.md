# Lessons Learned

## 2026-03-02 — Questionnaire Template Feedback (Anthony)

**Pattern**: When stakeholders give feedback on form/survey UX, apply changes to *all* template repositories (Firebase + Mock) — they share duplicated template definitions.

**Lesson**: The "last meal" dateTime picker was too complex for morning reporting (user has to navigate a full calendar). A simple "Today / Yesterday" multiple-choice + time picker is more practical. Always consider the *context* users are in when they fill out forms.

**Lesson**: Avoid redundant questions in questionnaire flows. The BP tracker had both "Which arm?" (multipleChoice) *and* a table question that also offered Left/Right — the table question should have asked for the actual readings (systolic/diastolic) instead of duplicating the arm selection.
