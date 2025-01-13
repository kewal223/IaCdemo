# VCN
resource "oci_core_virtual_network" "TFDemoVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "TFDemoVCN"
  compartment_id = oci_identity_compartment.TF_DEMOCompartment.id
  display_name   = "TFDemoVCN"
}

# DHCP Options
resource "oci_core_dhcp_options" "TFDemoDhcpOptions1" {
  compartment_id = oci_identity_compartment.TF_DEMOCompartment.id
  vcn_id         = oci_core_virtual_network.TFDemoVCN.id
  display_name   = "TFDemoDHCPOptions1"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["tfdemo.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "TFDemoInternetGateway" {
  compartment_id = oci_identity_compartment.TF_DEMOCompartment.id
  display_name   = "TFDemoInternetGateway"
  vcn_id         = oci_core_virtual_network.TFDemoVCN.id
}

# Route Table
resource "oci_core_route_table" "TFDemoRouteTableViaIGW" {
  compartment_id = oci_identity_compartment.TF_DEMOCompartment.id
  vcn_id         = oci_core_virtual_network.TFDemoVCN.id
  display_name   = "TFDemoRouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.TFDemoInternetGateway.id
  }
}

# Security List
resource "oci_core_security_list" "TFDemoSecurityList" {
  compartment_id = oci_identity_compartment.TF_DEMOCompartment.id
  display_name   = "TFDemoSecurityList"
  vcn_id         = oci_core_virtual_network.TFDemoVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.service_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR
  }
}

# Subnet
resource "oci_core_subnet" "TFDemoWebSubnet" {
  cidr_block        = var.Subnet-CIDR
  display_name      = "TFDemoWebSubnet"
  dns_label         = "TFDemoN1"
  compartment_id    = oci_identity_compartment.TF_DEMOCompartment.id
  vcn_id            = oci_core_virtual_network.TFDemoVCN.id
  route_table_id    = oci_core_route_table.TFDemoRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.TFDemoDhcpOptions1.id
  security_list_ids = [oci_core_security_list.TFDemoSecurityList.id]
}
