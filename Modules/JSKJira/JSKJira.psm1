try {

  $ScriptDir = (Split-Path -parent $MyInvocation.MyCommand.Definition)
  
  if ($IsLinux) {
    # Import all functions
    $Public = Get-ChildItem -Path (Join-Path -Path $ScriptDir -ChildPath 'functions/public') -Filter *.ps1 -Recurse
    $Private = Get-ChildItem -Path (Join-Path -Path $ScriptDir -ChildPath 'functions/private') -Filter *.ps1 -Recurse
  }
  else {
    # Import all functions
    $Public = Get-ChildItem -Path (Join-Path -Path $ScriptDir -ChildPath 'functions\public') -Filter *.ps1 -Recurse
    $Private = Get-ChildItem -Path (Join-Path -Path $ScriptDir -ChildPath 'functions\private') -Filter *.ps1 -Recurse 
  }

  $arr = [System.Collections.Generic.List[object]]::new()

  $arr.AddRange($Public)
  $arr.AddRange($Private)

  foreach ($Func in $arr) {
    . $Func.FullName
  }

  Export-ModuleMember -Function $Public.BaseName


}
catch {
  "Error was $_"
  $line = $_.InvocationInfo.ScriptLineNumber
  "Error was in Line $line"
}