variable eksCommonConfig{
   type = map
   default = {
     vpcCidr = "192.168.0.0/16"
     sshPublicKeyFile = "/root/.ssh/id_rsa.pub"
     natGwAZ = "us-west-2a"
   }
}

variable eksPublicSubnets{
    type = map
    default = {
      us-west-2a = "192.168.0.0/19"
      us-west-2b = "192.168.32.0/19"
      us-west-2c = "192.168.64.0/19"
    }
}

variable eksPrivateSubnets{
    type = map
    default = {
      us-west-2a = "192.168.96.0/19"
      us-west-2b = "192.168.128.0/19"
      us-west-2c = "192.168.192.0/19"
    }
}

variable eksClusterInfo{
   type = map 
   default = {
     name = "Assignment"
     kubernetesNetworkConfig = "10.100.0.0/16"
   }
}

variable eksClusterNodeGroupInfo {
   type = map
   default = {
     name = "assignmentNodeGroup"
     ami_type = "AL2_x86_64"
     capacity_type = "ON_DEMAND"
     instance_types = "t3.medium"
     disk_size = 20
   }
}

variable eksClusterNodeGroupScalingInfo{
   type = map
   default = {
     desired_size = 2
     max_size     = 4
     min_size     = 2
   }
}

variable rdsInfo{
   type = map
   default = {
     useRDSInstance = true
     allocated_storage    = 100
     engine               = "mariadb"
     engine_version       = "10.4.13"
     parameter_group_name = "default.mariadb10.4"
     instance_class       = "db.t3.micro"
     name                 = "notejam"
     username             = "admin"
     password             = "CatchMeIfYouCan"
     skip_final_snapshot  = true
     multi_az             = true
     port                 = 3306
     max_allocated_storage= 1024
     iops                 = 3000
   }
}
