#!/bin/bash
#
# DEBUG
set -x

LOG="/root/backup/Export_VM_$(date +%Y%m%d).log"
DESTINATARI_MAIL="mail add"

TAG_DA_BACKUPPARE=BACKUP_DA_SAN

function manda_mail () {
                cat $LOG | mail -s "XenDev Export VM - $MESSAGGIO" $DESTINATARI_MAIL
}

function verifica_esecuzione () {
        if [ $? -gt 0 ]; then 
                MESSAGGIO=$1
                manda_mail
                exit 1
        fi

        find /mnt/backup/ -name $VM_IERI* -daystart -atime 1 -delete

}

function backup_per_host () {

        # Estraggo la lista delle VM con tag_da_backuppare 

        xe vm-list tags=$TAG_DA_BACKUPPARE | grep name-label | awk '{ print $4 }' > lista_vm

        # Per ogni VM eseguo la procedura di backup
        for VM_NAME in $(cat lista_vm); do
        
                MOUNT=$(mount | grep /mnt | wc -l)

                if [ $MOUNT = 1 ]
                        # Nome della VirtualMachine

                                VM_IERI=$(echo $VM_NAME | cut -d _ -f1)
                
                                echo -e "\n$(date) -- Inizio Backup ${VM_IERI}" >> $LOG
              

                        # Creo la VM a partire dallo snapshot tracciando la data e impostando il tag BACKUP"
        
                                echo "  $(date) -- Inizio Export della VM" >> $LOG
                                xe vm-export vm=$VM_NAME filename="/mnt/backup/$VM_NAME$(date +%Y%m%d).ovf"  2>> $LOG
                        
                        # Se l'operazione è andata bene proseguo, altrimenti esco e avviso
                
                                verifica_esecuzione "Problema creazione VM ${VM_IERI}"
                                echo "  $(date) -- Fine Export della VM (creato ${VM_IERI})" >> $LOG

                        else

                                echo "NFS non presente" | mail -s "TASSI XenS Export VM KO" $DESTINATARI

                                exit 1
                        fi

        done

}

# MAIN
 > $LOG
 backup_per_host
 MESSAGGIO="OK"
 manda_mail
(END) 

                        then    
                        
