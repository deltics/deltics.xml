
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Document;


interface

  uses
    Classes,
    Deltics.IO.Streams,
    Deltics.Nullable,
    Deltics.StringEncodings,
    Deltics.StringLists,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  type
    TXmlDocument = class(TXmlNode, IXmlDocument, IXmlHasNodes)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlDocument + IXmlHasNodes
      function get_DocType: IXmlDocType;
      function get_Nodes: IXmlNodeList;
      function get_Prolog: IXmlProlog;
      function get_RootElement: IXmlElement;
      function get_SourceEncoding: TEncoding;
      function get_Standalone: Utf8String;
      procedure set_DocType(const aValue: IXmlDocType);
      procedure set_RootElement(const aValue: IXmlElement);
      procedure set_Standalone(const aValue: Utf8String);
//      procedure Add(const aNode: IXmlNode);
      procedure SaveToFile(const aFilename: String; const aEncoding: TEncoding = NIL);
      procedure SaveToStream(const aStream: IStream; const aEncoding: TEncoding = NIL); overload;
      procedure SaveToStream(const aStream: TStream; const aEncoding: TEncoding = NIL); overload;

    private
      fDocType: IXmlDocType;
      fNodes: IXmlNodeList;
      fProlog: IXmlProlog;
      fRootElement: IXmlElement;
      fStandalone: Utf8String;

      fSourceEncoding: TEncoding;
    protected
      function Accepts(const aNode: TXmlNode): Boolean; override;
      procedure Assign(const aSource: TXmlNode); overload; override;
      procedure DeleteNode(const aNode: IXmlNode); override;
      procedure NodeAdded(const aNode: IXmlNode); override;
      procedure NodeDeleted(const aNode: IXmlNode); override;
    public
      constructor Create;
      constructor CreateFromFile(const aFilename: String; const aEncoding: TEncoding = NIL);
      constructor CreateFromStream(const aStream: TStream; const aEncoding: TEncoding = NIL);
      constructor CreateFromString(const aXml: AnsiString); overload;
      constructor CreateFromString(const aXml: UnicodeString); overload;
      constructor CreateFromUtf8(const aXml: Utf8String);
      procedure Reset;
      property DocType: IXmlDocType read fDocType write set_DocType;
      property Nodes: IXmlNodeList read fNodes;
      property Prolog: IXmlProlog read fProlog;
      property RootElement: IXmlElement read fRootElement write set_RootElement;
      property SourceEncoding: TEncoding read fSourceEncoding write fSourceEncoding;
    end;




implementation

  uses
    SysUtils,
    Deltics.InterfacedObjects,
    Deltics.Strings,
    Deltics.Xml.Loader,
    Deltics.Xml.Nodes.DocType,
    Deltics.Xml.Reader,
    Deltics.Xml.Types,
    Deltics.Xml.Utils,
    Deltics.Xml.Writer;


  type
    TEncoding = Deltics.StringEncodings.TEncoding;



