# RuboCop TODO Checker

![alt text](https://img.shields.io/badge/RUBY-~>2.3-red)
![alt text](https://img.shields.io/badge/VERSION-0.1.0-brightgreen)

### Docker based github action usses ruby and rubocop.

### Concepts
This action will use `.rubocop_todo.yml` and will determine if new offenses were added in the current commit.

How it works:

 - parse `rubocop_todo.yml` and extract number of offenses for each Cop.
 - execute `rubocop --auto-gen-config` to generate the new config.
 - parse again `rubocop_todo.yml` and extract number of offenses for each Cop.
 - make a diff between old offenses and new offenses.
 - if `new offenses > old offenses` it will print how many offenses were added and to which Cops.
 - prints a summary.

### How to use PR updates functionality:
 - is recommended to create a separate github user that will only have read access and will post updates.
 - generate a token that has read access.
 - set the token in workflow definition as:

 ```
 env:
  RTC_TOKEN: ${{ secrets.YOUR_TOKEN }}
  UPDATE_PR: true
 ```

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
      - uses: gimmyxd/rtc-action@0.0.5
```

### Example Job Result
![alt text](https://i.postimg.cc/Vk3f0BNH/Screenshot-2020-02-28-at-00-51-56.png)
