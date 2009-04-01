dnl Check for CURL Libraries
dnl CHECK_CURL(ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND])
dnl Sets:
dnl  CURL_CFLAGS
dnl  CURL_LIBS

CURL_CONFIG=""
CURL_CFLAGS=""
CURL_LIBS=""
CURL_MIN_VERSION="7.15.1"

AC_DEFUN([CHECK_CURL],
[dnl

AC_ARG_WITH(
    curl,
    [AC_HELP_STRING([--with-curl=PATH],[Path to curl prefix or config script])],
    [test_paths="${with_curl}"],
    [test_paths="/usr/local/libcurl /usr/local/curl /usr/local /opt/libcurl /opt/curl /opt /usr"])

AC_MSG_CHECKING([for libcurl config script])

for x in ${test_paths}; do
    dnl # Determine if the script was specified and use it directly
    if test ! -d "$x" -a -e "$x"; then
        CURL_CONFIG="`basename $x`"
        curl_path=`echo $x | sed "s/\/\?${CURL_CONFIG}\$//"`
        break
    fi

    dnl # Try known config script names/locations
    for CURL_CONFIG in curl-config; do
        if test -e "${x}/bin/${CURL_CONFIG}"; then
            curl_path="${x}/bin"
            break
        elif test -e "${x}/${CURL_CONFIG}"; then
            curl_path="${x}"
            break
        else
            curl_path=""
        fi
    done
    if test -n "$curl_path"; then
        break
    fi
done

if test -n "${curl_path}"; then
    CURL_CONFIG="${curl_path}/${CURL_CONFIG}"
    AC_MSG_RESULT([${CURL_CONFIG}])
    CURL_CFLAGS="`${CURL_CONFIG} --includes --cppflags --cflags`"
    if test "$verbose_output" -eq 1; then AC_MSG_NOTICE(curl CFLAGS: $CURL_CFLAGS); fi
    CURL_LIBS="`${CURL_CONFIG} --libs`"
    if test "$verbose_output" -eq 1; then AC_MSG_NOTICE(curl LIBS: $CURL_LIBS); fi
    CURL_VERSION="`${CURL_CONFIG} --version`"
    if test "$verbose_output" -eq 1; then AC_MSG_NOTICE(curl VERSION: $CURL_VERSION); fi
    CFLAGS=$save_CFLAGS
    LDFLAGS=$save_LDFLAGS

    dnl # Check version is ok
    AC_MSG_CHECKING([if libcurl is at least v${CURL_MIN_VERSION}])
    if ${CURL_CONFIG} --checkfor "${CURL_MIN_VERSION}" >/dev/null 2>&1; then
        AC_MSG_RESULT([yes])
    else
        AC_MSG_RESULT([no])
        AC_MSG_NOTICE([NOTE: curl library may be too old: $CURL_VERSION])
    fi

else
    AC_MSG_RESULT([no])
fi

AC_SUBST(CURL_LIBS)
AC_SUBST(CURL_CFLAGS)

if test -z "${CURL_LIBS}"; then
  AC_MSG_NOTICE([*** curl library not found.])
  ifelse([$2], , AC_MSG_NOTICE([NOTE: curl library is only required for building mlogc]), $2)
else
  AC_MSG_NOTICE([using '${CURL_LIBS}' for curl Library])
  ifelse([$1], , , $1) 
fi 
])
