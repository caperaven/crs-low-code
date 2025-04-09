# View DSL

## Index
1. [DSL](./_dsl.md)
2. [Index](./../index.md)

## Introduction
The purpose of the dsl is to:

1. Define layout structure
2. Enable UI manipulation based on triggers.

## Example

```
ENTITY: AuditDashboardForm, 1.0.0, "Audit viewer"

PARAMETERS:
  loadAudits: FUNC
  showAudits: BOOL = false

STATE:
  auditTrail: COLLECTION OF Audit = EMPTY
  showAudits: @@showAudits
  context: PermissionContext

CONDITIONS:
  isAdmin: @context.role = "admin"
  hasAudits: LENGTH OF @auditTrail > 0

TEMPLATES:
  no-audits:
    LAYOUT:
      DIV:
        content: "No audits available"

  card:
    PARAMETERS:
      title: STR

    LAYOUT:
      DIV:
        class: "card"

        HEADER:
          content: @title

        SLOT: content

        SLOT: footer
          WHEN isAdmin?

LAYOUT:
  ~card:
    title: "Welcome to the audit dashboard"

    IN SLOT content:
      TEXT: "Below you'll find the audit records."

    IN SLOT footer:
      BUTTON:
        label: "Admin Settings"

  IF @showAudits:
    ASYNC:
      loader: @loadAudits
      target: @auditTrail

      FOR @auditTrail AS audit:
        DIV:
          id: CONCAT("audit-", audit.id)
          content: CONCAT(audit.type, " on ", audit.timestamp)
  ELSE ~no-audits

VIEW_LOGIC:
  #auditLog:
    visible: hasAudits?

STYLE:
  #auditLog:
    font-style: italic
    color: VAR(cl-warning-fg)
```

## API

1. insertBefore     - insert widget before the defined target widget
1. insertBeforeFor  - insert widget before, for a given entity property definition
1. insertAfter      - insert widget after the defined target widget
1. setAttribute     - set an attribute value on the defined target widget
1. getAttribute     - get the value of an attribute for the defined widget
1. toggleAttribute  - toggle boolean attribute on defined widget
1. remove           - remove from the dom a given element