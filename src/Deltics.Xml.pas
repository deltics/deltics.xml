
{$i deltics.xml.inc}

  unit Deltics.Xml;


interface

  uses
  { vcl: }
    Classes,
    Contnrs,
    Types,
  { deltics: }
    Deltics.Nullable,
    Deltics.Strings;


  type
    TXmlAttribute = class;
    TXmlCDATA = class;
    TXmlComment = class;
    TXmlDocument = class;
    TXmlElement = class;
    TXmlNamespace = class;
    TXmlNode = class;
    TXmlText = class;

    TXmlAttributeList = class;
    TXmlNodeList = class;


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


    TXmlDtdDeclaration = class;
      TXmlDtdAttListDeclaration = class;
      TXmlDtdElementDeclaration = class;
      TXmlDtdEntityDeclaration = class;
      TXmlDtdNotationDeclaration = class;

      TXmlDtdAttributeDeclaration = class;
      TXmlDtdContentParticle = class;
        TXmlDtdContentParticleList = class;



    IXmlNodeSelection = interface
    ['{7183D272-7E6B-4851-848E-548913BA489C}']
      function get_Count: Integer;
      function get_First: TXmlNode;
      function get_Last: TXmlNode;
      function get_Node(const aIndex: Integer): TXmlNode;

      property Count: Integer read get_Count;
      property First: TXmlNode read get_First;
      property Last: TXmlNode read get_Last;
      property Nodes[const aIndex: Integer]: TXmlNode read get_Node; default;
    end;


    IXmlElementSelection = interface(IXmlNodeSelection)
    ['{59D16950-59AF-4FB2-8772-27B548CDACD0}']
      function get_Item(const aIndex: Integer): TXmlElement;
      function ItemByName(const aName: Utf8String): TXmlElement;

      property Items[const aIndex: Integer]: TXmlElement read get_Item; default;
    end;


    IXmlNamespaceSelection = interface(IXmlNodeSelection)
    ['{9F9DCFFB-3799-444F-BF77-1FE3A59C9547}']
      function get_Item(const aIndex: Integer): TXmlNamespace;
      function ItemByPrefix(const aPrefix: Utf8String): TXmlNamespace;

      property Items[const aIndex: Integer]: TXmlNamespace read get_Item; default;
    end;


    TXmlNode = class
    private
      fNodeType: TXmlNodeType;
      fParent: TXmlNode;
      function get_AsAttribute: TXmlAttribute;
      function get_AsElement: TXmlElement;
      function get_Document: TXmlDocument;
    protected
      constructor Create(const aNodeType: TXmlNodeType);
      function get_Index: Integer;
      function get_Name: Utf8String; virtual;
      function get_Path: Utf8String;
      function get_Text: Utf8String; virtual;
      function get_Xml: Utf8String; virtual; abstract;
      procedure set_Text(const Value: Utf8String); virtual;
      procedure Assign(const aSource: TXmlNode); virtual; abstract;
      procedure DeleteNode(const aNode: TXmlNode); virtual;
    public
      destructor Destroy; override;
      procedure Delete;
      function SelectAttribute(const aPath: Utf8String): TXmlAttribute; overload;
      function SelectAttribute(const aElementPath: Utf8String; const aAttribute: Utf8String): TXmlAttribute; overload;
      function SelectElement(const aPath: Utf8String): TXmlElement;
      function SelectNode(const aPath: Utf8String): TXmlNode;
      function SelectNodes(const aPath: Utf8String): IXmlNodeSelection;
      function Clone: TXmlNode;
      property AsAttribute: TXmlAttribute read get_AsAttribute;
      property AsElement: TXmlElement read get_AsElement;
      property Document: TXmlDocument read get_Document;
      property Index: Integer read get_Index;
      property Name: Utf8String read get_Name;
      property NodeType: TXmlNodeType read fNodeType;
      property Parent: TXmlNode read fParent;
      property Path: Utf8String read get_Path;
      property Text: Utf8String read get_Text;
      property Xml: Utf8String read get_Xml;
    end;


    TXmlNodeList = class
    private
      fItems: TObjectList;
      fOwner: TXmlNode;
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): TXmlNode;
      function get_Text: Utf8String;
    protected
      function get_Xml: Utf8String; virtual;
      procedure Assign(const aSource: TXmlNodeList);
      function CanAdd(const aNode: TXmlNode): Boolean; virtual;
      procedure InternalAdd(const aNode: TXmlNode; const aIndex: Integer = -1);
    public
      constructor Create(const aOwner: TXmlNode);
      destructor Destroy; override;
      procedure Add(const aNode: TXmlNode);
      procedure Insert(const aIndex: Integer; const aNode: TXmlNode);
      procedure Clear;
      procedure Delete(const aIndex: Integer); overload;
      procedure Delete(const aNode: TXmlNode); overload;
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: TXmlNode read get_Item; default;
      property Text: Utf8String read get_Text;
      property Xml: Utf8String read get_Xml;
    end;


      TXmlAttributeList = class(TXmlNodeList)
      private
        function get_Item(const aIndex: Integer): TXmlAttribute;
      protected
        function get_Xml: Utf8String; override;
        function CanAdd(const aNode: TXmlNode): Boolean; override;
      public
        procedure Add(const aAttribute: TXmlAttribute); reintroduce; overload;
        procedure Add(const aName, aValue: Utf8String); overload;
        function ByName(const aName: Utf8String; const aCreate: Boolean = FALSE): TXmlAttribute;
        function ByValue(const aValue: Utf8String): TXmlAttribute;
        property Items[const aIndex: Integer]: TXmlAttribute read get_Item; default;
      end;


    TXmlVirtualNodeList = class
    private
      fNodes: TXmlNodeList;
    protected
      function get_Count: Integer; virtual;
      function get_Item(const aIndex: Integer): TXmlNode;
      function IsListMember(const aNode: TXmlNode): Boolean; virtual;
      property Nodes: TXmlNodeList read fNodes;
    public
      constructor Create(const aSource: TXmlNodeList);
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: TXmlNode read get_Item; default;
    end;


      TXmlNamespaceBindings = class(TXmlVirtualNodeList)
      private
        function get_Item(const aIndex: Integer): TXmlNamespace;
      protected
        function IsListMember(const aNode: TXmlNode): Boolean; override;
      public
        procedure Add(const aPrefix, aURI: Utf8String); reintroduce;
        property Items[const aIndex: Integer]: TXmlNamespace read get_Item; default;
      end;




    TXmlNamespaceNode = class(TXmlNode)
    private
      fLocalName: Utf8String;
      fNamespaceName: Utf8String;
      procedure set_Name(const aValue: Utf8String);
    protected
      constructor Create(const aNodeType: TXmlNodeType;
                         const aName: Utf8String);
      function get_Name: Utf8String; override;
      function get_Namespace: TXmlNamespace; virtual;
      procedure Assign(const aSource: TXmlNode); override;
    public
      function FindNamespaceByPrefix(const aPrefix: Utf8String; var aNamespace: TXmlNamespace): Boolean;
      property LocalName: Utf8String read fLocalName;
      property Namespace: TXmlNamespace read get_Namespace;
      property NamespaceName: Utf8String read fNamespaceName;
      property Name: Utf8String read get_Name write set_Name;
    end;


      TXmlAttribute = class(TXmlNamespaceNode)
      private
        fValue: Utf8String;
        function get_AsNamespace: TXmlNamespace;
        function get_IsNamespaceBinding: Boolean;
      protected
        constructor Create(const aNodeType: TXmlNodeType; const aName, aValue: Utf8String); overload;
        function get_Namespace: TXmlNamespace; override;
        function get_Text: Utf8String; override;
        function get_Xml: Utf8String; override;
        procedure Assign(const aSource: TXmlNode); override;
      public
        constructor Create(const aName, aValue: Utf8String); overload;
        property AsNamespace: TXmlNamespace read get_AsNamespace;
        property IsNamespaceBinding: Boolean read get_IsNamespaceBinding;
        property Value: Utf8String read fValue write fValue;
      end;


        TXmlNamespace = class(TXmlAttribute)
        private
          function get_IsDefault: Boolean;
          function get_Name: Utf8String; reintroduce;
          function get_Prefix: Utf8String;
          procedure set_Name(const aValue: Utf8String); reintroduce;
          procedure set_Prefix(const aValue: Utf8String);
        public
          property IsDefault: Boolean read get_IsDefault;
          property Name: Utf8String read get_Name write set_Name;
          property Prefix: Utf8String read get_Prefix write set_Prefix;
        end;


      TXmlElement = class(TXmlNamespaceNode)
      private
        fAttributes: TXmlAttributeList;
        fIsEmpty: Boolean;
        fNamespaceBindings: TXmlNamespaceBindings;
        fNodes: TXmlNodeList;
        function get_Value: String;
        procedure set_IsEmpty(const aValue: Boolean);
      protected
        function get_IsEmpty: Boolean;
        function get_Text: Utf8String; override;
        function get_Xml: Utf8String; override;
        procedure set_Text(const aValue: Utf8String); override;
        procedure Assign(const aSource: TXmlNode); override;
        procedure DeleteNode(const aNode: TXmlNode); override;
        function NamespaceByPrefix(const aPrefix: Utf8String): TXmlNamespace;
      public
        constructor Create(const aName: Utf8String);
        constructor CreateEmpty(const aName: Utf8String);
        destructor Destroy; override;
        function ContainsElement(const aName: Utf8String; var aElement: TXmlElement): Boolean; overload;
        function HasAttribute(const aName: Utf8String): Boolean; overload;
        function HasAttribute(const aName: Utf8String; var aValue: Utf8String): Boolean; overload;
        function AllNamespaces: IXmlNamespaceSelection;
        property Attributes: TXmlAttributeList read fAttributes;
        property IsEmpty: Boolean read get_IsEmpty write set_IsEmpty;
        property Namespaces: TXmlNamespaceBindings read fNamespaceBindings;
        property Nodes: TXmlNodeList read fNodes;
        property Text: Utf8String read get_Text write set_Text;
        property Value: String read get_Value;
      end;




    TXmlCDATA = class(TXmlNode)
    private
      fText: Utf8String;
    protected
      function get_Text: Utf8String; override;
      function get_Xml: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aText: Utf8String);
    end;


    TXmlComment = class(TXmlNode)
    private
      fText: Utf8String;
    protected
      function get_Text: Utf8String; override;
      function get_Xml: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aText: Utf8String);
    end;


    TXmlFPI = class
    private
      fStandard: Utf8String;
      fOrganisation: Utf8String;
      fDocumentType: Utf8String;
      fLanguage: Utf8String;
      function get_AsString: Utf8String;
      procedure set_AsString(const aValue: Utf8String);
    public
      constructor Create(const aFPI: Utf8String);
      property AsString: Utf8String read get_AsString write set_AsString;
      property Standard: Utf8String read fStandard write fStandard;
      property Organisation: Utf8String read fOrganisation write fOrganisation;
      property DocumentType: Utf8String read fDocumentType write fDocumentType;
      property Language: Utf8String read fLanguage write fLanguage;
    end;


    TXmlDocType = class(TXmlNode)
    private
      fFPI: TXmlFPI;
      fInternalSubset: TXmlNodeList;
      fLocation: Utf8String;
      fNodes: TXmlNodeList;
      fRoot: Utf8String;
      fScope: TXmlDocTypeScope;
      procedure set_Location(const aValue: Utf8String);
      procedure set_InternalSubset(const aValue: TXmlNodeList);
      constructor Create(const aRoot: Utf8String);
    protected
      function get_Name: Utf8String; override;
      function get_Xml: Utf8String; override;

    public
      constructor CreateInternal(const aRoot: Utf8String);
      constructor CreatePublic(const aRoot, aFPI, aLocation: Utf8String);
      constructor CreateSystem(const aRoot, aLocation: Utf8String);
      destructor Destroy; override;
      procedure Assign(const aSource: TXmlNode); override;
      property FPI: TXmlFPI read fFPI;
      property InternalSubset: TXmlNodeList read fInternalSubset write set_InternalSubset;
      property Location: Utf8String read fLocation write set_Location;
      property Name: Utf8String read fRoot write fRoot;
      property Nodes: TXmlNodeList read fNodes;
      property Root: Utf8String read fRoot write fRoot;
      property Scope: TXmlDocTypeScope read fScope;
    end;


    TXmlDtdContentParticle = class(TXmlNode)
    private
      fAllowMultiple: Boolean;
      fElement: TXmlDtdElementDeclaration;
      fIsPCDATA: Boolean;
      fIsRequired: Boolean;
      fName: Utf8String;
      fParent: TXmlDtdContentParticle;
      function get_Element: TXmlDtdElementDeclaration;
      function get_Parent: TXmlDtdContentParticle;
    public
      constructor Create(const aName: Utf8String); reintroduce; overload;
      constructor CreatePCDATA;
      function get_Xml: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
      property AllowMultiple: Boolean read fAllowMultiple write fAllowMultiple;
      property Element: TXmlDtdElementDeclaration read get_Element;
      property IsPCDATA: Boolean read fIsPCDATA write fIsPCDATA;
      property IsRequired: Boolean read fIsRequired write fIsRequired;
      property Name: Utf8String read fName;
      property Parent: TXmlDtdContentParticle read get_Parent;
    end;

      TXmlDtdContentParticleList = class(TXmlDtdContentParticle)
      private
        fItems: TObjectList;
        fListType: TXmlDtdContentParticleListType;
        function get_Count: Integer;
        function get_Item(const aIndex: Integer): TXmlDtdContentParticle;

      public
        constructor Create; reintroduce;
        destructor Destroy; override;
        function get_Xml: Utf8String; override;
        procedure Assign(const aSource: TXmlNode); override;
        procedure Add(const aParticle: TXmlDtdContentParticle);
        procedure Delete(const aIndex: Integer); overload;
        property Count: Integer read get_Count;
        property Items[const aIndex: Integer]: TXmlDtdContentParticle read get_Item; default;
        property ListType: TXmlDtdContentParticleListType read fListType write fListType;
      end;


    TXmlDtdDeclaration = class(TXmlNode);


      TXmlDtdAttListDeclaration = class(TXmlDtdDeclaration)
      private
        fAttributes: TXmlNodeList;
        fElementName: Utf8String;
      public
        constructor Create; reintroduce;
        destructor Destroy; override;
        function get_Xml: Utf8String; override;
        function Add(const aName: Utf8String;
                     const aType: TXmlDtdAttributeType): TXmlDtdAttributeDeclaration;
        procedure Assign(const aSource: TXmlNode); override;
        property ElementName: Utf8String read fElementName write fElementName;
      end;


      TXmlDtdAttributeDeclaration = class(TXmlDtdDeclaration)
      private
        fAttributeType: TXmlDtdAttributeType;
        fConstraint: TXmlDtdAttributeConstraint;
        fDefaultValue: Utf8String;
        fMembers: TStringList;
        fName: Utf8String;
      protected
        function get_Name: Utf8String; override;
      public
        constructor Create(const aName: Utf8String; const aType: TXmlDtdAttributeType); reintroduce;
        destructor Destroy; override;
        function get_Xml: Utf8String; override;
        procedure Assign(const aSource: TXmlNode); override;
        property AttributeType: TXmlDtdAttributeType read fAttributeType;
        property Constraint: TXmlDtdAttributeConstraint read fConstraint write fConstraint;
        property DefaultValue: Utf8String read fDefaultValue write fDefaultValue;
        property Members: TStringList read fMembers;
        property Name: Utf8String read fName;
      end;


      TXmlDtdElementDeclaration = class(TXmlDtdDeclaration)
      private
        fCategory: TXmlDtdElementCategory;
        fContent: TXmlDtdContentParticleList;
        fName: Utf8String;

      protected
        function get_Name: Utf8String; override;
        function get_Xml: Utf8String; override;
        procedure Assign(const aSource: TXmlNode); override;

      public
        constructor Create(const aName: String); overload;
        constructor Create(const aName: String;
                           const aContent: TXmlDtdContentParticleList); overload;
        constructor CreateANY(const aName: String);
        constructor CreateEMPTY(const aName: String);
        destructor Destroy; override;
        property Category: TXmlDtdElementCategory read fCategory;
        property Content: TXmlDtdContentParticleList read fContent;
        property Name: Utf8String read fName;
      end;


      TXmlDtdEntityDeclaration = class(TXmlDtdDeclaration)
      private
        fName: Utf8String;
        fContent: Utf8String;
      protected
        function get_Name: Utf8String; override;
        function get_Xml: Utf8String; override;
        procedure Assign(const aSource: TXmlNode); override;
      public
        constructor Create(const aName: Utf8String;
                           const aContent: Utf8String);
        property Name: Utf8String read fName write fName;
        property Content: Utf8String read fContent write fContent;
      end;


      TXmlDtdNotationDeclaration = class(TXmlDtdDeclaration)
      private
        fName: Utf8String;
      protected
        function get_Name: Utf8String; override;
        function get_Xml: Utf8String; override;
        procedure Assign(const aSource: TXmlNode); override;
      public
        constructor Create(const aName: Utf8String);
        property Name: Utf8String read fName write fName;
      end;


    TXmlDeclaration = class(TXmlNode)
    private
      fVersion: Utf8String;
      fEncoding: Utf8String;
      fStandalone: Utf8String;
    protected
      function get_Text: Utf8String; override;
      function get_Xml: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aVersion, aEncoding, aStandalone: Utf8String);
      property Version: Utf8String read fVersion write fVersion;
      property Encoding: Utf8String read fEncoding write fEncoding;
      property Standalone: Utf8String read fStandalone write fStandalone;
    end;


    TXmlProcessingInstruction = class(TXmlNode)
    private
      fInstruction: Utf8String;
      fTarget: Utf8String;
    protected
      function get_Text: Utf8String; override;
      function get_Xml: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aTarget: Utf8String;
                         const aInstruction: Utf8String);
      property Instruction: Utf8String read fInstruction;
      property Target: Utf8String read fTarget;
    end;


    TXmlText = class(TXmlNode)
    private
      fContainsReferences: NullableBoolean;
      fText: Utf8String;
      function get_ContainsReferences: Boolean;
    protected
      function get_Text: Utf8String; override;
      function get_Xml: Utf8String; override;
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aText: Utf8String); overload;
      property ContainsReferences: Boolean read get_ContainsReferences;
    end;


    TXmlDocument = class(TXmlNode)
    private
      fDocType: TXmlDocType;
      fErrors: TStringList;
      fNodes: TXmlNodeList;
      fRoot: TXmlElement;
      fWarnings: TStringList;
      procedure set_DocType(const aValue: TXmlDocType);
      procedure set_Root(const aValue: TXmlElement);
    protected
      function get_Xml: Utf8String; override;
      procedure set_Xml(const aXml: Utf8String);
      procedure Assign(const aSource: TXmlNode); overload; override;
      procedure DeleteNode(const aNode: TXmlNode); override;
    public
      class function CreateFrom(const aString: String): TXmlDocument;
      class function CreateFromFile(const aFilename: String): TXmlDocument;
      class function CreateFromStream(const aStream: TStream): TXmlDocument;
      constructor Create; overload;
      destructor Destroy; override;
      procedure Assign(const aSource: TXmlDocument); reintroduce; overload;
      procedure Clear;
      procedure LoadFromFile(const aFilename: String);
      procedure LoadFromStream(const aStream: TStream);
      procedure SaveToFile(const aFilename: String);
      procedure SaveToStream(const aStream: TStream);
      property DocType: TXmlDocType read fDocType write set_DocType;
      property Errors: TStringList read fErrors;
      property Nodes: TXmlNodeList read fNodes;
      property Root: TXmlElement read fRoot write set_Root;
      property Warnings: TStringList read fWarnings;
      property Xml: Utf8String read get_Xml write set_Xml;
    end;


    TXmlFragment = class(TXmlNode)
    private
      fErrors: TStringList;
      fNodes: TXmlNodeList;
      fWarnings: TStringList;
    protected
      procedure Assign(const aSource: TXmlNode); overload; override;
    public
      constructor Create; overload;
      destructor Destroy; override;
      procedure Add(const aNode: TXmlNode);
      procedure Assign(const aSource: TXmlFragment); reintroduce; overload;
      procedure Clear;
      procedure LoadFromFile(const aFilename: String);
      procedure LoadFromStream(const aStream: TStream);
      function SelectNode(const aQuery: Utf8String): TXmlNode;
      function SelectNodes(const aQuery: Utf8String): IXmlNodeSelection;
      property Nodes: TXmlNodeList read fNodes;
      property Errors: TStringList read fErrors;
      property Warnings: TStringList read fWarnings;
    end;





