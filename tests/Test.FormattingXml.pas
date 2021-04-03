
{$i deltics.inc}

unit Test.FormattingXml;


interface

  uses
    Deltics.Smoketest;


  type
    FormattingXml = class(TTest)
      procedure ConcatResults;
      procedure ReadableStringWithNoProlog;
      procedure ReadableStringWithProlog;
      procedure ReadableUtf8WithNoProlog;
    end;


implementation

  uses
    Deltics.StringTypes,
    Deltics.Xml,
    Deltics.Xml.Writer;


{ FormattingXml }

  procedure FormattingXml.ConcatResults;
  var
    s: Utf8String;
  begin
    s := Concat(['<', 'root', '/>']);
    Test('Concat(<. root, />)').AssertUtf8(s).Equals('<root/>');

    s := Concat(['<', '', '/>']);
    Test('Concat(<. , />)').AssertUtf8(s).Equals('</>');
  end;


  procedure FormattingXml.ReadableStringWithNoProlog;
  const
    EXPECTED : UnicodeString = '<note>'#10
                             + '  <to>Tove</to>'#10
                             + '  <from>Jani</from>'#10
                             + '  <heading>Reminder</heading>'#10
                             + '  <body>Don''t forget me this weekend!</body>'#10
                             + '</note>';
  var
    doc: IXmlDocument;
    s: UnicodeString;
  begin
    Xml.Load(doc).FromFile('X:\dev\src\delphi\libs\congress\deltics.xml\tests\samples\note.xml');

    s := Xml.Format(doc)
            .Prolog(FALSE)
            .AsUnicodeString;

    Test('result').Assert(s).Equals(EXPECTED);
  end;


  procedure FormattingXml.ReadableStringWithProlog;
  const
    EXPECTED : UnicodeString = '<?xml version="1.0" encoding="UTF-16LE"?>'#10
                             + '<note>'#10
                             + '  <to>Tove</to>'#10
                             + '  <from>Jani</from>'#10
                             + '  <heading>Reminder</heading>'#10
                             + '  <body>Don''t forget me this weekend!</body>'#10
                             + '</note>';
  var
    doc: IXmlDocument;
    s: UnicodeString;
  begin
    Xml.Load(doc).FromFile('X:\dev\src\delphi\libs\congress\deltics.xml\tests\samples\note.xml');

    s := Xml.Format(doc)
            .Prolog(TRUE)
            .AsUnicodeString;

    Test('result').Assert(s).Equals(EXPECTED);
  end;


  procedure FormattingXml.ReadableUtf8WithNoProlog;
  const
    EXPECTED : Utf8String = '<note>'#10
                          + '  <to>Tove</to>'#10
                          + '  <from>Jani</from>'#10
                          + '  <heading>Reminder</heading>'#10
                          + '  <body>Don''t forget me this weekend!</body>'#10
                          + '</note>';
  var
    doc: IXmlDocument;
    s: Utf8String;
  begin
    Xml.Load(doc).FromFile('X:\dev\src\delphi\libs\congress\deltics.xml\tests\samples\note.xml');

    s := Xml.Format(doc)
            .Prolog(FALSE)
            .AsUtf8String;

    Test('result').AssertUtf8(s).Equals(EXPECTED);
  end;



end.
