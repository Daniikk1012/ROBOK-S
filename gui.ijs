NB. GUI system

require'cube.ijs'
require'defaults.ijs'
require'parser.ijs'

cocurrent'settings'
load^:fexist'settings.ijs'

cocurrent'gui'
coinsert'jgl2'
coinsert'settings'

9!:1@<.@(+/ .^&2@(6!:0@]))'' NB. Randomize seed, copied from J phrases

STYLESHEET =: noun define
  * {
    font-size: {0}pt;
  }
  Form {
    background-color: rgb({1});
  }
)
MIN_FONT_SIZE =. 12
MAX_FONT_SIZE =. 24

wd'pc main closeok'
wd'pmove _1 _1 800 400'
wd'pn *Rubik''s Cube'
wd'bin hv1h'
wd'cc options button'
wd'cn Options'
wd'bin sz'
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

update_style =: {{
  id =. wd'getp id'
  wd'psel main'
  s =. ('{0}';":FONT_SIZE)stringreplace STYLESHEET
  s =. ('{1}';}.;<@(',',":)"0 BACKGROUND_COLOR)stringreplace s
  wd'pstylesheet *',s
  wd'psel ',id
}}
update_style''

wd'pc options owner ptop'
wd'pn Options'
wd'bin v'
wd'groupbox "Font size"'
wd'bin h'
wd'cc font_size_slider slider'
wd'set _ min ',":MIN_FONT_SIZE
wd'set _ max ',":MAX_FONT_SIZE
wd'set _ value ',":FONT_SIZE
wd'cc font_size_spinbox spinbox'
wd'set _ min ',":MIN_FONT_SIZE
wd'set _ max ',":MAX_FONT_SIZE
wd'set _ value ',":FONT_SIZE
wd'groupboxend'
wd'groupbox "Background color"'
wd'bin g'
wd'grid cell 0 0'
wd'cc background_r_label static'
wd'cn Red:'
wd'grid cell 0 1'
wd'cc background_r_slider slider'
wd'set _ min 0'
wd'set _ max 255'
wd'grid cell 0 2'
wd'cc background_r_spinbox spinbox'
wd'set _ min 0'
wd'set _ max 255'
wd'grid cell 1 0'
wd'cc background_g_label static'
wd'cn Green:'
wd'grid cell 1 1'
wd'cc background_g_slider slider'
wd'set _ min 0'
wd'set _ max 255'
wd'grid cell 1 2'
wd'cc background_g_spinbox spinbox'
wd'set _ min 0'
wd'set _ max 255'
wd'grid cell 2 0'
wd'cc background_b_label static'
wd'cn Blue:'
wd'grid cell 2 1'
wd'cc background_b_slider slider'
wd'set _ min 0'
wd'set _ max 255'
wd'grid cell 2 2'
wd'cc background_b_spinbox spinbox'
wd'set _ min 0'
wd'set _ max 255'
wd'grid cell 3 0'
wd'cc background_hex_label static'
wd'cn Hex:'
wd'grid cell 3 1 1 2'
wd'cc background_hex edit'
wd'set _ regexpvalidator *#?[0-9a-fA-F]{6}'
wd'groupboxend'
wd'bin s'
wd'cc back button'
wd'cn Back'

update_background_color =: {{
  wd'set background_r_slider value ',":0{BACKGROUND_COLOR
  wd'set background_r_spinbox value ',":0{BACKGROUND_COLOR
  wd'set background_g_slider value ',":1{BACKGROUND_COLOR
  wd'set background_g_spinbox value ',":1{BACKGROUND_COLOR
  wd'set background_b_slider value ',":2{BACKGROUND_COLOR
  wd'set background_b_spinbox value ',":2{BACKGROUND_COLOR
  wd'set background_hex text ',,hfd 16 16#:BACKGROUND_COLOR
}}
update_background_color''

wd'psel main'

main_options_button =: {{
  wd'psel options'
  wd'pshow'
  wd'pcenter'
}}

main_scramble_button =: {{
  wd'set scramble_text text *',scramble_text =: scramble_cube_''
  main_compile_button''
}}

main_choose_button =: {{
  file =. wd'mb open1 "Choose file" .'
  if. #file do.
    wd'set path text *',path =: file
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
COLORS =: 255 0 0,255 255 255,0 255 0,255 165 0,255 255 0,:0 0 255

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

options_close =: options_back_button =: {{
  if. _1-:(show nl_settings_'')fwrite'settings.ijs' do.
    wdinfo'Error!';'could not save settings: ',>{:2!:8''
  end.
  wd'pshow hide'
}}

options_font_size_slider_changed =: {{
  wd'set font_size_spinbox value ',":FONT_SIZE_settings_ =: ".font_size_slider
  update_style''
}}

options_font_size_spinbox_changed =: {{
  wd'set font_size_slider value ',":FONT_SIZE_settings_ =: ".font_size_spinbox
  update_style''
}}

update_background_color =: {{
  wd'set background_r_slider value ',":0{BACKGROUND_COLOR
  wd'set background_r_spinbox value ',":0{BACKGROUND_COLOR
  wd'set background_g_slider value ',":1{BACKGROUND_COLOR
  wd'set background_g_spinbox value ',":1{BACKGROUND_COLOR
  wd'set background_b_slider value ',":2{BACKGROUND_COLOR
  wd'set background_b_spinbox value ',":2{BACKGROUND_COLOR
  wd'set background_hex text ',,hfd 16 16#:BACKGROUND_COLOR
}}

options_background_r_slider_changed =: {{
  BACKGROUND_COLOR_settings_ =: BACKGROUND_COLOR 0}~".background_r_slider
  update_background_color''
  update_style''
}}

options_background_r_spinbox_changed =: {{
  BACKGROUND_COLOR_settings_ =: BACKGROUND_COLOR 0}~".background_r_spinbox
  update_background_color''
  update_style''
}}

options_background_g_slider_changed =: {{
  BACKGROUND_COLOR_settings_ =: BACKGROUND_COLOR 1}~".background_g_slider
  update_background_color''
  update_style''
}}

options_background_g_spinbox_changed =: {{
  BACKGROUND_COLOR_settings_ =: BACKGROUND_COLOR 1}~".background_g_spinbox
  update_background_color''
  update_style''
}}

options_background_b_slider_changed =: {{
  BACKGROUND_COLOR_settings_ =: BACKGROUND_COLOR 2}~".background_b_slider
  update_background_color''
  update_style''
}}

options_background_b_spinbox_changed =: {{
  BACKGROUND_COLOR_settings_ =: BACKGROUND_COLOR 2}~".background_b_spinbox
  update_background_color''
  update_style''
}}

options_background_hex_button =: {{
  BACKGROUND_COLOR_settings_ =: (3$256)#:dfh}.^:('#'={:)background_hex
  update_background_color''
  update_style''
}}

wd'pshow'
wd'pcenter'
wd'ptop'
wd'ide hide'
