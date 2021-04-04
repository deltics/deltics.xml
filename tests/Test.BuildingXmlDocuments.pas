

  unit Test.BuildingXmlDocuments;

interface

  uses
    Deltics.Smoketest;


  type
    BuildingXmlDocuments = class(TTest)
      procedure NewEmptyDocumentHasExpectedProperties;
      procedure UnparentedElementCanBeDirectlyAssignedAsRootElement;
    end;


implementation

  uses
    Deltics.StringLists,
    Deltics.Xml;


{ XmlDocument }

  procedure BuildingXmlDocuments.NewEmptyDocumentHasExpectedProperties;
  var
    doc: IXmlDocument;
  begin
    doc := Xml.Document;

    Test('Document.DocType').Assert(doc.DocType).IsNIL;
    Test('Document.RootElement').Assert(doc.RootElement).IsNIL;
    Test('Document.Nodes').Assert(doc.Nodes).IsAssigned;
    Test('Document.Nodes.Count').Assert(doc.Nodes.Count).Equals(0);
    Test('Document.Name').AssertUtf8(doc.Name).Equals('#document');
    Test('Document.Document').Assert(doc.Document).Equals(doc);
    Test('Document.Index').Assert(doc.Index).Equals(-1);
  end;


  procedure BuildingXmlDocuments.UnparentedElementCanBeDirectlyAssignedAsRootElement;
  var
    doc: IXmlDocument;
    element: IXmlElement;
  begin
    doc     := Xml.Document;
    element := Xml.Element('project');

    doc.RootElement := element;

    Test('Document.Nodes.Count').Assert(doc.Nodes.Count).Equals(1);

    Test('Document.RootElement').Assert(doc.RootElement).IsAssigned;
    Test('Document.RootElement').Assert(doc.RootElement).Equals(element);
    Test('Document.RootElement.Name').AssertUtf8(doc.RootElement.Name).Equals('project');
    Test('Document.RootElement.IsEmpty').Assert(doc.RootElement.IsEmpty).IsTrue;

    Test('Element.Parent').Assert(element.Parent).IsAssigned;
    Test('Element.Parent').Assert(element.Parent).Equals(doc);
    Test('Element.Document').Assert(element.Document).Equals(doc);
  end;




end.
