;; ----- CLJS x JS ----- ;;

;;>> define a library

(ns my.library)


;;>> o 'println' no navegador

(.log js/console "Hello world")


;;>> variável global

(def foo "bar")

(defn foo []
  (let [bar "bar"] ;; variável local
    bar))


;;>> [não tem] hoisting

(defn print-name []
  (println "Hello, " name)
  (let [name "Bob"])) ; emite um aviso

(defn print-name []
  (let [name "Bob"]
    (println "Hello, " name)))

(print-name)


;;>> destructing bind

(def obj {:a 1
          :b 2})

(let [{:keys [a b]} obj] ;; // const { a, b } = obj
  (println (+ a b)))

(def color [255 255 100 0.5])

(let [[r g _ a] color]
  (println a))


;;>> [efficient] dynamic binding

(def ^:dynamic x 5)

(binding [x "a"]
  (println x)) ;; => "a"

(println x) ;; => 5


;;>> [não há] mutable locals

#_(defn foo [x]
  (set! x "bar")) ;; emite um erro


;;>> criação de objetos

(def foo (js-obj "bar" "baz")) ;; #js{:bar baz}
(println (:bar foo)) ;; => nil

(def foo {:bar "baz"})
(println (:bar foo)) ;; => "baz"


;;>> property access

(set! (.-bar foo) "baz") ;; foo.bar = "baz"
(.log js/console (.-bar foo))

(aset foo "abc" 17) ;; foo["abc"] = 17
(.log js/console (aget foo "abc"))


;;>> interoperabilidade


;; Enhance JavaScript objects to ClojureScript
;; records for additional capabilities.
;; Then do something on each element.
;; Then convert back to plain JavaScript.
(defn get-names [people]
  (let [people (js->clj people)
        names (map "name" people)]
    (clj->js names)))



;;>> arrays

(def a (array)) ;; var a = []
(def a (array 1 2)) ;; var a = [1, 2]


;;>> immutable lists, vectors, sets, hashmaps

;; efficient addition at the head

