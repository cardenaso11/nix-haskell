{ ... }:

{

  # Ignored when the project does not contain splitmix.
  config.packages.splitmix.patches = [
    ./splitmix-js.patch
  ];

}
