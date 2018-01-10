;; a primeira chamada no arquivo deve ser 'ns' pra definir o namespace
(ns learnclojure) ; => nil

;; criação de strings concatenadas
(str "Hello" " " "World") ; => "Hello World"

;; operadores aritméticos
(+ 2 2) ; => 4
(- 4 1) ; => 3
(* 2 1) ; => 2
(/ 1 1) ; => 1
(- 1 (- 3 2)) ; => 0

;; operadores lógicos
(= 1 1)    ; => true
(= 2 1)    ; => false
(not true) ; => false


;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; TIPOS ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;

(class 1)     ; => java.lang.Long
(class 1.)    ; => java.lang.Double
(class "")    ; => java.lang.String
(class false) ; => java.lang.Boolean
(class nil)   ; => nil

'(+ 1 2) ; lista literal => (+ 1 2)
(quote (+ 1 2))
(list 0 1 2)

(eval '(+ 1 2)) ; => 3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; COLLECTIONS & SEQUENCES ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(class '(1 2 3)); => clojure.lang.PersistentList
(class [1 2 3]) ; => clojure.lang.PersistentVector

(coll? '(1 2 3)) ; => true
(coll? [1 2 3])  ; => true

(seq? '(1 2 3)) ; => true
(seq? [1 2 3])  ; => false

(range 4) ; => (0 1 2 3)
;(range) ; => (0 1 2 3 4 ...) (an infinite series)
(take 4 (range)) ; => (0 1 2 3)

; 'cons' para adicionar um item no início da list/vector gerando uma list
(cons 1 '(2 3)) ; => (1 2 3)
(cons 1 [2 3])  ; => (1 2 3)

; 'conj' também adciona um item, mas de forma eficiente e sem perder o tipo original
; se vector -> insere no fim
; se list   -> insere no começo
(conj [1 2 3] 4)  ; => [1 2 3 4]
(conj '(1 2 3) 1) ; => (1 2 3)

; 'concat' para juntar lists e vectors
(concat [1 2] '(3 4)) ; => (1 2 3 4)

; 'filter' e 'map' para iterar em collections
(map inc [1 2 3])      ; => (2 3 4)
(filter even? [1 2 3]) ; => (2)

; 'reduce' para reduzi-los
(reduce + '(1 2 3))  ; => 6
(reduce + [1 2 3])   ; => 6

(reduce conj [:x :y] '(3 2 1)) ; => [:x :y 3 2 1]


;;;;;;;;;;;;;;;;;;;;;
;;;;; FUNCTIONS ;;;;;
;;;;;;;;;;;;;;;;;;;;;


; 'fn' para declarar uma função anônima
(fn [] "Hello World")

; 'def' para declarar variável
(def variavel 123)

; atribuição de uma função à variável
(def fnanonima (fn [] "Hello!"))
(defn fnanonima [] "Hello!")

(defn hello [name]
  (str "Hello " name))

(def hello2 #(str "Hello " %1)) ; shorthand para 'fn'

; função multi-variadic
(defn hello3
  ([] "Hello World")
  ([name] (str "Hello " name)))

(hello3)
(hello3 "Micael")

; functions can pack extra arguments up in a seq
(defn count-args [& args]
  (str "You passed " (count args) " args: " args))

(count-args 1 2 3)

(defn hello-count [name & args]
  (str "Hello " name ", you passed " (count args) " extra args"))

(hello-count "Finn" 1 2 3)


;;;;;;;;;;;;;;;;
;;;;; MAPS ;;;;;
;;;;;;;;;;;;;;;;

(class {:a 1 :b 2 :c 3})
(class (hash-map :a 1 :b 2 :c 3))

(class :a) ; => clojure.lang.keyword

(def stringmap {"a" 1, "b" 2, "c" 3})
stringmap ; => {"a" 1, "b" 2, "c" 3}

(def keymap {:a 1, :c 2, :b 3})

(stringmap "a")
(keymap :c)
(:b keymap)

(stringmap "d") ; => nil

; 'assoc' para adicionar keys para hash-maps
(def newkeymap (assoc keymap :d 4))
newkeymap

; 'dissoc' para remover keys
(dissoc keymap :a :b) ; => {:c 3}


;;;;;;;;;;;;;;;;
;;;;; SETS ;;;;;
;;;;;;;;;;;;;;;;

(class #{1 2 3})
(set [1 1 1 2 2 3 1 3 4 5 5]) ; => #{1 4 3 2 5}

; 'conj' adicionar elemento(s) em set
(conj #{1 2 3} 4 5)

; 'disj' remover elemento(s)
(disj #{1 2 3} 1 3)

; testar se elemento está no set, retornando-o
(#{3 1 2} 2)
(#{1 2 3} 4)


;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; USEFUL FORMS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

(if false "then" "else")
(if false "then")

; 'let' para criar bindings temporários
(let [a 3 b 2]
  (> a b))

; 'do' para agrupar instruções
(do
  (print "Só ")
  "Vai") ; -> "Vai" (prints ("Só ")

; funções possuem um 'do' implícito
(defn print-and-say-hello [name]
  (print "Saying hello to " name)
  (str "Hello " name))

; o mesmo que chamar a função acima
(let [name "Micael"]
  (print "Saying hello to" name)
  (str "Hello " name))


;; usar threading macros (-> e ->>) para expressar transformações de dados mais claramente

; "Thread-first" macro (->) insere em cada form o resultado do anterior como argumento
(->
    {:a 1 :b 2} ; o argumento inicial
    (assoc :c 3) ; => (assoc {:a 1 :b 2} :c 3)
    (dissoc :b)) ; => (dissoc (assoc {:a 1 :b 2} :c 3) :b)
; x
; (f x y)
; (g (f x y) z)

; o mesmo para '->>' mas insere o resultado de cada linha no final da form. útíl para operações de collections
(->>
  (range 10) ; o argumento inicial
  (map inc)     ; => (map inc (range 10))
  (filter odd?) ; => (filter odd? (map inc (range 10))
  (into []))    ; => (into [] (filter odd? (map inc (range 10)))
; x
; (f y x)
; (g z (f y x))


; usar o 'as->' para ter mais liberdade sobre a posição do resultado das transformações anteriores do dado
(as-> [1 2 3] input
  (map inc input)
  (nth input 2)
  (conj [4 5 6] input [8 9 10]))



;;;;;;;;;;;;;;;;;;;
;;;;; MODULES ;;;;;
;;;;;;;;;;;;;;;;;;;


; usar 'use' para obter todas as funções de um módulo
(use 'clojure.set)

; agora pode-se usar as funções importadas
(intersection #{1 2 3} #{2 3 4})
(difference #{1 2 3} #{2 3 4})

; importar apenas certas funções
; (use '[clojure.set :only [intersection])

; 'require' para importar um módulo
(require 'clojure.string)
; pode-se abreviar o nome do módulo importado
(require '[clojure.string :as str])

; '/' para chamar as funções do módulo importado
(clojure.string/blank? "  ") ; => true
(str/replace "isso é um teste." #"[aeiou]" str/upper-case)
;; onde #"" indica uma expressão regular literal


; ':require' para usar o require de um namespace
(ns test
  (:require
    [clojure.string :as str]
    [clojure.set :as set]))

(set/intersection #{1 2} #{2})



;;;;;;;;;;;;;;;;
;;;;; JAVA ;;;;;
;;;;;;;;;;;;;;;;


; 'import' para carregar um módulo do Java
(import java.util.Date)

; também pode-se usar de um namespace
(ns test
  (:import java.util.Date
           java.util.Calendar))

; usar o nome da classe com um ponto no final para criar uma nova instância
(Date.)

; '.' para chamar métodos. ou o atalho ".método"
(. (Date.) getTime) ; um timestamp
(.toString (.getTime (Date.)))
(.println (System/out) "§opa")
(.getName String)
(.toUpperCase "maria")


; '/' para chamar métodos estáticos
(System/currentTimeMillis)

; 'doto' para lidar com classes mutáveis
(doto (Calendar/getInstance)
  (.set 2017 1 1 0 0 0)
  .getTime) ; Date. definada para 20017-02-01 00:00:00



;;;;;;;;;;;;;;;
;;;;; STM ;;;;;
;;;;;;;;;;;;;;;
; Software Transactional Memory

; um Atom simples
(def my-atom (atom {}))


; 'swap!' para atualizar um Atom
(swap! my-atom assoc :a 1) ; definir my-atom com o valor de (assoc {} :a 1)
(swap! my-atom assoc :b 2) ; definir (assoc {a: 1} :b 2)


; '@' para desreferenciar o atom e obter seu valor
my-atom ; retorna um objeto do tipo Atom
@my-atom ; retorna o valor do objeto


;; um contador usando um Atom
(def counter (atom 0))
(defn inc-counter []
  (swap! counter inc))

(inc-counter) ; => 1
(inc-counter) ; => 2
(inc-counter) ; => 3
