
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.ProcessingInstruction;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;


  type
    TXmlProcessingInstruction = class(TXmlNode, IXmlProcessingInstruction)
    protected // IXmlNode
      function get_Name: Utf8String; override;

    protected // IXmlNode
      function get_Content: Utf8String;
      function get_Target: Utf8String;
    private
      fContent: Utf8String;
      fTarget: Utf8String;
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aTarget: Utf8String; const aContent: Utf8String);
      property Content: Utf8String read fContent;
      property Target: Utf8String read fTarget;
    end;



implementation

  uses
    Deltics.Xml.Types;


{ TXmlProcessingInstruction ---------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlProcessingInstruction.Create(const aTarget, aContent: Utf8String);
  begin
    inherited Create(xmlProcessingInstruction);

    fTarget   := aTarget;
    fContent  := aContent;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProcessingInstruction.get_Content: Utf8String;
  begin
    result := fContent;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProcessingInstruction.get_Name: Utf8String;
  begin
    result := fTarget;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlProcessingInstruction.get_Target: Utf8String;
  begin
    result := fTarget;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlProcessingInstruction.Assign(const aSource: TXmlNode);
  var
    src: TXmlProcessingInstruction absolute aSource;
  begin
    inherited;

    fTarget   := src.fTarget;
    fContent  := src.fContent;
  end;


end.
