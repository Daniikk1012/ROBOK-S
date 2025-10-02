Note'License'
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.
)

NB. A parser combinator library written in J

cocurrent'jarser'

Note'Parsers'
  Parsers are dyadic, where x is the input string, and y is the initial state
  of the parser (Usually amount of string items parsed so far) to process. They
  return either (d;<s) on success, where d is the resulting data and s is the
  new state, or (<e) on error, where e is a user-defined error type (The generic
  parser combinators use y if they cannot use errors returned by their input
  parsers). For irrecoverable errors (Useful for precise error reporting),
  parsers use (e;x;<y)
)

NB. Start of generic parser combinator library

NB. Maps output of a parser u using monadic function v
Map =: (].&.>)&.(0&{)^:(2=#)@:[.

NB. Maps the error value of a parser u using monadic function v
ErrMap =: (].&.>)&.(0&{)^:(2~:#)@:[.

NB. Makes the parser's error irrecoverable
Must =: {{
  r =. x u y
  select. #r
  case. 1 do. r,x;<y
  case. 2 do. r
  case. 3 do. r
  end.
}}

NB. Only succeeds to parse using u if (v d) is true for its output data d
Filter =: {{
  r =. x u y
  if. 2=#r do.
    if. v>{.r do. r else. <y end.
  else.
    r
  end.
}}

NB. Applies parsers in gerund m in order, then collects their results into a
NB. single boxed list
List =: {{
  d =. ''
  for_p. m do.
    r =. x p`:0 y
    if. 2~:#r do. r return. end.
    y =. >{:r
    d =. d,{.r
  end.
  d;<y
}}

NB. Applies first parser u, then parser v, then combines the results into a
NB. boxed pair
Pair =: `List

NB. Applies first parser u, then parser v, but only keeps the result of u
Left =: Pair Map(>@{.)

NB. Applies first parser u, then parser v, but only keeps the result of v
Right =: Pair Map(>@{:)

NB. Applies parser u without modifying the state
Also =: {{
  r =. x u y
  if. 2~:#r do. r else. ({.r),<y end.
}}

NB. Applies parser u without modifying the state, then applies v
And =: Also Pair]:Map(>@{:)

NB. Succeeds if parser u fails, and vice versa. On success the return data is
NB. the empty list, while keeping the state the same
Not =: {{
  r =. x u y
  select. #r
  case. 1 do. '';<y
  case. 2 do. <y
  case. 3 do. r
  end.
}}

NB. Returns the result of the first successful parser from the gerund m
Any =: {{
  r =. <y
  for_p. m do.
    r =. x p`:0 y
    if. 1<#r do. break. end.
  end.
  r
}}

NB. Returns the result of the first successful parser out of the two
Or =: `Any

NB. Applies parser u as many times as it can, combining all results into a
NB. single list
Many =: {{
  d =. ''
  while. 1 do.
    r =. x u y
    if. 1=#r do. d;<y return. end.
    if. 3=#r do. r return. end.
    y =. >{:r
    d =. d,{.r
  end.
}}

NB. Applies parser u as many times as it can, combining all results into a
NB. single list. u must succeed at least once
More =: {{u Pair(u Many)Map((,>)/)}}
