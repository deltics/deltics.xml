
  unit Deltics.Xml.Writer;

interface

  uses
    Classes,
    Deltics.IO.Streams,
    Deltics.StringEncodings,
    Deltics.Strings,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Types;


  type
    TXmlWriter = class
    private
      fDocumentProlog: Boolean;
      fEncoding: TEncoding;
      fIndent: Integer;
      fIncludeComments: Boolean;
      fLineEndings: TXmlLineEndings;
      fReadable: Boolean;

      fFirstLine: Boolean;
      fIndentString: Utf8String;
      fStream: TStream;
    private
      procedure DecIndent;
      procedure IncIndent;
    protected
      procedure Write(aString: Utf8String);
      procedure WriteIndent;
      procedure WriteLine(aString: Utf8String);
//      function ReadCDATA: IXmlCDATA;
//      function ReadComment: IXmlComment;
//      function ReadDocType: IXmlDocType;
      procedure WriteDocument(const aDocument: IXmlDocument);
      procedure WriteElement(const aElement: IXmlElement);
//      function ReadInternalDtd: IXmlDocType;
      procedure WriteNode(const aNode: IXmlNode);
      procedure WriteNodes(const aNodeList: IXmlNodeList);
      procedure WriteProcessingInstruction(const aProcessingInstruction: IXmlProcessingInstruction);
      procedure WriteProlog(const aStandalone: Utf8String);
//      function ReadText: IXmlText;
//      function ReadDtdAttList: IXmlDtdAttListDeclaration;
//      function ReadDtdContentParticles: IXmlDtdContentParticleList;
//      function ReadDtdDeclaration: IXmlDtdDeclaration;
//      function ReadDtdElement: IXmlDtdElementDeclaration;
//      function ReadDtdEntity: IXmlDtdEntityDeclaration;
//      function ReadDtdNotation: IXmlDtdNotationDeclaration;
//      procedure UnexpectedNode(const aNode: IXmlNode);
    public
      constructor Create;
      property DocumentProlog: Boolean read fDocumentProlog write fDocumentProlog;
      property Encoding: TEncoding read fEncoding write fEncoding;
      property LineEndings: TXmlLineEndings read fLineEndings write fLineEndings;
      property IncludeComments: Boolean read fIncludeComments write fIncludeComments;
      property Readable: Boolean read fReadable write fReadable;
      property ReadableIndent: Integer read fIndent write fIndent;

      procedure SaveDocument(const aDocument: IXmlDocument; const aStream: TStream);
      procedure SaveFragment(const aFragment: IXmlFragment; const aStream: TStream);
    end;




implementation

//  uses
//    SysUtils;
  uses
    Deltics.Exceptions,
    Deltics.Memory,
    Deltics.ReverseBytes,
    Deltics.Unicode,
    Deltics.Xml.Utils;