implementation

  uses
  { vcl: }
    SysUtils,
  { deltics: }
    Deltics.Exceptions,
    Deltics.InterfacedObjects,
    Deltics.IO.Streams,
    Deltics.StringTemplates,
    Deltics.Xml.Reader,
    Deltics.Xml.Selections,
    Deltics.Xml.Writer;





{ TXmlNode --------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNode.Create(const aNodeType: TXmlNodeType);
  begin
    inherited Create;
    fNodeType := aNodeType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlNode.Destroy;
  begin
    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_AsAttribute: TXmlAttribute;
  begin
    if NOT (fNodeType = xmlAttribute) then
      raise EConvertError.Create('Xml node is not an attribute');

    result := TXmlAttribute(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_AsElement: TXmlElement;
  begin
    if NOT (fNodeType = xmlElement) then
      raise EConvertError.Create('Xml node is not an element');

    result := TXmlElement(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Document: TXmlDocument;
  var
    node: TXmlNode absolute result;
  begin
    node := self;

    while Assigned(node) and (node.NodeType <> xmlDocument) do
      node := node.Parent;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Index: Integer;
  var
    parent: TXmlElement;
  begin
    result := -1;

    if fParent is TXmlElement then
    begin
      parent := TXmlElement(fParent);
      result := parent.Nodes.fItems.IndexOf(self);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Name: Utf8String;
  begin
    result := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Path: Utf8String;
  begin
    if Assigned(Parent) then
      result := Parent.Path + '/' + Name
    else
      result := Name;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.get_Text: Utf8String;
  begin
    result := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.set_Text(const Value: Utf8String);
  begin
    // NO-OP
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.Clone: TXmlNode;
  begin
    result := TXmlElement(ClassType.Create);
    result.Assign(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.Delete;
  begin
    if NOT Assigned(Parent) then
      raise Exception.Create('Cannot delete orphan node');

    Parent.DeleteNode(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNode.DeleteNode(const aNode: TXmlNode);
  begin
    // NO-OP
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectAttribute(const aPath: Utf8String): TXmlAttribute;
  var
    node: TXmlNode;
  begin
    node := SelectNode(aPath);

    if NOT Assigned(node) or (node.NodeType <> xmlAttribute) then
      raise Exception.CreateFmt('''%s'' is not a valid attribute path', [aPath]);

    result := TXmlAttribute(node);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectAttribute(const aElementPath: Utf8String;
                                    const aAttribute: Utf8String): TXmlAttribute;
  var
    node: TXmlNode;
  begin
    node := SelectNode(aElementPath + '@' + aAttribute);

    if NOT Assigned(node) or (node.NodeType <> xmlAttribute) then
      raise Exception.CreateFmt('''%s'' is not a valid attribute path', [aElementPath + '@' + aAttribute]);

    result := TXmlAttribute(node);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectElement(const aPath: Utf8String): TXmlElement;
  var
    node: TXmlNode;
  begin
    node := SelectNode(aPath);
    if NOT Assigned(node) or (node.NodeType <> xmlElement) then
      raise Exception.CreateFmt('''%s'' is not a valid element path', [aPath]);

    result := TXmlElement(node);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectNode(const aPath: Utf8String): TXmlNode;
  var
    element: TXmlElement absolute result;
    i: Integer;
    query: Utf8String;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    subquery: Utf8String;
    parts: StringArray;
    elementName: Utf8String;
    attrName: Utf8String;
  begin
    result  := NIL;
    query   := aPath;

    if (query <>'') and (query[1] = '/') then
    begin
      elements := TXmlElementSelection.Create(Document.Nodes);
      System.Delete(query, 1, 1);
    end
    else case NodeType of
      xmlElement  : elements := TXmlElementSelection.Create(TXmlElement(self).Nodes);
      xmlDocument : elements := TXmlElementSelection.Create(TXmlDocument(self).Nodes);
    else
      EXIT;
    end;

    template := TStringTemplate.Create('', '{', '}');
    match    := TStringList.Create;
    try
      if template.Matches('{root}/{subquery}', STR.FromUtf8(query), match) then
      begin
        elementName := Utf8.FromString(match.Values['root']);
        subquery    := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = elementName) then
          begin
            result := elements[i].SelectNode(subquery);
            if Assigned(result) then
              BREAK;
          end;
      end
      else
      begin
        case STR.Split(STR.FromUtf8(query), '@', parts) of
          1 : begin
                elementName := query;
                attrName    := ''
              end;

          2 : begin
                elementName := Utf8.FromString(parts[0]);
                attrName    := Utf8.FromString(parts[1]);
              end;
        end;

        result := elements.ItemByName(elementName);

        if Assigned(result) and (attrName <> '') then
        begin
          if (result.NodeType <> xmlElement) then
            raise Exception.CreateFmt('''%s'' is not an element', [result.Path]);

          result := element.Attributes.ByName(attrName);
        end;
      end;

    finally
      match.Free;
      template.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNode.SelectNodes(const aPath: Utf8String): IXmlNodeSelection;
  var
    i: Integer;
    query: Utf8String;
    selection: TXmlNodeSelection;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    root: Utf8String;
    subquery: Utf8String;
  begin
    selection := TXmlNodeSelection.Create;
    result    := selection;

    query := aPath;
    if (query <> '') and (query[1] = '/') then
    begin
      elements := TXmlElementSelection.Create(Document.Nodes);
      System.Delete(query, 1, 1);
    end
    else case NodeType of
      xmlElement  : elements := TXmlElementSelection.Create(TXmlElement(self).Nodes);
      xmlDocument : elements := TXmlElementSelection.Create(TXmlDocument(self).Nodes);
    else
      EXIT;
    end;

    template  := TStringTemplate.Create('[root]/[subquery]');
    match     := TStringList.Create;
    try
      if template.Matches(STR.FromUtf8(query), match) then
      begin
        root      := Utf8.FromString(match.Values['root']);
        subquery  := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = root) then
            selection.Add(elements[i].SelectNodes(subquery));
      end
      else
        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = query) then
            selection.Add(elements[i]);

    finally
      match.Free;
      template.Free;
    end;
  end;





{ TXmlNodeList ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNodeList.Create(const aOwner: TXmlNode);
  begin
    inherited Create;

    fOwner  := aOwner;
    fItems  := TObjectList.Create(TRUE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlNodeList.Destroy;
  begin
    FreeAndNIL(fItems);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.get_Text: Utf8String;
  var
    i: Integer;
  begin
    result := '';

    for i := 0 to Pred(Count) do
      case Items[i].NodeType of
        xmlElement,
        xmlText     : result := result + Items[i].Text;
      end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.get_Item(const aIndex: Integer): TXmlNode;
  begin
    result := TXmlNode(fItems[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.get_Xml: Utf8String;
  var
    i: Integer;
  begin
    result := '';
    for i := 0 to Pred(Count) do
      result := result + Items[i].Xml + #13;

    if Length(result) > 0 then
      SetLength(result, Length(result) - 1);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Insert(const aIndex: Integer;
                                const aNode: TXmlNode);
  begin
    InternalAdd(aNode, aIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.InternalAdd(const aNode: TXmlNode;
                                     const aIndex: Integer);
  var
    clone: Boolean;
    node: TXmlNode;
  begin
    if NOT Assigned(aNode) then
      EXIT;

    ASSERT(CanAdd(aNode), 'Attempted to add a ' + aNode.ClassName + ' to a ' + ClassName);

    // If the node we are adding already has a parent then we add a CLONE of the
    //  node rather than detaching it from it's current document

    clone := Assigned(aNode.Parent);
    if clone then
      node := aNode.Clone
    else
      node := aNode;

    try
      node.fParent := fOwner;

      if (aIndex = -1) or (aIndex >= Count) then
        fItems.Add(node)
      else
        fItems.Insert(aIndex, node);

    except
      if clone then
        node.Free;

      raise;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Add(const aNode: TXmlNode);
  begin
    InternalAdd(aNode);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Assign(const aSource: TXmlNodeList);
  var
    i: Integer;
  begin
    fItems.Clear;
    fItems.Capacity := aSource.Count;

    for i := 0 to Pred(aSource.Count) do
      Add(aSource[i].Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNodeList.CanAdd(const aNode: TXmlNode): Boolean;
  begin
    result := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Clear;
  begin
    fItems.Clear;
    fItems.Capacity := 0;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Delete(const aIndex: Integer);
  begin
    fItems.Delete(aIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNodeList.Delete(const aNode: TXmlNode);
  begin
    fItems.Remove(aNode);
  end;







{ TXmlAttributeList ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlAttributeList.Add(const aName, aValue: Utf8String);
  begin
    InternalAdd(TXmlAttribute.Create(aName, aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.ByName(const aName: Utf8String;
                                    const aCreate: Boolean): TXmlAttribute;
  var
    i: Integer;
  begin
    result := NIL;

    for i := 0 to Pred(Count) do
      if (Items[i].Name = aName) then
      begin
        result := Items[i];
        BREAK;
      end;

    if NOT Assigned(result) and aCreate then
    begin
      result := TXmlAttribute.Create(aName, '');
      Add(result);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.ByValue(const aValue: Utf8String): TXmlAttribute;
  var
    i: Integer;
  begin
    result := NIL;

    for i := 0 to Pred(Count) do
      if (Items[i].Value = aValue) then
      begin
        result := Items[i];
        BREAK;
      end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.get_Item(const aIndex: Integer): TXmlAttribute;
  begin
    result := TXmlAttribute(inherited get_Item(aIndex));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.get_Xml: Utf8String;
  var
    i: Integer;
  begin
    result := '';
    for i := 0 to Pred(Count) do
      result := result + Items[i].Xml + ' ';

    if Length(result) > 0 then
      SetLength(result, Length(result) - 1);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlAttributeList.Add(const aAttribute: TXmlAttribute);
  begin
    InternalAdd(aAttribute);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttributeList.CanAdd(const aNode: TXmlNode): Boolean;
  begin
    result := (aNode.NodeType = xmlAttribute);
  end;







{ TXmlVirtualNodeList ---------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlVirtualNodeList.Create(const aSource: TXmlNodeList);
  begin
    inherited Create;

    fNodes := aSource;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlVirtualNodeList.get_Count: Integer;
  var
    i: Integer;
  begin
    result := 0;

    for i := 0 to Pred(Nodes.Count) do
      if IsListMember(Nodes[i]) then
        Inc(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlVirtualNodeList.get_Item(const aIndex: Integer): TXmlNode;
  var
    i: Integer;
    idx: Integer;
  begin
    idx     := 0;
    result  := NIL;

    for i := 0 to Pred(Nodes.Count) do
    begin
      if IsListMember(Nodes[i]) then
      begin
        if (idx = aIndex) then
        begin
          result := Nodes[i];
          BREAK;
        end
        else
          Inc(idx);
      end;
    end;

    if NOT Assigned(result) then
      raise EListError.CreateFmt('List index out of bounds (%d)', [aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlVirtualNodeList.IsListMember(const aNode: TXmlNode): Boolean;
  begin
    result := TRUE;
  end;






{ TXmlNamespaceBindings -------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceBindings.get_Item(const aIndex: Integer): TXmlNamespace;
  begin
    result := TXmlNamespace(inherited get_Item(aIndex));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespaceBindings.Add(const aPrefix, aURI: Utf8String);
  begin
    Nodes.Add(TXmlNamespace.Create(aPrefix, aURI));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceBindings.IsListMember(const aNode: TXmlNode): Boolean;
  var
    attr: TXmlAttribute absolute aNode;
  begin
    result := (aNode.NodeType = xmlAttribute) and attr.IsNamespaceBinding;
  end;







{ TXmlNamespaceNode ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlNamespaceNode.Create(const aNodeType: TXmlNodeType;
                                       const aName: Utf8String);
  begin
    inherited Create(aNodeType);

    set_Name(aName);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespaceNode.Assign(const aSource: TXmlNode);
  var
    src: TXmlNamespaceNode absolute aSource;
  begin
    inherited;

    fLocalName      := src.fLocalName;
    fNamespaceName  := src.fNamespaceName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.get_Name: Utf8String;
  begin
    if (fNamespaceName <> '') then
      result := fNamespaceName + ':' + LocalName
    else
      result := LocalName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.get_Namespace: TXmlNamespace;
  begin
    if NOT FindNamespaceByPrefix(fNamespaceName, result) then
      raise Exception.Create('Invalid namespace reference')
    else if (result.Prefix = '') and (result.Name = '') then
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespaceNode.set_Name(const aValue: Utf8String);
  var
    parts: StringArray;
  begin
    case STR.Split(STR.FromUtf8(aValue), ':', parts) of
      1 : fLocalName := aValue;

      2 : begin
            fNamespaceName  := Utf8.FromString(parts[0]);
            fLocalName      := Utf8.FromString(parts[1]);
          end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespaceNode.FindNamespaceByPrefix(const aPrefix: Utf8String;
                                                   var aNamespace: TXmlNamespace): Boolean;
  var
    element: TXmlElement;
  begin
    case NodeType of
      xmlAttribute  : element := Parent.AsElement;
      xmlElement    : element := self.AsElement;
    else
      element := NIL;
    end;

    while Assigned(element) do
    begin
      aNamespace := element.NamespaceByPrefix(aPrefix);
      if NOT Assigned(aNamespace) and (element.Parent.NodeType = xmlElement) then
        element := TXmlElement(element.Parent)
      else
        BREAK;
    end;

    result := Assigned(aNamespace);
  end;









{ TXmlAttribute ---------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlAttribute.Create(const aNodeType: TXmlNodeType; const aName, aValue: Utf8String);
  begin
    inherited Create(aNodeType, aName);

    fValue := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlAttribute.Create(const aName, aValue: Utf8String);
  begin
    Create(xmlAttribute, aName, aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_AsNamespace: TXmlNamespace;
  begin
    if NOT IsNamespaceBinding then
      raise EConvertError.Create('Attribute is not a namespace binding');

    result := TXmlNamespace(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_IsNamespaceBinding: Boolean;
  begin
    result := (NamespaceName = 'Xmlns') or ((NamespaceName = '') and (LocalName = 'Xmlns'));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_Namespace: TXmlNamespace;
  begin
    if (NamespaceName <> '') then
      result := inherited get_Namespace
    else
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_Text: Utf8String;
  begin
    result := fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlAttribute.get_Xml: Utf8String;
  begin
    result := Name + '="' + Value + '"';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlAttribute.Assign(const aSource: TXmlNode);
  var
    src: TXmlAttribute absolute aSource;
  begin
    inherited;

    fValue  := src.fValue;
  end;




{ TXmlNamespace ---------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespace.get_IsDefault: Boolean;
  begin
    result := ((inherited Name) = 'Xmlns');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespace.get_Name: Utf8String;
  begin
    result := inherited Value;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlNamespace.get_Prefix: Utf8String;
  begin
    result := LocalName;
    if (LocalName = 'Xmlns') then
      result := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespace.set_Name(const aValue: Utf8String);
  begin
    inherited Value := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlNamespace.set_Prefix(const aValue: Utf8String);
  begin
    if (aValue = '') then
      inherited Name := 'Xmlns'
    else
      inherited Name := 'Xmlns:' + aValue;
  end;







{ TXmlCDATA -------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlCDATA.Create(const aText: Utf8String);
  begin
    inherited Create(xmlCDATA);

    fText := aText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlCDATA.get_Text: Utf8String;
  begin
    result := fText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlCDATA.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlCDATA.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlCDATA.Assign(const aSource: TXmlNode);
  var
    src: TXmlCData absolute aSource;
  begin
    inherited;

    fText := src.fText;
  end;










{ TXmlComment ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlComment.Create(const aText: Utf8String);
  begin
    inherited Create(xmlComment);

    fText := aText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlComment.get_Text: Utf8String;
  begin
    result := fText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlComment.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlComment.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlComment.Assign(const aSource: TXmlNode);
  var
    src: TXmlComment absolute aSource;
  begin
    inherited;

    fText := src.fText;
  end;







{ TXmlDocType ------------------------------------------------------------------------------------ }

  { TXmlFPI ---------------------------------------------------------------------------- }

    { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
    constructor TXmlFPI.Create(const aFPI: Utf8String);
    begin
      inherited Create;
      AsString := aFPI;
    end;


    { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
    function TXmlFPI.get_AsString: Utf8String;
    begin
      result := fStandard + '//'
              + fOrganisation + '//'
              + fDocumentType + '//'
              + fLanguage;
    end;


    { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
    procedure TXmlFPI.set_AsString(const aValue: Utf8String);
    var
      i: Integer;
      s: String;
      p: Integer;
    begin
      fStandard     := '';
      fOrganisation := '';
      fDocumentType := '';
      fLanguage     := '';

      i := 0;
      s := STR.FromUtf8(aValue);
      p := Pos('//', s);
      while (p > 0) do
      begin
        case i of
          0 : fStandard     := Utf8.FromString(Copy(s, 1, p - 1));
          1 : fOrganisation := Utf8.FromString(Copy(s, 1, p - 1));
          2 : fDocumentType := Utf8.FromString(Copy(s, 1, p - 1));
          3 : fLanguage     := Utf8.FromString(Copy(s, 1, p - 1));
        else
          raise Exception.Create('''' + STR.FromUtf8(aValue) + ''' is not a valid FPI');
        end;
        Delete(s, 1, p + 1);

        p := Pos('//', s);
      end;

      fLanguage := Utf8.FromString(s);

      if (fStandard = '')
       or (fOrganisation = '')
       or (fDocumentType = '')
       or (fLanguage     = '') then
        raise Exception.Create('''' + STR.FromUtf8(aValue) + ''' is not a valid FPI');
    end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocType.Create(const aRoot: Utf8String);
  begin
    inherited Create(xmlDocType);

    fRoot := aRoot;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocType.CreateInternal(const aRoot: Utf8String);
  begin
    Create(aRoot);

    fNodes  := TXmlNodeList.Create(self);
    fScope  := dtdInternal;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocType.CreatePublic(const aRoot, aFPI, aLocation: Utf8String);
  begin
    Create(aRoot);

    fScope    := dtdPublic;
    fLocation := aLocation;

    fFPI := TXmlFPI.Create(aFPI);

    fInternalSubset := TXmlNodeList.Create(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocType.CreateSystem(const aRoot, aLocation: Utf8String);
  begin
    Create(aRoot);

    fScope    := dtdSystem;
    fLocation := aLocation;

    fInternalSubset := TXmlNodeList.Create(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlDocType.Destroy;
  begin
    FreeAndNIL(fInternalSubset);
    FreeAndNIL(fNodes);
    FreeAndNIL(fFPI);
    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocType.get_Name: Utf8String;
  begin
    result := fRoot;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocType.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDocType.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocType.Assign(const aSource: TXmlNode);
  var
    src: TXmlDocType absolute aSource;
  begin
    inherited;

    fInternalSubset.Assign(src.InternalSubset);
    fNodes.Assign(src.Nodes);

    fLocation := src.Location;
    fRoot     := src.Root;
    fScope    := src.Scope;

    if Assigned(src.FPI) then
    begin
      if Assigned(FPI) then
        fFPI.AsString := src.FPI.AsString
      else
        fFPI := TXmlFPI.Create(src.FPI.AsString)
    end
    else
      FreeAndNIL(fFPI);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocType.set_InternalSubset(const aValue: TXmlNodeList);
  begin
    if NOT Assigned(fInternalSubset) then
      raise Exception.Create('Internal DocType cannot have an InternalSubset');

    fInternalSubset.Assign(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocType.set_Location(const aValue: Utf8String);
  begin
    fLocation := aValue;
  end;








{ TXmlElement ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlElement.Create(const aName: Utf8String);
  begin
    inherited Create(xmlElement, aName);

    fAttributes         := TXmlAttributeList.Create(self);
    fNamespaceBindings  := TXmlNamespaceBindings.Create(fAttributes);
    fNodes              := TXmlNodeList.Create(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlElement.CreateEmpty(const aName: Utf8String);
  begin
    Create(aName);
    fIsEmpty := TRUE;

    // TODO: Validation against doctype or scheme if present (when added to a document)
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlElement.Destroy;
  begin
    FreeAndNIL(fNodes);
    FreeAndNIL(fNamespaceBindings);
    FreeAndNIL(fAttributes);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_IsEmpty: Boolean;
  begin
    result := fIsEmpty;

    if NOT Assigned(Document) then
      EXIT;

    // TODO: When part of a document, override/determine result from doctype or
    //        schema (if present)
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_Text: Utf8String;
  begin
    result := Nodes.Text;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_Value: String;
  var
    i: Integer;
  begin
    result := '';

    for i := 0 to Pred(Nodes.Count) do
      if Nodes[i].NodeType = xmlText then
      begin
        result := STR.FromUtf8(Nodes[i].Text);
        BREAK;
      end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.get_Xml: Utf8String;
  begin
    if IsEmpty then
      result := '<' + Name + ' ' + Attributes.Xml + ' />'
    else if (Nodes.Count > 0) then
    begin
      if (Attributes.Count > 0) then
        result := '<' + Name + ' ' + Attributes.Xml + '>'#13
      else
        result := '<' + Name + '>'#13;

      result := result + Nodes.Xml + #13
              + '</' + Name + '>'
    end
    else
      result := '<' + Name + '>' + Nodes.Xml + '</' + Name + '>';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.ContainsElement(const aName: Utf8String;
                                       var   aElement: TXmlElement): Boolean;
  var
    i: Integer;
    node: TXmlNode;
    element: TXmlElement absolute node;
  begin
    result    := FALSE;
    aElement  := NIL;

    for i := 0 to Pred(Nodes.Count) do
    begin
      node    := Nodes[i];
      result  := (node.NodeType = xmlElement) and (element.Name = aName);

      if result then
      begin
        aElement := element;
        EXIT;
      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.HasAttribute(const aName: Utf8String): Boolean;
  var
    notUsed: Utf8String;
  begin
    result := HasAttribute(aName, notUsed);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.HasAttribute(const aName: Utf8String;
                                    var   aValue: Utf8String): Boolean;
  var
    attr: TXmlAttribute;
  begin
    attr    := Attributes.ByName(aName);
    result  := Assigned(attr);

    if result then
      aValue := attr.Value;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.NamespaceByPrefix(const aPrefix: Utf8String): TXmlNamespace;
  var
    i: Integer;
  begin
    result := NIL;

    for i := 0 to Pred(fNamespaceBindings.Count) do
      if (fNamespaceBindings[i].Prefix = aPrefix) then
      begin
        result := fNamespaceBindings[i];
        BREAK;
      end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlElement.set_IsEmpty(const aValue: Boolean);
  begin
    // TODO: Clear children if setting TRUE
    fIsEmpty := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlElement.set_Text(const aValue: Utf8String);
  var
    i: Integer;
  begin
    inherited;

    for i := Pred(Nodes.Count) downto 0 do
      if Nodes[i].NodeType in [xmlElement, xmlText] then
        Nodes.Delete(i);

    // TODO: Parse the text content to add text and elements as required.
    //
    //   i.e.  Text := 'This text <b>is</b> made up of text <u>and</u> <i>elements</i>.';

    Nodes.Add(TXmlText.Create(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlElement.AllNamespaces: IXmlNamespaceSelection;
  {
    Returns a NamespaceSelection that identifies all in scope namespaces
     for the element.
  }
  var
    i: Integer;
    element: TXmlElement;
    selection: TXmlNamespaceSelection;
    namespace: TXmlNamespace;
  begin
    selection := TXmlNamespaceSelection.Create(fAttributes);
    result := selection;

    if (Parent.NodeType <> xmlElement) then
      EXIT;

    element := self;

    while TRUE do
    begin
      element := TXmlElement(element.Parent);

      for i := 0 to Pred(element.Namespaces.Count) do
      begin
        namespace := element.Namespaces[i];
        if NOT Assigned(selection.ItemByPrefix(namespace.Prefix)) then
          selection.Add(namespace);
      end;

      if (element.Parent.NodeType <> xmlElement) then
        BREAK;
    end;

    if FindNamespaceByPrefix('', namespace)
     and (namespace.Prefix = '') and (namespace.Name = '') then
    begin
      namespace := selection.ItemByPrefix('');
      selection.Remove(namespace);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlElement.Assign(const aSource: TXmlNode);
  var
    src: TXmlElement absolute aSource;
  begin
    inherited;

    fAttributes.Assign(src.fAttributes);
    fNodes.Assign(src.fNodes)
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlElement.DeleteNode(const aNode: TXmlNode);
  begin
    inherited;
    if (aNode.NodeType = xmlAttribute) then
      fAttributes.Delete(aNode)
    else
      fNodes.Delete(aNode);
  end;











{ TXmlDeclaration -------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDeclaration.Create(const aVersion, aEncoding, aStandalone: Utf8String);
  begin
    inherited Create(xmlDeclaration);

    fVersion    := aVersion;
    fEncoding   := aEncoding;
    fStandalone := aStandalone;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDeclaration.get_Text: Utf8String;
  begin
    result := '';

    if fVersion = '' then EXIT;
    result := Utf8.FromString(STR.FromUtf8(result) + Format('version="%s"', [STR.FromUtf8(fVersion)]));

    if fEncoding = '' then EXIT;
    result := Utf8.FromString(STR.FromUtf8(result) + Format('encoding="%s"', [STR.FromUtf8(fEncoding)]));

    if fStandalone = '' then EXIT;
    result := Utf8.FromString(STR.FromUtf8(result) + Format('standalone="%s"', [STR.FromUtf8(fStandalone)]));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDeclaration.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDeclaration.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDeclaration.Assign(const aSource: TXmlNode);
  var
    src: TXmlDeclaration absolute aSource;
  begin
    inherited;

    fVersion    := src.Version;
    fEncoding   := src.Encoding;
    fStandalone := src.Standalone;
  end;









{ TXmlProcessingInstruction ---------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlProcessingInstruction.Create(const aTarget, aInstruction: Utf8String);
  begin
    inherited Create(xmlProcessingInstruction);

    fTarget       := aTarget;
    fInstruction  := aInstruction;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProcessingInstruction.get_Text: Utf8String;
  begin
    result := fInstruction;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProcessingInstruction.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlProcessingInstruction.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlProcessingInstruction.Assign(const aSource: TXmlNode);
  var
    src: TXmlProcessingInstruction absolute aSource;
  begin
    inherited;

    fTarget       := src.fTarget;
    fInstruction  := src.fInstruction;
  end;







{ TXmlText --------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlText.Create(const aText: Utf8String);
  begin
    inherited Create(xmlText);

    fText := aText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlText.get_ContainsReferences: Boolean;
  begin
    if fContainsReferences.IsNull then
      fContainsReferences.Value := Pos('&', STR.FromUtf8(fText)) > 0;

    result := fContainsReferences.Value;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlText.get_Text: Utf8String;
  begin
    result := fText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlText.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDocText.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlText.Assign(const aSource: TXmlNode);
  var
    src: TXmlText absolute aSource;
  begin
    inherited;

    fText               := src.fText;
    fContainsReferences := src.fContainsReferences;
  end;








{ TXmlDocument ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TXmlDocument.CreateFrom(const aString: String): TXmlDocument;
  var
    strm: TStringStream;
  begin
    strm := TStringStream.Create(aString);
    try
      result := CreateFromStream(strm);

    finally
      strm.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TXmlDocument.CreateFromFile(const aFilename: String): TXmlDocument;
  var
    strm: TFileStream;
  begin
    strm := TFileStream.Create(aFilename, fmOpenRead);
    try
      result := CreateFromStream(strm);

    finally
      strm.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TXmlDocument.CreateFromStream(const aStream: TStream): TXmlDocument;
  var
    reader: TXmlReader;
  begin
    result := TXmlDocument.Create;
    reader := TXmlReader.Create;
    try
      reader.LoadDocument(result, aStream);

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocument.Create;
  begin
    inherited Create(xmlDocument);

    fNodes    := TXmlNodeList.Create(self);
    fErrors   := TStringList.Create;
    fWarnings := TStringList.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlDocument.Destroy;
  begin
    fRoot := NIL;

    FreeAndNIL(fWarnings);
    FreeAndNIL(fErrors);
    FreeAndNIL(fNodes);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.get_Xml: Utf8String;
  begin
    result := Nodes.Xml;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.set_DocType(const aValue: TXmlDocType);
  var
    docType: TXmlDocType;
  begin
    if Assigned(aValue) and Assigned(fDocType) then
      raise Exception.Create('Document already has a DOCTYPE');

    if Assigned(fDocType) then
      fDocType.Delete;

    docType := aValue;
    if Assigned(docType.Parent) then
      docType := TXmlDocType(docType.Clone);

    fNodes.Add(docType);
    fDocType := docType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.set_Root(const aValue: TXmlElement);
  var
    element: TXmlElement;
  begin
    if Assigned(aValue) and Assigned(fRoot) then
      raise Exception.Create('Document already has a root node');

    if Assigned(fRoot) then
      fRoot.Delete;

    element := aValue;
    if Assigned(element.Parent) then
      element := TXmlElement(element.Clone);

    fNodes.Add(element);
    fRoot := element;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.set_Xml(const aXml: Utf8String);
  var
    doc: TXmlDocument;
    reader: TXmlReader;
    stream: TStringStream;
  begin
    if Length(aXml) = 0 then
    begin
      Clear;
      EXIT;
    end;

    reader  := NIL;
    stream  := NIL;

    doc := TXmlDocument.Create;
    try
      reader  := TXmlReader.Create;
      stream  := TStringStream.Create;
      stream.Write(aXml[1], Length(aXml));
      stream.Position := 0;

      reader.LoadDocument(doc, stream);

    finally
      self.Assign(doc);
      stream.Free;
      reader.Free;
      doc.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.Assign(const aSource: TXmlNode);
  var
    src: TXmlDocument absolute aSource;
  begin
    fNodes.Assign(src.Nodes);
    fErrors.Assign(src.Errors);
    fWarnings.Assign(src.Warnings);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.Assign(const aSource: TXmlDocument);
  var
    i: Integer;
  begin
    fErrors.Assign(aSource.Errors);
    fWarnings.Assign(aSource.Warnings);

    fRoot := NIL;
    fNodes.Assign(aSource.Nodes);

    for i := 0 to Pred(fNodes.Count) do
      if (fNodes[i].NodeType = xmlElement) then
      begin
        fRoot := TXmlElement(fNodes[i]);
        BREAK;
      end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.Clear;
  begin
    fRoot := NIL;

    fNodes.Clear;
    fErrors.Clear;
    fWarnings.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.DeleteNode(const aNode: TXmlNode);
  begin
    fNodes.Delete(aNode);

    case aNode.NodeType of
      xmlDocType  : fDocType  := NIL;
      xmlElement  : fRoot     := NIL;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.LoadFromFile(const aFilename: String);
  var
    strm: TFileStream;
  begin
    strm := TFileStream.Create(aFilename, fmOpenRead);
    try
      LoadFromStream(strm);

    finally
      strm.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.LoadFromStream(const aStream: TStream);
  var
    reader: TXmlReader;
  begin
    reader := TXmlReader.Create;
    try
      reader.LoadDocument(self, aStream);

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.SaveToFile(const aFilename: String);
  var
    stream: TFileStream;
  begin
    stream := TFileStream.Create(aFilename, fmOpenWrite or fmCreate);
    try
      SaveToStream(stream);

    finally
      stream.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.SaveToStream(const aStream: TStream);
  var
    writer: TXmlWriter;
  begin
    writer := TXmlWriter.Create;
    try
      writer.SaveDocument(self, aStream);

    finally
      writer.Free;
    end;
  end;







{ TXmlFragment ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlFragment.Create;
  begin
    inherited Create(xmlFragment);

    fErrors   := TStringList.Create;
    fWarnings := TStringList.Create;
    fNodes    := TXmlNodeList.Create(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlFragment.Destroy;
  begin
    FreeAndNIL(fNodes);
    FreeAndNIL(fWarnings);
    FreeAndNIL(fErrors);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.Add(const aNode: TXmlNode);
  begin
    fNodes.Add(aNode);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.Assign(const aSource: TXmlFragment);
  var
    i: Integer;
  begin
    Clear;

    for i := 0 to Pred(aSource.Nodes.Count) do
      Add(aSource.Nodes[i].Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.Assign(const aSource: TXmlNode);
  begin

  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.Clear;
  begin
    fNodes.Clear;
    fErrors.Clear;
    fWarnings.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.LoadFromFile(const aFilename: String);
  var
    strm: TFileStream;
  begin
    strm := TFileStream.Create(aFilename, fmOpenRead);
    try
      LoadFromStream(strm);

    finally
      strm.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlFragment.LoadFromStream(const aStream: TStream);
  var
    reader: TXmlReader;
  begin
    reader := TXmlReader.Create;
    try
      reader.LoadFragment(self, aStream);

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFragment.SelectNode(const aQuery: Utf8String): TXmlNode;
  var
    i: Integer;
    query: Utf8String;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    root: Utf8String;
    subquery: Utf8String;
  begin
    result  := NIL;
    query   := aQuery;

    if (query <> '') and (query[1] = '/') then
      System.Delete(query, 1, 1);

    elements  := TXmlElementSelection.Create(fNodes);
    template  := TStringTemplate.Create('[root]/[subquery]');
    match     := TStringList.Create;
    try
      if template.Matches(STR.FromUtf8(query), match) then
      begin
        root      := Utf8.FromString(match.Values['root']);
        subquery  := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = root) then
          begin
            result := elements[i].SelectNode(subquery);
            if Assigned(result) then
              BREAK;
          end;
      end
      else
        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = query) then
          begin
            result := elements[i];
            BREAK;
          end;

    finally
      match.Free;
      template.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFragment.SelectNodes(const aQuery: Utf8String): IXmlNodeSelection;
  var
    i: Integer;
    query: Utf8String;
    selection: TXmlNodeSelection;
    elements: IXmlElementSelection;
    template: TStringTemplate;
    match: TStringList;
    root: Utf8String;
    subquery: Utf8String;
  begin
    selection := TXmlNodeSelection.Create;
    result    := selection;
    query     := aQuery;

    if (query <> '') and (query[1] = '/') then
      System.Delete(query, 1, 1);

    elements  := TXmlElementSelection.Create(fNodes);
    template  := TStringTemplate.Create('[root]/[subquery]');
    match     := TStringList.Create;
    try
      if template.Matches(STR.FromUtf8(query), match) then
      begin
        root      := Utf8.FromString(match.Values['root']);
        subquery  := Utf8.FromString(match.Values['subquery']);

        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = root) then
            selection.Add(elements[i].SelectNodes(subquery));
      end
      else
        for i := 0 to Pred(elements.Count) do
          if (elements[i].Name = query) then
            selection.Add(elements[i]);

    finally
      match.Free;
      template.Free;
    end;
  end;







{ TXmlDtdAttListDeclaration ---------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdAttListDeclaration.Create;
  begin
    inherited Create(dtdAttList);

    fAttributes := TXmlNodeList.Create(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlDtdAttListDeclaration.Destroy;
  begin
    FreeAndNIL(fAttributes);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttListDeclaration.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDtdAttListDeclaration.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttListDeclaration.Add(const aName: Utf8String;
                                         const aType: TXmlDtdAttributeType): TXmlDtdAttributeDeclaration;
  begin
    result := TXmlDtdAttributeDeclaration.Create(aName, aType);
    fAttributes.Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdAttListDeclaration.Assign(const aSource: TXmlNode);
  begin
    raise ENotImplemented.Create('TXmlDtdAttListDeclaration.Assign');
  end;











{ TXmlDtdAttributeDeclaration -------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdAttributeDeclaration.Create(const aName: Utf8String;
                                                 const aType: TXmlDtdAttributeType);
  begin
    inherited Create(dtdAttribute);

    fName           := aName;
    fAttributeType  := aType;

    if fAttributeType in [atEnum, atNotation] then
      fMembers := TStringList.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlDtdAttributeDeclaration.Destroy;
  begin
    FreeAndNIL(fMembers);
    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttributeDeclaration.get_Name: Utf8String;
  begin
    result := fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdAttributeDeclaration.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDtdAttributeDeclaration.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdAttributeDeclaration.Assign(const aSource: TXmlNode);
  begin
    raise ENotImplemented.Create('TXmlDtdAttributeDeclaration.Assign');
  end;







{ TXmlDtdEntityDeclaration ----------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdEntityDeclaration.Assign(const aSource: TXmlNode);
  begin
    raise ENotImplemented.Create('TXmlDtdEntityDeclaration.Assign');
  end;

  constructor TXmlDtdEntityDeclaration.Create(const aName: Utf8String;
                                              const aContent: Utf8String);
  begin
    inherited Create(dtdEntity);

    fName     := aName;
    fContent  := aContent;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdEntityDeclaration.get_Name: Utf8String;
  begin
    result := fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdEntityDeclaration.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDtdEntityDeclaration.get_Xml');
  end;










{ TXmlDtdElementDeclaration ----------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdElementDeclaration.Create(const aName: String);
  begin
    inherited Create(dtdElement);

    fName     := Utf8.FromString(aName);
    fCategory := ecMixed;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdElementDeclaration.Create(const aName: String;
                                               const aContent: TXmlDtdContentParticleList);

    procedure SetElementAndParent(const aPart: TXmlDtdContentParticle);
    var
      i: Integer;
      sub: TXmlDtdContentParticleList absolute aPart;
    begin
      aPart.fElement := self;

      if aPart is TXmlDtdContentParticleList then
        for i := 0 to Pred(sub.Count) do
        begin
          sub[i].fParent := aPart;
          SetElementAndParent(sub[i]);
        end;
    end;

  begin
    Create(aName);

    fContent := aContent;

    if NOT Assigned(Content) then
      EXIT;

    if (Content.Count > 0) and (Content[0].IsPCDATA) then
    begin
      // The content list contains at least one initial #PCDATA in addition to
      //  further children.  We can remove the initial #PCDATA cp as this is
      //  required/assumed for MIXED elements

      Content.Delete(0);

      // If there are no other children then we can dispose of the content
      //  list entirely.  Either way our work is done.

      if (Content.Count = 0) then
        FreeAndNIL(fContent);
    end
    else
      fCategory := ecChildren;

    if Assigned(Content) then
      SetElementAndParent(Content);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdElementDeclaration.CreateANY(const aName: String);
  begin
    Create(aName);
    fCategory := ecAny;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdElementDeclaration.CreateEMPTY(const aName: String);
  begin
    Create(aName);
    fCategory := ecEmpty;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlDtdElementDeclaration.Destroy;
  begin
    FreeAndNIL(fContent);
    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdElementDeclaration.get_Name: Utf8String;
  begin
    result := fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdElementDeclaration.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDtdElementDeclaration.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdElementDeclaration.Assign(const aSource: TXmlNode);
  var
    src: TXmlDtdElementDeclaration absolute aSource;
  begin
    inherited;

    FreeAndNIL(fContent);

    fName     := src.Name;
    fCategory := src.Category;

    if Assigned(src.Content) then
      fContent := TXmlDtdContentParticleList(src.Content.Clone);
  end;







{ TXmlDtdContentParticle ------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdContentParticle.Create(const aName: Utf8String);
  begin
    inherited Create(dtdContentParticle);

    fName           := aName;
    fIsRequired     := TRUE;
    fAllowMultiple  := FALSE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdContentParticle.CreatePCDATA;
  begin
    Create('');
    fIsPCDATA := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_Element: TXmlDtdElementDeclaration;
  var
    n: TXmlNode;
  begin
    result := NIL;

    n := self;
    while Assigned(n) and (n.NodeType <> dtdElement) do
      n := n.Parent;

    if Assigned(n) then
      result := TXmlDtdElementDeclaration(n);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_Parent: TXmlDtdContentParticle;
  var
    p: TXmlNode;
  begin
    p := inherited Parent;

    if (p.NodeType = dtdContentParticle) then
      result := TXmlDtdContentParticle(p)
    else
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdContentParticle.Assign(const aSource: TXmlNode);
  begin
    raise ENotImplemented.Create('TXmlDtdContentParticle.Assign');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticle.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDtdContentParticle.get_Xml');
  end;





{ TXmlDtdContentParticleList --------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDtdContentParticleList.Create;
  begin
    inherited Create(dtdContentParticleList);

    fItems := TObjectList.Create(TRUE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdContentParticleList.Delete(const aIndex: Integer);
  begin
    fItems.Delete(aIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TXmlDtdContentParticleList.Destroy;
  begin
    FreeAndNIL(fItems);
    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticleList.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticleList.get_Item(const aIndex: Integer): TXmlDtdContentParticle;
  begin
    result := TXmlDtdContentParticle(fItems[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdContentParticleList.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDtdContentParticleList.get_Xml');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdContentParticleList.Assign(const aSource: TXmlNode);
  begin
    raise ENotImplemented.Create('TXmlDtdContentParticleList.Assign');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdContentParticleList.Add(const aParticle: TXmlDtdContentParticle);
  begin
    fItems.Add(aParticle);
  end;










{ TXmlDtdNotationDeclaration --------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDtdNotationDeclaration.Assign(const aSource: TXmlNode);
  begin
    raise ENotImplemented.Create('TXmlDtdNotationDeclaration.Assign');
  end;


  constructor TXmlDtdNotationDeclaration.Create(const aName: Utf8String);
  begin
    inherited Create(dtdNotation);

    fName := aName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdNotationDeclaration.get_Name: Utf8String;
  begin
    result := fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDtdNotationDeclaration.get_Xml: Utf8String;
  begin
    raise ENotImplemented.Create('TXmlDtdNotationDeclaration.get_Xml');
  end;
















end.
