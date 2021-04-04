
{$i deltics.xml.inc}

  unit Deltics.Xml.Interfaces;


interface

  uses
    Classes,
    Deltics.IO.Streams,
    Deltics.Nullable,
    Deltics.StringEncodings,
    Deltics.StringLists,
    Deltics.StringTypes,
    Deltics.Xml.Types;


  type
    IXmlFormatter       = interface;
    IXmlFormatterYields = interface;

    IXmlLoader          = interface;
    IXmlLoaderYields    = interface;


    IXmlAttribute               = interface;
    IXmlAttributeList           = interface;
    IXmlDocType                 = interface;
    IXmlDocument                = interface;
    IXmlDtdAttribute            = interface;
    IXmlDtdAttributeList        = interface;
    IXmlDtdContentParticle      = interface;
    IXmlDtdContentParticleList  = interface;
    IXmlDtdDeclaration          = interface;
    IXmlDtdElement              = interface;
    IXmlDtdEntity               = interface;
    IXmlDtdNotation             = interface;
    IXmlElement                 = interface;
    IXmlFpi                     = interface;
    IXmlHasNodes                = interface;
    IXmlNamespace               = interface;
    IXmlNamespaceList           = interface;
    IXmlNamespaceNode           = interface;
    IXmlNode                    = interface;
    IXmlNodeList                = interface;
    IXmlNodeSelection           = interface;
    IXmlProlog                  = interface;
    IXmlText                    = interface;



    IXmlFpi = interface
    ['{BF3DFD23-3703-4B0A-A6F2-001B770AECB6}']
      function get_AsString: Utf8String;
      function get_Standard: Utf8String;
      function get_Organisation: Utf8String;
      function get_DocumentType: Utf8String;
      function get_Language: Utf8String;
      procedure set_AsString(const aValue: Utf8String);
      procedure set_Standard(const aValue: Utf8String);
      procedure set_Organisation(const aValue: Utf8String);
      procedure set_DocumentType(const aValue: Utf8String);
      procedure set_Language(const aValue: Utf8String);

      property AsString: Utf8String read get_AsString write set_AsString;
      property Standard: Utf8String read get_Standard write set_Standard;
      property Organisation: Utf8String read get_Organisation write set_Organisation;
      property DocumentType: Utf8String read get_DocumentType write set_DocumentType;
      property Language: Utf8String read get_Language write set_Language;
    end;


    IXmlHasNodes = interface
    ['{6775CEAD-B9D7-4487-BF10-E72EE7F57868}']
      function get_Nodes: IXmlNodeList;

      property Nodes: IXmlNodeList read get_Nodes;
    end;


    IXmlNode = interface
    ['{A9031517-5412-4E82-B093-71A41473C240}']
      function get_AsAttribute: IXmlAttribute;
      function get_AsElement: IXmlElement;
      function get_Document: IXmlDocument;
      function get_Index: Integer;
      function get_Name: Utf8String;
      function get_NodeType: TXmlNodeType;
      function get_Parent: IXmlNode;
      function get_Text: Utf8String;
      function get_Path: Utf8String;

      function Clone: IXmlNode;
      procedure Delete;
      function SelectNode(const aPath: Utf8String): IXmlNode;
      function SelectNodes(const aPath: Utf8String): IXmlNodeSelection;

      property AsAttribute: IXmlAttribute read get_AsAttribute;
      property AsElement: IXmlElement read get_AsElement;
      property Document: IXmlDocument read get_Document;
      property Index: Integer read get_Index;
      property Name: Utf8String read get_Name;
      property NodeType: TXmlNodeType read get_NodeType;
      property Parent: IXmlNode read get_Parent;
      property Text: Utf8String read get_Text;
      property Path: Utf8String read get_Path;
    end;


