{lib,...}:
rec {
  lsDirs=path: lib.mapAttrsToList (k: v: k) (lib.filterAttrs (k: v: v == "directory") (builtins.readDir path));
  users=path: 
    builtins.listToAttrs (
        lib.flatten (
          map (user:
            map (host: {name=user + "@" + host;value=path + "/${user}/${host}/home.nix";}) (lsDirs ( path + "/${user}"))
            ) (lsDirs path)
          )
        );
  forUsers=path: f: lib.mapAttrs f (users path);
  forHosts=path: f: lib.genAttrs (lsDirs path) (x: f (path + "/${x}/configuration.nix"));
}
