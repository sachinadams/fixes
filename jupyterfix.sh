#Run in master
docker rm --force "/jupyterpatch" > /dev/null 2>&1

docker run -dit --name=jupyterpatch mycluster.icp:8500/zen/jupyter-d9a36-set1:v1.0.157-x86_64   
docker  exec -it jupyterpatch -- sed -i "s/requests.post(url, json=body, headers=headers)/requests.post(url, json=body, headers=headers, verify=False)/" /opt/conda3/lib/python3.6/site-packages/dsx_ml/util.py
docker exec jupyterpatch touch /patched.000
docker tag mycluster.icp:8500/zen/jupyter-d9a36-set1:v1.0.157-x86_64  mycluster.icp:8500/zen/jupyter-d9a36-set1:v1.0.157-x86_64.org

docker commit jupyterpatch mycluster.icp:8500/zen/jupyter-d9a36-set1:v1.0.157-x86_64
docker push mycluster.icp:8500/zen/jupyter-d9a36-set1:v1.0.157-x86_64

kubectl scale  deployment -l type=jupyter-py36 --replicas=0


# This needs to be done on all the worker nodes. 
echo " " 
echo " " 
echo "+++ Below command needs to be run manually in all the worker nodes. +++ "
echo "docker rmi mycluster.icp:8500/zen/jupyter-d9a36-set1:v1.0.157-x86_64    --force"

#This would be needed in the master
echo " " 
echo " "
echo "+++ Once done, run below command from master +++ "
echo "kubectl scale  deployment -l type=jupyter-py36  --replicas=1"

echo " " 
echo "  "
echo "+++ After scaling back the deployment, make sure the jupyter pods is up and then check if the change is present in the util.py file by running +++"
echo "for i in `kubectl get pods -n zen | grep jupyter-py36-server |cut -f1 -d" "`; do kubectl exec -n zen  $i --  tail -1 /opt/conda3/lib/python3.6/site-packages/dsx_ml/util.py ;  done"
