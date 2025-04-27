BIN_DIR=/usr/local/bin

all:
	g++ -O2 -std=c++17 -o runp-bin src/main.cpp

install: all
	install -Dm755 runp-bin $(BIN_DIR)/runp-bin
	install -Dm755 scripts/runp.sh $(BIN_DIR)/runp.sh

uninstall:
	rm -f $(BIN_DIR)/runp-bin
	rm -f $(BIN_DIR)/runp.sh

clean:
	rm -f runp-bin
