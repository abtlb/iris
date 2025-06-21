package com.example.symspell

// Replace with the actual package from the JAR/AAR
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.gitlab.rxp90.jsymspell.*
import io.gitlab.rxp90.jsymspell.api.*

class SymSpellBridge(
    private val context: Context,
    private val flutterEngine: FlutterEngine
) : MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.example.symspell/bridge"
        private const val BIGRAM_ASSET = "symspell/bigrams.txt"
        private const val UNIGRAM_ASSET = "symspell/words.txt"
        private const val MAX_EDIT_DISTANCE = 2
        private const val PREFIX_LENGTH = 7
    }

    private val symSpell: SymSpell
    private val unigrams: Map<String, Long>

    init {
        // 1) Load bigrams from assets
        val bigrams = mutableMapOf<Bigram, Long>()
        context.assets.open(BIGRAM_ASSET).bufferedReader().useLines { lines ->
            lines.forEach { line ->
                val tokens = line.split(" ")
                if (tokens.size >= 3) {
                    bigrams[Bigram(tokens[0], tokens[1])] = tokens[2].toLong()
                }
            }
        }

        // 2) Load unigrams from assets
        unigrams = mutableMapOf<String, Long>()
        context.assets.open(UNIGRAM_ASSET).bufferedReader().useLines { lines ->
            lines.forEach { line ->
                val tokens = line.split(",")
                if (tokens.size >= 2) {
                    unigrams[tokens[0]] = tokens[1].toLong()
                }
            }
        }

        // 3) Initialize SymSpell
        symSpell = SymSpellBuilder()
            .setUnigramLexicon(unigrams)
            .setBigramLexicon(bigrams)
            .setMaxDictionaryEditDistance(MAX_EDIT_DISTANCE)
            .createSymSpell()

        // 4) Register MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "correct" -> {
                val word = call.argument<String>("word") ?: ""
                // Call lookupCompound without named arguments
                val suggestions: List<SuggestItem> = symSpell.lookupCompound(
                    word,
                    MAX_EDIT_DISTANCE,
                    false // includeUnknownWords
                )
                val best = suggestions.firstOrNull()?.suggestion ?: word
                result.success(best)
            }
            else -> result.notImplemented()
        }
    }

}