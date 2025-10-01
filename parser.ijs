NB. Parser for the extended Rubik's cube notation

require'jarser.ijs'
cocurrent'parser'
coinsert'jarser'

NB. All possible basic (Without modifiers) turns
TURNS =: 'RLUDFBrludfbxyzMES'

Note'Cube state'
  State is a list of six 3x3 tables. Each 3x3 is a side. Order: R L U D F B.
  Left, Right, Front and Back sides are oriented with Up side on the top.
  Up side is oriented with Back side on the top.
  Down side is oriented with Front side on the top.
  This is done for easy rendering in the unwrapped form.
  Sticker IDs are indices to state in ravelled form
)

SIDES =: 'RLUDFB'
ADJASCENT =: 'UFBD','UBFD','BLRF','FLRB','ULRD',:'URLD'

NB. AST type enum. The variables have names AST_*.
NB. List of all AST type names is in AST_TYPES.
NB. AST is encoded using boxed lists of varying lengths, where first item is the
NB. type of the node, and the rest are the data of that node
('AST_'&,each AST_TYPES) =: i.#AST_TYPES =: ;cut each cutLF noun define
  TURN
  PRIME TWICE
  GROUP
  CONDITIONS
)

NB. Replaces indices with names for readable output
ast_named =: {{
  i =. >{.y
  y =. {&AST_TYPES@>&.(0&{)y
  select. i
  case. AST_TURN do. y =. {&TURNS&.>&.(1&{)y
  fcase. AST_PRIME do.
  case. AST_TWICE do. y =. ast_named&.>&.(1&{)y
  case. AST_GROUP do. y =. ast_named each&.>&.(1&{)y
  case. AST_CONDITIONS do.
    y =. ast_named&.>&.(1&{)rows&.>&.(1&{)y
    str1 =. SIDES{~9%~-&4
    str2 =. 9&|((SIDES{~]),(ADJASCENT{~]){~1 3 5 7 i.[)[:<.%&9
    str3 =. 9&|((SIDES{~]),(ADJASCENT{~]){~(,/0 3,"0/1 2){~0 2 6 8 i.[)[:<.%&9
    str =. str1`str2`str3@.([:{.@I.(4;1 3 5 7;0 2 6 8)e.~every 9&|)
    y =. ({.;str each@}.)rows each&.>&.(0&{)rows&.>&.(1&{)y
  end.
  y
}}

Note'Parser state'
  (i;<b) where i - index of current character, b - 2-column mapping table where
  each row is (n;<m) where n is the name of the macro, and m is the expanded
  suffixed term that corresponds to that macro (For now always a group, but may
  change later)
)

NB. Any character
char =: {{
  'i s' =. y
  if. i=#x do. <y else. (i{x);<(i+1);<s end.
}}

NB. A specific character
Char =: char f.Filter(&=)

NB. A specific sequence of characters
Chars =: {{
  p =: ''
  for_c. m do. p =. p`(c Char) end.
  p List Map;
}}

NB. Whitespace (Single character, not a newline)
lws =: '-'Char`(' 'Char)`(TAB Char)`(CR Char)Any

NB. Whitespace (Multiple characters, without newlines)
lwss =: lws Many

NB. Whitespace (Single character)
ws =: lws Or(LF Char)

NB. Whitespace (Multiple characters)
wss =: ws Many

NB. A turn
basic =. (,(i.#TURNS){{y Char Map(x"_)`''}}"0 TURNS)Any
wide =. (,(TURNS&i.{{(>y)Chars Map(x"_)`''}}"0 toupper<@,"0'w'"_)'rludfb')Any
turn =: wide f.Or(basic f.)Map(AST_TURN;<)

NB. A macro name
end =. '>'Char Must ErrMap(''"_)
name =: '<'Char Right('>'Char Or(LF Char)Not And char Many Map;)Left(end f.)

NB. A macro call
macro =: name{{
  r =. x u y
  select. #r
  case. 1 do. r
  case. 2 do.
    'd s' =. r
    'i a' =. s
    e =. 1 i.~(d-:>@{.)rows a
    if. e=#a do. ('no macro named ''',d,''' found in scope');x;<y return. end.
    ({:e{a),<s
  case. 3 do. r
  end.
}}

NB. A scope (Sequence of suffixed terms and definitions)
start =. definition Left wss Many Right suffixed Left wss Many
wrapped =. wss Right(start f.)Left(definition Left wss Many)
mapped =. wrapped f.Map(,&<~&AST_GROUP)
scope =: mapped f.{{
  r =. x u y
  select. #r
  case. 1 do. r
  case. 2 do.
    'd s' =. r
    'i a' =. s
    d;<i;{:y
  case. 3 do. r
  end.
}}

NB. A group of suffixed terms and definitions
group =: '('Char Right scope Left(')'Char Must ErrMap('expected '')'''"_))

NB. A condition group
NB. The condition is in sum of products form, with each term being a = or <>
side1 =. (,{{y Char`''}}"0 SIDES)Any Map(SIDES&i.)
side2 =. side1 f.`(side1 f.)List Map;
side3 =. side1 f.`(side1 f.)`(side1 f.)List Map;
sides =. side3 f.`(side2 f.)`(side1 f.)Any Filter(,-:~.)
mapping1 =. 4+*&9
mapping2 =. (9*{.)+1 3 5 7 _{~(ADJASCENT{~{.)i.SIDES{~{:
mapping3 =. (9*{.)+9#.[:+/0 0 2 6 _{~(ADJASCENT{~{.)i.SIDES{~}.
unfiltered =. sides f.Map(mapping1 f.`(mapping2 f.)`(mapping3 f.)@.(<:@#))
sticker =. unfiltered f.Filter(~:&_)Must ErrMap('invalid sticker notation'"_)
equality_unmapped =. '='Char Map 1:Or('<>'Chars Map 0:)
equality =. equality_unmapped f.Must ErrMap('expected ''='' or ''<>'''"_)
comp_unmapped =. sticker f.Left wss`(equality f.)`(wss Right(sticker f.))List
comp =. comp_unmapped f.Map>Map(1 0 2&{)
anded =. comp f.Pair(wss Right(','Char)Right wss Right(comp f.)Many)Map(>@(,>)/)
ored =. anded f.Pair(wss Right('|'Char)Right wss Right(anded f.)Many)Map((,>)/)
body =. wss Right suffixed Many Map(,&<~&AST_GROUP)
condition_end =. wss Left(']'Char Must ErrMap('expected '']'''"_))
condition_some =. '['Char Right wss Right(']'Char Not And(ored f.))
condition =. condition_some f.Or('['Char Map(''"_))Left(condition_end f.)
arrow =. '=>'Chars Must ErrMap('expected ''=>'''"_)
conditional =. condition f.Left wss Left(arrow f.)Pair(body f.)
unmapped =. '{'Char Right(wss Right(conditional f.)Many)Left wss Left('}'Char)
conditions =: unmapped f.Map>Map(,&<~&AST_CONDITIONS)

NB. A term (Turn, macro, group, or conditions)
term =: turn`macro`group`conditions Any

NB. Suffixed terms (Prime and twice modifiers)
suffix =. wss Right(''''Char Map(AST_PRIME"_)Or('2'Char Map(AST_TWICE"_)))
suffixed =: term Pair(suffix f.Many)Map([:>[:,&<&.>/|.@>@{:,{.)

NB. A definition
body_start =. lwss Right suffixed Many Left lwss
body_end =. LF Char`(')'Char Also)`(char Not)Any
body =. body_start f.Left(body_end f.)Map(,&<~&AST_GROUP)
unmapped =. name Left lwss Left(':'Char)Pair(body f.)
definition =: unmapped f.{{
  r =. x u y
  select. #r
  case. 1 do. r
  case. 2 do.
    'd s' =. r
    'i a' =. s
    '';<i;<d,a
  case. 3 do. r
  end.
}}

NB. Parser for the whole program, guaranteed to either succeed or result in an
NB. irrecoverable error
root =: scope f.Left(char Not Must ErrMap('expected EOF'"_))

NB. Wrapper around the root parser. Returns the parsed tree on success, and an
NB. error string on error
parse =: {{
  r =. y root 0;<0 2$a:
  if. 2=#r do. >{.r return. end.
  'e s i' =. r NB. We know for sure that any error we get is irrecoverable
  i =. >{.i
  if. i=#s do.
    'unexpected EOF, ',e
  else.
    ls =. I.s=LF
    li =. ls I.i
    ci =. i-li{0,1+ls
    'unexpected character ''',(i{s),''' at ',(":1+li),':',(":1+ci),', ',e
  end.
}}
