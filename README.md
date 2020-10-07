# panel.docker

Working- 07-10-2020

Command: docker create --name Metabox_Panel -v /mb:/mb -v /var/run/docker.sock:/var/run/docker.sock -p 9999:9999 metaboxcloud/metabox.panel.docker:latest