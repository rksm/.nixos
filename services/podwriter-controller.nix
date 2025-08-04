# Podwriter Controller Service Configuration
{ config, pkgs, lib, ... }:

{
  # Enable the podwriter-controller service
  services.podwriter-controller = {
    enable = false;

    # Package from the podwriter flake
    package = pkgs.podwriter;

    # Data directory
    dataDir = "/home/robert/projects/biz/podwriter-deploy-test-data/transcription-jobs";

    # Environment
    environment = "development";

    # Database connection
    # For security, consider using sops-nix or agenix for secrets
    databaseUrl = "postgresql://podwriter:AK2YD3*_3qla!pla@podwriter-1:5432/podwriter";

    # Service endpoints
    natsUrl = "nats://podwriter:9BueebFpVBDTtoK2isi@nats.transcripts.cloud:4222";
    elasticsearchHost = "http://localhost:9200";

    # AI model
    transcriptionChatModel = "gpt-4o";

    # Spotify credentials - CHANGE THESE
    spotify = {
      username = "YOUR_SPOTIFY_USERNAME";
      password = "YOUR_SPOTIFY_PASSWORD";
      clientId = "YOUR_SPOTIFY_CLIENT_ID";
      clientSecret = "YOUR_SPOTIFY_CLIENT_SECRET";
    };

    # Logging
    logLevel = "info,sqlx=warn,podwriter=debug";

    # Additional environment variables if needed
    extraEnvironment = {
      # Add any additional environment variables here
      # NATS_USER='podwriter'
      # NATS_PASSWORD='9BueebFpVBDTtoK2isi'
      # NATS_URL='nats://nats.transcripts.cloud:4222'
    };
  };

  # Optional: Ensure other required services are running
  # services.postgresql.enable = true;
  # services.nats.enable = true;
  # services.elasticsearch.enable = true;
}
