// libraries
#include <QDebug>
#include <QCommandLineParser>

// local
#include "ListCommand.h"
#include "InstallCommand.h"

int main(int argc, char** argv) {

    QCoreApplication app(argc, argv);

    QCommandLineParser parser;
    parser.addPositionalArgument("command", QCoreApplication::translate("cli-main",
                                                                        "Command to be executed: search | install | update | remove"));
    parser.process(app);

    QStringList args = parser.positionalArguments();
    if (args.size() == 0)
        parser.showHelp(0);

    Command* command = nullptr;
    if (args.first() == "search") {
        args.pop_front();
        if (args.empty())
            qFatal("Missing search query, try:\n\tapp search franz");

        command = new ListCommand(args.first());
    }

    if (args.first() == "install") {
        args.pop_front();
        if (args.empty())
            qFatal("Missing application id, try:\n\tapp install franz");

        command = new InstallOperation(args.first());
    }

    if (command) {
        QObject::connect(command, &Command::executionCompleted, &app, &QCoreApplication::quit);
        QObject::connect(command, &Command::executionFailed, [&app](const QString& message) {
            qWarning() << message;
            app.exit(0);
        });
        command->execute();

        return app.exec();
    } else
        parser.showHelp(0);
}
