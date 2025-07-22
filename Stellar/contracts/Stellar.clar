;; StellarDomains Cosmic Real Estate Platform

;; Status codes
(define-constant status-forbidden-overlord (err u100))
(define-constant status-unauthorized-landlord (err u101))
(define-constant status-vacant-listing (err u102))
(define-constant status-unreasonable-rent (err u103))
(define-constant status-nonexistent-property (err u104))
(define-constant status-corrupted-coordinates (err u105))
(define-constant status-outrageous-tax (err u106))
(define-constant status-invalid-heir (err u107))

;; Property NFT
(define-non-fungible-token stellar-plot uint)

;; Control variables
(define-data-var overlord principal tx-sender)
(define-data-var plot-sequence uint u1)

;; Property records
(define-map cosmic-registry
  { plot-num: uint }
  { landlord: principal, developer: principal, coordinates: (string-ascii 256), tax-rate: uint }
)

;; Rental market
(define-map rental-board
  { plot-num: uint }
  { rent-price: uint, lessor: principal }
)

;; Internal validation: overlord privileges
(define-private (validate-overlord)
  (is-eq tx-sender (var-get overlord))
)

;; Succession of overlord with proper validation
(define-public (crown-overlord (heir principal))
  (begin
    (asserts! (validate-overlord) status-forbidden-overlord)
    ;; Validate the heir principal
    (asserts! (is-standard heir) status-invalid-heir)
    (asserts! (not (is-eq heir (var-get overlord))) status-invalid-heir)
    (ok (var-set overlord heir))
  )
)

;; Display overlord identity
(define-read-only (identify-overlord)
  (ok (var-get overlord))
)

;; Establish new property
(define-public (establish-plot (coordinates (string-ascii 256)) (tax-rate uint))
  (let
    (
      (plot-num (var-get plot-sequence))
    )
    (asserts! (> (len coordinates) u0) status-corrupted-coordinates)
    (asserts! (<= tax-rate u1000) status-outrageous-tax)
    (try! (nft-mint? stellar-plot plot-num tx-sender))
    (map-set cosmic-registry
      { plot-num: plot-num }
      { landlord: tx-sender, developer: tx-sender, coordinates: coordinates, tax-rate: tax-rate }
    )
    (var-set plot-sequence (+ plot-num u1))
    (ok plot-num)
  )
)

;; Advertise property rental
(define-public (advertise-rental (plot-num uint) (rent-price uint))
  (let
    (
      (property-owner (unwrap! (nft-get-owner? stellar-plot plot-num) status-nonexistent-property))
    )
    (asserts! (> rent-price u0) status-unreasonable-rent)
    (asserts! (is-eq tx-sender property-owner) status-unauthorized-landlord)
    (map-set rental-board
      { plot-num: plot-num }
      { rent-price: rent-price, lessor: tx-sender }
    )
    (ok true)
  )
)

;; Remove rental advertisement
(define-public (withdraw-listing (plot-num uint))
  (let
    (
      (rental-info (unwrap! (map-get? rental-board { plot-num: plot-num }) status-vacant-listing))
    )
    (asserts! (< plot-num (var-get plot-sequence)) status-nonexistent-property)
    (asserts! (is-eq tx-sender (get lessor rental-info)) status-unauthorized-landlord)
    (map-delete rental-board { plot-num: plot-num })
    (ok true)
  )
)

;; Secure property lease
(define-public (secure-lease (plot-num uint))
  (let
    (
      (rental-terms (unwrap! (map-get? rental-board { plot-num: plot-num }) status-vacant-listing))
      (lease-cost (get rent-price rental-terms))
      (current-lessor (get lessor rental-terms))
      (property-details (unwrap! (map-get? cosmic-registry { plot-num: plot-num }) status-nonexistent-property))
      (original-developer (get developer property-details))
      (development-fee (get tax-rate property-details))
      (developer-cut (/ (* lease-cost development-fee) u10000))
      (lessor-earnings (- lease-cost developer-cut))
    )
    (asserts! (< plot-num (var-get plot-sequence)) status-nonexistent-property)
    (try! (stx-transfer? developer-cut tx-sender original-developer))
    (try! (stx-transfer? lessor-earnings tx-sender current-lessor))
    (try! (nft-transfer? stellar-plot plot-num current-lessor tx-sender))
    (map-set cosmic-registry
      { plot-num: plot-num }
      (merge property-details { landlord: tx-sender })
    )
    (map-delete rental-board { plot-num: plot-num })
    (ok true)
  )
)

;; Survey property information
(define-read-only (survey-property (plot-num uint))
  (ok (unwrap! (map-get? cosmic-registry { plot-num: plot-num }) status-nonexistent-property))
)

;; Browse rental listings
(define-read-only (browse-rental (plot-num uint))
  (ok (unwrap! (map-get? rental-board { plot-num: plot-num }) status-vacant-listing))
)