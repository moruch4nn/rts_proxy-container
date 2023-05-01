#!/bin/bash

#
# getリクエストをリンクに対して飛ばし、レスポンスのjsonをjqで解析する関数です。
#
function get() {
  local response
  response=$(curl -fsSL --request "GET" "$1" | tr -d "[:cntrl:]")
  local result
  result=$(parse_json "$response" "$2")
  echo "$result"
}

#
# jqを使用してjsonをパースする関数です。
#
function parse_json() {
  local result
  result=$(echo "$1" | jq -r "$2")
  echo "$result"
}

#
# Velocityの最新バージョンをダウンロードし、proxy.jarという名前で保存する関数です。
#
function setup_velocity() {
  local version
  version=$(get "https://api.papermc.io/v2/projects/velocity" ".versions[-1]")
  local latest_build
  latest_build=$(get "https://api.papermc.io/v2/projects/velocity/versions/${version}/builds" ".builds[-1]")
  local build_number
  build_number=$(parse_json "$latest_build" ".build")
  local file_name
  file_name=$(parse_json "$latest_build" ".downloads.application.name")
  local download_link
  download_link="https://api.papermc.io/v2/projects/velocity/versions/${version}/builds/$build_number/downloads/$file_name"
  curl "$download_link" -fsSL -H "User-Agent: RedTownServer-Proxy-Setup" --output proxy.jar
}

#
# Velocityの今フィルファイルを生成する関数です。
#
function generate_velocity_config() {
  java -jar /tmp/vcb.jar \
  --bind "${BIND:-"0.0.0.0:25577"}" \
  --motd "${MOTD:-"&#09add3A Velocity Server"}" \
  --show_max_players "${SHOW_MAX_PLAYERS:-"500"}" \
  --online_mode "${ONLINE_MODE:-"true"}" \
  --force_key_authentication "${FORCE_KEY_AUTHENTICATION:-"true"}" \
  --prevent_client_proxy_connections "${PREVENT_CLIENT_PROXY_CONNECTIONS:-"false"}" \
  --player_info_forwarding_mode "${PLAYER_INFO_FORWARDING_MODE:-"none"}" \
  --forwarding_secret_file "${FORWARDING_SECRET_FILE:-"forwarding.secret"}" \
  --announce_forge "${ANNOUNCE_FORGE:-"false"}" \
  --kick_existing_players "${KICK_EXISTING_PLAYERS:-"true"}" \
  --ping_passthrough "${PING_PASSTHROUGH:-"disabled"}" \
  --enable_player_address_logging "${ENABLE_PLAYER_ADDRESS_LOGGING:-"true"}" \
  --servers "${SERVERS:-"lobby=127.0.0.1:25566"}" \
  --try "${TRY:-"lobby"}" \
  --forced_hosts "${FORCED_HOSTS:-"lobby.example.com=lobby"}" \
  --compression_threshold "${COMPRESSION_THRESHOLD:-"256"}" \
  --compression_level "${COMPRESSION_LEVEL:-"6"}" \
  --login_ratelimit "${LOGIN_RATELIMIT:-"3000"}" \
  --connection_timeout "${CONNECTION_TIMEOUT:-"5000"}" \
  --read_timeout "${READ_TIMEOUT:-"30000"}" \
  --haproxy_protocol "${HAPROXY_PROTOCOL:-"false"}" \
  --tcp_fast_open "${TCP_FAST_OPEN:-"false"}" \
  --bungee_plugin_message "${BUNGEE_PLUGIN_MESSAGE:-"true"}" \
  --show_ping_requests "${SHOW_PING_REQUESTS:-"false"}" \
  --failover_on_unexpected_server_disconnect "${FAILOVER_ON_UNEXPECTED_SERVER_DISCONNECT:-"true"}" \
  --announce_proxy_commands "${ANNOUNCE_PROXY_COMMANDS:-"true"}" \
  --log_command_executions "${LOG_COMMAND_EXECUTIONS:-"false"}" \
  --log_player_connections "${LOG_PLAYER_CONNECTIONS:-"true"}" \
  --query_enabled "${QUERY_ENABLED:-"true"}" \
  --query_port "${QUERY_PORT:-"25577"}" \
  --query_map "${QUERY_MAP:-"Velocity"}" \
  --query_show_plugins "${QUERY_SHOW_PLUGINS:-"false"}" \
  --output "velocity.toml"

  # forwarding.secretが存在しない場合は生成する
  if [ ! -f "${FORWARDING_SECRET_FILE:-"forwarding.secret"}" ]; then
    < /dev/random tr -dc 'a-zA-Z0-9' | fold -16 | head -1 > "${FORWARDING_SECRET_FILE:-"forwarding.secret"}"
  fi

  # server-icon.pngがない場合はダウンロードしてくる
  if [ -n "${SERVER_ICON}" ]; then
    curl "$SERVER_ICON" -fsSL -H "User-Agent: RedTownServer-Proxy-Setup" --output server-icon.png
  fi
}

