apt-get install openjdk-8-jdk -y
useradd -M -d /opt/nexus -s /bin/bash -r nexus
echo "nexus ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nexus
mkdir /opt/nexus
wget https://download.sonatype.com/nexus/3/nexus-3.63.0-01-unix.tar.gz
tar xzf nexus-3.29.2-02-unix.tar.gz -C /opt/nexus --strip-components=1
chown -R nexus:nexus /opt/nexus

content="-Xms1024m\n-Xmx1024m\n-XX:MaxDirectMemorySize=1024m\n-XX:LogFile=./sonatype-work/nexus3/log/jvm.log\n-XX:-OmitStackTraceInFastThrow\n-Djava.net.preferIPv4Stack=true\n-Dkaraf.home=.\n-Dkaraf.base=.\n-Dkaraf.etc=etc/karaf\n-Djava.util.logging.config.file=/etc/karaf/java.util.logging.properties\n-Dkaraf.data=./sonatype-work/nexus3\n-Dkaraf.log=./sonatype-work/nexus3/log\n-Djava.io.tmpdir=./sonatype-work/nexus3/tmp"
file_path="/opt/nexus/bin/nexus.vmoptions"
echo -e "$content" | sudo tee -a "$file_path" > /dev/null
rc_file="/opt/nexus/bin/nexus.rc"
rc_content='run_as_user="nexus"'
echo -e "$rc_content" | sudo tee -a "$rc_file" > /dev/null

sudo -u nexus /opt/nexus/bin/nexus start
