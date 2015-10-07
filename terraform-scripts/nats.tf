# Based on RobR's cf-docker-registry.tf at 
# https://github.com/hpcloud/cf-docker-registry/blob/master/cf-docker-registry.tf

# minimum terraform script to create an instance on hpcloud and provision

variable "os_user" {
    description = "${var.cloud_username}"
}

variable "os_password" {
    description = "${var.cloud_password}"
}

provider "openstack" {

}

resource "openstack_networking_floatingip_v2" "nats-poc-fip" {
    pool = "Ext-Net"
}

resource "openstack_compute_instance_v2" "nats-poc" {
    name = "nats-poc"
    flavor_id = "102"
    key_pair = "ericp01"
    image_id = "564be9dd-5a06-4a26-ba50-9453f972e483"  #*
    # image name: "Ubuntu Server 14.04.1 LTS (amd64 20150706) - Partner Image"
    floating_ip = "${openstack_networking_floatingip_v2.nats-poc-fip.address}" #*
    network { 
         uuid = "f52350cd-6bb8-4869-858d-f76517a52d45"  #*
    } 

    connection {
          host = "${openstack_networking_floatingip_v2.nats-poc-fip.address}"
          user = "${var.runtime_username:hcf}"
          key_file = "${var.key_file}"
    }
    
    provisioner "remote-exec" {
        inline = [
            "sudo apt-get install -y wget",
    	    "wget -qO- https://get.docker.com | sh",
	    "docker pull morspin/fibo"  # placeholder for a nats docker image
        ]
    }
}
