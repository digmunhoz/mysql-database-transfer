build: ; @\
        clear; \
        echo "[Building MySQL Database Transfer Image...]"; \
        echo "";\
        docker build -t teste .

run: ; @\
        clear; \
        echo "[Running MySQL Database Transfer Image...]"; \
        echo "";\
        docker run --rm --env-file env.list teste