(*
  {$ifdef Generics}
    NullableBooleanProp = NullableBoolean;
  {$else}
    NullableBooleanProp = ^NullableBoolean;
  {$endif}
*)
    IXmlDocument = interface(IXmlNode)
    ['{677EBA8B-54C0-434B-BD91-E7AFEE0CAB3B}']
      function get_DocType: IXmlDocType;
      function get_Nodes: IXmlNodeList;
      function get_Prolog: IXmlProlog;
      function get_RootElement: IXmlElement;
      function get_SourceEncoding: TEncoding;
      function get_Standalone: Utf8String;
      procedure set_DocType(const aValue: IXmlDocType);
      procedure set_RootElement(const aValue: IXmlElement);
      procedure set_Standalone(const aValue: Utf8String);

      procedure SaveToFile(const aFilename: String; const aEncoding: TEncoding = NIL);
      procedure SaveToStream(const aStream: IStream; const aEncoding: TEncoding = NIL); overload;
      procedure SaveToStream(const aStream: TStream; const aEncoding: TEncoding = NIL); overload;

      property DocType: IXmlDocType read get_DocType write set_DocType;
      property Nodes: IXmlNodeList read get_Nodes;
      property Prolog: IXmlProlog read get_Prolog;
      property RootElement: IXmlElement read get_RootElement write set_RootElement;
      property SourceEncoding: TEncoding read get_SourceEncoding;
      property Standalone: Utf8String read get_Standalone write set_Standalone;
    end;


    IXmlCDATA = interface(IXmlNode)
    ['{7E700937-6330-41BF-8C73-F26BD5886F2C}']
      function get_Text: Utf8String;
      procedure set_Text(const aValue: Utf8String);
      property Text: Utf8String read get_Text write set_Text;
    end;


    IXmlComment = interface(IXmlNode)
    ['{435F8153-CED7-48DF-A2E0-BC71EA33774E}']
      function get_Text: Utf8String;
      procedure set_Text(const aValue: Utf8String);
      property Text: Utf8String read get_Text write set_Text;
    end;


    IXmlProlog = interface(IXmlNode)
    ['{BEE40B0E-406E-4909-A699-A5BE39807711}']
      function get_Version: Utf8String;
      function get_Encoding: Utf8String;
      function get_Standalone: Utf8String;
      procedure set_Version(const aValue: Utf8String);
      procedure set_Standalone(const aValue: Utf8String);

      property Version: Utf8String read get_Version write set_Version;
      property Encoding: Utf8String read get_Encoding;
      property Standalone: Utf8String read get_Standalone write set_Standalone;
    end;


    IXmlDocType = interface(IXmlNode)
    ['{68490A01-E6A1-4D86-84A1-085987B247F2}']
      function get_Fpi: Utf8String;
      function get_InternalSubset: IXmlNodeList;
      function get_RootElement: Utf8String;
      function get_Scope: TXmlDocTypeScope;
      function get_Uri: Utf8String;

      property Fpi: Utf8String read get_Fpi;
      property InternalSubset: IXmlNodeList read get_InternalSubset;
      property Uri: Utf8String read get_Uri;
      property RootElement: Utf8String read get_RootElement;
      property Scope: TXmlDocTypeScope read get_Scope;
    end;



    IXmlFragment = interface(IXmlNode)
    ['{20D343CC-F8B7-431F-A471-B8CAEE3005CF}']
      function get_Nodes: IXmlNodeList;
      function get_SourceEncoding: TEncoding;

      procedure Add(const aNode: IXmlNode);
      procedure Clear;

      property Nodes: IXmlNodeList read get_Nodes;
      property SourceEncoding: TEncoding read get_SourceEncoding;
    end;


    IXmlProcessingInstruction = interface(IXmlNode)
    ['{1363DCDC-AA66-49B0-B48C-54991AA4F8FD}']
      function get_Content: Utf8String;
      function get_Target: Utf8String;

      property Content: Utf8String read get_Content;
      property Target: Utf8String read get_Target;
    end;



    IXmlNamespaceNode = interface(IXmlNode)
    ['{85AADF64-C8AF-41DD-96BD-762F347F746E}']
      function get_LocalName: Utf8String;
      function get_Namespace: IXmlNamespace;
      function get_NamespacePrefix: Utf8String;
      procedure set_Name(const aValue: Utf8String);

      property LocalName: Utf8String read get_LocalName;
      property Name: Utf8String read get_Name write set_Name;
      property Namespace: IXmlNamespace read get_Namespace;
      property NamespacePrefix: Utf8String read get_NamespacePrefix;
    end;


    IXmlAttribute = interface(IXmlNamespaceNode)
    ['{D24E2A03-466F-4869-9D7E-45D86D0F6AA6}']
      function get_Value: Utf8String;
      procedure set_Value(const aValue: Utf8String);

      property Value: Utf8String read get_Value write set_Value;
    end;


    IXmlNamespace = interface(IXmlAttribute)
    ['{FD76645B-5C90-4AA2-AC18-CF1CE245F76F}']
//      function get_IsDefault: Boolean;
      function get_Prefix: Utf8String;
      procedure set_Prefix(const aValue: Utf8String);

