# UPI QR Codes: Static vs Dynamic

## Overview

UPI (Unified Payments Interface) QR codes in India come in two distinct types: **Static QR Codes** and **Dynamic QR Codes**. Understanding the difference is crucial for building payment applications, as they have fundamentally different architectures and use cases.

---

## 📋 Table of Contents

1. [Static QR Codes](#static-qr-codes)
2. [Dynamic QR Codes](#dynamic-qr-codes)
3. [Key Differences](#key-differences)
4. [Technical Details](#technical-details)
5. [Why Dynamic QR Codes Can't Be Supported](#why-dynamic-qr-codes-cant-be-supported)
6. [How to Identify Each Type](#how-to-identify-each-type)
7. [Use Cases](#use-cases)
8. [Examples](#examples)

---

## Static QR Codes

### What They Are

**Static QR codes** contain all payment information directly embedded in the QR code itself. The QR code data includes:
- Merchant's UPI ID (permanent)
- Merchant name
- Optional: Fixed amount (if specified)
- Optional: Transaction note/reference

### Characteristics

✅ **Permanent** - The QR code never expires  
✅ **Reusable** - Can be scanned multiple times  
✅ **Self-contained** - All payment data is in the QR code  
✅ **No server dependency** - Works offline (for reading)  
✅ **Simple** - Easy to generate and use  
✅ **Suitable for small merchants** - Individuals, small shops, freelancers  

### Example QR Code Data

```
upi://pay?pa=merchant@oksbi&pn=John%20Doe&am=100.00&cu=INR&tn=Payment%20for%20services
```

**Parsed:**
- **pa** (payee address): `merchant@oksbi` ← This is the UPI ID
- **pn** (payee name): `John Doe`
- **am** (amount): `100.00` (optional)
- **cu** (currency): `INR`
- **tn** (transaction note): `Payment for services` (optional)

### How They Work

1. Merchant generates a QR code with their UPI ID
2. Customer scans the QR code
3. Payment app extracts UPI ID directly from QR code
4. Customer enters amount (if not specified) and pays
5. Payment goes directly to merchant's UPI ID

**No server communication required** to read the QR code.

---

## Dynamic QR Codes

### What They Are

**Dynamic QR codes** contain a **temporary reference** or **URL** that points to a payment gateway server. The actual payment details are **not** in the QR code itself - they're stored on a server and fetched dynamically.

### Characteristics

⏰ **Time-limited** - Expires after a few minutes (typically 5-15 minutes)  
🔒 **Single-use** - Can only be used once  
🌐 **Server-dependent** - Requires internet connection to resolve  
🔄 **Generated on-demand** - Created when payment is initiated  
🏢 **Used by large merchants** - E-commerce, POS systems, payment gateways  
🔐 **May require authentication** - Some gateways need merchant credentials  

### Example QR Code Data

```
upi://pay?pa=temp123@razorpay&pn=Merchant&url=https://api.razorpay.com/v1/qr/xyz789abc
```

**Parsed:**
- **pa** (payee address): `temp123@razorpay` ← **NOT the real merchant UPI ID!**
- **pn** (payee name): `Merchant`
- **url** (redirect URL): `https://api.razorpay.com/v1/qr/xyz789abc` ← **Key indicator!**

### How They Work

1. Merchant initiates payment on their system (POS/e-commerce)
2. Payment gateway generates a **temporary QR code** with a unique reference
3. Customer scans the QR code
4. Payment app must **make an HTTP request** to the URL in the QR code
5. Server returns actual payment details (merchant UPI ID, amount, etc.)
6. Customer pays using the resolved details
7. QR code expires after payment or timeout

**Requires server communication** to resolve the actual payment details.

---

## Key Differences

| Feature | Static QR Code | Dynamic QR Code |
|---------|---------------|-----------------|
| **Data Location** | Embedded in QR code | On server (URL in QR code) |
| **Validity** | Permanent | Expires in minutes |
| **Reusability** | Unlimited | Single-use only |
| **Internet Required** | No (for reading) | Yes (to resolve) |
| **UPI ID in QR** | Real merchant UPI ID | Temporary gateway ID |
| **Amount** | Optional (can be fixed) | Usually required |
| **Generation** | One-time generation | Generated per transaction |
| **Use Case** | Small merchants, individuals | Large merchants, POS systems |
| **Complexity** | Simple | Complex (requires server) |
| **Examples** | Street vendors, small shops | Razorpay, Paytm POS, PhonePe |

---

## Technical Details

### Static QR Code Format

```
upi://pay?pa=<UPI_ID>&pn=<NAME>&am=<AMOUNT>&cu=<CURRENCY>&tn=<NOTE>
```

**Parameters:**
- `pa` - Payee Address (UPI ID) - **Required**
- `pn` - Payee Name - Optional
- `am` - Amount - Optional
- `cu` - Currency (default: INR) - Optional
- `tn` - Transaction Note - Optional
- `tr` - Transaction Reference - Optional
- `mc` - Merchant Code - Optional

### Dynamic QR Code Format

```
upi://pay?pa=<TEMP_GATEWAY_ID>&pn=<NAME>&url=<RESOLUTION_URL>
```

**Key Indicator:** Presence of `url` parameter

**Additional Parameters (may vary):**
- `pa` - Temporary gateway UPI ID (not real merchant ID)
- `url` - **Server URL to resolve payment details** - **Required for dynamic**
- `pn` - Merchant name (may be generic)
- Other gateway-specific parameters

### URL Resolution Process (Dynamic QR)

When a dynamic QR code is scanned:

1. **Extract URL** from `url` parameter
2. **Make HTTP GET request** to the URL
3. **Server responds** with JSON containing:
   ```json
   {
     "upiId": "realmerchant@oksbi",
     "amount": 100.00,
     "currency": "INR",
     "merchantName": "Actual Merchant Name",
     "expiresAt": "2024-01-20T12:30:00Z"
   }
   ```
4. **Use resolved data** for payment

**Problems with this approach:**
- Requires server-side integration with each payment gateway
- Each gateway has different API formats
- Requires authentication/API keys in many cases
- Time-sensitive (expires quickly)
- Complex error handling

---

## Why Dynamic QR Codes Can't Be Supported

### Technical Limitations

1. **Server-Side Processing Required**
   - Must make HTTP requests to resolve payment details
   - Each payment gateway has different APIs
   - Requires API keys/authentication for many gateways

2. **Gateway-Specific Implementation**
   - Razorpay has one format
   - Paytm has another
   - PhonePe has another
   - Would need to support dozens of gateways

3. **Time Sensitivity**
   - QR codes expire in minutes
   - User might scan an expired code
   - Complex error handling for timeouts

4. **Security Concerns**
   - Need to validate server responses
   - Risk of malicious URLs
   - Requires certificate pinning

5. **Architecture Mismatch**
   - PlebQR India is designed for **direct peer-to-peer payments**
   - Dynamic QR codes require **centralized gateway integration**
   - Goes against the app's philosophy

### Business Limitations

1. **API Access**
   - Payment gateways don't provide public APIs for resolving dynamic QR codes
   - Would need partnerships with each gateway
   - Commercial agreements required

2. **Cost**
   - API calls cost money
   - Would need to maintain gateway integrations
   - Ongoing maintenance burden

3. **User Experience**
   - Adds latency (network request)
   - More failure points
   - Confusing error messages

---

## How to Identify Each Type

### Static QR Code Indicators

✅ **Has `pa` parameter with real-looking UPI ID** (e.g., `merchant@oksbi`)  
✅ **No `url` parameter**  
✅ **Can be scanned multiple times**  
✅ **Works immediately without network** (for reading)  
✅ **UPI ID format looks legitimate** (not `temp123@gateway`)  

### Dynamic QR Code Indicators

❌ **Has `url` parameter** - **Strongest indicator!**  
❌ **`pa` parameter contains temporary/gateway ID** (e.g., `temp123@razorpay`, `merchant@paytm`)  
❌ **Common gateway patterns in `pa`:**
   - `@razorpay`
   - `@paytm`
   - `@phonepe`
   - `@gateway`
   - `temp*@*` (temporary IDs)

### Detection Logic

```dart
bool isDynamicQrCode(Map<String, String> upiParams) {
  // Check for URL parameter (strongest indicator)
  if (upiParams.containsKey('url') && upiParams['url']!.isNotEmpty) {
    return true;
  }
  
  // Check for known gateway patterns in payee address
  final payeeAddress = upiParams['pa']?.toLowerCase() ?? '';
  final dynamicPatterns = [
    '@razorpay',
    '@paytm',
    '@phonepe',
    '@gateway',
    'temp',
  ];
  
  return dynamicPatterns.any((pattern) => payeeAddress.contains(pattern));
}
```

---

## Use Cases

### Static QR Codes Are Best For:

- 🏪 **Small merchants** - Street vendors, small shops
- 👤 **Individuals** - Freelancers, service providers
- 🏠 **Home businesses** - Home-based services
- 💰 **Fixed pricing** - Services with standard rates
- 🔄 **Recurring payments** - Same merchant, multiple transactions
- 📱 **Simple apps** - Direct peer-to-peer payments

### Dynamic QR Codes Are Used By:

- 🏢 **Large e-commerce platforms** - Amazon, Flipkart
- 🏬 **POS systems** - Retail stores with payment terminals
- 💳 **Payment gateways** - Razorpay, Paytm, PhonePe merchant solutions
- 🎫 **Event ticketing** - Time-sensitive transactions
- 🚕 **Ride-sharing** - Uber, Ola (amount calculated dynamically)
- 🍔 **Food delivery** - Swiggy, Zomato (order-specific payments)

---

## Examples

### Example 1: Static QR Code (Supported ✅)

**QR Code Data:**
```
upi://pay?pa=aniketambore0@oksbi&pn=Aniket%20Ambore&cu=INR
```

**Parsed:**
- UPI ID: `aniketambore0@oksbi` ← **Real merchant UPI ID**
- Name: `Aniket Ambore`
- Currency: `INR`
- **No `url` parameter** ← Static QR code

**Action:** Extract UPI ID directly, proceed with payment flow.

---

### Example 2: Dynamic QR Code (Not Supported ❌)

**QR Code Data:**
```
upi://pay?pa=temp123@razorpay&pn=Merchant&url=https://api.razorpay.com/v1/qr/abc123xyz
```

**Parsed:**
- UPI ID: `temp123@razorpay` ← **Temporary gateway ID, NOT real merchant!**
- Name: `Merchant` (generic)
- **Has `url` parameter** ← Dynamic QR code indicator

**Action:** Show error message:
> "Dynamic QR codes are not supported. This QR code requires server-side processing. Please ask the merchant for a static UPI QR code or enter their UPI ID manually."

---

### Example 3: Static QR Code with Amount (Supported ✅)

**QR Code Data:**
```
upi://pay?pa=shopkeeper@paytm&pn=Local%20Shop&am=250.00&cu=INR&tn=Grocery%20Purchase
```

**Parsed:**
- UPI ID: `shopkeeper@paytm` ← **Real merchant UPI ID**
- Name: `Local Shop`
- Amount: `250.00` (pre-filled, but user can change)
- Currency: `INR`
- Note: `Grocery Purchase`
- **No `url` parameter** ← Static QR code

**Action:** Extract UPI ID, optionally pre-fill amount, proceed with payment.

---

### Example 4: Dynamic QR Code from POS (Not Supported ❌)

**QR Code Data:**
```
upi://pay?pa=merchant@phonepe&url=https://merchant.phonepe.com/api/v1/qr/resolve?id=xyz789&token=abc123
```

**Parsed:**
- UPI ID: `merchant@phonepe` ← **Gateway ID, not real merchant**
- **Has `url` parameter with complex path** ← Dynamic QR code

**Action:** Show error message explaining dynamic QR codes are not supported.

---

## Summary

| Aspect | Static QR | Dynamic QR |
|--------|-----------|------------|
| **Support Status** | ✅ Supported | ❌ Not Supported |
| **Reason** | Self-contained, simple | Requires server integration |
| **User Action** | Scan and pay | Ask merchant for static QR or manual UPI ID entry |
| **App Behavior** | Extract UPI ID directly | Show helpful error message |

---

## For Developers

When implementing QR code scanning:

1. **Parse the UPI URL** to extract parameters
2. **Check for `url` parameter** - if present, it's dynamic
3. **Check `pa` parameter** for gateway patterns
4. **If static:** Extract UPI ID and proceed
5. **If dynamic:** Show user-friendly error message with guidance

**Error Message Template:**
> "This appears to be a dynamic QR code, which requires server-side processing that this app doesn't support.  
>   
> **What you can do:**  
> - Ask the merchant for a static UPI QR code  
> - Or enter the merchant's UPI ID manually in the app  
>   
> Static QR codes work permanently and can be scanned multiple times."

---

## References

- [UPI Deep Linking Specification](https://www.labnol.org/files/linking.pdf)
- [NPCI UPI Brand Guildeline](https://www.npci.org.in/uploads/UPI_Cash_Point_Brand_Guidlines_acefe6e3a7.pdf)

---

**Last Updated:** January 2026
