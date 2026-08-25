# The bundled cross targets, one row each. ./target-module.nix
# accepts a row's `name`, or a full row of this same shape from a project.
# `bundleFields` dispatches over the registered rows in target name order,
# and at most one row may match a target. A row carries:
# 1. `name`: the target's registry key, what ./target-module.nix is
#    called with.
# 2. `flag`: the option name, which is also the `hostPlatform` and
#    elaborated-target attribute of the same question. A row whose flag is
#    not a platform attribute supplies `matches` (elaborated platform ->
#    bool) instead. The default reads the flag attribute, false when the
#    platform lacks it.
# 3. `selected`: whether a `shell.crossPlatforms` selection names the
#    target, over the selected platform names. `selectedText` documents it.
# 4. `optimizer`/`optimize`: the settings option and the function-option
#    that applies them. `runPath` names the run library for the manual. A
#    row for a tool ../bundle-optimizer/options.nix does not know supplies
#    `optimizer-fields` (field name -> { type, default, description }) and
#    its own `optimize-defaultText`.
# 5. `artifact`/`extension`: the argument the optimize function takes and
#    the suffix of the built file; `examplePlatform` and `lead` feed the
#    option's description.
# 6. `mkOptimize`: builds the optimize function from pkgs, lib and the
#    settings resolver.
# 7. `node ? true`: whether the target needs Node.js in the shell.
#
# Example:
#
#   (builtins.head (import ./targets.nix { inherit lib; })).flag
#   => "isWasm"
{ lib }:

with lib;

[

  { name = "wasm";
    flag = "isWasm";
    target = "wasm";
    selected = names: builtins.any (name: hasInfix "wasm" name || hasPrefix "wasi" name) names;
    selectedText = ''
      `true` when the host platform is wasm, or when
      `shell.crossPlatforms` selects a platform whose name contains
      `wasm` or starts with `wasi`.
    '';
    optimizer = "wasm-opt";
    optimize = "wasm-optimize";
    runPath = "bundle-optimizer/wasm-opt/run.nix";
    artifact = "wasm";
    extension = ".wasm";
    examplePlatform = "wasi32";
    lead = ''
      A wasm binary optimized and stripped. It takes the file, not the
      package that carries it. It yields the file, not a directory
      holding it, so the caller installs it under any name:'';
    mkOptimize = { pkgs, lib, settings }:
      { platform ? null, package ? null, exe ? null, wasm }:
        import ../bundle-optimizer/wasm-opt/run.nix { inherit pkgs lib; }
          ({ inherit wasm; } // settings { inherit platform package exe; });
  }

  { name = "ghcjs";
    flag = "isGhcjs";
    target = "GHCJS";
    selected = names: builtins.elem "ghcjs" names;
    selectedText = ''
      `true` when the host platform is GHCJS, or when
      `shell.crossPlatforms` selects `ghcjs`.
    '';
    optimizer = "closure-compiler";
    optimize = "js-optimize";
    runPath = "bundle-optimizer/closure-compiler/run.nix";
    artifact = "jsexe";
    extension = ".jsexe";
    examplePlatform = "ghcjs";
    lead = ''
      A linked `.jsexe` directory with its `all.js` closure-compiled. The
      rest of the directory is copied unchanged. It takes the directory,
      not the package that carries it:'';
    mkOptimize = { pkgs, lib, settings }:
      { platform ? null, package ? null, exe ? null, jsexe }:
        import ../bundle-optimizer/closure-compiler/run.nix { inherit pkgs lib; }
          ({ inherit jsexe; } // settings { inherit platform package exe; });
  }

]
