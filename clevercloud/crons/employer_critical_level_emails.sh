set -euo pipefail

if [[ "${INSTANCE_NUMBER:-}" != "0" ]]; then
    echo "Instance number is ${INSTANCE_NUMBER}. Stop here."
    exit 0
fi

cd "${APP_HOME}"

lock_file="/tmp/lock_file.lock"

cleanup() {
    rm -f "${lock_file}"
}

trap cleanup EXIT INT TERM

exec 9>"${lock_file}"
if ! flock -n 9; then
    echo "Another run is already in progress. Stop here."
    exit 0
fi

bundle exec rake digest_mailers:send_critical_urgency_emails
sleep 15m