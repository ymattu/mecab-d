IMAGE=mecab-d
CONTAINER=rs

build:
        docker build -t $(IMAGE) .
run:
        docker run -it \
                -v /Users/ymattu/Desktop/R:/home/rstudio \
                -p 8787:8787 \
                -d \
                --name=$(CONTAINER) \
                $(IMAGE) /bin/bash
shell:
        docker exec -it $(CONTAINER) /bin/bash
clean: rm
        docker rmi $(IMAGE)
rm:
        docker rm -f $(CONTAINER)
rerun: rm run
stop:
        docker stop $(CONTAINER)
start:
        docker start $(CONTAINER)
restart: stop start
