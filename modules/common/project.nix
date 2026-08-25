# Project-wide identity and build options: the system, the name, and the
# GHC flags every package gets.
{ lib, config }:

with lib;

{

  system = mkOption {
    type = types.str;
    default = builtins.currentSystem;
    defaultText = ''
      builtins.currentSystem
    '';
    description = ''
      The system the project is built on. Each driver instantiates its
      package set for this system, and cross target names are relative
      to it.
    '';
  };

  name = mkOption {
    type = types.nullOr types.str;
    default = if isPath config.src
      then baseNameOf config.src
      else getName config.src;
    defaultText = literalMD ''
      the base name of `src`
    '';
    description = ''
      Optional project name. It improves error messages, and the nixpkgs
      driver names the dev shell with it.
    '';
  };

  ghcOptions = mkOption {
    type = types.listOf types.str;
    default = [];
    description = ''
      GHC flags applied project-wide.
    '';
    example = [ "-O2" "-fexpose-all-unfoldings" ];
  };

}
