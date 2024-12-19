# **Python libraries and dependencies local installation:**
1. From **python/build**:
   2. Run _build_python_rosetta.sh_ using git bash\
        `sh build_python_rosetta.sh`
3. From **python/src/main/resources/runtime**:
   4. Run _build_runtime.sh_ using git bash\
      `sh build_runtime.sh`
5. From **python/src/main/resources/runtime**:
   6. Copy the absolute path for the file rosetta_runtime-2.0.0-py3-none-any.whl
   7. Run `pip install _absolute path_`
8. From **python/target/python**:
   9. Copy the absolute path for the file python_cdm-0.0.0-py3-none-any.whl
   10. Run `pip install _absolute path_`