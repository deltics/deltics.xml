
{$i deltics.inc}

unit Test.FormattingXml;


interface

  uses
    Deltics.Smoketest;


  type
    FormattingXml = class(TTest)
      procedure CDATAElements;
      procedure ConcatResults;
      procedure ReadableStringWithNoProlog;
      procedure ReadableStringWithProlog;
      procedure ReadableUtf8WithNoProlog;
    end;


implementation

  uses
    Deltics.StringTypes,
    Deltics.Xml,
    Deltics.Xml.Utils,
    Deltics.Xml.Writer,
    Samples;


{ FormattingXml }

  procedure FormattingXml.CDATAElements;
  const
    EXPECTED : Utf8String = '<root>'#10
                          + '  <![CDATA[The quick brown fox'#10
                          + 'jumped over the lazy dog!]]>'#10
                          + '</root>';
  var
    doc: IXmlDocument;
    s: Utf8String;
  begin
    doc := Xml.Document;
    doc.RootElement := Xml.Element('root');
    doc.RootElement.Add(Xml.CDATA('The quick brown fox'#10'jumped over the lazy dog!'));

    s := Xml.Format(doc)
            .Prolog(FALSE)
            .AsUtf8String;

    Test('result').AssertUtf8(s).Equals(EXPECTED);
  end;


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
    Xml.Load(doc).FromFile(Sample('note'));

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
    Xml.Load(doc).FromFile(Sample('note'));

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
    Xml.Load(doc).FromFile(Sample('note'));

    s := Xml.Format(doc)
            .Prolog(FALSE)
            .AsUtf8String;

    Test('result').AssertUtf8(s).Equals(EXPECTED);
  end;



end.
