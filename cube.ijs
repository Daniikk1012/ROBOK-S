NB. Utilities for manipulating the Rubik's cube

require'parser.ijs'
cocurrent'cube'

NB. This file defines functions for rotating a 3x3 cube according to AST

NB. Cube state, same structure as in parser.ijs
DEFAULT_STATE =: 3 3&$"0 i.6

NB. The indices in raveled state that are to be permuted (Written in
NB. counterclockwise order so that C. will rotate them clockwise)
PERMUTATIONS =: (#TURNS_parser_)$a:
append =. {{PERMUTATIONS =: ,&y&.>&.((TURNS_parser_ i.x)&{)PERMUTATIONS}}
SIDES_parser_ append items(0 6 8 2;1 3 7 5)&(+each)every 9*i.6
'R'append 11 20 38 51;14 23 41 48;17 26 44 45
'U'append 27 18  0 45;28 19  1 46;29 20  2 47
'F'append 15 35 38  0;16 32 37  3;17 29 36  6
'L'append  9 53 36 18;12 50 39 21;15 47 42 24
'D'append 24 33 51  6;25 34 52  7;26 35 53  8
'B'append  9  2 44 33;10  5 43 30;11  8 42 27
'M'append 10 52 37 19;13 49 40 22;16 46 43 25
'E'append 21 30 48  3;22 31 49  4;23 32 50  5
'S'append 12 34 41  1;13 31 40  4;14 28 39  7
'r'append(,|.each)&>/(TURNS_parser_ i.'RM'){PERMUTATIONS
'u'append(,|.each)&>/(TURNS_parser_ i.'UE'){PERMUTATIONS
'f'append ,       &>/(TURNS_parser_ i.'FS'){PERMUTATIONS
'l'append ,       &>/(TURNS_parser_ i.'LM'){PERMUTATIONS
'd'append ,       &>/(TURNS_parser_ i.'DE'){PERMUTATIONS
'b'append(,|.each)&>/(TURNS_parser_ i.'BS'){PERMUTATIONS
'x'append(,|.each)&>/(TURNS_parser_ i.'rL'){PERMUTATIONS
'y'append(,|.each)&>/(TURNS_parser_ i.'uD'){PERMUTATIONS
'z'append(,|.each)&>/(TURNS_parser_ i.'fB'){PERMUTATIONS

NB. Rotates the state y according to AST x
NB. Returns the list of all intermediate states, excluding starting state
NB. Throws on error
rotate =: {{
  select. i =. >{.x
  case. AST_TURN_parser_ do. ,:((>{:x)>@{PERMUTATIONS)&C.&.,y
  case. AST_PRIME_parser_ do. y rotate inv~>{:x
  case. AST_TWICE_parser_ do. }.(>{:x)(],[rotate{:@])^:2,:y
  case. AST_GROUP_parser_ do.
    r =. ,:y
    for_child. >{:x do. r =. r,(>child)rotate{:r end.
    }.r
  case. AST_CONDITIONS_parser_ do.
    r =. 0$~0,$y
    for_term. >{:x do.
      'cond body' =. term
      if. #cond do.
        neq =. 1&{~:&({&(,y)){:
        eq =. 1&{=&({&(,y)){:
        nop =. 1&{(3~:|@-)&({&(,y)){:
        op =. 1&{(3=|@-)&({&(,y)){:
        if. -.+./([:*./neq`eq`nop`op@.{.rows)every cond
        do.
          continue.
        end.
      end.
      r =. body rotate y
      break.
    end.
    r
  end.
}} :.{{
  select. i =. >{.x
  case. AST_TURN_parser_ do. ,:((>{:x)>@{PERMUTATIONS)&C.inv&.,y
  case. AST_PRIME_parser_ do. y rotate~>{:x
  case. AST_TWICE_parser_ do. }.(>{:x)(],[rotate inv{:@])^:2,:y
  case. AST_GROUP_parser_ do.
    r =. ,:y
    for_child. |.>{:x do. r =. r,(>child)rotate inv{:r end.
    }.r
  case. AST_CONDITIONS_parser_ do. throw.
  end.
}}

NB. Prints the cube state y in a (almost) pretty format
display =: {{
  s =. ,((3$' '),{&SIDES_parser_,LF"_)rows(SIDES_parser_ i.'U'){y
  s =. s,,({&SIDES_parser_,LF"_)rows,./(SIDES_parser_ i.'LFRB'){y
  s =. s,,((3$' '),{&SIDES_parser_,LF"_)rows(SIDES_parser_ i.'D'){y
  echo}:s
}}

NB. Returns a randomly generated scramble
scramble =: {{
  r =. ,?6
  for. i.17+?5 do.
    if. 3=|-/_2{.!.(#SIDES_parser_)r do.
      r =. r,(+(1 2-~sort(,6|+&3){:r)&I.)?2-~#SIDES_parser_
    else.
      r =. r,>:^:(({:r)&<:)?<:#SIDES_parser_
    end.
  end.
  }.;(r{SIDES_parser_)' '&,@,each('';'''';'2'){~?3$~#r
}}
