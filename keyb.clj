(ns keyb
  (:require
   [clojure.data.json :as json]
   [clojure.java.io :as io])

  (:use
   [scad-clj.model]
   [scad-clj.scad]))

(def halfpi (/ pi 2))

(def opts
  {:total-height 12
   :switch-size 14
   :switch-sep 5
   :wall-thickness 2.4
   :plate-thickness 2.6})

(defn col [cnt cx cy]
  (->> (range cnt)
    (map #(* (+ (:switch-size opts) (:switch-sep opts)) %1))
    (map #(vector cx (- (+ cy %1)) 0))))

(def switch-hole
  (let [f (- (:switch-size opts) 0.2)] (square f f))) 

(defn keyiter [layout f]
  (->> layout
    (map (fn [[x y a]]
           (->> f
             (rotatec [0 0 a])
             (translate [x y 0]))))))

(defmacro round-corners [r & b]
  `(offset (- ~r) (offset ~r ~@b)))

(defmacro s-x [s] `(:x (second ~s)))
(defmacro s-y [s] `(:y (second ~s)))

(def ic-rect-x 18.2)
(def ic-rect-y 33.2)

(def ic-rect
  (mirror [0 1 0]
    (square ic-rect-x ic-rect-y :center nil)))

(def ic-pin-cutout
  (->>
    (square (- ic-rect-x (* 2.5 2))
      ic-rect-y :center nil)
    (translate [2.5 (- ic-rect-y) 0])
    (difference ic-rect)
    (resize [0 (- ic-rect-y 0.5) 0])
    (translate [0 -0.5 0])))

(def jack-d 9)
(def jack-loc
  [0
   (- (+ (:switch-sep opts) (/ jack-d 2) ic-rect-y))
   0])

(defn perimeter [layout ic-loc ext]
  (round-corners
    8
    (translate ic-loc
      (offset {:delta (:switch-sep opts)} ic-rect)

      (translate (map + jack-loc [0 (:switch-sep opts) 0]) 
        (offset {:delta (:switch-sep opts)}
          (mirror [0 1 0] (square ic-rect-x jack-d :center nil)))))

    (map #(%1) ext)
    
    (keyiter layout (offset {:delta (:switch-sep opts)} switch-hole))))

(def clamp-space 
  (let [t (:plate-thickness opts)]
    (translate [0 0 (+ 1.5 (/ t 2))]
      (cube 5 (+ (:switch-size opts) 1) t))))

(defmacro polyhole [& args]
  `(call-module 'polyhole ~@args))

;; (defn extrude-chamfer [opts & args]
;;   (extrude-linear (conj opts {:center nil}) args))
(defmacro extrude-chamfer [& args] `(call-module-with-block 'chamfer_extrude ~@args))

(defn tent-hole [h]
  (with-center nil
    (with-fs 6
      (mirror [0 0 1]
        (difference
          (extrude-chamfer {:chamfer 2.5 :faces [false true] :height h}
            (hull
              (translate [-6.5 0 0]
                (square 0.1 17 :center true))
              (translate [4.5 0 0]
                (circle (+ (/ 5 2) 2.5 1.5 1)))))
          
          (translate [4.5 0 -1]
            (with-fn 6 (cylinder (/ 9.3 2) (+ 5 0.1))) ;
            (polyhole (/ 5 2) (+ h 2))))))))

(defn tents [tent-list]
  (->> tent-list
    (map (fn [[[x y] a]]
           (translate [x y 0]
             (rotate [0 0 a]
               (tent-hole 8)))))
    (apply union)))

(defn kbd [layout & {:keys [ic-loc tent-loc ext ext-holes]}]
  (let [ic-y 8

        ic-body
        (mirror [0 0 1]
          (translate [0 0 1.5]
            (extrude-chamfer {:height ic-y :faces [false true]}
              (offset {:delta 2}
                ic-rect))))

        walls
        (translate [0 0 (- (:total-height opts))]
          (extrude-chamfer {:faces [false true] :height (:total-height opts)}
            (perimeter layout ic-loc ext)))
        
        body-hollow
        (translate [0 0 (:plate-thickness opts)]
          (extrude-linear {:height (:total-height opts) :center nil}
            (offset {:delta (- (:wall-thickness opts))}
              (perimeter layout ic-loc ext))))

        switch-holes
        (extrude-linear {:height (:plate-thickness opts) :center nil}
          (keyiter layout switch-hole))


        usb-cutout
        (let [w 8.5 h 4]
          (translate [(/ ic-rect-x 2)
                      (:wall-thickness opts)
                      (- ic-y 1 (/ h 2))]
            (cube w 8 h)))

        ic-pins-cutout
        (translate [0 0 ic-y]
          (extrude-linear {:height 1.5 :center nil}
            ic-pin-cutout))

        ic-body-cutout
        (translate [0 0 -1]
          (extrude-linear {:height (+ ic-y 1) :center nil}
            ic-rect))

        jack-hole
        (translate
          (map + jack-loc
            [ic-rect-x 0
             (/ (+ (:total-height opts) (:plate-thickness opts)) 2)])
          (rotate [0 halfpi 0] (polyhole 3.1 13)))

        ic-offset [0 (- (:switch-sep opts) 2) 0]]

    (union
      ;; (translate [0 0 -2.5 ] (keyiter layout cherry-mx))
      (difference
        (union
          (translate (map + ic-loc ic-offset)
            ic-body)
          (difference
            (union walls (tents tent-loc))

            (mirror [0 0 1]
              body-hollow switch-holes
              (map #(%1) ext-holes)
              (keyiter layout clamp-space))))

        (translate (map + ic-loc ic-offset)
          (mirror [0 0 1]
            usb-cutout
            jack-hole
            ic-pins-cutout
            ic-body-cutout))))))

(def cherry-mx
  (translate [0 0 (/ (:switch-sep opts) 2)]
    (union
      (include "cherry_mx.scad")           
      (translate [0 0 (:switch-sep opts)]
        (call-module "keycap")))))

(def ec11-encoder
  (union
    (translate [0 0 -3.5]
      (cube 12 12 7))
    (cylinder 7.5 15 :center nil)
    ;; (cylinder 3.5 7 :center nil)
    ;; (translate [0 0 7]
    ;;   (cylinder 12.5 8 :center nil))
    ))

(spit "wow.scad"
      (write-scad
       (use "cap.scad")
       (use "../ext/scad-redox-case/Lenbok_Utils/utils.scad")
       ;; (translate [-16 -70 (- (:plate-thickness opts))]
       ;;            ec11-encoder)
       (kbd
         (concat
           ;; columns
           (col 3 (* -3 (+ (:switch-size opts) (:switch-sep opts))) 33)
           (col 3 (* -2 (+ (:switch-size opts) (:switch-sep opts))) 33)
           (col 3 (* -1 (+ (:switch-size opts) (:switch-sep opts))) 10)
           (col 3 (*  0 (+ (:switch-size opts) (:switch-sep opts))) 0)
           (col 3 (*  1 (+ (:switch-size opts) (:switch-sep opts))) 9)
           (col 3 (*  2 (+ (:switch-size opts) (:switch-sep opts))) 10)

           ;; thumb is rotating around its joint so the thumb keys
           ;; are located on an arc
           (let [angle (deg->rad 12)
                 l 100 cx 5 cy -167]
             (->>
               (range 4)
               (map #(vector
                       (+ cx (* l (Math/cos (- halfpi (* %1 angle)))))
                       (+ cy (* l (Math/sin (- halfpi (* %1 angle)))))
                       (- (* %1 angle))))
               (map-indexed
                 #(case %1
                    ;; shift leftmost key a little for better reachability
                    0 (map + [0 -6 0] %2)       
                    %2)))))

         :ic-loc
         [(+ (* 3 (:switch-sep opts))
            (* 2.5 (:switch-size opts)))
          -3.1 0]

         :ext
         [(fn encoder [] (translate [-16 -70] (square 28 28)))]
         :ext-holes
         [(fn encoder-hole []
            (translate [-16 -70 -5] (polyhole 3.5 10)))]

         :tent-loc
         [[[22 6] halfpi]
          [[70 -71] (deg->rad 55)]
          [[-36 -16] (deg->rad 135)]
          [[-73 -70] pi]])))

(spit "test-keyb.scad"
  (write-scad
    (use "cap.scad")
    (use "controller.scad")
    (use "../ext/scad-redox-case/Lenbok_Utils/utils.scad")
    ;; (translate [21 -9.6 0] (call-module 'promicro))
    ;; (translate (map +
    ;; (map + [(+ (* 1 (:switch-sep opts))
    ;;                        (* 0.5 (:switch-size opts)))

    ;;                     (+ 2 (:switch-sep opts) -0.1) 0])
    ;;                         jack-loc
    ;;                        [ic-rect-x 0
    ;;                         (- (+ (:plate-thickness opts)
    ;;                               (/ (- (:total-height opts)
    ;;                                     (:plate-thickness opts))
    ;;                                  2)))])
    ;;                            (rotate [0 halfpi 0] (polyhole 3 13)))
    (kbd 
      (concat
        (col 3 (* 0 (+ (:switch-size opts) (:switch-sep opts))) 0)
        (col 3 (* -1 (+ (:switch-size opts) (:switch-sep opts))) 0)
        (col 3 (* -2 (+ (:switch-size opts) (:switch-sep opts))) 0))

      :ic-loc
      (map + [(+ (* 1 (:switch-sep opts))
                (* 0.5 (:switch-size opts)))

              (+ 2 (:switch-sep opts) -0.1) 0])
      :tent-loc
      [[[24 -49] (- halfpi)]])))

(spit "calibrate.scad"
  (write-scad

    (let [allholes
          (fn [c]
            (->>
              (range -2 3 1)
              (map #(translate [(* 19 %1) 0 0]
                      (let [s (+ 14 (* %1 0.1))]
                        (c s))))))
          
          holes (allholes #(square %1 %1))
          clamps (allholes #(translate [0 0 2]
                              (union
                                (cube 4 (+ %1 1) 4)
                                (cube (+ %1 1) 4 4))))
          signs (allholes #(translate [-5 8 0] (text (str %1) :size 3)))
          perimeter (offset {:delta 5} holes)]

      (union
        (translate [0 0 2.5]
          (extrude-linear {:height 0.4 :center nil} signs))
        (difference
          (extrude-linear {:height 2.5 :center nil} perimeter)
          (extrude-linear {:height 2.5 :center nil} holes)

          (translate [0 0 1.5] clamps))))))


(defn d2 [d]
  (/ (Math/round (* d 100.0)) 100.0))

;; (spit "keyb.json"
;;   (json/write-str
;;     (let [min-x (Math/abs (apply min (map first layout)))
;;           min-y (Math/abs (apply min (map second layout)))]

;;       (first
;;        (reduce (fn [[acc [px py]] [x y a]]
;;                  (let [nx (+ min-x x)
;;                        ny (+ min-y y)
;;                        rx (/ nx 19)
;;                        ry (- (inc (/ (- ny py) 19)))]
;;                    [(conj acc [
;;                                (if (> (Math/abs a) 0.01)
;;                                  {:r (- (rad->deg a))
;;                                   :x (- (d2 rx)) :y (- (d2 ry))
;;                                   :rx (d2 rx) :ry (d2 ry)
;;                                   }
;;                                  {:x (d2 rx) :y (d2 ry)})
;;                                "k"]) [nx ny]]))
;;                [[] [0 (+ 38 min-y)]]
;;                layout)))
;;     ))

1
