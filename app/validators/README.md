Attachment Validators
====

These attachments are added, hopefully temporarily, from https://github.com/igorkasyanchuk/active_storage_validations. A dependency is not desired in this case as ActiveStorage
validations are planned to be added to Rails 6.1 (Rails is at 6.0.1 at time of writing).

The idea is that this codebase can depend on these validators while necessary. Once Rails
releases it's own validators for attachments, we should instead use these.

These validators are included within this codebase as the gem they are sourced from
was quickly thrown together as a patch. Against the disadvantage of a few more lines of
code in this application, we gain the ability to read and modify these validators as required.

