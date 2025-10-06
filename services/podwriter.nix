# Podwriter Controller Service Configuration
{ config, pkgs, lib, ... }:

{
  services.podwriter-controller = {
    enable = false;
    logLevel = "info,sqlx=warn,podwriter=debug";
    environment = "development";

    dataDir = /home/robert/projects/biz/podwriter-deploy-test-data/transcription-jobs;
    databaseUrl = "postgresql://podwriter:AK2YD3*_3qla!pla@podwriter-1:5432/podwriter";
    natsUrl = "nats://nats.transcripts.cloud:4222";
    natsUser = "podwriter";
    natsPassword = "9BueebFpVBDTtoK2isi";
    elasticsearchHost = "http://localhost:9200";

    transcriptionChatModel = "gpt-4o";

    spotify = {
      username = "YOUR_SPOTIFY_USERNAME";
      password = "YOUR_SPOTIFY_PASSWORD";
      clientId = "YOUR_SPOTIFY_CLIENT_ID";
      clientSecret = "YOUR_SPOTIFY_CLIENT_SECRET";
    };

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


  services.podwriter-web-app = {
    enable = false;
    logLevel = "info,sqlx=warn,podwriter=debug,firebase=debug";

    host = "0.0.0.0";
    port = 3003;
    environment = "development";

    sessionDb = /home/robert/projects/biz/podwriter/data/sessions.sqlite;
    dataDir = /home/robert/projects/biz/podwriter-deploy-test-data/transcription-jobs;
    databaseUrl = "postgresql://podwriter:AK2YD3*_3qla!pla@podwriter-1:5432/podwriter";
    natsUrl = "nats://podwriter:9BueebFpVBDTtoK2isi@nats.transcripts.cloud:4222";
    natsUser = "podwriter";
    natsPassword = "9BueebFpVBDTtoK2isi";

    transcriptionChatModel = "gpt-4o";

    extraEnvironment = { };
  };

}