{ TXmlDocument ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocument.Create;
  begin
    inherited Create(xmlDocument);

    fNodes := TXmlNodeList.Create(self);

    fStandalone := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocument.CreateFromFile(const aFilename: String;
                                          const aEncoding: TEncoding);
  var
    stream: TFileStream;
  begin
    stream := TFileStream.Create(aFilename, fmOpenRead or fmShareDenyWrite);
    try
      CreateFromStream(stream, aEncoding);

    finally
      stream.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocument.CreateFromStream(const aStream: TStream;
                                            const aEncoding: TEncoding);
  begin
    inherited Create(xmlDocument);

    fNodes := TXmlNodeList.Create(self);

    fStandalone := '';

    TXmlReader.LoadDocument(self, aStream, NIL, NIL);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocument.CreateFromString(const aXml: AnsiString);
  var
    stream: IStream;
    wideXml: UnicodeString;
  begin
    wideXml := Wide.FromAnsi(aXml);
    stream  := TFixedMemoryStream.Create(Pointer(wideXml), Length(wideXml) * 2);
    CreateFromStream(stream.Stream, Encoding.Utf16LE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocument.CreateFromString(const aXml: UnicodeString);
  var
    stream: IStream;
  begin
    stream := TFixedMemoryStream.Create(Pointer(aXml), Length(aXml) * 2);
    CreateFromStream(stream.Stream, Encoding.Utf16LE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlDocument.CreateFromUtf8(const aXml: Utf8String);
  var
    stream: IStream;
  begin
    stream := TFixedMemoryStream.Create(Pointer(aXml), Length(aXml));
    CreateFromStream(stream.Stream, Encoding.Utf8);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.get_DocType: IXmlDocType;
  begin
    result := fDocType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.get_Name: Utf8String;
  begin
    result := '#document';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.get_Nodes: IXmlNodeList;
  begin
    result := fNodes;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.get_Prolog: IXmlProlog;
  begin
    result := fProlog;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.get_RootElement: IXmlElement;
  begin
    result := fRootElement;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.get_SourceEncoding: TEncoding;
  begin
    result := fSourceEncoding;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.get_Standalone: Utf8String;
  begin
    result := fStandalone;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.NodeAdded(const aNode: IXmlNode);
  begin
    case aNode.NodeType of
      xmlDocType  : fDocType := aNode as IXmlDocType;
      xmlElement  : fRootElement := aNode as IXmlElement;
      xmlProlog   : fProlog := aNode as IXmlProlog;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.NodeDeleted(const aNode: IXmlNode);
  begin
    case aNode.NodeType of
      xmlDocType  : fDocType := NIL;
      xmlElement  : fRootElement := NIL;
      xmlProlog   : fProlog := NIL;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.SaveToFile(const aFilename: String;
                                    const aEncoding: TEncoding);
  var
    stream: TFileStream;
  begin
    stream := TFileStream.Create(aFilename, fmCreate or fmShareExclusive);
    try
      SaveToStream(stream, aEncoding);

    finally
      stream.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.SaveToStream(const aStream: IStream;
                                      const aEncoding: TEncoding);
  begin
    SaveToStream(aStream.Stream, aEncoding);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.SaveToStream(const aStream: TStream;
                                      const aEncoding: TEncoding);
  var
    writer: TXmlWriter;
  begin
    writer := TXmlWriter.Create;
    try
      writer.DocumentProlog := Assigned(fProlog);
      writer.Encoding       := aEncoding;
      writer.Readable       := TRUE;
      writer.ReadableIndent := 2;

      if NOT Assigned(writer.Encoding) then
        writer.Encoding := SourceEncoding;

      writer.SaveDocument(self, aStream);

    finally
      writer.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.set_DocType(const aValue: IXmlDocType);
  var
    src: TXmlDocType;
    doctype: IXmlDocType;
    nodes: TXmlNodeList;
  begin
    if Assigned(aValue) and Assigned(fDocType) then
      raise Exception.Create('Document already has a DOCTYPE');

    InterfaceCast(fNodes, TXmlNodeList, nodes);

    if Assigned(fDocType) then
    begin
      DeleteNode(fDocType);
      fDocType := NIL;

      EXIT;
    end;

    InterfaceCast(aValue, TXmlDocType, src);

    if Assigned(src.Parent) then
      doctype := src.Clone as IXmlDocType;

    nodes.Add(doctype);

    fDocType := doctype;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.set_RootElement(const aValue: IXmlElement);
  var
    newRoot: IXmlElement;
    nodes: TXmlNodeList;
  begin
    if Assigned(aValue) and Assigned(fRootElement) then
      raise Exception.Create('Document already has a root node');

    if Assigned(fRootElement) then
      fRootElement.Delete;

    if NOT Assigned(aValue) then
      EXIT;

    if Assigned(aValue.Parent) then
      newRoot := aValue.Clone
    else
      newRoot := aValue;

    InterfaceCast(fNodes, TXmlNodeList, nodes);

    nodes.Add(newRoot);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.set_Standalone(const aValue: Utf8String);
  begin
    if (aValue = 'yes') or (aValue = 'no') then
      fStandalone := aValue
    else
      fStandalone := '';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlDocument.Accepts(const aNode: TXmlNode): Boolean;
  var
    nodeTypes: set of TXmlNodeType;
  begin
    nodeTypes := [xmlComment, xmlDocType, xmlElement, xmlProcessingInstruction, xmlProlog];

    if Assigned(DocType) then
      Exclude(nodeTypes, xmlDocType);

    if Assigned(Prolog) then
      Exclude(nodeTypes, xmlProlog);

    if Assigned(RootElement) then
      Exclude(nodeTypes, xmlElement);

    result := aNode.NodeType in nodeTypes;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.Assign(const aSource: TXmlNode);
  var
    src: TXmlDocument absolute aSource;
    nodes: TXmlNodeList;
  begin
    inherited;

    fStandalone := src.fStandalone;

    InterfaceCast(fNodes, TXmlNodeList, nodes);
    nodes.Assign(src.Nodes);

    if Assigned(src.RootElement) then
      fRootElement := nodes[src.RootElement.Index] as IXmlElement
    else
      fRootElement := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.Reset;
  var
    nodes: TXmlNodeList;
  begin
    InterfaceCast(fNodes, TXmlNodeList, nodes);

    nodes.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlDocument.DeleteNode(const aNode: IXmlNode);
  begin
    AsObject(fNodes).Delete(aNode);
  end;



end.
