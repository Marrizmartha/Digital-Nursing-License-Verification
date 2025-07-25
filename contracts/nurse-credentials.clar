;; NurseCredentials - Digital Nursing License Verification System
;; This contract manages and verifies nursing credentials on the Stacks blockchain

(define-map nurses
  { nurse-id: uint }
  {
    principal: principal,
    license-number: (string-ascii 20),
    license-type: (string-ascii 50),
    issue-date: uint,
    expiry-date: uint,
    issuing-authority: (string-ascii 100),
    is-active: bool
  }
)

(define-map license-verifications
  { verification-id: uint }
  {
    nurse-id: uint,
    verifier: principal,
    verification-block: uint,
    status: (string-ascii 20)
  }
)

(define-data-var next-nurse-id uint u1)
(define-data-var next-verification-id uint u1)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-expired (err u102))
(define-constant err-invalid-input (err u103))

;; Register a new nurse credential
(define-public (register-nurse
  (license-number (string-ascii 20))
  (license-type (string-ascii 50))
  (issue-date uint)
  (expiry-date uint)
  (issuing-authority (string-ascii 100))
)
  (let
    (
      (nurse-id (var-get next-nurse-id))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> expiry-date issue-date) err-invalid-input)
    (asserts! (> (len license-number) u0) err-invalid-input)
    
    (map-set nurses
      { nurse-id: nurse-id }
      {
        principal: tx-sender,
        license-number: license-number,
        license-type: license-type,
        issue-date: issue-date,
        expiry-date: expiry-date,
        issuing-authority: issuing-authority,
        is-active: true
      }
    )
    
    (var-set next-nurse-id (+ nurse-id u1))
    (ok nurse-id)
  )
)

;; Verify a nurse's credentials
(define-public (verify-credentials (nurse-id uint))
  (let
    (
      (nurse-data (unwrap! (map-get? nurses { nurse-id: nurse-id }) err-not-found))
      (verification-id (var-get next-verification-id))
    )
    (asserts! (get is-active nurse-data) err-not-found)
    (asserts! (> (get expiry-date nurse-data) stacks-block-height) err-expired)
    
    (map-set license-verifications
      { verification-id: verification-id }
      {
        nurse-id: nurse-id,
        verifier: tx-sender,
        verification-block: stacks-block-height,
        status: "verified"
      }
    )
    
    (var-set next-verification-id (+ verification-id u1))
    (ok true)
  )
)

;; Get nurse information
(define-read-only (get-nurse (nurse-id uint))
  (map-get? nurses { nurse-id: nurse-id })
)

;; Check if license is valid
(define-read-only (is-license-valid (nurse-id uint))
  (match (map-get? nurses { nurse-id: nurse-id })
    nurse-data
    (and 
      (get is-active nurse-data)
      (> (get expiry-date nurse-data) stacks-block-height)
    )
    false
  )
)

;; Deactivate a license
(define-public (deactivate-license (nurse-id uint))
  (let
    (
      (nurse-data (unwrap! (map-get? nurses { nurse-id: nurse-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    
    (map-set nurses
      { nurse-id: nurse-id }
      (merge nurse-data { is-active: false })
    )
    (ok true)
  )
)

;; Get verification history
(define-read-only (get-verification (verification-id uint))
  (map-get? license-verifications { verification-id: verification-id })
)