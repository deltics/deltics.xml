

  unit Deltics.Xml.Schema.Consts;


interface

  type
    TXSDDataType = (
                      xsCustom,

                    // String types
                      xsString,
                      xsNormalizedString,
                      xsToken,

                    // Date/Time types
                      xsDate,
                      xsTime,
                      xsDateTime,
                      xsDuration,
                      xsDay,
                      xsMonth,
                      xsMonthDay,
                      xsYear,
                      xsYearMonth,

                    // Numeric types
                      xsByte,
                      xsDecimal,
                      xsInt,
                      xsInteger,
                      xsLong,
                      xsNegativeInteger,
                      xsNonNegativeInteger,
                      xsNonPositiveInteger,
                      xsPositiveInteger,
                      xsShort,
                      xsUnsignedLong,
                      xsUnsignedInt,
                      xsUnsignedShort,
                      xsUnsignedByte,

                    // Misc types
                      xsBoolean,
                      xsAnyURI,
                      xsBase64Binary,
                      xsHexBinary,
                      xsDouble,
                      xsFloat,
                      xsNOTATION,
                      xsQName
                   );


  const
    XS_attributeFormDefault = 'attributeFormDefault';
    XS_elementFormDefault   = 'elementFormDefault';
    XS_id                   = 'id';
    XS_targetNamespace      = 'targetNamespace';
    XS_version              = 'version';

    XS_formDefaultQualified   = 'qualified';
    XS_formDefaultUnqualified = 'unqualified';

    XS_element  = 'element';


    XS_datatypeName: array[TXSDDataType] of UTF8String = (
                                                          '',
                                                          'string',
                                                          'normalizedString',
                                                          'token',
                                                          'date',
                                                          'time',
                                                          'dateTime',
                                                          'duration',
                                                          'day',
                                                          'month',
                                                          'monthDay',
                                                          'year',
                                                          'yearMonth',
                                                          'byte',
                                                          'decimal',
                                                          'int',
                                                          'integer',
                                                          'long',
                                                          'negativeInteger',
                                                          'nonNegativeInteger',
                                                          'nonPositiveInteger',
                                                          'positiveInteger',
                                                          'short',
                                                          'unsignedLong',
                                                          'unsignedInt',
                                                          'unsignedShort',
                                                          'unsignedByte',
                                                          'boolean',
                                                          'anyURI',
                                                          'base64Binary',
                                                          'hexBinary',
                                                          'double',
                                                          'float',
                                                          'NOTATION',
                                                          'QName'
                                                         );


implementation

end.
