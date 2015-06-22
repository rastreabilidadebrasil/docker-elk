# /bin/bash
sudo docker run -d -p 8080:80 -p 28778:28778 -p 28777:28777 -p 9200:9200  -v /mnt/data1:/data --name logstash rblabs/elk

