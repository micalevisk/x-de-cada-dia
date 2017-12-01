;; (-> x)
;; (-> x form)
;; (-> form & more)

;; (->> x form)
;; (->> x form & more)


(def common-words (-> (slurp "https://www.textfixer.com/tutorials/common-english-words.txt")
                      (clojure.string/split #",")
                      set))

(def text (slurp "http://www.clearwhitelight.org/hitch/hhgttg.txt"))

(->> text
     (re-seq #"[\w|']+")
     (map #(clojure.string/lower-case %))
     (remove common-words)
     frequencies
     (sort-by val)
     reverse)

; ----^ sem a macro thread-last
(reverse (sort-by val (frequencies (remove common-words (map #(clojure.string/lower-case %) (re-seq #"[\w|']+" text))))))



; -----

(comment

  ;; último arg
  (->> text
       (re-seq #"[\w|']+" ,,,)
       (map #(clojure.string/lower-case %) ,,,)
       (remove common-words ,,,)
       frequencies ,,,
       (sort-by val ,,,)
       reverse ,,,)

  ;; primeiro arg
  (-> (slurp "https://www.textfixer.com/tutorials/common-english-words.txt")
      (clojure.string/split ,,, #",")
      (->> (set ,,,)))

)


(clojure.walk/macroexpand-all '  (->> text
                                      (re-seq #"[\w|']+")
                                      #_(map #(clojure.string/lower-case %))
                                      #_(remove common-words)
                                      frequencies
                                      #_(sort-by val)
                                      reverse))
