# Visibility Matrix Contract

Source: Claude Design `04-Final.html` Social data model and Visibility Matrix section, cross-checked against the current Domain implementation and `VisibilityMatrixTests`.

The Claude preview confirms an 8 resource x 5 viewer matrix. Exact iframe table-cell DOM extraction is currently blocked, so this file records the implementation contract that is protected by 40 Domain tests. Do not change this behavior for Goal 6. If a later exported design table disagrees, update the matrix and tests in the same PR.

## Axes

Resources:

- `profile`
- `taskList`
- `taskDetail`
- `streak`
- `record`
- `bragPost`
- `cheerCount`
- `commentList`

Viewer relations:

- `owner`
- `mutual`
- `oneWay`
- `stranger`
- `blocked`

Task visibility:

- `.private`
- `.followers`
- `.public`

## Resource Matrix

| Resource | owner | mutual | oneWay | stranger | blocked | Visibility rule |
|---|---:|---:|---:|---:|---:|---|
| profile | yes | yes | yes | yes | no | public social shell unless blocked |
| taskList | yes | conditional | conditional | conditional | no | task-scoped |
| taskDetail | yes | conditional | conditional | conditional | no | task-scoped |
| streak | yes | conditional | conditional | conditional | no | task-scoped |
| record | yes | conditional | conditional | conditional | no | stricter record-scoped |
| bragPost | yes | yes | yes | yes | no | post shell visible unless blocked |
| cheerCount | yes | yes | yes | yes | no | visible with post shell unless blocked |
| commentList | yes | yes | yes | yes | no | visible with post shell unless blocked |

## Task-Scoped Rule

Applies to `taskList`, `taskDetail`, and `streak`.

| Task visibility | owner | mutual | oneWay | stranger | blocked |
|---|---:|---:|---:|---:|---:|
| nil | yes | no | no | no | no |
| private | yes | no | no | no | no |
| followers | yes | yes | yes | no | no |
| public | yes | yes | yes | yes | no |

## Record-Scoped Rule

Applies to `record`.

| Task visibility | owner | mutual | oneWay | stranger | blocked |
|---|---:|---:|---:|---:|---:|
| nil | yes | no | no | no | no |
| private | yes | no | no | no | no |
| followers | yes | yes | no | no | no |
| public | yes | yes | yes | yes | no |

## Goal 6 Rule

Goal 6 is visual only. It may display visibility labels or copy, but it must not change `canView(_:relation:taskVisibility:)`, repository filters, or migration defaults.
