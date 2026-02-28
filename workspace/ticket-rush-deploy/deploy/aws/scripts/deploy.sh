#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="${SCRIPT_DIR}/../docker-compose/ticket-rush"
COMPOSE_FILE="${COMPOSE_DIR}/docker-compose.ec2.yml"

HOST=""
KEY_PATH=""
SSH_USER="ec2-user"
AWS_REGION="ap-northeast-2"
ACCOUNT_ID=""
BACKEND_REPO=""
BACKEND_TAG=""
FRONTEND_REPO=""
FRONTEND_TAG=""
REMOTE_DIR="/opt/ticket-rush"
SEED_ENABLED="true"
SEED_MARKER_KEY="kpop20_seed_marker_v1"

usage() {
  cat <<USAGE
Usage: deploy.sh --host <EC2_PUBLIC_IP> --key <PEM_PATH> --account-id <AWS_ACCOUNT_ID> \\
  --backend-repo <ECR_REPO> --backend-tag <TAG> --frontend-repo <ECR_REPO> --frontend-tag <TAG> [options]

Options:
  --user <SSH_USER>                (default: ec2-user)
  --aws-region <REGION>            (default: ap-northeast-2)
  --remote-dir <PATH>              (default: /opt/ticket-rush)
  --seed-enabled <true|false>      (default: true)
  --seed-marker-key <KEY>          (default: kpop20_seed_marker_v1)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) HOST="$2"; shift 2 ;;
    --key) KEY_PATH="$2"; shift 2 ;;
    --user) SSH_USER="$2"; shift 2 ;;
    --aws-region) AWS_REGION="$2"; shift 2 ;;
    --account-id) ACCOUNT_ID="$2"; shift 2 ;;
    --backend-repo) BACKEND_REPO="$2"; shift 2 ;;
    --backend-tag) BACKEND_TAG="$2"; shift 2 ;;
    --frontend-repo) FRONTEND_REPO="$2"; shift 2 ;;
    --frontend-tag) FRONTEND_TAG="$2"; shift 2 ;;
    --remote-dir) REMOTE_DIR="$2"; shift 2 ;;
    --seed-enabled) SEED_ENABLED="$2"; shift 2 ;;
    --seed-marker-key) SEED_MARKER_KEY="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

for required in HOST KEY_PATH ACCOUNT_ID BACKEND_REPO BACKEND_TAG FRONTEND_REPO FRONTEND_TAG; do
  if [[ -z "${!required}" ]]; then
    echo "[ERROR] missing required arg: ${required}" >&2
    usage
    exit 1
  fi
done

if [[ ! -f "${KEY_PATH}" ]]; then
  echo "[ERROR] key not found: ${KEY_PATH}" >&2
  exit 1
fi

ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
TMP_ENV="$(mktemp)"
trap 'rm -f "${TMP_ENV}"' EXIT

cat > "${TMP_ENV}" <<ENV
AWS_REGION=${AWS_REGION}
ECR_REGISTRY=${ECR_REGISTRY}
BACKEND_IMAGE_REPO=${BACKEND_REPO}
BACKEND_IMAGE_TAG=${BACKEND_TAG}
FRONTEND_IMAGE_REPO=${FRONTEND_REPO}
FRONTEND_IMAGE_TAG=${FRONTEND_TAG}
APP_SEED_KPOP20_ENABLED=${SEED_ENABLED}
APP_SEED_KPOP20_MARKER_KEY=${SEED_MARKER_KEY}
ENV

SSH_OPTS=(-i "${KEY_PATH}" -o StrictHostKeyChecking=accept-new)

ssh "${SSH_OPTS[@]}" "${SSH_USER}@${HOST}" "mkdir -p ${REMOTE_DIR}"
scp "${SSH_OPTS[@]}" "${COMPOSE_FILE}" "${SSH_USER}@${HOST}:${REMOTE_DIR}/docker-compose.ec2.yml"
scp "${SSH_OPTS[@]}" "${TMP_ENV}" "${SSH_USER}@${HOST}:${REMOTE_DIR}/.env"

ssh "${SSH_OPTS[@]}" "${SSH_USER}@${HOST}" bash -s <<REMOTE
set -euo pipefail
cd "${REMOTE_DIR}"
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"
docker compose --env-file .env -f docker-compose.ec2.yml pull
docker compose --env-file .env -f docker-compose.ec2.yml up -d
docker compose --env-file .env -f docker-compose.ec2.yml ps
REMOTE

echo "[OK] deployed to ${HOST}"
