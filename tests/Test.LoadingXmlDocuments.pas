
{$i deltics.inc}

  unit Test.LoadingXmlDocuments;

interface

  uses
    Deltics.Smoketest;


  type
    LoadingXmlDocuments = class(TTest)
      procedure NoteXml;
      procedure EmptyElement;
      procedure EmptyElementWithAttributes;
      procedure ElementWithChild;
    end;


implementation

  uses
    Deltics.StringLists,
    Deltics.Xml,
    Samples;


{ XmlDocument }

  var
    sut: IXmlDocument;

  procedure LoadingXmlDocuments.NoteXml;
  var
    note: IXmlElement;
  begin
    Xml.Load(sut).FromFile(Sample('note'));

    Test('Document').Assert(sut).IsAssigned;
    Test('Document.DocType').Assert(sut.DocType).IsNIL;
    Test('Document.RootElement').Assert(sut.RootElement).IsAssigned;
    Test('Document.Nodes').Assert(sut.Nodes).IsAssigned;
    Test('Document.Nodes.Count').Assert(sut.Nodes.Count).Equals(2);

    note := sut.RootElement;

    Test('note.Nodes.Count').Assert(note.Nodes.Count).Equals(4);
    Test('note.Nodes[0].Name').AssertUtf8(note.Nodes[0].Name).Equals('to');
    Test('note.Nodes[1].Name').AssertUtf8(note.Nodes[1].Name).Equals('from');
    Test('note.Nodes[2].Name').AssertUtf8(note.Nodes[2].Name).Equals('heading');
    Test('note.Nodes[3].Name').AssertUtf8(note.Nodes[3].Name).Equals('body');

    Test('note.Nodes[0].Text').AssertUtf8(note.Nodes[0].Text).Equals('Tove');
    Test('note.Nodes[1].Text').AssertUtf8(note.Nodes[1].Text).Equals('Jani');
    Test('note.Nodes[2].Text').AssertUtf8(note.Nodes[2].Text).Equals('Reminder');
    Test('note.Nodes[3].Text').AssertUtf8(note.Nodes[3].Text).Equals('Don''t forget me this weekend!');
  end;


  procedure LoadingXmlDocuments.ElementWithChild;
  begin
    Xml.Load(sut).FromString('<root><child /></root>');

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(1);

    Test('RootElement').Assert(sut.RootElement).IsAssigned;
    Test('RootElement.IsEmpty').Assert(sut.RootElement.IsEmpty).IsFalse;
    Test('RootElement.Name').Assertutf8(sut.RootElement.Name).Equals('root');

    Test('RootElement.Nodes').Assert(sut.RootElement.Nodes).IsAssigned;
    Test('RootElement.Nodes.Count').Assert(sut.RootElement.Nodes.Count).Equals(1);
    Test('RootElement.Nodes[0].Name').Assertutf8(sut.RootElement.Nodes[0].Name).Equals('child');
  end;


  procedure LoadingXmlDocuments.EmptyElement;
  begin
    Xml.Load(sut).FromString('<root />');

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(1);
    Test('RootElement').Assert(sut.RootElement).IsAssigned;
    Test('RootElement.IsEmpty').Assert(sut.RootElement.IsEmpty).IsTrue;
    Test('RootElement.Name').Assertutf8(sut.RootElement.Name).Equals('root');
  end;


  procedure LoadingXmlDocuments.EmptyElementWithAttributes;
  begin
    Xml.Load(sut).FromString('<root attr1="first" attr2="second" />');

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(1);

    Test('RootElement').Assert(sut.RootElement).IsAssigned;
    Test('RootElement.IsEmpty').Assert(sut.RootElement.IsEmpty).IsTrue;
    Test('RootElement.Name').Assertutf8(sut.RootElement.Name).Equals('root');

    Test('RootElement.Attributes.Count').Assert(sut.RootElement.Attributes.Count).Equals(2);
    Test('RootElement.Attributes[0].Name').AssertUtf8(sut.RootElement.Attributes[0].Name).Equals('attr1');
    Test('RootElement.Attributes[0].Value').AssertUtf8(sut.RootElement.Attributes[0].Value).Equals('first');
    Test('RootElement.Attributes[1].Name').AssertUtf8(sut.RootElement.Attributes[1].Name).Equals('attr2');
    Test('RootElement.Attributes[1].Value').AssertUtf8(sut.RootElement.Attributes[1].Value).Equals('second');
  end;



end.
