## SG ##
module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins_sg"
  description = "Security group for Jenkins server"

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "Jenkins Instance"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3a.small"
  key_name                    = "develeap"
  monitoring                  = true
  vpc_security_group_ids      = [module.vote_service_sg.security_group_id]
  iam_instance_profile        = "SSMInstanceProfile"
  user_data                   = file("jenkins-install.sh")
  associate_public_ip_address = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}