#pragma once

// libraries
#include <QObject>
#include <QString>

// local
#include <Command.h>
#include <entities/Explorer.h>
#include <interactors/InstallAppImageInteractor.h>

class InstallOperation : public Command {
Q_OBJECT
public:
    InstallOperation(const QString& appId, QObject* parent = nullptr);

public slots:

    void execute() override;

protected slots:

    void handleGetApplicationCompleted(QVariantMap app);

private:
    bool isCompatibleBinary(QString arch);

    QString appId;
    Explorer explorer;

    InstallAppImageInteractor* interactor;
    QNetworkAccessManager networkAccessManager;
    DownloadManager* downloadManager;
};
