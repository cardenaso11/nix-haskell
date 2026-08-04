# DO NOT HAND-EDIT THIS FILE
{
  inputs = {
    "upstream" = {
      owner = "georgefst";
      repo = "nixpkgs";
      rev = "1a3237b27813e77f360f9877bfae3f7640eeb6db";
      type = "github";
    };
  };
  outputs = inputs: inputs."upstream".outputs;
}
