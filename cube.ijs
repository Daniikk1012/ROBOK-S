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
'R'append 44 35 45 26;41 32 48 23;38 29 51 20
'L'append 53 27 36 18;50 30 39 21;47 33 42 24
'U'append 47 11 38  2;46 10 37  1;45  9 36  0
'D'append 42 15 51  6;43 16 52  7;44 17 53  8
'F'append 24 17 29  0;25 14 28  3;26 11 27  6
'B'append 33  9 20  8;34 12 19  5;35 15 18  2
'M'append 52 28 37 19;49 31 40 22;46 34 43 25
'E'append 39 12 48  3;40 13 49  4;41 14 50  5
'S'append 21 16 32  1;22 13 31  4;23 10 30  7
'r'append(,|.each)&>/(TURNS_parser_ i.'RM'){PERMUTATIONS
'l'append ,       &>/(TURNS_parser_ i.'LM'){PERMUTATIONS
'u'append(,|.each)&>/(TURNS_parser_ i.'UE'){PERMUTATIONS
'd'append ,       &>/(TURNS_parser_ i.'DE'){PERMUTATIONS
'f'append ,       &>/(TURNS_parser_ i.'FS'){PERMUTATIONS
'b'append(,|.each)&>/(TURNS_parser_ i.'BS'){PERMUTATIONS
'x'append(,|.each)&>/(TURNS_parser_ i.'rL'){PERMUTATIONS
'y'append(,|.each)&>/(TURNS_parser_ i.'uD'){PERMUTATIONS
'z'append(,|.each)&>/(TURNS_parser_ i.'fB'){PERMUTATIONS

NB. Rotates the state y according to AST x. Throws on error
rotate =: {{
  select. i =. >{.x
  case. AST_TURN_parser_ do. ((>{:x)>@{PERMUTATIONS)&C.&.,y
  case. AST_PRIME_parser_ do. y rotate inv~>{:x
  case. AST_TWICE_parser_ do. y rotate^:2~>{:x
  case. AST_GROUP_parser_ do.
    for_child. >{:x do. y =. y rotate~>child end.
    y
  case. AST_CONDITIONS_parser_ do.
    for_term. >{:x do.
      'cond body' =. term
      if. #cond do.
        if. -.+./([:*./(1&{~:&({&(,y)){:)`(1&{=&({&(,y)){:)@.{.rows)every cond
        do.
          continue.
        end.
      end.
      y =. body rotate y
      break.
    end.
    y
  end.
}} :.{{
  select. i =. >{.x
  case. AST_TURN_parser_ do. ((>{:x)>@{PERMUTATIONS)&C.inv&.,y
  case. AST_PRIME_parser_ do. y rotate~>{:x
  case. AST_TWICE_parser_ do. y rotate inv^:2~>{:x
  case. AST_GROUP_parser_ do.
    for_child. |.>{:x do. y =. y rotate inv~>child end.
    y
  case. AST_CONDITIONS_parser_ do. throw.
  end.
}}

NB. Prints the cube state y in a (almost) pretty format
display =: {{
  s =. ,((3$' '),{&SIDES_parser_,LF"_)rows 2{y
  s =. s,,({&SIDES_parser_,LF"_)rows,./1 4 0 5{y
  s =. s,,((3$' '),{&SIDES_parser_,LF"_)rows 3{y
  echo}:s
}}

NB. Returns a randomly generated scramble
scramble =: {{
  s =. 'RLUDFB'
  r =. ,?6
  for. i.17+?5 do.
    if. =/<.2%~_2{.!.(#s)r do.
      r =. r,+&2^:(((-2&|){:r)&<:)?-&2#s
    else.
      r =. r,>:^:(({:r)&<:)?<:#s
    end.
  end.
  }.;(r{s)' '&,@,each('';'''';'2'){~?3$~#r
}}
