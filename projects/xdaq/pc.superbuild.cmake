# xDAQ is complex and is split in 2 external projects
add_custom_target(${EP_NAME})
add_dependencies(${EP_NAME} core.${EP_NAME} worksuite.${EP_NAME})

# Define the xDAQ environment variables
# Projects requiring xDAQ will also have access to these variables
string(TOLOWER "${CMAKE_SYSTEM_NAME}" _xdaq_os)
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" _xdaq_platform)

set(XDAQ_OS "${_xdaq_os}" CACHE INTERNAL "")
set(XDAQ_PLATFORM "${_xdaq_platform}" CACHE INTERNAL "")

# xDAQ worksuite packages to be build
# Other packages have not been tested and may or may not compile
set(WORKSUITE_PACKAGES
  "xdaq2rc \
   extern/oracle \
   tstore/utils tstore/client tstore tstore/api"
)

set(_xdaq_core_options
  "XDAQ_OS=${XDAQ_OS}" "XDAQ_PLATFORM=${XDAQ_PLATFORM}"
  PROJECT_NAME=core
  "XDAQ_ROOT=<SOURCE_DIR>"
  "UserExecutableLinkFlags=-Wl,-rpath='$$ORIGIN/../lib'"
  "INSTALL_PREFIX=<INSTALL_DIR>/opt/xdaq"
)

ExternalProject_Add(core.${EP_NAME}
  PREFIX "${EP_PREFIX}"
  INSTALL_DIR "${EP_INSTALL_DIR}"

  DOWNLOAD_DIR "${SUPERBUILD_CACHE_DIR}"
  URL https://gitlab.cern.ch/cmsos/core/-/archive/1f55790f611805c3a1e63316669514ab12b737f5/core-1f55790f611805c3a1e63316669514ab12b737f5.tar.bz2
  URL_HASH SHA256=15a054a25a07ca9aeea8f254c7e2c9366191cf807f4ab1118b83fc0f4f6ceedf

  PATCH_COMMAND patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/00-xalan.patch"
  COMMAND       patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/01-boost_thread.patch"
  COMMAND       patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/02-asyncresolv.patch"
  COMMAND       patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/03-parallel_build.patch"

  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE TRUE
  BUILD_COMMAND $(MAKE)
    ${_xdaq_core_options}
  INSTALL_COMMAND $(MAKE) install
    ${_xdaq_core_options}
)

set(_xdaq_worksuite_options
  "XDAQ_OS=${XDAQ_OS}" "XDAQ_PLATFORM=${XDAQ_PLATFORM}"
  PROJECT_NAME=worksuite
  "PACKAGES=${WORKSUITE_PACKAGES}"
  "XDAQ_ROOT=${EP_PREFIX}/src/core.xdaq.pc"
  "UserExecutableLinkFlags=-Wl,-rpath='$$ORIGIN/../lib'"
  "INSTALL_PREFIX=<INSTALL_DIR>/opt/xdaq"
)

ExternalProject_Add(worksuite.${EP_NAME}
  PREFIX "${EP_PREFIX}"
  INSTALL_DIR "${EP_INSTALL_DIR}"

  DOWNLOAD_DIR "${SUPERBUILD_CACHE_DIR}"
  URL https://gitlab.cern.ch/cmsos/worksuite/-/archive/1b498ec569aba656054aa09516db73d2652d70a4/worksuite-1b498ec569aba656054aa09516db73d2652d70a4.tar.bz2
  URL_HASH SHA256=658564ed2f260ed52dc82f5df1cdddbcc65507218c27c30152e452981797145a

  PATCH_COMMAND patch -p1 -i "${CMAKE_CURRENT_LIST_DIR}/00-oracle.patch"
  COMMAND       sed "s/BUILD_HOME/XDAQ_ROOT/g" "${EP_PREFIX}/src/core.xdaq.pc/mfDefs.core" > "<SOURCE_DIR>/mfDefs.core"
  COMMAND       echo "include <SOURCE_DIR>/mfDefs.core" >> "<SOURCE_DIR>/mfDefs.worksuite"

  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE TRUE
  BUILD_COMMAND make
    ${_xdaq_worksuite_options}
  INSTALL_COMMAND make install
    ${_xdaq_worksuite_options}

  DEPENDS core.${EP_NAME}
)

