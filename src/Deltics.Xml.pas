
{$i deltics.xml.inc}

  unit Deltics.Xml;


interface

  uses
    Deltics.Xml.Interfaces,
    Deltics.Xml.Types,
    Deltics.Xml.Nodes.Attributes,
    Deltics.Xml.Nodes.CDATA,
    Deltics.Xml.Nodes.Document,
    Deltics.Xml.Nodes.Elements,
    Deltics.Xml.Nodes.Text;


  type
    TXmlDocTypeScope               = Deltics.Xml.Types.TXmlDocTypeScope;
    TXmlNodeType                   = Deltics.Xml.Types.TXmlNodeType;
    TXmlDtdElementCategory         = Deltics.Xml.Types.TXmlDtdElementCategory;
    TXmlDtdContentParticleListType = Deltics.Xml.Types.TXmlDtdContentParticleListType;
    TXmlDtdAttributeType           = Deltics.Xml.Types.TXmlDtdAttributeType;
    TXmlDtdAttributeConstraint     = Deltics.Xml.Types.TXmlDtdAttributeConstraint;
    TXmlLineEndings                = Deltics.Xml.Types.TXmlLineEndings;


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
    xmlElement               = Deltics.Xml.Types.xmlElement;
    xmlAttribute             = Deltics.Xml.Types.xmlAttribute;
    xmlText                  = Deltics.Xml.Types.xmlText;
    xmlCDATA                 = Deltics.Xml.Types.xmlCDATA;
    xmlEntityReference       = Deltics.Xml.Types.xmlEntityReference;
    xmlEntity                = Deltics.Xml.Types.xmlEntity;
    xmlProcessingInstruction = Deltics.Xml.Types.xmlProcessingInstruction;
    xmlComment               = Deltics.Xml.Types.xmlComment;
    xmlDocument              = Deltics.Xml.Types.xmlDocument;
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
    xmlEndTag                 = Deltics.Xml.Types.xmlEndTag;      // Transient node (discarded after detection) used to simplify loading of Xml
    xmlNamespace              = Deltics.Xml.Types.xmlNamespace;   // Special case of xmlAttribute (xmlns or xmls:<prefix>)
    xmlProlog                 = Deltics.Xml.Types.xmlProlog;      // Special case of xmlProcessingInstruction
    xmlWhitespace             = Deltics.Xml.Types.xmlWhitespace;  // Intended for whitespace preservation.  Not currently used!

    xmlLF                     = Deltics.Xml.Types.xmlLF;
    xmlCRLF                   = Deltics.Xml.Types.xmlCRLF;


  // Interfaces
  type
    IXmlDocument  = Deltics.Xml.Interfaces.IXmlDocument;
    IXmlAttribute = Deltics.Xml.Interfaces.IXmlAttribute;
    IXmlComment   = Deltics.Xml.Interfaces.IXmlComment;
    IXmlElement   = Deltics.Xml.Interfaces.IXmlElement;
    IXmlNode      = Deltics.Xml.Interfaces.IXmlNode;
    IXmlText      = Deltics.Xml.Interfaces.IXmlText;

    IXmlNodeSelection       = Deltics.Xml.Interfaces.IXmlNodeSelection;
    IXmlElementSelection    = Deltics.Xml.Interfaces.IXmlElementSelection;
    IXmlNamespaceSelection  = Deltics.Xml.Interfaces.IXmlNamespaceSelection;


  // Implementation classes for use where needed.  Recommend use of
  //  Xml factory methods where possible
  type
    TXmlAttribute = Deltics.Xml.Nodes.Attributes.TXmlAttribute;
    TXmlCDATA     = Deltics.Xml.Nodes.CDATA.TXmlCDATA;
    TXmlDocument  = Deltics.Xml.Nodes.Document.TXmlDocument;
    TXmlElement   = Deltics.Xml.Nodes.Elements.TXmlElement;
    TXmlText      = Deltics.Xml.Nodes.Text.TXmlText;


  // Utilities
  type
    Xml = class
      class function Format(const aRootNode: IXmlNode): IXmlFormatter;
      class function Load(var aDocument: IXmlDocument): IXmlLoader;

      // Factory methods
      class function Attribute(const aName: Utf8String; const aValue: Utf8String = ''): IXmlAttribute;
      class function CDATA(const aText: Utf8String): IXmlCDATA;
      class function Document: IXmlDocument;
      class function Element(const aName: Utf8String): IXmlElement; overload;
      class function Element(const aName: Utf8String; const aText: Utf8String): IXmlElement; overload;
      class function Text(const aValue: Utf8String): IXmlText;
    end;



implementation

  uses
    Deltics.Xml.Formatter,
    Deltics.Xml.Loader;


{ Xml -------------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Xml.Attribute(const aName, aValue: Utf8String): IXmlAttribute;
  begin
    result := TXmlAttribute.Create(aName, aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Xml.Element(const aName: Utf8String): IXmlElement;
  begin
    result := TXmlElement.Create(aName);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Xml.CDATA(const aText: Utf8String): IXmlCDATA;
  begin
    result := TXmlCDATA.Create(aText);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Xml.Document: IXmlDocument;
  begin
    result := TXmlDocument.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Xml.Element(const aName, aText: Utf8String): IXmlElement;
  begin
    result := TXmlElement.Create(aName, aText);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Xml.Format(const aRootNode: IXmlNode): IXmlFormatter;
  begin
    result := TXmlFormatter.Create(aRootNode);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function Xml.Load(var aDocument: IXmlDocument): IXmlLoader;
  begin
    result := TXmlLoader.Create(aDocument);
  end;


  class function Xml.Text(const aValue: Utf8String): IXmlText;
  begin
    result := TXmlText.Create(aValue);
  end;



end.
