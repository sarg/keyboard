(use-modules (gnu packages firmware)
             (guix utils)
             (guix gexp))
(make-qmk-firmware "sarg" "default"
                   #:description "Firmware for my keyb"
                   #:keyboard-source-directory
                   (local-file "./firmware" #:recursive? #t))
