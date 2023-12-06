module "svc_resource_group" {
  source = "git::ssh://git@code.siemens.com/siemens-fs/fs-cloud-infrastructure/core/modules/resource-group?ref=ft-sfs-test_rg"
  project_details = local.project_details 
  tags            = var.tags
  rg_details      = var.rg_details 
}

module "virtual_network" {
  depends_on = [module.svc_resource_group]
  source          = "git::ssh://git@code.siemens.com/siemens-fs/fs-cloud-infrastructure/core/modules/virtual-network?ref=ft-sfs-vnet" #virtual network module path
  project_details = local.project_details 
  tags            = var.tags
  vnet_details    = var.vnet_details    
  rg_details = module.svc_resource_group.resource_group
  
}

module "route_table" {
  depends_on = [module.virtual_network]
  source = "git::ssh://git@code.siemens.com/siemens-fs/fs-cloud-infrastructure/core/modules/route-table?ref=ft-sfs-route_table"
  project_details = local.project_details 
  tags            = var.tags
  route_table    = var.route_table 
  rg_details = module.svc_resource_group.resource_group
}

module "network_security_group" {
  depends_on = [module.svc_resource_group]
  source = "git::ssh://git@code.siemens.com/siemens-fs/fs-cloud-infrastructure/core/modules/network_security_group?ref=ft-sfs-nsg"
  project_details = local.project_details
  tags = var.tags
  nsg_details = var.nsg_details
  rg_details = module.svc_resource_group.resource_group
}

module "subnet" {
    depends_on = [module.virtual_network, module.route_table, module.network_security_group]
    source = "git::ssh://git@code.siemens.com/siemens-fs/fs-cloud-infrastructure/core/modules/subnet?ref=sfs-test-snetmodule"
    project_details = local.project_details
    tags = var.tags
    subnet_details = var.subnet_details
    rg_details = module.svc_resource_group.resource_group
    nsg_details = module.network_security_group.nsg
    rt_details = module.route_table.route_table
    vnet_details = module.virtual_network.vnet
}

module "route_table_entries" {
  depends_on = [module.route_table,  module.subnet]
  source = "git::ssh://git@code.siemens.com/siemens-fs/fs-cloud-infrastructure/core/modules/route-table?ref=route_entries"
  rg_details = module.svc_resource_group.resource_group
  rt_details = module.route_table.route_table
  route_entries = var.route_entries
  route_next_hop_address = var.route_next_hop_address
}

