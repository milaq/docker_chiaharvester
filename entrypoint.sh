#!/bin/bash

LASTCHALLENGE_FILE="/dev/shm/chia_harvester_lastchallenge"
LASTCHALLENGE_THRESHOLD=60
BINDIR=/chia/bin

export PLOTSDIR=/chia/plots
export CADIR=/chia/ca
export CHIA_HOME=/chia/data
export CHIA_LOGFILE=$CHIA_HOME/.chia/mainnet/log/debug.log

chia_cmd() {
  su chia -c ". $BINDIR/activate && chia $1"
  return $?
}

if [[ -z $FARMER_HOST ]]; then
  echo "Error: FARMER_HOST environment variable missing"
  exit 1
fi

if [[ ! -d $PLOTSDIR ]]; then
  echo "Error: Plots directory does not exist ($PLOTSDIR)"
  exit 1
fi

if [[ ! -d $CADIR ]]; then
  echo "Error: Chia CA directory not found ($CADIR)"
  exit 1
fi

if [[ -z $PLOTS_REFRESH_FREQUENCY ]]; then
  export PLOTS_REFRESH_FREQUENCY=1800
fi

if [[ -z $HARVESTER_LOGLEVEL ]]; then
  export HARVESTER_LOGLEVEL="WARNING"
fi

echo "Initializing Chia resources"
chia_cmd "init"
chia_cmd "init -c $CADIR"

echo "Configuring Chia harvester"
/chia/configure.py $CHIA_HOME/.chia/mainnet/config/config.yaml
if [[ $? -ne 0 ]]; then
  echo "Error: Harvester configuration failed"
  exit 1
fi

echo "Starting harvester"
chia_cmd "start harvester"
sleep 30

challenge_received=-1
while true; do
  last_challenge=$(cat $LASTCHALLENGE_FILE 2> /dev/null)
  if [[ ! $last_challenge =~ ^[0-9]+$ ]]; then
    last_challenge=0
  fi
  curtime=$(date +%s)
  last_challenge_age=$(($curtime - $last_challenge))
  if [[ $last_challenge_age -gt $LASTCHALLENGE_THRESHOLD ]]; then
    if [[ $challenge_received -ne 0 ]]; then
      echo "[$(date)] Did not receive a challenge from farmer for at least $LASTCHALLENGE_THRESHOLD seconds"
    fi
    challenge_received=0
  else
    if [[ $challenge_received -ne 1 ]]; then
      echo "[$(date)] Receiving challenges from farmer"
    fi
    challenge_received=1
  fi
  sleep 10
done
