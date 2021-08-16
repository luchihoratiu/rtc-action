# RuboCop TODO Checker
test

![alt text](https://img.shields.io/badge/RUBY-~>2.3-red)
![alt text](https://img.shields.io/badge/VERSION-0.1.1-brightgreen)

### Docker based github action usses ruby and rubocop.

### Concepts
This action will use `rubocop --auto-gen-config` to determine if new offenses were added in the current PR.

How it works:
 - get a list of changes files.
 - execute `rubocop --auto-gen-config --format j` to get the offenses for the changed files.
 - move back before the merge commit.
 - execute `rubocop --auto-gen-config --format j` to get the offenses for the changed files before the PR.
 - parse again the extracted data and make a  diff between old offenses and new offenses.
 - print a summary containing the new offenses per file and cop.

### How to use PR updates functionality:
 - is recommended to create a separate github user that will only have read access and will post updates.
 - generate a token that has read access.
 - set the token in workflow definition as:

 ```
 env:
  RTC_TOKEN: ${{ secrets.YOUR_TOKEN }}
  UPDATE_PR: true
 ```

### ENV configurations:
```
  RTC_TOKEN: ${{ secrets.YOUR_TOKEN }} # token used for posting updates
  UPDATE_PR: bool # weather to post updates as comments or not
  FORCE_ERROR_EXIT: bool # force the job to be mark as failed if new offenses are added
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
      - uses: gimmyxd/rtc-action@0.2.0
        env:
          RTC_TOKEN: ${{ secrets.RTC_TOKEN }}
          UPDATE_PR: true
```

### Example Job Result
![alt text](https://i.postimg.cc/Vk3f0BNH/Screenshot-2020-02-28-at-00-51-56.png)
