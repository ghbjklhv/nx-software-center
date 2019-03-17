#include <gateways/SimpleDownloadManager.h>
#include "InstallCommand.h"

extern "C" {
#include <sys/ioctl.h>
}

InstallOperation::InstallOperation(const QString& appId, QObject* parent)
    : Command(parent), appId(appId), explorer("http://apps.nxos.org/api"),
      downloadManager(new SimpleDownloadManager(&networkAccessManager, this)) {

    connect(&explorer, &Explorer::getApplicationCompleted, this, &InstallOperation::handleGetApplicationCompleted,
            Qt::QueuedConnection);
}

void InstallOperation::execute() {
    explorer.getApplication(appId + ".desktop");
}

void InstallOperation::handleGetApplicationCompleted(QVariantMap app) {
    if (app.empty()) {
        emit Command::executionFailed("Application not found: " + appId);
        return;
    }

    auto releases = app.value("releases").toList();
    if (releases.empty()) {
        emit Command::executionFailed("No compatible releases found for: " + appId);
        return;
    }

    // find latest release
    QVariantMap latestRelease = releases.first().toMap();
    for (const auto& itr: releases) {
        auto map = itr.toMap();

        auto version = map.value("version", "latest").toString();
        if (latestRelease.value("version") < map.value("version"))
            latestRelease = map;
    }


    // find binary for the current arch
    QVariantMap file;
    for (const auto& itr: latestRelease.value("files").toList()) {
        auto map = itr.toMap();
        if (isCompatibleBinary(map.value("architecture").toString())) {
            file = map;
            break;
        }
    }

    if (file.empty()) {
        emit Command::executionFailed("No binaries releases found for: " + QSysInfo::currentCpuArchitecture());
        return;
    }

    Application a(latestRelease.value("id").toString(), latestRelease.value("version", "latest").toString());
    a.setArch(file.value("architecture").toString());
    a.setDownloadUrl(file.value("url").toString());

    interactor = new InstallAppImageInteractor(a, downloadManager, this);

    static QTextStream out(stdout);
    out << "Installing " << a.getCodeName() << " from " << a.getDownloadUrl();
    // Qt::QueuedConnection required to allow the download to be properly completed
    connect(interactor, &InstallAppImageInteractor::completed, this, &Command::executionCompleted, Qt::QueuedConnection);
    connect(interactor, &InstallAppImageInteractor::metadataChanged, [](const QVariantMap& changes) {
        auto message = changes.value("progress_message").toString();

        out << message;

        // clear spaces in the right
        struct winsize size;
        ioctl(1, TIOCGWINSZ, &size);
        for (int i = 0; i < size.ws_col - message.size(); i++)
            out << " ";

        out << "\r";
        out.flush();
    });

    interactor->execute();
}

bool InstallOperation::isCompatibleBinary(QString arch) {
    auto normalArch = arch.replace('-', '_');
    return normalArch == QSysInfo::currentCpuArchitecture();
}

