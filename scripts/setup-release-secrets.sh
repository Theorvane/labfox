#!/usr/bin/env bash
#
# Loads the release pipeline's credentials into the repository's environments.
#
# Every value goes straight from a local file, or from your keyboard, into
# `gh secret set` over stdin. Nothing is echoed, nothing is written to a
# temporary file, and nothing lands in your shell history. Run it yourself:
# it needs secrets, so it is deliberately not something CI or an agent does.
#
#   ./scripts/setup-release-secrets.sh android
#   ./scripts/setup-release-secrets.sh apple
#   ./scripts/setup-release-secrets.sh check
#
# What each credential is and where to get it: RELEASING.md.

set -euo pipefail

REPO="${LABFOX_REPO:-theorvane/labfox}"
KEY_PROPERTIES="apps/labfox/android/key.properties"

die() { echo "error: $*" >&2; exit 1; }
note() { printf '  %s\n' "$*"; }

# Sets a secret without the value appearing as an argument, in `ps`, or in the
# shell history.
set_secret() {
  local name="$1" env="$2"
  gh secret set "$name" --repo "$REPO" --env "$env" >/dev/null
  note "set $name"
}

# Reads one key out of key.properties without printing it.
prop() {
  local key="$1"
  sed -n "s/^${key}=//p" "$KEY_PROPERTIES" | head -1
}

prompt_secret() {
  local name="$1" env="$2" label="$3"
  local value
  printf '%s: ' "$label" >&2
  read -rs value
  printf '\n' >&2
  [ -n "$value" ] || die "$name cannot be empty"
  printf '%s' "$value" | set_secret "$name" "$env"
}

prompt_file_base64() {
  local name="$1" env="$2" label="$3"
  local path
  printf '%s (path): ' "$label" >&2
  read -r path
  path="${path/#\~/$HOME}"
  [ -f "$path" ] || die "no file at $path"
  base64 < "$path" | tr -d '\n' | set_secret "$name" "$env"
}

setup_android() {
  echo "Android — environment: play-store"
  [ -f "$KEY_PROPERTIES" ] || die "$KEY_PROPERTIES not found; see RELEASING.md"

  local store_file store_password key_alias key_password
  store_file="$(prop storeFile)"
  store_password="$(prop storePassword)"
  key_alias="$(prop keyAlias)"
  key_password="$(prop keyPassword)"

  [ -n "$store_file" ] || die "storeFile is empty in $KEY_PROPERTIES"
  [ -f "$store_file" ] || die "the keystore at storeFile does not exist"
  [ -n "$store_password" ] || die "storePassword is empty in $KEY_PROPERTIES"
  [ -n "$key_alias" ] || die "keyAlias is empty in $KEY_PROPERTIES"
  [ -n "$key_password" ] || die "keyPassword is empty in $KEY_PROPERTIES"

  base64 < "$store_file" | tr -d '\n' | set_secret ANDROID_KEYSTORE_BASE64 play-store
  printf '%s' "$store_password" | set_secret ANDROID_KEYSTORE_PASSWORD play-store
  printf '%s' "$key_alias" | set_secret ANDROID_KEY_ALIAS play-store
  printf '%s' "$key_password" | set_secret ANDROID_KEY_PASSWORD play-store

  echo
  echo "Google Play service account JSON"
  note "Play Console → Setup → API access → create a service account,"
  note "grant it release permissions, then download its JSON key."
  local json_path
  printf '  path to the JSON key: ' >&2
  read -r json_path
  json_path="${json_path/#\~/$HOME}"
  [ -f "$json_path" ] || die "no file at $json_path"
  set_secret GOOGLE_PLAY_SERVICE_ACCOUNT_JSON play-store < "$json_path"
}

setup_apple() {
  echo "Apple — environment: app-store"

  local team_id
  printf 'APPLE_TEAM_ID (App Store Connect → Membership): ' >&2
  read -r team_id
  [ -n "$team_id" ] || die "APPLE_TEAM_ID cannot be empty"
  # A variable, not a secret: it is not sensitive and is easier to audit visible.
  gh variable set APPLE_TEAM_ID --repo "$REPO" --env app-store --body "$team_id" >/dev/null
  note "set APPLE_TEAM_ID"

  echo
  echo "App Store Connect API key"
  note "Users and Access → Integrations → App Store Connect API."
  note "Apple lets you download the .p8 once. Keep your copy."
  prompt_secret ASC_KEY_ID app-store "  ASC_KEY_ID"
  prompt_secret ASC_ISSUER_ID app-store "  ASC_ISSUER_ID"
  local p8
  printf '  path to the .p8 private key: ' >&2
  read -r p8
  p8="${p8/#\~/$HOME}"
  [ -f "$p8" ] || die "no file at $p8"
  set_secret ASC_PRIVATE_KEY app-store < "$p8"

  echo
  echo "Signing assets"
  prompt_file_base64 APPLE_DISTRIBUTION_CERTIFICATE_BASE64 app-store \
    "  Apple Distribution certificate (.p12)"
  prompt_secret APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD app-store \
    "  the password you set when exporting that .p12"
  prompt_file_base64 APP_STORE_PROVISIONING_PROFILE_BASE64 app-store \
    "  App Store provisioning profile (.mobileprovision)"
}

check() {
  echo "Configured — values are write-only, so only their presence is visible."
  echo
  for env in play-store app-store; do
    echo "$env"
    gh api "repos/$REPO/environments/$env/secrets" \
      --jq '.secrets[].name' 2>/dev/null | sed 's/^/  secret   /' || note "(none)"
    gh api "repos/$REPO/environments/$env/variables" \
      --jq '.variables[].name' 2>/dev/null | sed 's/^/  variable /' || true
  done
  echo
  echo "Expected by the workflows:"
  grep -rhoE "secrets\.[A-Z_]+|vars\.[A-Z_]+" .github/workflows/*.yml \
    | sed 's/^/  /' | sort -u
}

case "${1:-}" in
  android) setup_android ;;
  apple) setup_apple ;;
  check) check ;;
  *)
    echo "usage: $0 {android|apple|check}" >&2
    exit 2
    ;;
esac
