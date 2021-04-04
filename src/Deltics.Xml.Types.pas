

  unit Deltics.Xml.Types;

interface


  type
    TXmlDocTypeScope = (
                        dtInternal,
                        dtSYSTEM,
                        dtPUBLIC
                       );

    TXmlNodeType = (
                    xmlUndefined,
                  // the following node types are aligned with W3C values
                    xmlElement,
                    xmlAttribute,
                    xmlText,
                    xmlCDATA,
                    xmlEntityReference,
                    xmlEntity,
                    xmlProcessingInstruction,
                    xmlComment,
                    xmlDocument,
                    xmlDocType,
                    xmlFragment,
                  // the remaining node types are specific to this implementation
                    xmlDtdAttribute,
                    xmlDtdAttributeList,
                    xmlDtdContentParticle,
                    xmlDtdContentParticleList,
                    xmlDtdElement,
                    xmlDtdEntity,
                    xmlDtdNotation,
                    xmlEndTag,
                    xmlNamespace,
                    xmlProlog,
                    xmlWhitespace
                   );

    TXmlDtdElementCategory = (
                              ecEmpty,
                              ecAny,
                              ecMixed,
                              ecChildren
                             );

    TXmlDtdContentParticleListType = (
                                      cpChoice,
                                      cpSequence
                                     );

    TXmlDtdAttributeType = (
                            atUnknown,
                            atCDATA,
                            atEnum,
                            atID,
                            atIDREF,
                            atIDREFS,
                            atNmToken,
                            atNmTokens,
                            atEntity,
                            atEntities,
                            atNotation
                           );

    TXmlDtdAttributeConstraint = (
                                  acRequired,
                                  acImplied,
                                  acFixed
                                 );


    TXmlFormatterLineEndings = (xmlLF, xmlCRLF);



implementation

end.
