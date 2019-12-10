# EAP Cluster on OpenShift

Code for testing a JBoss EAP Cluster.  The test app called "cluster_test.war" creates a user session and stores the hit count into the session memory.  The app displays the hit count and the session ID. 

# Launch the test app

```
git clone https://github.com/sjbylo/cluster-test.git 
cd cluster-test 
oc new-build openshift/jboss-eap72-openshift:1.0 --name eap-cluster --binary
oc start-build eap-cluster --from-dir=. --follow
```

# Create the app 

```
oc new-app eap-cluster
oc expose svc eap-cluster 
```

# Fetch the app's route endpoint
```
RT=http://`oc get route eap-cluster -o template --template {{.spec.host}}`/cluster_test/
```

# Disable sticky sessions 
```
oc annotate routes eap-cluster  haproxy.router.openshift.io/disable_cookies='true'
```

# Set up the probes 

```
oc set probe dc/eap-cluster --liveness   --initial-delay-seconds=30 --timeout-seconds=8 -- echo ok
oc set probe dc/eap-cluster --readiness --get-url=http://:8080/cluster_test/ --initial-delay-seconds=10 --timeout-seconds=8
```

# Scale the cluster up to 3 instances 

```
oc scale dc eap-cluster --replicas=3
```

# Set up the clustering for the app

```
oc create -f - <<END
kind: Service
apiVersion: v1
spec:
    clusterIP: None
    ports:
    - name: ping
      port: 8888
    selector:
        deploymentconfig: eap-cluster
metadata:
    name: eap-cluster-ping
    annotations:
        service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
        description: "The JGroups ping port for clustering."
END
```

```
oc set env dc eap-cluster \
   JGROUPS_PING_PROTOCOL=openshift.DNS_PING \
   OPENSHIFT_DNS_PING_SERVICE_NAME=eap-cluster-ping \
   OPENSHIFT_DNS_PING_SERVICE_PORT=8888 
```

# Test the cluster

```
./test.sh $RT 0.5 10
```

