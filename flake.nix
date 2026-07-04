{
  description = "Develop Python on Nix with uv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          commonPackages = with pkgs; [
            python313
            uv
          ];

          linuxRuntimeLibraries = with pkgs; [
            libxkbcommon
            libxcb
            libxcb-util
            libxcb-cursor
            libxcb-image
            libxcb-keysyms
            libxcb-render-util
            libxcb-wm
            libx11
            libsm
            libice
            fontconfig
            freetype
            dbus
            glib
            wayland
            mesa
            libglvnd
            zlib
            zstd
            stdenv.cc.cc.lib
          ];

          darwinRuntimeLibraries = with pkgs; [
            zlib
            zstd
          ];

          runtimeLibraries =
            lib.optionals pkgs.stdenv.isLinux linuxRuntimeLibraries
            ++ lib.optionals pkgs.stdenv.isDarwin darwinRuntimeLibraries;
        in {
          default = pkgs.mkShell {
            packages = commonPackages ++ runtimeLibraries;

            env = (lib.optionalAttrs pkgs.stdenv.isLinux {
              LD_LIBRARY_PATH = lib.makeLibraryPath runtimeLibraries;
            }) // {
              UV_PYTHON = "${pkgs.python313}/bin/python3.13";
              UV_PYTHON_DOWNLOADS = "never";
            };

            shellHook = ''
              unset PYTHONPATH

              if [ -d .venv ]; then
                if ! .venv/bin/python -c 'import sys' >/dev/null 2>&1; then
                  rm -rf .venv
                elif [ "$("$UV_PYTHON" -c 'import os; print(os.path.realpath(".venv/bin/python"))')" != "$("$UV_PYTHON" -c 'import os; print(os.path.realpath(os.environ["UV_PYTHON"]))')" ]; then
                  rm -rf .venv
                fi
              fi

              [ -d .venv ] || uv venv --python "$UV_PYTHON"
              uv sync
              . .venv/bin/activate
            '';
          };
        });
    };
}
