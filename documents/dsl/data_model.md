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
ENTITY: Person, 1.0.1, "Person entity"
  REST:
    collection: "/people"
    item      : "/people/{id}"
    create    : "/people"
    delete    : "/people/{id}"
    update    : "/people/{id}"

  COLLECTIONS:
    roles: ENUM
      0=user
      1=admin
      2=superadmin

    options: ARRAY = [1, 2, 3]

    values: ARRAY = [
        {id: 1, name: "One"},
        {id: 2, name: "Two"},
        {id: 3, name: "Three"}
    ]

  PROPERTIES:
      id     : INT REQUIRED AUTO_INCREMENT PRIMARY_KEY READONLY
      name   : STR REQUIRED MIN_LENGTH=1 MAX_LENGTH=100
      age    : INT REQUIRED MIN=18 MAX=65
      email  : EMAIL
      notes  : STR MAX_LENGTH=1000
      role   : ENUM roles DEFAULT=user
      active : BOOLEAN DEFAULT=true
      option : INT IN options
      value  : INT IN values

  VALIDATIONS:
    inactive_role_is_null:
      IF active IS FALSE
      THEN role MUST BE NULL

  TRIGGERS:
    on_active_changed:
      IF active IS FALSE
      THEN SET role TO NULL
      AND SET notes TO "User is inactive"
```