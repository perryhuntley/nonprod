module "map" {
  source = "git@git.signintra.com:dct/azure/terraform-subscription-static.git"
}

module "vm" {
  
  # If specific version is needed, please update with version suffix, for example "?ref=1.5.1" OR "?ref=feature/xxx"
  source = "git::git@git.signintra.com:dct/azure/terraform-azurerm-vm.git"
  vm_count = 1

  # VM CONFIG
  
  lin_machine             = true
  resource_group_location = data.azurerm_resource_group.rg_nonprod.location
  resource_group_name     = data.azurerm_resource_group.rg_nonprod.name
  location_code           = module.map.region_map[var.location]
  # project_name            = "${var.topic}-${var.application}"
  vm_name                 = "${var.topic}-${var.stage}-vm-${var.application}-${module.map.region_map[var.location]}"
  computer_name           = "${var.topic}-${var.stage}-vm-${var.application}-${module.map.region_map[var.location]}"
  
  key_vault_password      = local.key_vault_password

  subnet_ids = [
    data.azurerm_subnet.app_sub.id,
  ]

  zones = [  #add more if there is more than one VM.
    2,
  ]

  network_security_group_id = module.nsg.network_security_group_id

  vm_size                 = var.vm_sizes["2vCPU-8GB"]
  storage_os_disk_type    = "StandardSSD_LRS" # typical choice for nonprod"
  storage_os_disk_size_gb = 64

  

  
  backup_policy_id = "${local.subscription_id_full}/resourceGroups/${local.env_prefix}-rg-spoke-${local.loc}/providers/Microsoft.RecoveryServices/vaults/${local.env_prefix}-rsv-${local.loc}/backupPolicies/${var.backup_plans["ShortTerm(1month)-03:00-06:00"]}-${upper(module.map.region_map[var.location])}"

  Backupwindows = ["${var.backup_plans["ShortTerm(1month)-03:00-06:00"]}-${upper(module.map.region_map[var.location])}"]

  ## OS CONFIG

  
  source_image_id = "dbschenker-rhel8/versions/2022.12.26" #np for win16, win19, ubuntu18, ubuntu20, rhel7, rhel8

  
  patching_schedule = "Linux-NonProd-3sun-11_00-14_00-${upper(module.map.region_map[var.location])}"

  topic         = var.topic
  application   = var.application
  heritage      = var.heritage
  contact       = var.contact
  costcenter    = var.costcenter
  executionitem = var.executionitem
  stage         = var.stage
  operatedby    = var.operatedby
  # task          =

  # comment below line if Grafana dashboard is not required
  grafana_enabled          = true
  # uncomment below line if Grafana Kits(folder, notification channel, team) are required
  grafana_kits             = true
  # uncomment below line and change the value if overwrite default dashboard user is required
  # grafana_dashboard_users = ["saint.wang@dbschenker.com"]
  # uncomment below line and change the value if overwrite default alert receive user is required
  # grafana_alert_users     = "saint.wang@dbschenker.com;min.m.zhu@dbschenker.com"
  # uncomment below line and change the value if additional tag is required
  # grafana_tag             = "test"
  # uncomment below line and change the value if you know where to put the dashboard
  # grafana_folder_id        = 1166
  # uncomment below line and change the value if you know where to put the alerts
  # grafana_notification_uid = "gjH9N9gVk"


  chefclient_enabled     = true
  chef_validation_key    = data.azurerm_key_vault_secret.chef_validation_key.value
  chef_policy_name       = "azure-basic"
  chef_policy_group      = "nonprod"
}


