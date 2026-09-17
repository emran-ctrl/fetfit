# fetfit IDP — hermetic dev toolchain
# Node/Yarn/Python pinned to versions supported by Backstage.
{
  description = "fetfit IDP development environment";

  # Channel tarball instead of github: ref — avoids GitHub API rate limits
  inputs.nixpkgs.url = "https://nixos.org/channels/nixos-25.05/nixexprs.tar.xz";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22   # Backstage-supported LTS (26 is too new)
            yarn        # Yarn Classic 1.22 — what create-app expects
            python312   # for native module builds (node-gyp); 3.14 is too new
            git
            (python312.withPackages (ps: [
              ps.mkdocs            # TechDocs local generator
              ps.mkdocs-material   # MkDocs theme (material; techdocs-core not in nixpkgs)
              ps.markdown-include  # include .md fragments from other dirs
            ]))
          ];

          shellHook = ''
            ENV_FILE="$PWD/backstage/.env"
            if [ ! -f "$ENV_FILE" ]; then
              touch "$ENV_FILE"
              chmod 600 "$ENV_FILE"
            fi
            if [ -z "$BACKEND_SECRET" ] && ! grep -q '^BACKEND_SECRET=' "$ENV_FILE" 2>/dev/null; then
              printf 'BACKEND_SECRET=%s\n' "$(hexdump -n 24 -e '8/4 "%08X"' /dev/urandom)" >> "$ENV_FILE"
              echo "Wrote new BACKEND_SECRET to backstage/.env"
            fi
            set -a
            . "$ENV_FILE"
            set +a

            echo ""
            echo "🔧 fetfit IDP dev shell"
            echo "   node $(node --version) | yarn $(yarn --version) | python $(python3 --version | cut -d' ' -f2)"
            echo ""
          '';
        };
      });
    };
}
