
{$i deltics.inc}

  unit Test.XPath;


interface

  uses
    Deltics.Smoketest;


  type
    XPath = class(TTest)
      procedure SetupTest;
      procedure SelectNodeSelectsTheRootNode;
      procedure SelectNodeSelectsFirstChildOfMany;
      procedure SelectNodesSelectsAllChildren;
    end;


implementation

  uses
    Deltics.Xml;



{ XPath }

  var
    doc: IXmlDocument;


  procedure XPath.SetupTest;
  begin
    Xml.Load(doc).FromFile('%PROJECTDIR%\samples\menu.xml');
  end;



  procedure XPath.SelectNodeSelectsFirstChildOfMany;
  var
    sut: IXmlElement;
  begin
    sut := doc.SelectNode('menu/item') as IXmlElement;

    Test('result').Assert(sut).IsAssigned;
    Test('result.Name').AssertUtf8(sut.Name).Equals('item');
    Test('result.Nodes.Count').Assert(sut.Nodes.Count).Equals(4);
    Test('result.Nodes[0].Name').AssertUtf8(sut.Nodes[0].Name).Equals('name');
    Test('result.Nodes[0].Text').AssertUtf8(sut.Nodes[0].Text).Equals('Belgian Waffles');
  end;


  procedure XPath.SelectNodeSelectsTheRootNode;
  var
    sut: IXmlNode;
  begin
    sut := doc.SelectNode('menu');

    Test('result').Assert(sut).IsAssigned;
    Test('result.Name').AssertUtf8(sut.Name).Equals('menu');
  end;



  procedure XPath.SelectNodesSelectsAllChildren;
  var
    sut: IXmlNodeSelection;
  begin
    sut := doc.SelectNodes('menu/item');

    Test('result').Assert(sut).IsAssigned;
    Test('result.Count').Assert(sut.Count).Equals(5);
  end;




end.
