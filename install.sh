#!/bin/bash

curl -sSL https://paratonnerre-eskers.s3.us-west-2.amazonaws.com/uninstall.sh | sudo bash

mkdir -p /opt/paratonnerre_eskers/
chmod +x /opt/paratonnerre_eskers/

groupadd -r paratonnerre_eskers
useradd -g paratonnerre_eskers paratonnerre_eskers

for script in common.sh popup.sh shutdown.sh wholog.sh timestamp_now.sh
do 
    curl -sSLo /tmp/$script https://paratonnerre-eskers.s3.us-west-2.amazonaws.com/$script
    sudo install -m 755 /tmp/$script /opt/paratonnerre_eskers/$script
done

curl -sSLo /tmp/popup.sh.desktop https://paratonnerre-eskers.s3.us-west-2.amazonaws.com/popup.sh.desktop
if [[ -d /home/centos/ ]]; then
    mkdir -p /home/centos/.config/autostart
    cp /tmp/popup.sh.desktop /home/centos/.config/autostart/popup.sh.desktop
    chown centos /home/centos/.config/autostart/popup.sh.desktop
    chmod a+rwx /home/centos/.config/autostart/popup.sh.desktop
fi

mkdir -p /var/log/paratonnerre_eskers
touch /var/log/paratonnerre_eskers/shutdown.log
usermod --append --groups paratonnerre_eskers centos
chown -R paratonnerre_eskers:paratonnerre_eskers /var/log/paratonnerre_eskers
chmod -R ug+rwx /var/log/paratonnerre_eskers

sed -i '/paratonnerre_eskers/d' /etc/crontab
echo '* * * * * root /opt/paratonnerre_eskers/shutdown.sh >/dev/null' | tee -a /etc/crontab
echo '* * * * * root /opt/paratonnerre_eskers/wholog.sh' | tee -a /etc/crontab
echo '@reboot root /opt/paratonnerre_eskers/timestamp_now.sh' | tee -a /etc/crontab

curl -sSLo /tmp/paratonnerre_eskers_logrotate https://paratonnerre-eskers.s3.us-west-2.amazonaws.com/logrotate
sudo install -m 755 /tmp/paratonnerre_eskers_logrotate /etc/logrotate.d/paratonnerre_eskers

# add first timestamp for $UPTIME from now
. /opt/paratonnerre_eskers/common.sh
write_timestamp
