#!/bin/bash

function get() {
  local response
  response=$(curl --request "GET" "$1" | tr -d "[:cntrl:]")
  local result
  result=$(parse_json "$response" "$2")
  echo "$result"
}

function parse_json() {
  local result
  result=$(echo "$1" | jq -r "$2")
  echo "$result"
}

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
  curl "$download_link" --output proxy.jar
}

