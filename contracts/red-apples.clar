
;; title: red-apples
;; version:
;; summary:
;; description:

;;;;;;;;;;;;;;;;;;;;; SIP 010 ;;;;;;;;;;;;;;;;;;;;;;
(impl-trait .sip-010-trait-ft-standard.sip-010-trait)

;; Defines the Red Apple token according to the SIP-010 Standard
(define-fungible-token red-apples)
(define-data-var token-uri (string-utf8 256) u"")
(define-constant CONTRACT-OWNER 'STRP7MYBHSMFH5EGN3HGX6KNQ7QBHVTBPF1669DW)

;; errors
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-UNAUTHORIZED-MINT (err u101))

;; ---------------------------------------------------------
;; SIP-10 Functions
;; ---------------------------------------------------------

(define-read-only (get-total-supply)
  (ok (ft-get-supply red-apples))
)

(define-read-only (get-name)
  (ok "RAPL")
)

(define-read-only (get-symbol)
  (ok "RAPL")
)

(define-read-only (get-decimals)
  (ok u0)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance red-apples account))
)

(define-read-only (get-balance-simple (account principal))
  (ft-get-balance red-apples account)
)


(define-public (set-token-uri (value (string-utf8 256)))
  (if (is-eq tx-sender CONTRACT-OWNER)
    (ok (var-set token-uri value))
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-read-only (get-token-uri)
  (ok (some (var-get token-uri)))
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)

    (match (ft-transfer? red-apples amount sender recipient)
      response (begin
        (print memo)
        (ok response)
      )
      error (err error)
    )
  )
)


(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender recipient) ERR-UNAUTHORIZED-MINT)
    (ft-mint? red-apples amount recipient)
  )
)

(define-public (burn (burner principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED-MINT)
    (ft-burn? red-apples amount burner)
  )
)
