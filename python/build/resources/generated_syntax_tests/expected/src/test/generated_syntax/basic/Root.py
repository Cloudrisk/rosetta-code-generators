class Root(BaseDataClass):
    basicSingle: Optional[test.generated_syntax.basic.BasicSingle.BasicSingle] = Field(None, description='')
    basicList: Optional[test.generated_syntax.basic.BasicList.BasicList] = Field(None, description='')
