
<#
.SYNOPSIS
Converts bytes to MB GB or TB

.DESCRIPTION
This is a converter to convert byte values to the passed in unit type

.PARAMETER unitTypeConfig
MB, GB or TB

.PARAMETER count
Parameter description

.EXAMPLE
An example

.NOTES
TODO: THIS FILE WILL BE REPLACED WHEN WE REGENERATE THE SDK, SAVE THIS FILE.
#>
Function Convert-BytesToUnit {
  Param(
    [string]
    $unitTypeConfig,
    [Decimal]
    $count
  )
  Process {
    switch ($unitTypeConfig) {
      "MB" {
        $count = $count / 1048576
      }
      "GB" {
        $count = $count / 1073741824
      }
      "TB" {
        $count = $count / 1099511627776
      }
    }
    return $count
  }
}