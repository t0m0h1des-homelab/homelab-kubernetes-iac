{
  description = "C1 K8s IaC Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          ansible
          sshpass
          ansible-lint
          kubectl
          terraform
        ];

        shellHook = ''
          echo "🚀 Ansible & Terraform Environment Loaded!"
          ansible --version
          terraform -v
        '';
      };
    };
}