#
# start a velocity server
#
function start_velocity_server() {
  java -jar -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 proxy.jar nogui
}

function download_plugin() {
  local download_link="$1"
  local file_name="$2"
  mkdir -p plugins
  curl "$download_link" -fsSL -H "User-Agent: RedTownServer-Proxy-Setup" --output "./plugins/${file_name}"
}

#
# LuckPermsの最新バージョンをダウンロード
#
function download_latest_luckperms() {
  local download_link
  download_link=$(get "https://metadata.luckperms.net/data/all" ".downloads.velocity")
  download_plugin "$download_link" "luckperms.jar"
}

#
# ViaVersionの最新バージョンをダウンロード
#
function download_latest_viaversion() {
  local download_link
  download_link=https://api.spiget.org/v2/resources/19254/download
  download_plugin "$download_link" viaversion.jar
}

function download_latest_rtsproxy() {
  local download_link
  download_link=https://github.com/moruch4nn/rts-proxy-plugin/releases/latest/download/rts-proxy.jar
  download_plugin "$download_link" rtsproxy.jar
}

#
# GeyserMCの最新バージョンをダウンロード
#
function download_latest_geyser() {
  local download_link
  download_link=https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/velocity/build/libs/Geyser-Velocity.jar
  mkdir -p plugins
  download_plugin "$download_link" geyser.jar
}

#
# 最新のOnlyLatestをダウンロード
#
function download_latest_onlylatest() {
  local download_link
  download_link=https://github.com/moruch4nn/OnlyLatest/releases/latest/download/only-latest.jar
  download_plugin "$download_link" onlylatest.jar
}

#
# 最新のFloodgateをダウンロード
#
function download_latest_floodgate() {
  local download_link
  download_link=https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/velocity/build/libs/floodgate-velocity.jar
  download_plugin "$download_link" floodgate.jar
}

#
# 最新のvTunnelをダウンロード
#
function download_latest_vtunnel() {
  local download_link
  download_link=https://github.com/moruch4nn/vTunnel/releases/latest/download/vtunnel-server_velocity.jar
  download_plugin "$download_link" floodgate.jar
}

function download_plugins() {
  if [ -n "${PLUGIN_LINKS}" ]; then
    local plugin_links
    plugin_links=$(echo "${PLUGIN_LINKS}" | tr "," "\n")
    for file_link_name in $plugin_links
    do
      if [[ $file_link_name =~ (.+?)=(.+) ]]; then
        local file_name
        local download_link
        file_name=${BASH_REMATCH[1]}
        download_link=${BASH_REMATCH[2]}
        download_plugin "$download_link" file_name.jar &
      fi
    done
  fi
  wait
}

# Velocity関連のセットアップ
setup_velocity &
generate_velocity_config &

# 必要なプラグインのセットアップ
download_latest_luckperms &
download_latest_viaversion &
download_latest_geyser &
download_latest_floodgate &
download_latest_onlylatest &
download_latest_rtsproxy &
download_latest_vtunnel &

# 追加のプラグインが必要な場合はダウンロード
download_plugins &

# 並列実行の終了を待機
wait

# Velocityプラグインを起動
start_velocity_server