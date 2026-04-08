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
Q_QMLTYPE_EXPORT void qml_register_types_com_library_name()
{
    QT_WARNING_PUSH QT_WARNING_DISABLE_DEPRECATED
    qmlRegisterTypesAndRevisions<Router>("com.library.name", 1);
    QT_WARNING_POP
    qmlRegisterModule("com.library.name", 1, 0);
}

static const QQmlModuleRegistration comlibrarynameRegistration("com.library.name", qml_register_types_com_library_name);
