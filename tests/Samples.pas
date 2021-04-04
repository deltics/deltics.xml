

  unit Samples;


interface

  function Sample(const aSampleName: String): String;


implementation

  uses
    Deltics.IO.Path;


  function Sample(const aSampleName: String): String;
  begin
  {$ifdef _CICD}
    // CI/CD tests are executed from the repo root
    result := '.\tests\samples';
  {$else}
    result := '..\..\samples';
  {$endif}
    result := Path.Absolute(Path.Append(result, aSampleName + '.xml'));
  end;



end.
