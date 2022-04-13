#!/bin/bash
## EMQ docker image start script
# Huang Rui <vowstar@gmail.com>
# EMQ X Team <support@emqx.io>

## Shell setting
if [[ -n "$DEBUG" ]]; then
    set -ex
else
    set -e
fi

shopt -s nullglob

## EMQ Base settings and plugins setting
# Base settings in /opt/emqx/etc/emqx.conf
# Plugin settings in /opt/emqx/etc/plugins

_EMQX_HOME='/opt/emqx'

if [[ -z "$EMQX_NODE_NAME" ]]; then

    if [[ -z "$EMQX_NAME" ]]; then
        EMQX_NAME="$(hostname)"
    fi
    if [[ -z "$EMQX_HOST" ]]; then
        LOCAL_IP=$(hostname -i)
        if [[ "$EMQX_CLUSTER__DISCOVERY" == "dns" ]] && \
            [[ "$EMQX_CLUSTER__DNS__TYPE" == "srv" ]] && \
            grep -q "$(hostname).$EMQX_CLUSTER__DNS__NAME" /etc/hosts; then
                EMQX_HOST="$(hostname).$EMQX_CLUSTER__DNS__NAME"
        elif [[ "$EMQX_CLUSTER__DISCOVERY" == "k8s" ]] && \
            [[ "$EMQX_CLUSTER__K8S__ADDRESS_TYPE" == "dns" ]] && \
            [[ -n "$EMQX_CLUSTER__K8S__NAMESPACE" ]]; then
                EMQX_CLUSTER__K8S__SUFFIX=${EMQX_CLUSTER__K8S__SUFFIX:-"pod.cluster.local"}
                EMQX_HOST="${LOCAL_IP//./-}.$EMQX_CLUSTER__K8S__NAMESPACE.$EMQX_CLUSTER__K8S__SUFFIX"
        elif [[ "$EMQX_CLUSTER__DISCOVERY" == "k8s" ]] && \
            [[ "$EMQX_CLUSTER__K8S__ADDRESS_TYPE" == 'hostname' ]] && \
            [[ -n "$EMQX_CLUSTER__K8S__NAMESPACE" ]]; then
                EMQX_CLUSTER__K8S__SUFFIX=${EMQX_CLUSTER__K8S__SUFFIX:-'svc.cluster.local'}
                EMQX_HOST=$(grep -h "^$LOCAL_IP" /etc/hosts | grep -o "$(hostname).*.$EMQX_CLUSTER__K8S__NAMESPACE.$EMQX_CLUSTER__K8S__SUFFIX")
        else
            EMQX_HOST="$LOCAL_IP"
        fi
        export EMQX_HOST
    fi

    export EMQX_NODE_NAME="$EMQX_NAME@$EMQX_HOST"
    unset EMQX_NAME
    unset EMQX_HOST
fi

# Set hosts to prevent cluster mode failed

if [[ -z "$EMQX_NODE__PROCESS_LIMIT" ]]; then
    export EMQX_NODE__PROCESS_LIMIT=2097152
fi

if [[ -z "$EMQX_NODE__MAX_PORTS" ]]; then
    export EMQX_NODE__MAX_PORTS=1048576
fi

if [[ -z "$EMQX_NODE__MAX_ETS_TABLES" ]]; then
    export EMQX_NODE__MAX_ETS_TABLES=2097152
fi

if [[ -z "$EMQX_LISTENER__TCP__EXTERNAL__ACCEPTORS" ]]; then
    export EMQX_LISTENER__TCP__EXTERNAL__ACCEPTORS=64
fi

if [[ -z "$EMQX_LISTENER__TCP__EXTERNAL__MAX_CONNECTIONS" ]]; then
    export EMQX_LISTENER__TCP__EXTERNAL__MAX_CONNECTIONS=1024000
fi

if [[ -z "$EMQX_LISTENER__SSL__EXTERNAL__ACCEPTORS" ]]; then
    export EMQX_LISTENER__SSL__EXTERNAL__ACCEPTORS=32
fi

if [[ -z "$EMQX_LISTENER__SSL__EXTERNAL__MAX_CONNECTIONS" ]]; then
    export EMQX_LISTENER__SSL__EXTERNAL__MAX_CONNECTIONS=102400
fi

if [[ -z "$EMQX_LISTENER__WS__EXTERNAL__ACCEPTORS" ]]; then
    export EMQX_LISTENER__WS__EXTERNAL__ACCEPTORS=16
fi

if [[ -z "$EMQX_LISTENER__WS__EXTERNAL__MAX_CONNECTIONS" ]]; then
    export EMQX_LISTENER__WS__EXTERNAL__MAX_CONNECTIONS=102400
fi

if [[ -z "$EMQX_LISTENER__WSS__EXTERNAL__ACCEPTORS" ]]; then
    export EMQX_LISTENER__WSS__EXTERNAL__ACCEPTORS=16
fi

if [[ -z "$EMQX_LISTENER__WSS__EXTERNAL__MAX_CONNECTIONS" ]]; then
    export EMQX_LISTENER__WSS__EXTERNAL__MAX_CONNECTIONS=102400
fi

# The default rpc port discovery 'stateless' is mostly for clusters
# having static node names. So it's troulbe-free for multiple emqx nodes
# running on the same host.
# When start emqx in docker, it's mostly one emqx node in one container
export EMQX_RPC__PORT_DISCOVERY="${EMQX_RPC__PORT_DISCOVERY:-manual}"

exec "$@"
