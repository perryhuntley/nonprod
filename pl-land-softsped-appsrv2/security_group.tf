module "nsg" {
  source              = "git::git@git.signintra.com:dct/azure/terraform-azurerm-nsg.git"
  location            = data.azurerm_resource_group.rg_nonprod.location
  resource_group_name = data.azurerm_resource_group.rg_nonprod.name
  security_group_name = "${var.topic}-${var.stage}-nsg-${var.application}-${module.map.region_map[var.location]}"

  custom_rules = [
    
    {
      name                                       = "AllowSSH"
      priority                                   = "121"
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      destination_port_range                     = "22"
      source_address_prefixes                    = "10.228.192.128/27, 10.228.137.32/32"
      
      destination_application_security_group_ids = [module.vm.asg]
    },
    {
      name                   = "BlockAny"
      priority               = "2000"
      direction              = "Inbound"
      access                 = "Deny"
      protocol               = "Tcp"
      source_port_ranges     = "*"
      destination_port_range = "*"
      description            = "BlockAny"
    },
  ]

  dynamic_rules = [
    
    {
      name                                       = "https_access"
      description                                = "https access"
      priority                                   = "105"
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      destination_port_range                     = "443"
      source_address_prefixes                    = ["10.0.0.0/8"]
      destination_application_security_group_ids = [module.vm.asg]
    },


{
      name                                       = "nrpe_prosiak.schenker.pl"
      description                                = "nrpe prosiak.schenker.pl"
      priority                                   = "106"
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      destination_port_range                     = "5666"
      source_address_prefixes                    = ["10.228.161.204/32"]
      destination_application_security_group_ids = [module.vm.asg]
    },

    {
      name                                       = "ftp_jenkins.schenker.pl"
      description                                = "ftp jenkins.schenker.pl"
      priority                                   = "107"
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      destination_port_range                     = "20,21"
      source_address_prefixes                    = ["10.228.196.225/32"]
      destination_application_security_group_ids = [module.vm.asg]
    },

{
      name                                       = "Adhoc_Rule1"
      description                                = "Adhoc_rule1"
      priority                                   = "108"
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      destination_port_range                     = "8080,9090"
      source_address_prefixes                    = ["10.0.0.0/8"]
      destination_application_security_group_ids = [module.vm.asg]
    },

    /*
    {
      name                                       = "AllowSQL"
      priority                                   = "126"
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      destination_port_range                     = "1433"
      source_address_prefixes                    = ["10.0.0.0/8"]
      destination_application_security_group_ids = [module.vm.asg]
    },
    */
  ]

  tags = local.tags
}
