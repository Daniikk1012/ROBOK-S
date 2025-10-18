# ROBOK'S: An interpreter for extended Rubik's cube notation

## Usage

The easiest way to install and run the GUI is by running J Qt IDE and typing:
```j
require'pacman'
'install'jpkg'github:Daniikk1012/ROBOK-S'`
load'daniikk1012/roboks/gui'
```
If you want to use it as a library, omit the `/gui`, this will load `parser.ijs`
and `cube.ijs`. For this use case you don't need to be running J Qt IDE
specifically, both JHS and J console will work.

If you want to run it as a standalone application, not as an addon, clone this
repository anywhere you'd like and then run `main.ijs` using either `jconsole`
(For CLI) or `jqt` (For GUI).

## What's the notation?

It supports the basic Rubik's cube notation, including:
- `R`, `L`, `U`, `D`, `F`, `B` for turns;
- `'` (prime) for inverting the move;
- `2` for doubling the move;
- `Rw`, `Lw`, `Uw`, `Dw`, `Fw`, `Bw` for the wide turns;
- `r`, `l`, `u`, `d`, `f`, `b` for the wide turns as well;
- `x`, `y`, `z` for whole cube rotations;
- `M`, `E`, `S` for middle layer turns;
- `( ... )` for grouping.

`-` and whitespace are ignored.

It also supports some extensions (which is the whole point of this project),
specifically:
- `'` does not only negate turns, but anything except conditionals;
- `2` does not only double turns, but anything;
- `{ [ condition ] => moves ... }` - conditionals (more below);
- `<macro>: body` - macro definitions, terminated by a newline;
- `<macro>` - macro calls;
- `>> comment` - comments.

### Macros

Macros are lexically scoped, and expanded as soon as they are seen during
compilation, so if you use a macro in another macro it must be available at the
time of definition

### Conditionals

Each term in the conditional is of form `[ ... ] => ...`, where the square
brackets contain a condition, and the right hand side of `=>` contains the moves
to do (body of the term) if that condition is true. When executing a
conditional, terms' conditions are checked from first to last, and when one is
found, its body is executed and the conditional stops, no further terms are
checked. If no condition was true, nothing is done, the conditional just has no
effect.

A condition is either empty, in which case it is always considered to be true,
or it is a `|`-separated list of subconditions, at least one of which has to be
true for the whole condition to be true. Each subcondition is a `,`-separated
list of comparisons, and each comparison must be true for the subcondition to be
true. Each comparison is two sticker identifiers, separated by `=`, `<>`, `><`,
or `>/<`, checking for equality or inequality, being opposite colors, and not
being opposite colors, respectively. A sticker is denoted as follows:
- If it's a center, just use the face of that center, e.g., `R` for the center
  sticker of the right face;
- If it's an edge, use first the face that sticker is on, and then the side it's
  adjascent to, e.g., `RU` for the sticker on the right face that is also
  adjascent to the top face;
- If it's a corner, use first the face of that the sticker is on, and then the
  two faces it's adjascent to, e.g., `RUF` for the sticker on the right face
  that is also adjascent to top and front faces (`RFU` would have also worked).

An example of a conditional (It does not do anything meaningful, just syntax
demonstration):
```
{
    [RU = LU, FU <> BU | RD >< LD, FD >/< BD] => U2
    [] => D2
}
```

## Examples

`beginner.roboks` contains an example that solves the cube from any state using
a beginner's method

## Why?

Just some idea I had: what if the Rubik's cube notation was powerful enough to
be able to write a formula in it, that solves the cube from any state? So I
decided to add conditionals and potentially some other things you typically see
in programming languages.

Because I wanted this language to feel like something you could naturally
stumble upon when someone is describing to you how to solve the Rubik's cube
using the regular notation, but without using any words from natural languages,
I tried to think of ways to make it feel "natural".  Macros were easy, use
`name: definition` for definition, and then reference the name. This has a
problem of clashing with turn notation, so I went with `<name>` instead of just
`name`, which is pretty common in templates.

Conditionals are a bit harder, and I am still not sure how to do them properly,
so I settled with whatever I have here.

## Dependencies

None except for J 9.6. Might work with earlier versions, but I haven't checked.

## Name

Thought of it while writing this README, a play on "robot" + "Rubik's"

## License

This project is licensed under GNU GPL v3. `jarser.ijs` specifically is also
available under MPL v2.0
