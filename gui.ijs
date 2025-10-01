NB. GUI system

require'cube.ijs'
require'parser.ijs'
cocurrent'gui'
coinsert'jgl2'

BACKGROUND_COLOR =: 3$200
BACKGROUND_COLOR_FORMATTED =. }.;<@(',',":)"0 BACKGROUND_COLOR

wd'pc main closeok'
wd'pmove _1 _1 800 400'
wd'pn *Rubik''s Cube'
wd'bin hh1'
wd'cc graphics isigraph'
wd'set _ minwh 50 50'
wd'bin zv1h'
wd'cc scramble_text edit'
wd'cc scramble button'
wd'cn Scramble'
wd'bin zh'
wd'cc choose button'
wd'cn Choose'
wd'cc path edit'
wd'cc load button'
wd'cn Load'
wd'cc save button'
wd'cn Save'
wd'bin z'
wd'cc code editm'
wd'cc compile button'
wd'cn Compile'
wd'pstylesheet *Form{background-color:rgb(',BACKGROUND_COLOR_FORMATTED,')}'

main_scramble_button =: {{ wd'set scramble_text text *',scramble_cube_'' }}

main_choose_button =: {{
  file =. wd'mb open1 "Choose file" .'
  if. #file do.
    wd'set path text *',file
    path =: file
    main_load_button''
  end.
}}

main_path_button =: main_load_button =: {{
  s =. fread path
  if. s-:_1 do.
    wdinfo'Error!';'Could not read from the file: ',>{:2!:8''
  else.
    wd'set code text *',s
  end.
}}

main_save_button =: {{
  if. _1-:code fwrite path do.
    wdinfo'Error!';'Could not write into the file: ',>{:2!:8''
  else.
    wdinfo'Saved successfully'
  end.
}}

NB. State of the cube
STATE =: DEFAULT_STATE_cube_

main_scramble_text_button =: main_compile_button =: {{
  if. JBOXED~:3!:0 ast =. parse_parser_ scramble_text,code do.
    wdinfo'Error!';ast
    STATE =: DEFAULT_STATE_cube_
    glpaint''
    return.
  end.
  try.
    STATE =: ast rotate_cube_ DEFAULT_STATE_cube_
  catcht.
    wdinfo'Error!';'cannot invert a conditional'
    STATE =: DEFAULT_STATE_cube_
    return.
  end.
  glpaint''
}}

NB. Using the same order as SIDES_parser_
COLORS =: 255 0 0,255 165 0,255 255 255,255 255 0,0 255 0,:0 0 255

NB. Polygon points (Relative to viewport size)
NB. For right, top, and front, in that order
FACES =. (1 3r4,1r2 0,:0 3r4),items(1]\.0 1r4,1r2 1,:1 1r4),"2 _]1r2 1r2
spl =. ([+"1(3%~i.4)*"0 _-~)/@:{
lnPP =. (-/ .*,~[:(,~-)/-~/)@,:"1 NB. From J phrases
ptLL =. (-@{:"1%.2&{."1)@,:"1     NB. From J phrases
POINTS =. ((0 2&spl lnPP 1 3&spl)ptLL/0 1&spl lnPP 2 3&spl)items FACES
POSITIONS =: (0 1 3 2{,/)"3]2 2&(];._3)items POINTS
POSITIONS =: |.items@|.&.(0&{)POSITIONS
POSITIONS =: 1 0 2 3&|:&.(1&{)POSITIONS
POSITIONS =: |.@(1 0 2 3&|:)&.(2&{)POSITIONS

NB. The target cube ratio
RATIO =: %:3r4 NB. Ratio of the bounding box of a perfect hexagon

NB. Margin for the graphics
MARGIN =: 5

main_graphics_paint =: {{
  glclear''
  glfill BACKGROUND_COLOR,255
  glpen 2
  gsize =. (glqwh'')-+:MARGIN
  if. RATIO>%/gsize do.
    size =. (,%&RATIO){.gsize
  else.
    size =. (,~*&RATIO){:gsize
  end.
  origin =. MARGIN+-:gsize-size
  'RUF'(]{{
    glrgb y
    glbrush''
    glpolygon x
  }}"1 COLORS{~STATE{~SIDES_parser_ i.[)items,"2 origin+"1 POSITIONS*"1 size
}}

wd'pshow'
wd'pcenter'
wd'ptop'
wd'ide hide'
