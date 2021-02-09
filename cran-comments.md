## Test environments

* local: ubuntu 20.04, R 4.0.3
* github actions: windows-latest, macOS-latest, ubuntu-20.04
* r-hub: windows-x86_64-devel, ubuntu-gcc-release, fedora-clang-devel
* win-builder: windows-x86_64-devel

## R CMD check results

0 errors | 0 warnings | 0 note

## Resubmission

* Improve reliability of tests to pass at any time.
* Improve how tests randomly wait before running.
* Remove non-ASCII characters from data.
