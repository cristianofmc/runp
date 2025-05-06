BIN_NAME=runp
BIN_DIR=/usr/local/bin

all:
	g++ -O2 -std=c++17 -o $(BIN_NAME) src/main.cpp

install: all
	install -Dm755 $(BIN_NAME) $(BIN_DIR)/$(BIN_NAME)
	rm -f $(BIN_DIR)/runp-bin

uninstall:
	rm -f $(BIN_DIR)/$(BIN_NAME)
	@echo "Removed $(BIN_NAME) from $(BIN_DIR)"

clean:
	rm -f $(BIN_NAME)


compile_install_script:
	g++ -O2 -std=c++17 -o $(INSTALL_SCRIPT_BIN) $(INSTALL_SCRIPT_CPP)
