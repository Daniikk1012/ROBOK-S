NB. The entry point of the application, as well as the CLI

{{
  if. IFQT do.
    load'gui.ijs'
    return.
  end.

  ijconsole =. >0{ARGV
  program =. >1{ARGV

  usage =. LF,LF,'usage: ',ijconsole,' ',program,' <filename>',LF

  if. 3~:#ARGV do.
    stderr program,': error: incorrect number of arguments',usage
    exit 1
  end.

  path =. >2{ARGV
  code =. fread path
  if. code-:_1 do.
    'errno error' =. 2!:8''
    stderr program,': error: could not read from ',path,': ',error,usage
    exit errno
  end.

  require'parser.ijs'
  require'cube.ijs'

  if. JBOXED~:3!:0 ast =. parse_parser_ code do.
    echo ast
    exit 1
  end.

  try.
    state =. {:ast rotate_cube_ DEFAULT_STATE_cube_
  catcht.
    stderr program,': error: cannot invert a conditional',LF
    exit 2
  end.

  echo'BEFORE:'
  display_cube_ DEFAULT_STATE_cube_
  echo''
  echo'AFTER:'
  display_cube_ state

  exit''
}}''
