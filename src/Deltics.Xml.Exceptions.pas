
{$i deltics.xml.inc}

  unit Deltics.Xml.Exceptions;


interface

  uses
    Deltics.Exceptions;


  type
    EXmlException = class(Exception);

    EXmlNodeTypeException = class(EXmlException);


implementation

end.
