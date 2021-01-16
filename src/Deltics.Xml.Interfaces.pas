unit Deltics.Xml.Interfaces;

interface

  uses
    Deltics.Strings,
    Deltics.Xml.Types;


  type
    IXmlAttribute = interface;
    IXmlDocument  = interface;
    IXmlElement   = interface;
    IXmlNode      = interface;

    IXmlNodeSelection = interface;


    IXmlAttribute = interface(IXmlNamespaceNode)
    ['{F590C4AA-8902-4870-94BA-3B872EEF0410}']
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


    IXmlNode = interface
    ['{4F9944B3-1526-4264-8C5F-9BAD7B675932}']
      function get_AsAttribute: IXmlAttribute;
      function get_AsElement: IXmlElement;
      function get_Document: IXmlDocument;
      function get_Index: Integer;
      function get_Name: Utf8String;
      function get_Path: Utf8String;
      function get_Text: Utf8String;
      function get_Xml: Utf8String;
      procedure set_Text(const aValue: Utf8String);

      procedure DeleteNode(const aNode: IXmlNode);
      procedure Delete;
      function SelectAttribute(const aPath: Utf8String): IXmlAttribute; overload;
      function SelectAttribute(const aElementPath: Utf8String; const aAttribute: Utf8String): IXmlAttribute; overload;
      function SelectElement(const aPath: Utf8String): IXmlElement;
      function SelectNode(const aPath: Utf8String): IXmlNode;
      function SelectNodes(const aPath: Utf8String): IXmlNodeSelection;
      function Clone: IXmlNode;

      property AsAttribute: IXmlAttribute read get_AsAttribute;
      property AsElement: IXmlElement read get_AsElement;
      property Document: IXmlDocument read get_Document;
      property Index: Integer read get_Index;
      property Name: Utf8String read get_Name;
      property NodeType: TXmlNodeType read get_NodeType;
      property Parent: IXmlNode read get_Parent;
      property Path: Utf8String read get_Path;
      property Text: Utf8String read get_Text;
      property Xml: Utf8String read get_Xml;
    end;


    IXmlNamespaceNode = interface(IXmlNode)
    ['{EBBECF20-2782-4482-8701-F5BA71EEE8B2}']
      procedure set_Name(const aValue: Utf8String);
      function get_LocalName: utf8String;
      function get_Namespace: IXmlNamespace;

      function FindNamespaceByPrefix(const aPrefix: Utf8String; var aNamespace: IXmlNamespace): Boolean;

      property LocalName: Utf8String read get_LocalName;
      property Namespace: IXmlNamespace read get_Namespace;
      property NamespaceName: Utf8String read get_NamespaceName;
      property Name: Utf8String read get_Name write set_Name;
    end;






implementation



end.
