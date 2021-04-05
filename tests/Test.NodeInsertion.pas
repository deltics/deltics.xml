
{$i deltics.inc}

  unit Test.NodeInsertion;

interface

  uses
    Deltics.Smoketest;


  type
    NodeInsertion = class(TTest)
      procedure SetupMethod;
      procedure TestSetupMethod;
      procedure InsertAfter;
      procedure InsertAtIndex;
      procedure InsertBefore;
      procedure InsertFirst;
      procedure InsertLast;
      procedure InsertReplacingIndex;
      procedure InsertReplacingNode;
    end;


    AttributeInsertion = class(TTest)
      procedure SetupMethod;
      procedure TestSetupMethod;
      procedure InsertAfter;
      procedure InsertBefore;
      procedure InsertReplacingNode;
    end;



implementation


  uses
    Deltics.Xml,
    Deltics.Xml.Insertion,
    Deltics.Xml.Nodes;




{ NodeInsertion }

  var
    doc: IXmlDocument;
    sut: IXmlElement;
    a: IXmlNode;
    b: IXmlNode;
    c: IXmlNode;
    i: IXmlNode;

    aa: IXmlAttribute;
    ab: IXmlAttribute;
    ac: IXmlAttribute;
    ai: IXmlAttribute;


  procedure NodeInsertion.SetupMethod;
  begin
    doc := TXmlDocument.CreateFromUtf8('<root><a/><b/><c/></root>');
    sut := doc.RootElement;
    a := sut.Nodes.ItemByName('a');
    b := sut.Nodes.ItemByName('b');
    c := sut.Nodes.ItemByName('c');

    i := Xml.Element('i');
  end;



  procedure NodeInsertion.TestSetupMethod;
  begin
    Test('sut').Assert(sut.Nodes.Count).Equals(3);
    Test('a').Assert(a).IsAssigned;
    Test('a.Index').Assert(a.Index).Equals(0);
    Test('b').Assert(b).IsAssigned;
    Test('b.Index').Assert(b.Index).Equals(1);
    Test('c').Assert(c).IsAssigned;
    Test('c.Index').Assert(c.Index).Equals(2);

    Test('i').Assert(i).IsAssigned;
    Test('i.Index').Assert(i.Index).Equals(-1);
    Test('i.Parent').Assert(i.Parent).IsNIL;
  end;


  procedure NodeInsertion.InsertAfter;
  begin
    sut.Insert(i).After(b);

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(4);
    Test('b.Index').Assert(b.Index).Equals(1);
    Test('c.Index').Assert(c.Index).Equals(3);
    Test('i.Index').Assert(i.Index).Equals(2);
    Test('i.Parent').Assert(i.Parent).Equals(sut);
  end;


  procedure NodeInsertion.InsertAtIndex;
  begin
    sut.Insert(i).AtIndex(1);

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(4);
    Test('a.Index').Assert(a.Index).Equals(0);
    Test('b.Index').Assert(b.Index).Equals(2);
    Test('c.Index').Assert(c.Index).Equals(3);

    Test('i.Index').Assert(i.Index).Equals(1);
    Test('i.Parent').Assert(i.Parent).Equals(sut);
  end;


  procedure NodeInsertion.InsertBefore;
  begin
    sut.Insert(i).Before(b);

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(4);
    Test('b.Index').Assert(b.Index).Equals(2);
    Test('c.Index').Assert(c.Index).Equals(3);
    Test('i.Index').Assert(i.Index).Equals(1);
    Test('i.Parent').Assert(i.Parent).Equals(sut);
  end;


  procedure NodeInsertion.InsertFirst;
  begin
    sut.Insert(i).AsFirst;

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(4);
    Test('a.Index').Assert(a.Index).Equals(1);
    Test('b.Index').Assert(b.Index).Equals(2);
    Test('c.Index').Assert(c.Index).Equals(3);

    Test('i.Index').Assert(i.Index).Equals(0);
    Test('i.Parent').Assert(i.Parent).Equals(sut);
  end;


  procedure NodeInsertion.InsertLast;
  begin
    sut.Insert(i).AsLast;

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(4);
    Test('a.Index').Assert(a.Index).Equals(0);
    Test('b.Index').Assert(b.Index).Equals(1);
    Test('c.Index').Assert(c.Index).Equals(2);

    Test('i.Index').Assert(i.Index).Equals(3);
    Test('i.Parent').Assert(i.Parent).Equals(sut);
  end;


  procedure NodeInsertion.InsertReplacingIndex;
  begin
    sut.Insert(i).Replacing(1); // Replaces 'b'

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(3);
    Test('b.Index').Assert(b.Index).Equals(-1);
    Test('b.Parent').Assert(b.Parent).IsNIL;
    Test('c.Index').Assert(c.Index).Equals(2);
    Test('i.Index').Assert(i.Index).Equals(1);
    Test('i.Parent').Assert(i.Parent).Equals(sut);
  end;


  procedure NodeInsertion.InsertReplacingNode;
  begin
    sut.Insert(i).Replacing(b);

    Test('Nodes.Count').Assert(sut.Nodes.Count).Equals(3);
    Test('b.Index').Assert(b.Index).Equals(-1);
    Test('b.Parent').Assert(b.Parent).IsNIL;
    Test('c.Index').Assert(c.Index).Equals(2);
    Test('i.Index').Assert(i.Index).Equals(1);
    Test('i.Parent').Assert(i.Parent).Equals(sut);
  end;


