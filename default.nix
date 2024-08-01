{lib, ruby, stdenv, bundlerEnv, ...}@pkgs :

let
  
  gems = bundlerEnv {
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
  src = ./src/wifi_state_machine.rb;
in stdenv.mkDerivation {
  name = "wificlient";
  src = ./src;
  buildInputs = [ ruby gems ];
  shellHook = ''
    bundle install
    bundix
    export GEM_HOME=$PWD/.gems
    export GEM_PATH=$PWD/.gems
    export BUNDLE_PATH=$PWD/.gems
    mkdir -p $out/{bin,share/wificlient}
    rsync -Rr * $out/share/wificlient
    bin=$out/bin/wificlient
#using bundle exec to start in the bundled env
    cat > $bin <<EOF
#!/bin/sh -e
exec ${gems}/bin/bundle exec ${ruby}/bin/ruby $out/share/wificlient/src/wifi_state_machine.rb "\$@"
EOF
    chmod +x $bin
  '';
}

