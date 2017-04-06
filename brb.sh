#!/bin/bash
# Binlogic Replica Builder
# Santiago Lertora - Binlogic Inc. 2015
#curso ale


MASTERUSER="user"
MASTERPASS="pass"
MASTERHOST=ip"

SLAVEUSER="root"
SLAVEPASS="tester"
BKPDIR="backup"
#cd mydumper
echo "-----------------------------------------------"
echo "-----------------------------------------------"
echo "-------INICIANDO COPIA DE DATOS DEL MASTER-----"
echo "-----------------------------------------------"

time mydumper -u $MASTERUSER -p $MASTERPASS --host $MASTERHOST -r 4000000  -t 8 -e -v 3  --regex '^(?!(mysql|sys|performance_schema))' -c -o $BKPDIR &> $BKPDIR/mydumper.log

echo "Copia Finalizada"
echo "-----------------------------------------------"
echo "--------------Parando Replica------------------"
echo "-----------------------------------------------"
mysql -u$SLAVEUSER -p$SLAVEPASS-e 'stop slave; reset slave all;'
echo " Iniciando Restore"
time myloader -u $SLAVEUSER -p $SLAVEPASS -t 8 -q 10 -v 3 -o -d  $BKPDIR
echo "Restore Finalizado"
cd $BKPDIR

echo "-------------------------------------------------------"
echo " LEYENDO METADATA"c
echo " Iniciando Esclavo"

POS=$(awk '/Pos:/{print $NF}' metadata)
LOG=$(awk '/Log:/{print $NF}' metadata)
read -a pos <<<$POS
read -a log <<<$LOG
LOG1=${log[0]}
POS1=${pos[0]}
mysql -u$SLAVEUSER -p$SLAVEPASS -e "CHANGE MASTER TO MASTER_HOST='$MASTERHOST', MASTER_USER='$MASTERUSER', MASTER_PASSWORD='$MASTERPASS', MASTER_LOG_FILE='$LOG1', MASTER_LOG_POS=$POS1 ;start slave; SHOW SLAVE STATUS\G";
# Simple Slack Integration
/usr/bin/curl \
    -X POST \
    -s \
    --data-urlencode "payload={ \
        \"channel\": \"#general\", \
        \"username\": \"Replica Builder\", \
        \"pretext\": \"servername | $MONIT_DATE\", \
        \"color\": \"danger\", \
        \"icon_emoji\": \":ghost:\", \
        \"text\": \"$SLAVEHOST - $REPLICA_FINALIZADA\" \
    }" \
#Insert your incoming webhook here
