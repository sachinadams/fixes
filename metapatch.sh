docker rm --force "/xmetapatch" > /dev/null 2>&1
docker run -dit --name=xmetapatch  mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1
docker exec xmetapatch chage -m 0 -M 99999 -I -1 -E -1 xmeta
docker exec xmetapatch chage -m 0 -M 99999 -I -1 -E -1 db2inst1
docker exec xmetapatch chage -m 0 -M 99999 -I -1 -E -1 db2fenc1
docker exec xmetapatch chage -m 0 -M 99999 -I -1 -E -1 xmetasr
docker exec xmetapatch chage -m 0 -M 99999 -I -1 -E -1 dsodb
docker exec xmetapatch chage -m 0 -M 99999 -I -1 -E -1 srduser
docker exec xmetapatch chage -m 0 -M 99999 -I -1 -E -1 iauser
docker exec xmetapatch chage -m 0 -M 99999 -I -1 -E -1 dasusr1
docker exec xmetapatch touch /patched.000
docker tag mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1  mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1.org
docker commit xmetapatch mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1
docker push mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1

kubectl delete pod $(kubectl get pods -n zen | grep xmeta|cut -f1 -d" ") -n zen

sleep 15
echo "Current User Expiry------------------------------------------"
kubectl exec -n zen $(kubectl get pods -n zen | grep xmeta|cut -f1 -d" ") -- chage -l xmeta
