(use-modules (guix packages)
             (gnu packages)
             (guix git-download)
             ((guix licenses) #:prefix license:)
             (guix build-system python))

(define-public python-hjson
  (package
   (name "python-hjson")
   (version "3.0.1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/hjson/hjson-py")
           (commit "2e7cfe0352564937370716a3b33959ecf8100cc2")))
     (file-name (git-file-name name version))
     (sha256
      (base32 "1mn44cxax2sk5pzrjgx0n2p56pshwbbn5f1pyb7g33sikda51dkm"))))
   (build-system python-build-system)
   (home-page "http://github.com/hjson/hjson-py")
   (synopsis "Hjson, a user interface for JSON.")
   (description "Hjson, a user interface for JSON.")
   (license license:expat)))

(concatenate-manifests
 (list
  (specifications->manifest
   '("openscad"
     "bash" "gawk" "coreutils" "findutils" "grep" "sed" "diffutils"
     "python-appdirs" "python-argcomplete" "python-colorama"

     "avr-toolchain@4"
     "make"
     "python"
     "openjdk"
     "leiningen"))
  (packages->manifest
   `((,python-hjson "out")))))
