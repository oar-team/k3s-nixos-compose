{ pkgs, ... }: {
  roles =
    let
      tokenFile = pkgs.writeText "token" "p@s$w0rd";
    in
    {
    server = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ gzip jq kubectl ];
        # k3s uses enough resources the default vm fails.
        
        services.k3s = {
          inherit tokenFile;
          enable = true;
          role = "server";
          package = pkgs.k3s;
        };
    };

    agent = { pkgs, ... }: {
      services.k3s = {
        inherit tokenFile;
        enable = true;
        role = "agent";
        serverAddr = "https://server:6443";
      };
    };
  };
  testScript = ''
    foo.succeed("true")
  '';
}
