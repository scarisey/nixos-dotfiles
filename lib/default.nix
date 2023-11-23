{lib,...}:
rec {
  #lsDirs :: path -> [ dir1 dir 2 ... ]
  lsDirs=path: lib.mapAttrsToList (k: v: k) (lib.filterAttrs (k: v: v == "directory") (builtins.readDir path));
  #users :: path -> { "user1@host1"=path1; "user2"@host1=path2; ...}
  #structure of path must be: path/user/host
  users=path: 
    builtins.listToAttrs (
        lib.flatten (
          map (user:
            map (host: {name=user + "@" + host;value=path + "/${user}/${host}/home.nix";}) (lsDirs ( path + "/${user}"))
            ) (lsDirs path)
          )
        );
  #forUsers :: path -> (user -> userPath -> result) -> { "user1@host1"= result; }
  forUsers=path: f: lib.mapAttrs f (users path);
  #forHosts :: path -> (hostPath -> result) -> { "host1"= result; }
  forHosts=path: f: lib.genAttrs (lsDirs path) (x: f (path + "/${x}/configuration.nix"));
}
