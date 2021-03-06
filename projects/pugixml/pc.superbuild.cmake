ExternalProject_Add(${EP_NAME}
  PREFIX "${EP_PREFIX}"
  INSTALL_DIR "${EP_INSTALL_DIR}"

  DOWNLOAD_DIR "${SUPERBUILD_CACHE_DIR}"
  URL "https://github.com/zeux/pugixml/releases/download/v1.9/pugixml-1.9.tar.gz"
  URL_HASH SHA256=d156d35b83f680e40fd6412c4455fdd03544339779134617b9b28d19e11fdba6

  CMAKE_ARGS
    "-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>/usr"
    -DBUILD_SHARED_LIBS=ON
    -DBUILD_PKGCONFIG=OFF
    -DCMAKE_INSTALL_LIBDIR=lib
)

