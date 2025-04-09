# Data Model DSL

## Index
1. [DSL](./_dsl.md)
2. [Index](./../index.md)

## Introduction
The purpose of the dsl is to:

1. Define Entities  - the core object that defines a data structure and everything related to that
2. Attributes       - the fields that contain the data and their types, and configuration
3. Validation       - how the entity is evaluated for being correct
4. Triggers         - side effects that happen when a entity value changes

## Example

```
ENTITY: Person, 1.0.1-stable, "Person entity"

COLLECTIONS:
  roles: ENUM INT
    0 = user
    1 = admin
    2 = superadmin

  options: ARRAY<INT> = [1, 2, 3]

  values: ARRAY<OBJECT>
    { id: 1, name: "One" }
    { id: 2, name: "Two" }
    { id: 3, name: "Three" }

PROPERTIES:
  id:
    type        : INT
    required    : true
    auto        : true
    primary_key : true
    readonly    : true

  name:
    type        : STR
    required    : true
    min_length  : 1
    max_length  : 100

  age:
    type        : INT
    required    : true
    min         : 18
    max         : 65

  email:
    type        : EMAIL
    unique      : true
    nullable    : true

  notes:
    type        : STR
    max_length  : 1000
    nullable    : true

  role:
    type        : ENUM roles
    default     : user

  active:
    type        : BOOL
    default     : true

  option:
    type        : INT
    in          : options

  value:
    type        : INT
    in          : values.id

  manager:
    type        : INT
    ref         : Person.id
    nullable    : true

  created_at:
    type        : DATETIME
    default     : NOW
    readonly    : true

  full_name:
    type        : STR
    computed    : CONCAT(name, " [", age, "]")

TRIGGERS:
  on_active_changed:
    IF active IS FALSE
    THEN
      SET role TO NULL
      AND SET notes TO "User is inactive"

GUARDS:
  prevent_name_change_if_inactive:
    ON UPDATE
    IF active IS FALSE AND name CHANGES
    THEN BLOCK WITH "Inactive users cannot change name"

  prevent_all_changes_if_inactive:
    ON UPDATE
    IF active IS FALSE AND NOT (active CHANGES)
    THEN BLOCK WITH "You cannot modify inactive users"

  prevent_delete_if_still_manager:
    ON DELETE
    IF EXISTS Person WHERE manager == THIS
    THEN BLOCK WITH "Cannot delete: this person is still someone's manager"

SIDE_EFFECTS:
  ON DELETE:
    FOR Person WHERE manager == THIS
    SET manager TO NULL

```