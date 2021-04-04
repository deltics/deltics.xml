
{$i deltics.inc}

  unit Test.DocumentEncoding;

interface

  uses
    Deltics.Smoketest;


  type
    DocumentEncoding = class(TTest)
      procedure LoadedFromUnicodeStringHasSourceEncodingUtf16Le;
      procedure LoadedFromUnicodeStringSavesAsUnicodeStringByDefault;
      procedure LoadedFromUnicodeStringSavedAsUtf8SavesAsUtf8;
      procedure LoadedFromUtf8StringHasSourceEncodingUtf8;
      procedure LoadedFromUtf8StringSavesAsUtf16LeEncoding;
      procedure LoadedFromUtf8StringSavesAsUtf8ByDefault;
      procedure PrologEncodingIsUtf8WhenSavedAsUtf8;
      procedure PrologEncodingIsUtf16LeWhenSavedAsUtf16Le;
    end;


implementation

{ DocumentEncoding }

  uses
    Deltics.IO.Streams,
    Deltics.StringEncodings,
    Deltics.StringTypes,
    Deltics.Xml;


  const
    XML_UTF16LE : UnicodeString = '<root/>';
    XML_UTF8    : Utf8String = '<root/>';

  var
    doc: IXmlDocument;
    stream: IStream;


  procedure DocumentEncoding.LoadedFromUnicodeStringHasSourceEncodingUtf16LE;
  begin
    Xml.Load(doc).FromString(XML_UTF16LE);

    Test('Doc.SourceEncoding').Assert(doc.SourceEncoding.Codepage).Equals(cpUtf16Le);
  end;


  procedure DocumentEncoding.LoadedFromUnicodeStringSavedAsUtf8SavesAsUtf8;
  begin
    Xml.Load(doc).FromString(XML_UTF16LE);

    stream := TDynamicMemoryStream.Create;
    doc.SaveToStream(stream, TEncoding.Utf8);

    // A crude test that uses the size of the stream to determine the encoding (1 byte per char)
    Test('Stream.Size').Assert(stream.Stream.Size).Equals(7);
  end;


  procedure DocumentEncoding.LoadedFromUnicodeStringSavesAsUnicodeStringByDefault;
  begin
    Xml.Load(doc).FromString(XML_UTF16LE);

    stream := TDynamicMemoryStream.Create;
    doc.SaveToStream(stream);

    // A crude test that uses the size of the stream to determine the encoding (2 bytes per char)
    Test('Stream.Size').Assert(stream.Stream.Size).Equals(14);
  end;


  procedure DocumentEncoding.LoadedFromUtf8StringHasSourceEncodingUtf8;
  begin
    Xml.Load(doc).FromUtf8(XML_UTF8);

    Test('Doc.SourceEncoding').Assert(doc.SourceEncoding.Codepage).Equals(cpUtf8);
  end;


  procedure DocumentEncoding.LoadedFromUtf8StringSavesAsUtf16LeEncoding;
  begin
    Xml.Load(doc).FromUtf8(XML_UTF8);

    stream := TDynamicMemoryStream.Create;
    doc.SaveToStream(stream, TEncoding.Utf16LE);

    // A crude test that uses the size of the stream to determine the encoding (2 bytes per char)
    Test('Stream.Size').Assert(stream.Stream.Size).Equals(14);
  end;


  procedure DocumentEncoding.LoadedFromUtf8StringSavesAsUtf8ByDefault;
  begin
    Xml.Load(doc).FromUtf8(XML_UTF8);

    stream := TDynamicMemoryStream.Create;
    doc.SaveToStream(stream);

    // A crude test that uses the size of the stream to determine the encoding (1 byte per char)
    Test('Stream.Size').Assert(stream.Stream.Size).Equals(7);
  end;


  procedure DocumentEncoding.PrologEncodingIsUtf16LeWhenSavedAsUtf16Le;
  begin
    Xml.Load(doc).FromUtf8(XML_UTF8);

    Test('Prolog').Assert(doc.Prolog).IsNIL;

    stream := TDynamicMemoryStream.Create;
    Xml.Format(doc).Prolog(TRUE).IntoStream(stream, TEncoding.Utf16LE);

    stream.Seek(0);
    Xml.Load(doc).FromStream(stream);

    Test('Prolog').Assert(doc.Prolog).IsAssigned;
    Test('Prolog.Encoding').AssertUtf8(doc.Prolog.Encoding).Equals('UTF-16LE');
  end;


  procedure DocumentEncoding.PrologEncodingIsUtf8WhenSavedAsUtf8;
  begin
    Xml.Load(doc).FromString(XML_UTF16LE);

    Test('Prolog').Assert(doc.Prolog).IsNIL;

    stream := TDynamicMemoryStream.Create;
    Xml.Format(doc).Prolog(TRUE).IntoStream(stream, TEncoding.Utf8);

    stream.Seek(0);
    Xml.Load(doc).FromStream(stream);

    Test('Prolog').Assert(doc.Prolog).IsAssigned;
    Test('Prolog.Encoding').AssertUtf8(doc.Prolog.Encoding).Equals('UTF-8');
  end;



end.
