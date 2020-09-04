(ns keyb
  (:gen-class)
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

(def ic-w 18.5)
(def ic-h 34)
(def ic-z 4)

(defn d2 [d] (/ (Math/round (* d 100.0)) 100.0))

(defn col [cnt cx cy]
  (->> (range cnt)
    (map #(* (+ (:switch-size opts) (:switch-sep opts)) %1))
    (map #(vector cx (- (+ cy %1)) 0))))

(def switch-hole
  ;; shrink hole a little for a better switch fit
  (let [f (- (:switch-size opts) 0.2)]
    (square f f)))

(defn keyiter [layout f]
  (->> layout
    (map (fn [[x y a]]
           (->> f
             (rotatec [0 0 a])
             (translate [x y 0]))))))

(defmacro round-corners [r & b]
  `(offset (- ~r) (offset ~r ~@b)))

(def ic-rect
  (mirror [0 1 0]
    (square ic-w ic-h :center nil)))

(def ic-pin-cutout
  (let [w 2.8]
    (->>
      (square (- ic-w (* w 2))
        ic-h :center nil)
      (translate [w (- ic-h) 0])
      (difference ic-rect)
      (resize [0 (- ic-h 0.5) 0])
      (translate [0 -0.5 0]))))

(def jack-d 9)
(def jack-loc
  [0
   (- (+ (:switch-sep opts) (/ jack-d 2) ic-h))
   0])

(defn perimeter [layout ic-loc ext]
  (round-corners
    8
    (translate ic-loc
      (offset {:delta (:switch-sep opts)} ic-rect)

      (translate (map + jack-loc [0 (:switch-sep opts) 0]) 
        (offset {:delta (:switch-sep opts)}
          (mirror [0 1 0] (square ic-w jack-d :center nil)))))

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
(defmacro rounded-slot [& args] `(call-module 'slot ~@args))

(defn tent-hole [h]
  (with-center nil
    (mirror [0 0 1]
      (difference
        (extrude-chamfer {:chamfer 2.5 :faces [false true] :height h}
          (hull
            (translate [-6.5 0 0]
              (square 0.1 17 :center true))
            (translate [4.5 0 0]
              (circle (+ (/ 5 2) 2.5 1.5 1)))))
        
        (translate [4.5 0 -1]
          (with-fn 6 (cylinder (/ 9.2 2) (+ 5.5 0.1))) ;
          (polyhole (/ 5.4 2) (+ h 2)))))))

(defn tents [tent-list]
  (->> tent-list
    (map (fn [[[x y] a]]
           (translate [x y -0.04]
             (rotate [0 0 a]
               (tent-hole 8)))))
    (apply union)))

(defn kbd [layout & {:keys [ic-loc tent-loc ext ext-holes]}]
  (let [ic-body
        (mirror [0 0 1]
          (translate [0 0 1.5]
            (extrude-chamfer {:height ic-z :faces [false true]}
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
        (let [w 8.2 h 4]
          (translate [(/ ic-w 2)
                      (:wall-thickness opts)
                      (- ic-z 1 (/ h 2))]
            (cube w 8 h)))

        ic-pins-cutout
        (translate [0 0 ic-z]
          (extrude-linear {:height 1.5 :center nil}
            ic-pin-cutout))

        ic-body-cutout
        (translate [0 0 -1]
          (extrude-linear {:height (+ ic-z 1) :center nil}
            ic-rect))

        jack-z
        (/ (+ (:total-height opts) (:plate-thickness opts)) 2)

        jack-plate
        (translate [(+ ic-w (:switch-sep opts)) 0 (- jack-z)]
          (mirror [1 0 0]
            (translate [0 -6 -4.72]     ; fix hardcode maybe
              (cube (+ 1.6 (:wall-thickness opts)) 12 10 :center nil))))
        
        jack-hole
        (translate
          (map + jack-loc [ic-w 0 jack-z])
          (translate [(- (:switch-sep opts) (:wall-thickness opts)) 0 0]
            (rotate [0 halfpi 0] (polyhole 4.5 3))
            (translate [0 -4.5 0]
              (cube 3 9 9 :center nil)))
          (rotate [0 halfpi 0]
            (polyhole 3.1 (+ 1 (:switch-sep opts)))))
        
        ic-offset [0 (- (:switch-sep opts) 2) 0]]

    (union
      ;; (translate [0 0 -2.5 ] (keyiter layout cherry-mx))
      ;;
      (difference
        (union
          (translate (map + ic-loc ic-offset)
            ic-body
            (translate jack-loc jack-plate))
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

(defn -main [& args]

  (let [keymap
        (concat
         ["`" "esc" "tab"]
         (map str "qazwsxedcrfvtgb")
         ["win" "lalt" "lctrl" "space"])
      
        layout
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
                0 (apply vector (map + [0 -6 0] %2))       
                %2)))))

        keyboard
        (kbd layout
             :ic-loc
             [(+ (* 3 (:switch-sep opts))
                 (* 2.5 (:switch-size opts)))
              -3.1 0]

             :ext
             [(fn encoder [] (translate [-16 -70] (square 28 28)))]
             :ext-holes
             [(fn encoder-hole []
                (translate [-16 -70 0]
                           (translate [0 0 -5] (polyhole 3.6 10))
                           (translate [0 0 (- (:plate-thickness opts) 1.5)]
                             (extrude-linear {:height 3 :center nil}
                               (translate [(- 6 0.5) 0 0] (square 1 2))))))]

             :tent-loc
             [[[22 6] halfpi]
              [[70 -71] (deg->rad 55)]
              [[-36 -16] (deg->rad 135)]
              [[-73 -70] pi]])]

    (spit "_right.scad"
          (write-scad
           (use "cap.scad")
           (use "./scad-lenbok-utils/utils.scad")
           ;; (translate [-16 -70 (- (:plate-thickness opts))]
           ;;            ec11-encoder)
           (mirror [1 0 0] keyboard)))

    (spit "_left.scad"
          (write-scad
           (use "cap.scad")
           (use "./scad-lenbok-utils/utils.scad")
           keyboard))

    (spit "keyb.json"
          (json/write-str
           (let [min-x (Math/abs (apply min (map first layout)))
                 min-y (Math/abs (apply min (map second layout)))]

             (first
              (reduce (fn [[acc [px py]] [x y a n]]
                        (let [nx (+ min-x x)
                              ny (+ min-y y)
                              rx (/ nx 19)
                              ry (- (inc (/ (- ny py) 19)))]
                          [(conj acc [{:x (d2 rx) :y (d2 ry)} n]) [nx ny]]))
                      [[] [0 (+ 38 min-y)]]
                      (map conj layout keymap)))))))

  (spit "_test-keyb.scad"
        (write-scad
         (use "cap.scad")
         (use "./scad-lenbok-utils/utils.scad")
         ;; (translate [21 -9.6 0] (call-module 'promicro))
         ;; (translate (map +
         ;; (map + [(+ (* 1 (:switch-sep opts))
         ;;                        (* 0.5 (:switch-size opts)))

         ;;                     (+ 2 (:switch-sep opts) -0.1) 0])
         ;;                         jack-loc
         ;;                        [ic-w 0
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

  (spit "_calibrate.scad"
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

  (spit "_test-ic.scad"
        (write-scad
         (use "./scad-lenbok-utils/utils.scad")
         (kbd []
              :ic-loc [0 0 0]
              ;; :tent-loc [[[9 -55] (- halfpi)]]
              ))))

(-main)
1