{ AttributeInsertion }

  procedure AttributeInsertion.SetupMethod;
  begin
    doc := TXmlDocument.CreateFromUtf8('<root a="a" b="b" c="c" />');
    sut := doc.RootElement;
    aa := sut.Attributes.ItemByName('a');
    ab := sut.Attributes.ItemByName('b');
    ac := sut.Attributes.ItemByName('c');

    ai := Xml.Attribute('i', 'i');
  end;


  procedure AttributeInsertion.TestSetupMethod;
  begin
    Test('sut').Assert(sut.Attributes.Count).Equals(3);
    Test('aa').Assert(aa).IsAssigned;
    Test('aa.Index').Assert(aa.Index).Equals(0);
    Test('ab').Assert(ab).IsAssigned;
    Test('ab.Index').Assert(ab.Index).Equals(1);
    Test('ac').Assert(ac).IsAssigned;
    Test('ac.Index').Assert(ac.Index).Equals(2);

    Test('ai').Assert(ai).IsAssigned;
    Test('ai.Index').Assert(ai.Index).Equals(-1);
    Test('ai.Parent').Assert(ai.Parent).IsNIL;
  end;



  procedure AttributeInsertion.InsertAfter;
  begin
    sut.Insert(ai).After(ab);

    Test('Attributes.Count').Assert(sut.Attributes.Count).Equals(4);
    Test('ab.Index').Assert(ab.Index).Equals(1);
    Test('ac.Index').Assert(ac.Index).Equals(3);
    Test('ai.Index').Assert(ai.Index).Equals(2);
    Test('ai.Parent').Assert(ai.Parent).Equals(sut);
  end;


  procedure AttributeInsertion.InsertBefore;
  begin
    sut.Insert(ai).Before(ab);

    Test('Attributes.Count').Assert(sut.Attributes.Count).Equals(4);
    Test('ab.Index').Assert(ab.Index).Equals(2);
    Test('ac.Index').Assert(ac.Index).Equals(3);
    Test('ai.Index').Assert(ai.Index).Equals(1);
    Test('ai.Parent').Assert(ai.Parent).Equals(sut);
  end;


  procedure AttributeInsertion.InsertReplacingNode;
  begin
    sut.Insert(ai).Replacing(ab);

    Test('Attributes.Count').Assert(sut.Attributes.Count).Equals(3);
    Test('ab.Index').Assert(ab.Index).Equals(-1);
    Test('ab.Parent').Assert(ab.Parent).IsNIL;
    Test('ac.Index').Assert(ac.Index).Equals(2);
    Test('ai.Index').Assert(ai.Index).Equals(1);
    Test('ai.Parent').Assert(ai.Parent).Equals(sut);
  end;



end.