{ TXmlWriter }

  constructor TXmlWriter.Create;
  begin
    inherited;

    fEncoding     := TEncoding.Utf8;
    fIndent       := 2;
    fIndentString := '';
    fLineEndings  := xmlLF;
    fReadable     := TRUE;
  end;


  procedure TXmlWriter.WriteIndent;
  begin
    Write(fIndentString);
  end;


  procedure TXmlWriter.DecIndent;
  begin
    if fIndent = 0 then
      EXIT;

    if Length(fIndentString) > 0 then
      SetLength(fIndentString, Length(fIndentString) - fIndent)
    else
      raise Exception.Create('Ooops');
  end;


  procedure TXmlWriter.IncIndent;
  var
    i: Integer;
  begin
    if fIndent = 0 then
      EXIT;

    i := Length(fIndentString);
    SetLength(fIndentString, i + fIndent);

    for i := i + 1 to Length(fIndentString) do
      fIndentString[i] := ' ';
  end;


  procedure TXmlWriter.SaveDocument(const aDocument: IXmlDocument; const aStream: TStream);
  begin
    fFirstLine  := TRUE;
    fStream     := aStream;

    if DocumentProlog then
      WriteProlog(aDocument.Standalone);

    WriteDocument(aDocument);
  end;



  procedure TXmlWriter.SaveFragment(const aFragment: IXmlFragment; const aStream: TStream);
  begin

  end;


  procedure TXmlWriter.Write(aString: Utf8String);
  var
    s: UnicodeString;
    bytes: PWideChar;
  begin
    if Length(aString) = 0 then
      EXIT;

    case fEncoding.Codepage of
      cpUtf8    : fStream.Write(aString[1], Length(aString));

      cpUtf16Le : begin
                    s := Unicode.Utf8ToUtf16(aString);
                    fStream.Write(s[1], Length(s) * 2);
                  end;

      cpUtf16   : begin
                    s := Unicode.Utf8ToUtf16(aString);

                    GetMem(bytes, Length(s) * 2);
                    try
                      ReverseBytes(PWord(bytes), Length(s));
                      fStream.Write(bytes^, Length(s) * 2);

                    finally
                      FreeMem(bytes);
                    end;
                  end;
    else
      raise Exception.Create('Encoding is not supported');
    end;
  end;


  procedure TXmlWriter.WriteLine(aString: Utf8String);
  const
    UTF8_ENDING     : Utf8String = #13#10;
    UTF16LE_ENDING  : UnicodeString = #$000d#$000a;
    UTF16_ENDING    : UnicodeString = #$0d00#$0a00;
  begin
    if Readable then
    begin
      if NOT fFirstLine then
        case fEncoding.CodePage of
          cpUtf8  : case fLineEndings of
                      xmlLF   : fStream.Write(UTF8_ENDING[2], 1);
                      xmlCRLF : fStream.Write(UTF8_ENDING[1], 2);
                    end;

          cpUtf16  : case fLineEndings of
                      xmlLF   : fStream.Write(UTF16_ENDING[2], 2);
                      xmlCRLF : fStream.Write(UTF16_ENDING[1], 4);
                    end;

          cpUtf16LE  : case fLineEndings of
                      xmlLF   : fStream.Write(UTF16LE_ENDING[2], 2);
                      xmlCRLF : fStream.Write(UTF16LE_ENDING[1], 4);
                    end;
        end;

      fFirstLine := FALSE;

      WriteIndent;
    end;

    Write(aString);
  end;


  procedure TXmlWriter.WriteDocument(const aDocument: IXmlDocument);
  begin
    WriteNode(aDocument);
  end;


  procedure TXmlWriter.WriteElement(const aElement: IXmlElement);
  var
    i: Integer;
    attr: IXmlAttribute;
    attrs: Utf8String;
    s: Utf8String;
  begin
    if (aElement.Attributes.Count > 0) then
    begin
      attrs := '';

      for i := 0 to Pred(aElement.Attributes.Count) do
      begin
        attr  := aElement.Attributes[i];
        attrs := Concat([attrs, attr.Name, '="', attr.Value, '" ']);
      end;

      SetLength(attrs, Length(attrs) - 1);
    end;

    if (aElement.IsEmpty)
     or ((aElement.Nodes.Count = 1) and (aElement.Nodes[0].NodeType = xmlText)) then
    begin
      case Length(attrs) of
        0 : if aElement.IsEmpty and (attrs = '') then
              s := Concat(['<', aElement.Name, '/>'])
            else
              s := Concat(['<', aElement.Name, '>', aElement.Text, '</', aElement.Name, '>']);
      else
        if aElement.IsEmpty then
          s := Concat(['<', aElement.Name, ' ', attrs, '>', aElement.Text, '</', aElement.Name, '>'])
        else
          s := Concat(['<', aElement.Name, ' ', attrs, '/>']);
      end;

      WriteLine(s);

      EXIT;
    end;

    if (attrs = '') then
      WriteLine(Concat(['<', aElement.Name, '>']))
    else
      WriteLine(Concat(['<', aElement.Name, ' ', attrs, '>']));

    IncIndent;
    WriteNodes(aElement.Nodes);
    DecIndent;

    WriteLine(Concat(['</', aElement.Name, '>']));
  end;



  procedure TXmlWriter.WriteNode(const aNode: IXmlNode);
  begin
    case aNode.NodeType of
      xmlDocument               : WriteNodes((aNode as IXmlDocument).Nodes);
      xmlElement                : WriteElement(aNode as IXmlElement);
      xmlProcessingInstruction  : WriteProcessingInstruction(aNode as IXmlProcessingInstruction);
    end;
  end;



  procedure TXmlWriter.WriteNodes(const aNodeList: IXmlNodeList);
  var
    i: Integer;
  begin
    for i := 0 to Pred(aNodeList.Count) do
      WriteNode(aNodeList[i]);
  end;



  procedure TXmlWriter.WriteProcessingInstruction(const aProcessingInstruction: IXmlProcessingInstruction);
  begin
    WriteLine(Concat(['<?', aProcessingInstruction.Name, ' ', aProcessingInstruction.Target, '?>']));
  end;



  procedure TXmlWriter.WriteProlog(const aStandalone: Utf8String);
  var
    encoding: Utf8String;
  begin
    case fEncoding.Codepage of
      cpUtf8    : encoding := 'UTF-8';
      cpUtf16   : encoding := 'UTF-16';
      cpUtf16LE : encoding := 'UTF-16LE';
    end;

    if aStandalone <> '' then
      WriteLine(Concat(['<?xml version="1.0" encoding="', encoding, '" standalone="', aStandalone, '"?>']))
    else
      WriteLine(Concat(['<?xml version="1.0" encoding="', encoding, '"?>']));
  end;



end.
