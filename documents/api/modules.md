# Modules

## Introduction

Modules are basically a grouping mechanism. 
The module name is used to group models, views, templates ...
Modules are exportable and importable.
This allows you to define modules as reusable features.

Though modules are about reusability, they also act as ways to structure large projects.
Having 1000 views in a single folder is just not maintainable.
More often than not you can group views into categories.
Modules allow you to create those categories and if you need them in a nother project they should be easily transferable.

## Module Config

We need a way to keep track of modules from a UI perspective.
When you define a model you define it as part of a module.
When you select a module we need a list of modules to select from.
The same goes for moving a model from one module to the next.

Module details are saved in a json document in the .lowcode folder.

## Actions

The module api includes the following actions.

1. create(id, name, description) - create a new module entry and folder.
2. disable(id) - changes are suspended.
3. enable(id) - changes are resumed.