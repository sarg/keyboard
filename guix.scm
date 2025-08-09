(use-modules (gnu packages firmware)
             (guix utils)
             (guix packages)
             (guix git-download)
             (guix gexp))

(let ((base
       (make-qmk-firmware "sarg" "default"
                          #:description "Firmware for my keyb"
                          #:keyboard-source-directory
                          (local-file "./firmware" #:recursive? #t))))
  (package
    (inherit base)
    (name "qmk-firmware-sarg")
    (version "0.29.12")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/qmk/qmk_firmware")
                     (commit version)))
              (file-name (git-file-name "qmk-firmware" version))
              (sha256
               (base32
                "16rmyjhxgpiqkkfkk5v5ighzwww2d96gdjiwq0wgz1fkmdxfj2ik"))))))
