;; Clojure destructuring cheatsheet.
;; all the following destructuring forms can be used in any of the
;; Clojure's `let` derived bindings such as function's parameters,
;; `let`, `loop`, `binding`, `for`, `doseq`, etc.

;; list, vectors and sequences
[zero _ _ three & four-and-more :as numbers] (range)
{one 1 two 2} [:a :b :c :d :e :f :g]
;; zero = 0, three = 3, four-and-more = (4 5 6 7 ...),
;; numbers = (0 1 2 3 4 5 6 7 ...)
;; one = :b, two = :c

;; maps and sets
{:keys [firstname lastname] :as person} {:firstname "John"  :lastname "Smith"}
{:keys [:firstname :lastname] :as person} {:firstname "John"  :lastname "Smith"}
{:strs [firstname lastname] :as person} {"firstname" "John" "lastname" "Smith"}
{:syms [firstname lastname] :as person} {'firstname "John"  'lastname "Smith"}
;; firstname = John, lastname = Smith, person = {:firstname "John" :lastname "Smith"}

;; maps destructuring with different local vars names
{name :firstname family-name :lastname :as person} {:firstname "John"  :lastname "Smith"}
;; name = John, family-name = Smith, person = {:firstname "John" :lastname "Smith"}

;; default values
{:keys [firstname lastname] :as person
 :or {firstname "Jane"  :lastname "Bloggs"}} {:firstname "John"}
;; firstname = John, lastname = Bloggs, person = {:firstname "John"}

;; nested destructuring
[[x1 y1] [x2 y2] [_ _ z]]  [[2 3] [5 6] [9 8 7]]
;; x1 = 2, y1 = 3, x2 = 5, y2 = 6, z = 7

{:keys [firstname lastname]
    {:keys [phone]} :contact} {:firstname "John" :lastname "Smith" :contact {:phone "0987654321"}}
;; firstname = John, lastname = Smith, phone = 0987654321

;; namespaced keys in maps and sets
{:keys [contact/firstname contact/lastname] :as person}     {:contact/firstname "John" :contact/lastname "Smith"}
{:keys [:contact/firstname :contact/lastname] :as person}   {:contact/firstname "John" :contact/lastname "Smith"}
{:keys [::firstname ::lastname] :as person}                 {::firstname "John"        ::lastname "Smith"}
{:syms [contact/firstname contact/lastname] :as person}     {'contact/firstname "John" 'contact/lastname "Smith"}
;; firstname = John, lastname = Smith, person = {:firstname "John" :lastname "Smith"}
