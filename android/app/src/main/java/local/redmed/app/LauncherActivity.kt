package local.redmed.app

import com.google.androidbrowserhelper.trusted.LauncherActivity

/**
 * Launches the hosted web app (index.html) as a Trusted Web Activity —
 * full-screen, no browser chrome, using androidbrowserhelper's default
 * behavior driven entirely by the meta-data in AndroidManifest.xml.
 * No custom code needed beyond this empty subclass.
 */
class LauncherActivity : LauncherActivity()
