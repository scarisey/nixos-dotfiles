# Development Shell for Non-Nix Software

This template provides a Nix development shell configured to run software that isn't compiled specifically for Nix.

## Features

- Pre-configured with common system libraries needed to run non-Nix binaries
- Automatically sets up `LD_LIBRARY_PATH` for runtime dependencies
- Creates a local `bin` directory for your non-Nix executables
- Uses NixGL for OpenGL support

## Usage

### Initialize a new project

```bash
nix flake init -t github:scarisey/nixos-dotfiles#devshell
```

### Enter the development shell

```bash
nix develop
```

### Running non-Nix software

1. Place your non-Nix binaries in the `./bin` directory
2. They will be automatically added to your PATH when in the development shell
3. The shell provides common runtime libraries via `LD_LIBRARY_PATH`

### Customization

Edit the `flake.nix` file to:

- Add more system libraries to `nonNixDependencies`
- Add development tools to the `packages` list
- Modify environment variables in the `shellHook`
- Configure additional overlays as needed

## Troubleshooting

If your non-Nix software is still missing dependencies:

1. Try running it with `strace` to identify missing libraries
2. Add the required libraries to the `nonNixDependencies` list
3. Rebuild the shell with `nix develop`
