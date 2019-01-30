DOCKER_IMAGE_NAME:=mysql-database-transfer

build: ; @\
        clear; \
        echo "[Building MySQL Database Transfer Image...]"; \
        echo "";\
        docker build -t ${DOCKER_IMAGE_NAME} .

run: ; @\
        clear; \
        echo "[Running MySQL Database Transfer...]"; \
        echo "";\
        docker run --rm --env-file env.list ${DOCKER_IMAGE_NAME}
