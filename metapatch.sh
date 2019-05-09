#Run in master
docker rm --force "/xmetapatch" > /dev/null 2>&1
#docker run -dit --name=xmetapatch  mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1
docker run -dit --name=xmetapatch --entrypoint "tail" mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1   -f  /dev/null
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
#docker commit xmetapatch mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1
docker commit  --change='ENTRYPOINT  ["/opt/IBM/InformationServer/initScripts/startcontainer.sh"]'  xmetapatch mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1
docker push mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1
#kubectl  scale rs  $(kubectl get rs -n zen | grep xmetarepo | cut -f1 -d' ' | tr '\n' ' ') -n zen --replicas=0
kubectl scale  Deployment/ibm-iisee-zen100-ibm-iisee-zen-iis-xmetarepo -n zen   --replicas=0

# This needs to be done on all the worker nodes. 
docker rmi mycluster.icp:8500/zen/is-db2xmeta-image:11.7.0.2SP1 --force

#This would be needed in the master
#kubectl  scale rs  $(kubectl get rs -n zen | grep xmetarepo | cut -f1 -d' ' | tr '\n' ' ') -n zen --replicas=1
kubectl scale  Deployment/ibm-iisee-zen100-ibm-iisee-zen-iis-xmetarepo -n zen   --replicas=1
#kubectl delete pod $(kubectl get pods -n zen | grep iis | cut -f1 -d' ' | tr '\n' ' ') -n zen
sleep 15
echo "Current User Expiry------------------------------------------"
kubectl exec -n zen $(kubectl get pods -n zen | grep xmeta|cut -f1 -d" ") -- chage -l xmeta
