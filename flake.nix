{
  description = "Wificlient";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = 
  {nixpkgs, ... }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    runPackages = [ 
      pkgs.ruby_3_2 
      pkgs.ruby.devEnv 
      pkgs.bundix
    ]; 
   # gems = pkgs.lib.bundlerEnv {
   #   name  = "default-env";
    #  inherit pkgs;
   #   gemfile = ./Gemfile; 
   # };
   gems = pkgs.bundlerEnv {
    name = "gems";
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemdir = ./.gems;
    gemset = (import ./gemset.nix ) // {
      bundler = {
       source = {
         remotes = ["https://rubygems.org"];
         sha256 = "334dc796438384732fdf19bfa2f623753b7ed85160d08ce1f20009984cefb362";
         type = "gem";
       };
       version = "2.4.19";
     };
    };
    inherit lib ruby;
    
  };

   lib = pkgs.lib;
   stdenv = pkgs.stdenv;
   ruby = pkgs.ruby;

  in 
  {
    devShells."x86_64-linux".default = pkgs.mkShell {
      buildInputs = [
        runPackages
        gems
        
      ];
      shellHook = ''
        touch ./.gems/gemset.nix
        export GEM_HOME=$PWD/.gems
        export GEM_PATH=$PWD/.gems
        ''; 
      };
    
      defaultPackage.x86_64-linux = pkgs.callPackage ./default.nix {
        inherit lib stdenv ruby pkgs;

      };
    

    };
    }
  
   




  

