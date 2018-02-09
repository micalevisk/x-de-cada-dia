;; Desestruturação de Listas

;BEGIN:ex1
(let [lista [1 2 3]
      primeiro (nth lista 0)
      segundo (nth lista 1)
      terceiro (nth lista 2)]
  (+ primeiro segundo terceiro)) ;; => 6

(let [lista [1 2 3]
      [primeiro segundo terceiro] lista]
  (+ primeiro segundo terceiro)) ;; => 6
;END:ex1

;BEGIN:ex2
(let [[x] "exemplo"
      [y] '(1 2 3)
      [z] [4 5 6]
  [x y z]]) ;; => [\e 1 4]
;END:ex2

;BEGIN:ex3
(let [lista [1 2 3]
      head (nth lista 0)
      tail (rest lista)]
  [head tail]) ;; => [1 (2 3)]

(let [lista [1 2 3]
      [head & tail] lista]
  [head tail]) ;; => [1 (2 3)]
;END:ex3

;BEGIN:ex4
(let [[a b c & resto :as letras] "Ola Mundo"]
  [a b c resto letras]) ;; => [\O \l \a (\space \M \u \n \d \o) "Ola Mundo"]
;END:ex4


;; Desestruturação de Mapas

;BEGIN:ex5
(defn exemplo1 [mapa]
  (str
    " :chave => " (:chave mapa)
    " :nome => " (:nome mapa)))
(exemplo1 {:chave "abcd", :nome "Bruno"}) ;;> " :chave => abcd :nome => Bruno"

(defn exemplo2 [{c :chave n :nome}]
  (str
    " :chave => " c
    " :nome => " n))
(exemplo2 {:chave "abcd", :nome "Bruno"}) ;;> " :chave => abcd :nome => Bruno"
;END:ex5

;BEGIN:ex6
(defn exemplo1 [mapa]
  (str
    " :chave => " (:chave mapa "<sem chave>")
    " :nome => " (:nome mapa "<sem nome>")))
(exemplo1 {:chave "abcd", :nome "Bruno"}) ;; => " :chave => abcd :nome => Bruno"
(exemplo1 {:nome "Bruno"}) ;; " :chave => <sem chave> :nome => Bruno"

(defn exemplo2 [{c :chave n :nome
                 :or {c "<sem chave>" n "<sem nome>"}}]
  (str
    " :chave => " c
    " :nome => " n))
(exemplo2 {:chave "abcd", :nome "Bruno"}) ;; => " :chave => abcd :nome => Bruno"
(exemplo2 {:chave "abcd"}) ;; => " :chave => abcd :nome => <sem nome>"
;END:ex6

;BEGIN:ex7
(defn example [{a :a :as mapa}]
  [a mapa])

(example {:a 1 :b 2}) ;; => [1 {:a 1, :b 2}]
;END:ex7

;BEGIN:ex8
(let [mapa {:a 1, 'b 2, "c" 3, :d 4}
      {:keys [a d]} mapa
      {:syms [b]} mapa
      {:strs [c]} mapa]
  [a b c d]) ;; => [1 2 3 4]
;END:ex8

;BEGIN:ex9
(def meu-mapa {:chave "abcd"
              :valores [1 2 3 4 5]})

(defn terceiro-valor [{[_ _ tv] :valores}]
  tv)

(terceiro-valor meu-mapa) ;; => 3
;END:ex9
