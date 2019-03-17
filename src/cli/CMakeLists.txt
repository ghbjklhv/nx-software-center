add_executable(app
    main.cpp
    Command.h
    ListCommand.cpp
    InstallCommand.cpp
    $<TARGET_OBJECTS:core>
    )

target_link_libraries(app PRIVATE
    Qt5::Core
    Qt5::Network
    Qt5::XmlPatterns
    Qt5::Gui
    libappimage
    )

target_include_directories(app PRIVATE ..)