(def l (list))
(def l (list 1 2 3))
(def l '(1 2 3))
(conj l 4) ;; => '(4 1 2 3)

;; efficient addition at the end

(def v (vector))
(def v [])
(def v [1 2 3])
(conj v 4) ;; => [1 2 3 4]

(def s (set))
(def s #{})
(def s #{"cat" "bird" "dog"})
(conj s "cat") ;; => #{"cat" "bird" "dog"}

(def m (hash-map))
(def m {})
(def m {:foo 1 :bar 2})
(conj m [:baz 3]) ;; => {:foo 1 :bar 2 :baz 3}


;;>> acessando valores

;; collections access is first class

(def m {:foo 1
        :bar 2})
(get m :foo) ;; m.foo

(def v ["red" "blue" "green"])
(nth v 1) ;; v[1]


;;>> arbitrary keys

;; em JS, apenas strings
(def m {[1 2] 3 ;; m["1 2"] = 3
        #{1 2} 3
        '(1 2) 3})


;;>> adicionando na collection

;; atualização não-destrutiva eficiente

(def a [])
(conj a "foo") ;; => ["foo"]

(def b {})
(conj b :bar 1) ;; => {:bar 1}


;;>> callable collections

(def address {:street "1 Bit Ave."
              :city "Bit City"
              :zip 10111011})

;; Collections can act as functions.
;; HashMaps are functions of their keys.

(map address [:zip :street]) ;; => (10111011 "1 Bit Ave.")


;;>> igualdade

(def a ["red" "blue"])
(def b ["red" "blue"])
(= a b) ;; => true

(= 1 "1") ;; => false
(= {} {}) ;; => true


;;>> booleans

(def bug-numbers [3234 452 944 124])

(if (pos? (count bug-numbers))
  (println ".length > 0"))


;;>> handling of empty strings

(def empty-string "")
(if empty-string ;; usar o 'empty?'
  println "string vazia não é false!")


;;>> handling of zero

(def zero 0)
(if zero ;; usar o 'zero?'
  (println "zero não é false!"))


;;>> [não há] parâmetros opcionais

(defn foo [a b c] c)
(foo 1) ;; WARNING


;;>> dispatch on arity

(defn foo
  ([a] "one")
  ([a b] "two")
  ([a b c] "three"))

(foo 1) ;; => "one"
(foo 1 2) ;; => "two"
(foo 1 2 3) ;; => "three"


;;>> variable arguments

(defn foo [& args]) ;; function foo(..args) {}


;;>> named parameters & defaults

(defn foo [& {:keys [bar baz]}])

(foo :bar 1 :baz 2)


(defn foo [& {:keys [bar baz]
              :or {bar "default1"
                   baz "default2"}}])


;;>> iteração uniforme para todos os tipos

(def colors (array "red" "orange" "green"))

(doseq [color colors]
  (println color))


(def colorsv ["red" "orange" "green"])

(doseq [color colorsv]
  (println color))


(def data { ... })

(doseq [[k v] data]
  (println "key" k)
  (println "value" v))


;;>> closures e contatores em laços

;; ClojureScript has proper lexical scope

(def callbacks (atom []))

(dotimes [i 2]
  (swap! callbacks conj (fn [] i)))

((@callbacks 0)) ;; => 0


;;>> .map

;; lazy, will only traverse once array

(def colors ["red" "green" "blue"])

(println
  (map #(str % "foo") (map first colors)) ;; => ("rfoo" "gfoo" "bfoo")


;;>> .filter

(def numbers [0 1 2 3 4 5 6 7 8 9 10])

(def filtered
  (filter #(zero? (rem % 5)) numbers))

(def firstn (first filtered))

;; lazy filter, values after 5 haven't been looked at


;;>> tipos

(deftype Person [name]
  Object
  (greet [_]
    (str "Hello" name)))

;; Constructors don't look like functions
;; No explicit prototype manipulation
;; No explicit 'this' to access fields


(Person. "Bob") ;; new Person("Bob")

(def namex "Bob")
(type namex) ;; => string

(= (type namex) js/String) ;; => true
(string? name) ;; => true

(not= (type name) js/Number) ;; => true
(not (number? name)) ;; => true


;;>> protocols

(defprotocol ISound (sound []))

(deftype Cat []
  ISound
  (sound [_] "Meow!"))

(deftype Dog []
  ISound
  (sound [_] "Woof!"))

(extend-type default
  ISound
  (sound [_] "... silence ..."))

(sound 1) ;; => "... silence ..."


;;>> expressões regulares

(def email "test@foo.bar")
(.match email #"@") ;; => ["@"]

(def invalid-email "f@il@example.com")
(re-seq #"@" invalid-email) ;; => ("@" "@")


;;>> exceptions

(throw (js/Error. "Oops!")) ;; trhow Error("Oops!")

(try
  (undefined-function)
  (catch js/Error e
    (if (= (type e) js/ReferenceError)
      (println
        (str "You called a function"
             "that does not exist"))))
  (finally
    (println
      (str "this runs even if an"
           "exception is thrown"))))


;;>> expression problem

(defprotocol MyStuff
  (foo [this]))

(extend-type string
  MyStuff
  (foo [this]
    ...))

;; For example say you'd like to use RegExps as functions
;; This is precisely how callable collections are implemented.
(extend-type js/RegExp
  IFn
  (-invoke
   ([this s]
     (re-matches this s))))

(filter #"foo.*" ["foo" "bar" "foobar"]) ;; => ("foo" "foobar")


;;>> macros

;; ClojureScript has compiler macros, no external tool required
(defmacro my-code-transformation [...]
  ...)

;; Ocaml, Haskell style pattern matching is a
;; library.

;; Prolog style relational programming is a
;; library
