add_custom_target(${EP_NAME})
add_dependencies(${EP_NAME} core.${EP_NAME} worksuite.${EP_NAME})

# xDAQ worksuite packages to be build
# Other packages have not been tested and may or may not compile
set(WORKSUITE_PACKAGES
  "xdaq2rc \
   extern/oracle \
   tstore/utils tstore/client tstore tstore/api"
)

ExternalProject_Add(core.${EP_NAME}
  PREFIX "${EP_PREFIX}"
  INSTALL_DIR "${EP_INSTALL_DIR}/opt/xdaq"

  DOWNLOAD_DIR "${GEM_SUPERBUILD_CACHE_DIR}"
  URL https://gitlab.cern.ch/cmsos/core/-/archive/release_14_10_0_0/core-release_14_10_0_0.tar.bz2
  URL_HASH SHA256=2cb223ded3db28f67443f38dc7b40a432667643fc3f96983402b7f4c3cdafcfa

  PATCH_COMMAND patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/xalan-makefile.patch"
  COMMAND       patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/xdaq-core-cpp11.patch"
  COMMAND       patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/xdaq-core-asyncresolv.patch"

  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE TRUE
  BUILD_COMMAND make
    "XDAQ_OS=${XDAQ_OS}" "XDAQ_PLATFORM=${XDAQ_PLATFORM}"
    PROJECT_NAME=core
    "XDAQ_ROOT=<SOURCE_DIR>"
    "INSTALL_PREFIX=<INSTALL_DIR>"
  INSTALL_COMMAND make install
    "XDAQ_OS=${XDAQ_OS}" "XDAQ_PLATFORM=${XDAQ_PLATFORM}"
    PROJECT_NAME=core
    "XDAQ_ROOT=<SOURCE_DIR>"
    "INSTALL_PREFIX=<INSTALL_DIR>"
)

ExternalProject_Add(worksuite.${EP_NAME}
  PREFIX "${EP_PREFIX}"
  INSTALL_DIR "${EP_INSTALL_DIR}/opt/xdaq"

  DOWNLOAD_DIR "${GEM_SUPERBUILD_CACHE_DIR}"
  URL https://gitlab.cern.ch/cmsos/worksuite/-/archive/release_14_9_0_0/worksuite-release_14_9_0_0.tar.bz2
  URL_HASH SHA256=2a40740227e414f45be0c36c70ce5d590756e2e9156327730ad74bfb6094a0de

  PATCH_COMMAND patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/oracle-makefile.patch"
  COMMAND       patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/xdaq-worksuite-cpp11.patch"
  COMMAND       sed "s/BUILD_HOME/XDAQ_ROOT/g" "${EP_PREFIX}/src/core.xdaq.pc/mfDefs.core" > "<SOURCE_DIR>/mfDefs.core"
  COMMAND       echo "include <SOURCE_DIR>/mfDefs.core" >> "<SOURCE_DIR>/mfDefs.worksuite"

  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE TRUE
  BUILD_COMMAND make
    "XDAQ_OS=${XDAQ_OS}" "XDAQ_PLATFORM=${XDAQ_PLATFORM}"
    PROJECT_NAME=worksuite
    "PACKAGES=${WORKSUITE_PACKAGES}"
    "XDAQ_ROOT=${EP_PREFIX}/src/core.xdaq.pc"
    "INSTALL_PREFIX=<INSTALL_DIR>"
  INSTALL_COMMAND make install
    "XDAQ_OS=${XDAQ_OS}" "XDAQ_PLATFORM=${XDAQ_PLATFORM}"
    PROJECT_NAME=worksuite
    "PACKAGES=${WORKSUITE_PACKAGES}"
    "XDAQ_ROOT=${EP_PREFIX}/src/core.xdaq.pc"
    "INSTALL_PREFIX=<INSTALL_DIR>"

  DEPENDS core.${EP_NAME}
)

