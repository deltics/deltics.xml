
{$i deltics.xml.inc}

  unit Deltics.Xml;


interface

  uses
    Deltics.Xml.Factories,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Types;


  type
    TXmlDocTypeScope               = Deltics.Xml.Types.TXmlDocTypeScope;
    TXmlNodeType                   = Deltics.Xml.Types.TXmlNodeType;
    TXmlDtdElementCategory         = Deltics.Xml.Types.TXmlDtdElementCategory;
    TXmlDtdContentParticleListType = Deltics.Xml.Types.TXmlDtdContentParticleListType;
    TXmlDtdAttributeType           = Deltics.Xml.Types.TXmlDtdAttributeType;
    TXmlDtdAttributeConstraint     = Deltics.Xml.Types.TXmlDtdAttributeConstraint;
    TXmlFormatterLineEndings       = Deltics.Xml.Types.TXmlFormatterLineEndings;


  const
    acRequired               = Deltics.Xml.Types.acRequired;
    acImplied                = Deltics.Xml.Types.acImplied;
    acFixed                  = Deltics.Xml.Types.acFixed;

    atUnknown                = Deltics.Xml.Types.atUnknown;
    atCDATA                  = Deltics.Xml.Types.atCDATA;
    atEnum                   = Deltics.Xml.Types.atEnum;
    atID                     = Deltics.Xml.Types.atID;
    atIDREF                  = Deltics.Xml.Types.atIDREF;
    atIDREFS                 = Deltics.Xml.Types.atIDREFS;
    atNmToken                = Deltics.Xml.Types.atNmToken;
    atNmTokens               = Deltics.Xml.Types.atNmTokens;
    atEntity                 = Deltics.Xml.Types.atEntity;
    atEntities               = Deltics.Xml.Types.atEntities;
    atNotation               = Deltics.Xml.Types.atNotation;

    cpChoice                 = Deltics.Xml.Types.cpChoice;
    cpSequence               = Deltics.Xml.Types.cpSequence;

    dtInternal               = Deltics.Xml.Types.dtInternal;
    dtSYSTEM                 = Deltics.Xml.Types.dtSYSTEM;
    dtPUBLIC                 = Deltics.Xml.Types.dtPUBLIC;

    ecEmpty                  = Deltics.Xml.Types.ecEmpty;
    ecAny                    = Deltics.Xml.Types.ecAny;
    ecMixed                  = Deltics.Xml.Types.ecMixed;
    ecChildren               = Deltics.Xml.Types.ecChildren;

    xmlUndefined             = Deltics.Xml.Types.xmlUndefined;
//    xmlElement               = Deltics.Xml.Types.xmlElement;
    xmlAttribute             = Deltics.Xml.Types.xmlAttribute;
    xmlText                  = Deltics.Xml.Types.xmlText;
    xmlCDATA                 = Deltics.Xml.Types.xmlCDATA;
    xmlEntityReference       = Deltics.Xml.Types.xmlEntityReference;
    xmlEntity                = Deltics.Xml.Types.xmlEntity;
    xmlProcessingInstruction = Deltics.Xml.Types.xmlProcessingInstruction;
    xmlComment               = Deltics.Xml.Types.xmlComment;
//    xmlDocument              = Deltics.Xml.Types.xmlDocument;
    xmlDocType               = Deltics.Xml.Types.xmlDocType;
    xmlFragment              = Deltics.Xml.Types.xmlFragment;

    // Implementation specific extensions
    xmlDtdAttribute           = Deltics.Xml.Types.xmlDtdAttribute;
    xmlDtdAttributeList       = Deltics.Xml.Types.xmlDtdAttributeList;
    xmlDtdContentParticle     = Deltics.Xml.Types.xmlDtdContentParticle;
    xmlDtdContentParticleList = Deltics.Xml.Types.xmlDtdContentParticleList;
    xmlDtdElement             = Deltics.Xml.Types.xmlDtdElement;
    xmlDtdEntity              = Deltics.Xml.Types.xmlDtdEntity;
    xmlDtdNotation            = Deltics.Xml.Types.xmlDtdNotation;
    xmlEndTag                 = Deltics.Xml.Types.xmlEndTag;
    xmlNamespace              = Deltics.Xml.Types.xmlNamespace;
    xmlProlog                 = Deltics.Xml.Types.xmlProlog;
    xmlWhitespace             = Deltics.Xml.Types.xmlWhitespace;

    xmlLF                     = Deltics.Xml.Types.xmlLF;
    xmlCRLF                   = Deltics.Xml.Types.xmlCRLF;


  // Interfaces
  type
    IXmlDocument  = Deltics.Xml.Interfaces.IXmlDocument;
    IXmlElement   = Deltics.Xml.Interfaces.IXmlElement;


  // Factories
  type
    XmlDocument = Deltics.Xml.Factories.XmlDocument;
    XmlElement  = Deltics.Xml.Factories.XmlElement;


  // Utilities
  type
    Xml = class
      class function Format(const aRootNode: IXmlNode): IXmlFormatter;
      class function Load(var aDocument: IXmlDocument): IXmlLoader;
    end;



implementation

  uses
    Deltics.Xml.Formatter,
    Deltics.Xml.Loader;


{ Xml }

  class function Xml.Format(const aRootNode: IXmlNode): IXmlFormatter;
  begin
    result := TXmlFormatter.Create(aRootNode);
  end;


  class function Xml.Load(var aDocument: IXmlDocument): IXmlLoader;
  begin
    result := TXmlLoader.Create(aDocument);
  end;




end.
