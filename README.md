# General information

**ParaPF** (para print function) is my attempt to develop a function that would be similar to `printf`.

**ParaPF** supports following format specifiers:

| Specifier | Data type         |
|-----------|-------------------|
| %d, %i    | int (decimal)     |
| %x, %X    | int (hexadecimal) |
| %o        | octal             |
| %b        | binary            |
| %c        | char              |
| %s        | array of chars    |
| %%        | percent character |

# How to bild

To build and run project:
```
$ make
$ make run
```

It you want to clean all objective files:
```
$ make clean
```

# Output example

![Output](https://github.com/KetchuppOfficial/ParaPF/blob/master/Output_Example.png)
