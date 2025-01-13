resource "oci_identity_compartment" "TF_DEMOCompartment" {
  provider = oci.homeregion
  name = "tf_demo"
  description = "Terraform Demo Compartment"
  compartment_id = var.compartment_ocid

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