//      property IsDefault: Boolean read get_IsDefault;
      property Prefix: Utf8String read get_Prefix write set_Prefix;
      property Url: Utf8String read get_Value write set_Value;
    end;


    IXmlElement = interface(IXmlNamespaceNode)
    ['{916E79B4-8E77-4109-9873-D9B433D22865}']
      function get_Attributes: IXmlAttributeList;
      function get_Nodes: IXmlNodeList;
      function get_IsEmpty: Boolean;
      function get_Namespaces: IXmlNamespaceList;
      function get_Text: Utf8String;
      procedure set_IsEmpty(const aValue: Boolean);
      procedure set_Text(const aValue: Utf8String);

      function Add(const aNode: IXmlNode): Integer;
      function AddAttribute(const aName: Utf8String; const aValue: Utf8String): IXmlAttribute;
      function AddElement(const aName: Utf8String): IXmlElement; overload;
      function AddElement(const aName: Utf8String; const aText: Utf8String): IXmlElement; overload;
      function Clone: IXmlElement; overload;
      function ContainsElement(const aName: Utf8String; var aElement: IXmlElement): Boolean;
      function FindNamespace(const aPrefix: Utf8String): IXmlNamespace;
      function HasAttribute(const aName: Utf8String): Boolean; overload;
      function HasAttribute(const aName: Utf8String; var aValue: Utf8String): Boolean; overload;
//      function AllNamespaces: IXmlNamespaceSelection;

      property Attributes: IXmlAttributeList read get_Attributes;
      property Nodes: IXmlNodeList read get_Nodes;
      property IsEmpty: Boolean read get_IsEmpty write set_IsEmpty;
      property Namespaces: IXmlNamespaceList read get_Namespaces;
      property Text: Utf8String read get_Text write set_Text;
    end;


    IXmlText = interface(IXmlNode)
    ['{65962459-1507-4DC6-9B4F-F8F944BF2E4D}']
//      function get_ContainsEntities: Boolean;
      function get_Text: Utf8String;
      procedure set_Text(const aValue: Utf8String);

