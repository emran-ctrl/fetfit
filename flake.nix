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
            append_env_line() {
              # Appending to a file without a trailing newline would merge the
              # new key into the previous line (e.g. BACKEND_SECRET).
              if [ -s "$ENV_FILE" ] && [ -n "$(tail -c 1 "$ENV_FILE")" ]; then
                printf '\n' >> "$ENV_FILE"
              fi
              printf '%s\n' "$1" >> "$ENV_FILE"
            }
            if [ -z "$BACKEND_SECRET" ] && ! grep -q '^BACKEND_SECRET=' "$ENV_FILE" 2>/dev/null; then
              append_env_line "BACKEND_SECRET=$(hexdump -n 24 -e '8/4 "%08X"' /dev/urandom)"
              echo "Wrote new BACKEND_SECRET to backstage/.env"
            fi
            if ! grep -q '^AUTH_GITHUB_CLIENT_ID=' "$ENV_FILE" 2>/dev/null; then
              append_env_line 'AUTH_GITHUB_CLIENT_ID='
              echo "Added AUTH_GITHUB_CLIENT_ID placeholder to backstage/.env"
            fi
            if ! grep -q '^AUTH_GITHUB_CLIENT_SECRET=' "$ENV_FILE" 2>/dev/null; then
              append_env_line 'AUTH_GITHUB_CLIENT_SECRET='
              echo "Added AUTH_GITHUB_CLIENT_SECRET placeholder to backstage/.env"
            fi
            if grep -qE '^AUTH_GITHUB_CLIENT_(ID|SECRET)=$' "$ENV_FILE" 2>/dev/null; then
              echo "  -> fill AUTH_GITHUB_CLIENT_ID/SECRET in from your GitHub OAuth App before signing in"
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
