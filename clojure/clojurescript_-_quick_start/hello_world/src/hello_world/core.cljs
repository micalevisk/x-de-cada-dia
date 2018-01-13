(ns hello-world.core) ;; cada hífen vira um underscore (no index.html)
  ; (:require [clojure.browser.repl :as repl]))

; (defonce conn
;   (repl/connect "http://localhost:9000/repl"))

(enable-console-print!)

(prn "Hello World!")
; (js/alert "aa") ;; (.alert js/window "aa")
(.write js/document "
<h1>Hello Browser</h1>
<div>
  <p>aaaaaaaaaaaaaaa</p>
</div>
")

(defn foo [a b]
  (+ a b))
