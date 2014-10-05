docker-wheezy-cloudtools
========================

The AWS CLI, GCE SDK and Ansible built on a minimal Google Wheezy.

#### Why:

There are existing images for each of these tools in isolation, but none that combine them. At the same time, the best or at least most notable image for each depend on varying baseimages making the task of combining them at least on par with devising a new build of my own.

<br>

#### Pull:

```docker pull ozzyjohnson/wheezy-cloudtools```

<br>

#### Prepare:

At minimum, the ```/.boto``` (file) and ```/.gce``` (dir) mounts should be prepared with credentials corresponding to an IAM User and Service Account respectively. With this done, Ansible playbooks targetting either platform can be run as a ```local_action``` against a container generated from this image.

**/.boto**

	[Credentials]
	aws_access_key_id = <your_access_key_here>
	aws_secret_access_key = <your_secret_key_here>

If you aren't familiar with AWS access keys, reference my quick guide to [Creating an IAM user](http://ozzyjohnson.github.io/aws10/#Creating-an-IAM-User).

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

<br>

#### Name:

Create a set of volumes for export to future containers with the convenience of ```--volumes-from``` in place a list of mounts. 

	docker run \
	  --name cloudtools-auth \
	  -v ~/data:/data \
	  -v ~/.gce:/.gce \
	  -v ~/.boto:/.boto \
	  -it wheezy-cloudtools

<br>

#### Run:

Once configured, this image can be run interactively or executable style.

**Interactive:**

 	docker run \
	  --volumes-from cloudtools-auth \
	  -it --rm wheezy-cloudtools 

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
