;; Energy Entity Verification Contract
;; Simple validation of energy sector participants

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ENTITY_EXISTS (err u101))
(define-constant ERR_ENTITY_NOT_FOUND (err u102))

;; Data Variables
(define-data-var next-entity-id uint u1)

;; Data Maps
(define-map entities
  { entity-id: uint }
  {
    name: (string-ascii 100),
    owner: principal,
    verified: bool,
    sector: (string-ascii 50)
  }
)

(define-map entity-by-owner
  { owner: principal }
  { entity-id: uint }
)

;; Read-only functions
(define-read-only (get-entity (entity-id uint))
  (map-get? entities { entity-id: entity-id })
)

(define-read-only (is-verified-entity (entity-id uint))
  (match (get-entity entity-id)
    entity (get verified entity)
    false
  )
)

;; Public functions
(define-public (register-entity (name (string-ascii 100)) (sector (string-ascii 50)))
  (let ((entity-id (var-get next-entity-id)))
    (asserts! (is-none (map-get? entity-by-owner { owner: tx-sender })) ERR_ENTITY_EXISTS)

    (map-set entities
      { entity-id: entity-id }
      {
        name: name,
        owner: tx-sender,
        verified: false,
        sector: sector
      }
    )

    (map-set entity-by-owner
      { owner: tx-sender }
      { entity-id: entity-id }
    )

    (var-set next-entity-id (+ entity-id u1))
    (ok entity-id)
  )
)

(define-public (verify-entity (entity-id uint))
  (let ((entity (unwrap! (get-entity entity-id) ERR_ENTITY_NOT_FOUND)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)

    (map-set entities
      { entity-id: entity-id }
      (merge entity { verified: true })
    )
    (ok true)
  )
)
