enable_testing()

include(cmake/fetch_gtest.cmake)

######
# Configure tests
######
add_subdirectory(src/remote)

find_package(Qt5 REQUIRED COMPONENTS Core Gui Network Test XmlPatterns)

add_executable(test_core
    $<TARGET_OBJECTS:core>
    src/test_core_main.cpp
    src/TestFetchApplicationsInteractor.cpp
    src/DummySource.h src/BrokenDummySource.h
    src/TestAppImageHubSource.cpp
    src/TestAppImageInstallLinksRegExParser.cpp
    src/TestExecutor.cpp
    src/TestDownload.cpp
    src/FakeDownloadManager.h src/FakeDownloadManager.cpp
    src/TestRegistry.cpp
    src/TestUpdater.cpp
    src/TestCache.cpp
    src/TestApplicationSerializer.cpp
    src/TestUpgrader.cpp
    src/TestOSCStoreParser.cpp
    src/TestExplorer.cpp)

target_include_directories(test_core PRIVATE ${CMAKE_SOURCE_DIR}/src/)

target_compile_definitions(test_core PRIVATE TEST_DATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}/data/")

target_link_libraries(
    test_core

    PRIVATE Qt5::Core
    PRIVATE Qt5::Gui
    PRIVATE Qt5::Network
    PRIVATE Qt5::Test
    PRIVATE Qt5::XmlPatterns
    PRIVATE libappimage
    PRIVATE gtest
    PRIVATE gtest_main
)

add_dependencies(test_core gtest)

add_test(software_center_core test_core)
