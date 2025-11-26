#! /bin/bash
 echo $'0 0 BOL\n0 1 a\n0 2 @\n0 3  \n' | jq -Rn '
  reduce inputs as $line (
    {map: {}}; 
    ($line | split(" ")) as $parts
    | if ($parts | length) < 3 then . 
      else 
        .map[$parts[0]] //= {}
        | .map[$parts[0]][$parts[1]] = ( $parts[2:] | join(" ") )
      end
  )
'
