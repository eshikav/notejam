resource "aws_vpc" "eksVPC" {
  cidr_block = var.eksCommonConfig.vpcCidr
  instance_tenancy = "default"
  tags = {
    Name = "AssignmentVPC"
  }
}

resource "aws_internet_gateway" "eksIgw" {
    vpc_id = aws_vpc.eksVPC.id
}

resource "aws_nat_gateway" "eksPrivateSubnetNatGw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = lookup(aws_subnet.eksPublicSubnets, var.eksCommonConfig.natGwAZ).id
}

resource "aws_eip" "nat" {
}

resource "aws_subnet" "eksPublicSubnets" {
  for_each = var.eksPublicSubnets
  vpc_id     = aws_vpc.eksVPC.id
  cidr_block = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = "eksSubnet-${each.key}"
    az = each.key
    public = true
    environment = "assignment"
    "kubernetes.io/cluster/Assignment" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "eksPrivateSubnets" {
  for_each = var.eksPrivateSubnets
  vpc_id     = aws_vpc.eksVPC.id
  cidr_block = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = "eksPrivateSubnet-${each.key}"
    az = each.key
    private = true
    environment = "assignment"
    "kubernetes.io/cluster/Assignment" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table" "eksClusterRoutingTable" {
    vpc_id = aws_vpc.eksVPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eksIgw.id
    }

}

resource "aws_route_table" "eksNodeGroupRoutingTable" {
    vpc_id = aws_vpc.eksVPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.eksPrivateSubnetNatGw.id
    }

}

resource "aws_route_table_association" "eksClusterRTAssociation"{
    for_each = var.eksPublicSubnets
    subnet_id = lookup(aws_subnet.eksPublicSubnets, each.key).id
    route_table_id = aws_route_table.eksClusterRoutingTable.id
}

resource "aws_route_table_association" "eksNodeGroupRTAssociation"{
    for_each = var.eksPrivateSubnets
    subnet_id = lookup(aws_subnet.eksPrivateSubnets, each.key).id
    route_table_id = aws_route_table.eksNodeGroupRoutingTable.id
}

resource "aws_security_group" "eksSecGroup"{
  name        = "eksSecGGroup"
  description = "EKS Security Group"
  vpc_id      = aws_vpc.eksVPC.id
  tags = {
   Name = "eksSecGroup"
  }
}

resource "aws_security_group_rule" "eksIngress" {
    type =  "ingress"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    security_group_id = aws_security_group.eksSecGroup.id
    self = true
}

resource "aws_security_group_rule" "eksEgress" {
    type =  "egress"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    security_group_id = aws_security_group.eksSecGroup.id
    cidr_blocks  = ["0.0.0.0/0"]
}
