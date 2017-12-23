(def coords [10 20 30])

(let [x (first coords)
      y (second coords)
      z (last coords)]
  (+ x y z))

(let [[x y z] coords]
  (+ x y z))


;; ====== vector destructuring ======

(def my-list '("Bronn" "Mountain" "Hound"))

(let [[name-1 name-2 name-3] my-list]
  (str name-3 " " name-2 ", " name-1))


(def my-string "Jon")

(let [[char-1 _ char-3] my-string]
  (str char-1 char-3))


(let [[_ name-2 :as sellswords] my-list]
  [name-2 sellswords])


;; cauda da lista
(rest my-list)

;; emular o 'rest' usando destructuring
(let [[_ & tail] my-list]
  tail)



;; ====== map destructuring ======

(def my-map {:x 10 :y 20 :z 30})

(let [{x :x y :y z :z} my-map]
  (+ x y z))

(let [{:keys [x y z]} my-map]
  (+ x y z))

(let [{:keys [x y z] :or {x 100 y 200}} {:z 50}]
  (+ x y z))


;; ====== nested data ======

(defn add-everything [ [_ {:keys [a c] [b1 b2] :b} d] ]
  (+ a b1 b2 c d))

(add-everything [0 {:a 1 :b [2 3] :c 4} 5])
