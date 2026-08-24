# A literalMD of one fenced code block, for a defaultText or an example
# that is nothing but code. The body may or may not end with a newline;
# the fence comes out the same either way.
#
# Example:
#
#   fenced-code = import ./fenced-code.nix { inherit lib; };
#
#   fenced-code ''config."haskell-nix".input.nixpkgsArgs''
#   => lib.literalMD "```\nconfig.\"haskell-nix\".input.nixpkgsArgs\n```\n"
{ lib }:

text:

lib.literalMD "```\n${lib.removeSuffix "\n" text}\n```\n"
