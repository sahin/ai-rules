# 🚪 APPROVAL GATE - NO EXCEPTIONS

## FUNDAMENTAL RULE

**NO ACTION WITHOUT EXPLICIT APPROVAL**

## 🔒 APPROVAL REQUIREMENTS

### Valid Approval Signals:
- "yes"
- "proceed"
- "go ahead"
- "approved"
- "continue"
- "do it"
- "okay" / "ok"

### Invalid (DO NOT PROCEED):
- Questions about the plan
- Suggestions for changes
- Silence
- Unrelated comments
- "Let me think about it"

## 🛑 GATE ENFORCEMENT

```
if (!user_approved) {
  STOP();
  WAIT();
  DO_NOTHING();
}
```

## 📊 VIOLATION TRACKING

Acting without approval = CRITICAL VIOLATION

This includes:
- Writing code
- Running commands
- Making changes
- Creating files
- Any implementation action

## ✅ PROPER FLOW

1. Create plan
2. Present plan
3. Ask "Would you like me to proceed?"
4. **WAIT FOR EXPLICIT APPROVAL**
5. Only then implement

## ✅ Allowed Without Explicit Approval (Non-destructive)

Allowed (examples):
- Documentation-only fixes (typos, grammar, broken links, headings/anchors)
- Rule index/manifest sync (e.g., `.claude/rules/user/rule-manifest.json`) and router cross-link fixes that don’t change behavior
- CI/docs linters configuration (markdown link checker, markdownlint) that have no effect on build/deploy behavior
- Formatting-only changes (Prettier/ESLint) and comment wording updates
- Image/asset metadata updates (alt text, captions) without changing JS/CSS
- Internal references/anchors across rules and docs
- Non-functional updates to `README`/`CHANGELOG`/docs (no new runtime requirements)

Not allowed (non-examples — approval required):
- Any code or configuration that changes runtime behavior (even if “small”)
- Build/CI changes affecting test selection, build flags, env vars, cache keys, or release steps
- Dependency changes (add/remove/upgrade/downgrade), lockfile modifications
- Feature flags, environment files, CORS/CSRF/security settings, auth flows
- Rule changes that alter scope/requirements or introduce new obligations
- Secrets/credentials rotation or any sensitive value changes
- Database migrations, schema changes, or docs that imply functional changes

Quick decision test:
- If it impacts user-visible behavior, production build, tests, security, or data → STOP and get approval.

## 🚨 EMERGENCY OVERRIDE

Only valid with explicit statement:
```
EMERGENCY: OVERRIDE APPROVAL
Reason: [Production outage/Security incident]
```

Without this exact format → WAIT FOR APPROVAL