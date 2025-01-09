# _Hot Fix for Pydantic and Switch_

_What is being released?_

This release contains hot fixes to make the Python generator compatible with CDM 5.x.x.  The changes will
not address CDM 6 compatibility.

- Pydantic: the version is limited to >=2.6.1 and <2.10.0.  Thhis removes an issue identified with Pydantic 2.10+
- Addition of support for the Rune Switch, Deep Path, Min and Max operators
- Refactoring of test cases including addition of more Python unit tests

_Issues to be closed with this release_
- [Python code generator should support ->> #304](https://github.com/REGnosys/rosetta-code-generators/issues/304)
- [Python code generator should support default operator #302](https://github.com/REGnosys/rosetta-code-generators/issues/302)
- [Python generator - defects in the runtime functions #366](https://github.com/REGnosys/rosetta-code-generators/issues/366)
- Partially Closed: [Python generator does not implement all Rosetta expressions #246](https://github.com/REGnosys/rosetta-code-generators/issues/246)