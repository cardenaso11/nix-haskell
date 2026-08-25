# What a driver built for one executable of one cross target, and what
# that target's optimizer makes of it. Only a driver knows what it
# built, so these answer only when the tree is read through one, as
# `config.<driver>.platforms.<platform>.packages.<package>....`. At the
# top level there is no driver to ask, so they are `null`. A project
# that has something else to ship can define either of them instead.
{ lib, config, topConfig }:

with lib;

let crossPlatform = import ../../libs/cross/platform.nix { inherit lib; };

in { platform, package, exe }:

   let named = { inherit platform package exe; };

       carrier = config.cross-exe named;

       artifact = extension: "${carrier}/bin/${exe}${extension}";

       target = crossPlatform.targetFor platform;

       throughDriver = config ? cross-exe;

   in {

     optimized = mkOption {
       type = types.nullOr types.package;
       default =
         let rowFor = findFirst (row: row.matches target) null (attrValues topConfig.cross-targets);
         in if ! throughDriver || rowFor == null
            then null
            else topConfig.${rowFor.optimize}
              (named // { ${rowFor.artifact} = artifact rowFor.extension; });
       defaultText = literalMD ''
         the executable this driver built for this target, through
         `wasm-optimize` or `js-optimize`
       '';
       description = ''
         The executable a driver built for this target, sent through
         that target's optimizer. This is what a project ships. It is
         `null`:

         - for a target that has no optimizer
         - when read anywhere but through a driver
       '';
     };

     jsffi = mkOption {
       type = types.nullOr types.package;
       default =
         if throughDriver && target.isWasm
         then topConfig.wasm-jsffi {
           ghc = config.cross-compiler platform;
           wasm = artifact ".wasm";
         }
         else null;
       defaultText = literalMD ''
         `wasm-jsffi` on the executable this driver built, with the compiler it
         was built with
       '';
       description = ''
         The `ghc_wasm_jsffi.js` without which this target's binary
         cannot be instantiated. `wasm-jsffi` reads it out of the binary
         as linked, not out of `optimized`, because the optimizer strips
         the sections the read needs. `null` for every target that is
         not wasm.
       '';
     };

   }
