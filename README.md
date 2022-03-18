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

The other specifiers as well as the flags, precision, width and length field are not supported yet. I'm working on this.

# How to bild

To build and run project:
```
$ make
$ make run
```

If you want to clean all objective files:
```
$ make clean
```

# Output example

![Output](https://github.com/KetchuppOfficial/ParaPF/blob/master/Pictures/Output_Example.png)

# Error handling

Anything that not does not match standard syntax of `printf ()` from the standard library of C is identified as an error.

An example of an error report:

``` C
extern void ParaPF (const char *format_str, ...);

int main (void)
{
    ParaPF ("Hello, World!\n");
    ParaPF ("My name is ParaPF.\n");
    ParaPF ("I can handle errors just like that:\n");
    ParaPF ("%%%");
    
    return 0;
}
```

![Report](https://github.com/KetchuppOfficial/ParaPF/blob/master/Pictures/Error_Report.png)
