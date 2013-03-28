/*
*   ConVirt   -  Copyright (c) 2008 Convirture Corp.
*   ======

* ConVirt is a Virtualization management tool with a graphical user
* interface that allows for performing the standard set of VM operations
* (start, stop, pause, kill, shutdown, reboot, snapshot, etc...). It
* also attempts to simplify various aspects of VM lifecycle management.


* This software is subject to the GNU General Public License, Version 2 (GPLv2)
* and for details, please consult it at:

* http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
* author : Jd <jd_jedi@users.sourceforge.net>
*/
/*
 * MODES--EDIT_VM_INFO,EDIT_VM_CONFIG
 * panel1--Disks
 * panel2--Networks
 * panel3--BootParams
 * panel4--Miscellaneous
 * panel5--Provisioning
 */
//var convirt={};
convirt.PlatformUIHelper=function(platform,mode){
    this.mode=mode;
    this.platform=platform;
    var xen_in_memory=new Array('vmname','panel2','panel3','panel4'); 
    var xen_on_disk=new Array();
    var kvm_in_memory=new Array('memory','vcpu','boot_loader','boot_check','panel1','panel2','panel3','panel4');
    var kvm_on_disk=new Array('boot_loader','boot_check');
    this.getComponentsToDisable=function(){
        if(this.platform==='kvm'){
            if(this.mode==='EDIT_VM_INFO'){
                return kvm_in_memory;
            }else if(this.mode==='EDIT_VM_CONFIG'){
                return kvm_on_disk;
            }
        }else if(this.platform==='xen'){
            if(this.mode==='EDIT_VM_INFO'){
                return xen_in_memory;
            }else if(this.mode==='EDIT_VM_CONFIG'){
                return xen_on_disk;
            }
        }
        return (new Array());
    }
}
