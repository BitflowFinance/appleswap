
;; title: apple-lp
;; version:
;; summary:
;; description:

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-010-trait-ft-standard.sip-010-trait)



(define-fungible-token apple-lp)

(define-data-var token-uri (string-utf8 256) u"")

(define-constant CONTRACT-OWNER 'STRP7MYBHSMFH5EGN3HGX6KNQ7QBHVTBPF1669DW)
(define-data-var ALLOWED-MINTER principal 'STRP7MYBHSMFH5EGN3HGX6KNQ7QBHVTBPF1669DW)



;; errors
(define-constant ERR-UNAUTHORIZED-MINT (err u100))
(define-constant ERR-ZERO-MINT (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply apple-lp))
)

(define-read-only (get-name)
  (ok "APPLE-LP")
)

(define-read-only (get-symbol)
  (ok "APPLE-LP")
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance apple-lp account))
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)

    (match (ft-transfer? apple-lp amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)

(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-uri value))
    ERR-NOT-AUTHORIZED
  )
)

;; Change the minter to any other principal, can only be called the current minter
(define-public (set-minter (who principal))
  (begin
    (asserts! (is-eq tx-sender (var-get ALLOWED-MINTER)) ERR-UNAUTHORIZED-MINT)
    ;; who is unchecked, we allow the minter to make whoever they like the new minter
    ;; #[allow(unchecked_data)]
    (ok (var-set ALLOWED-MINTER who))
  )
)

(define-public (mint (amount uint) (who principal))
  (begin
    ;; (asserts! (is-eq tx-sender (var-get ALLOWED-MINTER)) ERR-UNAUTHORIZED-MINT)
    (asserts! (> amount u0) ERR-ZERO-MINT)
    ;; amount, who are unchecked, but we let the contract owner mint to whoever they like for convenience
    ;; #[allow(unchecked_data)]
    (ft-mint? apple-lp amount who)
  )
)


(define-public (burn (burner principal) (amount uint))
  (begin
    ;; (asserts! (is-eq tx-sender (var-get ALLOWED-MINTER)) ERR-UNAUTHORIZED-MINT)
    ;; #[allow(unchecked_data)]
    (ft-burn? apple-lp amount burner)
  )
)
