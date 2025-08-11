(use-modules (gnu packages firmware)
             (guix utils)
             (guix packages)
             (guix build-system copy)
             (guix build-system gnu)
             (guix git-download)
             (gnu packages commencement)
             (gnu packages pkg-config)
             (gnu packages libusb)
             ((guix licenses) #:prefix license:)
             (guix gexp))

(define qmk-headers
  (package
    (name "qmk-headers")
    (version "0.29.12")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/qmk/qmk_firmware")
              (commit version)))
       (file-name (git-file-name "qmk-firmware" version))
       (sha256
        (base32
         "16rmyjhxgpiqkkfkk5v5ighzwww2d96gdjiwq0wgz1fkmdxfj2ik"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:install-plan
      #~'(("quantum" "/" #:include-regexp (".*.h")))))
    (home-page #f)
    (synopsis #f)
    (description #f)
    (license #f)))

(define write-eeprom
  (package
    (name "write-eeprom")
    (version "0.0.1")
    (source
     (local-file "./write_eeprom" #:recursive? #t))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:make-flags
      #~(list (string-append "PREFIX=" #$output)
              (string-append "CC=" #$(cc-for-target))
              (let ((hdr (assoc-ref %build-inputs "qmk-headers")))
                (string-append
                 "CFLAGS=-I" hdr " -I" hdr "/sequencer -I" hdr "/keymap_extras")))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure))))
    (inputs (list hidapi))
    (native-inputs (list gcc-toolchain
                         pkg-config
                         qmk-headers))
    (home-page #f)
    (synopsis #f)
    (description #f)
    (license #f)))

write-eeprom
