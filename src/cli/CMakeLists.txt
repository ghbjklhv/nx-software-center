add_executable(app
    main.cpp
    Command.h
    commands/GetCommand.cpp
    commands/ListCommand.cpp
    commands/SearchCommand.cpp
    commands/RemoveCommand.cpp
    $<TARGET_OBJECTS:core>
    )

target_link_libraries(app
    PRIVATE Qt5::Core
    PRIVATE Qt5::Network
    PRIVATE Qt5::XmlPatterns
    PRIVATE Qt5::Gui
    PRIVATE libappimage
    )

target_include_directories(app PRIVATE ..)
