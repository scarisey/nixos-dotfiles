{...}: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        root_url = "https://grafana-hyperion.carisey.dev";
        http_addr = "127.0.0.1";
        http_port = 3000;
        enable_gzip = true;
      };
      security = {
        admin_user = "admin";
        admin_password = "$__file{/run/secrets/hyperion/grafana/init_passwd}"; #only for first setup
        secret_key = "$__file{/run/secrets/hyperion/grafana/init_secret}"; #only for first setup
        cookie_secure = true;
        cookie_samesite = "strict";
        allow_embedding = false;
        # strict_transport_security = true;
        # content_security_policy = true;
      };
      smtp.enabled = false;
      users = {
        allow_sign_up = false;
      };
    };
  };
}
