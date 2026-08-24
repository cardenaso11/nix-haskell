# One cross-target module, built from the target's row in
# ./cross-targets.nix:
# - The `is<Target>` flag: whether the project targets it, natively or
#   through `shell.crossPlatforms`.
# - The optimizer settings option, from ./bundle-optimizer-options.nix.
# - The optimize function-option, running the row's run library with the
#   settings the named target, package and executable resolve to.
# - Node.js in the shell while the flag is on.
#
# Example:
#
#   imports = [ (import ./cross-target-module.nix "wasm") ];
name:

{ config, lib, pkgs, ... }:

with lib;
with (import ./prelude { inherit lib; });

let rows = import ./cross-targets.nix { inherit lib; };

    unknownTarget = throw ((import ./message-prefix.nix {}) "no cross target named \"${name}\"");

    row = findFirst (row: row.name == name) unknownTarget rows;

    bundleOptimizer = import ./bundle-optimizer-options.nix { inherit lib; };

    bundleSettings = import ./bundle-optimizer-settings.nix { inherit lib; };

    crossPlatform = import ./cross-platform.nix { inherit lib; };

in {

  options = {

    ${row.flag} = mkOption {
      type = types.bool;
      default =
        let selected = config.shell.crossPlatforms (crossPlatform.probe pkgs);
        in pkgs.stdenv.hostPlatform.${row.flag}
           || row.selected selected;
      defaultText = literalMD row.selectedText;
      description = ''
        Whether the project targets ${row.target}, natively or through
        cross-compilation. When true, Node.js is added to
        `shell.buildInputs`.
      '';
    };

    ${row.optimizer} = bundleOptimizer.${row.optimizer};

    ${row.optimize} = function-option {
      default = row.mkOptimize {
        inherit pkgs lib;
        settings = keys: bundleSettings ({
          tool = row.optimizer;
          defaults = config.${row.optimizer};
          inherit (config) packages platforms;
        } // keys);
      };
      defaultText = fenced-code "<nix-haskell>/libs/${row.runPath}, run with the settings the named target, package and executable resolve to";
      description = ''
        ${row.lead}

        ```
        ${row.optimize} {
          platform = "${row.examplePlatform}";
          package = "frontend";
          exe = "frontend";
          ${row.artifact} = "''${frontend}/bin/frontend${row.extension}";
        }
        ```

        `platform`, `package` and `exe` are only lookup keys for the
        settings. Each can be left out, and an omitted key states nothing.

        The `${row.optimizer}` settings are resolved per field. The most
        specific layer that states a field decides it, in this order:

        1. `platforms.<platform>.packages.<package>.components.exes.<exe>.${row.optimizer}`
        2. `platforms.<platform>.packages.<package>.${row.optimizer}`
        3. `platforms.<platform>.${row.optimizer}`
        4. `packages.<package>.components.exes.<exe>.${row.optimizer}`,
           then `packages.<package>.${row.optimizer}`
        5. `${row.optimizer}` at the top level, the only layer that holds
           every field.

        The settings come from the project's own values, not a driver's.
        This function runs on a built artifact, outside any driver.
      '';
    };

  };

  config = {

    shell = {

      # Template Haskell needs Node.js. The slim build is enough: only the
      # runtime is run, never npm.
      buildInputs = mkIf config.${row.flag} [ pkgs.nodejs-slim ];

    };

  };

}
