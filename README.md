# Template-EPUB3

## Overview

## Requirement

- Linux
- zip (shell command.)
- [epubcheck](https://github.com/w3c/epubcheck/releases)

## Usage

### `$> epubgen.sh -i <Directory>`

The `$> epubgen.sh -i <Directory>` initialize <Directory> to publish EPUB3.
The structure of <Directory> is as follows.

```
<Directory>/ --- META-INF/ --- container.xml
              |
              |- images/
              |- styles/
              |- xhtmls/ --- nav.xhtml
              |           |- cover-front.xhtml
              |           -- cover-back.xhtml
              |
              |- publish/ --- template-contents.xhtml
              |
              |- book.opf
              -- mimetype
```

This action can not generate `<Directory>/images/cover-front.jpg` and
`<Directory>/images/cover-back.jpg`. The size of these images is
supposed 2560 x 1600.

### `$> epubgen.sh <Directory>`

The `$> epubgen.sh <Directory>` generate `<Directory>/publish/generate.epub`.
This action zip the following:

- mimetype.
- xml files in META-INF.
- book.opf.
- xhtml files in xhtmls.
- css files in styles.
- any files in images.

## Install

1. Download or Copy `epubgen.sh` to your machine.
2. Give the right of execution for `epubgen.sh`.
3. End.

## Licence

[UNLICNSE](https://unlicense.org/)

## Author

[ms-td](https://github.com/ms-td/)
