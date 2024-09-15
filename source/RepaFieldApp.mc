import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class RepaFieldApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [new RepaFieldView() as View];
    }

}

function getApp() as RepaFieldApp {
    return Application.getApp() as RepaFieldApp;
}