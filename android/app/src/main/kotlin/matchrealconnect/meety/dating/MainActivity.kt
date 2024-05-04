package matchrealconnect.meety.dating
import android.os.Bundle
import android.os.PersistableBundle
import android.view.WindowManager.LayoutParams

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {

        window.addFlags(LayoutParams.FLAG_SECURE)

        super.onCreate(savedInstanceState, persistentState)
    }
}
