#pragma once

// local
#include <Command.h>
#include <entities/Explorer.h>

class ListCommand : public Command {
Q_OBJECT
public:
    explicit ListCommand(const QString& query);

public slots:
    void execute() override;

protected slots:
    void handleSearchCompleted(QList<QVariantMap> apps);

protected:
    Explorer explorer;
    QString query;

    QStringList applicationsIds;
};
