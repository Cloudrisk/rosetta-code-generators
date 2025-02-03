# Rune Python Generator

This repository contains both a Python CDM implementation and the code to generate the package from Regnosys' [Rune](https://github.com/finos/rune-dsl) specifications.  
 
The implementation follows the same approach as those completed for other languages such as C# in that it does not include the complete scope of functionality available in the Java implementation.

The Python package requires Python version 3.10+.

## License

[License terms](<https://portal.cdm.rosetta-technology.io/#/terms-isda>) 

## Contributors
- [CloudRisk](https://www.cloudrisk.uk)
- [FT Advisory LLC](https://www.ftadvisory.co)
- [TradeHeader SL](https://www.tradeheader.com)

## Repository Organization

- `README.md` - this file, for documentation purposes
- `src/main`  - Java/Xtend code to generate Python from Rune
- `src/main/resources`  - the package and source for building the Python Rosetta Runtime library used by the generated code
- `src/test`  - Java/Xtend code to run JUnit tests on the code generation process
- `build/build_cdm.sh` - used to create a Python package from code generated using CDM Rune definitions
- `build/resources` - configuration scripts to setup and tear down the Python unit testing environment
- `test` - Python unit tests and scripts to run the tests

# Generation 

At present, the only way to generate the Python code itself is by running a unit test in a development environment.

The following instructions are based on directions found at:

[https://github.com/REGnosys/rosetta-code-generators](https://github.com/REGnosys/rosetta-code-generators)

[https://github.com/REGnosys/rosetta-code-generators/issues/149](https://github.com/REGnosys/rosetta-code-generators/issues/149)

# Building and Testing
See below and [BUILDANDTEST.md](BUILDANDTEST.md) for instructions on building and testing

## Prerequisites

[Eclipse 2021 (JSEE) + xtend support Eclipse IDE for Java and DSL Developers](https://www.eclipse.org/downloads/packages/release/2021-12/r/eclipse-ide-java-and-dsl-developers)

[Git](https://git-scm.com/)

[Maven](http://maven.apache.org/)

## Installation Steps

1. Create a directory structure hereafter referred to as [CODEGEN]
```
mkdir -p [CODEGEN]/.m2
mkdir -p [CODEGEN]/github/REGnosys
```

2. Fork and clone the generator 

Fork a copy from `https://github.com/REGnosys/rosetta-code-generators` ([MYREPO])

```
cd [CODEGEN]/github/REGnosys/
git clone https://github.com/[MYREPO]/rosetta-code-generators.git
```

3. Run a clean maven install 

```
cd [CODEGEN]/github/REGnosys/rosetta-code-generators/python
mvn -s clean install
```
All the tests should pass.

More build and testing instructions can be found in [BUILDANDTEST.md](./BUILDANDTEST.md)

# Reading From and Writing To a String

The generated Python code can deserialize and serialize an object.

## Deserializing from a string

To deserialize from a string and create a object of the model specified in the string invoke the function:

`BaseDataClass.rune_deserialize` with the following parameters

    rune_json (str): A JSON string.

    validate_model (bool, optional): Validate the model after
    deserialization. It checks also all Rune type constraints. Defaults
    to True.

    strict (bool, optional): Perform strict attribute validation.
    Defaults to True.

    raise_validation_errors (bool, optional): Raise an exception in
    case a validation error has occurred. Defaults to True.

    Returns:
      BaseModel: The Rune model.

To serialize from an object ("[obj]") of a generated class, invoke the function:

`[obj].rune_serialize` with the following parameters:

    validate_model (bool, optional): Validate the model prior
    serialization. It checks also all Rune type constraints.
    Defaults to True.

    strict (bool, optional): Perform strict attribute validation. 
    Defaults to True.

    raise_validation_errors (bool, optional): Raise an exception in
    case a validation error has occurred. Defaults to True.

    indent (int | None, optional): Indentation to use in the JSON
    output. If None is passed, the output will be compact. Defaults to
    None.

    include (IncEx | None, optional): Field(s) to include in the JSON
    output. Defaults to None.

    exclude (IncEx | None, optional): Field(s) to exclude from the
    JSON output. Defaults to None.

    context (Any | None, optional): Additional context to pass to the
    serializer. Defaults to None.

    by_alias (bool, optional): Whether to serialize using field
    aliases. Defaults to False.

    exclude_unset (bool, optional): Whether to exclude fields that
    have not been explicitly set. Defaults to True.

    exclude_defaults (bool, optional): Whether to exclude fields that
    are set to their default value. Defaults to True.

    exclude_none (bool, optional): Whether to exclude fields that have
    a value of `None`. Defaults to False.

    round_trip (bool, optional): If True, dumped values should be
    valid as input for non-idempotent types such as Json[T]. Defaults to
    False.

    warnings (bool | Literal['none', 'warn', 'error'], optional): How
    to handle serialization errors. False/"none" ignores them,
    True/"warn" logs errors, "error" raises a
    PydanticSerializationError`. Defaults to True.

    serialize_as_any (bool, optional): Whether to serialize fields
    with duck-typing serialization behavior. Defaults to False.

    Returns:
      A string.

# To Generate CDM from Rune

Use this script to generated the Python version of CDM
```sh
build/build_cdm.sh
```
This will generate CDM from the master branch of the [FINOS Repo](https://github.com/finos/common-domain-model)

To use a different version of CDM, update CDM_VERSION in the script.