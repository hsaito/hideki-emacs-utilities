;; -*- coding: utf-8; lexical-binding: t -*-
;; Script for Setting Up Connection to IRC Through Proxy Using ERC
;; Personally intended for SOCKS proxy established by SSH.

(provide 'erc-proxy)

(defun setup-localproxy()
  "Setup Emacs for using local SOCKS proxy for ERC"
  (interactive)
  
  (require 'socks)
  (setq socks-noproxy '("localhost"))
  (setq socks-override-functions 1)
  (setq erc-server-connect-function 'socks-open-network-stream)

  ;; ssh port number for dynamic forwarding
  (setq socks-server '("ssh" "localhost" 24123 5)))

(defun unsetup-localproxy()
  "Unsetup Emacs for using local SOCKS proxy for ERC"
  (interactive)
  
  (require 'socks)
  (setq socks-noproxy nil)
  (setq socks-override-funcions nil)
  (setq erc-server-connect-function 'open-network-stream)
  )

(defun erc-through-proxy()
  "Setup local proxy and connect to IRC"
  (interactive)
  (setup-localproxy)
  (erc)
  )

(defun erc-direct-connection()
  "Unsetup local proxy and connect to IRC"
  (interactive)
  (unsetup-localproxy)
  (erc)
  )
