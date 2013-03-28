update vms set vm_config=concat(vm_config,"\nconfig_filename = '/var/cache/convirt/vm_configs/",name,"'") where vm_config not like '%config_filename%';

