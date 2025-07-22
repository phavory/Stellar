# StellarDomains - Cosmic Real Estate Platform 

A decentralized NFT-based real estate platform built on the Stacks blockchain, allowing users to create, rent, and trade virtual cosmic properties with built-in royalty mechanisms.

##  Features

- **NFT Property System**: Each plot is represented as a unique non-fungible token
- **Rental Marketplace**: Property owners can list their plots for rent
- **Developer Royalties**: Original developers earn fees on all future transactions
- **Overlord Governance**: Administrative control with secure succession mechanisms
- **Coordinate-Based Properties**: Properties defined by string coordinates in cosmic space

##  Contract Overview

### Core Components

- **Property NFTs**: `stellar-plot` tokens representing individual cosmic plots
- **Registry System**: Complete property records with ownership and development history
- **Rental Market**: Active marketplace for property leasing
- **Fee Distribution**: Automatic royalty payments to original developers

## Functions

### Administrative Functions

#### `crown-overlord(heir: principal)`
Transfer overlord privileges to a new principal.
- **Access**: Current overlord only
- **Validation**: Ensures heir is a valid standard principal and different from current overlord
- **Returns**: `(ok true)` on success

#### `identify-overlord()`
Returns the current overlord's principal.
- **Access**: Public read-only
- **Returns**: `(ok principal)`

### Property Management

#### `establish-plot(coordinates: string-ascii, tax-rate: uint)`
Create a new cosmic property plot.
- **Parameters**: 
  - `coordinates`: Location string (max 256 characters)
  - `tax-rate`: Developer fee rate (max 1000 = 10.00%)
- **Returns**: Plot number on success
- **NFT**: Mints new `stellar-plot` token to creator

#### `survey-property(plot-num: uint)`
Get complete property information.
- **Access**: Public read-only
- **Returns**: Property details including landlord, developer, coordinates, and tax rate

### Rental System

#### `advertise-rental(plot-num: uint, rent-price: uint)`
List a property for rent.
- **Access**: Property owner only
- **Parameters**: Plot number and rent price in STX
- **Requirements**: Must own the NFT, price > 0

#### `withdraw-listing(plot-num: uint)`
Remove property from rental market.
- **Access**: Current lessor only
- **Effect**: Removes listing from rental board

#### `secure-lease(plot-num: uint)`
Purchase a rental property (transfers ownership).
- **Payment**: Automatically splits payment between lessor and original developer
- **NFT Transfer**: Moves ownership to buyer
- **Registry Update**: Updates landlord information

#### `browse-rental(plot-num: uint)`
View rental listing details.
- **Access**: Public read-only
- **Returns**: Rent price and lessor information

##  Economics

### Fee Structure
- **Developer Tax**: Set per property (0-10.00%)
- **Revenue Split**: 
  - Developer receives: `(rent-price × tax-rate) / 10000`
  - Lessor receives: Remainder after developer cut

### Example Transaction
```
Rent Price: 1000 STX
Tax Rate: 500 (5.00%)
Developer Cut: 50 STX
Lessor Earnings: 950 STX
```

##  Security Features

- **Ownership Validation**: All functions verify proper ownership before execution
- **Input Sanitization**: Coordinates must be non-empty, tax rates capped at 10%
- **Principal Validation**: Overlord succession requires valid standard principals
- **Reentrancy Protection**: Uses Stacks built-in transaction atomicity

##  Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `status-forbidden-overlord` | Unauthorized overlord operation |
| u101 | `status-unauthorized-landlord` | Not the property owner |
| u102 | `status-vacant-listing` | Property not listed for rent |
| u103 | `status-unreasonable-rent` | Invalid rent price (≤ 0) |
| u104 | `status-nonexistent-property` | Property doesn't exist |
| u105 | `status-corrupted-coordinates` | Invalid coordinate string |
| u106 | `status-outrageous-tax` | Tax rate exceeds 10% |
| u107 | `status-invalid-heir` | Invalid overlord succession |

##  Getting Started

### Prerequisites
- Stacks wallet (Hiro Wallet recommended)
- STX tokens for transactions
- Clarity CLI for local development

### Deployment
```bash
# Check contract syntax
clarinet check

# Run tests
clarinet test

# Deploy to testnet
clarinet deploy --testnet
```

### Example Usage

1. **Create a Property**:
   ```clarity
   (contract-call? .stellar-domains establish-plot "Sector-7G-Alpha-Prime" u250)
   ```

2. **List for Rent**:
   ```clarity
   (contract-call? .stellar-domains advertise-rental u1 u1000)
   ```

3. **Purchase Rental**:
   ```clarity
   (contract-call? .stellar-domains secure-lease u1)
   ```

## 🔍 Data Structures

### Property Registry
```clarity
{
  plot-num: uint,
  landlord: principal,     ; Current owner
  developer: principal,    ; Original creator (receives royalties)
  coordinates: string-ascii,
  tax-rate: uint          ; Royalty rate (basis points)
}
```

### Rental Listings
```clarity
{
  plot-num: uint,
  rent-price: uint,       ; Price in STX
  lessor: principal       ; Current renter/owner
}
```

##  Important Notes

- **Ownership Transfer**: `secure-lease` transfers full ownership, not just rental rights
- **Permanent Royalties**: Developer tax applies to all future transactions
- **Coordinate Uniqueness**: No built-in coordinate uniqueness validation
- **STX Requirements**: Buyers must have sufficient STX for rent + gas fees

##  Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request


