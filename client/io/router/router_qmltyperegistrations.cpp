/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#if __has_include(</home/san3/mycode/control_and_sort/controlAndSort/controller/router.py>)
#  include </home/san3/mycode/control_and_sort/controlAndSort/controller/router.py>
#endif


#if !defined(QT_STATIC)
#define Q_QMLTYPE_EXPORT Q_DECL_EXPORT
#else
#define Q_QMLTYPE_EXPORT
#endif
Q_QMLTYPE_EXPORT void qml_register_types_io_router()
{
    QT_WARNING_PUSH QT_WARNING_DISABLE_DEPRECATED
    qmlRegisterTypesAndRevisions<Page>("io.router", 1);
    qmlRegisterTypesAndRevisions<Router>("io.router", 1);
    QT_WARNING_POP
    qmlRegisterModule("io.router", 1, 0);
}

static const QQmlModuleRegistration iorouterRegistration("io.router", qml_register_types_io_router);
