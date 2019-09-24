#!/bin/bash --posix
# -*- coding:utf-8 -*-

# === Coding shell scripting Memo ==============================================
# ${<name>#<pattern>} :: matching delete with shortest by forword.
# ${<name>##<pattern>} :: matching delete with longest by forword.
# ${<name>%<pattern>} :: matching delete with shortest by backword.
# ${<name>%%<pattern>} :: mathing delete with longest by backword.
# ${<name>/<before>/<after>} :: replace only first matching.
# ${<name>//<before>/<after>} :: replace all matching.
# ${<name>:-<value>} :: if no yet set value, return value.
# ${<name>:=<value>} :: if no yet set value, return value and set.

# ". <shell script>" is to keep current shell and take over environment.

# === Initialize shell environment =============================================
set -u                        # Just stop undefined values.
set -e                        # Just stop error.
set -x                        # Debug running command.

umask 0022
export LC_ALL=C
export LANG=C
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:${PATH+:}${PATH-}"
type command >/dev/null 2>&1 && type getconf >/dev/null 2>&1 &&
export PATH="$(command -p getconf PATH):${PATH}"
export UNIX_STD=2003          # to make HP-UX conform to POSIX

# === Define the functions for printing usage and error message ================
usage_and_exit(){
    cat <<-"    USAGE" 1>&2
    epubgen.sh is .

    Usage   : epubgen.sh [options] <directory>
    Options :
        -h |--help |--version
            This help.
        -i |--init
            Initialize <directory>.
        -t |--tool <epubcheck.jar>
            EPUB check by tool.
    Version : 2019-09-23_15:15:44 0.01
    LICENSE : CC0
              This is a public-domain software (CC0). It means that
              all of the people can use this for any purposes with no
              restrictions at all. By the way, We are fed up with the
              side effects which are brought about by the major licenses.
    Author  : 2019 TD
    USAGE

    exit 1
}

error_exit() {
    ${2+:} false && echo "${0##*/}: $2" 1>&2

    exit "$1"
}

# === Initialize parameters ====================================================
# Detect home directory of this app. and define more
#Homedir="$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d.."; pwd)"
#PATH="$Homedir/<Add Dir>:$PATH" # for additional command

zzz='' # test value.
#. "$Homedir/<shell script config-file.>"        # configration value.

Mode='NORMAL'
Dir=''
Tool=''

NAV_TXT='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
  <head>
    <title>Nav</title>
  </head>
  <body>
    <nav epub:type="toc">
      <h1>Nav</h1>
      <ol>
        <li><a href="chap1.xhtml">Chap1</a></li>
      </ol>
    </nav>

    <nav epub:type="landmarks" hidden="">
      <h1>Guide</h1>
      <ol>
        <li><a epub:type="cover" href="cover-front.xhtml">Cover</a></li>
        <li><a epub:type="toc" href="nav.xhtml">Nav</a></li>
        <li><a epub:type="bodymatter" href=".xhtml">Main</a></li>
      </ol>
    </nav>
  </body>
</html>
'

BOOK_TXT='<?xml version="1.0" encoding="UTF-8"?>
<package unique-identifier="pub-id" version="3.0" xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="pub-id">urn:uuid:c5929f72-b2e7-4104-b353-012199fc1e14</dc:identifier>
    <dc:title>MINIMUM SAMPLE</dc:title>
    <dc:language>ja-JP</dc:language>
    <meta property="dcterms:modified">2019-09-23T12:00:00Z</meta>
  </metadata>

  <manifest>
    <item id="cover-front" href="./xhtmls/cover-front.xhtml" media-type="application/xhtml+xml" properties="svg" />
    <item id="nav" href="./xhtmls/nav.xhtml" properties="nav" media-type="application/xhtml+xml" />
    <item id="" href="./xhtmls/.xhtml" media-type="application/xhtml+xml" />
    <item id="cover-back" href="./xhtmls/cover-back.xhtml" media-type="application/xhtml+xml" properties="svg" />

    <item id="img-cover-front" href="./images/cover-front.jpg" properties="cover-image" media-type="image/jpeg" />
    <item id="img-" href="./images/.png" media-type="image/png" />
    <item id="img-cover-back" href="./images/cover-back.jpg" media-type="image/jpeg" />
  </manifest>

  <spine page-progression-direction="rtl">
    <itemref idref="cover-front" />
    <itemref idref="nav" />
    <itemref idref="" />
    <itemref idref="cover-back" />
  </spine>
