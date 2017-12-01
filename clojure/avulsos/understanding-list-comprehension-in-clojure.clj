(for [number [1 2 3]] (* number 2))
(map #(* % 2) [1 2 3])

;; -----

(for [number [1 2 3]
      letter [:a :b :c]]
  (str number letter))

(mapcat (fn [number] (map (fn [letter] (str number letter)) [:a :b :c])) [1 2 3])

;; -----

(count (for [tumbler-1 (range 10)
             tumbler-2 (range 10)
             tumbler-3 (range 10)
             :when (or (= tumbler-1 tumbler-2)
                       (= tumbler-2 tumbler-3)
                       (= tumbler-3 tumbler-1))]
         [tumbler-1 tumbler-2 tumbler-3]))




(def capital-letters (map char (range (int \A) (inc (int \Z)))))
(def blacklisted #{\I \O})

(for [letter-1 capital-letters
      letter-2 capital-letters
      :when (and (not (blacklisted letter-1))
                 (not (blacklisted letter-2)))]
  (str letter-1 letter-2))




(for [number [1 2 3]
      :let [tripled (* number 3)]
      :while (odd? tripled)]
  tripled) ; 3 6<-para o loop


;; ----- para resolver o problema "Largest Palindrome Product" (c) https://projecteuler.net/problem=4

(defn- palindrome? [number]
  (= (str number) (clojure.string/reverse (str number))))

(max 1 2 3) ; => 3
(apply max [1 2 3]) ; => 3

(apply max(for [three-digit-number-1 (range 100 1000)
                three-digit-number-2 (range 100 1000)
                :let [product (* three-digit-number-1 three-digit-number-2)]
                :when (palindrome? product)]
            product))
