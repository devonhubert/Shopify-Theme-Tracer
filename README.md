# Shopify-Theme-Tracer
Easily map the tree structure of your Shopify Theme code!

Improvements and suggestions welcome!


## How to Use:
1) Download your Shopify theme code, and extract files to a folder
  Normal folder structure:

> templates/ (+ templates/customers/)

> sections/

> snippets/

> assets/

> config/

> layout/

> locales/

2) Place the 'map_theme.sh' file into the same directory as the folders listed above
3) Make sure the file is executable
Linux/Unix:
```$ sudo chmod a+x map_theme.sh```

4) Run script!
```$ ./map_theme.sh```
  (Use Windows Subsystem for Linux or Git Bash, etc. if using Windows)

## Options:
By default, the script assumes that templates/ is the top-level parent folder for the trace.
To specify a different target directory, add the directory name as the first argument!

Example:
```$ ./map_theme.sh sections/```
  
By default, the script outputs the tree structure to stdout, as well as a text file named "theme_code_map.txt"
You can additionally specify a different text file name as the second argument!

Example:
```$ ./map_theme.sh snippets/ my_outfile_file_name.txt```
