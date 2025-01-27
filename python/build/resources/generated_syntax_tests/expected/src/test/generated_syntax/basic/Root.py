class Root(BaseDataClass):
    basicSingle: Optional[Annotated[test.generated_syntax.basic.BasicSingle.BasicSingle]] = Field(None, description='')
    basicList: Optional[Annotated[test.generated_syntax.basic.BasicList.BasicList]] = Field(None, description='')
