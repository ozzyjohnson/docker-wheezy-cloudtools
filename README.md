docker-wheezy-cloudtools
========================

Built: 2014.12.06

The AWS CLI, GCE SDK and Ansible built on a minimal Google Wheezy.

#### Why:

There are existing images for each of these tools in isolation, but none that combine them. At the same time, the best or at least most notable image for each depend on varying baseimages making the task of combining them at least on par with devising a new build of my own.

<br>

#### Pull:

```docker pull ozzyjohnson/wheezy-cloudtools```

<br>

#### Prepare:

**AWS:**

At minimum, the ```/.boto``` (file) and ```/.gce``` (dir) mounts should be prepared with credentials corresponding to an IAM User and Service Account respectively. With this done, Ansible playbooks targetting either platform can be run as a ```local_action``` against a container generated from this image.

**/.boto**

    [Credentials]
    aws_access_key_id = <your_access_key_here>
    aws_secret_access_key = <your_secret_key_here>

If you aren't familiar with AWS access keys, reference my quick guide to [Creating an IAM user](http://ozzyjohnson.github.io/aws10/#Creating-an-IAM-User).

**GCE:**

The easiest way to get ready to use GCE is by mounting a directory to the /.config mountpount then running ```gcloud auth login```. After autheticating via the provided link /.config/gcloud will be populated and ready for use, remounting in the future or exporting with ```--volumes-from```.

Setup:

    docker run -it \
        -v /home/ubuntu/data/.config:/.config \
        --name gcloud-auth \
        gcloud-test \
        gcloud auth login \
        --project your-project-123

Going Forward:
    
    docker run -it --rm --volumes-from gcloud-auth

Alternatively, we can configure a service account in /.gce.

**/.gce/converted.pem**

A keyfile, generated using the commands shown below, from a ```.p12``` key associated with a GCE cloud project Service Account. 

    openssl pkcs12 \
        -in generated.p12 \
        -passin pass:notasecret \
        -nodes \
        -nocerts | \
        openssl rsa \
        -out converted.pem

Salt provides an excellent set of [instructions](http://docs.saltstack.com/en/latest/topics/cloud/gce.html#google-compute-engine-setup) for creating a new cloud project, service account and generating / converting the required key. 

Be sure to take note of your resulting ```Project ID``` and ```Service Account Email Address``` for use in ```secrets.py``` as shown below.

**/.gce/secrets.py**

    GCE_PARAMS = ('long...@developer.gserviceaccount.com', '/path/to/converted.pem')
    GCE_KEYWORD_PARAMS = {'project': 'my_project_id'}

With that done, we can configure the account like so.

Setup:

    docker run -it \
        -v /home/ubuntu/data/.config:/.config \
        --name gcloud-service \
        ozzyjohnson/cloudtools

From the interactive prompt.

    gcloud auth activate-service-account \
        `awk -F\' 'NR==1{print $2}' /.gce/secrets.py` \
        --key-file \
        `awk -F\' 'NR==1{print $4}' /.gce/secrets.py` \
        --project your-project-123

Going Forward:

    docker run -it --rm --volumes-from gcloud-service

#### Run:

Once configured, this image can be run interactively or executable style.

**Interactive:**

     docker run \
         --volumes-from cloudtools-auth \
         -it \
         --rm wheezy-cloudtools 

**Executable:**

    docker run \
        --volumes-from cloudtools-auth \
        -it --rm wheezy-cloudtools \
        ansible-playbook -i *, /data/ec2.yml

**ec2.yml**

    # Simple EC2 playbook.
    - hosts: 127.0.0.1
      connection: local
      tasks:
        - local_action:
            module: ec2
            key_name: mykey
            region: us-east-1
            instance_type: t1.micro
            image: ami-0870c460
            wait: yes
            count: 1

**gce.yml**

    # Simple GCE playbook.
    - hosts: 127.0.0.1
      connection: local
      tasks:
      - local_action:
          module: gce
          name: test-instance-01
          zone: us-central1-a
          machine_type: n1-standard-1
          image: debian-7