//      property ContainsEntities: Boolean read get_ContainsEntities;
      property Text: Utf8String read get_Text write set_Text;
    end;




    IXmlDtdDeclaration = interface(IXmlNode)
    ['{A3FB0F01-5B03-41B5-B430-A3F5101BFA77}']
    end;


    IXmlDtdContentParticle = interface(IXmlDtdDeclaration)
    ['{F877B3DD-0F13-4B13-BC79-3B5843680B25}']
      function get_AllowMultiple: Boolean;
      function get_Element: IXmlDtdElement;
      function get_IsPCDATA: Boolean;
      function get_IsRequired: Boolean;
      function get_Parent: IXmlDtdContentParticle; overload;

      property AllowMultiple: Boolean read get_AllowMultiple;
      property Element: IXmlDtdElement read get_Element;
      property IsPCDATA: Boolean read get_IsPCDATA;
      property IsRequired: Boolean read get_IsRequired;
      property Parent: IXmlDtdContentParticle read get_Parent;
    end;


    IXmlDtdContentParticleList = interface(IXmlDtdContentParticle)
    ['{E097C166-E42A-4ABD-B105-9B573B491A72}']
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): IXmlDtdContentParticle;
      function get_ListType: TXmlDtdContentParticleListType;

      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: IXmlDtdContentParticle read get_Item; default;
      property ListType: TXmlDtdContentParticleListType read get_ListType;
    end;


    IXmlDtdAttributeList = interface(IXmlDtdDeclaration)
    ['{71376FC3-93CC-4791-996E-5601BCCEDE51}']
      function get_Count: Integer;
      function get_ElementName: Utf8String;
      function get_Item(const aIndex: Integer): IXmlDtdAttribute;

      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: IXmlDtdAttribute read get_Item; default;

      property ElementName: Utf8String read get_ElementName;
    end;


    IXmlDtdAttribute = interface(IXmlDtdDeclaration)
    ['{2AC8AB66-4A17-49E3-9928-A43E377CCC88}']
      function get_AttributeType: TXmlDtdAttributeType;
      function get_Constraint: TXmlDtdAttributeConstraint;
      function get_DefaultValue: Utf8String;
      function get_Members: IUtf8StringList;

      property AttributeType: TXmlDtdAttributeType read get_AttributeType;
      property Constraint: TXmlDtdAttributeConstraint read get_Constraint;
      property DefaultValue: Utf8String read get_DefaultValue;
      property Members: IUtf8StringList read get_Members;

    end;


    IXmlDtdElement = interface(IXmlDtdDeclaration)
    ['{CFB38A31-78F4-468F-8501-EAE8FC0F0BBC}']
      function get_Category: TXmlDtdElementCategory;
      function get_Content: IXmlDtdContentParticleList;

      property Category: TXmlDtdElementCategory read get_Category;
      property Content: IXmlDtdContentParticleList read get_Content;
    end;


    IXmlDtdEntity = interface(IXmlDtdDeclaration)
    ['{D8ACB35D-E168-4841-BB6D-C5DA9CBF0661}']
      function get_Content: Utf8String;

      property Content: Utf8String read get_Content;
    end;


    IXmlDtdNotation = interface(IXmlDtdDeclaration)
    ['{AF4333D6-7B70-4093-AE86-F4682F7B9A7E}']
    end;





    IXmlNodeList = interface
    ['{8A9093E3-D061-464D-8BD6-7B06A2A86426}']
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): IXmlNode;
      function IndexOf(const aNode: IXmlNode): Integer;
      function ItemByName(const aName: Utf8String): IXmlNode;
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: IXmlNode read get_Item; default;
    end;


    IXmlAttributeList = interface(IXmlNodeList)
    ['{971C97D6-02BD-4CDF-8948-026ADC0C2204}']
      function get_Item(const aIndex: Integer): IXmlAttribute; overload;
      function Contains(const aName: Utf8String; var aAttribute: IXmlAttribute): Boolean; overload;
      function Contains(const aName: Utf8String; var aValue: Utf8String): Boolean; overload;
      procedure Delete(const aItem: IXmlAttribute);
      function IndexOf(const aItem: IXmlAttribute): Integer; overload;
      property Items[const aIndex: Integer]: IXmlAttribute read get_Item; default;
    end;


    IXmlNamespaceList = interface(IXmlNodeList)
    ['{D0610B6D-FC00-471D-9F67-91A9EE5994D9}']
      function get_Item(const aIndex: Integer): IXmlNamespace;
      property Items[const aIndex: Integer]: IXmlNamespace read get_Item; default;
    end;







    IXmlLoaderYields = interface
    ['{C1A91711-F3E4-4F18-8D03-345AEBDA07A7}']
      function Errors(var aList: IStringList): IXmlLoader;
      function Warnings(var aList: IStringList): IXmlLoader;
    end;


    IXmlLoader = interface
    ['{CC6A5B1F-9C7D-46B4-A7BE-8E2728272DD5}']
      procedure FromFile(const aFilename: String);
      procedure FromStream(const aStream: IStream); overload;
      procedure FromStream(const aStream: TStream); overload;
      procedure FromString(const aString: AnsiString); overload;
      procedure FromString(const aString: UnicodeString); overload;
      procedure FromUtf8(const aString: Utf8String);
      function Yielding: IXmlLoaderYields;
    end;





    IXmlFormatterYields = interface
    ['{66447F71-19A4-4D48-B6F6-549D440400E7}']
      function Errors(var aList: IStringList): IXmlFormatter;
      function Warnings(var aList: IStringList): IXmlFormatter;
    end;


    IXmlFormatter = interface
    ['{864B88D3-DA39-4E1A-9070-6DE62E66AF37}']
      function AsUnicodeString: UnicodeString;
      function AsUtf8String: Utf8String;
      procedure IntoStream(const aStream: IStream; const aEncoding: TEncoding = NIL); overload;
      procedure IntoStream(const aStream: TStream; const aEncoding: TEncoding = NIL); overload;
      function LineEndings(const aValue: TXmlLineEndings): IXmlFormatter;
      function Prolog(const aValue: Boolean): IXmlFormatter;
      function Readable(const aValue: Boolean): IXmlFormatter;
      function Yielding: IXmlFormatterYields;
    end;






    IXmlNodeSelection = interface
    ['{998632E0-22EA-44E8-BC3B-DDA83F55502C}']
      function get_Count: Integer;
      function get_First: IXmlNode;
      function get_Item(const aIndex: Integer): IXmlNode;
      function get_Last: IXmlNode;

      property Count: Integer read get_Count;
      property First: IXmlNode read get_First;
      property Items[const aIndex: Integer]: IXMLNode read get_Item; default;
      property Last: IXmlNode read get_Last;
    end;


    IXmlElementSelection = interface(IXmlNodeSelection)
    ['{A1076722-FAA1-46E9-9D05-07BA9785C2B7}']
      function get_First: IXmlElement;
      function get_Item(const aIndex: Integer): IXmlElement;
      function get_Last: IXmlElement;

      function ItemByName(const aName: Utf8String): IXmlElement;

      property First: IXmlElement read get_First;
      property Items[const aIndex: Integer]: IXmlElement read get_Item; default;
      property Last: IXmlElement read get_Last;
    end;


    IXmlNamespaceSelection = interface(IXmlNodeSelection)
    ['{228ACC12-C0AB-4E84-A318-ED59C0BDCF3E}']
      function get_First: IXmlNamespace;
      function get_Item(const aIndex: Integer): IXmlNamespace;
      function get_Last: IXmlNamespace;

      property First: IXmlNamespace read get_First;
      function ItemByPrefix(const aPrefix: Utf8String): IXmlNamespace;
      property Items[const aIndex: Integer]: IXmlNamespace read get_Item; default;
      property Last: IXmlNamespace read get_Last;
    end;



implementation

end.
