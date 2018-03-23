let
  pkgs = import "/home/mbuszka/workspace/nixpkgs" {};
in
  pkgs.stdenv.mkDerivation {
    name = "none";
    buildInputs = [
      pkgs.haskellPackages.purescript
      pkgs.psc-package
      pkgs.nodejs
      pkgs.python36Packages.grip
      pkgs.nodePackages.jshint
      pkgs.nodePackages.bower
      pkgs.python35
    ];
    shellHook = ''
      export PATH=./node_modules/.bin:$PATH
      export EDITOR=vim
      export VISUAL=code
    '';
  }