</package>
'

CONTAINER_TXT='<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="book.opf" media-type="application/oebps-package+xml" />
  </rootfiles>
</container>
'

XHTML_TXT='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title></title>
  </head>
  <body>
    <p>paragraph.</p>
  </body>
</html>
'

XHTML_COVER_FRONT_TXT='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html
   xmlns="http://www.w3.org/1999/xhtml"
   xmlns:epub="http://www.idpf.org/2007/ops"
   xml:lang="ja"
   >
  <head>
    <title>Cover</title>
    <meta name="viewport" content="width=1600, height=2650"/>
  </head>
  <body>
    <svg xmlns="http://www.w3.org/2000/svg" version="1.1"
         xmlns:xlink="http://www.w3.org/1999/xlink"
         width="100%" height="100%" viewBox="0 0 1600 2650">
      <image width="1600" height="2650" xlink:href="../images/cover-front.jpg"/>
    </svg>
  </body>
</html>
'

XHTML_COVER_BACK_TXT='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html
   xmlns="http://www.w3.org/1999/xhtml"
   xmlns:epub="http://www.idpf.org/2007/ops"
   xml:lang="ja"
   >
  <head>
    <title>Cover</title>
    <meta name="viewport" content="width=1600, height=2650"/>
  </head>
  <body>
    <svg xmlns="http://www.w3.org/2000/svg" version="1.1"
         xmlns:xlink="http://www.w3.org/1999/xlink"
         width="100%" height="100%" viewBox="0 0 1600 2650">
      <image width="1600" height="2650" xlink:href="../images/cover-back.jpg"/>
    </svg>
  </body>
</html>
'

# === Confirm that the required commands exist =================================
# --- cURL or Wget (exsample)
#if   type curl    >/dev/null 2>&1; then
#  CMD_CURL='curl'
#elif type wget    >/dev/null 2>&1; then
#  CMD_WGET='wget'
#else
#  error_exit 1 'No HTTP-GET/POST command found.'
#fi

# --- zip command check
if type zip >/dev/null 2>&1; then
    :
else
    error_exit 1 'No zip command found.'
fi

# === Print usage and exit if one of the help options is set ===================
case "$# ${1:-}" in
    '1 -h'|'1 --help'|'1 --version') usage_and_exit;;
esac

# === Read options =============================================================
while :; do
    case "${1:-}" in
        --zzz=*)
            zzz=$(printf '%s' "${1#--zzz=}" | tr -d '\n')
            echo "${zzz}"
            shift
            ;;
        -zzz)
            zzz=$(printf '%s' "${2:-}" | tr -d '\n')
            echo "${zzz}"
            shift 2
            ;;
        --init|-i)
            Mode='INIT'
            shift
            ;;
        --tool|-t)
            Tool=$(printf '%s' "${2:-}" | tr -d '\n')
            shift 2
            ;;
        --|-)
            break
            ;;
        --*|-*)
            error_exit 1 'Invalid option'
            ;;
        *)
            break
            ;;
    esac
done

# === Require parameters check =================================================
#printf '%s\n' "${zzz}" | grep -Eq '^$|^-?[0-9.]+,-?[0-9.]+$' || {
#  error_exit 1 'Invalid -l,--location option'
#}

