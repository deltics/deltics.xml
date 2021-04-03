
{$i deltics.xml.inc}

  unit Deltics.Xml.Nodes.Comment;


interface

  uses
    Deltics.StringTypes,
    Deltics.Xml.Interfaces,
    Deltics.Xml.Nodes;

  type
    TXmlComment = class(TXmlNode, IXmlComment)
    protected // IXmlNode
      function get_Name: Utf8String; override;
      function get_Text: Utf8String; override;

    protected // IXmlComment
      procedure set_Text(const aValue: Utf8String);

    private
      fText: Utf8String;
    protected
      procedure Assign(const aSource: TXmlNode); override;
    public
      constructor Create(const aText: Utf8String);
    end;


implementation

  uses
    Deltics.Xml.Types;


{ TXmlComment ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TXmlComment.Create(const aText: Utf8String);
  begin
    inherited Create(xmlComment);

    fText := aText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlComment.get_Name: Utf8String;
  begin
    result := '#comment';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TXmlComment.get_Text: Utf8String;
  begin
    result := fText;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlComment.set_Text(const aValue: Utf8String);
  begin
    fText := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TXmlComment.Assign(const aSource: TXmlNode);
  var
    src: TXmlComment absolute aSource;
  begin
    inherited;

    fText := src.fText;
  end;





end.
