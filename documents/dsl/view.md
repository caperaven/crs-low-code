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
ENTITY: Person, 1.0.1, "Person entity"
  HORIZONTAL_STACK: gap=1
    fullName
    active

  HORIZONTAL_GRID: height=auto
    COLUMN: width=50%
      firstName
      
    COLUMN: width=50%
      lastName
      
  notes: width=100% height=20
  
  STYLE:
    firstName: background=VAR(cl-error-bg) foreground=VAR(cl-error-fg)      
    firstName:focus background=VAR(cl-success-bg) foreground=VAR(cl-success-fg)
```