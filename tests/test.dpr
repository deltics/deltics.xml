
{$define CONSOLE}

{$i deltics.smoketest.inc}

  program test;

uses
  FastMM4,
  Deltics.Smoketest,
  Deltics.Xml in '..\src\Deltics.Xml.pas',
  Deltics.Xml.Exceptions in '..\src\Deltics.Xml.Exceptions.pas',
  Deltics.Xml.Formatter in '..\src\Deltics.Xml.Formatter.pas',
  Deltics.Xml.Fpi in '..\src\Deltics.Xml.Fpi.pas',
  Deltics.Xml.Interfaces in '..\src\Deltics.Xml.Interfaces.pas',
  Deltics.Xml.Loader in '..\src\Deltics.Xml.Loader.pas',
  Deltics.Xml.Parser in '..\src\Deltics.Xml.Parser.pas',
  Deltics.Xml.Reader in '..\src\Deltics.Xml.Reader.pas',
  Deltics.Xml.Selections in '..\src\Deltics.Xml.Selections.pas',
  Deltics.Xml.Types in '..\src\Deltics.Xml.Types.pas',
  Deltics.Xml.Utils in '..\src\Deltics.Xml.Utils.pas',
  Deltics.Xml.Writer in '..\src\Deltics.Xml.Writer.pas',
  Deltics.Xml.XPath in '..\src\Deltics.Xml.XPath.pas',
  Deltics.Xml.Nodes in '..\src\Deltics.Xml.Nodes.pas',
  Deltics.Xml.Nodes.Dtd in '..\src\Deltics.Xml.Nodes.Dtd.pas',
  Deltics.Xml.Nodes.Dtd.Attributes in '..\src\Deltics.Xml.Nodes.Dtd.Attributes.pas',
  Deltics.Xml.Nodes.Dtd.ContentParticles in '..\src\Deltics.Xml.Nodes.Dtd.ContentParticles.pas',
  Deltics.Xml.Nodes.Dtd.Elements in '..\src\Deltics.Xml.Nodes.Dtd.Elements.pas',
  Deltics.Xml.Nodes.Dtd.Entities in '..\src\Deltics.Xml.Nodes.Dtd.Entities.pas',
  Deltics.Xml.Nodes.Dtd.Notation in '..\src\Deltics.Xml.Nodes.Dtd.Notation.pas',
  Deltics.Xml.Nodes.Attributes in '..\src\Deltics.Xml.Nodes.Attributes.pas',
  Deltics.Xml.Nodes.Attributes.Namespaces in '..\src\Deltics.Xml.Nodes.Attributes.Namespaces.pas',
  Deltics.Xml.Nodes.CDATA in '..\src\Deltics.Xml.Nodes.CDATA.pas',
  Deltics.Xml.Nodes.Comment in '..\src\Deltics.Xml.Nodes.Comment.pas',
  Deltics.Xml.Nodes.DocType in '..\src\Deltics.Xml.Nodes.DocType.pas',
  Deltics.Xml.Nodes.Document in '..\src\Deltics.Xml.Nodes.Document.pas',
  Deltics.Xml.Nodes.Elements in '..\src\Deltics.Xml.Nodes.Elements.pas',
  Deltics.Xml.Nodes.Fragment in '..\src\Deltics.Xml.Nodes.Fragment.pas',
  Deltics.Xml.Nodes.ProcessingInstruction in '..\src\Deltics.Xml.Nodes.ProcessingInstruction.pas',
  Deltics.Xml.Nodes.Prolog in '..\src\Deltics.Xml.Nodes.Prolog.pas',
  Deltics.Xml.Nodes.Text in '..\src\Deltics.Xml.Nodes.Text.pas',
  Samples in 'Samples.pas',
  Test.BuildingXmlDocuments in 'Test.BuildingXmlDocuments.pas',
  Test.LoadingXmlDocuments in 'Test.LoadingXmlDocuments.pas',
  Test.FormattingXml in 'Test.FormattingXml.pas',
  Test.XPath in 'Test.XPath.pas',
  Test.DocumentEncoding in 'Test.DocumentEncoding.pas',
  Deltics.Xml.Insertion in '..\src\Deltics.Xml.Insertion.pas',
  Test.NodeInsertion in 'Test.NodeInsertion.pas';

begin
  TestRun.Test(BuildingXmlDocuments);
  TestRun.Test(LoadingXmlDocuments);
  TestRun.Test(FormattingXml);
  TestRun.Test(DocumentEncoding);
  TestRun.Test(NodeInsertion);
  TestRun.Test(XPath);
end.