# === Last parameter ===========================================================
#case $# in
#  0) <input>=$(cat -)
#     ;;
#  1) case "${1:-}" in
#       '--') usage_and_exit;;
#        '-') <input>=$(cat -)    ;;
#          *) <input>=$1          ;;
#     esac
#     ;;
#  *) case "$1" in '--') shift;; esac
#     <input>="$*"
#     ;;
#esac                         # Escape 0x0A to 0x1E

case $# in
    0)
        error_exit 1 'Undifine Directory.'
        ;;
    1)
        Dir=$(printf '%s' "${1%/*}" | tr -d '\n')
        if [ -e "${Dir}" ] ; then
            :
        else
            error_exit 1 'No Exsist Directory.'
        fi
        ;;
    *)
        error_exit 1 'Too Many Args.'
        ;;
esac

# === Define funcitons =========================================================
initialize() {
    Ret=0

    if [ ! -e "${Dir}/mimetype" ]; then
        printf '%s' "application/epub+zip" > "${Dir}/mimetype"
    fi

    if [ ! -e "${Dir}/book.opf" ]; then
        printf '%s' "${BOOK_TXT}" > "${Dir}/book.opf"
    fi

    if [ ! -e "${Dir}/META-INF/" ]; then
        mkdir "${Dir}/META-INF/"
    fi

    if [ ! -e "${Dir}/META-INF/container.xml" ]; then
        printf '%s' "${CONTAINER_TXT}" > "${Dir}/META-INF/container.xml"
    fi

    if [ ! -e "${Dir}/images/" ]; then
        mkdir "${Dir}/images/"
    fi

    if [ ! -e "${Dir}/xhtmls/" ]; then
        mkdir "${Dir}/xhtmls/"
    fi

    if [ ! -e "${Dir}/xhtmls/nav.xhtml" ]; then
        printf '%s' "${NAV_TXT}" > "${Dir}/nav.xhtml"
    fi

    if [ ! -e "${Dir}/xhtmls/cover-front.xhtml" ]; then
        printf '%s' "${XHTML_COVER_FRONT_TXT}" > "${Dir}/cover-front.xhtml"
    fi

    if [ ! -e "${Dir}/xhtmls/cover-back.xhtml" ]; then
        printf '%s' "${XHTML_COVER_BACK_TXT}" > "${Dir}/cover-back.xhtml"
    fi

    if [ ! -e "${Dir}/styles/" ]; then
        mkdir "${Dir}/styles/"
    fi

    if [ ! -e "${Dir}/publish/" ]; then
        mkdir "${Dir}/publish/"
        printf '%s' "${XHTML_TXT}" > "${Dir}/publish/template-contents.xhtml"
        # printf '%s' "${CSS_TXT}" > "${Dir}/publish/template-css.css"
    fi

    return ${Ret}
}

generate() {
    if [ -e "publish/generate.epub" ]; then
        rm "publish/generate.epub"
    fi

    zip -X0 "publish/generate.epub" "mimetype"
    zip -r9 "publish/generate.epub" "book.opf"
    zip -r9 "publish/generate.epub" "META-INF/" -i "*.xml"
    zip -r9 "publish/generate.epub" "xhtmls/" -i "*.xhtml"
    zip -r9 "publish/generate.epub" "images/" -i "*.*"
#    zip -r9 "publish/generate.epub" "styles/" -i "*.css"

    if [ -e "others/" ]; then
        zip -r9 "publish/generate.epub" "others/*" -i "*.*"
    fi

    return 0
}

# === Main routine =============================================================
case ${Mode} in
    INIT)
        initialize
        ;;
    NORMAL)
        initialize
        (cd "${Dir}"; generate)

        if [ -e "${Tool}" ]; then
            if type java >/dev/null 2>&1; then
                java -jar "${Tool}" "${Dir}/publish/generate.epub"
            fi
        fi
        ;;
    *)
        error_exit 1 'No Action.'
        ;;
esac

# === End shell script =========================================================
exit 0

