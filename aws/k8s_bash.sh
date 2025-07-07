#########################################################
#                  CONFIGURATION                      #
#########################################################
# ❗ IMPORTANT: Set this to the full path of your YAML file
export K8S_DAEMONSET_YAML="/mnt/llm-data/users/lichang93/k8s/daemonset.yaml"

# Define the namespace and label selector for convenience
export K8S_NS="explore-rl"
export K8S_SELECTOR="app=lichang93"
#########################################################


# Start the pods using the DaemonSet YAML
kup() {
    if [ ! -f "$K8S_DAEMONSET_YAML" ]; then
        echo "❌ Error: DaemonSet file not found at $K8S_DAEMONSET_YAML"
        return 1
    fi
    echo "🚀 Applying DaemonSet from $K8S_DAEMONSET_YAML..."
    kubectl apply -f "$K8S_DAEMONSET_YAML"
    echo "⏳ Waiting for 5 pods to be running..."
    kubectl wait --for=condition=Ready pod --selector=$K8S_SELECTOR -n $K8S_NS --timeout=300s
    echo "✅ All 5 pods are ready."
}

# Tear down all pods by deleting the DaemonSet
kdown() {
    if [ ! -f "$K8S_DAEMONSET_YAML" ]; then
        echo "❌ Error: DaemonSet file not found at $K8S_DAEMONSET_YAML"
        return 1
    fi
    echo "🔥 Deleting DaemonSet defined in $K8S_DAEMONSET_YAML..."
    kubectl delete -f "$K8S_DAEMONSET_YAML"
}

# Bring up a Ray cluster on the first 4 pods
# Bring up a Ray cluster on the first 4 pods
krayup() {
    echo " RAY CLUSTER: Starting..."
    # Get all pod names, sort them to be deterministic
    PODS=($(kubectl get pods -n $K8S_NS --selector=$K8S_SELECTOR -o 'jsonpath={.items[*].metadata.name}' | tr ' ' '\n' | sort))

    if [ ${#PODS[@]} -lt 4 ]; then
        echo "❌ Error: Less than 4 pods found. Found ${#PODS[@]}."
        return 1
    fi

    HEAD_POD=${PODS[0]}
    WORKER_PODS=(${PODS[1]} ${PODS[2]} ${PODS[3]})

    echo "🔹 Head Pod: $HEAD_POD"
    echo "🔹 Worker Pods: ${WORKER_PODS[*]}"

    # Get the IP of the head pod
    HEAD_IP=$(kubectl get pod $HEAD_POD -n $K8S_NS -o jsonpath='{.status.podIP}')
    if [ -z "$HEAD_IP" ]; then
        echo "❌ Error: Could not get IP for head pod $HEAD_POD."
        return 1
    fi
    echo "🔹 Head IP: $HEAD_IP"

    local CHECK_CMD="if pgrep -f '[r]aylet' > /dev/null; then echo 'Ray is already running, skipping.'; else . /root/.venv/base/bin/activate && "
    local HEAD_START_CMD="ray start --head --port=6379 --disable-usage-stats; fi"
    local WORKER_START_CMD="ray start --address=${HEAD_IP}:6379 --disable-usage-stats; fi"

    # Start Ray head, only if not already running
    echo "⏳ Checking Ray head on $HEAD_POD..."
    kubectl exec -n $K8S_NS $HEAD_POD -- \
        bash -c "${CHECK_CMD}${HEAD_START_CMD}"

    # Start Ray workers in parallel, only if not already running
    for WORKER in "${WORKER_PODS[@]}"; do
        echo "⏳ Checking Ray worker on $WORKER..."
        kubectl exec -n $K8S_NS $WORKER -- \
            bash -c "${CHECK_CMD}${WORKER_START_CMD}" &
    done

    echo "⌛ Waiting for all checks to complete..."
    wait

    echo "✅ Ray cluster startup command finished."
}

# Shut down the Ray cluster
kraydown() {
    echo " RAY CLUSTER: Shutting down..."
    PODS=($(kubectl get pods -n $K8S_NS --selector=$K8S_SELECTOR -o 'jsonpath={.items[*].metadata.name}' | tr ' ' '\n' | sort | head -n 4))

    # Stop Ray on all pods in parallel
    for POD in "${PODS[@]}"; do
        echo "⏳ Stopping Ray on $POD..."
        kubectl exec -n $K8S_NS $POD -- \
            bash -c ". /root/.venv/base/bin/activate && ray stop" &
    done

    echo "⌛ Waiting for all Ray instances to stop..."
    wait # Pauses here until all background jobs are done

    echo "✅ Ray cluster shut down."
}

# Get an interactive shell on the 5th pod for development
kdev() {
    echo " DEV SHELL: Connecting to the 5th pod..."
    # Get all pod names, sort them, and grab the 5th one (index 4)
    DEV_POD=$(kubectl get pods -n $K8S_NS --selector=$K8S_SELECTOR -o 'jsonpath={.items[*].metadata.name}' | tr ' ' '\n' | sort | sed -n '5p')

    if [ -z "$DEV_POD" ]; then
        echo "❌ Error: Could not find the 5th pod."
        return 1
    fi

    echo "🔹 Connecting to dev pod: $DEV_POD"
    kubectl exec -it -n $K8S_NS $DEV_POD -- bash
}
alias kpods="kubectl get pods -n explore-rl"
kbash() { kubectl exec -it -n $K8S_NS "$1" -- bash; }
# Runs a given command on all pods, or on a specific list of pods.
#
# Usage (all pods):
#   k-exec <command>
#   Example: k-exec hostname -I
#
# Usage (specific pods):
#   k-exec -p "pod1_name pod2_name" <command>
#   Example: k-exec -p "verldev-abcde verldev-fghij" hostname -I
#
kexec() {
    local POD_LIST=""

    # Check if the first argument is the '-p' (pods) flag
    if [[ "$1" == "-p" || "$1" == "--pods" ]]; then
        POD_LIST="$2"
        shift 2 # Consume the '-p' flag and the pod list string
    fi

    # The rest of the arguments are the command to run
    local CMD="$@"

    if [ -z "$CMD" ]; then
        echo "Usage: k-exec [-p \"pod1 pod2\"] <command>"
        return 1
    fi

    local PODS=()
    # If a pod list was provided, use it. Otherwise, get all pods.
    if [ -n "$POD_LIST" ]; then
        echo "🏃 Running command on specific pods: '$CMD'"
        # Convert the space-separated string into a bash array
        read -r -a PODS <<< "$POD_LIST"
    else
        echo "🏃 Running command on ALL pods: '$CMD'"
        # Get all pod names
        PODS=($(kubectl get pods -n $K8S_NS --selector=$K8S_SELECTOR -o 'jsonpath={.items[*].metadata.name}' | tr ' ' '\n' | sort))
    fi

    if [ ${#PODS[@]} -eq 0 ]; then
        echo "❌ Error: No pods found to run on."
        return 1
    fi

    # Run the command on all specified pods in parallel
    for POD in "${PODS[@]}"; do
        (
            echo "--- Output from $POD ---"
            kubectl exec -n $K8S_NS "$POD" -- bash -c "$CMD" | sed "s/^/$POD: /"
            echo "--------------------------"
        ) &
    done

    # Wait for all background jobs to finish
    wait
    echo "✅ Command finished."
}
