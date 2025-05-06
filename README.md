# runp - Navigate Your Projects Quickly

`runp` is a command-line tool designed to speed up navigation between your projects. It allows you to define a base directory and then quickly "jump" to subdirectories within it using short names.

## Features

* **Set a Base Directory:** Configure a central location where your projects reside.
* **Quick Navigation:** Use short names to print the full path of subdirectories within the base directory.
* **`cd` Integration:** Easily integrate with your shell's `cd` command to quickly change directories.
* **Ignore Directories:** Configure a list of directories to be ignored when listing subdirectories.
* **Help Information:** Get usage instructions with the `--help` option.

## Compilation

This project is written in C++ and requires a C++ compiler (like g++) and the `filesystem` library (available in C++17 and later).

To compile `runp`, open your terminal in the project directory and run the following command:

`make` and `sudo make install`

### Manually add the content of the following file to your `~/.bashrc` file:

You can find the content to add here: [add_to_bashrc.txt](add_to_bashrc.txt)

after adding run the command `source ~/.bashrc`



## Running
### Usage:
`runp [options] [directory]`

#### Options:

- `--use [path]` : Set the base directory to [path]. If no path is provided, it defaults to the current working directory. This setting is saved in ~/.runpconfig.
- `--exclude <dir>`: Add `<dir>` to the list of ignored directories in the configuration.
- `--help` : Show this help message.
#### Without Options:

- `runp`: Lists the subdirectories within the configured base directory.
- `runp <subdir>`: Prints the full path to the `<subdir>` within the configured base directory.


## Test
Run `bats script_test.sh` inside the tests directory


## License

Distributed under the terms of the [LICENSE.txt](./LICENSE.txt) file.
