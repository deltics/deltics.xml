
  unit Deltics.Xml.Writer;

interface

  uses
    Classes,
    Deltics.IO.Streams,
    Deltics.Strings,
    Deltics.XML;


  type
    TXMLWriter = class
    private
      fIndent: Integer;
      fStream: TStringStream;
    protected
      procedure Write(aString: String);
//      function ReadCDATA: TXMLCDATA;
//      function ReadComment: TXMLComment;
//      function ReadDocType: TXMLDocType;
      procedure WriteDocument(const aDocument: TXMLDocument);
      procedure WriteElement(const aElement: TXMLElement);
//      function ReadInternalDTD: TXMLDocType;
      procedure WriteNode(const aNode: TXMLNode);
      procedure WriteNodes(const aNodeList: TXMLNodeList);
      procedure WriteProcessingInstruction(const aProcessingInstruction: TXMLProcessingInstruction);
//      function ReadText: TXMLText;
//      function ReadDTDAttList: TXMLDTDAttListDeclaration;
//      function ReadDTDContentParticles: TXMLDTDContentParticleList;
//      function ReadDTDDeclaration: TXMLDTDDeclaration;
//      function ReadDTDElement: TXMLDTDElementDeclaration;
//      function ReadDTDEntity: TXMLDTDEntityDeclaration;
//      function ReadDTDNotation: TXMLDTDNotationDeclaration;
//      procedure UnexpectedNode(const aNode: TXMLNode);
    public
      function Indent: String;
      procedure SaveDocument(const aDocument: TXMLDocument; const aStream: TStream);
      procedure SaveFragment(const aFragment: TXMLFragment; const aStream: TStream);
    end;




implementation

  uses
    SysUtils;

{ TXMLWriter }

  function TXMLWriter.Indent: String;
  begin
    result := STR.StringOf(' ', fIndent * 4);
  end;



  procedure TXMLWriter.SaveDocument(const aDocument: TXMLDocument; const aStream: TStream);
  begin
    fStream := TStringStream.Create;

    // TODO: UTF8 Encoding / Encoding options

    WriteDocument(aDocument);

    fStream.Position := 0;
    aStream.CopyFrom(fStream, fStream.Size);
  end;



  procedure TXMLWriter.SaveFragment(const aFragment: TXMLFragment; const aStream: TStream);
  begin

  end;




  procedure TXMLWriter.Write(aString: String);
  const
    CRLF = ANSIChar(#13) + ANSIChar(#10);
  begin
    fStream.WriteString(Indent);
    fStream.WriteString(aString);
    fStream.WriteString(CRLF);
  end;


  procedure TXMLWriter.WriteDocument(const aDocument: TXMLDocument);
  begin
    WriteNode(aDocument);
  end;



  procedure TXMLWriter.WriteElement(const aElement: TXMLElement);
  var
    i: Integer;
    attr: TXMLAttribute;
    attrs: String;
  begin
    if (aElement.Attributes.Count > 0) then
    begin
      attrs := '';

      for i := 0 to Pred(aElement.Attributes.Count) do
      begin
        attr := aElement.Attributes[i];
        attrs := attrs + STR.FromUTF8(attr.Name) + '="' + STR.FromUTF8(attr.Value) + '" ';
      end;

      SetLength(attrs, Length(attrs) - 1);
    end;

    if (aElement.Nodes.Count = 0)
     or ((aElement.Nodes.Count = 1) and (aElement.Nodes[0].NodeType = xmlText)) then
    begin
      if (aElement.Value = '') and (attrs = '') then
        Write(Format('<%s/>', [aElement.Name]))
      else if (aElement.Value <> '') and (attrs = '') then
        Write(Format('<%s>%s</%s>', [aElement.Name, aElement.Value, aElement.Name]))
      else if (aElement.Value <> '') and (attrs <> '') then
        Write(Format('<%s %s>%s</%s>', [aElement.Name, attrs, aElement.Value, aElement.Name]))
      else if (aElement.Value = '') and (attrs <> '') then
        Write(Format('<%s %s/>', [aElement.Name, attrs]));

      EXIT;
    end;

    if (attrs = '') then
      Write(Format('<%s>', [aElement.Name]))
    else
      Write(Format('<%s %s>', [aElement.Name, attrs]));

    Inc(fIndent);
    WriteNodes(aElement.Nodes);
    Dec(fIndent);

    Write(Format('</%s>', [aElement.Name]));
  end;



  procedure TXMLWriter.WriteNode(const aNode: TXMLNode);
  var
    element: TXMLElement absolute aNode;
    processingInstruction: TXMLProcessingInstruction absolute aNode;
  begin
    case aNode.NodeType of
      xmlDocument               : WriteNodes((aNode as TXMLDocument).Nodes);
      xmlElement                : WriteElement(element);
      xmlProcessingInstruction  : WriteProcessingInstruction(processingInstruction);
    end;
  end;



  procedure TXMLWriter.WriteNodes(const aNodeList: TXMLNodeList);
  var
    i: Integer;
  begin
    for i := 0 to Pred(aNodeList.Count) do
      WriteNode(aNodeList[i]);
  end;



  procedure TXMLWriter.WriteProcessingInstruction(const aProcessingInstruction: TXMLProcessingInstruction);
  begin
    Write(Format('<?%s %s?>', [aProcessingInstruction.Name, aProcessingInstruction.Target]));
  end;




end.
