terraform {
  backend "local" {
    path = "/tmp/terraform/workspace/terraform.tfstate"
  }
  
}


provider "aws" {
  region = "us-east-1"
  
}

resource "aws_instance" "backend" {
  ami                    = "ami-04763b3055de4860b"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.sg-id}"]

}

resource "null_resource" "remote-exec-1" {
    connection {
    user        = "ubuntu"
    type        = "ssh"
    private_key = "${file(var.pvt_key)}"
    host        = "${aws_instance.backend.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install python sshpass -y",
    ]
  }
}

resource "null_resource" "ansible-main" {
provisioner "local-exec" {
  command = <<EOT
        sleep 100;
        export ANSIBLE_HOST_KEY_CHECKING=False;
        ansible-playbook -e  sshKey=${var.pvt_key} ./ansible/setup-backend.yaml -u ubuntu -v
    EOT
}
}
