
#--- Execute on Master-- Grants for MyDumper Process
GRANT USAGE ON *.* TO 'dump'@'%' IDENTIFIED BY 'slavepass';
GRANT SELECT, LOCK TABLES ON `mysql`.* TO 'dump'@'%';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON `myschema`.* TO 'dump'@'%';

MASTERIP=10.0.0.0

#----------MyLoader Vars---------------

#----------Information and credentials to access the master as Slave User
USER="amazonreplica"
PASS="737g0t3am"
HOST=$MASTERIP
IGONREDB="performance_schema | mysql"

cd mydumper
echo "------------------------------"
echo "------------------------------"
echo "INICIANDO COPIA DE DATOS DEL MASTER"
time ./mydumper -u amazon -p 737g0t3am --host $IPMASTER -r 4000000  -t 8 -e -v 3  --regex '^(?!($IGNOREDB))' -c -o ~/backup_dir &> ~/backup_dir/mydumper.log
echo "Copia Finalizada"
echo " Iniciando Restore"
time ./myloader -u root -p letgo -t 8 -q 500 -v 3 -o -d  ~/backup_dir
echo "Restore Finalizado"
cd /home/santiago.lertora/backup_letgo

echo "-------------------------------------------------------"
echo " LEYENDO METADATA"
echo " Iniciando Esclavo"

POS=$(awk '/Pos:/{print $NF}' metadata)
LOG=$(awk '/Log:/{print $NF}' metadata)
read -a pos <<<$POS
read -a log <<<$LOG
LOG1=${log[0]}
POS1=${pos[0]}
mysql -uroot -pletgo -e 'CHANGE MASTER TO MASTER_HOST='$HOST', MASTER_USER='$USER', MASTER_PASSWORD='$PASS', MASTER_LOG_FILE='$LOG1', MASTER_LOG_POS=$POS1; start slave;'
mysql -uroot -pletgo -e 'show slave status\G'
