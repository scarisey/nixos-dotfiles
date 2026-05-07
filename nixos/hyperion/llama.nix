{pkgs, ...}: let
  modelFile = "/var/lib/llama-cpp/models/lmstudio-community/gemma-4-E4B-it-GGUF/gemma-4-E4B-it-Q4_K_M.gguf";
  modelUrl = "https://huggingface.co/lmstudio-community/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf";
in {
  scarisey.llama-cpp = {
    enable = true;
    model = modelFile;
    host = "127.0.0.1";
    port = 7070;
    openFirewall = false;
    package = pkgs.llama-cpp-rocm;
    extraFlags = [
      "--threads"
      "6"
      "--ctx-size"
      "32768"
      "--cache-type-k"
      "q8_0"
      "--cache-type-v"
      "q8_0"
      "--n-gpu-layers"
      "99"
      "--no-mmap"
    ];
  };

  systemd.services.llama-cpp-download-model = {
    description = "Download llama-cpp model if not present";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["llama-cpp.service"];
    before = ["llama-cpp.service"];
    partOf = ["llama-cpp.service"];
    unitConfig.RequiresMountsFor = "/var/lib/llama-cpp";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p "$(dirname "${modelFile}")"
      if [ ! -f "${modelFile}" ]; then
        ${pkgs.curl}/bin/curl -L -o "${modelFile}.part" "${modelUrl}"
        mv "${modelFile}.part" "${modelFile}"
      fi
      chmod 644 "${modelFile}"
    '';
  };
}
