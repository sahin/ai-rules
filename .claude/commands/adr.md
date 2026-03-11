# Architecture Decision Records

Use this guide when making significant architectural decisions that affect the project long-term.

## When to Create an ADR

Create an ADR when:
- Choosing a framework, library, or major dependency
- Changing the project's architecture or patterns
- Making a decision that would be costly to reverse
- Resolving a technical debate within the team
- Deviating from established conventions

Do NOT create an ADR for:
- Routine coding decisions
- Bug fixes
- Minor dependency updates
- Style/formatting choices

## ADR Template

```markdown
# ADR-NNN: Title (short, descriptive)

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-NNN]

## Date
YYYY-MM-DD

## Context
What is the issue or question? What forces are at play?

Describe:
- The problem or decision that needs to be made
- Technical and business constraints
- Relevant quality attributes (performance, security, maintainability)
- What alternatives were considered

## Decision
What is the decision and why?

State clearly:
- The chosen approach
- Why it was selected over alternatives
- Any tradeoffs accepted

## Alternatives Considered

### Option A: [Name]
- **Pros**: ...
- **Cons**: ...
- **Why rejected**: ...

### Option B: [Name]
- **Pros**: ...
- **Cons**: ...
- **Why rejected**: ...

## Consequences

### Positive
- What becomes easier or better?

### Negative
- What becomes harder or worse?
- What are the accepted tradeoffs?

### Risks
- What could go wrong?
- How will we mitigate?

## References
- Links to relevant documentation, RFCs, discussions
```

## Status Lifecycle

```
Proposed -> Accepted -> [Active]
                     -> Deprecated (no longer relevant)
                     -> Superseded by ADR-NNN (replaced by new decision)
```

- **Proposed**: Under discussion, not yet agreed upon
- **Accepted**: Team has agreed, decision is active
- **Deprecated**: Decision is no longer relevant (technology removed, etc.)
- **Superseded**: A new ADR replaces this one (link to the new ADR)

## Storage and Naming

- Location: `docs/adr/` directory
- Naming: `NNN-short-description.md` (e.g., `001-use-postgresql.md`)
- Sequential numbering, never reuse numbers
- Keep all ADRs (including deprecated/superseded) for historical context

## Example ADR

```markdown
# ADR-001: Use PostgreSQL as Primary Database

## Status
Accepted

## Date
2024-01-15

## Context
We need a primary database for our application. Key requirements:
- ACID transactions for financial data
- JSON support for flexible metadata
- Strong ecosystem and tooling
- Horizontal read scaling capability

## Decision
Use PostgreSQL 16 as our primary database.

PostgreSQL provides ACID compliance, excellent JSONB support,
mature tooling (pgAdmin, pg_dump), and read replicas for scaling.
The team has existing PostgreSQL experience.

## Alternatives Considered

### MySQL 8
- **Pros**: Familiar, fast for simple queries
- **Cons**: Weaker JSON support, less extensible
- **Why rejected**: JSONB support is critical for our metadata model

### MongoDB
- **Pros**: Flexible schema, native JSON
- **Cons**: No ACID transactions across collections, eventual consistency
- **Why rejected**: Financial data requires strong consistency guarantees

## Consequences

### Positive
- Strong data integrity guarantees
- Excellent JSONB querying and indexing
- Large community and documentation

### Negative
- Vertical scaling limits (mitigated by read replicas)
- Schema migrations required for changes
- More complex setup than SQLite for local dev
```
