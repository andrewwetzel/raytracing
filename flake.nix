{
  description = "My monorepo development environment";

  # This defines the "inputs" to your environment, like the package collection.
  inputs = {
    # We pin 'nixpkgs' to a specific version for reproducibility.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # This defines the "outputs", which is your actual dev shell.
  outputs = { self, nixpkgs, ... }:
    let
      # Define the system we're building for (e.g., x86_64 Linux)
      system = "x86_64-linux";
      
      # Get the packages for that system
      pkgs = nixpkgs.legacyPackages.${system};

    in
    {
      # This is the dev shell you will enter.
      devShells.${system}.default = pkgs.mkShell {
        
        # List all the packages you want in your environment
        packages = [
          pkgs.gfortran
          
          # It's good practice to include gfortran.cc to get the 
          # libgfortran shared library, which is often needed for linking.
          pkgs.gfortran.cc 
          
          # The just command runner
          pkgs.just
        ];

        # You can also run commands every time the shell loads
        shellHook = ''
          echo "Nix development shell activated."
          echo "gfortran is ready to use."

          # Enable justfile auto-completion
          # This detects your current shell (bash, zsh, etc.)
          # and sources the correct completion script.
          eval "$(just --completions $(basename $SHELL))"
          echo "Justfile auto-completion enabled."
        '';
      };
    };
}