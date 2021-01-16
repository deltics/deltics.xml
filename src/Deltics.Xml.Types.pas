
unit Deltics.Xml.Types;

interface

  type
    TXmlDocTypeScope = (
                        dtdInternal,
                        dtdSystem,
                        dtdPublic
                       );

    TXmlNodeType = (
                    xmlUndefined,
                  // the following node types are aligned with W3C values
                    xmlElement,
                    xmlAttribute,
                    xmlText,
                    xmlCDATA,
                    xmlEntityRef,
                    xmlEntity,
                    xmlProcessingInstruction,
                    xmlComment,
                    xmlDocument,
                    xmlDocType,
                    xmlFragment,
                  // the remaining node types are specific to this implementation
                    xmlDeclaration,
                    xmlNamespaceBinding,
                    xmlWhitespace,
                    xmlEndTag,
                    dtdAttList,
                    dtdElement,
                    dtdEntity,
                    dtdNotation,
                    dtdAttribute,
                    dtdContentParticle,
                    dtdContentParticleList
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



implementation

end.
