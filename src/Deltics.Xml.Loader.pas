
{$i deltics.xml.inc}

  unit Deltics.Xml.Loader;


interface

  uses
    Classes,
    Deltics.InterfacedObjects,
    Deltics.IO.Streams,
    Deltics.StringEncodings,
    Deltics.StringLists,
    Deltics.StringTypes,
    Deltics.Xml.Interfaces;


  type
    PXmlDocument  = ^IXmlDocument;
    PStringList   = ^IStringList;


    TXmlLoader = class(TComInterfacedObject, IXmlLoader, IXmlLoaderYields)
    protected // IXmlLoader
      procedure FromFile(const aFilename: String);
      procedure FromStream(const aStream: TStream);
      procedure FromString(const aString: String);
      procedure FromUnicode(const aString: UnicodeString);
      procedure FromUtf8(const aString: Utf8String);
      function Yielding: IXmlLoaderYields;

    protected // IXmlLoaderYields
      function Errors(var aList: IStringList): IXmlLoader;
      function Warnings(var aList: IStringList): IXmlLoader;

    private
      fDocumentRef: PXmlDocument;
      fErrorsRef: PStringList;
      fWarningsRef: PStringList;
      procedure FromStreamDisposing(const aStream: TStream);
    public
      constructor Create(var aDocumentRef: IXmlDocument);
    end;



implementation

  uses
    SysUtils,
    Deltics.Xml.Nodes.Document,
    Deltics.Xml.Reader;


{ TXmlLoader }

  constructor TXmlLoader.Create(var aDocumentRef: IXmlDocument);
  begin
    inherited Create;

    fDocumentRef := @aDocumentRef;
  end;


  function TXmlLoader.Errors(var aList: IStringList): IXmlLoader;
  begin
    fErrorsRef  := @aList;
    result      := self;
  end;


  procedure TXmlLoader.FromFile(const aFilename: String);
  begin
    FromStreamDisposing(TFileStream.Create(aFilename, fmOpenRead or fmShareDenyWrite));
  end;


  procedure TXmlLoader.FromStream(const aStream: TStream);
  var
    doc: IXmlDocument;
    errors: IStringList;
    warnings: IStringList;
  begin
    with TXmlReader.Create do
    try
      if Assigned(fErrorsRef) then
      begin
        if (fErrorsRef^ = nil) then
          fErrorsRef^ := TStringList.CreateManaged;

        errors := fErrorsRef^;
      end
      else
        errors := NIL;

      if Assigned(fWarningsRef) then
      begin
        if (fWarningsRef^ = nil) then
          fWarningsRef^ := TStringList.CreateManaged;

        warnings := fWarningsRef^;
      end
      else
        warnings := NIL;

      doc := fDocumentRef^;
      if NOT Assigned(doc) then
        doc := TXmlDocument.Create;

      LoadDocument(doc, aStream, errors, warnings);

      fDocumentRef^ := doc;

    finally
      Free;
    end;
  end;


  procedure TXmlLoader.FromStreamDisposing(const aStream: TStream);
  begin
    try
      FromStream(aStream);

    finally
      aStream.Free;
    end;
  end;


  procedure TXmlLoader.FromString(const aString: String);
  begin
    FromStreamDisposing(TFixedMemoryStream.Create(Pointer(aString), Length(aString) * SizeOf(Char)));
  end;


  procedure TXmlLoader.FromUnicode(const aString: UnicodeString);
  begin
  {$ifdef UNICODE}
    FromStreamDisposing(TStringStream.Create(aString));
  {$else}
    FromStreamDisposing(TFixedMemoryStream.Create(Pointer(aString), Length(aString) * 2));
  {$endif}
  end;


  procedure TXmlLoader.FromUtf8(const aString: Utf8String);
  begin
    FromStreamDisposing(TFixedMemoryStream.Create(Pointer(aString), Length(aString)));
  end;


  function TXmlLoader.Warnings(var aList: IStringList): IXmlLoader;
  begin
    fWarningsRef  := @aList;
    result        := self;
  end;


  function TXmlLoader.Yielding: IXmlLoaderYields;
  begin
    result := self;
  end;



end.
