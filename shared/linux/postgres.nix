{ config, lib, pkgs, modulesPath, ... }:

{
  options = {
    postgres.enable = lib.mkEnableOption "Setup a PostgreSQL database server";
  };

  config = lib.mkIf config.postgres.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = [ "diamondkeep" ];
      enableTCPIP = true;
      settings.port = 5432;

      # user creation:
      # CREATE USER foo WITH PASSWORD 'bar';
      # GRANT ALL PRIVILEGES ON DATABASE fooapp TO foo;

      authentication = pkgs.lib.mkOverride 10 ''
        # type    database        DBuser          origin-address          auth-method

        # "local" is for Unix domain socket connections only
        local     all             all                                     trust

        host      all             all             127.0.0.1/32            trust
        host      all             all             ::1/128                 trust
        host      sameuser        diamondkeep     0.0.0.0/0               scram-sha-256
        host      sameuser        diamondkeep     ::/0                    scram-sha-256

        # Allow replication connections from localhost, by a user with the
        # replication privilege.
        local   replication     all                                     trust
        host    replication     all             127.0.0.1/32            trust
        host    replication     all             ::1/128                 trust
      '';
    };
  };

}
