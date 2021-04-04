
{$i deltics.xml.inc}

  unit Deltics.Xml.Formatter;


interface

  uses
    Classes,
    Deltics.InterfacedObjects,
    Deltics.IO.Streams,
    Deltics.StringEncodings,
    Deltics.StringLists,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Types;


  type
    PStringList   = ^IStringList;


    TXmlFormatter = class(TComInterfacedObject, IXmlFormatter, IXmlFormatterYields)
    protected // IXmlFormatter
      function AsUnicodeString: UnicodeString;
      function AsUtf8String: Utf8String;
      function LineEndings(const aValue: TXmlLineEndings): IXmlFormatter;
      function Prolog(const aValue: Boolean): IXmlFormatter;
      function Readable(const aValue: Boolean): IXmlFormatter;
      function Yielding: IXmlFormatterYields;

    protected // IXmlLoaderYields
      function Errors(var aList: IStringList): IXmlFormatter;
      function Warnings(var aList: IStringList): IXmlFormatter;

    private
      fLineEndings: TXmlLineEndings;
      fProlog: Boolean;
      fIndent: Integer;
      fRootNode: IXmlNode;
      fErrorsRef: PStringList;
      fWarningsRef: PStringList;
    public
      constructor Create(const aRootNode: IXmlNode);
    end;



implementation

  uses
    Deltics.Memory,
    Deltics.Xml.Writer;


{ TXmlFormatter ---------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlFormatter.Create(const aRootNode: IXmlNode);
  begin
    inherited Create;

    fRootNode     := aRootNode;
    fIndent       := 2;
    fLineEndings  := xmlLF;
    fProlog       := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFormatter.AsUnicodeString: UnicodeString;
  var
    writer: TXmlWriter;
    stream: IMemoryStream;
  begin
    writer := TXmlWriter.Create;
    try
      writer.DocumentProlog := fProlog;
      writer.Encoding       := Encoding.Utf16LE;
      writer.Readable       := fIndent > -1;
      writer.ReadableIndent := fIndent;

      stream := TDynamicMemoryStream.Create;
      writer.SaveDocument(fRootNode as IXmlDocument, stream.Stream);
    finally
      writer.Free;
    end;

    SetLength(result, stream.Stream.Size div 2);
    Memory.Copy(stream.BaseAddress, stream.Stream.Size, Pointer(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFormatter.AsUtf8String: Utf8String;
  var
    writer: TXmlWriter;
    stream: IMemoryStream;
  begin
    writer := TXmlWriter.Create;
    try
      writer.DocumentProlog := fProlog;
      writer.Encoding       := Encoding.Utf8;
      writer.Readable       := fIndent > -1;
      writer.ReadableIndent := fIndent;

      stream := TDynamicMemoryStream.Create;
      writer.SaveDocument(fRootNode as IXmlDocument, stream.Stream);
    finally
      writer.Free;
    end;

    SetLength(result, stream.Stream.Size);
    Memory.Copy(stream.BaseAddress, stream.Stream.Size, Pointer(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFormatter.Errors(var aList: IStringList): IXmlFormatter;
  begin
    fErrorsRef  := @aList;
    result      := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFormatter.LineEndings(const aValue: TXmlLineEndings): IXmlFormatter;
  begin
    fLineEndings  := aValue;
    result        := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFormatter.Prolog(const aValue: Boolean): IXmlFormatter;
  begin
    fProlog := aValue;
    result  := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFormatter.Readable(const aValue: Boolean): IXmlFormatter;
  begin
    if aValue then
      fIndent := 2
    else
      fIndent := -1;

    result  := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFormatter.Warnings(var aList: IStringList): IXmlFormatter;
  begin
    fWarningsRef  := @aList;
    result        := self;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlFormatter.Yielding: IXmlFormatterYields;
  begin
    result := self;
  end;




end.
