# RuboCop TODO Checker - docker action

### Concepts
This action will use the `.rubocop_todo.yml` from your project and will determine if new offenses were added in the current commit.

How it works:
 - parse `rubocop_todo.yml` and extract number of offenses for each Cop.
 - execute `rubocop --auto-gen-config` to generate the new config.
 - parse again `rubocop_todo.yml` and extract number of offenses for each Cop.
 - make a diff between old offense and new offense.
 - if new offenses > old offenses it will print how many offenses were added and to which Cops.
 - prints a summary.

### Example usage:
```yaml
# .github/workflows/rtc.yml

---
name: RuboCop TODO checker

on: [push]

jobs:
  rtc:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: gimmyxd/rtc-action@0.0.3.pre
```

### Example Job Result
![alt text](https://i.postimg.cc/ZRPdgN6q/Screenshot-2020-02-27-at-23-27-02.png)
