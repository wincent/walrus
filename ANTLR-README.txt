The pure-Ruby version of Walrus is thoroughly tested and works very well, but
it has one major flaw: it is very slow. This "antlr" branch will be used to
develop a much faster version of Walrus that uses a Ruby extension written in
C to perform all lexing, parsing and AST construction. ANTLR will be used to
generate the recognizers (lexer, parser, and possibly a tree grammar or
grammars for transforming the AST).

In addition to the expected speed improvements, it is hoped that the use of
ANTLR will allow for much better error reporting in the event of syntax errors
in the input, and should also allow for the correction of a number of small
quirks/bugs in the Ruby-only implementation (the Ruby implementation, for
instance, has a lot of trouble detecting and accurately reporting node
boundaries, due to fundamental issues with the design of the parser
generator which cannot be easily worked around).

It is expected that this branch will diverge fairly significantly from the
master branch, and many of the specs will have to be rewritten in order to
match the changes that flow on from the new architecture.
