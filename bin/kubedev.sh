NAME=$1
NAMESPACE=$2
IMAGE=$3
shift 3
PORT=80
FORWARD=false
SERVICE=false
INGRESS=""

# Get the options
while getopts ":fsp:i:" option; do
  echo "option specifed: $option"
  echo "value: $OPTARG"
  case $option in
    s)
      SERVICE=true;;
    f)
      FORWARD=true;;
    p)
      PORT=$OPTARG;;
    i)
      INGRESS=$OPTARG;;
    \?)
      echo "Bad option!"
  esac
done

echo "NAME: $NAME"
echo "NAMESPACE: $NAMESPACE"
echo "IMAGE: $IMAGE"
echo "PORT: $PORT"
if [ ! $INGRESS == "" ] ; then
  echo "INGRESS: $INGRESS"
fi
if [ $FORWARD = true ] ; then
  echo "opening port forward"
fi
if [ $SERVICE = true ] ; then
  echo "creating a service!"
fi

SPEC=$(cat <<EOF
  {
    "apiVersion": "v1",
    "spec": {
      "containers": [
        {
          "name": "$NAME",
          "image": "$IMAGE",
          "command": [
            "/bin/bash",
            "-c"
          ],
          "args": [ "sleep infinity"],
          "ports": [
            {
              "containerPort": $PORT
            }
          ],
          "env": [
            {
              "name": "PS1",
              "value": "[KUBEDEV] § "
            }
          ],
          "volumeMounts": [{
            "mountPath": "/kubedev",
            "name": "kubedev"
          }]
        }
      ],
      "volumes": [{
        "name":"kubedev",
        "emptyDir":{}
      }]
    }
  }
EOF
)

SVC=$(cat <<EOF
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "$NAME"
  },
  "spec": {
    "selector": {
      "run": "$NAME"
    },
    "ports": [
      {
        "protocol": "TCP",
        "port": $PORT,
        "targetPort": $PORT
      }
    ]
  }
}
EOF
)

kubectl run \
  -n $NAMESPACE \
  --image=$IMAGE --restart=Never \
  --port=$PORT \
  --overrides=" $SPEC " \
  $NAME

while true;
do
  sleep 1
  VAR=$(kubectl get pod -n $NAMESPACE $NAME -o jsonpath="{.status.phase}")
  if [[ $VAR == "Running" ]]; then
    break
  fi
  echo "status: $VAR"
done
echo "up and running!"

FIFONAME=".kubedev-$(uuidgen)"
mkfifo $FIFONAME

bash remote_sync.sh "kubectl cp -n $NAMESPACE" "$NAME:/kubedev" >> $FIFONAME &
CP_PID=$!
echo "fifo: $FIFONAME"

if command -v tmux;
then
  tmux split-window -v "cat $FIFONAME"
fi
if [ $SERVICE = true ] ; then
  echo "creating a service!"
  echo $SVC
  echo $SVC | kubectl apply -n $NAMESPACE -f -
fi

if [ $FORWARD = true ] ; then
  echo "forwarding port $PORT"
  kubectl port-forward -n $NAMESPACE $NAME $PORT:$PORT > /dev/null &
  PORT_PID=$!
fi
kubectl exec -itn $NAMESPACE $NAME -c $NAME -- /bin/bash -c "cd /kubedev; bash"
kill $CP_PID
if [ $FORWARD = true ] ; then
  kill $PORT_PID
fi
if [ $SERVICE = true ] ; then
  kubectl delete svc -n $NAMESPACE $NAME
fi
rm $FIFONAME
kubectl delete pod -n $NAMESPACE $NAME

