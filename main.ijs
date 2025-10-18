NB. The entry point of the application, as well as the CLI

{{
  here =. ({.~1+<./@i:&'/\')>(4!:4''){4!:3''
  if. IFQT do.
    load here,'gui.ijs'
    wd'ide hide'
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

  require here,'parser.ijs'
  require here,'cube.ijs'

  if. JBOXED~:3!:0 ast =. parse_roboksparser_ code do.
    echo ast
    exit 1
  end.

  try.
    state =. {:ast rotate_robokscube_ DEFAULT_STATE_robokscube_
  catcht.
    stderr program,': error: cannot invert a conditional',LF
    exit 2
  end.

  echo'BEFORE:'
  display_robokscube_ DEFAULT_STATE_robokscube_
  echo''
  echo'AFTER:'
  display_robokscube_ state

  exit''
}}''
